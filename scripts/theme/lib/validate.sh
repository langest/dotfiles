#!/usr/bin/env bash

# Shared validation helpers for theme data.

is_hex_color() {
  local value="$1"
  [[ "$value" =~ ^#[0-9A-Fa-f]{6}$ ]]
}

is_rgb_triplet() {
  local value="$1"
  [[ "$value" =~ ^([0-9]{1,3}),([0-9]{1,3}),([0-9]{1,3})$ ]] || return 1
  local r="${BASH_REMATCH[1]}"
  local g="${BASH_REMATCH[2]}"
  local b="${BASH_REMATCH[3]}"
  (( r <= 255 && g <= 255 && b <= 255 ))
}

validate_colors_toml_strict() {
  local colors_file="$1"
  local line

  [[ -f "$colors_file" ]] || return 1

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -n "${line//[[:space:]]/}" ]] || continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue

    if [[ ! "$line" =~ ^[[:space:]]*[A-Za-z0-9_]+[[:space:]]*=[[:space:]]*\"#[0-9A-Fa-f]{6}\"[[:space:]]*(#.*)?$ ]]; then
      echo "Invalid colors.toml line (only #RRGGBB values allowed): $line" >&2
      return 1
    fi
  done <"$colors_file"
}

get_color_from_toml() {
  local colors_file="$1"
  local key="$2"
  local value=""

  validate_colors_toml_strict "$colors_file" || return 1

  value="$(grep -E "^${key}[[:space:]]*=" "$colors_file" 2>/dev/null | head -n1 | sed -E 's/.*\"(#[0-9A-Fa-f]{6})\".*/\1/')"
  [[ -n "$value" ]] || return 1
  is_hex_color "$value" || return 1
  printf '%s\n' "$value"
}

is_safe_sway_theme_line() {
  local line="$1"
  [[ "$line" =~ ^client\.(focused|focused_inactive|unfocused|urgent|placeholder)[[:space:]]+#[0-9A-Fa-f]{6}[[:space:]]+#[0-9A-Fa-f]{6}[[:space:]]+#[0-9A-Fa-f]{6}[[:space:]]+#[0-9A-Fa-f]{6}[[:space:]]+#[0-9A-Fa-f]{6}[[:space:]]*$ ]]
}

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

hex_to_rgb() {
  local hex="${1#\#}"
  printf "%d,%d,%d" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

rgb_to_hex() {
  local rgb="$1"
  printf '#%02x%02x%02x' ${rgb//,/ }
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

build_sed_substitutions_from_toml() {
  local colors_file="$1"
  local sed_script="$2"
  local line key value

  validate_colors_toml_strict "$colors_file" || return 1

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -n "${line//[[:space:]]/}" ]] || continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue

    [[ "$line" =~ ^[[:space:]]*([A-Za-z0-9_]+)[[:space:]]*=[[:space:]]*\"(#[0-9A-Fa-f]{6})\" ]] || continue
    key="${BASH_REMATCH[1]}"
    value="${BASH_REMATCH[2]}"

    printf 's|{{ %s }}|%s|g\n' "$key" "$value" >>"$sed_script"
    printf 's|{{ %s_strip }}|%s|g\n' "$key" "${value#\#}" >>"$sed_script"
    printf 's|{{ %s_rgb }}|%s|g\n' "$key" "$(hex_to_rgb "$value")" >>"$sed_script"
  done <"$colors_file"
}

is_safe_sway_theme_line() {
  local line="$1"
  [[ "$line" =~ ^client\.(focused|focused_inactive|unfocused|urgent|placeholder)[[:space:]]+#[0-9A-Fa-f]{6}[[:space:]]+#[0-9A-Fa-f]{6}[[:space:]]+#[0-9A-Fa-f]{6}[[:space:]]+#[0-9A-Fa-f]{6}[[:space:]]+#[0-9A-Fa-f]{6}[[:space:]]*$ ]]
}

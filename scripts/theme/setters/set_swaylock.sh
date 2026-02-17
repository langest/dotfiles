#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/validate.sh"

theme_dir="$HOME/.config/omarchy/current/theme"
source_file="$theme_dir/swaylock.color"
colors_file="$theme_dir/colors.toml"

color=""
if [[ -f "$source_file" ]]; then
  color="$(tr -d '[:space:]' <"$source_file")"
fi

if [[ -z "$color" && -f "$colors_file" ]]; then
  if color_hex="$(get_color_from_toml "$colors_file" background 2>/dev/null)"; then
    color="${color_hex#\#}"
  fi
fi

if [[ -z "$color" ]]; then
  exit 0
fi

normalized_color="${color#\#}"
if ! is_hex_color "#$normalized_color"; then
  echo "Invalid swaylock color: $color" >&2
  exit 1
fi

target_dir="$HOME/.config/swaylock"
target_file="$target_dir/color"
mkdir -p "$target_dir"
printf '%s\n' "$normalized_color" >"$target_file"

echo "swaylock theme applied"

#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/validate.sh"

theme_dir="$HOME/.config/omarchy/current/theme"
source_file="$theme_dir/swaylock.color"

if [[ ! -f "$source_file" ]]; then
  exit 0
fi

color="$(tr -d '[:space:]' <"$source_file")"
if ! is_hex_color "#$color"; then
  echo "Invalid swaylock color in $source_file" >&2
  exit 1
fi

target_dir="$HOME/.config/swaylock"
target_file="$target_dir/color"
mkdir -p "$target_dir"
printf '%s\n' "$color" >"$target_file"

echo "swaylock theme applied"

#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/lib/validate.sh"

color_file_runtime="$HOME/.config/swaylock/color"
color_file_theme="$HOME/.config/omarchy/current/theme/swaylock.color"

color="847674"

if [[ -f "$color_file_runtime" ]]; then
  candidate="$(tr -d '[:space:]' <"$color_file_runtime")"
  if is_hex_color "#$candidate"; then
    color="$candidate"
  fi
elif [[ -f "$color_file_theme" ]]; then
  candidate="$(tr -d '[:space:]' <"$color_file_theme")"
  if is_hex_color "#$candidate"; then
    color="$candidate"
  fi
fi

exec swaylock -f -c "$color"

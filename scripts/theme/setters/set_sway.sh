#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/validate.sh"

theme_file="$HOME/.config/omarchy/current/theme/sway.theme"

if [[ ! -f "$theme_file" ]]; then
  exit 0
fi

while IFS= read -r line; do
  [[ -n "$line" && "$line" != \#* ]] || continue
  if ! is_safe_sway_theme_line "$line"; then
    echo "Skipping unsafe sway theme line: $line" >&2
    continue
  fi
  swaymsg "$line" >/dev/null
done <"$theme_file"

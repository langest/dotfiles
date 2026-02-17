#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
themes_path="$HOME/.config/omarchy/themes"

"$script_dir/sync_builtin.sh" >/dev/null

if [[ ! -d "$themes_path" ]]; then
  exit 0
fi

find "$themes_path" -mindepth 1 -maxdepth 1 \( -type d -o -type l \) -printf '%f\n' | sort -u | while read -r name; do
  [[ -n "$name" ]] || continue
  echo "$name"
done

#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
theme_name_path="$HOME/.config/omarchy/current/theme.name"

if [[ ! -f "$theme_name_path" ]]; then
  echo "No current theme set"
  exit 1
fi

"$script_dir/set.sh" "$(cat "$theme_name_path")"

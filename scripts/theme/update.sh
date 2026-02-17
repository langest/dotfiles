#!/usr/bin/env bash
set -euo pipefail

themes_dir="$HOME/.config/omarchy/themes"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
omarchy_path="${OMARCHY_PATH:-$HOME/repos/omarchy}"

if [[ -d "$omarchy_path/.git" ]]; then
  echo "Updating official themes source: $omarchy_path"
  git -C "$omarchy_path" pull --ff-only
fi

"$script_dir/sync_builtin.sh"

if [[ ! -d "$themes_dir" ]]; then
  exit 0
fi

for dir in "$themes_dir"/*; do
  [[ -L "$dir" ]] && continue
  [[ -d "$dir/.git" ]] || continue
  echo "Updating: $(basename "$dir")"
  git -C "$dir" pull --ff-only
done

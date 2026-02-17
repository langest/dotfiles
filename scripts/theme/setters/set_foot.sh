#!/usr/bin/env bash
set -euo pipefail

theme_dir="$HOME/.config/omarchy/current/theme"
source_file="$theme_dir/foot.ini"

if [[ ! -f "$source_file" ]]; then
  exit 0
fi

foot_dir="$HOME/.config/foot"
target_file="$foot_dir/omarchy-theme.ini"

mkdir -p "$foot_dir"
cp "$source_file" "$target_file"

echo "foot theme applied"

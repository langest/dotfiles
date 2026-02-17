#!/usr/bin/env bash
set -euo pipefail

theme_dir="$HOME/.config/omarchy/current/theme"
source_file="$theme_dir/wofi.css"

if [[ ! -f "$source_file" ]]; then
  exit 0
fi

wofi_dir="$HOME/.config/wofi"
target_file="$wofi_dir/style.css"

mkdir -p "$wofi_dir"
cp "$source_file" "$target_file"

echo "wofi theme applied"

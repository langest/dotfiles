#!/usr/bin/env bash
set -euo pipefail

theme_dir="$HOME/.config/omarchy/current/theme"
source_file="$theme_dir/nvim.vim"

if [[ ! -f "$source_file" ]]; then
  exit 0
fi

nvim_dir="$HOME/.config/nvim"
target_file="$nvim_dir/omarchy-theme.vim"

mkdir -p "$nvim_dir"
cp "$source_file" "$target_file"

echo "nvim theme applied"

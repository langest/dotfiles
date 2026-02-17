#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${1:-}" ]]; then
  echo "Usage: remove.sh <theme-name>"
  exit 1
fi

theme_name="$1"
theme_path="$HOME/.config/omarchy/themes/$theme_name"

if [[ ! -d "$theme_path" ]]; then
  echo "Theme '$theme_name' not found in ~/.config/omarchy/themes"
  exit 1
fi

rm -rf "$theme_path"
echo "Removed theme: $theme_name"

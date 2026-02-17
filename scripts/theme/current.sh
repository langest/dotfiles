#!/usr/bin/env bash
set -euo pipefail

theme_name_path="$HOME/.config/omarchy/current/theme.name"

if [[ -f "$theme_name_path" ]]; then
  cat "$theme_name_path"
else
  echo "unknown"
fi

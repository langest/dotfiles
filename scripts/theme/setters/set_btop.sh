#!/usr/bin/env bash
set -euo pipefail

theme_dir="$HOME/.config/omarchy/current/theme"
source_file="$theme_dir/btop.theme"
target_file="$HOME/.config/btop/themes/omarchy.theme"

if [[ ! -f "$source_file" ]]; then
  exit 0
fi

mkdir -p "$(dirname "$target_file")"
cp "$source_file" "$target_file"
echo "btop theme applied"

btop_dir="$HOME/.config/btop"
config_file="$btop_dir/btop.conf"
mkdir -p "$btop_dir"

if [[ -f "$config_file" ]]; then
  if grep -q '^color_theme[[:space:]]*=' "$config_file"; then
    sed -i 's/^color_theme[[:space:]]*=.*/color_theme = "omarchy"/' "$config_file"
  else
    printf 'color_theme = "omarchy"\n' >>"$config_file"
  fi
else
  cat >"$config_file" <<'EOF'
color_theme = "omarchy"
theme_background = True
truecolor = True
EOF
fi

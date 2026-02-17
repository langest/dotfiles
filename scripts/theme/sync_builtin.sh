#!/usr/bin/env bash
set -euo pipefail

omarchy_path="${OMARCHY_PATH:-$HOME/repos/omarchy}"
builtin_themes_path="$omarchy_path/themes"
themes_path="$HOME/.config/omarchy/themes"

mkdir -p "$themes_path"

if [[ ! -d "$builtin_themes_path" ]]; then
  exit 0
fi

for builtin in "$builtin_themes_path"/*; do
  [[ -d "$builtin" ]] || continue
  name="$(basename "$builtin")"
  target="$themes_path/$name"

  if [[ -e "$target" || -L "$target" ]]; then
    continue
  fi

  ln -s "$builtin" "$target"
done

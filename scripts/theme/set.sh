#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${1:-}" ]]; then
  echo "Usage: set.sh <theme-name>"
  exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/lib/validate.sh"

current_theme_path="$HOME/.config/omarchy/current/theme"
next_theme_path="$HOME/.config/omarchy/current/next-theme"
theme_name_path="$HOME/.config/omarchy/current/theme.name"
themes_path="$HOME/.config/omarchy/themes"
templates_dir="$repo_root/config/omarchy/themed"
user_templates_dir="$HOME/.config/omarchy/themed"
colors_file="$next_theme_path/colors.toml"

copy_theme_data() {
  if [[ ! -f "$theme_path/colors.toml" ]]; then
    echo "Theme '$theme_name' is missing colors.toml" >&2
    return 1
  fi

  cp "$theme_path/colors.toml" "$next_theme_path/colors.toml"
  validate_colors_toml_strict "$next_theme_path/colors.toml"

  # Backgrounds are static assets, not executed; copy common image formats only.
  if [[ -d "$theme_path/backgrounds" ]]; then
    mkdir -p "$next_theme_path/backgrounds"
    for bg in "$theme_path/backgrounds"/*; do
      [[ -f "$bg" ]] || continue
      case "${bg##*.}" in
        jpg|jpeg|png|webp|gif|JPG|JPEG|PNG|WEBP|GIF) cp "$bg" "$next_theme_path/backgrounds/" ;;
      esac
    done
  fi
}

generate_templates() {
  if [[ ! -f "$colors_file" ]]; then
    return 0
  fi

  local sed_script
  sed_script="$(mktemp)"
  build_sed_substitutions_from_toml "$colors_file" "$sed_script"

  shopt -s nullglob
  for tpl in "$user_templates_dir"/*.tpl "$templates_dir"/*.tpl; do
    local output_path
    output_path="$next_theme_path/$(basename "$tpl" .tpl)"
    # Generated template output always wins over theme-provided files.
    sed -f "$sed_script" "$tpl" >"$output_path"
  done

  rm -f "$sed_script"
}

theme_name="$(echo "$1" | sed -E 's/<[^>]+>//g' | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
"$script_dir/sync_builtin.sh" >/dev/null
theme_path="$themes_path/$theme_name"

if [[ ! -d "$theme_path" ]]; then
  echo "Theme '$theme_name' does not exist"
  exit 1
fi

rm -rf "$next_theme_path"
mkdir -p "$next_theme_path"
copy_theme_data
generate_templates

rm -rf "$current_theme_path"
mv "$next_theme_path" "$current_theme_path"
echo "$theme_name" >"$theme_name_path"

"$script_dir/setters/set_sway.sh"
"$script_dir/setters/set_swaylock.sh"
"$script_dir/setters/set_foot.sh"
"$script_dir/setters/set_nvim.sh"
"$script_dir/setters/set_wofi.sh"
"$script_dir/setters/set_btop.sh"
"$script_dir/setters/set_wallpaper.sh"
"$script_dir/setters/set_chromium.sh"
"$script_dir/setters/set_firefox.sh"

if pgrep -x waybar >/dev/null 2>&1; then
  pkill -x -SIGUSR2 waybar
fi

echo "Theme set: $theme_name"

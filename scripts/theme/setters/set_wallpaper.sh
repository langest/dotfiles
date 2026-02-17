#!/usr/bin/env bash
set -euo pipefail

backgrounds_dir="$HOME/.config/omarchy/current/theme/backgrounds"

if [[ ! -d "$backgrounds_dir" ]]; then
  echo "Theme wallpaper skipped: no backgrounds directory"
  exit 0
fi

mapfile -t wallpapers < <(
  find "$backgrounds_dir" -mindepth 1 -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \) \
    | sort
)

if [[ ${#wallpapers[@]} -eq 0 ]]; then
  echo "Theme wallpaper skipped: no images in $backgrounds_dir"
  exit 0
fi

mapfile -t outputs < <(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name')

if [[ ${#outputs[@]} -eq 0 ]]; then
  echo "Theme wallpaper skipped: no active sway outputs"
  exit 0
fi

if pgrep -x swaybg >/dev/null 2>&1; then
  pkill -x swaybg
fi

mapfile -t shuffled_wallpapers < <(printf '%s\n' "${wallpapers[@]}" | shuf)
wallpaper_count="${#shuffled_wallpapers[@]}"

for idx in "${!outputs[@]}"; do
  output="${outputs[$idx]}"
  wallpaper="${shuffled_wallpapers[$((idx % wallpaper_count))]}"
  swaybg -o "$output" -i "$wallpaper" -m fill >/dev/null 2>&1 &
done

echo "Theme wallpaper applied (${#outputs[@]} outputs, ${#wallpapers[@]} image(s))"

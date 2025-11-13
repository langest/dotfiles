#!/usr/bin/env bash
# File: `scripts/t16/wallpaper_tiling.sh`
# Perfectly aligned tiling across combined monitor geometry.
set -euo pipefail
source "$(dirname "$0")/monitor_constants.sh"

TILING_DIR="${TILING_DIR:-$HOME/Pictures/tiling}"
[ -d "$TILING_DIR" ] || { echo "Missing tiling dir: $TILING_DIR" >&2; exit 1; }

pkill -x swaybg 2>/dev/null || true

WALLPAPER=$(find "$TILING_DIR" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | shuf -n 1)
[ -n "${WALLPAPER:-}" ] || { echo "No images" >&2; exit 1; }

# Require ImageMagick.
command -v convert >/dev/null || { echo "ImageMagick convert not found" >&2; exit 1; }

read -r TOTAL_W TOTAL_H < <(total_bbox)

# Build full tiled canvas.
FULL_IMG="/tmp/tiling_full.png"
convert -size "${TOTAL_W}x${TOTAL_H}" tile:"$WALLPAPER" "$FULL_IMG"

# Per-output crop preserves alignment.
for m in "${MONITOR_LIST[@]}"; do
  read -r EW EH < <(effective_dims "$m")
  X=${MONITOR_POSX[$m]}
  Y=${MONITOR_POSY[$m]}
  CROP_IMG="/tmp/tiling_${m}.png"
  convert "$FULL_IMG" -crop "${EW}x${EH}+${X}+${Y}" +repage "$CROP_IMG"
  swaybg -o "$m" -i "$CROP_IMG" -m stretch &
done

wait
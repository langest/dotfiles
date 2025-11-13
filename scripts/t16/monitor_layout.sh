#!/usr/bin/env bash
# Apply layout using shared constants.
set -euo pipefail
source "$(dirname "$0")/monitor_constants.sh"

for m in "${MONITOR_LIST[@]}"; do
  mode="${MONITOR_MODE[$m]}"
  transform="${MONITOR_TRANSFORM[$m]}"
  x=${MONITOR_POSX[$m]}
  y=${MONITOR_POSY[$m]}
  swaymsg output "$m" mode "$mode" transform "$transform" position "$x" "$y"
done
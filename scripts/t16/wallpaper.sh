#!/usr/bin/env bash

LANDSCAPE_DIR="$HOME/pictures/wps"
PORTRAIT_DIR="$HOME/pictures/wps_portrait"

# Get all active outputs and their rotation
swaymsg -t get_outputs | jq -c '.[] | select(.active)' | while read -r output; do
  NAME=$(echo "$output" | jq -r '.name')
  TRANSFORM=$(echo "$output" | jq -r '.transform')

  # Portrait if rotated 90 or 270 degrees
  if [[ "$TRANSFORM" == "90" || "$TRANSFORM" == "270" ]]; then
    DIR="$PORTRAIT_DIR"
  else
    DIR="$LANDSCAPE_DIR"
  fi

  WALLPAPER=$(find "$DIR" -type f | shuf -n 1)
  if [ -n "$WALLPAPER" ]; then
    swaybg -o "$NAME" -i "$WALLPAPER" 2>/dev/null &
  fi
done
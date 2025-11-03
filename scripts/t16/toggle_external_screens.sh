#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/pictures/wps"
OUTPUT="HDMI-A-1"

# Get current state of HDMI-A-1
STATE=$(swaymsg -t get_outputs | grep -A5 "\"name\": \"$OUTPUT\"" | grep '"active": true')

if [ -n "$STATE" ]; then
  swaymsg output "$OUTPUT" disable
else
  swaymsg output "$OUTPUT" enable resolution 1920x1200 position 1920,0

  WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
  if [ -n "$WALLPAPER" ]; then
    swaybg -o "$OUTPUT" -i "$WALLPAPER" &
  fi
fi
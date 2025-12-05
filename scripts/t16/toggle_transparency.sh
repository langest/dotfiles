#!/bin/bash

# Check current transparency mark and cycle through levels
if swaymsg -t get_tree | jq -e '.. | select(.focused? == true) | .marks[]? | select(. == "opacity_1")' > /dev/null; then
  swaymsg opacity 0.8
  swaymsg unmark opacity_1
  swaymsg mark opacity_2
elif swaymsg -t get_tree | jq -e '.. | select(.focused? == true) | .marks[]? | select(. == "opacity_2")' > /dev/null; then
  swaymsg opacity 0.6
  swaymsg unmark opacity_2
  swaymsg mark opacity_3
elif swaymsg -t get_tree | jq -e '.. | select(.focused? == true) | .marks[]? | select(. == "opacity_3")' > /dev/null; then
  swaymsg opacity 1
  swaymsg unmark opacity_3
else
  swaymsg opacity 0.87
  swaymsg mark opacity_1
fi
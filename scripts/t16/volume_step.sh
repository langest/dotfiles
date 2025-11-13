#!/usr/bin/env bash
# Snap volume to discrete steps.
# Usage: volume_step.sh up 5   or   volume_step.sh down 5
direction="$1"
STEP="${2:-5}"              # step in percent (integer)
SINK='@DEFAULT_AUDIO_SINK@'

# Get current volume (first floating number from wpctl output), scale to integer percent.
raw="$(wpctl get-volume $SINK | grep -E -o '[0-9]+\.[0-9]+' | head -1)"
[ -z "$raw" ] && exit 1
cur_pct=$(awk -v v="$raw" 'BEGIN{printf "%.0f", v*100}')

step=$STEP

if [ "$direction" = "up" ]; then
  if [ $((cur_pct % step)) -eq 0 ]; then
    new=$((cur_pct + step))
  else
    new=$(( ( (cur_pct / step) + 1 ) * step ))
  fi
elif [ "$direction" = "down" ]; then
  if [ $((cur_pct % step)) -eq 0 ]; then
    new=$((cur_pct - step))
  else
    new=$(( (cur_pct / step) * step ))
  fi
else
  echo "Usage: $0 {up|down} [step]" >&2
  exit 2
fi

# Clamp (0–150%) to avoid excessive amplification (adjust if you allow more).
[ $new -lt 0 ] && new=0
[ $new -gt 150 ] && new=150

# Convert back to 0.x form (two decimals) and set.
target=$(awk -v v="$new" 'BEGIN{printf "%.2f", v/100}')
wpctl set-volume $SINK "$target"
#!/usr/bin/env bash
# Toggle external monitors (DP-2, HDMI-A-1) and (re)assign all workspaces.

set -euo pipefail

EXT1="DP-2"
EXT2="HDMI-A-1"
INT="eDP-1"
LAYOUT_SCRIPT="$HOME/repos/dotfiles/scripts/t16/monitor_layout.sh"
LOCKFILE="/tmp/monitor_toggle.lock"

need_layout() { [[ -x "$LAYOUT_SCRIPT" ]] || { echo "Error: layout script missing: $LAYOUT_SCRIPT" >&2; exit 1; }; }

with_lock() {
  if [[ -f "$LOCKFILE" ]]; then
    local pid; pid=$(<"$LOCKFILE") || true
    if [[ -n "$pid" && -d "/proc/$pid" ]]; then exit 0; fi
  fi
  echo $$ >"$LOCKFILE"
  trap 'rm -f "$LOCKFILE"' EXIT
}

is_active() {
  swaymsg -t get_outputs | jq -r --arg name "$1" '(.[] | select(.name==$name) | .active // false) | tostring'
}

wait_for_active() {
  local out="$1" tries=30
  while [[ $(is_active "$out") != "true" && $tries -gt 0 ]]; do
    sleep 0.1; tries=$((tries-1))
  done
}

assign_all() {
  for w in 1 2 3 4 5 6; do
    swaymsg workspace "$w"
    swaymsg move workspace to output "$EXT1"
  done
  for w in 7 8 9 10 11 12; do
    swaymsg workspace "$w"
    swaymsg move workspace to output "$EXT2"
  done
  swaymsg workspace 0
  swaymsg move workspace to output "$INT"
}

need_layout
with_lock

active1=$(is_active "$EXT1")
active2=$(is_active "$EXT2")

if [[ "$active1" == "true" || "$active2" == "true" ]]; then
  swaymsg output "$EXT1" disable
  swaymsg output "$EXT2" disable
  notify-send -t 300 "External monitors: OFF"
else
  swaymsg output "$EXT1" enable
  swaymsg output "$EXT2" enable
  wait_for_active "$EXT1"
  wait_for_active "$EXT2"
  bash "$LAYOUT_SCRIPT"
  assign_all
  notify-send -t 300 "External monitors: ON"
fi

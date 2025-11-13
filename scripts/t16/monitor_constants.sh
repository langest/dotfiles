#!/usr/bin/env bash
# Format: name => mode WxH, transform, posX, posY
MONITOR_LIST=(DP-2 HDMI-A-1 eDP-1)

declare -A MONITOR_MODE MONITOR_TRANSFORM MONITOR_POSX MONITOR_POSY
MONITOR_MODE[DP-2]="1920x1200";  MONITOR_TRANSFORM[DP-2]="270";    MONITOR_POSX[DP-2]=0;    MONITOR_POSY[DP-2]=0
MONITOR_MODE[HDMI-A-1]="1920x1200"; MONITOR_TRANSFORM[HDMI-A-1]="normal"; MONITOR_POSX[HDMI-A-1]=1200; MONITOR_POSY[HDMI-A-1]=366
MONITOR_MODE[eDP-1]="1920x1200"; MONITOR_TRANSFORM[eDP-1]="normal"; MONITOR_POSX[eDP-1]=3120; MONITOR_POSY[eDP-1]=660

effective_dims() {
  local name="$1"
  local mode="${MONITOR_MODE[$name]}"
  local transform="${MONITOR_TRANSFORM[$name]}"
  local w="${mode%x*}"; local h="${mode#*x}"
  if [[ "$transform" == "90" || "$transform" == "270" ]]; then
    echo "$h $w"
  else
    echo "$w $h"
  fi
}

total_bbox() {
  local maxW=0 maxH=0
  for m in "${MONITOR_LIST[@]}"; do
    read -r ew eh < <(effective_dims "$m")
    local x=${MONITOR_POSX[$m]} y=${MONITOR_POSY[$m]}
    (( x + ew > maxW )) && maxW=$((x+ew))
    (( y + eh > maxH )) && maxH=$((y+eh))
  done
  echo "$maxW $maxH"
}
#!/bin/bash
xrandr --output HDMI1 --right-of eDP1 --auto --rotate left
xrandr --output HDMI2 --right-of HDMI1 --mode 1920x1200
xrandr --output eDP1 --off
#feh --randomize --recursive --bg-fill /home/langest/img/wps
/home/langest/.fehbg
bash `dirname "$0"`/wallpaper.sh


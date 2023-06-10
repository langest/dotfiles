#!/bin/bash

export DISPLAY=:0.0
export XAUTHORITY="/home/daniel/.Xauthority"
PID=$(pgrep xfce4-session)
export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ|cut -d= -f2-)

DIR_H="${HOME}/Pictures/wps"
DIR_V="${HOME}/Pictures/wps_portrait"

PIC1=$(find "$DIR_H" -type f \( -name '*.jpg' -o -name '*.png' \) | shuf -n 1)
PIC2=$(find "$DIR_H" -type f \( -name '*.jpg' -o -name '*.png' \) | shuf -n 1)
PIC3=$(find "$DIR_V" -type f \( -name '*.jpg' -o -name '*.png' \) | shuf -n 1)

#echo `date` 'Updating background' >> /home/daniel/.log/wallpaper.log

xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitoreDP1/workspace1/image-style -s 5
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitoreDP1/workspace1/last-image -s "$PIC1"

xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorHDMI1/workspace1/image-style -s 5
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorHDMI1/workspace1/last-image -s "$PIC2"

xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorHDMI2/workspace1/image-style -s 5
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorHDMI2/workspace1/last-image -s "$PIC3"

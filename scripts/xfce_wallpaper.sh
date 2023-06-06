#!/bin/bash

DIR_H="${HOME}/Pictures/wps"
DIR_V="${HOME}/Pictures/wps_portrait"

PIC1=$(find "$DIR_H" -type f \( -name '*.jpg' -o -name '*.png' \) | shuf -n 1)
PIC2=$(find "$DIR_H" -type f \( -name '*.jpg' -o -name '*.png' \) | shuf -n 1)
PIC3=$(find "$DIR_V" -type f \( -name '*.jpg' -o -name '*.png' \) | shuf -n 1)

echo "$PIC1"
echo "$PIC2"
echo "$PIC3"

xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitoreDP1/workspace1/last-image -s "$PIC1"
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitoreDP1/workspace1/image-style -s 5

xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorHDMI1/workspace1/last-image -s "$PIC2"
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorHDMI1/workspace1/image-style -s 5

xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorHDMI2/workspace1/last-image -s "$PIC3"
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorHDMI2/workspace1/image-style -s 5

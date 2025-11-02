#!/bin/bash
tmpbg="/tmp/screen.png"

scrot "$tmpbg"
convert "$tmpbg" -scale 10% -blur 0x2 -scale 1000% "$tmpbg"
slimlock

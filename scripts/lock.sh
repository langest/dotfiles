#!/bin/bash
tmpbg="/tmp/screen.png"

scrot "$tmpbg"
convert "$tmpbg" -scale 20% -scale 500% "$tmpbg"
slimlock

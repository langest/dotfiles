#!/bin/bash
tmpbg="/tmp/screen.png"

scrot "$tmpbg"
convert "$tmpbg" -scale 10% -scale 1000% "$tmpbg"
slimlock

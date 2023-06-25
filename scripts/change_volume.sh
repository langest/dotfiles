#!/bin/bash

# Fetch current volume
current_volume=$(amixer get Master | grep 'Mono:' | awk '{print $4}' | sed 's/\[\(.*\)%\]/\1/')

if [ "$1" = "increase" ]; then
    if [ $current_volume -lt 95 ]; then
        amixer set Master 5%+
    else
        amixer set Master 100%
    fi
elif [ "$1" = "decrease" ]; then
    if [ $current_volume -gt 5 ]; then
        amixer set Master 5%-
    else
        amixer set Master 0%
    fi
fi


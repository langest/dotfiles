#!/bin/bash

# Generate a random number between 0 and 99.
RANDOM_NUMBER=$((RANDOM % 100))

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


if (( RANDOM_NUMBER < 85 )); then
    "$SCRIPT_DIR/wallpaper.sh"
else
    "$SCRIPT_DIR/wallpaper_tiling.sh"
fi


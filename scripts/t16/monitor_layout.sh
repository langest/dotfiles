#!/usr/bin/env bash
# Arrange monitors in Sway: DP-2 (rotated 270°) | HDMI-A-1 (center) | eDP-1 (right)

# Left monitor (DP-2): rotated 270°, 1920x1200
swaymsg output DP-2 mode 1920x1200 transform 270 position 0 0

# Middle monitor (HDMI-A-1): to the right of rotated DP-2 (width 1200)
swaymsg output HDMI-A-1 mode 1920x1200 transform normal position 1200 366

# Right monitor (eDP-1): to the right of HDMI-A-1 (1200 + 1920 = 3120)
swaymsg output eDP-1 mode 1920x1200 transform normal position 3120 660
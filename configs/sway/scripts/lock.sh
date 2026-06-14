#!/usr/bin/env bash
# Lock screen with blurred wallpaper screenshot if imagemagick available

LOCK_IMG="/tmp/swaylock-blur.png"

if command -v grim &>/dev/null && command -v convert &>/dev/null; then
    grim "$LOCK_IMG" 2>/dev/null
    convert "$LOCK_IMG" -scale 10% -scale 1000% -fill "#1e1e2e" \
        -colorize 40 "$LOCK_IMG" 2>/dev/null
    swaylock -f --config ~/.config/swaylock/config --image "$LOCK_IMG"
else
    swaylock -f --config ~/.config/swaylock/config
fi

#!/usr/bin/env bash
# Weather popup — Louisville, KY

WEATHER=$(curl -fsSL --max-time 10 "https://wttr.in/Louisville+KY?format=4" 2>/dev/null \
    || echo "Weather unavailable")

yad --title="Weather — Louisville, KY" \
    --text="$WEATHER" \
    --button="Close":0 \
    --center \
    --width=400 \
    --height=200 \
    --no-markup \
    2>/dev/null || \
notify-send "Weather" "$WEATHER"

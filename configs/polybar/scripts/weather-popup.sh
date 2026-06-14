#!/usr/bin/env bash
# Show a wttr.in weather popup using yad. Toggle on/off with each click.

LOCK="/tmp/polybar-weather-popup.lock"
LOCATION="Louisville+KY"

if [[ -f "$LOCK" ]]; then
    kill "$(cat "$LOCK")" 2>/dev/null
    rm -f "$LOCK"
    exit 0
fi

# Fetch a compact 3-day forecast (plain text, no ANSI colors)
WEATHER=$(curl -fsSL --max-time 10 \
    "https://wttr.in/${LOCATION}?format=4" 2>/dev/null \
    || echo "Weather unavailable")

FORECAST=$(curl -fsSL --max-time 10 \
    "https://wttr.in/${LOCATION}?T&n" 2>/dev/null \
    || echo "Forecast unavailable")

yad --title="Louisville, KY" \
    --text="${WEATHER}\n\n${FORECAST}" \
    --no-buttons \
    --undecorated \
    --close-on-unfocus \
    --fixed \
    --on-top \
    --width=420 \
    --height=280 \
    --text-align=left \
    --fontname="monospace 10" &

PID=$!
echo $PID > "$LOCK"
wait $PID
rm -f "$LOCK"

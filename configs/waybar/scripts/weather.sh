#!/usr/bin/env bash
# Weather for Waybar — Louisville, KY — outputs JSON with tooltip forecast

LOCATION="Louisville+KY"
CACHE_TEXT="/tmp/waybar-weather-text.cache"
CACHE_TIP="/tmp/waybar-weather-tip.cache"
CACHE_AGE=600

now=$(date +%s)
text_age=$(( now - $(stat -c %Y "$CACHE_TEXT" 2>/dev/null || echo 0) ))

if [ -f "$CACHE_TEXT" ] && [ "$text_age" -lt "$CACHE_AGE" ]; then
    text=$(cat "$CACHE_TEXT")
    tip=$(cat "$CACHE_TIP" 2>/dev/null || echo "")
    printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$tip"
    exit 0
fi

text=$(curl -fsSL --max-time 8 "https://wttr.in/${LOCATION}?format=%c+%t" 2>/dev/null \
    | sed 's/\xef\xb8\x8f//g' | tr -d '\n' | tr -s ' ' | sed 's/^ *//;s/ *$//')

forecast=$(curl -fsSL --max-time 10 "https://wttr.in/${LOCATION}?format=3&period=1" 2>/dev/null \
    | sed 's/\xef\xb8\x8f//g' | head -7 | tr '\n' '\n')

if [ -z "$text" ]; then
    [ -f "$CACHE_TEXT" ] && text=$(cat "$CACHE_TEXT") || text="? --°F"
fi
if [ -z "$forecast" ]; then
    [ -f "$CACHE_TIP" ] && forecast=$(cat "$CACHE_TIP") || forecast="Forecast unavailable"
fi

# Escape for JSON
tip=$(echo "$forecast" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' '\n' | paste -sd '\\n' -)

echo "$text" > "$CACHE_TEXT"
echo "$forecast" > "$CACHE_TIP"

printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$tip"

#!/usr/bin/env bash
LOCATION="Louisville+KY"
CACHE_TEXT="/tmp/waybar-weather-text.cache"
CACHE_TIP="/tmp/waybar-weather-tip.cache"
CACHE_AGE=600

now=$(date +%s)
text_age=$(( now - $(stat -c %Y "$CACHE_TEXT" 2>/dev/null || echo 0) ))

if [ -f "$CACHE_TEXT" ] && [ "$text_age" -lt "$CACHE_AGE" ]; then
    text=$(cat "$CACHE_TEXT")
    tip=$(cat "$CACHE_TIP" 2>/dev/null || echo "Forecast unavailable")
    jq -cn --arg t "$text" --arg tip "$tip" '{"text":$t,"tooltip":$tip}'
    exit 0
fi

text=$(curl -fsSL --max-time 8 "https://wttr.in/${LOCATION}?format=%c+%t" 2>/dev/null \
    | sed 's/\xef\xb8\x8f//g' | tr -d '\n' | sed 's/^ *//;s/ *$//')

forecast=$(curl -fsSL --max-time 10 -H "Accept-Language: en" \
    "https://wttr.in/${LOCATION}?T&n&format=3" 2>/dev/null \
    | sed 's/\xef\xb8\x8f//g')

# Fall back to full ASCII forecast if format=3 gives nothing useful
if [ "$(echo "$forecast" | wc -l)" -lt 2 ]; then
    forecast=$(curl -fsSL --max-time 10 -H "Accept-Language: en" \
        "https://wttr.in/${LOCATION}?T&n" 2>/dev/null \
        | sed 's/\xef\xb8\x8f//g; s/\x1b\[[0-9;]*m//g' | head -25)
fi

[ -z "$text" ] && { [ -f "$CACHE_TEXT" ] && text=$(cat "$CACHE_TEXT") || text="? --°F"; }
[ -z "$forecast" ] && { [ -f "$CACHE_TIP" ] && forecast=$(cat "$CACHE_TIP") || forecast="Forecast unavailable"; }

echo "$text" > "$CACHE_TEXT"
echo "$forecast" > "$CACHE_TIP"

jq -cn --arg t "$text" --arg tip "$forecast" '{"text":$t,"tooltip":$tip}'

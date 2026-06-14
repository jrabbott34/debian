#!/usr/bin/env bash
# Fetch current weather for Louisville, KY from wttr.in

LOCATION="Louisville+KY"
CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/polybar-weather"
CACHE_TTL=600

now=$(date +%s)
if [[ -f "$CACHE_FILE" ]]; then
    age=$(( now - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0) ))
    if [[ $age -lt $CACHE_TTL ]]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# %c = condition icon, %f = temperature in Fahrenheit
# Strip U+FE0F (emoji variation selector) that polybar can't render
result=$(curl -sf --max-time 8 "https://wttr.in/${LOCATION}?format=%c+%f" 2>/dev/null \
    | sed 's/\xef\xb8\x8f//g' \
    | tr -d '\n')

if [[ -n "$result" ]]; then
    echo -n "$result" > "$CACHE_FILE"
    echo "$result"
elif [[ -f "$CACHE_FILE" ]]; then
    cat "$CACHE_FILE"
else
    echo " N/A"
fi

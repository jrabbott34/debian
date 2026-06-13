#!/usr/bin/env bash
# Fetch current weather for Louisville, KY from wttr.in
# Returns: icon + temperature (e.g. "⛅ 72°F")

LOCATION="Louisville+KY"
CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/polybar-weather"
CACHE_TTL=600  # seconds

now=$(date +%s)
if [[ -f "$CACHE_FILE" ]]; then
    cached_time=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)
    age=$(( now - cached_time ))
    if [[ $age -lt $CACHE_TTL ]]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

result=$(curl -sf --max-time 8 "https://wttr.in/${LOCATION}?format=%c+%t" 2>/dev/null)

if [[ -n "$result" ]]; then
    # Convert Celsius to Fahrenheit if needed (wttr.in returns °C by default without u flag)
    # Use format=3 for US units
    result=$(curl -sf --max-time 8 "https://wttr.in/${LOCATION}?format=%c+%f" 2>/dev/null)
    echo -n "$result" > "$CACHE_FILE"
    echo "$result"
else
    # Show cached value if fetch failed, or fallback
    if [[ -f "$CACHE_FILE" ]]; then
        cat "$CACHE_FILE"
    else
        echo " N/A"
    fi
fi

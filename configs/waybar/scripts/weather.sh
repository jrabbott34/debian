#!/usr/bin/env bash
# Weather for Waybar — Louisville, KY — wttr.in

CACHE_FILE="/tmp/waybar-weather.cache"
CACHE_AGE=600  # 10 minutes

if [ -f "$CACHE_FILE" ]; then
    age=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0) ))
    if [ "$age" -lt "$CACHE_AGE" ]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

result=$(curl -fsSL --max-time 8 "https://wttr.in/Louisville+KY?format=%c+%t" 2>/dev/null)
if [ -z "$result" ]; then
    # Try cached value even if stale
    [ -f "$CACHE_FILE" ] && cat "$CACHE_FILE" && exit 0
    echo "? --°F"
    exit 0
fi

# Strip U+FE0F variation selector and trim whitespace
cleaned=$(echo "$result" | sed 's/\xef\xb8\x8f//g' | tr -s ' ' | sed 's/^ *//;s/ *$//')
echo "$cleaned" | tee "$CACHE_FILE"

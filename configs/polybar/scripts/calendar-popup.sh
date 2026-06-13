#!/usr/bin/env bash
# Toggle a yad calendar popup anchored near the polybar clock.
# A second click (or pressing Escape) closes it.

LOCK="/tmp/polybar-calendar.lock"

if [[ -f "$LOCK" ]]; then
    # Already open — close it
    kill "$(cat "$LOCK")" 2>/dev/null
    rm -f "$LOCK"
    exit 0
fi

# Open calendar; store PID so a second click can dismiss it
yad --calendar \
    --no-buttons \
    --undecorated \
    --close-on-unfocus \
    --fixed \
    --on-top \
    --title="" &

PID=$!
echo $PID > "$LOCK"
wait $PID
rm -f "$LOCK"

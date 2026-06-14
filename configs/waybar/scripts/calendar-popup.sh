#!/usr/bin/env bash
# Calendar toggle popup

# Kill existing yad calendar if running
if pkill -f "yad --calendar" 2>/dev/null; then
    exit 0
fi

yad --calendar \
    --title="Calendar" \
    --undecorated \
    --close-on-unfocus \
    --no-buttons \
    --width=200 \
    --height=200 \
    2>/dev/null &

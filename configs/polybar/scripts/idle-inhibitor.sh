#!/usr/bin/env bash
# Software idle inhibitor for X11 (xdotool keeps activity alive)
# State stored in /tmp so it resets on reboot.

STATE_FILE="/tmp/polybar-idle-inhibitor"
XDOTOOL_PID_FILE="/tmp/polybar-idle-inhibitor-xdotool.pid"

ICON_ON="  󰈈 "   # screen-lock-off  (inhibiting)
ICON_OFF=" 󰈉 "   # screen-lock-on   (normal)

start_inhibit() {
    # Simulate mouse jitter every 55s to prevent screensaver/dpms
    (
        while [[ -f "$STATE_FILE" ]]; do
            xdotool mousemove_relative -- 0 0 2>/dev/null
            sleep 55
        done
    ) &
    echo $! > "$XDOTOOL_PID_FILE"
    echo "on" > "$STATE_FILE"
}

stop_inhibit() {
    if [[ -f "$XDOTOOL_PID_FILE" ]]; then
        kill "$(cat "$XDOTOOL_PID_FILE")" 2>/dev/null || true
        rm -f "$XDOTOOL_PID_FILE"
    fi
    rm -f "$STATE_FILE"
}

case "${1:-status}" in
    toggle)
        if [[ -f "$STATE_FILE" ]]; then
            stop_inhibit
        else
            start_inhibit
        fi
        ;;
    status)
        if [[ -f "$STATE_FILE" ]]; then
            echo -n "$ICON_ON"
        else
            echo -n "$ICON_OFF"
        fi
        ;;
esac

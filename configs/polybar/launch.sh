#!/usr/bin/env bash
# Kill any running polybar instances then relaunch
killall -q polybar
while pgrep -u "$UID" -x polybar > /dev/null; do sleep 0.1; done

# Launch on every connected monitor
if type "xrandr" > /dev/null 2>&1; then
    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        MONITOR=$m polybar --reload mainbar &
    done
else
    polybar --reload mainbar &
fi

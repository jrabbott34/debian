#!/usr/bin/env bash
# Rofi power menu

chosen=$(printf "  Lock\n  Logout\n  Suspend\n  Reboot\n  Shutdown" \
    | rofi -dmenu \
           -p "Power" \
           -i \
           -no-fixed-num-lines \
           -width 20 \
           2>/dev/null)

case "$chosen" in
    "  Lock")     swaylock -f -c 1e1e2e ;;
    "  Logout")   swaymsg exit ;;
    "  Suspend")  systemctl suspend ;;
    "  Reboot")   systemctl reboot ;;
    "  Shutdown") systemctl poweroff ;;
esac

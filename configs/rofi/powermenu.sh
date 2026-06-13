#!/usr/bin/env bash
# Rofi power menu

LOCK="  Lock"
LOGOUT="  Logout"
SUSPEND="  Suspend"
REBOOT="  Restart"
SHUTDOWN="  Shutdown"

chosen=$(echo -e "$LOCK\n$LOGOUT\n$SUSPEND\n$REBOOT\n$SHUTDOWN" \
    | rofi -dmenu \
           -p "  Power" \
           -config "$HOME/.config/rofi/powermenu.rasi" \
           -no-fixed-num-lines \
           -theme-str 'window { width: 220px; }')

case "$chosen" in
    "$LOCK")     i3lock -c 2E3440 ;;
    "$LOGOUT")   i3-msg exit ;;
    "$SUSPEND")  systemctl suspend ;;
    "$REBOOT")   systemctl reboot ;;
    "$SHUTDOWN") systemctl poweroff ;;
esac

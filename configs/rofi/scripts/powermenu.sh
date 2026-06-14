#!/usr/bin/env bash
# Rofi power menu

chosen=$(printf "󰌾  Lock\n󰍃  Logout\n⏾  Suspend\n󰜉  Reboot\n󰐥  Shutdown" \
    | rofi -dmenu \
           -p "󰐥 Power" \
           -i \
           -no-fixed-num-lines \
           -width 20 \
           -theme-str 'configuration { show-icons: false; }' \
           2>/dev/null)

case "$chosen" in
    "󰌾  Lock")     swaylock -f --config ~/.config/swaylock/config ;;
    "󰍃  Logout")   swaymsg exit ;;
    "⏾  Suspend")  systemctl suspend ;;
    "󰜉  Reboot")   systemctl reboot ;;
    "󰐥  Shutdown") systemctl poweroff ;;
esac

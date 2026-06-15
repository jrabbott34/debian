#!/usr/bin/env bash
# Show all sway keybinds in a rofi menu by parsing the config

grep -E '^\s*bindsym' ~/.config/sway/config \
    | sed 's/^\s*bindsym\s*//' \
    | sed 's/\$mod/Super/g' \
    | awk '{key=$1; $1=""; printf "%-30s →%s\n", key, $0}' \
    | sort \
    | rofi -dmenu \
           -p "󰌌 Keybinds" \
           -i \
           -no-fixed-num-lines \
           -theme-str 'configuration { show-icons: false; } window { width: 900px; } listview { lines: 16; }' \
           2>/dev/null

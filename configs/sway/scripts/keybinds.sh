#!/usr/bin/env bash
# Show all sway keybinds in a rofi menu

swaymsg -t get_bindings | jq -r '.[] | "\(.event_state_mask | join("+"))+\(.symbol // .input_code | tostring)  →  \(.command)"' \
    | sort \
    | sed 's/^+//' \
    | rofi -dmenu \
           -p "󰌌 Keybinds" \
           -i \
           -no-fixed-num-lines \
           -theme-str 'configuration { show-icons: false; } window { width: 900px; } listview { lines: 16; }' \
           2>/dev/null

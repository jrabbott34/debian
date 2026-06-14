#!/usr/bin/env bash
LOCK_IMG="/tmp/swaylock-blur.png"

if command -v grim &>/dev/null && command -v convert &>/dev/null; then
    grim "$LOCK_IMG" 2>/dev/null && \
    convert "$LOCK_IMG" -blur 0x8 -fill "#1e1e2e" -colorize 50 "$LOCK_IMG" 2>/dev/null
fi

ARGS=(
    -f
    --indicator-radius 100
    --indicator-thickness 10
    --ring-color cba6f7
    --ring-clear-color 89b4fa
    --ring-ver-color a6e3a1
    --ring-wrong-color f38ba8
    --inside-color 1e1e2e88
    --inside-ver-color 31324488
    --inside-wrong-color f38ba822
    --inside-clear-color 1e1e2e88
    --line-color 00000000
    --line-clear-color 00000000
    --line-ver-color 00000000
    --line-wrong-color 00000000
    --key-hl-color cba6f7
    --bs-hl-color f38ba8
    --separator-color 00000000
    --text-color cdd6f4
    --text-ver-color cdd6f4
    --text-wrong-color f38ba8
    --text-clear-color cdd6f4
    --font "JetBrainsMono Nerd Font"
    --font-size 18
)

if [[ -f "$LOCK_IMG" ]]; then
    swaylock "${ARGS[@]}" --image "$LOCK_IMG"
else
    swaylock "${ARGS[@]}" --color 1e1e2e
fi

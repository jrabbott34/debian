#!/usr/bin/env bash
# Set wallpaper with swaybg. Pass --random to pick one at random.

WALLPAPER_DIR="$HOME/.config/wallpapers"
FALLBACK_COLOR="#1e1e2e"

if [[ "${1:-}" == "--random" ]]; then
    mapfile -t WALLS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) 2>/dev/null)
    if [[ ${#WALLS[@]} -gt 0 ]]; then
        IMG="${WALLS[RANDOM % ${#WALLS[@]}]}"
    fi
else
    IMG=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" \) 2>/dev/null | head -1)
fi

pkill swaybg 2>/dev/null || true

if [[ -n "${IMG:-}" && -f "$IMG" ]]; then
    swaybg -i "$IMG" -m fill &
else
    swaybg -c "$FALLBACK_COLOR" &
fi

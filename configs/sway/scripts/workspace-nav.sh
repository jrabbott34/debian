#!/usr/bin/env bash
# Navigate to adjacent workspace by number, creating it if empty
# Usage: workspace-nav.sh next|prev

DIRECTION="${1:-next}"
CURRENT=$(swaymsg -t get_workspaces | jq '.[] | select(.focused) | .num')

if [[ "$DIRECTION" == "next" ]]; then
    TARGET=$(( CURRENT + 1 ))
    [[ $TARGET -gt 10 ]] && TARGET=1
else
    TARGET=$(( CURRENT - 1 ))
    [[ $TARGET -lt 1 ]] && TARGET=10
fi

swaymsg workspace number "$TARGET"

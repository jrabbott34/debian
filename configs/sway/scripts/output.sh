#!/usr/bin/env bash
# Adjust output layout depending on whether the dock (DP-6) is connected.
# DP-6 sits above eDP-1 (laptop panel).

if swaymsg -t get_outputs | grep -q '"DP-6"'; then
    swaymsg 'output DP-6 pos 0 0'
    swaymsg 'output eDP-1 pos 0 1080'
else
    swaymsg 'output eDP-1 pos 0 0'
fi

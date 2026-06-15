#!/usr/bin/env bash
# Show an OSD notification for volume/brightness changes

TYPE="${1:-volume}"

case "$TYPE" in
    volume)
        VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
        MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -c MUTED)
        if [ "$MUTED" -gt 0 ]; then
            ICON="󰝟"
            MSG="Muted"
        elif [ "$VOL" -lt 33 ]; then
            ICON="󰕿"
            MSG="${VOL}%"
        elif [ "$VOL" -lt 66 ]; then
            ICON="󰖀"
            MSG="${VOL}%"
        else
            ICON="󰕾"
            MSG="${VOL}%"
        fi
        notify-send -t 1500 -h string:x-canonical-private-synchronous:volume \
            -h "int:value:${VOL}" "$ICON  Volume" "$MSG"
        ;;
    brightness)
        BRIGHT=$(brightnessctl get)
        MAX=$(brightnessctl max)
        PCT=$(( BRIGHT * 100 / MAX ))
        notify-send -t 1500 -h string:x-canonical-private-synchronous:brightness \
            -h "int:value:${PCT}" "󰃞  Brightness" "${PCT}%"
        ;;
esac

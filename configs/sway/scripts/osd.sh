#!/usr/bin/env bash
TYPE="${1:-volume}"

case "$TYPE" in
    volume)
        VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
        MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -c MUTED)
        if [ "$MUTED" -gt 0 ]; then
            ICON="󰝟"; MSG="Muted"
        elif [ "$VOL" -lt 33 ]; then
            ICON="󰕿"; MSG="${VOL}%"
        elif [ "$VOL" -lt 66 ]; then
            ICON="󰖀"; MSG="${VOL}%"
        else
            ICON="󰕾"; MSG="${VOL}%"
        fi
        BAR=$(printf '█%.0s' $(seq 1 $((VOL / 5))))
        notify-send -a osd -t 1500 "$ICON  Volume  ${VOL}%" "$BAR"
        ;;
    brightness)
        BRIGHT=$(brightnessctl get)
        MAX=$(brightnessctl max)
        PCT=$(( BRIGHT * 100 / MAX ))
        BAR=$(printf '█%.0s' $(seq 1 $((PCT / 5))))
        notify-send -a osd -t 1500 "󰃞  Brightness  ${PCT}%" "$BAR"
        ;;
esac

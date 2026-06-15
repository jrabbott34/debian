#!/usr/bin/env bash
TYPE="${1:-volume}"
ID_FILE="/tmp/osd-notify-id"

get_id() { [ -f "$ID_FILE" ] && cat "$ID_FILE" || echo 0; }

case "$TYPE" in
    volume)
        VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
        MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -c MUTED)
        if [ "$MUTED" -gt 0 ]; then ICON="󰝟"; MSG="Muted"
        elif [ "$VOL" -lt 33 ]; then ICON="󰕿"; MSG="${VOL}%"
        elif [ "$VOL" -lt 66 ]; then ICON="󰖀"; MSG="${VOL}%"
        else ICON="󰕾"; MSG="${VOL}%"; fi
        FILLED=$((VOL / 5))
        EMPTY=$((20 - FILLED))
        BAR="$(printf '▰%.0s' $(seq 1 $FILLED))$(printf '▱%.0s' $(seq 1 $EMPTY))"
        TITLE="$ICON  Volume  ${VOL}%"
        BODY="<span foreground='#89b4fa'>$BAR</span>"
        ;;
    brightness)
        BRIGHT=$(brightnessctl get)
        MAX=$(brightnessctl max)
        PCT=$(( BRIGHT * 100 / MAX ))
        FILLED=$((PCT / 5))
        EMPTY=$((20 - FILLED))
        BAR="$(printf '▰%.0s' $(seq 1 $FILLED))$(printf '▱%.0s' $(seq 1 $EMPTY))"
        TITLE="󰃞  Brightness  ${PCT}%"
        BODY="<span foreground='#fab387'>$BAR</span>"
        ;;
esac

ID=$(notify-send -p -r "$(get_id)" -t 1500 "$TITLE" "$BODY" 2>/dev/null)
echo "${ID:-0}" > "$ID_FILE"

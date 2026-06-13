#!/usr/bin/env bash
# Idle screen locker — runs in background from i3 autostart.
# Blanks display after 10 min idle, locks after 11 min.
# Skips lock while audio is playing.

BLANK_MS=600000   # 10 minutes
LOCK_MS=660000    # 11 minutes

audio_playing() {
    # Returns 0 (true) if any PulseAudio/PipeWire sink is running
    pactl list sink-inputs 2>/dev/null | grep -q "state: RUNNING"
}

while true; do
    idle=$(xprintidle 2>/dev/null || echo 0)

    if [[ $idle -ge $LOCK_MS ]]; then
        if ! audio_playing; then
            xset dpms force off
            i3lock -c 1e1e2e
        fi
    elif [[ $idle -ge $BLANK_MS ]]; then
        if ! audio_playing; then
            xset dpms force off
        fi
    fi

    sleep 30
done

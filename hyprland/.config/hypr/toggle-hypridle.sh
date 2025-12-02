#!/bin/bash

STATUS_FILE="/tmp/hypridle_mode_status"

get_mode() {
    if [ -f "$STATUS_FILE" ]; then
        cat "$STATUS_FILE"
    else
        echo "normal"
    fi
}

set_mode() {
    echo "$1" > "$STATUS_FILE"
    if [ "$1" == "normal" ]; then
        # Start hypridle if not running
        if ! pidof hypridle > /dev/null; then
            hypridle &
        fi
        notify-send "Hypridle" "Enabled (Normal Mode)"
    elif [ "$1" == "afk" ]; then
        # Stop hypridle
        killall hypridle
        notify-send "Hypridle" "Disabled (AFK Mode)"
    fi
}

toggle() {
    current=$(get_mode)
    if [ "$current" == "normal" ]; then
        set_mode "afk"
    else
        set_mode "normal"
    fi
}

case "$1" in
    normal)
        set_mode "normal"
        ;;
    afk)
        set_mode "afk"
        ;;
    toggle)
        toggle
        ;;
    *)
        echo "Usage: $0 {normal|afk|toggle}"
        exit 1
        ;;
esac

#!/bin/bash
# volume-live.sh — Real-time volume display using pactl subscribe

output_volume() {
    vol_output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    vol_raw=$(echo "$vol_output" | awk '{ print $2 }')
    vol_int=$(echo "$vol_raw * 100" | bc 2>/dev/null | awk '{ print int($1) }')
    
    # Cap at 100%
    [ "$vol_int" -gt 100 ] && vol_int=100
    [ -z "$vol_int" ] && vol_int=0
    
    # Check mute status
    if echo "$vol_output" | grep -q "MUTED"; then
        is_muted=true
    else
        is_muted=false
    fi

    # Icon logic (nerd font speaker icons)
    if [ "$is_muted" = true ]; then
        icon="󰝟"
    elif [ "$vol_int" -lt 30 ]; then
        icon="󰕿"
    elif [ "$vol_int" -lt 70 ]; then
        icon="󰖀"
    else
        icon="󰕾"
    fi

    # Granular bar using shade blocks (vertically centered)
    # Density chars: ░ ▒ ▓ █ (4 levels, centered)
    density=("░" "▒" "▓" "█")
    empty_char="░"
    full_char="█"
    
    if [ "$is_muted" = true ]; then
        display_vol=0
    else
        display_vol=$vol_int
    fi
    
    bar=""
    for i in $(seq 0 9); do
        segment_start=$((i * 10))
        segment_end=$(((i + 1) * 10))
        if [ "$display_vol" -ge "$segment_end" ]; then
            bar="${bar}${full_char}"
        elif [ "$display_vol" -le "$segment_start" ]; then
            bar="${bar}${empty_char}"
        else
            # Partial fill: map 0-9 to density index 0-3
            partial=$((display_vol - segment_start))
            idx=$(( (partial * 3) / 10 ))
            bar="${bar}${density[$idx]}"
        fi
    done

    # Color
    if [ "$is_muted" = true ]; then
        fg="#bf616a"
    elif [ "$vol_int" -lt 30 ]; then
        fg="#fab387"
    else
        fg="#56b6c2"
    fi

    echo "{\"text\":\"<span foreground='$fg'>$icon ${bar} ${vol_int}%</span>\",\"tooltip\":\"Volume: ${vol_int}%\"}"
}

# Output initial volume
output_volume

# Listen with unbuffered output for faster response
stdbuf -oL pactl subscribe 2>/dev/null | while read -r line; do
    case "$line" in
        *sink*) output_volume ;;
    esac
done

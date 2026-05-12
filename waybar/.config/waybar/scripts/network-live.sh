#!/bin/bash
# network-live.sh — Active internet connectivity monitoring
# Checks actual internet connectivity via ping to 8.8.8.8
# Shows bandwidth stats from default route interface

get_bandwidth_stats() {
    # Get default route interface
    default_iface=$(ip route | grep '^default' | awk '{print $5}' | head -1)
    if [ -z "$default_iface" ]; then
        echo "0 0"
        return
    fi
    
    # Get rx/tx bytes from ip -s link
    stats=$(ip -s link show "$default_iface" 2>/dev/null | grep -A1 "RX.*bytes" | tail -2)
    rx_bytes=$(echo "$stats" | awk 'NR==1 {print $1}')
    tx_bytes=$(echo "$stats" | awk 'NR==2 {print $1}')
    
    # Format bandwidth (human readable)
    format_bytes() {
        local bytes=$1
        # Handle empty/invalid input
        if [ -z "$bytes" ] || ! [[ "$bytes" =~ ^[0-9]+$ ]]; then
            printf "0 B"
            return
        fi
        if [ "$bytes" -gt 1073741824 ]; then
            printf "%.1f GiB" $(echo "$bytes / 1073741824" | bc -l)
        elif [ "$bytes" -gt 1048576 ]; then
            printf "%.1f MiB" $(echo "$bytes / 1048576" | bc -l)
        elif [ "$bytes" -gt 1024 ]; then
            printf "%.1f KiB" $(echo "$bytes / 1024" | bc -l)
        else
            printf "%d B" "$bytes"
        fi
    }
    
    echo "$(format_bytes "$rx_bytes") $(format_bytes "$tx_bytes")"
}

check_connectivity() {
    # Ping 8.8.8.8 with 2 second timeout, 1 packet
    if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
        echo "true"
    else
        echo "false"
    fi
}

main() {
    connected=$(check_connectivity)
    bw_stats=$(get_bandwidth_stats)
    rx_bytes=$(echo "$bw_stats" | awk '{print $1}')
    tx_bytes=$(echo "$bw_stats" | awk '{print $2}')
    
    # Icon and color selection
    if [ "$connected" = "true" ]; then
        icon=" 󰤨 "
        color="#56b6c2"  # Green
        status="Connected"
        class=""  # No special class
    else
        icon=" 󰖪 "
        color="#bf616a"  # Red
        status="Disconnected"
        class="disconnected"
    fi
    
    # Tooltip format
    tooltip="Network: $status\n⇣$rx_bytes  ⇡$tx_bytes"
    
    # Output JSON (same format as volume-live.sh)
    echo "{\"text\":\"<span foreground='$color'>$icon</span>\",\"tooltip\":\"$tooltip\",\"class\":\"$class\"}"
}

main

# Infinite loop for real-time updates (waybar handles via interval)
# Output gets called every interval seconds
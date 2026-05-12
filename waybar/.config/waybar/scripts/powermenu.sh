#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  Wofi Power Menu
#  Provides a simple system power menu integrated with Waybar.
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(dirname "$0")"

options="Shutdown\nReboot\nLogout\nSuspend\nLock"

chosen=$(echo -e "$options" | wofi --dmenu --location=center --width=15% --hide-search --prompt="Power" --style="$SCRIPT_DIR/wofi.css")

case "$chosen" in
    Shutdown) systemctl poweroff ;;
    Reboot) systemctl reboot ;;
    Logout) hyprctl dispatch exit ;;
    Suspend) systemctl suspend ;;
    Lock) hyprlock ;;
esac


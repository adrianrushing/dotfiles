#!/bin/bash

CURRENT_MODE=$(cat /tmp/hypridle_mode_status 2>/dev/null)

if [[ "$1" == "toggle" ]]; then
  if [[ "$CURRENT_MODE" == "afk" ]]; then
    MODE="normal"
  else
    MODE="afk"
  fi
else
  MODE=${1:-normal}
fi

echo "$MODE" >/tmp/hypridle_mode_status
notify-send "Hypridle" "Mode: $MODE"

pkill hypridle
hypridle &

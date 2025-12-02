#!/bin/bash

mode=$(cat /tmp/hypridle_mode_status 2>/dev/null)

if [[ "$mode" == "afk" ]]; then
  echo '{"text": "AFK", "class": "afk"}'
else
  echo '{"text": "Normal", "class": "normal"}'
fi

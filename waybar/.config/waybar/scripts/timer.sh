#!/usr/bin/env bash

set -u

WORK_SECONDS=1500
BREAK_SECONDS=300

STATE_DIR="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}"
STATE_FILE="$STATE_DIR/waybar-timer.state"
LOCK_FILE="$STATE_DIR/waybar-timer.lock"

default_phase="work"
default_running=0
default_remaining=$WORK_SECONDS
default_end_ts=0

phase="$default_phase"
running=$default_running
remaining=$default_remaining
end_ts=$default_end_ts

duration_for_phase() {
  if [ "$1" = "break" ]; then
    printf '%s\n' "$BREAK_SECONDS"
  else
    printf '%s\n' "$WORK_SECONDS"
  fi
}

load_state() {
  if [ -f "$STATE_FILE" ]; then
    # shellcheck disable=SC1090
    . "$STATE_FILE"
  fi

  phase="${phase:-$default_phase}"
  running="${running:-$default_running}"
  remaining="${remaining:-$default_remaining}"
  end_ts="${end_ts:-$default_end_ts}"
}

save_state() {
  umask 077
  {
    printf 'phase=%q\n' "$phase"
    printf 'running=%q\n' "$running"
    printf 'remaining=%q\n' "$remaining"
    printf 'end_ts=%q\n' "$end_ts"
  } >"$STATE_FILE"
}

switch_phase() {
  if [ "$phase" = "work" ]; then
    phase="break"
  else
    phase="work"
  fi
  remaining="$(duration_for_phase "$phase")"
}

notify_phase_end() {
  swaync-client -t "Focus Session Over!" -b "Time to take a well-deserved break." -a "pomodoro" -u critical >/dev/null 2>&1 || true
  paplay /usr/share/sounds/freedesktop/stereo/complete.oga >/dev/null 2>&1 &
}

tick() {
  [ "$running" -eq 1 ] || return

  local now
  now="$(date +%s)"

  if [ "$end_ts" -le 0 ]; then
    end_ts=$((now + remaining))
  fi

  remaining=$((end_ts - now))

  while [ "$remaining" -le 0 ]; do
    notify_phase_end
    switch_phase
    end_ts=$((end_ts + $(duration_for_phase "$phase")))
    remaining=$((end_ts - now))
  done
}

format_time() {
  local total="$1"
  local mins secs

  mins=$((total / 60))
  secs=$((total % 60))
  printf '%02d:%02d' "$mins" "$secs"
}

emit_text() {
  local icon pause_icon
  if [ "$phase" = "break" ]; then
    icon="󰞶"
  else
    icon="󰄉"
  fi

  if [ "$running" -eq 1 ]; then
    pause_icon=""
  else
    pause_icon=" "
  fi

  printf '%s %s%s\n' "$icon" "$(format_time "$remaining")" "$pause_icon"
}

refresh_waybar() {
  pkill -SIGRTMIN+9 waybar >/dev/null 2>&1 || true
}

handle_toggle() {
  local now
  now="$(date +%s)"

  if [ "$running" -eq 1 ]; then
    tick
    running=0
    end_ts=0
  else
    running=1
    end_ts=$((now + remaining))
  fi
  refresh_waybar
}

handle_reset() {
  running=0
  end_ts=0
  phase="work"
  remaining="$WORK_SECONDS"
  refresh_waybar
}

handle_skip() {
  running=0
  end_ts=0
  switch_phase
  refresh_waybar
}

main() {
  local cmd="${1:-render}"

  exec 9>"$LOCK_FILE"
  flock -x 9

  load_state

  case "$cmd" in
    toggle)
      handle_toggle
      ;;
    reset)
      handle_reset
      ;;
    skip)
      handle_skip
      ;;
    render)
      tick
      ;;
    *)
      tick
      ;;
  esac

  save_state
  emit_text
}

main "$@"

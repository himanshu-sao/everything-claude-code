#!/usr/bin/env bash
# monitor_tasks.sh – Background watchdog for task registry heartbeats
# Scans $HOME/.config/opencode/tasks.json every 10s, checks running tasks' heartbeats.
set -euo pipefail

TASKS_FILE="$HOME/.config/opencode/tasks.json"
HEARTBEAT_DIR="$HOME/.config/opencode/heartbeats"
HEARTBEAT_TTL=30
SLEEP_INTERVAL=10

mkdir -p "$(dirname "$TASKS_FILE")"
mkdir -p "$HEARTBEAT_DIR"

while true; do
  if [ ! -f "$TASKS_FILE" ]; then
    sleep $SLEEP_INTERVAL
    continue
  fi

  RUNNING_IDS=()
  while IFS= read -r id; do
    [ -n "$id" ] && RUNNING_IDS+=("$id")
  done < <(jq -r '.tasks[] | select(.status == "running") | .id' "$TASKS_FILE")
  if [ ${#RUNNING_IDS[@]} -gt 0 ]; then
    for ID in "${RUNNING_IDS[@]}"; do
    AGENT=$(jq -r ".tasks[] | select(.id == \"$ID\") | .agent" "$TASKS_FILE")
    HB_FILE="$HEARTBEAT_DIR/heartbeat.$AGENT"
    if [ ! -f "$HB_FILE" ]; then
      STALE=1
    else
      LAST=$(cat "$HB_FILE")
      NOW=$(date +%s)
      AGE=$((NOW - LAST))
      if [ "$AGE" -gt "$HEARTBEAT_TTL" ]; then
        STALE=1
      else
        STALE=0
      fi
    fi

    if [ "$STALE" -eq 1 ]; then
      PID=$(jq -r ".tasks[] | select(.id == \"$ID\") | .pid // empty" "$TASKS_FILE")
      if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
        kill -9 "$PID" 2>/dev/null || true
      fi
      jq "(.tasks[] | select(.id == \"$ID\")) |= (.status = \"error\" | .pid = null)" "$TASKS_FILE" > "$TASKS_FILE.tmp" && mv "$TASKS_FILE.tmp" "$TASKS_FILE"
    fi
  done
  fi

  sleep $SLEEP_INTERVAL
done

#!/usr/bin/env bash
# update_task.sh – Update an existing task entry in tasks.json
# Usage: update_task.sh <task_id> '<json_fragment>'
# Example: update_task.sh 123 '{"status":"done","pid":null}'

set -euo pipefail

TASKS_FILE="$HOME/.config/opencode/tasks.json"
LOCK_FILE="$HOME/.config/opencode/tasks.lock"

TASK_ID="$1"
JSON_FRAGMENT="$2"

# Acquire lock (if flock is available)
if command -v flock >/dev/null 2>&1; then
  exec 200>"$LOCK_FILE"
  flock -n 200 || { echo "Failed to acquire lock on $LOCK_FILE" >&2; exit 1; }
fi

# Update the task using jq
TMP=$(mktemp)
# Use jq to map over tasks and update matching id
jq "(.tasks[] | select(.id == \"$TASK_ID\")) |= . + $JSON_FRAGMENT" "$TASKS_FILE" > "$TMP" && mv "$TMP" "$TASKS_FILE"

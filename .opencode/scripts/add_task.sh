#!/usr/bin/env bash
# add_task.sh – Register a new task and return its UUID
# Usage: add_task.sh <agent_name>

set -euo pipefail

TASKS_FILE="$HOME/.config/opencode/tasks.json"
LOCK_FILE="$HOME/.config/opencode/tasks.lock"

# Ensure tasks file exists
if [ ! -f "$TASKS_FILE" ]; then
  echo '{"tasks":[]}' > "$TASKS_FILE"
fi

# Generate UUID (fallback if uuidgen missing)
if command -v uuidgen >/dev/null 2>&1; then
  TASK_ID=$(uuidgen)
else
  # Simple fallback using timestamp and random
  TASK_ID="$(date +%s%N)$(printf "%04d" $RANDOM)"
fi

AGENT_NAME="$1"
TIMESTAMP=$(date +%s)

# Acquire lock (if flock is available)
if command -v flock >/dev/null 2>&1; then
  exec 200>"$LOCK_FILE"
  flock -n 200 || { echo "Failed to acquire lock on $LOCK_FILE" >&2; exit 1; }
fi

# Append new task entry using jq
TMP=$(mktemp)
jq ".tasks += [{\"id\": \"$TASK_ID\", \"agent\": \"$AGENT_NAME\", \"status\": \"pending\", \"pid\": null, \"created\": $TIMESTAMP}]" "$TASKS_FILE" > "$TMP" && mv "$TMP" "$TASKS_FILE"

# Output the task ID for caller
echo "$TASK_ID"

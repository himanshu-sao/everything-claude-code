#!/usr/bin/env bash
# Unit tests for the OpenCode task-registry scripts
# Requires: jq, uuidgen (or fallback), timeout
set -euo pipefail

# Helper to assert a condition
assert() {
  if ! "$@"; then
    echo "ASSERTION FAILED: $*" >&2
    exit 1
  fi
}

# Clean any previous state
TASKS_FILE="$HOME/.config/opencode/tasks.json"
HEARTBEAT_DIR="$HOME/.config/opencode/heartbeats"
rm -f "$TASKS_FILE"
rm -rf "$HEARTBEAT_DIR"
mkdir -p "$(dirname \"$TASKS_FILE\")"
mkdir -p "$HEARTBEAT_DIR"

# 1. Add a task for the developer agent
TASK_ID=$(bash ~/.config/opencode/scripts/add_task.sh developer)
assert [ -n "$TASK_ID" ]
# Verify the task exists and is pending
STATUS=$(jq -r ".tasks[] | select(.id == \"$TASK_ID\") | .status" "$TASKS_FILE")
assert [ "$STATUS" = "pending" ]

# 2. Update to running with a fake PID
FAKE_PID=12345
bash ~/.config/opencode/scripts/update_task.sh "$TASK_ID" "{\"status\":\"running\",\"pid\":$FAKE_PID}"
STATUS=$(jq -r ".tasks[] | select(.id == \"$TASK_ID\") | .status" "$TASKS_FILE")
PID=$(jq -r ".tasks[] | select(.id == \"$TASK_ID\") | .pid" "$TASKS_FILE")
assert [ "$STATUS" = "running" ]
assert [ "$PID" = "$FAKE_PID" ]

# 3. Simulate a stale heartbeat (older than 30 s)
OLD_TS=$(( $(date +%s) - 100 ))
echo "$OLD_TS" > "$HEARTBEAT_DIR/heartbeat.developer"

# 4. Run the monitor in background (it will check every 10 s)
bash ~/.config/opencode/scripts/monitor_tasks.sh &
MONITOR_PID=$!
# Give it a little time to detect the stale heartbeat
sleep 12
# Kill monitor (it runs forever)
kill $MONITOR_PID 2>/dev/null || true

# 5. Verify the task status is now error and pid cleared
STATUS=$(jq -r ".tasks[] | select(.id == \"$TASK_ID\") | .status" "$TASKS_FILE")
PID=$(jq -r ".tasks[] | select(.id == \"$TASK_ID\") | .pid" "$TASKS_FILE")
assert [ "$STATUS" = "error" ]
assert [ "$PID" = "null" ]

echo "All task-registry unit tests passed."

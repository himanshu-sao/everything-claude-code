#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_DIR="$HOME/.config/opencode/scripts"
TASKS_FILE="$HOME/.config/opencode/tasks.json"
HEARTBEAT_DIR="$HOME/.config/opencode/heartbeats"

cleanup() {
  "$SCRIPT_DIR/stop_monitor.sh" 2>/dev/null || true
  rm -f "$TASKS_FILE"
  rm -rf "$HEARTBEAT_DIR"
}
trap cleanup EXIT

echo "=== Integration Test: Task Registry + Monitor ==="

# Clean state
rm -f "$TASKS_FILE"
rm -rf "$HEARTBEAT_DIR"

# Start monitor
"$HOME/.config/opencode/scripts/start_monitor.sh"
echo "PASS: monitor started"

# Register a task
TASK_ID=$("$SCRIPT_DIR/add_task.sh" dummy-agent)
echo "Task ID: $TASK_ID"
[ -n "$TASK_ID" ] || { echo "FAIL: no task ID"; exit 1; }

# Mark as running
"$SCRIPT_DIR/update_task.sh" "$TASK_ID" '{"status":"running"}'

# Verify
STATUS=$(jq -r '.tasks[0].status' "$TASKS_FILE")
[ "$STATUS" = "running" ] || { echo "FAIL: expected running, got $STATUS"; exit 1; }
echo "PASS: task registered and running"

# Start heartbeat
"$SCRIPT_DIR/heartbeat.sh" dummy-agent &
HB_PID=$!

# Wait for heartbeats to register
sleep 12
STATUS=$(jq -r '.tasks[0].status' "$TASKS_FILE")
[ "$STATUS" = "running" ] || { echo "FAIL: task should be running with fresh heartbeat"; exit 1; }
echo "PASS: task still running with fresh heartbeat"

# Stop heartbeat (simulate agent crash)
kill $HB_PID 2>/dev/null || true
wait $HB_PID 2>/dev/null || true
echo "PASS: heartbeat stopped (simulated agent crash)"

# Wait for monitor to detect stale (TTL 30s, check every 10s, wait up to 45s)
echo "Waiting for monitor to detect stale task..."
for i in $(seq 1 9); do
  sleep 5
  STATUS=$(jq -r '.tasks[0].status' "$TASKS_FILE" 2>/dev/null || echo "none")
  if [ "$STATUS" = "error" ]; then
    echo "PASS: monitor detected stale task and marked it error"
    break
  fi
  echo "  ...still waiting (check $i/9, status=$STATUS)"
done

STATUS=$(jq -r '.tasks[0].status' "$TASKS_FILE")
[ "$STATUS" = "error" ] || { echo "FAIL: expected error, got $STATUS"; exit 1; }

# Stop monitor
"$SCRIPT_DIR/stop_monitor.sh"
echo "PASS: monitor stopped"

echo ""
echo "=== All integration tests passed ==="

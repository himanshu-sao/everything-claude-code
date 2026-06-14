#!/usr/bin/env bash
# start_monitor.sh – Launch the task‑registry monitor safely
# Ensures only one monitor runs per session.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIDFILE="$HOME/.config/opencode/monitor.pid"

# If a monitor PID file exists and the process is still alive, do nothing.
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo "monitor already running (PID $(cat "$PIDFILE"))"
  exit 0
fi

# Start the monitor in the background and record its PID.
"$SCRIPT_DIR/monitor_tasks.sh" &
echo $! > "$PIDFILE"

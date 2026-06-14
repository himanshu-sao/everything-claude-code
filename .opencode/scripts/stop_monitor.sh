#!/usr/bin/env bash
# stop_monitor.sh – Stop the task‑registry monitor if it is running
set -euo pipefail

PIDFILE="$HOME/.config/opencode/monitor.pid"

if [ -f "$PIDFILE" ]; then
  kill "$(cat "$PIDFILE")" 2>/dev/null || true
  rm -f "$PIDFILE"
  echo "monitor stopped"
else
  echo "no monitor PID file found"
fi

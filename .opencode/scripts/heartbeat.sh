#!/usr/bin/env bash
# heartbeat.sh – Write timestamp every 5 seconds for given agent name
# Usage: heartbeat.sh <agent_name>

set -euo pipefail

HEARTBEAT_DIR="$HOME/.config/opencode/heartbeats"
mkdir -p "$HEARTBEAT_DIR"

AGENT_NAME="$1"
FILE="$HEARTBEAT_DIR/heartbeat.$AGENT_NAME"

# Ensure cleanup on exit
cleanup() {
  rm -f "$FILE"
}
trap cleanup EXIT

while true; do
  date +%s > "$FILE"
  sleep 5
done

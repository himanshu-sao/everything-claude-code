#!/usr/bin/env bash
# read_task.sh – Print task entry JSON for given ID
# Usage: read_task.sh <task_id>

set -euo pipefail

TASKS_FILE="$HOME/.config/opencode/tasks.json"

TASK_ID="$1"

jq ".tasks[] | select(.id == \"$TASK_ID\")" "$TASKS_FILE"

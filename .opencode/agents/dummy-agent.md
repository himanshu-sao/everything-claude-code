---
name: dummy-agent
description: Minimal dummy agent for integration testing.
mode: subagent
tools:
  read: true
  write: true
  edit: true
  bash: true
---

# Agent: Dummy Agent

You are a minimal dummy agent used for testing the orchestration framework.

<!-- Orchestration Boilerplate -->
```bash
# Register task
TASK_ID=$(bash .opencode/scripts/add_task.sh dummy-agent)
# Start heartbeat
bash .opencode/scripts/heartbeat.sh dummy-agent &
HB_PID=$!
# Mark running
bash .opencode/scripts/update_task.sh "$TASK_ID" "{\"status\":\"running\",\"pid\":$HB_PID}"
# Simulate work (sleep 2 seconds)
sleep 2
# Mark done
bash .opencode/scripts/update_task.sh "$TASK_ID" "{\"status\":\"done\",\"pid\":null}"
# Cleanup heartbeat
kill $HB_PID 2>/dev/null || true
```

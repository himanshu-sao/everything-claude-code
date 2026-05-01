---
name: agent-supervisor
description: DEPRECATED. Please use tech-lead.
mode: subagent
model: ollama/gemma4:e4b
tools:
  read: true
---

# DEPRECATED
This agent has been deprecated as part of the Nexus-Super-Manus architecture.
All orchestration, stack monitoring, and supervision logic has been folded directly into the `tech-lead`.

If you are a sub-agent trying to use the supervisor, **redirect your request to the `tech-lead`**.

# 🚀 OpenCode Environment: Setup & Maintenance Guide

This guide explains how to manage and maintain your OpenCode configuration, optimized for the **Apple M4 Max (14-core CPU, 36GB RAM)**.

## 🧠 Model Tier Strategy

To ensure high performance without overwhelming your system's RAM, we use a tiered model approach:

| Tier | Model | Memory | Assigned To |
| :--- | :--- | :--- | :--- |
| **Heavy** | `ollama/qwen3-coder:latest` | ~18 GB | `build` (Primary Agent) |
| **Medium** | `ollama/gemma4:e4b` | ~9.6 GB | `architect` (System Design) |
| **Smart Chat**| `ollama/llama3.2:3b` | ~2.0 GB | `chat` (Default Entry Point) |
| **Utility** | `ollama/mistral:7b` | ~4.4 GB | All other 31 sub-agents |
| **Lite** | `ollama/deepseek-coder:1.3b`| ~776 MB | Quick code snippets |

> [!TIP]
> This distribution allows you to run a "Heavy" agent alongside several "Utility" agents without hitting the 36GB RAM limit or slowing down your macOS UI.

## 🔄 Global Synchronization

You can promote your project-specific agents, skills, and configuration to your global environment at any time.

### How to Sync
Run the enhanced sync script from the workspace root:
```bash
.opencode/sync-agents-global.sh
```

### What gets synced:
1.  **Agents**: `.opencode/agents/*.md` → `~/.opencode/agents/`
2.  **Skills**: `skills/` → `~/.opencode/skills/`
3.  **Instructions**: `instructions/` → `~/.opencode/instructions/`
4.  **Config**: `.opencode/opencode.json` → `~/.config/opencode/opencode.json`

### 💾 Backups
Every sync creates a timestamped backup of your previous global state in:
`~/.opencode/backups/backup_YYYYMMDD_HHMMSS/`

## ⚙️ Configuration Management

### Local vs. Global
*   **Local (`.opencode/opencode.json`)**: Used for testing new skills, agents, or commands within this specific repository.
*   **Global (`~/.config/opencode/opencode.json`)**: The "Gold Master" configuration used as a fallback for all projects.

### Transitioning to Global-Only
Once you are satisfied with your local testing:
1.  Run the sync script: `.opencode/sync-agents-global.sh`
2.  (Optional) Remove the local `.opencode/opencode.json` if you want to rely purely on the global fallback.

## 🛠 Adding New Agents

1.  Create a new markdown file in `.opencode/agents/`.
2.  Use the `ollama:model-name` prefix for the model field.
3.  Choose the tier (Heavy/Medium/Utility) based on the agent's task complexity.
4.  Run `.opencode/verify-agents.sh` to ensure the format is correct.
5.  Sync to global when ready.

## 🔍 Troubleshooting

*   **Model not loading**: Run `ollama list` to ensure the model exists.
*   **Command missing**: Check the `command` object in `opencode.json`.
*   **Agent not found**: Run `opencode agent list` and check for syntax errors.
*   **RAM pressure**: If the system is sluggish, downgrade the `build` agent to `ollama:mistral:7b` temporarily.

---
**Maintained by:** OpenCode Optimization Workflow  
**Last Updated:** 2026-04-27

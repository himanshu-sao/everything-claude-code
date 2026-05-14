# Model & Provider Management Guide

This project implements a **Tiered Model Strategy** to balance performance, cost, and speed across different AI providers.

## The Tiering Strategy

To optimize the Expert-Direct workflow, agents are assigned to specific tiers:

| Tier | Purpose | Target Agents | Recommended Model |
|---|---|---|---|
| **Power** | Complex coding & deep reasoning | `developer` | `qwen3-coder-480b` |
| **Balanced** | Planning & Architecture | `architect`, `project-manager` | `llama-3.3-70b` |
| **Fast** | Orchestration & Routing | `chat`, `tech-lead` | `deepseek-v4-flash` |

## Switching Providers

You can switch the entire environment between configured providers using the switching script:

```bash
# Switch to Nvidia NIM (Cloud)
python3 .opencode/switch-provider.py nvidia

# Switch to Local Ollama (Ollama Bridge)
python3 .opencode/switch-provider.py ollama-local
```

### What happens during a switch?
1. **`opencode.json`** is updated with the provider's specific model IDs.
2. **`agents/*.md`** files have their `model:` field updated to match the tier for that agent.
3. **Global Sync**: After switching, run `./.opencode/sync-agents-global.sh` to apply the changes to your global OpenCode configuration.

## Adding a New Provider

To add a new provider (e.g., Anthropic, OpenAI):

1. **Update `opencode.json`**: Add the new provider block under `"provider"`.
2. **Update `profiles.json`**: Add a new entry with the model IDs for each tier:
   ```json
   "my-new-provider": {
     "name": "My New Provider",
     "model": "provider/power-model",
     "small_model": "provider/fast-model",
     "tiers": {
       "power": "provider/power-model",
       "balanced": "provider/balanced-model",
       "fast": "provider/fast-model"
     }
   }
   ```
3. **Run the switch**: `python3 .opencode/switch-provider.py my-new-provider`.

## Auditing Model Access

If you suspect models are failing or want to see exactly which ones are enabled for your Nvidia/Ollama account, run the audit script:

```bash
python3 .opencode/scripts/audit-models.py
```

This script will:
1. Fetch all models from the provider.
2. Test connectivity for each with a 0.1s delay.
3. Save the successful models to `.opencode/scripts/model_audit.json`.

## Troubleshooting

- **Model Not Found**: Ensure the model ID in `profiles.json` exactly matches the ID provided by the NIM or Ollama API.
- **Sync Issues**: If agents are still using old models, ensure you've run the `sync-agents-global.sh` script.
- **Permission Denied**: On macOS/Linux, you may need to grant execution permissions: `chmod +x .opencode/*.sh`.

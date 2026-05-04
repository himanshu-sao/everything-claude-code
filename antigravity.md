# Antigravity Repo Context — Hardened Orchestration (v2)

This document defines the hardened, mechanical protocols required to stabilize AI agents in this repository. 

#### 1. System Architecture & Protocol Hardening
*   **Ultimate Router Pattern**: Established `@tech-lead` as a "Pure Router" on **Gemma 4**. It is now strictly forbidden from content generation, serving exclusively to pass prompts via the `task` tool.
*   **"Nuclear" Zero-Talk Mandate**: All sub-agents (`project-manager`, `architect`, `developer`) are now configured as **Mechanical Document Writers**. They are prohibited from conversational output and are strictly mandated to output results as filesystem artifacts.
*   **Framework-Level System Prompt**: Reverted all agents back to `local-bridge/gemma4:e4b` after discovering that DeepSeek Coder V2 completely ignored native tool-calling. To prevent Gemma 4 from hallucinating plain-text when writing large files, a strict `system_prompt` ("CRITICAL: YOU ARE A MECHANICAL TOOL USER...") was injected directly into `opencode.json` for `gemma4:e4b`, enforcing tool-use at the Vercel AI SDK API layer.
*   **Schema Error Resolution**: Resolved the `SchemaError(task_id)` blocking the `task` tool by enforcing a "Schema Protection" rule in the agent instructions, mandating that agents omit the `task_id` parameter entirely.
*   **Single-Step Execution**: Transitioned all agents to a "Single-Step Mandate." Models now execute exactly one `write` tool call per turn to prevent "thought loss" or context-dropping inherent in local model tool-chaining.
*   **XML-Fallback Removed**: The legacy `<tool_call>` XML bypass was removed, as it conflicted with the `"tool_call": true` flag required for native SDK tool execution.

#### 2. RSS CLI Development Status
*   **Phase 1 (Planning)**: Re-testing with Gemma 4 under the new framework-level system prompt.
*   **Phase 2 (Architecture)**: Infrastructure is hardened and ready. The `architect` agent is primed with a specific "Architecture Document Format" mandate.
*   **Phase 3 (Developer)**: The `@developer` agent has been completely rewritten to follow the Flat Pipeline rules (no recursive agent-supervisor delegation) and restored to `opencode.json`.
*   **Verification**: The environment is persistent; all agents are synchronized via `sync-agents-global.sh` to ensure consistent behavior across all projects using the Golden Template.

#### 3. Environment & Configuration
*   **Golden Template**: The logic is persisted in `.opencode/` and `antigravity.md`.
*   **Model Standard**: The entire core fleet (Router + Workers) is standardized on `gemma4:e4b`.
*   **Frontmatter Override**: Confirmed that the YAML frontmatter inside `.md` agent files overrides `opencode.json` model settings. All frontmatter has been correctly synced to `gemma4:e4b`.

#### 4. Known Issues & Blockers
*   **Context Window Escaping**: Monitoring if Gemma 4 can successfully encode large markdown payloads into the native `write` tool JSON schema without breaking quotes or escaping logic.
*   **Model Latency**: As we rely on pure local execution (Ollama), verify memory head-room if parallel agent calls are attempted.

#### 5. Next Steps for Resumption
1.  **Invoke Planning**: Execute the following prompt: `@project-manager Design a simple RSS Reader CLI. It should allow adding URLs, listing the latest 5 headlines, and saving feeds to a 'feeds.json' file.`
2.  **Verify**: Perform an `ls` or `read` on `docs/PLAN.md` to confirm the artifact exists.
3.  **Initiate Architecture**: Once the plan is confirmed, proceed to the Architect phase by invoking `@tech-lead` to route the architectural tasks.

## 5. Golden Source of Truth (The Template)

The local `.opencode` directory in this repo has been restored and hardened as the **Golden Template**.

- **Sync Script**: Modified to EXCLUDE orchestrators and manage only the Flat Fleet.
- **Chat Agent**: Hardened with **Force-Tool Injection** logic.
- **Config**: Locked to Gemma 4 for all core agents (`project-manager`, `architect`, `tech-lead`, `chat`) to ensure consistency, and uses absolute global paths.

**PROTOCOL**: Always update the local `.opencode` first, then run `sh .opencode/sync-agents-global.sh` to propagate "Nuclear" rules to other projects.

---
*Updated by Antigravity on 2026-05-05 (Golden Source Truth)*

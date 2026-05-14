# OpenCode Agent Infrastructure

> **Status:** ✅ Configured and Working  
> **Last Updated:** 2026-05-03
> **Total Agents:** 36 (1 primary + 35 subagents)

## Quick Start

```bash
# List all available agents
opencode agent list

# Invoke an agent
@planner help me plan a new feature
@code-reviewer review my latest changes
@security-reviewer check for vulnerabilities

# Sync agents to global directory
./sync-agents-global.sh
```

## Configuration Overview

This project uses OpenCode's markdown-based agent configuration for maximum maintainability:

- **Primary Agent:** Defined in `opencode.json` (just `build`)
- **Subagents:** Auto-discovered from `.opencode/agents/*.md` (33 agents)
- **Format:** Each agent is a separate markdown file with YAML frontmatter

### Why This Approach?

✅ **Maintainable** - Each agent in its own file  
✅ **Modular** - Easy to add/remove agents  
✅ **Clean** - JSON config stays simple (137 lines vs 462)  
✅ **Scalable** - Can grow to 100+ agents without cluttering  
✅ **Documented** - Each agent file is self-documenting  

## Agent Architecture

```
                ┌─────────────┐
                │   BUILD     │  ← Primary agent (JSON)
                └─────────────┘
                       │
    ┌──────────────────┼──────────────────┐
    ▼                  ▼                  ▼
dispatcher      task-dispatcher    excel-dispatcher
(routing)       (code tasks)       (spreadsheets)
    │                  │                  │
    ▼                  ▼                  ▼
[domain agents]  [code agents]    [excel agents]
```

## Available Agents

### Core Development Agents
- **architect** - System design and architecture decisions
- **planner** - Task breakdown and implementation planning
- **builder** - Code implementation with TDD workflow
- **code-reviewer** - Code quality and best practices review
- **security-reviewer** - Security vulnerability detection
- **tdd-guide** - Test-driven development specialist

### Language-Specific Agents
- **java-agent** - Java/Spring Boot development
- **go-agent** - Go development
- **python-agent** - Python/FastAPI development
- **shell-agent** - Shell scripting and CLI

### Build & Testing Agents
- **build-resolver** - Build and compilation error fixes
- **test-agent** - Unit test creation and maintenance
- **e2e-runner** - End-to-end testing with Playwright

### Specialized Agents
- **database-reviewer** - Database query optimization
- **doc-updater** - Documentation maintenance
- **git-agent** - Git operations and workflows
- **improver** - Code improvement suggestions
- **refactor-cleaner** - Dead code cleanup

### Workflow & Coordination Agents
- **dispatcher** - General task routing
- **task-dispatcher** - Code task coordination
- **data-dispatcher** - Data analysis tasks
- **excel-dispatcher** - Spreadsheet operations
- **infra-dispatcher** - DevOps/infrastructure tasks
- **research-dispatcher** - Research and documentation lookup

### Support Agents
- **complexity-analyzer** - Task complexity assessment
- **context-agent** - Context management
- **fallback-agent** - Fallback handling
- **memory-agent** - Persistent learning across sessions
- **metrics-agent** - Performance metrics tracking
- **mcp-registry** - MCP server management
- **pm-agent** - Project management
- **sandbox-agent** - Safe execution environment
- **ux-agent** - User experience optimization
- **party-mode** - Fun and experimental features

## Agent File Format

Each agent is defined in a markdown file with this structure:

```markdown
---
name: agent-name
description: What this agent does
mode: subagent
model: ollama:model-name
tools:
  read: true
  write: true
  edit: true
  bash: true
  grep: true
  glob: true
---

# Agent Instructions

Your detailed agent prompt and instructions here...
```

### Required Fields
- `name` - Agent identifier (lowercase, hyphenated)
- `description` - Brief description of agent's purpose
- `mode` - Either `primary` or `subagent`
- `model` - Ollama model to use (e.g., `ollama:mistral:7b`)
- `tools` - Object with boolean flags for available tools

### Available Tools
- `read` - Read files
- `write` - Write/create files
- `edit` - Edit existing files
- `bash` - Execute shell commands
- `grep` - Search files with regex
- `glob` - File pattern matching
- `task` - Spawn sub-tasks
- `webfetch` - Fetch web content
- `websearch` - Search the web

## Adding a New Agent

1. Create a new file in `.opencode/agents/`:
   ```bash
   touch .opencode/agents/my-new-agent.md
   ```

2. Add the frontmatter and instructions:
   ```markdown
   ---
   name: my-new-agent
   description: My specialized agent
   mode: subagent
   model: ollama:mistral:7b
   tools:
     read: true
     write: true
     bash: true
   ---
   
   You are a specialized agent for...
   ```

3. OpenCode will auto-discover it immediately:
   ```bash
   opencode agent list | grep my-new-agent
   ```

## Modifying an Agent

Simply edit the corresponding `.md` file in `.opencode/agents/`. Changes take effect immediately.

## Removing an Agent

Delete the `.md` file from `.opencode/agents/`. OpenCode will no longer list it.

## Global Agent Setup

To make your agents available globally across all projects:

```bash
# Sync agents to global directory
./sync-agents-global.sh

# Or manually
cp -r .opencode/agents/* ~/.opencode/agents/
```

The sync script will:
- Copy all agents to `~/.opencode/agents/`
- Preserve existing global agents
- Skip duplicates
- Create backup before syncing

## Model Management & Switching

This project supports a tiered model strategy for different providers (Nvidia, Ollama, etc.).

See **[MODEL_MANAGEMENT.md](file:///Users/himanshusao/Work/src/extra/himanshu-sao/everything-claude-code/.opencode/MODEL_MANAGEMENT.md)** for details on how to switch providers and manage tiers.

### Quick Switch:
```bash
# Switch to Nvidia NIM
python3 .opencode/switch-provider.py nvidia

# Switch to Local Ollama
python3 .opencode/switch-provider.py ollama-local
```

## Global Agent Setup

### Default Models
- **mistral:7b** (776 MB) - Planning, orchestration, analysis
- **codellama:7b** (3.8 GB) - Code implementation, testing

### Changing Models
Edit the `model` field in any agent's markdown file:
```yaml
model: ollama:deepseek-coder-v2  # or any other Ollama model
```

## Troubleshooting

### Agent Not Showing Up
```bash
# Check file format
head -20 .opencode/agents/your-agent.md

# Verify frontmatter has required fields
grep -E "^(name|mode|model):" .opencode/agents/your-agent.md

# Check for syntax errors
opencode agent list 2>&1 | grep -i error
```

### Tool Format Errors
Ensure tools use object format, not array:
```yaml
# ❌ Wrong
tools: [Read, Write, Edit]

# ✅ Correct
tools:
  read: true
  write: true
  edit: true
```

### Validation Script
Run the verification script:
```bash
.opencode/verify-agents.sh
```

## Configuration Files

- **`opencode.json`** - Main configuration (primary agent, commands, settings)
- **`agents/*.md`** - Individual agent definitions (33 files)
- **`prompts/agents/*.txt`** - Legacy prompt files (optional)
- **`verify-agents.sh`** - Configuration verification script
- **`sync-agents-global.sh`** - Global agent sync script

## Best Practices

1. **One Agent Per File** - Keep agents modular and focused
2. **Clear Descriptions** - Help users understand when to use each agent
3. **Appropriate Tools** - Only enable tools the agent needs
4. **Consistent Naming** - Use lowercase with hyphens (e.g., `code-reviewer`)
5. **Document Escalation** - Specify when to delegate to other agents
6. **Test Changes** - Run `opencode agent list` after modifications

## Migration Notes

This configuration was migrated from inline JSON definitions to markdown files on 2026-04-27:

- **Before:** 462-line JSON with 25 inline agent definitions
- **After:** 137-line JSON + 33 modular markdown files
- **Benefits:** Better maintainability, easier to add/modify agents

See `AGENT_MIGRATION.md` for detailed migration history.

## Resources

- [OpenCode Documentation](https://opencode.ai/docs/agents/)
- [Agent Configuration Guide](https://opencode.ai/docs/agents/#configure)
- [Ollama Models](https://ollama.ai/library)

## Support

For issues or questions:
1. Check `opencode agent list` for errors
2. Run `.opencode/verify-agents.sh` for validation
3. Review agent markdown files for format issues
4. Consult OpenCode documentation

---

**Configuration Status:** ✅ Complete and Working  

---

## Pipeline & Gate System (v2 — opencode branch)

> **Added:** 2026-05-03 | Resolves: QA diagram not being generated, no user checkpoints

### Problem Solved

Previously, `tech-lead` used a **NO PAUSES** autonomous chain. This caused:
- `qa-engineer` (verify) was called at build-time, not design-time — no QA test matrix ever generated
- Chain silently dropped phases when prior agent stalled
- No user visibility or approval between design phases

### New Two-Phase Architecture

```
User Request
    ↓
@tech-lead
    ↓
  PHASE A: Design (pipeline-orchestrator)
  ┌──────────────────────────────────────────────────────
  │ [1] project-manager  → docs/PLAN.md
  │         GATE 1/5: "plan approved"
  │ [2] architect        → docs/ARCHITECTURE.md
  │         GATE 2/5: "arch lgtm"
  │ [3] quality-gate     → architecture validation
  │         GATE 3/5: "quality ok"
  │ [4] qa-planner       → docs/QA_TESTCASES.md  ← NEW
  │         GATE 4/5: "qa approved"
  │ [5] tdd-guide        → docs/TDD_STUBS.md
  │         GATE 5/5: "tdd ready"
  └──────────────────────────────────────────────────────
        User approves: "build start"
    ↓
  PHASE B: Build (tech-lead supervised chain)
  ┌──────────────────────────────────────────────────────
  │ [1] developer        → source code
  │ [2] ui-engineer      → frontend (if applicable)
  │ [3] qa-engineer      → smoke tests
  │ [4] security-reviewer → audit
  └──────────────────────────────────────────────────────
```

### New Agents (v2)

| Agent | File | Purpose |
|---|---|---|
| `pipeline-orchestrator` | `agents/pipeline-orchestrator.md` | Runs design pipeline with 5 gate checkpoints |
| `qa-planner` | `agents/qa-planner.md` | Generates `docs/QA_TESTCASES.md` at design time |

### New Commands (v2)

| Command | Agent | Purpose |
|---|---|---|
| `/design` | `pipeline-orchestrator` | Full 5-phase design pipeline with gates |
| `/qa-plan` | `qa-planner` | Standalone QA test matrix generation |

### Gate Mode

Controlled by `USER_PREFERENCES.md` under `## Pipeline Gates`:
- `strict` (default): Must type exact phrase to advance
- `relaxed`: Warning only, proceeds automatically
- `off`: Legacy NO PAUSES behavior

To change: ask `@improver` to update `USER_PREFERENCES.md`.
**Agents:** 34 total (1 primary + 33 subagents)  
**Format:** Markdown-based with YAML frontmatter

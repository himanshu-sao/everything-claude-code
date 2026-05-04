# OpenCode Pipeline Guide

> **Branch:** `opencode` | **Version:** 2.0 | **Last Updated:** 2026-05-03  
> **Author:** himanshu-sao | **Requires:** OpenCode + Ollama

---

## Table of Contents

1. [What is This?](#what-is-this)
2. [Prerequisites](#prerequisites)
3. [Models Required](#models-required)
4. [Quick Start](#quick-start)
5. [How the Pipeline Works](#how-the-pipeline-works)
6. [Gate Checkpoints](#gate-checkpoints)
7. [All Agents Reference](#all-agents-reference)
8. [Commands Reference](#commands-reference)
9. [File Structure](#file-structure)
10. [Dry-Run Example](#dry-run-example)
11. [Troubleshooting](#troubleshooting)
12. [Customizing the Pipeline](#customizing-the-pipeline)

---

## What is This?

This repository configures **OpenCode** to run as a fully local, multi-agent development environment using **Ollama models** (no API keys required).

The `opencode` branch introduces a **v2 two-phase pipeline** that solves a key problem with the original setup:

| Problem (v1) | Solution (v2) |
|---|---|
| QA test matrix never generated | New `qa-planner` agent runs at design time |
| No user visibility between phases | Mandatory gate checkpoints with continue phrases |
| Chain dropped phases silently | `agent-supervisor` now verifies deliverables + retries |
| Hardcoded absolute paths in config | All paths are now project-relative |
| `tdd-guide` used weak `mistral:7b` | Upgraded to `deepseek-coder-v2` |

---

## Prerequisites

1. **OpenCode** installed and configured
2. **Ollama** running locally (`ollama serve`)
3. The following models pulled:

```bash
# Pull all required models
ollama pull gemma4:e4b
ollama pull deepseek-coder-v2
ollama pull deepseek-coder:1.3b
```

4. Clone this repo and check out the `opencode` branch:

```bash
git clone https://github.com/himanshu-sao/everything-claude-code
cd everything-claude-code
git checkout opencode
```

5. Sync agents globally (so they work across all your projects):

```bash
./.opencode/sync-agents-global.sh
```

---

## Models Required

| Model | Used By | Role |
|---|---|---|
| `ollama/gemma4:e4b` | tech-lead, architect, qa-planner, agent-supervisor, pipeline-orchestrator | Heavy reasoning + orchestration |
| `ollama/deepseek-coder-v2` | tdd-guide, developer (build agent) | Code generation + TDD stubs |
| `ollama/deepseek-coder:1.3b` | Small tasks | Fast utility tasks |
| `ollama/mistral:7b` | dispatcher | Lightweight routing |

> All models run 100% locally via Ollama. Zero API calls, zero cost.

---

## Quick Start

### Option A: Full Pipeline (Design + Build)

```
@tech-lead build me a REST API for user authentication with JWT
```

The tech-lead will automatically:
1. Run the 5-phase design pipeline (with your approval at each step)
2. Then build the code once you approve all designs

### Option B: Design Phase Only

```
/design build me a REST API for user authentication with JWT
```

Runs only the 5 design phases. No code is written until you approve all artifacts and type `build start`.

### Option C: Just QA Test Matrix

```
/qa-plan generate test cases for the auth service
```

Runs only the `qa-planner` agent. Requires `docs/PLAN.md` and `docs/ARCHITECTURE.md` to already exist.

---

## How the Pipeline Works

Every request to `@tech-lead` goes through two phases:

```
User: "@tech-lead design a user auth service"
         |
         v
    [tech-lead]
    model: gemma4:e4b
         |
         v
  PHASE A: DESIGN
  ================
  Delegates to pipeline-orchestrator
         |
         v
  [1] project-manager  -->  docs/PLAN.md
         |                  GATE 1/5
         |               User types: "plan approved"
         v
  [2] architect        -->  docs/ARCHITECTURE.md
         |                  GATE 2/5
         |               User types: "arch lgtm"
         v
  [3] quality-gate     -->  architecture validation report
         |                  GATE 3/5
         |               User types: "quality ok"
         v
  [4] qa-planner       -->  docs/QA_TESTCASES.md   <-- NEW in v2!
         |                  GATE 4/5
         |               User types: "qa approved"
         v
  [5] tdd-guide        -->  docs/TDD_STUBS.md
                            GATE 5/5
                         User types: "tdd ready"
         |
         v
    [tech-lead waits]
  User types: "build start"
         |
         v
  PHASE B: BUILD
  ==============
  [1] developer        -->  source code (TDD)
  [2] ui-engineer      -->  frontend (if applicable)
  [3] qa-engineer      -->  smoke tests
  [4] security-reviewer --> security audit
         |
         v
    Team Task Complete. Sign-off.
```

---

## Gate Checkpoints

After each design phase, the pipeline **pauses and displays**:

```
+------------------------------------------------------
| GATE [N/5]: {Phase Name} Complete
| Deliverable: {filename} (N lines)
|
| Review the document above, then type:
|   "{continue_phrase}"  to proceed to Phase N+1
|   "block: [reason]"  to pause and request changes
+------------------------------------------------------
```

### Continue Phrases

| Gate | What was Produced | Type This to Continue |
|---|---|---|
| Gate 1/5 | `docs/PLAN.md` | `plan approved` |
| Gate 2/5 | `docs/ARCHITECTURE.md` | `arch lgtm` |
| Gate 3/5 | Architecture validation report | `quality ok` |
| Gate 4/5 | `docs/QA_TESTCASES.md` | `qa approved` |
| Gate 5/5 | `docs/TDD_STUBS.md` | `tdd ready` |
| Build phase trigger | All design docs approved | `build start` |

### If You Need Changes

Type `block: [your reason]` at any gate. For example:

```
block: The architecture is missing the caching layer for JWT tokens. Please add Redis.
```

The agent will revise and re-present the document for your approval.

### Changing Gate Mode

Gate mode is controlled in `.opencode/USER_PREFERENCES.md` under `## Pipeline Gates`:

- `strict` (default) — must type exact continue phrase
- `relaxed` — warning shown but pipeline advances automatically
- `off` — legacy NO PAUSES behavior (v1 style)

To change: ask `@improver to set gate_mode to relaxed in USER_PREFERENCES.md`

---

## All Agents Reference

### Core Orchestration

| Agent | Model | Role |
|---|---|---|
| `tech-lead` | `gemma4:e4b` | Top-level orchestrator. Delegates to pipeline-orchestrator (design) and build chain (implementation) |
| `pipeline-orchestrator` | `gemma4:e4b` | **NEW v2.** Runs the 5-phase design pipeline with user gate checkpoints |
| `agent-supervisor` | `gemma4:e4b` | Monitors every delegation: verifies deliverables exist, retries up to 2x, propagates BLOCKs |
| `dispatcher` | `mistral:7b` | Routes simple tasks to correct specialized agents |

### Design Phase Agents

| Agent | Model | Produces | Phase |
|---|---|---|---|
| `project-manager` | `gemma4:e4b` | `docs/PLAN.md` | 1 |
| `architect` | `gemma4:e4b` | `docs/ARCHITECTURE.md` | 2 |
| `quality-gate` | `gemma4:e4b` | Inline validation report | 3 |
| `qa-planner` | `gemma4:e4b` | `docs/QA_TESTCASES.md` | **4 (NEW)** |
| `tdd-guide` | `deepseek-coder-v2` | `docs/TDD_STUBS.md` | 5 |

### Build Phase Agents

| Agent | Model | Role |
|---|---|---|
| `developer` | `deepseek-coder-v2` | Core implementation using TDD stubs |
| `ui-engineer` | `gemma4:e4b` | Frontend, CSS, dashboards |
| `qa-engineer` | `gemma4:e4b` | Environment setup + smoke tests |
| `security-reviewer` | `gemma4:e4b` | Security audit |

### Support Agents

| Agent | Role |
|---|---|
| `code-reviewer` | Code quality review |
| `doc-updater` | Documentation maintenance |
| `git-agent` | Git operations |
| `improver` | Updates USER_PREFERENCES.md based on feedback |
| `memory-agent` | Reads/writes persistent context |
| `context-agent` | Resumes interrupted work from TASK_STATE.json |

---

## Commands Reference

Invoke these with `/command-name [arguments]` in OpenCode:

| Command | Agent | What It Does |
|---|---|---|
| `/design [feature]` | `pipeline-orchestrator` | Full 5-phase design pipeline with gate checkpoints |
| `/qa-plan [feature]` | `qa-planner` | Standalone QA test matrix generation |
| `/plan [feature]` | `project-manager` | Planning doc only |
| `/tdd [feature]` | `tdd-guide` | TDD stubs only |
| `/code-review` | `code-reviewer` | Review current code |
| `/security` | `security-reviewer` | Security audit |
| `/build-fix` | `build-error-resolver` | Fix build errors |
| `/e2e [feature]` | `e2e-runner` | E2E test generation |

---

## File Structure

```
.opencode/
├── opencode.json           # Main config: models, agents, commands
├── USER_PREFERENCES.md     # User memory: coding style, gate mode, preferences
├── TASK_STATE.json         # Active task stack (managed by agent-supervisor)
├── .agent-hardening-memory.md  # Anti-hallucination protocols
├── sync-agents-global.sh   # Sync agents to ~/.opencode/ for global use
├── verify-agents.sh        # Validate all agent files
├── agents/
│   ├── tech-lead.md            # Primary orchestrator (v2: two-phase workflow)
│   ├── pipeline-orchestrator.md # NEW v2: design pipeline with gates
│   ├── qa-planner.md           # NEW v2: QA test matrix generator
│   ├── agent-supervisor.md     # Updated v2: deliverable verification + retry
│   ├── tdd-guide.md            # Updated v2: deepseek-coder-v2 + deliverables
│   └── [33 other agents...]
├── commands/
│   ├── design.md               # NEW v2: /design command template
│   └── [existing commands...]
└── instructions/
    └── INSTRUCTIONS.md         # Global agent instructions

docs/                       # Generated by pipeline (auto-created)
├── PLAN.md                 # Created by project-manager (Gate 1)
├── ARCHITECTURE.md         # Created by architect (Gate 2)
├── QA_TESTCASES.md         # Created by qa-planner (Gate 4) -- NEW
└── TDD_STUBS.md            # Created by tdd-guide (Gate 5)
```

---

## Dry-Run Example

Here is a full walk-through of what happens when you type:
```
@tech-lead design a JWT authentication REST API
```

**Step 1 — tech-lead** receives the request (model: `gemma4:e4b`)  
Loads `USER_PREFERENCES.md`. Detects non-trivial task. Delegates to `pipeline-orchestrator` via `agent-supervisor`.

**Step 2 — pipeline-orchestrator** starts Phase 1  
Delegates to `project-manager`. Waits for `docs/PLAN.md` to be written.

**Step 3 — project-manager** writes `docs/PLAN.md`  
Contents: user stories, acceptance criteria, tech stack decisions.

**Step 4 — agent-supervisor** verifies `docs/PLAN.md` exists  
`ls -la docs/PLAN.md` → file found, 45 lines. Passes back to pipeline-orchestrator.

**Step 5 — Gate 1/5 shown to user**
```
+------------------------------------------------------
| GATE [1/5]: Planning Complete
| Deliverable: docs/PLAN.md (45 lines)
|
| Review the document above, then type:
|   "plan approved"  to proceed to Phase 2
|   "block: [reason]"  to pause and request changes
+------------------------------------------------------
```
User reads `docs/PLAN.md` and types: `plan approved`

**Step 6 — Phase 2: architect** writes `docs/ARCHITECTURE.md`  
Contents: component diagram, API spec, data models, security considerations.

**Step 7 — Gate 2/5** shown. User types: `arch lgtm`

**Step 8 — Phase 3: quality-gate** validates the architecture  
Checks for: undefined APIs, missing error handling, underspecified data models.  
Outputs: inline report. If clean, pipeline continues.

**Step 9 — Gate 3/5** shown. User types: `quality ok`

**Step 10 — Phase 4: qa-planner** writes `docs/QA_TESTCASES.md`  
Contents: 24 test cases across unit/integration/e2e/smoke categories, derived from acceptance criteria in PLAN.md.

**Step 11 — Gate 4/5** shown. User types: `qa approved`

**Step 12 — Phase 5: tdd-guide** writes `docs/TDD_STUBS.md`  
Model: `deepseek-coder-v2`. Contents: failing test stubs for each test case. Ready for Red-Green-Refactor cycle.

**Step 13 — Gate 5/5** shown. User types: `tdd ready`

**Step 14 — Design complete handoff**
```
Pipeline Complete. All 5 design artifacts produced.
Reply with "build start" to begin implementation.
```
User types: `build start`

**Step 15 — tech-lead Phase B (Build)**  
Delegates to: developer → qa-engineer → security-reviewer in sequence.  
Each delegation verified by agent-supervisor (file changes checked via `git diff --stat HEAD`).

**Step 16 — Sign-off**
```
Team Task Complete.
Design: docs/PLAN.md, docs/ARCHITECTURE.md, docs/QA_TESTCASES.md, docs/TDD_STUBS.md
Build: 12 files changed (+847 lines)
QA: smoke tests passed
Security: No critical issues found
Ready for review. Sign-off.
```

---

## Troubleshooting

### Pipeline Stopped with BLOCK:

The agent hit a problem it can't resolve alone. Read the BLOCK message carefully and either:
- Provide the missing information it's asking for
- Type `block: [clarification]` to redirect

### A Phase Produced No Output

The `agent-supervisor` will automatically retry up to 2 times with a more explicit prompt. If it fails twice, you'll see:
```
BLOCK: [Supervisor] Agent {name} failed to produce {deliverable} after 2 retries.
```
Action: Manually check if the `docs/` folder exists. If not, create it: `mkdir -p docs`

### Wrong Model Error

Verify your Ollama models are available:
```bash
ollama list
# Should show: gemma4:e4b, deepseek-coder-v2, deepseek-coder:1.3b
```

### Gate Not Appearing

Check `USER_PREFERENCES.md` to ensure `gate_mode` is set to `strict`. If it's `off`, no gates will appear.

### `docs/PLAN.md` Already Exists

If you run `/design` again on the same project, the old `docs/PLAN.md` will be overwritten. Back it up first if needed:
```bash
cp docs/PLAN.md docs/PLAN.md.backup
```

### Reset Pipeline State

If the pipeline seems stuck, reset the task state:
```bash
echo '{"active_stack": [], "status": "idle", "retries": {}}' > .opencode/TASK_STATE.json
```

---

## Customizing the Pipeline

### Change Gate Mode

Ask `@improver`:
```
@improver set gate_mode to relaxed in USER_PREFERENCES.md
```

### Skip a Phase

Edit `pipeline-orchestrator.md` to remove a phase from the sequence. Or invoke individual agents directly:
```
/plan    # Only planning
/qa-plan # Only QA test matrix
/tdd     # Only TDD stubs
```

### Add a New Phase

1. Create a new agent in `.opencode/agents/your-agent.md` with `phase: design` and a `deliverables:` field
2. Add it to the pipeline sequence in `pipeline-orchestrator.md`
3. Add a gate entry to the `USER_PREFERENCES.md` gates table
4. Sync: `./opencode/sync-agents-global.sh`

### Add a New Agent

```markdown
---
name: your-agent
description: What it does
mode: subagent
model: ollama/gemma4:e4b
phase: design  # or: build | review | deploy
deliverables:
  - docs/YOUR_OUTPUT.md
tools:
  read: true
  write: true
  bash: true
---

# Agent: Your Agent
...
```

Sync after creating: `./opencode/sync-agents-global.sh --tag "added-your-agent"`

---

## Key Files Quick Reference

| File | Purpose |
|---|---|
| `.opencode/opencode.json` | Main config: models, agent definitions, commands |
| `.opencode/USER_PREFERENCES.md` | Coding style, gate mode, TDD settings |
| `.opencode/agents/tech-lead.md` | Master orchestrator instructions |
| `.opencode/agents/pipeline-orchestrator.md` | Design pipeline + gate logic |
| `.opencode/agents/qa-planner.md` | QA test matrix generation |
| `.opencode/agents/agent-supervisor.md` | Deliverable verification + retry |
| `.opencode/commands/design.md` | /design command template |
| `.opencode/TASK_STATE.json` | Live pipeline state tracker |
| `.opencode/.agent-hardening-memory.md` | Anti-hallucination protocols |

---

*This guide covers the `opencode` branch (v2). For the original autonomous pipeline, see the `ollama` branch.*

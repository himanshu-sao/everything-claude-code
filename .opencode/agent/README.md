# OpenCode Agent System

## Architecture

```
                ┌─────────────┐
                │ DISPATCHER  │  ← General entry (primary)
                └─────────────┘
                       │
    ┌─────────────┬─────┴─────┬─────────────┐
    ▼             ▼           ▼            ▼
  task-dispatcher  excel-dispatcher  data-dispatcher  infra-dispatcher
 (code)          (Excel)        (Data)         (DevOps)
    │             │             │              │
    ▼             ▼             ▼              ▼
[code agents] [excel agents] [data agents] [infra agents]
```

## Agent Types

| Mode | Description |
|------|-------------|
| **primary** | Entry point, can spawn sub-agents |
| **subagent** | Specialized assistant |

## Primary Agent

| Agent | Mode | Model | Purpose |
|-------|------|-------|---------|
| **dispatcher** | primary | mistral:7b | General entry, routes to domains |

## Architecture Agents (under task-dispatcher)

| Agent | Mode | Model | Purpose |
|-------|------|-------|---------|
| architect | subagent | mistral:7b | System design, implementation plans |
| planner | subagent | mistral:7b | Task breakdown, progress tracking |
| builder | subagent | codellama:7b | Implementation, TDD workflow |

## Domain Dispatchers (subagent)

| Agent | Mode | Model | Domain |
|-------|------|-------|--------|
| task-dispatcher | subagent | mistral:7b | Code/Development |
| excel-dispatcher | subagent | mistral:7b | Excel/Spreadsheets |
| data-dispatcher | subagent | mistral:7b | Data Analysis |
| infra-dispatcher | subagent | mistral:7b | DevOps/Infra |
| research-dispatcher | subagent | mistral:7b | Research |

## Code Sub-Agents (under task-dispatcher)

| Agent | Model | Purpose |
|-------|-------|---------|
| java-agent | codellama:7b | Java/Spring Boot |
| go-agent | codellama:7b | Go development |
| python-agent | codellama:7b | Python/FastAPI |
| shell-agent | codellama:7b | Shell/CLI |
| tdd-guide | mistral:7b | TDD workflow |
| code-reviewer | mistral:7b | Code review |
| build-resolver | codellama:7b | Build errors |
| test-agent | codellama:7b | Unit tests |
| e2e-runner | mistral:7b | E2E tests |
| security-reviewer | mistral:7b | Security 
| git-agent | codellama:7b | Git operations |

## Usage

```
# Start with dispatcher (primary)
Task: dispatcher

# Or invoke specific domain dispatcher
Task: task-dispatcher for build Spring Boot app
Task: excel-dispatcher for create sales dashboard
Task: data-dispatcher for clean customer data

# Or invoke sub-agent directly
Task: java-agent
Task: python-agent
```

## Ollama Models

| Model | Size |
|-------|------|
| mistral:7b | 776 MB |
| codellama:7b | 3.8 GB |

1. Create domain-dispatcher.md in `.opencode/agents/`
2. Create sub-agents for that domain
3. Update dispatcher.md to include new domain

4. ## Architectural Notes

### Dispatcher Design

The agent system follows a hierarchical dispatch pattern:

1. **Primary Dispatcher** (`dispatcher.md`): Entry point that identifies task domain and routes to appropriate domain dispatcher

2. **Domain Dispatchers** (subagents): Each domain has a dispatcher that handles tasks directly:
   - `task-dispatcher`: Code/Development tasks (coordinates with language-specific agents)
   - `excel-dispatcher`: Excel/Spreadsheet tasks
   - `data-dispatcher`: Data Analysis and processing
   - `infra-dispatcher`: DevOps/Infrastructure tasks
   - `research-dispatcher`: Research and information gathering

3. **Sub-Agents**: Domain-specific execution agents (language agents, tool-specific agents, task agents)

### Key Design Principles

- **Single Responsibility**: Each agent has a focused role (planner, builder, reviewer, etc.)
- **Clear Escalation Paths**: Agents know when and where to escalate complex tasks
- **Task Coordination**: The Task tool enables multi-agent collaboration
- **Consistent Modeling**: Standard YAML frontmatter across all agents
- **Progressive Specialization**: General dispatcher → Domain dispatcher → Specialized agents

### Model Selection

- **mistral:7b** (776 MB): Used for orchestration, planning, and analysis tasks
- **codellama:7b** (3.8 GB): Used for code implementation, testing, and build-related tasks

The model choice balances performance with capability - mistral for general reasoning, codellama for code generation.

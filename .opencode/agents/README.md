# OpenCode Agents Directory

This directory contains 33 specialized OpenCode agents for various development tasks.

## Quick Reference

### Core Development
- `architect.md` - System design and architecture
- `planner.md` - Task breakdown and planning
- `builder.md` - Code implementation with TDD
- `code-reviewer.md` - Code quality review
- `security-reviewer.md` - Security analysis
- `tdd-guide.md` - Test-driven development

### Language-Specific
- `java-agent.md` - Java/Spring Boot
- `go-agent.md` - Go development
- `python-agent.md` - Python/FastAPI
- `shell-agent.md` - Shell scripting

### Build & Testing
- `build-resolver.md` - Build error fixes
- `test-agent.md` - Unit testing
- `e2e-runner.md` - End-to-end testing

### Specialized
- `database-reviewer.md` - Database optimization
- `doc-updater.md` - Documentation
- `git-agent.md` - Git operations
- `improver.md` - Code improvements

### Workflow Coordination
- `dispatcher.md` - General routing
- `task-dispatcher.md` - Code tasks
- `data-dispatcher.md` - Data analysis
- `excel-dispatcher.md` - Spreadsheets
- `infra-dispatcher.md` - DevOps
- `research-dispatcher.md` - Research

### Support
- `complexity-analyzer.md` - Task complexity
- `context-agent.md` - Context management
- `fallback-agent.md` - Fallback handling
- `memory-agent.md` - Learning persistence
- `metrics-agent.md` - Performance metrics
- `mcp-registry.md` - MCP management
- `pm-agent.md` - Project management
- `sandbox-agent.md` - Safe execution
- `ux-agent.md` - UX optimization
- `party-mode.md` - Experimental features

## Agent File Format

Each agent follows this structure:

```markdown
---
name: agent-name
description: Brief description
mode: subagent
model: ollama/model-name
tools:
  read: true
  write: true
  edit: true
  bash: true
---

Agent instructions and prompt...
```

## Usage

Agents are auto-discovered by OpenCode:

```bash
# List all agents
opencode agent list

# Invoke an agent
@planner help me plan a feature
@code-reviewer review my code
```

## Adding New Agents

1. Create `new-agent.md` in this directory
2. Add proper YAML frontmatter
3. Write agent instructions
4. OpenCode discovers it automatically

## Syncing to Global

Make agents available across all projects:

```bash
cd ..
./sync-agents-global.sh
```

This copies all agents to `~/.opencode/agents/` for global access.

## Documentation

See `../.opencode/README.md` for complete documentation.

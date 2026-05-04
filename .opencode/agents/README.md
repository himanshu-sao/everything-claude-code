# OpenCode Agents Directory

This directory contains 35+ specialized OpenCode agents for various development tasks.

## Quick Reference

### Core Development
- `architect.md` - System design and architecture
- `api-architect.md` - API design, contracts (OpenAPI)
- `project-manager.md` - Product & Project Management (PRD/Stories)
- `developer.md` - Code implementation with TDD
- `code-reviewer.md` - Code quality review
- `security-reviewer.md` - Security analysis
- `tdd-guide.md` - Test-driven development
- `qa-engineer.md` - Environment setup and validation

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
- `ui-engineer.md` - React/Next.js/UI implementation
- `deployment-agent.md` - CI/CD, Docker, and Cloud deployment
- `doc-updater.md` - Documentation
- `git-agent.md` - Git operations
- `improver.md` - Code improvements

### Workflow Coordination
- `dispatcher.md` - General routing
- `tech-lead.md` - Code tasks
- `data-dispatcher.md` - Data analysis
- `excel-dispatcher.md` - Spreadsheets
- `infra-dispatcher.md` - DevOps
- `research-dispatcher.md` - Research

### Support
- `analyzer-agent.md` - Complexity analysis and Performance tracking
- `ecosystem-optimizer.md` - Continuous Improvement (Meta-Cognitive)
- `context-agent.md` - Context management
- `fallback-agent.md` - Fallback handling
- `memory-agent.md` - Learning persistence
- `mcp-registry.md` - MCP management
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
@project-manager help me plan a feature
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

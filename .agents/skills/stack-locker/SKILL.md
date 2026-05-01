---
name: stack-locker
description: SDLC Hardening Skill. Scans the repository to identify the current tech stack and generates a 01_TECH_STACK.md file to prevent shadow dependencies.
---

# Skill: Stack-Locker

Use this skill during the Planning Phase to "freeze" the tech stack and prevent AI agents from introducing unauthorized libraries or frameworks.

## Instructions for the Tech-Lead
1. **Trigger**: Invoke this skill before finalizing `02_DESIGN.md`.
2. **Scan**: Analyze `package.json`, `requirements.txt`, `go.mod`, etc. to determine the existing stack.
3. **Lock**: Create or update `.planning/[task-slug]/01_TECH_STACK.md`.
4. **Enforce**: During Proxy Execution, if a worker returns an `EXECUTE:` block that adds a library not in the `01_TECH_STACK.md`, you MUST reject it unless explicitly approved by the user.

## Format of 01_TECH_STACK.md
```markdown
# Tech Stack Lock
- **Frontend**: React, Tailwind
- **Backend**: Node.js, Express
- **Database**: PostgreSQL
- **Testing**: Jest

> [!WARNING]
> Do not introduce any new core dependencies outside of this list.
```

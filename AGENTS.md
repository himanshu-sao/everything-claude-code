# Everything Claude Code (ECC) — Agent Instructions

This is a **production-ready AI coding plugin** providing 48 specialized agents, 183 skills, 79 commands, and automated hook workflows for software development.

**Version:** 1.11.0

## Core Principles

1. **Agent-First** — Delegate to specialized agents for domain tasks
2. **Test-Driven** — Write tests before implementation, 80%+ coverage required
3. **Security-First** — Never compromise on security; validate all inputs
4. **Immutability** — Always create new objects, never mutate existing ones
5. **Plan Before Execute** — Plan complex features before writing code
6. **Sign-off & Return** — Always signal task completion and explicitly return control to the caller.
7. **Deliverable Verification (MANDATORY)** — You are FORBIDDEN from reporting a task as complete or a design as finished unless you have verified that the expected files exist on disk using `read` or `list_dir`. Do NOT simulate work "internally."
8. **Context Continuity (MANDATORY)** — When delegating via the `task` tool, you MUST include the project name and the full content (or a mandatory `read` instruction) of the previous phase's deliverable in the `prompt`. Sub-agents do NOT share memory; you must provide their context explicitly.
9. **Gate Registry Protocol (MANDATORY)** — If you hit a gate (user approval required), you MUST write the gate details to `.opencode/GATE.json` before signing off. Every caller agent MUST check this file immediately after a `task` returns to ensure visibility.

## Available Agents

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| project-manager | Product & Project Management | Requirements, Stories, & Breakdown |
| tech-lead | Absolute Orchestration | The Single Source of Truth and Unified Execution Layer |
| developer | Code Implementation | TDD, logic, and core development |
| qa-engineer | Quality Assurance & Runtime | Env setup, validation, smoke tests |
| ui-engineer | Frontend & UX | React, Next.js, and Tailwind CSS |
| architect | System design and scalability | Architectural decisions |
| api-architect | API design and contracts | OpenAPI/REST/GraphQL design |
| e2e-runner | End-to-end Playwright testing | Critical user flows |
| refactor-cleaner | Dead code cleanup | Code maintenance |
| doc-updater | Documentation and codemaps | Updating docs |
| cpp-reviewer | C/C++ code review | C and C++ projects |
| cpp-build-resolver | C/C++ build errors | C and C++ build failures |
| docs-lookup | Documentation lookup via Context7 | API/docs questions |
| go-reviewer | Go code review | Go projects |
| go-build-resolver | Go build errors | Go build failures |
| kotlin-reviewer | Kotlin code review | Kotlin/Android/KMP projects |
| kotlin-build-resolver | Kotlin/Gradle build errors | Kotlin build failures |
| database-reviewer | PostgreSQL/Supabase specialist | Schema design, query optimization |
| python-reviewer | Python code review | Python projects |
| java-reviewer | Java and Spring Boot code review | Java/Spring Boot projects |
| java-build-resolver | Java/Maven/Gradle build errors | Java build failures |
| loop-operator | Autonomous loop execution | Run loops safely, monitor stalls, intervene |
| harness-optimizer | Harness config tuning | Reliability, cost, throughput |
| rust-reviewer | Rust code review | Rust projects |
| rust-build-resolver | Rust build errors | Rust build failures |
| pytorch-build-resolver | PyTorch runtime/CUDA/training errors | PyTorch build/training failures |
| typescript-reviewer | TypeScript/JavaScript code review | TypeScript/JavaScript projects |

## Agent Orchestration

Use agents proactively without user prompt:
- Complex feature requests → **project-manager**
- Code just written/modified → **code-reviewer**
- Bug fix or new feature → **tdd-guide**
- Architectural decision → **architect**
- Security-sensitive code → **security-reviewer**
- Autonomous loops / loop monitoring → **loop-operator**
- Harness config reliability and cost → **harness-optimizer**

Use parallel execution for independent operations — launch multiple agents simultaneously.

## Call & Return Protocol

When an agent is invoked via the **Task** tool:
1. **Blocked Caller**: The calling agent is blocked until the tool returns.
2. **Explicit Completion**: The called agent MUST provide a final summary and state "Task complete" or "Sign-off" to terminate its turn.
3. **Avoid Deadlocks (BLOCK EMISSION)**: Do not wait for user input or ask questions in plain text. If you need clarification, approval, or have a question for the user, you MUST prefix your response with "BLOCK: [Your Question]" and explicitly sign off to terminate your turn.
4. **State Resumption (BLOCK MANAGEMENT)**: If an outer agent receives an output from a sub-agent prefixed with "BLOCK:" (or a "Task initiated" placeholder), the outer agent MUST immediately stop, report it EXACTLY as received to its caller, and sign off. When later invoked with the user's answer, it must re-invoke the blocked sub-agent with the new context.
5. **The Absolute Orchestrator**: The `tech-lead` is the "Single Source of Truth". All complex workflows MUST be routed through the `tech-lead`. Direct delegation between sub-agents (e.g., `developer` -> `project-manager`) is prohibited to ensure centralized stack monitoring.
6. **Task Stack Monitoring**: The Tech-Lead MUST ensure any blocks or stalls are immediately bubbled up to the user by propagating the "BLOCK:" prefix.
7. **Zero-Silence Mandate (CRITICAL)**: If a tool call (especially `task`) returns a result that is empty, blank, or contains only a `task_id` without a `task_result` summary, you MUST NOT assume the task is "processing in the background." You MUST treat this as a **System Stall** and report: `BLOCK: System Stall detected in [Agent Name]. The tool returned no progress data.`
8. **Zero-Work Detection (MANDATORY)**: If you call a sub-agent and the `task_result` shows **0 toolcalls** and no new files on disk, you MUST treat the sub-agent as having failed/yapped. Do NOT summarize its text as success. Immediately retry once with a "STRICT_TOOL_USE" instruction or report a `BLOCK: Hallucination detected.`

## 8. Tool Parameter Requirements (MANDATORY)

To prevent `SchemaError`, you MUST provide all required parameters for tool calls. Do NOT output these as text; use the built-in tool-use mechanism.

- **task**: Requires `subagent_type` (target agent name), `prompt` (detailed instructions), and `description` (short summary of the task goal). **IMPORTANT**: `subagent_type` MUST be all lowercase (e.g., `tech-lead`, `agent-supervisor`). **CRITICAL SCHEMA RULE**: Do NOT include the `task_id` parameter in your tool call under ANY circumstances unless explicitly provided by the user to resume a task. NEVER set it to null. Omit it completely.
- **write**: Requires `path` and `content`.
- **edit**: Requires `path` and `changes`.
- **bash**: Requires `command` and `description`.
- **grep_search**: Requires `SearchPath` and `Query`.

## 9. XML Tool Protocol (FOR LOCAL MODELS)

If you are running on a local model (via Ollama/Local-Bridge) and native tool calls are failing, you MUST use the following XML format in your plain-text response. The OpenCode harness will intercept and execute these:

```xml
<tool_call>
{"name": "tool_name", "arguments": {"arg1": "value1"}}
</tool_call>
```

**CRITICAL**: Do NOT "hallucinate" the result. Wait for the harness to provide the `<tool_result>` in the next turn.

## Security Guidelines

**Before ANY commit:**
- No hardcoded secrets (API keys, passwords, tokens)
- All user inputs validated
- SQL injection prevention (parameterized queries)
- XSS prevention (sanitized HTML)
- CSRF protection enabled
- Authentication/authorization verified
- Rate limiting on all endpoints
- Error messages don't leak sensitive data

**Secret management:** NEVER hardcode secrets. Use environment variables or a secret manager. Validate required secrets at startup. Rotate any exposed secrets immediately.

**If security issue found:** STOP → use security-reviewer agent → fix CRITICAL issues → rotate exposed secrets → review codebase for similar issues.

## Coding Style

**Immutability (CRITICAL):** Always create new objects, never mutate. Return new copies with changes applied.

**File organization:** Many small files over few large ones. 200-400 lines typical, 800 max. Organize by feature/domain, not by type. High cohesion, low coupling.

**Error handling:** Handle errors at every level. Provide user-friendly messages in UI code. Log detailed context server-side. Never silently swallow errors.

**Input validation:** Validate all user input at system boundaries. Use schema-based validation. Fail fast with clear messages. Never trust external data.

**Code quality checklist:**
- Functions small (<50 lines), files focused (<800 lines)
- No deep nesting (>4 levels)
- Proper error handling, no hardcoded values
- Readable, well-named identifiers

## Testing Requirements

**Minimum coverage: 80%**

Test types (all required):
1. **Unit tests** — Individual functions, utilities, components
2. **Integration tests** — API endpoints, database operations
3. **E2E tests** — Critical user flows

**TDD workflow (mandatory):**
1. Write test first (RED) — test should FAIL
2. Write minimal implementation (GREEN) — test should PASS
3. Refactor (IMPROVE) — verify coverage 80%+

Troubleshoot failures: check test isolation → verify mocks → fix implementation (not tests, unless tests are wrong).

## Development Workflow

1. **Plan** — Use **project-manager** agent, identify dependencies and risks, break into phases
2. **TDD** — Use **tdd-guide** agent, write tests first, implement, refactor
3. **Review** — Use **code-reviewer** agent immediately, address CRITICAL/HIGH issues
3.5 **Validate** — Use **qa-engineer** to ensure environment and execution works "out of the box"
4. **Capture knowledge in the right place**
   - Personal debugging notes, preferences, and temporary context → auto memory
   - Team/project knowledge (architecture decisions, API changes, runbooks) → the project's existing docs structure
   - If the current task already produces the relevant docs or code comments, do not duplicate the same information elsewhere
   - If there is no obvious project doc location, ask before creating a new top-level file
5. **Commit** — Conventional commits format, comprehensive PR summaries

## Workflow Surface Policy

- `skills/` is the canonical workflow surface.
- New workflow contributions should land in `skills/` first.
- `commands/` is a legacy slash-entry compatibility surface and should only be added or updated when a shim is still required for migration or cross-harness parity.

## Git Workflow

**Commit format:** `<type>: <description>` — Types: feat, fix, refactor, docs, test, chore, perf, ci

**PR workflow:** Analyze full commit history → draft comprehensive summary → include test plan → push with `-u` flag.

## Architecture Patterns

**API response format:** Consistent envelope with success indicator, data payload, error message, and pagination metadata.

**Repository pattern:** Encapsulate data access behind standard interface (findAll, findById, create, update, delete). Business logic depends on abstract interface, not storage mechanism.

**Skeleton projects:** Search for battle-tested templates, evaluate with parallel agents (security, extensibility, relevance), clone best match, iterate within proven structure.

## Performance

**Context management:** Avoid last 20% of context window for large refactoring and multi-file features. Lower-sensitivity tasks (single edits, docs, simple fixes) tolerate higher utilization.

**Build troubleshooting:** Use build-error-resolver agent → analyze errors → fix incrementally → verify after each fix.

## Project Structure

```
agents/          — 48 specialized subagents
skills/          — 183 workflow skills and domain knowledge
commands/        — 79 slash commands
hooks/           — Trigger-based automations
rules/           — Always-follow guidelines (common + per-language)
scripts/         — Cross-platform Node.js utilities
mcp-configs/     — 14 MCP server configurations
tests/           — Test suite
```

`commands/` remains in the repo for compatibility, but the long-term direction is skills-first.

## Success Metrics

- All tests pass with 80%+ coverage
- No security vulnerabilities
- Code is readable and maintainable
- Performance is acceptable
- User requirements are met

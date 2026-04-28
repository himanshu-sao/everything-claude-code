# Product Lifecycle Workflow (5-Step Process)

This skill defines the mandatory Standard Operating Procedure (SOP) for all development tasks in this environment.

## The 5-Step Chain

### 1. Requirement Analysis (`@ba-agent`)
- **Input**: Jira Ticket, Git Issue, or User Request.
- **Action**: Identify stakeholders, invariants, and constraints.
- **Output**: Analysis summary.

### 2. Document Creation (`@ba-agent`)
- **Action**: Create/Update PRD.md or SRS.md.
- **Rule**: No code can be written until the documentation reflects the change.

### 3. Story Translation (`@story-writer`)
- **Input**: PRD/SRS.
- **Action**: Break into atomic user stories with Acceptance Criteria (AC).
- **Output**: Jira Stories or `STORIES.md`.

### 4. TDD & Coding (`@build` / `@builder`)
- **Input**: User Story AC.
- **Action**: Write failing tests first (RED), then minimal code (GREEN), then refactor.
- **Requirement**: 80%+ test coverage.

### 5. Testing & Validation (`@test-agent` / `@perf-engineer`)
- **Action**: Run unit, integration, E2E, and performance benchmarks.
- **Output**: Verification Walkthrough and Performance Report.

---

## 🔄 Recursive Multi-Pass Governance
To ensure production-ready outcomes, all critical outputs must go through a **minimum of two passes**.

### The Review Loop SOP:
1. **DRAFT**: The primary agent (e.g., `@architect` or `@builder`) produces the first version.
2. **AUDIT**: A peer agent (e.g., `@code-reviewer`, `@security-reviewer`, or `@perf-engineer`) performs a critical scan.
3. **REFINE**: The primary agent must address all CRITICAL and HIGH findings from the audit.
4. **FINAL GATE**: The `@quality-gate` agent must provide final sign-off.

### Recursive Design Loop:
- **Design Pass 1**: Draft architecture.
- **Review Pass 2**: Security and Performance audit.
- **Design Pass 3**: Final refined architecture with invariants and error handling.

### Recursive Code Loop:
- **Code Pass 1**: TDD Implementation (Red/Green).
- **Review Pass 2**: Static analysis and readability check.
- **Code Pass 3**: Refactored production-ready code.

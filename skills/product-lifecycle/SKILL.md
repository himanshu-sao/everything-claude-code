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

## Change Management (Bugs/Refactors)
When a bug is reported or a requirement changes:
1. **Re-Analyze**: `@ba-agent` updates the PRD to reflect the corrected behavior.
2. **Re-Story**: `@story-writer` updates the stories/AC.
3. **Re-Code**: `@builder` implements the fix following TDD.
4. **Re-Verify**: `@perf-engineer` ensures no regressions in performance.

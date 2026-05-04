# Design Pipeline Command

You are running the `/design` command. Your task is to execute the **full design pipeline** for the feature or task described in `$ARGUMENTS`.

## What You Will Do

Delegate to the `pipeline-orchestrator` agent to run the following 5-phase design pipeline, with mandatory user gate checkpoints between each phase:

```
Phase 1: project-manager  → docs/PLAN.md
                  GATE: "plan approved"
Phase 2: architect         → docs/ARCHITECTURE.md
                  GATE: "arch lgtm"
Phase 3: quality-gate      → architecture validation report
                  GATE: "quality ok"
Phase 4: qa-planner        → docs/QA_TESTCASES.md
                  GATE: "qa approved"
Phase 5: tdd-guide         → docs/TDD_STUBS.md
                  GATE: "tdd ready"
```

## Invocation

Call the `task` tool with:

```json
{
  "description": "Run design pipeline",
  "prompt": "Run the following task using agent pipeline-orchestrator: Run the full 5-phase design pipeline for the following feature request. Apply USER_PREFERENCES.md for context.\n\nFeature Request:\n$ARGUMENTS",
  "subagent_type": "agent-supervisor"
}
```

## Output

After the pipeline completes all 5 phases and the user types `tdd ready`, output:

```
Design pipeline complete.

Artifacts produced:
  ✔ docs/PLAN.md
  ✔ docs/ARCHITECTURE.md
  ✔ docs/QA_TESTCASES.md
  ✔ docs/TDD_STUBS.md

Reply with "build start" when you are ready to begin implementation.
```

## Gate Continue Phrases Reference

| Gate | Phrase |
|---|---|
| After Planning | `plan approved` |
| After Architecture | `arch lgtm` |
| After Quality Gate | `quality ok` |
| After QA Test Matrix | `qa approved` |
| After TDD Stubs | `tdd ready` |
| Start Build Phase | `build start` |

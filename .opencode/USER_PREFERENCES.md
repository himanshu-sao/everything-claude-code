# User Preferences & Persistent Learnings

This file is the "Memory" of the OpenCode environment. All agents must read this file to align with the user's specific style and expectations.

## 🏗️ Architectural Preferences
- **SDLC**: Follow the 5-step Product Lifecycle (Analysis -> Doc -> Stories -> Code -> Test).
- **Quality**: Enforce the Recursive Multi-Pass rule (Draft -> Audit -> Refine).
- **RAM Strategy**: Use the tiered model strategy (Heavy/Medium/Utility/Chat).
- **ADRs**: Mandatory Architectural Decision Records must be written for any structural changes.

## 💻 Coding Style
- **TDD Enforcement**: Minimum 80% test coverage is required for all new code. Tests must be written before implementation (Red/Green/Refactor).
- *Pending additional feedback... (Ask @improver to update)*

## 🤝 Workflow & Persona
- **Dispatcher**: Use the Chat agent as the primary entry point for simple tasks.
- **Tone**: Professional, concise, and production-oriented.


## 🚦 Pipeline Gates
- **gate_mode**: `strict` — User must approve each design phase before pipeline advances.
- **continue_phrase**: Use phase-specific phrases (see table below).
- **per_phase_phrases**: `true`

### Gate Continue Phrases
| Phase Completed | Required Phrase |
|---|---|
| Planning (`docs/PLAN.md`) | `plan approved` |
| Architecture (`docs/ARCHITECTURE.md`) | `arch lgtm` |
| Quality Gate (validation report) | `quality ok` |
| QA Test Matrix (`docs/QA_TESTCASES.md`) | `qa approved` |
| TDD Stubs (`docs/TDD_STUBS.md`) | `tdd ready` |
| Build complete (all code written) | `build start` *(triggers build phase)* |

### Gate Behavior Rules
- **User must type the exact continue phrase** to advance to the next phase.
- If user types `block: [reason]`, the current phase must be revised before proceeding.
- Gate mode can be set to `relaxed` (warning only) or `off` (legacy NO PAUSES behavior) by asking `@improver` to update this file.
- *(Managed by `@improver` based on your feedback.)*

---
*Note: This file is managed by the `@improver` agent based on your feedback.*

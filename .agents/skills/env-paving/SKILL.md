---
name: env-paving
description: SDLC Hardening Skill. Generates portable environment setup scripts at the end of a project to prevent "it works on my machine" errors.
---

# Skill: Env-Paving

Use this skill during the Handover Phase (Step 4) to ensure the project is easily portable and reproducible by other developers or CI/CD systems.

## Instructions for the Tech-Lead
1. **Trigger**: Invoke this skill after `04_TESTS.md` have passed successfully.
2. **Analyze**: Review `03_DEPS.md` and the final codebase.
3. **Generate**: Create an `init-setup.sh` or a `Dockerfile` in the project root.
4. **Verify**: If safe, execute the script in a dry-run or verification mode to ensure no syntax errors exist.
5. **Handover**: Present the setup script to the user as part of the final Task Completion sign-off.

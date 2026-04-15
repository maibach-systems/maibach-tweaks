---
description: "Review and fix changes since last stable commit."
---

# /check-changes

Reviews all changes since the last stable commit. Checks build, tests, regressions, plan compliance, and reuse. Fixes problems via subagents and updates the plan if one exists.

## Steps

### 1. Determine Scope

Run in parallel:
- `git log --oneline -20` — identify the last stable commit (look for the most recent commit before current work started, or the last deploy commit)
- `git diff <stable-commit>..HEAD` — capture all changed files and diffs
- `git status` — capture any unstaged changes

State the scope explicitly: which commits are included, which files changed.

### 2. Checks

Run all checks. For independent checks, spawn subagents in parallel.

**Build:**
- Run the project's build command
- Any compiler errors or warnings → flag as blocking

**Tests:**
- Run test suite if present (`npm test`, `pytest`, etc.)
- Report pass/fail count, flag any regressions vs main branch

**Regressions:**
- For each changed file, check: did the change break any caller, consumer, or related module?
- Grep for usages of renamed/removed functions or types
- Verify no import paths broken

**Plan Compliance:**
- If `.claude/current-plan.md` exists: compare implemented changes against the plan
- Flag deviations: missing steps, scope creep, skipped validations
- Flag if any phase was marked done but its changes are missing

**Reuse:**
- Were existing types used (not redefined locally)?
- Were existing components/utils reused where available?
- Were new abstractions introduced without 3+ usage points justifying them?

### 3. Fix Problems

Group fixable problems by concern. Spawn one subagent per independent fix cluster in parallel. Do not fix items that require user decisions — list them as open items instead.

After fixes: re-run build and affected checks to confirm resolution. Commit fixes with a short descriptive message.

### 4. Update Plan

If `.claude/current-plan.md` exists:
- Mark completed phases as ✔
- Update the active phase marker (◼)
- Note any blockers or open items in the plan file

### 5. Output Format

```
SCOPE
  Commits: <hash range>
  Files changed: N

PASSED
  - Build: ok
  - Tests: N passed
  - ...

FIXED (committed as <hash>)
  - [file:line] description of fix

OPEN (requires manual decision)
  - description
```

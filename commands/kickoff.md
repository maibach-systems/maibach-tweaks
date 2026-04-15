---
description: "Plan a project. Own tools, extending existing projects, new ideas."
---

# /kickoff

Plans a project from scratch. Works for new projects, extending existing ones, and tooling. Produces a structured plan saved to `.claude/current-plan.md`. Does not implement anything.

## Steps

### 1. Read Existing Code (if applicable)

If a codebase already exists:
- Read `CLAUDE.md` files (root and subdirectories) to understand project conventions
- Read `package.json` / `pyproject.toml` / equivalent for dependencies and scripts
- Scan directory structure (`ls` key directories)
- Read 2-3 representative source files to internalize code style and patterns

Skip this step only if starting from a completely empty directory.

### 2. Briefing Questions

Ask the following questions. Wait for the user's answers before continuing.

1. **What are we building?** Describe the feature, tool, or project in one paragraph.
2. **Stack and environment:** What languages, frameworks, runtimes, deployment targets?
3. **Constraints:** Performance requirements, budget, timeline, team size, existing integrations that must not break?
4. **Existing integrations:** What systems does this need to connect to (APIs, databases, auth providers, third-party services)?
5. **Definition of done:** What does success look like? What is explicitly out of scope?

Do not proceed to Step 3 until answers are received.

### 3. Define Architecture

Based on the briefing, define:

**Directory structure:** What new directories and files will be created? Where do they live relative to existing code?

**Dependencies:** What new packages or services are needed? Why each one (don't add dependencies without justification)?

**Interfaces and contracts:** What are the key data shapes, API contracts, and component APIs? Define these explicitly — they are the seams between phases.

**Key decisions with reasoning:** For each non-obvious choice (framework, data model, state management approach), state: option chosen, alternatives considered, reason for the choice.

### 4. Define Phases

Break work into phases grouped by what can be deployed together (a deploy group = phases that must ship together to be functional).

For each deploy group:

```
## Deploy Group A: [Name]
Goal: one sentence describing what this group delivers

### Phase 1: [Name]
- What to do (2-3 bullet points, specific enough to implement)
- Key files: list affected files
- Dependencies: what must exist before this phase starts

### Phase 2: [Name]
- ...

→ DEPLOY + STOP
```

Phase order should minimize integration risk: foundation before features, data layer before UI, happy path before edge cases.

### 5. Save Plan

Write the complete plan to `.claude/current-plan.md` using this structure:

```markdown
# Plan: [Project Name]

## Context
[2-3 sentences: what problem this solves and why, written so a fresh Claude in a new session understands the intent]

## Architecture
[Directory structure, key decisions, interfaces]

## Deploy Group A: [Name]
### Phase 1: ... ◻
### Phase 2: ... ◻
→ DEPLOY + STOP

## Deploy Group B: [Name]
### Phase 3: ... ◻
→ DEPLOY + STOP
```

**STOP after saving. Do not implement. Present the plan to the user and wait for confirmation.**

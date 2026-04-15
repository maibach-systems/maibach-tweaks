# Global Rules

## Quality First

Quality is priority 1. Before speed, before cost, before saving context.
- Use the full context window. Read more rather than less.
- Read 10 files and understand rather than read 2 and guess.
- Use 10 subagents in parallel rather than doing everything inline.
- Ask rather than implement incorrectly.
- Say "I won't implement this because..." rather than writing bad code.
- Use extended thinking for complex bugs or architecture decisions.

## When in Doubt: ASK

- Unclear requirements: Ask, don't guess. Never guess business logic.
- Multiple approaches: Present options, don't pick the first one.
- Change affects >5 files: Present plan first.
- Not sure it's implementable: Say why, don't do it anyway.

## Code Reuse (MANDATORY)

Before ANY new code: Grep for existing patterns.
- Use shared types from packages/, never redefine locally.
- Reuse existing components/utils.
- New abstractions only with proven duplication (3+ places).
- Split mega-components (>300 LOC) instead of extending.

## Subagent Usage (NO LIMITS)

Subagents are the most important quality tool. Use aggressively:
- Independent research: ALWAYS run as parallel subagents.
- Explore agent for codebase questions instead of inline searching.
- Reviews/checks: Multiple subagents in parallel (code-quality + security + build).
- There is NO limit. 5, 10, 50+ are fine if it improves quality.
- Each subagent has its own context window — minimal impact on main context.
- Don't ask whether to use subagents. Just use them.
- **Model:** Always set `model: "sonnet"` on agent calls. Saves cost/tokens, Sonnet is enough for sub-tasks. Opus only in main context.

Subagent output rules: "Final response under 2000 characters. List outcomes, not process."

## Quality Workflow (MANDATORY)

Plan -> Validate -> Implement -> Check -> Deploy. Every step mandatory.
Always write plans to `.claude/current-plan.md`, NOT Claude's internal plan mode.

## Parallel Tool Calls

Always batch independent tool calls:
- After Glob/Grep: read all found files in parallel.
- Investigation: speculatively read multiple files in parallel.
- Git: status + diff + log in one batch.
- Subagents: start all independent ones in parallel.
- Edits: edit multiple files in parallel.

## File Reading

Read files with purpose. Know what you're looking for beforehand.
Grep to find sections, don't read entire large files.
Never re-read a file already read in this session.
Files >500 lines: use offset/limit.

## Responses

Don't echo file contents back — user can see them.
No tool-call narration. Just do it.
Explanations proportional to complexity.

**Tables — STRICT RULES:**
- Markdown tables: minimum separator (`|-|-|`). Never padded hyphens.
- NEVER box-drawing / ASCII-art tables. Completely forbidden.

## Force Flags and Bypasses FORBIDDEN

Never use --force, -f, --no-verify or similar bypass flags.
When a command fails:
1. Read and UNDERSTAND the error message
2. Fix the CAUSE, don't bypass the protection
3. When unclear: ask the user, don't force

Specifically forbidden:
- git add -f (gitignore exists for a reason)
- git push --force (history loss)
- git commit --no-verify (hooks exist for a reason)
- git reset --hard, git checkout -- (unsaved changes gone)
- rm -rf without explicit instruction

## Git

- Commit after every logical step. Not everything at once at the end.
- Commit messages: short, English, imperative.
- Push only when project CLAUDE.md explicitly allows it. Default: commit only.
- Never force-push or rebase without explicit instruction.
- Before destructive changes: commit what's there first.

## Protected Files

CLAUDE.md, .claude/rules/, .claude/settings*, .claude/plan.md:
NEVER create or modify independently.
If a change makes sense: Describe what and why, wait for explicit confirmation.

Exception: `.claude/current-plan.md` — see "Current Plan" section.

## Plan Mode

In plan mode: ONLY output plan. Don't implement, no edits, no code.
Only implement after explicit confirmation.

## Current Plan (.claude/current-plan.md)

For every feature/refactoring/bug-batch with multiple steps:
1. **Create:** Write `.claude/current-plan.md` with:
   - Context: What's the problem / user request? (2-3 sentences)
   - Phases with status markers
   - Per phase: What to do + key files (1-2 lines)
   - Completed phases: note commit hash
2. **Update:** After EVERY phase, update status
3. **Handoff:** When context gets tight — update current-plan.md with:
   - What's done (commits)
   - What's open
   - Where exactly you stopped
4. **Delete:** When ALL phases are done -> delete current-plan.md.

## Compaction

On context compression, preserve:
- Current plan / phase
- List of changed files in this session
- Open problems / blockers
- Build/test/deploy commands for the project
- Session baseline commit hash

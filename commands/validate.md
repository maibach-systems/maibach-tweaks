---
description: "Ruthlessly critique the last plan. Assumptions, edge cases, overengineering."
---

# /validate

Ruthlessly critiques the current plan in `.claude/current-plan.md`. Covers assumptions, production failure modes, edge cases, overengineering, dependencies, and reuse. Updates the plan with revisions. Does not implement anything.

## Scope

Only the plan in `.claude/current-plan.md` in the current session. If no plan file exists, state that and stop.

## Critique Checklist

Work through each point systematically. Be specific — vague praise or vague criticism is useless.

### 1. Unchecked Assumptions

What does the plan assume to be true without verifying?
- Data shapes, API contracts, type compatibility
- Library behavior or availability
- User behavior or input format
- Existing code structure matching what the plan expects

For each assumption: is it verified? If not, what breaks if it's wrong?

### 2. Production Failure Modes

How does this fail in production?
- Network errors, timeouts, rate limits
- Concurrent requests hitting the same state
- Empty states, null/undefined, missing optional fields
- Large data volumes the plan wasn't tested against
- Auth edge cases (expired tokens, missing permissions)

### 3. Missing Edge Cases

What inputs, states, or sequences does the plan not handle?
- Boundary values (0, 1, max)
- User-generated content (XSS, special characters, very long strings)
- Partial failures (step 2 of 3 fails)
- Repeated actions (double-submit, double-click)
- Mobile/slow network behavior

### 4. Overengineering

Is the plan more complex than the problem demands?
- Could a simpler data structure suffice?
- Is a new abstraction justified, or does it add indirection without value?
- Are there intermediate layers (services, adapters) that don't carry their weight?
- Could this be done in half the phases?

### 5. Overlooked Dependencies and Side Effects

What else does this touch?
- Shared state, global stores, caches
- Other features consuming the same API or component
- Database migrations affecting existing queries
- Type changes rippling through consumers

### 6. Active Search for Weaknesses

Beyond the checklist: what is the single most likely way this plan fails? What would a hostile code reviewer attack first?

### 7. Reuse Check

- Are new types being defined that already exist (especially in `packages/types/` or equivalent)?
- Are new components being built that duplicate existing ones?
- Are new utils/hooks being written when existing ones could be extended?
- Are new API routes being added when existing ones could be parameterized?

## Output and Plan Update

List all findings, grouped by the checklist sections above. For each finding: state the problem, the risk, and a concrete resolution.

Then update `.claude/current-plan.md`:
- Add a `## Validation Notes` section at the top with a summary of critical findings and how the plan was revised to address them
- Revise phase descriptions or add phases where gaps were found
- Mark any phase that needs additional validation steps

**STOP after updating the plan. Do not implement.**

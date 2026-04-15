---
description: "Analyze code for refactoring potential. Duplication, naming, types, complexity."
---

# /refactor

Analyzes the codebase for refactoring opportunities. Covers duplication, long functions, unclear naming, type coverage, unused imports, and deep nesting. Output is grouped by impact. No auto-fix — analysis only.

## Checks

### 1. Duplication

- Identify repeated logic blocks (3+ near-identical implementations)
- Repeated type definitions that should be shared
- Copy-pasted component structures that could be parameterized
- Similar API handlers with identical boilerplate

For each: show the duplicated code fragments and suggest a unified abstraction with a before/after sketch.

### 2. Long Functions

- Flag any function or method exceeding 50 lines
- Flag any component render function exceeding 100 lines
- For each: identify the natural split points (each distinct responsibility becomes its own function)

### 3. Unclear Naming

- Variables named `data`, `result`, `temp`, `obj`, `val`, `info`, `stuff`
- Boolean variables not prefixed with `is`, `has`, `can`, `should`
- Functions named `handle`, `process`, `do`, `run` without a specific subject
- Single-letter variables outside of tight loops or math
- Misleading names (name implies X, behavior is Y)

For each: suggest a precise replacement name.

### 4. Missing Types / Excessive `any`

- Explicit `any` types (TypeScript) or missing type annotations (Python, Go)
- Function return types inferred as `any` or `unknown` without narrowing
- Props typed as `object` or `Record<string, any>` where a specific shape is known
- Type assertions (`as X`) used to paper over real type mismatches

For each: suggest the correct type or note what information is needed to derive it.

### 5. Unused Imports

- Imported symbols never referenced in the file
- Entire modules imported but only one export used (consider named import instead)
- Re-exports that are never consumed downstream

### 6. Deep Nesting

- Conditionals nested more than 3 levels deep
- Callbacks nested more than 2 levels deep (callback pyramid)
- Suggest: early returns, guard clauses, extraction to named functions, async/await

## Output Format

Group findings by impact:

```
HIGH IMPACT
  [file:line] description
  Before: <sketch>
  After:  <sketch>
  Affected files: list

MEDIUM IMPACT
  ...

LOW IMPACT
  ...
```

High = affects correctness risk, readability across many callsites, or significant duplication.
Medium = localized complexity, naming issues in important modules.
Low = style, minor naming, single-file cleanup.

**Analysis only. No edits, no commits.**

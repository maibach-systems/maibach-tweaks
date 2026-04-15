---
description: "Check codebase for existing patterns before building new ones."
---

# /reuse-check

Scans the codebase for existing patterns relevant to what is about to be built. Prevents duplication by surfacing what already exists and how to use or extend it. Run this before implementing any new feature, component, type, or utility.

## Steps

### 1. Read Inventory Files

Read in parallel:
- Root `CLAUDE.md` and any `CLAUDE.md` in subdirectories
- Any project inventory files (`packages/types/`, `src/components/index.ts`, `src/utils/index.ts`, or equivalent barrel files)
- Design token files (constants, theme files)

These give a map of what the project knows about itself.

### 2. Search for Existing Types

- Grep for type/interface definitions matching the domain of what you're building
- Check `packages/types/` or equivalent shared type package first
- Check if the type exists but under a different name (search by field names, not just type name)

### 3. Search for Similar Components

- Grep for component names matching the UI pattern (Modal, Dialog, Sheet, Drawer, Card, Table, List, Form, Input, Button variants)
- Read any matches to understand their props API
- Check if the needed variant is just a prop away from an existing component

### 4. Search for Similar Utils / Hooks

- Grep for function names in `utils/`, `hooks/`, `lib/`, `helpers/`
- Search by behavior keyword (format, parse, validate, fetch, transform, debounce, throttle)
- Check if an existing hook covers the use case with different configuration

### 5. Search for Similar API Routes

- Grep route definitions for similar resource names or path patterns
- Check if the needed operation is a missing method on an existing route (GET exists, need POST)
- Check for existing middleware or guards that should be reused

### 6. Search for Similar Patterns Elsewhere

- Find 2-3 existing implementations of the closest analog in the codebase
- Read them to understand the established pattern (error handling, loading states, data fetching approach)

## Output Format

```
REUSE — use directly
  TypeName in packages/types/foo.ts — matches your need exactly
  ComponentName in src/components/Bar.tsx — pass variant="X"

EXTEND — exists, needs adaptation
  useExistingHook in src/hooks/baz.ts — add optional param Y
  /api/resource in src/routes/resource.ts — add POST handler

BUILD NEW — does not exist (justified)
  NewFeatureComponent — no analog found; closest is X but structurally different because Z

WARNING — potential duplication
  You are about to define LocalType which overlaps with SharedType (packages/types/shared.ts:42)
  Resolve before implementing.
```

Do not proceed to implementation. Surface findings and stop — let the developer decide.

---
description: "Design consistency check. Scan all components for inconsistencies in colors, spacing, typography, buttons, animations. Web projects only."
---

# /consistency

Scans all components and styles for design inconsistencies. Flags hardcoded values that bypass the design system, inconsistent component patterns, and deviations from the established visual language. Web projects only.

## Prerequisites

Before scanning, locate:
- Design token file (constants.ts, tokens.ts, theme.ts, or CSS custom properties in a global stylesheet)
- List of all component files

Read the token file first to understand the established palette, spacing scale, type scale, and animation values.

## Checks

### 1. Hardcoded Color Values

Grep all component files for:
- Hex values (`#[0-9a-fA-F]{3,6}`)
- `rgb(` / `rgba(` / `hsl(` used inline
- Tailwind arbitrary color values (`text-[#...]`, `bg-[#...]`)

For each hit: check if a design token covers this value. Flag as inconsistency if a token exists. Flag as undocumented color if no token covers it.

### 2. Hardcoded Spacing / Sizing Values

Grep for:
- Inline `style={{ margin: ..., padding: ..., gap: ..., width: ..., height: ... }}` with pixel values
- Tailwind arbitrary values for spacing (`p-[14px]`, `mt-[22px]`)
- Magic pixel numbers in CSS modules or styled components that don't correspond to spacing scale

### 3. Button Style Consistency

Find all `<button>` elements and button-like components across the codebase. Check:
- Same button variant (primary, secondary, ghost, destructive) uses identical styles everywhere
- Hover, focus, and disabled states defined consistently
- Icon-only buttons have `aria-label`

### 4. Animation Duration and Easing Consistency

Grep for `transition`, `animation`, `duration`, `ease` values. Check:
- Duration values cluster around a defined scale (e.g., 150ms, 200ms, 300ms) or are arbitrary
- Easing functions are consistent (`ease-out` for entrances, `ease-in` for exits, or project-specific convention)
- No `transition: all` (performance issue and over-broad)

### 5. Spacing System Compliance

Check that padding, margin, and gap values come from the spacing scale. Any value not on the scale (e.g., 13px, 22px, 37px) is a flag.

### 6. Typography Hierarchy

Grep all heading elements and text style classes. Check:
- `h1`–`h6` map to consistent font sizes and weights across pages
- Body text size is consistent (no mix of 14px, 15px, 16px for the same semantic level)
- Line heights defined for body text
- No font-family overrides outside the token system

### 7. Border Radius Consistency

Grep for `border-radius`, `rounded-` classes. Check:
- Same component type uses same radius everywhere (e.g., all cards use `rounded-lg`, all inputs use `rounded-md`)
- No arbitrary radius values that don't match the scale

## Output Format

Per category:

```
COLORS
  [file:line] #F28C28 used directly — should be var(--color-primary) or token equivalent
  [file:line] rgba(0,0,0,0.5) — undocumented color, no token

SPACING
  [file:line] style={{ padding: '14px' }} — not on spacing scale

...
```

## Fix

After analysis, fix inconsistencies by replacing hardcoded values with design tokens or Tailwind classes. Commit fixes grouped by category.

---
description: "Full project audit. Security, code quality, and project-type specific checks."
---

# /audit

Full project audit covering security, code quality, and project-type-specific checks. Spawns parallel subagents, then fixes all Critical and High findings before stopping.

## Steps

### 1. Detect Project Type

Scan root directory for marker files:
- `package.json` → web project
- `wrangler.toml` → Cloudflare Worker
- `requirements.txt` or `pyproject.toml` → Python
- `go.mod` → Go
- Multiple markers → apply all matching rule sets

### 2. Universal Checks (all project types)

Spawn these two subagents **in parallel**, wait for both to finish:

- **@security** — check for secrets in source, insecure dependencies, injection vectors, CORS misconfiguration, missing auth guards, overly permissive roles
- **@code-quality** — check naming, dead code, overly complex functions, missing types, excessive `any`, magic numbers, commented-out code

Also run:
- Build check: run the project's build command, capture any errors or warnings
- Dependency audit: `npm audit` / `pip audit` / equivalent for detected stack. Flag High and Critical CVEs.

### 3. Web-Specific Checks

Only if project type is web:

**SEO:**
- Each page has unique `<title>` and `<meta name="description">`
- Structured data (JSON-LD) present where applicable
- `sitemap.xml` exists and is referenced in `robots.txt`
- `robots.txt` present and not blocking important paths
- Canonical URLs set

**Performance:**
- Run Lighthouse CLI if available (`npx lighthouse --output=json`)
- Font sizes: body >= 16px on mobile
- Images use modern formats (WebP/AVIF), have `width`/`height` attributes
- Cache headers set for static assets
- No render-blocking resources in `<head>` without `defer`/`async`

**Accessibility:**
- `<main>` element present on every page
- Skip-link ("Skip to content") present and functional
- `focus-visible` styles not suppressed globally (`outline: none` without replacement)
- Color contrast >= 4.5:1 for normal text, >= 3:1 for large text
- All `<img>` have non-empty `alt` attributes (decorative images use `alt=""`)
- Interactive elements reachable and operable via keyboard
- Touch targets >= 44x44px on mobile

**Mobile:**
- Layout tested at 375px, 768px, 1440px breakpoints
- No horizontal overflow at any breakpoint
- `<meta name="viewport">` present

### 4. Non-Web Checks

Only if project type is NOT web:

- Test coverage: report overall percentage, flag files below 60%
- Typing coverage: report percentage of typed vs untyped symbols

### 5. Output Format

Report findings grouped by severity:

```
CRITICAL  [file:line] description
HIGH      [file:line] description
MEDIUM    [file:line] description
LOW       [file:line] description
```

### 6. Fix Critical and High

Spawn one subagent per independent fix cluster, in parallel. Commit fixes. Re-run affected checks to verify resolution. List remaining open items if any could not be auto-fixed.

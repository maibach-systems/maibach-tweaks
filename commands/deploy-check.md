---
description: "Pre-deployment checklist. Project-type aware."
---

# /deploy-check

Runs a comprehensive pre-deployment checklist before any production deploy. Detects project type and applies the appropriate rule set. Output is clear: ready, missing (non-blocking), or blocking.

## Steps

### 1. Detect Project Type

Check root for: `package.json`, `wrangler.toml`, `requirements.txt`, `pyproject.toml`, `go.mod`. Apply all matching rule sets.

### 2. Universal Checks (all project types)

**Build:**
- Run the project's build command. Any error → BLOCKING.
- Zero compiler errors or type errors (`tsc --noEmit` for TypeScript).

**Environment Variables:**
- All env vars referenced in code are documented (`.env.example`, README, or equivalent).
- No `.env` or secrets file included in the build output or committed to git.
- No `localhost` or `127.0.0.1` hardcoded in production code paths.
- All external URLs use HTTPS.

**Security:**
- Security headers configured: `Content-Security-Policy`, `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`.
- No API keys, tokens, or secrets in client-side bundle. Grep for common patterns (`sk-`, `Bearer `, `API_KEY =`, base64-looking strings).
- `npm audit` / `pip audit` / equivalent — no Critical or High CVEs in production dependencies.

**Tests:**
- Test suite passes (if tests exist).

### 3. Web-Specific Checks

Only if project type is web:

**Discoverability:**
- `robots.txt` exists and does not block important paths.
- `sitemap.xml` exists, linked from `robots.txt`.
- Each page has a unique `<title>` and `<meta name="description">`.
- Canonical URLs set on all pages.
- OG tags present (`og:title`, `og:description`, `og:image`, `og:url`).

**Redirects:**
- `www` ↔ non-www redirect configured (pick one canonical form).
- Old URLs redirect correctly if routes changed.

**Analytics and Consent:**
- Analytics script present (if required by project).
- Cookie consent banner present if cookies are set (required in EU).

**Assets:**
- Images optimized (WebP/AVIF format, `width`/`height` attributes set).
- Favicon present (`/favicon.ico` or `<link rel="icon">`).
- Fonts: subset or loaded with `font-display: swap`.

### 4. Output Format

```
STATUS: READY / NOT READY

BLOCKING (must fix before deploy)
  [ ] Build: compiler errors in src/foo.ts:42
  [ ] Secret exposed in client bundle: STRIPE_KEY in dist/index.js

MISSING (non-blocking, fix soon)
  [ ] sitemap.xml not found
  [ ] OG image missing on /about

PASSED
  [x] Build clean
  [x] Tests: 42 passed
  [x] No secrets in bundle
  [x] HTTPS enforced
  ...
```

If STATUS is NOT READY: do not proceed with deploy. Fix all BLOCKING items first, then re-run `/deploy-check`.

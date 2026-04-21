<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-Config_Kit-F28C28?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IndoaXRlIiBzdHJva2Utd2lkdGg9IjIiPjxwYXRoIGQ9Ik0xMiAyTDIgN2wxMCA1IDEwLTUtMTAtNXoiLz48cGF0aCBkPSJNMiAxN2wxMCA1IDEwLTUiLz48cGF0aCBkPSJNMiAxMmwxMCA1IDEwLTUiLz48L3N2Zz4=" alt="Maibach Tweaks" />
  <br/>
  <img src="https://img.shields.io/badge/system--prompt-replaces_CC_default-F28C28?style=flat-square" alt="system prompt replacement" />
  <img src="https://img.shields.io/badge/hooks-9-blue?style=flat-square" alt="9 hooks" />
  <img src="https://img.shields.io/badge/agents-3-blue?style=flat-square" alt="3 agents" />
  <img src="https://img.shields.io/badge/commands-8-blue?style=flat-square" alt="8 commands" />
  <img src="https://img.shields.io/badge/CC-%E2%89%A5_2.1.112-green?style=flat-square" alt="CC >= 2.1.112" />
  <img src="https://img.shields.io/badge/macOS_%7C_Linux-supported-green?style=flat-square" alt="macOS | Linux" />
</p>

<p align="center">
  <strong>System-prompt replacement, hooks, agents, commands and settings for Claude Code.</strong><br/>
  <sub>Built from daily production use. Not theory — every piece exists because the default behavior caused a real problem.</sub>
</p>

---

## The Problem

Claude Code's default system prompt contains instructions like:

> *"Don't add features, refactor, or introduce abstractions beyond what the task requires"*
> *"Don't add error handling"*
> *"Three similar lines is better than a premature abstraction"*
> *"Don't clean up surrounding code"*
> *"Keep text between tool calls to ≤25 words. Keep final responses to ≤100 words"*

These are reasonable guardrails for casual use. For production work, they cause the model to cut corners, skip edge cases, avoid thorough investigation, produce brittle code that needs immediate follow-up, and trigger the "anxiety/apology spiral" mode that recent research (Amanda Askell, Anthropic) identifies as a direct output-quality killer.

Maibach Tweaks replaces the whole behavior block of the default system prompt with an Askell-conform, source-citation-enforcing, senior-engineer-toned variant — while leaving tool schemas, project-level CLAUDE.md, and subagent infrastructure intact.

---

## How It Works — and Why It Survives Updates

The repo ships a 13 KB custom system prompt (`config/my-system-prompt.txt`). An alias passes it to every Claude Code session via the documented `--system-prompt-file` CLI flag. That flag **fully replaces** the behavior-instruction block of the default prompt (verified via HTTP-proxy capture — the outgoing `system` field in the API request contains your custom text, not Anthropic's default).

No binary patching. No file watchers. No JavaScript string replacement that breaks on every CC version bump.

> [!IMPORTANT]
> The older `patches/patch-claude-code.sh` approach (regex replacements on `cli.js`) is **deprecated as of CC 2.1.113**. The npm package no longer ships patchable JavaScript; everything is compiled into a native Mach-O/ELF binary via per-platform optional dependencies. The patch script is kept in the repo for users still on CC ≤ 2.1.112, but the recommended path is the `--system-prompt-file` approach below.

---

## Quick Start

```bash
git clone https://github.com/maibach-systems/maibach-tweaks.git
cd maibach-tweaks

# See what would be installed (no changes)
./install.sh --dry-run

# Install (creates backup first)
./install.sh

# Add aliases to your shell
echo 'source ~/.claude/aliases.zsh'  >> ~/.zshrc     # zsh
echo 'source ~/.claude/aliases.bash' >> ~/.bashrc   # bash

# Open a fresh terminal, then try it
claudem     # Max effort, Opus 4.7 1M context, with custom system prompt
```

> [!NOTE]
> The installer never overwrites existing `CLAUDE.md`, `settings.json`, or `keybindings.json`. Your config stays intact. `my-system-prompt.txt` and `statusline-command.sh` are always copied (backed up first).

---

## What's Inside

### `config/my-system-prompt.txt` — Replacement System Prompt

A single ~13 KB text file that replaces the behavior-instruction block of Claude Code's default system prompt at runtime via `--system-prompt-file`. Organized into sections:

| Section | Purpose |
|-|-|
| Role | Askell-conform senior-engineer opener. Explicit permission to disagree, no apology spirals, no defensive hedging. |
| Work Quality | Read relevant files before concluding. Complete thoroughness without gold-plating. Adjacent broken code fixable. Real boundaries need validation. |
| Sources, Facts, Verification | Distinguish verified vs. from-memory. Cite URLs/paths/commands with line numbers. Tool output treated as claims, not facts. No silent upgrade of unsourced subagent claims. |
| Subagent Usage | Aggressive parallelism. Verbatim-quote rules for delegation prompts. Synthesis-layer spot-check mandatory. Hook-referenced skills loaded verbatim from `~/.claude/commands/` or `~/.claude/agents/`. |
| Tool Usage | Dedicated tools before Bash. Parallel calls when independent. TaskCreate for multi-step work. |
| Workflow Scaling | Simple/Medium/Complex ladder. Project CLAUDE.md/rules override defaults. No speculative planning documents. |
| Executing Actions | Blast-radius-aware confirmation. Force-flag ban. Investigate unexpected state before overwriting. |
| Output Style | ASCII tables in code blocks (no Unicode box-drawing). Proportional end-of-turn summary. No narration of internal deliberation. |
| Security | Authorized testing OK, destructive/mass-targeting refused. OWASP top-10 awareness. No secret-file commits. |
| Project Context | Project-level rules override these global defaults. Project-specific assumptions don't leak to other projects. |

**Design principles:**
- Positive instructions over negations (Askell-principle — reduces anxiety mode)
- Concrete, measurable criteria over vague adjectives (Opus-4.7 takes instructions literally, per Anthropic's own migration note)
- Project-agnostic — works in any repo, defers project rules to project-level `CLAUDE.md`/`.claude/rules/`
- No hidden length caps (no "≤25 words" / "≤100 words" anxiety triggers)
- Explicit source-citation and verification-rules for factual claims + subagent synthesis

---

### `patches/` — Legacy JavaScript Patches (CC ≤ 2.1.112 only)

> [!WARNING]
> Deprecated on CC 2.1.113+. Kept for historical reference and users on older CC versions.

19 regex replacements originally applied to CC's `cli.js` before Anthropic moved prompts into a compiled native binary. The **intent** of each patch is now baked into `config/my-system-prompt.txt` as a positive instruction rather than a post-hoc override.

<details>
<summary><strong>Original patch intents (now superseded by my-system-prompt.txt)</strong></summary>

| # | Intent | Where it lives now |
|-|-|-|
| 1-3 | Remove brevity/simplicity bias | "Work Quality" + "Output Style" sections |
| 4 | Allow fixing adjacent broken code | "Work Quality" — scope-of-task vs scope-of-file |
| 5 | Error handling at real boundaries | "Work Quality" |
| 6 | Use judgment on abstractions | "Work Quality" |
| 7 | Thorough completion, not gold-plating | "Work Quality" |
| 8 | Explore agent thoroughness | User's own `~/.claude/agents/` override |
| 9 | "Clear and appropriately detailed" | "Output Style" |
| 10 | Subagent code snippets when useful | "Subagent Usage" |
| 11 | Related issues may be fixed | "Work Quality" |
| 12 | Source citation enforcement | "Sources, Facts, Verification" |
| 13 | Tool output skepticism | "Sources, Facts, Verification" |
| 14 | Subagent summaries pass sources | "Subagent Usage" |
| 15 | Box-drawing tables banned | "Output Style" |
| 16 | Hook-referenced skills loaded verbatim | "Subagent Usage" |
| 17 | Planning docs when project rules require | "Workflow Scaling" |
| 18 | Proportional end-of-turn summaries | "Output Style" |

</details>

---

### `hooks/` — Guardrails and Workflow Enforcement

9 shell scripts wired into Claude Code's hook system:

#### Security (PreToolUse — blocks before execution)

| Hook | What it does |
|-|-|
| `block-force-flags.sh` | Blocks `git --force`, `--no-verify`, `--hard` — forces fixing root cause |
| `block-env-edit.sh` | Blocks any edit to `.env*` files |
| `block-secrets.sh` | Scans writes for API key patterns (AWS, GitHub, Stripe) and blocks |
| `protect-config.sh` | Requires confirmation before editing CLAUDE.md, settings, rules |

#### Workflow (PostToolUse — enforces after execution)

| Hook | What it does |
|-|-|
| `file-length-warning.sh` | Warns when a source file exceeds 300 LOC after edit |
| `plan-created-validate.sh` | Forces plan-griller validation when a new plan is created |
| `phase-complete-stop.sh` | Enforces grep-verify + check-changes at deploy boundaries |

#### Context (PreCompact / PostCompact)

| Hook | What it does |
|-|-|
| `pre-compact.sh` | Saves plan, git state, branch, latest plan file to `.claude/session-state.md` before compression |
| `post-compact.sh` | Re-injects critical rules, plan, deploy commands after compression |

> [!TIP]
> The compaction hooks solve the "Claude forgets the plan after context compression" problem. State is saved before and re-injected after.

---

### `agents/` — 3 Specialized Subagents

Subagents run in their own context window. Spawn them for specific tasks instead of doing everything in the main thread.

| Agent | Model | Purpose |
|-|-|-|
| `plan-griller` | Opus | Adversarial plan validator — finds problems, not praise |
| `security` | Opus | Security audit — XSS, injection, secrets, deps, auth, headers |
| `code-quality` | Opus | Code review — dead code, duplication, performance, naming, types |

> [!NOTE]
> All three agents use Opus for deeper reasoning on quality-critical tasks. Add your own agents in `~/.claude/agents/` — see [Customization](#customization).

---

### `commands/` — 8 Slash Commands

Type `/command-name` in Claude Code to run these. Each orchestrates multiple subagents with concrete checklists.

| Command | What it does |
|-|-|
| `/audit` | Full project audit: security + code quality + web-specific (SEO, perf, a11y) |
| `/check-changes` | Review git diff since last stable commit — build, tests, regressions, reuse |
| `/validate` | Ruthlessly critique the current plan — assumptions, edge cases, overengineering |
| `/refactor` | Analyze code for refactoring — duplication, naming, types, complexity |
| `/reuse-check` | Find existing patterns before building new ones |
| `/consistency` | Design consistency check — colors, spacing, typography, animations |
| `/deploy-check` | Pre-deployment checklist — project-type aware |
| `/kickoff` | Plan a project — briefing, architecture, phased plan |

---

### `config/` — Settings, Instructions, Keybindings

**`CLAUDE.md`** — Global instructions that apply to every project:
- Quality-first philosophy (read more, use subagents, ask don't guess)
- Code reuse enforcement (grep before new code, shared types only)
- Parallel tool calls (batch independent reads, edits, subagents)
- Protected files (CLAUDE.md, settings, rules require confirmation)
- Plan workflow (current-plan.md with phase tracking and handoff support)
- Force-flag ban (--force, --no-verify, --hard blocked at instruction + hook level)

**`settings.json`** — Pre-configured with:
- 128K output + thinking tokens
- All hooks wired
- Custom statusline
- Permission bypass for common tools, ask-mode for destructive ops
- Auto-memory disabled (explicit over implicit)
- Session recap enabled (`awaySummaryEnabled`)

**`keybindings.json`** — Vim-style navigation (j/k in lists, settings, message selector) plus shortcuts for thinking toggle (Ctrl+Shift+L), model picker (Meta+P), undo (Ctrl+_), stash (Ctrl+S).

**`my-system-prompt.txt`** — Loaded via `--system-prompt-file` alias flag. This is the heart of the repo — see dedicated section above for structure.

---

### `statusline/` — Custom Status Bar

Shows at a glance:

```
my-project main*  │  ████░░░░ 47%  $2.34  +142 -38  23m  Opus4.71M
     ↑       ↑ ↑        ↑       ↑      ↑      ↑     ↑
  project branch dirty context  cost  lines  time  model
```

Color-coded context bar: green (<50%), yellow (50-80%), red (>80%). Cost turns yellow >$1, red >$5. Dirty branch marker when uncommitted changes exist. Agent name shown when in subagent context. Model display shows version number (Opus4.7, Sonnet4.6, etc.).

---

### `aliases/` — Shell Shortcuts

```bash
claudem   # Max effort, Opus 4.7 1M context
claudex   # Extra-high effort, Opus 4.7 1M (new xhigh level)
claudeh   # High effort, Opus 4.7 1M
claudeo   # Default effort, Opus 4.7 1M
claudems  # High effort, Sonnet 4.6
claudes   # Default effort, Sonnet 4.6
```

All aliases auto-inject `--dangerously-skip-permissions` and pass the custom system prompt via `--system-prompt-file ~/.claude/my-system-prompt.txt`. That flag replaces the 17+ KB Anthropic default behavior block with the 13 KB custom variant. Tool schemas, project CLAUDE.md, and subagent prompts are unaffected.

```bash
# Add to your shell
echo 'source ~/.claude/aliases.zsh' >> ~/.zshrc     # zsh
echo 'source ~/.claude/aliases.bash' >> ~/.bashrc   # bash
```

---

## Installer

```bash
./install.sh                  # Install with backup
./install.sh --dry-run        # Preview without changes
./install.sh --status         # Show what's installed
./install.sh --backup-only    # Only backup current config
./install.sh --restore        # Restore from backup
./install.sh --uninstall      # Remove tweaks + restore backup
```

The installer backs up your existing `~/.claude/` config before touching anything. It skips config files that already exist (CLAUDE.md, settings.json, keybindings.json) — hooks, agents, and commands are always copied.

---

## Customization

### Add Your Own Agent

```markdown
# ~/.claude/agents/my-agent.md
---
name: my-agent
description: One-line description for the picker.
tools: Read, Write, Edit, Bash, Glob, Grep
model: sonnet
---

Your prompt here. Be specific about what it checks,
what tools to use, and what the output format should be.
```

### Add Your Own Command

```markdown
# ~/.claude/commands/my-command.md
---
description: One-line description for the picker.
---

Step-by-step instructions. Reference agents with @agent-name.
Orchestrate parallel subagents for independent work.
```

### Custom Spinner

The included `settings.json` ships with custom spinner verbs. Swap them out in `settings.json`:

```json
{
  "spinnerVerbs": {
    "mode": "replace",
    "verbs": ["Pondering", "Scheming", "Tinkering", "Noodling", "Wrangling"]
  }
}
```

### Recommended Post-Install Settings

These settings are stored via `/config` (interactive), not in settings.json:

```
/tui fullscreen                    # Flicker-free rendering (v2.1.110+)
/theme → Auto (match terminal)    # Matches dark/light from terminal (v2.1.111+)
/config → Show last response in external editor → on    # Ctrl+G shows context (v2.1.110+)
```

---

## File Structure

```
maibach-tweaks/
├── install.sh                      Installer with backup/restore/uninstall/dry-run
│
├── config/
│   ├── my-system-prompt.txt        Replacement system prompt (--system-prompt-file)
│   ├── CLAUDE.md                   Global user-role instructions
│   ├── settings.json               Permissions, hooks, env vars, statusline
│   └── keybindings.json            Vim-style navigation
│
├── patches/
│   └── patch-claude-code.sh        LEGACY: 19 JS patches (CC <= 2.1.112 only)
│
├── hooks/
│   ├── block-env-edit.sh           Block .env edits
│   ├── block-force-flags.sh        Block --force / --no-verify
│   ├── block-secrets.sh            Block API key writes
│   ├── protect-config.sh           Confirm before config edits
│   ├── file-length-warning.sh      Warn on >300 LOC
│   ├── plan-created-validate.sh    Force plan validation
│   ├── phase-complete-stop.sh      Enforce deploy-group workflow
│   ├── pre-compact.sh              Save state before compaction
│   └── post-compact.sh             Restore state after compaction
│
├── agents/
│   ├── plan-griller.md             Adversarial plan validation (Opus)
│   ├── security.md                 Security audit (Opus)
│   └── code-quality.md             Code review (Opus)
│
├── commands/
│   ├── audit.md                    Full project audit
│   ├── check-changes.md            Review git diff
│   ├── validate.md                 Critique plan
│   ├── refactor.md                 Refactoring analysis
│   ├── reuse-check.md              Find reusable patterns
│   ├── consistency.md              Design consistency
│   ├── deploy-check.md             Pre-deploy checklist
│   └── kickoff.md                  Project planning
│
├── statusline/
│   └── statusline-command.sh       Custom status bar
│
└── aliases/
    ├── aliases.zsh                 zsh aliases
    └── aliases.bash                bash aliases
```

---

## Requirements

- **Claude Code CLI** — installed and working (2.1.112 or newer recommended; aliases + `--system-prompt-file` approach works on all ≥ 2.1.112)
- **jq** — for hooks (`brew install jq` on macOS, usually pre-installed on Linux)
- **Node.js >= 18** — only if using the legacy patch script on CC ≤ 2.1.112

---

## License

MIT — use it, fork it, adapt it.

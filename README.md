<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-Config_Kit-F28C28?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IndoaXRlIiBzdHJva2Utd2lkdGg9IjIiPjxwYXRoIGQ9Ik0xMiAyTDIgN2wxMCA1IDEwLTUtMTAtNXoiLz48cGF0aCBkPSJNMiAxN2wxMCA1IDEwLTUiLz48cGF0aCBkPSJNMiAxMmwxMCA1IDEwLTUiLz48L3N2Zz4=" alt="Maibach Tweaks" />
  <br/>
  <img src="https://img.shields.io/badge/patches-19-blue?style=flat-square" alt="19 patches" />
  <img src="https://img.shields.io/badge/hooks-9-blue?style=flat-square" alt="9 hooks" />
  <img src="https://img.shields.io/badge/agents-3-blue?style=flat-square" alt="3 agents" />
  <img src="https://img.shields.io/badge/commands-8-blue?style=flat-square" alt="8 commands" />
  <img src="https://img.shields.io/badge/macOS_%7C_Linux-supported-green?style=flat-square" alt="macOS | Linux" />
</p>

<p align="center">
  <strong>Patches, hooks, agents, commands and settings for Claude Code.</strong><br/>
  <sub>Built from daily production use. Not theory — every piece exists because the default behavior caused a real problem.</sub>
</p>

---

## The Problem

Claude Code's default system prompt contains instructions like:

> *"Don't add features, refactor, or introduce abstractions beyond what the task requires"*
> *"Don't add error handling"*
> *"Three similar lines is better than a premature abstraction"*
> *"Don't clean up surrounding code"*

These are reasonable guardrails for casual use. For production work, they cause the model to cut corners, skip edge cases, avoid thorough investigation, and produce brittle code that needs immediate follow-up.

Maibach Tweaks fixes this at every layer — from the binary prompt to the workflow enforcement.

---

## Quick Start

```bash
git clone https://github.com/maibach-systems/maibach-tweaks.git
cd maibach-tweaks

# See what would be installed (no changes)
./install.sh --dry-run

# Install (creates backup first)
./install.sh

# Apply prompt patches
~/.claude/patch-claude-code.sh

# Auto-repatch after updates (optional)
~/.claude/patch-claude-code.sh --watch
```

> [!NOTE]
> The installer never overwrites existing `CLAUDE.md`, `settings.json`, or `keybindings.json`. Your config stays intact.

---

## What's Inside

### `patches/` — Binary Prompt Patches

19 string replacements applied to Claude Code's `cli.js` (with version-specific variants for cross-version compatibility). The core ones:

<table>
<tr><th width="40">#</th><th>Default</th><th>Patched</th></tr>
<tr><td>4</td><td><code>Don't add features beyond what the task requires</code></td><td>Fix adjacent broken code discovered during investigation</td></tr>
<tr><td>5</td><td><code>Don't add error handling</code></td><td><code>Add error handling at real boundaries</code> (I/O, APIs, user input)</td></tr>
<tr><td>7</td><td><code>Don't gold-plate</code></td><td>Do thorough work including edge cases</td></tr>
<tr><td>8</td><td>Explore agent optimized for speed</td><td>Explore agent optimized for thoroughness</td></tr>
<tr><td>12</td><td>No source citation rules</td><td>Must cite sources, never state training data as current truth</td></tr>
<tr><td>13</td><td>Tool output trusted implicitly</td><td>Tool output treated as claims — must verify before relaying</td></tr>
<tr><td>17</td><td>Planning documents banned</td><td>Allowed when project rules require them (current-plan.md)</td></tr>
<tr><td>18</td><td>"One or two sentences" end-of-turn summary</td><td>Proportional summaries — complex work gets structured output</td></tr>
</table>

<details>
<summary><strong>All patches</strong></summary>

| # | What Changes |
|-|-|
| 1-3 | Brevity/simplicity bias removed (obsolete in v2.1.110+ — Anthropic adopted similar wording) |
| 4 | Adjacent broken code may be fixed during investigation (v109 + v112+ variants) |
| 5 | Error handling encouraged at real boundaries |
| 6 | "Three lines > abstraction" → use judgment (v109 variant; merged into patch 4 for v112+) |
| 7 | "Don't gold-plate" → thorough work including edge cases |
| 8 | Explore agent: speed → thoroughness |
| 9 | "Short and concise" → "clear and appropriately detailed" |
| 10 | Code snippets allowed in subagent output when useful |
| 11 | Closely related issues may be fixed during work |
| 12 | Source citation enforcement, no training-data-as-truth |
| 13 | Tool output skepticism (WebFetch, search, subagents) |
| 14 | Subagent summaries must pass through source citations |
| 15 | Box-drawing tables banned, markdown tables enforced |
| 16 | Hook-referenced skills loaded from definition, not paraphrased |
| 17 | Planning documents allowed when project rules require them |
| 18 | End-of-turn summaries proportional to task complexity |

</details>

**Cross-version support:** Patches 4 and 6 include version-specific variants (v2.1.109 and v2.1.112+ wording) so the script works across Claude Code versions. Skipped patches are expected — they target text that Anthropic already removed or reworded.

**Auto-update survival:** The `--watch` flag installs a file watcher (launchd on macOS, systemd on Linux) that monitors `~/.local/share/claude/versions/` and re-patches automatically when Claude Code updates itself.

```bash
~/.claude/patch-claude-code.sh --watch    # install watcher
~/.claude/patch-claude-code.sh --check    # verify patches are applied
~/.claude/patch-claude-code.sh --restore  # undo everything
```

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

**`system-prompt.txt`** — Injected per session via aliases. Scales ceremony to task size: simple tasks get no plan overhead, complex tasks get full plan-validate-implement-check workflow.

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

All aliases auto-inject `--dangerously-skip-permissions` and the system prompt from `~/.claude/system-prompt.txt`.

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
├── patches/
│   └── patch-claude-code.sh        19 prompt patches + auto-update watcher
│
├── config/
│   ├── CLAUDE.md                   Global instructions
│   ├── settings.json               Permissions, hooks, env vars, statusline
│   ├── keybindings.json            Vim-style navigation
│   └── system-prompt.txt           Per-session workflow injection
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

- **Claude Code CLI** — installed and working
- **Node.js >= 18** — for the patch script
- **jq** — for hooks (`brew install jq` on macOS, usually pre-installed on Linux)

---

## License

MIT — use it, fork it, adapt it.

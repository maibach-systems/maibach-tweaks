#!/bin/bash
# PreCompact Hook — saves session state before context compression

OUT="$PWD/.claude/session-state.md"
mkdir -p "$(dirname "$OUT")" 2>/dev/null

{
  echo "# Session State (auto-saved before compaction)"
  echo "Saved: $(date '+%Y-%m-%d %H:%M')"
  echo ""

  # Current plan (active task)
  if [ -f "$PWD/.claude/current-plan.md" ]; then
    echo "## ACTIVE PLAN (current-plan.md)"
    cat "$PWD/.claude/current-plan.md"
    echo ""
  fi

  # Long-term plan
  if [ -f "$PWD/.claude/plan.md" ]; then
    echo "## Master Plan"
    head -30 "$PWD/.claude/plan.md"
    echo "..."
    echo ""
  fi

  # Changed files in this session (uncommitted)
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "## Uncommitted Changes"
    git diff --stat 2>/dev/null
    echo ""

    echo "## Recent Commits (last 5)"
    git log --oneline -5 2>/dev/null
    echo ""

    echo "## Current Branch"
    git branch --show-current 2>/dev/null
    echo ""
  fi

  # Active tasks from Claude plans dir
  PLANS_DIR="$HOME/.claude/plans"
  if [ -d "$PLANS_DIR" ]; then
    LATEST=$(ls -t "$PLANS_DIR"/*.md 2>/dev/null | head -1)
    if [ -n "$LATEST" ]; then
      echo "## Latest Plan File"
      echo "$(basename "$LATEST")"
      head -20 "$LATEST"
      echo "..."
      echo ""
    fi
  fi

} > "$OUT" 2>/dev/null

exit 0

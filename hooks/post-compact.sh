#!/bin/bash
# PostCompact Hook — re-injects critical context after compaction

STATE="$PWD/.claude/session-state.md"

{
  echo "=== POST-COMPACTION CONTEXT ==="
  echo ""
  echo "## Critical Rules (re-injected after compaction)"
  echo "- Code Reuse MANDATORY: Grep before new code, reuse shared types"
  echo "- When in doubt: ASK, don't guess"
  echo "- Quality workflow: Plan -> Validate -> Implement -> Check"
  echo "- CLAUDE.md and .claude/ files NEVER modify independently"
  echo ""

  # Current plan reminder
  PLAN="$PWD/.claude/current-plan.md"
  if [ -f "$PLAN" ]; then
    echo "## ACTIVE PLAN (current-plan.md exists — update after EVERY phase!)"
    cat "$PLAN"
    echo ""
    echo "IMPORTANT: Update current-plan.md after every phase. When all phases done -> delete file."
    echo ""
  fi

  # Session state from PreCompact
  if [ -f "$STATE" ]; then
    echo "## Session State (saved before compaction)"
    cat "$STATE"
    echo ""
  fi

  # Inject deploy commands from project CLAUDE.md if available
  if [ -f "$PWD/CLAUDE.md" ]; then
    deploy_section=$(sed -n '/^### Deploy/,/^#/p' "$PWD/CLAUDE.md" 2>/dev/null | head -20)
    if [ -n "$deploy_section" ]; then
      echo "## Deploy Commands (from project CLAUDE.md)"
      echo "$deploy_section"
    else
      echo "## Deploy: See project CLAUDE.md for deploy commands"
    fi
  fi
}

exit 0

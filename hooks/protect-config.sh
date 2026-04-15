#!/bin/bash
# PreToolUse Hook — ask before editing protected config files
# Protected: CLAUDE.md (any dir), .claude/rules/*, .claude/settings*, .claude/plan.md
# Exception: .claude/current-plan.md is always allowed
input=$(cat /dev/stdin)
file=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[ -z "$file" ] && exit 0

# Exception: current-plan.md
if [[ "$file" == *"/.claude/current-plan.md" ]]; then
  exit 0
fi

# Protected patterns
if [[ "$(basename "$file")" == "CLAUDE.md" ]] || \
   [[ "$file" == *"/.claude/rules/"* ]] || \
   [[ "$file" == *"/.claude/settings"* ]] || \
   [[ "$file" == *"/.claude/plan.md" ]]; then
  echo '{"decision":"ask","reason":"Protected config file: '"$(basename "$file")"'"}'
  exit 0
fi

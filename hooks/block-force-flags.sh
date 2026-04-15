#!/bin/bash
# PreToolUse Hook — blocks git force/bypass flags
cmd=$(cat /dev/stdin | jq -r '.tool_input.command // empty')

if echo "$cmd" | grep -qE 'git (add|push|commit|rebase|checkout|reset).*(--force|-f |--no-verify|--hard)'; then
  echo "BLOCKED: Force/bypass flag detected. Fix the root cause instead of bypassing safety checks. Ask the user if unclear." >&2
  exit 2
fi

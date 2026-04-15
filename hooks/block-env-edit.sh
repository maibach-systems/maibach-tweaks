#!/bin/bash
# PreToolUse Hook — blocks edits to .env files
file=$(cat /dev/stdin | jq -r '.tool_input.file_path // empty')
if [[ "$(basename "$file")" == .env* ]]; then
  echo "BLOCKED: Do not edit .env files." >&2
  exit 2
fi

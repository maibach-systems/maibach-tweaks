#!/bin/bash
# PostToolUse Hook on Edit|Write — warns when a file exceeds 300 LOC
input=$(cat /dev/stdin)
file=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[ -z "$file" ] && exit 0
[ ! -f "$file" ] && exit 0

# Only check source files
if [[ "$file" =~ \.(ts|tsx|js|jsx|astro|vue|svelte|py)$ ]]; then
  lines=$(wc -l < "$file" | tr -d ' ')
  if [ "$lines" -gt 300 ]; then
    echo "WARNING: $(basename "$file") = ${lines} LOC (>300 limit). Consider splitting."
  fi
fi

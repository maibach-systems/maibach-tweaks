#!/bin/bash
# PostToolUse Hook on Edit|Write — triggers mandatory plan validation via plan-griller
input=$(cat /dev/stdin)
file=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Only trigger on current-plan.md
[[ "$file" != *"current-plan.md" ]] && exit 0

# Read the full plan file
[ ! -f "$file" ] && exit 0
plan=$(cat "$file" 2>/dev/null || exit 0)

# New plan = has unchecked phases and NO completed phases
has_open=$(echo "$plan" | grep -c '◻' || true)
has_done=$(echo "$plan" | grep -c '✔' || true)

if [ "$has_open" -gt 0 ] && [ "$has_done" -eq 0 ]; then
  echo "NEW PLAN DETECTED — VALIDATION REQUIRED.
Start a plan-griller subagent NOW (subagent_type: plan-griller, model: opus).
Present the plan to the user ONLY AFTER validation has run.
Show validation results together with the plan.
Fix problems found BEFORE presenting to the user."
fi

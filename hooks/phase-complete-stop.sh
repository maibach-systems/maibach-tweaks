#!/bin/bash
# PostToolUse Hook on Edit — grep-verify reminder + check-changes + deploy-group enforcement
input=$(cat /dev/stdin)
file=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Only trigger on current-plan.md
[[ "$file" != *"current-plan.md" ]] && exit 0

new_string=$(echo "$input" | jq -r '.tool_input.new_string // .tool_input.content // empty')

# Was a phase just marked complete?
if echo "$new_string" | grep -q '✔'; then
  [ ! -f "$file" ] && exit 0
  plan=$(cat "$file" 2>/dev/null || exit 0)

  # ALWAYS remind about grep-verify when a phase is marked done
  echo "GREP-VERIFY REQUIRED: Grep for old pattern/function names/imports. SHOW the result, don't just say 'I'm sure'."

  # All phases complete? (no remaining = plan done)
  remaining=$(echo "$plan" | grep -c '◻' || true)

  if [ "$remaining" -eq 0 ]; then
    echo "ALL PHASES COMPLETE — FINAL QUALITY CHECK.
BEFORE deleting current-plan.md:
1. Start subagent: use /check-changes skill as prompt (model: opus).
   NOT code-quality, NOT ops-reviewer — /check-changes checks Build + Regressions + Reuse + Plan deviations.
   git diff over ALL changes since plan start. Thorough.
2. Fix problems found and commit.
3. Final deploy.
4. THEN delete current-plan.md.
Do NOT delete before the final check has run."
  elif echo "$plan" | grep -q 'DEPLOY + STOP'; then
    echo "Check if deploy group is complete.
If ALL phases of the current group are done:
1. Start subagent: use /check-changes skill as prompt (model: sonnet).
   NOT code-quality — /check-changes is more comprehensive (Build, Regressions, Reuse, Plan-Check).
2. Fix problems found.
3. Run deploy sequence.
4. STOP. Wait for user to continue.
If phases still open: keep working."
  fi
fi

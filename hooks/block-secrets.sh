#!/bin/bash
# PreToolUse Hook — blocks writes containing secrets/credentials
input=$(cat /dev/stdin)
content=$(echo "$input" | jq -r '.tool_input.new_string // .tool_input.content // empty')

# Skip empty content
[ -z "$content" ] && exit 0

# Match common secret patterns
if echo "$content" | grep -qE '(API_KEY|SECRET|TOKEN|PRIVATE_KEY|PASSWORD|CREDENTIALS|AUTH_KEY)[=: ]+['\''"][^'\''"]{8,}'; then
  echo "BLOCKED: Suspected secret/credential in content." >&2
  exit 2
fi

# Match common key formats (AWS, GitHub, Stripe, etc.)
if echo "$content" | grep -qE '(AKIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{36}|sk_live_[a-zA-Z0-9]{24,}|sk-[a-zA-Z0-9]{48,})'; then
  echo "BLOCKED: API key pattern detected." >&2
  exit 2
fi

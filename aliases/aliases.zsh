# Claude Code aliases — model selection + system prompt injection
#
# Usage: Source this file in your .zshrc or .bashrc:
#   source ~/.claude/aliases.zsh
#
# Adjust paths if you installed maibach-tweaks to a different location.

# System prompt (appended to every session)
_csp="--append-system-prompt \"$(cat ~/.claude/system-prompt.txt)\""

# Aliases — adjust model IDs when new models release
alias claudem="claude --dangerously-skip-permissions --effort max --model claude-opus-4-7[1m] $_csp"      # Max effort, Opus 1M
alias claudex="claude --dangerously-skip-permissions --effort xhigh --model claude-opus-4-7[1m] $_csp"    # Extra-high effort, Opus 1M
alias claudems="claude --dangerously-skip-permissions --effort high --model claude-sonnet-4-6 $_csp"       # High effort, Sonnet
alias claudeh="claude --dangerously-skip-permissions --effort high --model claude-opus-4-7[1m] $_csp"      # High effort, Opus 1M
alias claudeo="claude --dangerously-skip-permissions --model claude-opus-4-7[1m] $_csp"                    # Default effort, Opus 1M
alias claudes="claude --dangerously-skip-permissions --model claude-sonnet-4-6 $_csp"                      # Default effort, Sonnet

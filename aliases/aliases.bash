# Claude Code aliases — model selection + system prompt injection
#
# Usage: Source this file in your .bashrc:
#   source ~/.claude/aliases.bash
#
# Same as aliases.zsh but compatible with bash.
# Uses --system-prompt-file (replaces Anthropic's default prompt, CC 2.1.112+).

_csp="--system-prompt-file $HOME/.claude/my-system-prompt.txt"

alias claudem="claude --dangerously-skip-permissions --effort max --model claude-opus-4-7[1m] $_csp"
alias claudex="claude --dangerously-skip-permissions --effort xhigh --model claude-opus-4-7[1m] $_csp"
alias claudems="claude --dangerously-skip-permissions --effort high --model claude-sonnet-4-6 $_csp"
alias claudeh="claude --dangerously-skip-permissions --effort high --model claude-opus-4-7[1m] $_csp"
alias claudeo="claude --dangerously-skip-permissions --model claude-opus-4-7[1m] $_csp"
alias claudes="claude --dangerously-skip-permissions --model claude-sonnet-4-6 $_csp"

#!/bin/sh
# Claude Code statusline — compact, informative, no fluff
input=$(cat)

# Colors
dim='\033[0;90m'
blue='\033[0;34m'
green='\033[0;32m'
yellow='\033[0;33m'
red='\033[0;31m'
magenta='\033[0;35m'
reset='\033[0m'

# --- Project name (last segment only, truncate at 20) ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
if [ -n "$cwd" ]; then
  home="$HOME"
  short=$(echo "$cwd" | sed "s|^$home|~|")
  segment=$(basename "$short")
  if [ "$short" = "~" ]; then
    segment="~"
  fi
  if [ ${#segment} -gt 20 ]; then
    segment=$(printf "%.18s.." "$segment")
  fi
  dir_part=$(printf "${blue}%s${reset}" "$segment")
else
  dir_part=""
fi

# --- Git branch + status ---
git_part=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" -c core.hooksPath=/dev/null symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    if [ ${#branch} -gt 16 ]; then
      branch=$(printf "%.14s.." "$branch")
    fi
    if git -C "$cwd" -c core.hooksPath=/dev/null diff --quiet 2>/dev/null && git -C "$cwd" -c core.hooksPath=/dev/null diff --cached --quiet 2>/dev/null; then
      git_part=$(printf " ${green}%s${reset}" "$branch")
    else
      git_part=$(printf " ${yellow}%s${red}*${reset}" "$branch")
    fi
  fi
fi

# --- Agent name (when in subagent) ---
agent_part=""
agent_name=$(echo "$input" | jq -r '.agent.name // empty')
if [ -n "$agent_name" ]; then
  agent_part=$(printf " ${magenta}@%s${reset}" "$agent_name")
fi

# --- Context progress bar ---
ctx_part=""
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used")
  filled=$((used_int * 8 / 100))
  [ "$filled" -gt 8 ] && filled=8
  empty=$((8 - filled))
  if [ "$used_int" -ge 80 ]; then
    bar_color="$red"
  elif [ "$used_int" -ge 50 ]; then
    bar_color="$yellow"
  else
    bar_color="$green"
  fi
  bar_filled=""
  i=0; while [ "$i" -lt "$filled" ]; do bar_filled="${bar_filled}█"; i=$((i+1)); done
  bar_empty=""
  i=0; while [ "$i" -lt "$empty" ]; do bar_empty="${bar_empty}░"; i=$((i+1)); done
  ctx_part=$(printf "${bar_color}%s${dim}%s ${bar_color}%s%%${reset}" "$bar_filled" "$bar_empty" "$used_int")
fi

# --- Session cost ---
cost_part=""
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$cost" ]; then
  cost_fmt=$(printf "%.2f" "$cost")
  cost_int=$(printf "%.0f" "$cost")
  if [ "$cost_int" -ge 5 ]; then
    cost_color="$red"
  elif [ "$cost_int" -ge 1 ]; then
    cost_color="$yellow"
  else
    cost_color="$dim"
  fi
  cost_part=$(printf "${cost_color}\$%s${reset}" "$cost_fmt")
fi

# --- Lines changed ---
lines_part=""
added=$(echo "$input" | jq -r '.cost.total_lines_added // empty')
removed=$(echo "$input" | jq -r '.cost.total_lines_removed // empty')
if [ -n "$added" ] && [ "$added" != "0" -o "$removed" != "0" ] 2>/dev/null; then
  added_v=${added:-0}
  removed_v=${removed:-0}
  if [ "$added_v" -gt 0 ] 2>/dev/null || [ "$removed_v" -gt 0 ] 2>/dev/null; then
    lines_part=$(printf "${green}+%s ${red}-%s${reset}" "$added_v" "$removed_v")
  fi
fi

# --- Session duration ---
dur_part=""
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
if [ -n "$duration_ms" ]; then
  duration_s=$((duration_ms / 1000))
  if [ "$duration_s" -ge 3600 ]; then
    dur_h=$((duration_s / 3600))
    dur_m=$(((duration_s % 3600) / 60))
    dur_part=$(printf "${dim}%dh%dm${reset}" "$dur_h" "$dur_m")
  elif [ "$duration_s" -ge 60 ]; then
    dur_m=$((duration_s / 60))
    dur_part=$(printf "${dim}%dm${reset}" "$dur_m")
  fi
fi

# --- Model (short) ---
model_part=""
model=$(echo "$input" | jq -r '.model.display_name // ""')
if [ -n "$model" ]; then
  case "$model" in
    *Opus*4.7*1M*|*opus*4.7*1m*) short_model="Opus4.71M" ;;
    *Opus*4.6*1M*|*opus*4.6*1m*) short_model="Opus4.61M" ;;
    *Opus*1M*|*opus*1m*) short_model="Opus1M" ;;
    *Opus*4.7*|*opus*4.7*) short_model="Opus4.7" ;;
    *Opus*4.6*|*opus*4.6*) short_model="Opus4.6" ;;
    *Opus*|*opus*) short_model="Opus" ;;
    *Sonnet*4.6*|*sonnet*4.6*) short_model="Sonnet4.6" ;;
    *Sonnet*|*sonnet*) short_model="Sonnet" ;;
    *Haiku*|*haiku*) short_model="Haiku" ;;
    *) short_model="$model" ;;
  esac
  model_part=$(printf "${dim}%s${reset}" "$short_model")
fi

# --- Assemble ---
sep=$(printf " ${dim}│${reset} ")
sp="  "

left="${dir_part}${git_part}${agent_part}"
right="${ctx_part}${sp}${cost_part}${sp}${lines_part}${sp}${dur_part}${sp}${model_part}"

printf "%b%b%b" "$left" "$sep" "$right"

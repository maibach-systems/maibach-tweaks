#!/usr/bin/env bash
set -euo pipefail

# install.sh — Install or update Maibach Tweaks for Claude Code
#
# Usage:
#   ./install.sh                  # Install everything (with backup)
#   ./install.sh --dry-run        # Show what would be installed without modifying anything
#   ./install.sh --backup-only    # Only create backup, don't install
#   ./install.sh --restore        # Restore from backup
#   ./install.sh --uninstall      # Remove tweaks, restore backup
#   ./install.sh --status         # Show what's installed

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backup-before-tweaks"
TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
DRY_RUN=0

# Colors
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
dim='\033[0;90m'
bold='\033[1m'
reset='\033[0m'

info()  { printf "${blue}[INFO]${reset}  %s\n" "$1"; }
ok()    { printf "${green}[OK]${reset}    %s\n" "$1"; }
warn()  { printf "${yellow}[WARN]${reset}  %s\n" "$1"; }
error() { printf "${red}[ERROR]${reset} %s\n" "$1"; }
dry()   { printf "${dim}[DRY]${reset}   %s\n" "$1"; }

# Dry-run wrapper — prints what would happen instead of doing it
run_cp() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    dry "Would copy: $(basename "$1") -> $2"
  else
    cp "$1" "$2"
  fi
}

run_cp_r() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    dry "Would copy directory: $(basename "$1") -> $2"
  else
    cp -r "$1" "$2"
  fi
}

run_mkdir() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    dry "Would create: $1"
  else
    mkdir -p "$1"
  fi
}

run_chmod() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    return 0
  else
    chmod "$@"
  fi
}

# --------------------------------------------------------------------------- #
# Backup
# --------------------------------------------------------------------------- #

create_backup() {
  if [[ -d "$BACKUP_DIR" ]]; then
    warn "Backup already exists at $BACKUP_DIR"
    warn "To create a fresh backup, remove it first: rm -rf $BACKUP_DIR"
    return 0
  fi

  info "Creating backup at $BACKUP_DIR"
  run_mkdir "$BACKUP_DIR"

  # Back up existing files that we'll overwrite
  local files_to_backup=(
    "CLAUDE.md"
    "settings.json"
    "keybindings.json"
    "system-prompt.txt"
    "statusline-command.sh"
  )

  for f in "${files_to_backup[@]}"; do
    if [[ -f "$CLAUDE_DIR/$f" ]]; then
      run_cp "$CLAUDE_DIR/$f" "$BACKUP_DIR/$f"
      ok "Backed up $f"
    fi
  done

  # Back up directories
  local dirs_to_backup=("hooks" "agents" "commands")
  for d in "${dirs_to_backup[@]}"; do
    if [[ -d "$CLAUDE_DIR/$d" ]]; then
      run_cp_r "$CLAUDE_DIR/$d" "$BACKUP_DIR/$d"
      ok "Backed up $d/"
    fi
  done

  if [[ "$DRY_RUN" -eq 0 ]]; then
    echo "$TIMESTAMP" > "$BACKUP_DIR/.timestamp"
  fi
  ok "Backup complete"
}

# --------------------------------------------------------------------------- #
# Install
# --------------------------------------------------------------------------- #

install_tweaks() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf "${bold}${yellow}DRY RUN — no files will be modified${reset}\n"
  else
    info "Installing Maibach Tweaks..."
  fi
  echo ""

  # Ensure ~/.claude exists
  run_mkdir "$CLAUDE_DIR"
  run_mkdir "$CLAUDE_DIR/hooks"
  run_mkdir "$CLAUDE_DIR/agents"
  run_mkdir "$CLAUDE_DIR/commands"

  # --- Config files ---
  info "Installing config files..."

  # CLAUDE.md — only if not exists (don't overwrite user's customized version)
  if [[ ! -f "$CLAUDE_DIR/CLAUDE.md" ]]; then
    run_cp "$SCRIPT_DIR/config/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    ok "Installed CLAUDE.md"
  else
    warn "CLAUDE.md already exists — skipping (see config/CLAUDE.md for reference)"
  fi

  # settings.json — merge strategy: warn if exists
  if [[ ! -f "$CLAUDE_DIR/settings.json" ]]; then
    run_cp "$SCRIPT_DIR/config/settings.json" "$CLAUDE_DIR/settings.json"
    ok "Installed settings.json"
  else
    warn "settings.json already exists — skipping (see config/settings.json for reference)"
    warn "To merge manually: diff $CLAUDE_DIR/settings.json $SCRIPT_DIR/config/settings.json"
  fi

  # keybindings.json
  if [[ ! -f "$CLAUDE_DIR/keybindings.json" ]]; then
    run_cp "$SCRIPT_DIR/config/keybindings.json" "$CLAUDE_DIR/keybindings.json"
    ok "Installed keybindings.json"
  else
    warn "keybindings.json already exists — skipping"
  fi

  # system-prompt.txt
  run_cp "$SCRIPT_DIR/config/system-prompt.txt" "$CLAUDE_DIR/system-prompt.txt"
  ok "Installed system-prompt.txt"

  # --- Statusline ---
  run_cp "$SCRIPT_DIR/statusline/statusline-command.sh" "$CLAUDE_DIR/statusline-command.sh"
  run_chmod +x "$CLAUDE_DIR/statusline-command.sh"
  ok "Installed statusline"

  # --- Hooks ---
  info "Installing hooks..."
  for hook in "$SCRIPT_DIR"/hooks/*.sh; do
    local name=$(basename "$hook")
    run_cp "$hook" "$CLAUDE_DIR/hooks/$name"
    run_chmod +x "$CLAUDE_DIR/hooks/$name"
  done
  ok "Installed $(ls "$SCRIPT_DIR"/hooks/*.sh | wc -l | tr -d ' ') hooks"

  # --- Agents ---
  info "Installing agents..."
  for agent in "$SCRIPT_DIR"/agents/*.md; do
    local name=$(basename "$agent")
    run_cp "$agent" "$CLAUDE_DIR/agents/$name"
  done
  ok "Installed $(ls "$SCRIPT_DIR"/agents/*.md | wc -l | tr -d ' ') agents"

  # --- Commands ---
  info "Installing commands..."
  for cmd in "$SCRIPT_DIR"/commands/*.md; do
    local name=$(basename "$cmd")
    run_cp "$cmd" "$CLAUDE_DIR/commands/$name"
  done
  ok "Installed $(ls "$SCRIPT_DIR"/commands/*.md | wc -l | tr -d ' ') commands"

  # --- Patches ---
  run_cp "$SCRIPT_DIR/patches/patch-claude-code.sh" "$CLAUDE_DIR/patch-claude-code.sh"
  run_chmod +x "$CLAUDE_DIR/patch-claude-code.sh"
  ok "Installed patch script"

  echo ""
  printf "${bold}${green}Installation complete.${reset}\n"
  echo ""
  echo "Next steps:"
  echo ""
  echo "  1. Apply prompt patches (recommended):"
  echo "     ~/.claude/patch-claude-code.sh"
  echo ""
  echo "  2. Survive auto-updates (optional):"
  echo "     ~/.claude/patch-claude-code.sh --watch"
  echo ""
  echo "  3. Add aliases to your shell (optional):"
  echo "     echo 'source ~/.claude/aliases.zsh' >> ~/.zshrc"
  echo ""
  echo "  4. Review and customize:"
  echo "     - ~/.claude/CLAUDE.md        (global instructions)"
  echo "     - ~/.claude/settings.json    (permissions, hooks, env)"
  echo "     - ~/.claude/agents/*.md      (subagent definitions)"
  echo "     - ~/.claude/commands/*.md    (slash commands)"
  echo ""
}

# --------------------------------------------------------------------------- #
# Restore
# --------------------------------------------------------------------------- #

restore_backup() {
  if [[ ! -d "$BACKUP_DIR" ]]; then
    error "No backup found at $BACKUP_DIR"
    exit 1
  fi

  info "Restoring from backup..."

  # Restore files
  for f in "$BACKUP_DIR"/*; do
    local name=$(basename "$f")
    [[ "$name" == ".timestamp" ]] && continue
    if [[ -d "$f" ]]; then
      rm -rf "$CLAUDE_DIR/$name"
      cp -r "$f" "$CLAUDE_DIR/$name"
      ok "Restored $name/"
    else
      cp "$f" "$CLAUDE_DIR/$name"
      ok "Restored $name"
    fi
  done

  ok "Restore complete"
}

# --------------------------------------------------------------------------- #
# Uninstall
# --------------------------------------------------------------------------- #

uninstall_tweaks() {
  warn "This will remove all Maibach Tweaks and restore your backup."
  echo ""

  # Restore patches
  if [[ -f "$CLAUDE_DIR/patch-claude-code.sh" ]]; then
    info "Restoring original Claude Code binary..."
    bash "$CLAUDE_DIR/patch-claude-code.sh" --restore 2>/dev/null || true
  fi

  # Restore backup
  if [[ -d "$BACKUP_DIR" ]]; then
    restore_backup
  else
    warn "No backup found — can't restore previous config"
  fi

  # Clean up
  rm -f "$CLAUDE_DIR/patch-claude-code.sh"
  rm -f "$CLAUDE_DIR/patch.log"

  ok "Uninstall complete"
}

# --------------------------------------------------------------------------- #
# Status
# --------------------------------------------------------------------------- #

show_status() {
  printf "${bold}Maibach Tweaks Status${reset}\n"
  echo ""

  # Check backup
  if [[ -d "$BACKUP_DIR" ]]; then
    local ts=$(cat "$BACKUP_DIR/.timestamp" 2>/dev/null || echo "unknown")
    ok "Backup exists (created: $ts)"
  else
    warn "No backup found"
  fi

  # Check config files
  local configs=("CLAUDE.md" "settings.json" "keybindings.json" "system-prompt.txt" "statusline-command.sh")
  for f in "${configs[@]}"; do
    if [[ -f "$CLAUDE_DIR/$f" ]]; then
      ok "$f installed"
    else
      warn "$f not found"
    fi
  done

  # Check hooks
  local hook_count=$(ls "$CLAUDE_DIR/hooks/"*.sh 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$hook_count" -gt 0 ]]; then
    ok "$hook_count hooks installed"
  else
    warn "No hooks found"
  fi

  # Check agents
  local agent_count=$(ls "$CLAUDE_DIR/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$agent_count" -gt 0 ]]; then
    ok "$agent_count agents installed"
  else
    warn "No agents found"
  fi

  # Check commands
  local cmd_count=$(ls "$CLAUDE_DIR/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$cmd_count" -gt 0 ]]; then
    ok "$cmd_count commands installed"
  else
    warn "No commands found"
  fi

  # Check patches
  if [[ -f "$CLAUDE_DIR/patch-claude-code.sh" ]]; then
    info "Checking patch status..."
    bash "$CLAUDE_DIR/patch-claude-code.sh" --check 2>/dev/null || true
  else
    warn "Patch script not installed"
  fi

  echo ""
}

# --------------------------------------------------------------------------- #
# Main
# --------------------------------------------------------------------------- #

MODE="${1:-install}"

case "$MODE" in
  install|"")
    echo ""
    printf "${bold}Maibach Tweaks Installer${reset}\n"
    echo ""
    create_backup
    echo ""
    install_tweaks
    ;;

  --dry-run)
    DRY_RUN=1
    echo ""
    printf "${bold}Maibach Tweaks Installer${reset}\n"
    echo ""
    create_backup
    echo ""
    install_tweaks
    ;;

  --backup-only)
    create_backup
    ;;

  --restore)
    restore_backup
    ;;

  --uninstall)
    uninstall_tweaks
    ;;

  --status)
    show_status
    ;;

  --help|-h)
    echo "Usage: $0 [install | --dry-run | --backup-only | --restore | --uninstall | --status | --help]"
    echo ""
    echo "  install         Install everything with backup (default)"
    echo "  --dry-run       Show what would be installed without modifying anything"
    echo "  --backup-only   Only create backup of existing config"
    echo "  --restore       Restore from backup"
    echo "  --uninstall     Remove tweaks and restore backup"
    echo "  --status        Show what's installed"
    echo "  --help          Show this help"
    ;;

  *)
    error "Unknown option: $MODE"
    echo "Run $0 --help for usage"
    exit 1
    ;;
esac

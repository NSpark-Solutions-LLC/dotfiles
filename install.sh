#!/bin/bash
# install.sh — symlink Claude Code global dotfiles into ~/.claude/
# Run once from the dotfiles repo root on any local machine.
# After install, git pull updates everything immediately (symlinks, no re-install).

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_CLAUDE="$SCRIPT_DIR/.claude"
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"

echo "Claude Code global dotfiles installer"
echo "Source: $SCRIPT_DIR"
echo ""

mkdir -p "$COMMANDS_DIR"

# Symlink generic slash-command skills into ~/.claude/commands/
for f in "$DOTFILES_CLAUDE/commands/"*.md; do
  [[ -f "$f" ]] || continue
  name=$(basename "$f")
  ln -sf "$f" "$COMMANDS_DIR/$name"
  echo "  Linked  commands/$name"
done

# Symlink Stop hook scripts into ~/.claude/
for f in "$DOTFILES_CLAUDE/stop-hook-"*.sh; do
  [[ -f "$f" ]] || continue
  name=$(basename "$f")
  ln -sf "$f" "$CLAUDE_DIR/$name"
  chmod +x "$f"
  echo "  Linked  $name"
done

# Merge Stop hooks and permissions into ~/.claude/settings.json
python3 "$DOTFILES_CLAUDE/merge-settings.py" \
  "$DOTFILES_CLAUDE/settings-fragment.json" \
  "$CLAUDE_DIR/settings.json"

echo ""
echo "Done. Global skills and hooks are active in every Claude Code session."
echo "To update: cd $(dirname "$SCRIPT_DIR") && git pull  (symlinks update automatically)"

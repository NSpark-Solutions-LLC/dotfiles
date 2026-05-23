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

# Symlink global CLAUDE.md into ~/.claude/
if [[ -f "$DOTFILES_CLAUDE/CLAUDE.md" ]]; then
  ln -sf "$DOTFILES_CLAUDE/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
  echo "  Linked  CLAUDE.md"
fi

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
# Try python3 → python → node (covers Linux/Mac/Windows without Python)
if command -v python3 >/dev/null 2>&1; then
  python3 "$DOTFILES_CLAUDE/merge-settings.py" \
    "$DOTFILES_CLAUDE/settings-fragment.json" \
    "$CLAUDE_DIR/settings.json"
elif command -v python >/dev/null 2>&1; then
  python "$DOTFILES_CLAUDE/merge-settings.py" \
    "$DOTFILES_CLAUDE/settings-fragment.json" \
    "$CLAUDE_DIR/settings.json"
elif command -v node >/dev/null 2>&1; then
  node "$DOTFILES_CLAUDE/merge-settings.js" \
    "$DOTFILES_CLAUDE/settings-fragment.json" \
    "$CLAUDE_DIR/settings.json"
else
  echo "  WARNING: No Python or Node found — skipping settings merge."
  echo "  Install either and re-run: bash install.sh"
fi

echo ""
echo "Done. Global skills and hooks are active in every Claude Code session."
echo "To update: cd $(dirname "$SCRIPT_DIR") && git pull  (symlinks update automatically)"

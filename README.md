# Claude Code Global Dotfiles

Generic slash-command skills and Stop hooks for Claude Code, available in **every project** — not just GeoHavenOS.

This directory (`GeoHavenOS/dotfiles/`) is the **single source of truth**. The standalone `NSpark-Solutions-LLC/dotfiles` repo is a mirror, bootstrapped from here. Edit files here; the standalone repo syncs via the bootstrap process below.

---

## What's included

### Skills (slash commands)

| Command | What it does |
|---------|-------------|
| `/architect-review` | Tier A/B classification → risk register → per-file regression analysis → branch parity check. Presents all output before writing any code. |
| `/new-migration` | Auto-detects migration framework (Drizzle, Prisma, Alembic, Flyway, Knex, raw SQL). Enforces `IF NOT EXISTS` on all DDL. Runs the migration. |

> **GeoHavenOS note:** This repo also has project-specific versions of these skills in `.claude/commands/` (more detailed, GeoHavenOS-specific). Project-level skills always take precedence over global ones for same-name commands — no conflict.

### Global behavioral defaults

| File | What it does |
|------|-------------|
| `CLAUDE.md` | Four universal principles — Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution — loaded at the start of every Claude Code session in every project. Project-level CLAUDE.md rules override where they overlap. |

### Stop hooks (automatic, every session)

| Script | What it does |
|--------|-------------|
| `stop-hook-git-check.sh` | Blocks if there are uncommitted changes or unpushed commits |
| `stop-hook-ts-check.sh` | Runs TypeScript type check when `.ts`/`.tsx` files changed. Auto-detects `check`/`typecheck`/`type-check` from `package.json`. Skips silently for non-TypeScript projects. |

---

## Install — local machine (one time)

```bash
git clone https://github.com/NSpark-Solutions-LLC/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
```

Uses **symlinks** — `git pull` in `~/dotfiles` updates all skills and hooks immediately, no re-install needed.

---

## Cloud sessions — automatic (GeoHavenOS only)

The `SessionStart` hook in `.claude/settings.json` runs `.claude/hooks/install-global-dotfiles.sh` at the start of every GeoHavenOS cloud session. It copies these files to `~/.claude/` automatically — nothing to do manually.

---

## Bootstrap the standalone dotfiles repo

The standalone repo (`NSpark-Solutions-LLC/dotfiles`) is seeded from this directory. To create or re-sync it:

```bash
# 1. Create NSpark-Solutions-LLC/dotfiles on github.com (Settings → New repository)

# 2. From the GeoHavenOS repo root:
DOTFILES_REPO="https://github.com/NSpark-Solutions-LLC/dotfiles.git"
TMP=$(mktemp -d)
git clone "$DOTFILES_REPO" "$TMP"
cp -r dotfiles/. "$TMP/"
cd "$TMP"
git add .
git commit -m "sync: update from GeoHavenOS/dotfiles"
git push origin main
cd - && rm -rf "$TMP"
```

Run the same sync command whenever this directory changes and you want the standalone repo updated.

---

## Adding a new global skill

1. Add the `.md` file to `dotfiles/.claude/commands/` in **this repo** (GeoHavenOS)
2. Commit and push to GeoHavenOS — cloud sessions pick it up on next session start
3. Re-run the bootstrap sync above to update the standalone dotfiles repo
4. Local machines: `git pull` in `~/dotfiles` (symlinks update automatically)

## Updating the global behavioral defaults

Edit `dotfiles/.claude/CLAUDE.md` in **this repo** (GeoHavenOS) and follow the same four steps above. The install hook copies it to `~/.claude/CLAUDE.md` on every cloud session start; local machines get it via symlink on `git pull`.

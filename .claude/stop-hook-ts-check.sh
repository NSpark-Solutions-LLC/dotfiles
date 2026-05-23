#!/bin/bash
# Global Stop hook: run TypeScript type-check if this is a TypeScript project
# and any .ts/.tsx files were changed in the current branch.
#
# Reads hook JSON from stdin (Claude Code hook protocol).
# Exits 0  → silent pass (no message shown to user)
# Exits 2  → block with error message on stderr

input=$(cat)

# Recursion guard
stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active // empty')
if [[ "$stop_hook_active" == "true" ]]; then
  exit 0
fi

# Only run in a git repo
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  exit 0
fi

# Only run if a tsconfig.json exists anywhere in the project
project_root=$(git rev-parse --show-toplevel 2>/dev/null)
if ! find "$project_root" -maxdepth 3 -name "tsconfig.json" -not -path "*/node_modules/*" | grep -q .; then
  exit 0
fi

# Only run if any .ts/.tsx files changed since the last commit
changed_ts=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(ts|tsx)$')
staged_ts=$(git diff --cached --name-only 2>/dev/null | grep -E '\.(ts|tsx)$')
untracked_ts=$(git ls-files --others --exclude-standard 2>/dev/null | grep -E '\.(ts|tsx)$')

if [[ -z "$changed_ts" && -z "$staged_ts" && -z "$untracked_ts" ]]; then
  exit 0
fi

# Detect the right type-check command from package.json (if present)
pkg="$project_root/package.json"
check_cmd=""

if [[ -f "$pkg" ]]; then
  # Prefer scripts named: check, typecheck, type-check, tsc
  for script_name in check typecheck type-check tsc; do
    if jq -e --arg s "$script_name" '.scripts[$s]' "$pkg" >/dev/null 2>&1; then
      check_cmd="npm run $script_name"
      break
    fi
  done
fi

# Fall back to bare tsc if no npm script found
if [[ -z "$check_cmd" ]]; then
  if command -v tsc >/dev/null 2>&1; then
    check_cmd="tsc --noEmit"
  elif [[ -f "$project_root/node_modules/.bin/tsc" ]]; then
    check_cmd="$project_root/node_modules/.bin/tsc --noEmit"
  else
    # No TypeScript compiler found — skip silently
    exit 0
  fi
fi

# Run the check
cd "$project_root" || exit 0
output=$($check_cmd 2>&1)
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
  echo "TypeScript type check failed ($check_cmd):" >&2
  echo "$output" >&2
  exit 2
fi

exit 0

#!/usr/bin/env bash
# UserPromptSubmit hook: while learn mode is on for this project, re-inject its reminder
# so the mode survives context compaction. Silent everywhere else.
set -uo pipefail

input=$(cat || true)
cwd=$(sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' <<<"$input" | head -1)
[ -n "$cwd" ] && [ -d "$cwd" ] || cwd=$PWD

top=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || printf '%s' "$cwd")
state_dir=${LEARNING_WORKFLOW_HOME:-$HOME/.config/learning-workflow}/active
file="$state_dir/${top//\//_}.md"

[ -f "$file" ] || exit 0
if [ -n "$(find "$file" -mmin +720 2>/dev/null)" ]; then
  exit 0
fi
cat "$file"
exit 0

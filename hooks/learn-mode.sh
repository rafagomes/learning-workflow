#!/usr/bin/env bash
# UserPromptSubmit hook: while learn mode is on for this project, re-inject its reminder
# so the mode survives context compaction. Silent everywhere else; never fails a prompt.
set -uo pipefail
trap 'exit 0' ERR

input=$(cat 2>/dev/null || true)
cwd=$(sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' <<<"$input" | head -1)
if [ -z "$cwd" ] || [ ! -d "$cwd" ]; then cwd=$PWD; fi
cd "$cwd" 2>/dev/null || exit 0

# state-path (keep identical to skills/build/SKILL.md and skills/off/SKILL.md; tests/hook_test.sh checks it)
top=$(git rev-parse --show-toplevel 2>/dev/null || pwd); state="${LEARNING_WORKFLOW_HOME:-${HOME:-/nonexistent}/.config/learning-workflow}/active/${top//\//_}.md"

[ -f "$state" ] || exit 0
if [ -n "$(find "$state" -mmin +720 2>/dev/null)" ]; then
  exit 0
fi
touch "$state" 2>/dev/null
cat "$state"
exit 0

#!/usr/bin/env bash
# UserPromptSubmit hook: while learn mode is on for this project, re-inject its reminder
# so the mode survives context compaction. Silent everywhere else; never fails a prompt.
set -uo pipefail
trap 'exit 0' ERR

input=$(cat 2>/dev/null || true)
if command -v jq >/dev/null 2>&1; then
  cwd=$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)
elif command -v python3 >/dev/null 2>&1; then
  cwd=$(python3 -c 'import json,sys; print(json.loads(sys.stdin.read() or "{}").get("cwd") or "")' <<<"$input" 2>/dev/null)
else
  cwd=$(sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' <<<"$input" | head -1)
fi
if [ -z "$cwd" ] || [ ! -d "$cwd" ]; then cwd=$PWD; fi
cd "$cwd" 2>/dev/null || exit 0

# state-path (keep identical to skills/build/SKILL.md and skills/off/SKILL.md; tests/hook_test.sh checks it)
top=$(git rev-parse --show-toplevel 2>/dev/null || pwd); key=${top//[%]/%25}; state="${LEARNING_WORKFLOW_HOME:-${HOME:-/nonexistent}/.config/learning-workflow}/active/${key//\//%2F}.md"

[ -f "$state" ] || exit 0
if [ -n "$(find "$state" -mmin +720 2>/dev/null)" ]; then
  exit 0
fi
touch "$state" 2>/dev/null || true
cat "$state"
exit 0

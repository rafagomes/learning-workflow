#!/usr/bin/env bash
# Exercises the learn-mode UserPromptSubmit hook against temporary projects and state.
set -euo pipefail
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
root=$(cd "$(dirname "$0")/.." && pwd)
hook="$root/hooks/learn-mode.sh"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
export LEARNING_WORKFLOW_HOME="$tmp/config"
mkdir -p "$tmp/proj-a/sub" "$tmp/proj-b" "$LEARNING_WORKFLOW_HOME/active"
git -C "$tmp/proj-a" init -q; git -C "$tmp/proj-b" init -q
top_a=$(git -C "$tmp/proj-a" rev-parse --show-toplevel)
state="$LEARNING_WORKFLOW_HOME/active/${top_a//\//_}.md"

run() { printf '{"session_id":"s","cwd":"%s","prompt":"hi"}' "$1" | "$hook"; }
check() { # check <description> <expected-output> <actual-output>
  if [ "$2" = "$3" ]; then echo "  ok   $1"; else echo "  FAIL $1: expected [$2] got [$3]" >&2; exit 1; fi
}

check "no state: silent" "" "$(run "$tmp/proj-a")"
echo "[learn mode] step P1" > "$state"
check "active project: prints reminder" "[learn mode] step P1" "$(run "$tmp/proj-a")"
check "subdirectory of active project: prints reminder" "[learn mode] step P1" "$(run "$tmp/proj-a/sub")"
check "other project: silent" "" "$(run "$tmp/proj-b")"
check "missing cwd in input: falls back to PWD" "[learn mode] step P1" "$(cd "$tmp/proj-a" && echo '{}' | "$hook")"
touch -t 200001010000 "$state"
check "stale state (>12h): silent" "" "$(run "$tmp/proj-a")"

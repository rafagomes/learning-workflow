#!/usr/bin/env bash
# Exercises the learn-mode UserPromptSubmit hook, and checks that the state-path line in the
# hook and in the build/off skills is identical (the skills write the file the hook reads).
set -euo pipefail
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
root=$(cd "$(dirname "$0")/.." && pwd)
hook="$root/hooks/learn-mode.sh"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
export LEARNING_WORKFLOW_HOME="$tmp/config"

check() { # check <description> <expected> <actual>
  if [ "$2" = "$3" ]; then echo "  ok   $1"; else echo "  FAIL $1: expected [$2] got [$3]" >&2; exit 1; fi
}

snippet_of() { grep -A1 -x '# state-path' "$1" | tail -1 | sed 's/^[[:space:]]*//'; }
hook_line=$(grep -A1 '^# state-path' "$hook" | tail -1)
check "build skill state-path matches hook" "$hook_line" "$(snippet_of "$root/skills/build/SKILL.md")"
check "off skill state-path matches hook" "$hook_line" "$(snippet_of "$root/skills/off/SKILL.md")"

# The eval'd line assigns $state, which shellcheck can't see.
# shellcheck disable=SC2154
state_for() { (cd "$1" && eval "$hook_line" && printf '%s' "$state"); }   # what a skill would write
run() { printf '{"session_id":"s","cwd":"%s","prompt":"hi"}' "$1" | "$hook"; }

mkdir -p "$tmp/proj-a/sub" "$tmp/proj-b" "$tmp/with space/proj" "$tmp/nogit"
git -C "$tmp/proj-a" init -q; git -C "$tmp/proj-b" init -q; git -C "$tmp/with space/proj" init -q

check "no state: silent" "" "$(run "$tmp/proj-a")"
sa=$(state_for "$tmp/proj-a"); mkdir -p "$(dirname "$sa")"; echo "[learn mode] A" > "$sa"
check "active project: prints reminder" "[learn mode] A" "$(run "$tmp/proj-a")"
check "subdirectory of active project" "[learn mode] A" "$(run "$tmp/proj-a/sub")"
check "other project: silent" "" "$(run "$tmp/proj-b")"
check "missing cwd: falls back to PWD" "[learn mode] A" "$(cd "$tmp/proj-a" && echo '{}' | "$hook")"

ss=$(state_for "$tmp/with space/proj"); echo "[learn mode] S" > "$ss"
check "path with spaces" "[learn mode] S" "$(run "$tmp/with space/proj")"

sn=$(state_for "$tmp/nogit"); echo "[learn mode] N" > "$sn"
check "non-git directory" "[learn mode] N" "$(run "$tmp/nogit")"
check "non-git parent directory: silent" "" "$(run "$tmp")"

touch -t 200001010000 "$sa"
check "stale state (>12h): silent" "" "$(run "$tmp/proj-a")"
python3 -c 'import os,sys,time; t=time.time()-3600; os.utime(sys.argv[1],(t,t))' "$sa"
run "$tmp/proj-a" >/dev/null
fresh=$(python3 -c 'import os,sys,time; print(int(time.time()-os.path.getmtime(sys.argv[1]) < 60))' "$sa")
check "prompt refreshes the timestamp" "1" "$fresh"

out=$(cd "$tmp/proj-a" && env -u HOME -u LEARNING_WORKFLOW_HOME "$hook" </dev/null; echo "rc=$?")
check "HOME and LEARNING_WORKFLOW_HOME unset: exit 0" "rc=0" "$out"

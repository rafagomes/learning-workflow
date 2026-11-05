#!/usr/bin/env bash
# Repo checks: manifests, skill frontmatter, guard and hook behaviour, home-path/email scan, diagram drift, banned terms.
set -euo pipefail
cd "$(dirname "$0")/.."

pass=0; fail=0
ok()  { echo "ok   $1"; pass=$((pass+1)); }
bad() { echo "FAIL $1" >&2; fail=$((fail+1)); }

for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  if python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$f" 2>/dev/null; then ok "valid JSON: $f"; else bad "invalid JSON: $f"; fi
done

for skill in skills/*/SKILL.md; do
  name=$(basename "$(dirname "$skill")")
  head -1 "$skill" | grep -qx -- '---' || { bad "$skill: missing frontmatter"; continue; }
  fm=$(awk 'NR==1{next} /^---$/{exit} {print}' "$skill")
  for key in name description argument-hint; do
    grep -q "^$key:" <<<"$fm" || bad "$skill: frontmatter lacks $key"
  done
  if grep -qx "name: $name" <<<"$fm"; then ok "frontmatter: $name"; else bad "$skill: name must be $name"; fi
done

if bash -n skills/init/templates/repo/tools/guard.sh; then ok "guard.sh parses"; else bad "guard.sh syntax"; fi
if bash tests/guard_test.sh; then ok "guard behaviour"; else bad "guard behaviour"; fi
if bash -n hooks/learn-mode.sh && bash tests/hook_test.sh; then ok "learn-mode hook"; else bad "learn-mode hook"; fi
if python3 -c 'import json; json.load(open("hooks/hooks.json"))'; then ok "valid JSON: hooks/hooks.json"; else bad "invalid JSON: hooks/hooks.json"; fi

# Exercises must tell the learner what to do first (spec 009). Patterns are anchored to the headings they belong to.
missing=""
check() { grep -qE -- "$2" "$1" || missing="$missing $1:/$2/"; }
check skills/practice/SKILL.md '^2\. \*\*Start here\*\*'
check skills/practice/SKILL.md '^4\. \*\*Reading a failing test\*\*'
check skills/practice/SKILL.md '^7\. \*\*Stuck\?\*\*'
check skills/practice/SKILL.md '^\| solution stub \|.*TODO: replace with your code'
check skills/practice/SKILL.md '^\*\*In-folder test command\.\*\*'
check skills/practice/SKILL.md '^## Hand over$'
check skills/init/SKILL.md '^Two kinds that sound alike.*\*\*feedback question\*\*.*no verdict'
check skills/init/toolchains.md '^## Exercises$'
check skills/init/templates/subject/LEARNING.md '^\| In-folder test \|'
if [ -z "$missing" ]; then ok "practice Start here contract"; else bad "spec 009 text missing:$missing"; fi

# claude plugin update only pulls a new version, so plugin.json must match the newest released CHANGELOG heading.
pv=$(python3 -c 'import json; print(json.load(open(".claude-plugin/plugin.json"))["version"])')
cv=$(grep -m1 -oE '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' CHANGELOG.md | tr -d '#[] ')
if [ "$pv" = "$cv" ]; then ok "plugin.json version $pv matches CHANGELOG"; else bad "plugin.json version $pv != newest CHANGELOG release $cv"; fi

# Skills and docs must stay project-agnostic: no real home paths or personal email addresses.
if grep -rnE '/(home|Users)/[A-Za-z0-9._-]+/' --exclude-dir=.git --exclude=.git --exclude-dir=tests . | grep -vE '/(home|Users)/me/'; then
  bad "real home path found (use /home/me/...)"
else
  ok "no real home paths"
fi
if grep -rnoE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' --exclude-dir=.git --exclude=.git --exclude-dir=tests . | grep -vE '@(example\.(com|org)|anthropic\.com|github\.com)'; then
  bad "email address found"
else
  ok "no personal email addresses"
fi
gen=$(mktemp -d)
stale=""
if DIAGRAMS_OUT="$gen" python3 docs/diagrams/render.py; then
  for f in "$gen"/*.svg docs/diagrams/*.svg; do
    n=$(basename "$f")
    cmp -s "$gen/$n" "docs/diagrams/$n" || stale="$stale $n"
  done
else
  stale=" (render.py failed)"
fi
if [ -z "$stale" ]; then ok "diagram SVGs match docs/diagrams/render.py"; else bad "diagram SVGs differ from render.py:$stale (run python3 docs/diagrams/render.py)"; fi
rm -rf "$gen"
# Optional private list, e.g. BANNED_TERMS='acme|globex' bash tests/run.sh
if [ -z "${BANNED_TERMS:-}" ]; then
  echo "skip banned terms (set BANNED_TERMS to check)"
elif grep -rniE "$BANNED_TERMS" --exclude-dir=.git --exclude=.git --exclude-dir=tests .; then
  bad "banned term found"
else
  ok "no banned terms"
fi

echo "passed $pass, failed $fail"
[ "$fail" -eq 0 ]

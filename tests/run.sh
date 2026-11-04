#!/usr/bin/env bash
# Repo checks: manifests, skill frontmatter, guard behaviour, banned-term scan.
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

if bash -n skills/init/templates/tools/guard.sh; then ok "guard.sh parses"; else bad "guard.sh syntax"; fi
if bash tests/guard_test.sh; then ok "guard behaviour"; else bad "guard behaviour"; fi

# Skills must stay project-agnostic; extend this list if a real name ever leaks.
if [ -n "${BANNED_TERMS:-}" ] && grep -rniE "$BANNED_TERMS" --exclude-dir=.git --exclude-dir=tests . ; then
  bad "banned term found"
else
  ok "no banned terms"
fi

echo "passed $pass, failed $fail"
[ "$fail" -eq 0 ]

#!/usr/bin/env bash
# Exercises the pre-commit guard in a throwaway repo, isolated from the developer's git config.
set -euo pipefail
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
cd "$tmp"
git init -qb main
git config user.email test@example.com; git config user.name test; git config commit.gpgsign false
cp -R "$root/skills/init/templates/tools" tools
git config core.hooksPath tools/hooks
git add tools && git commit -qm "tools"

expect() { # expect <allow|block> <description> <git args...>
  local want=$1 desc=$2; shift 2
  "$@"
  if git commit -qm "$desc" >/dev/null 2>&1; then got=allow; else got=block; git reset -q --hard HEAD; fi
  if [ "$got" = "$want" ]; then echo "  ok   $want: $desc"; else echo "  FAIL wanted $want, got $got: $desc" >&2; exit 1; fi
}

echo notes > notes.md;                                   expect allow "markdown note" git add notes.md
mkdir -p lessons/001-x/exercises/01-a/data
echo "a,b" > lessons/001-x/exercises/01-a/data/d.csv;    expect allow "exercise data" git add lessons/001-x/exercises/01-a/data/d.csv
echo '{}' > lessons/001-x/exercises/01-a/package.json;   expect allow "package.json in an exercise" git add lessons/001-x/exercises/01-a/package.json
echo "a,b" > leak.csv;                                   expect block "data file at root" git add leak.csv
echo "a,b" > dump.JSON;                                  expect block "uppercase data extension" git add dump.JSON
mkdir -p lessons/001-x && echo '{}' > lessons/001-x/dump.json; expect block "data file in a lesson" git add lessons/001-x/dump.json
expect block "data file renamed out of data/" git mv lessons/001-x/exercises/01-a/data/d.csv moved.csv
head -c 1100000 /dev/zero > big.bin; git add big.bin; : > big.bin
expect block "staged blob over 1 MB, truncated on disk" true
rm -f big.bin
echo ok > after.md;                                      expect allow "clean commit after blocks" git add after.md
echo '{}' > customers.config.json;                       expect block "arbitrary *.config.json at root" git add customers.config.json
mkdir -p .vscode .claude; echo '{}' > .vscode/settings.json; echo '{}' > .claude/settings.json
expect allow "named editor/agent config" git add .vscode/settings.json .claude/settings.json
echo '[{"name":"x"}]' > .vscode/customers.json;          expect block "arbitrary json under .vscode/" git add .vscode/customers.json
echo '{}' > .claude/export.json;                         expect block "arbitrary json under .claude/" git add .claude/export.json
echo 'insert into t values (1);' > dump.sql;             expect block "sql dump at root" git add dump.sql
echo 'select 1;' > lessons/001-x/lab.sql;                expect allow "sql lab in a lesson" git add lessons/001-x/lab.sql
echo x > backup.zip;                                     expect block "archive" git add backup.zip
mkdir -p vendor/lessons/x/exercises/y/data && echo a > vendor/lessons/x/exercises/y/data/d.csv
expect block "nested lessons/ path is not an exercise data dir" git add vendor/lessons/x/exercises/y/data/d.csv

#!/usr/bin/env bash
# Exercises the pre-commit guard in a throwaway repo, isolated from the developer's git config.
set -euo pipefail
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
cd "$tmp"
git init -qb main
git config user.email test@example.com; git config user.name test; git config commit.gpgsign false
cp -R "$root/skills/init/templates/repo/tools" tools
git config core.hooksPath tools/hooks; git config advice.addEmbeddedRepo false
mkdir -p python && echo "# python" > python/LEARNING.md
git add tools python && git commit -qm "tools and a subject"

expect() { # expect <allow|block> <description> <git args...>
  local want=$1 desc=$2; shift 2
  "$@"
  if git commit -qm "$desc" >/dev/null 2>&1; then got=allow; else got=block; git reset -q --hard HEAD; fi
  if [ "$got" = "$want" ]; then echo "  ok   $want: $desc"; else echo "  FAIL wanted $want, got $got: $desc" >&2; exit 1; fi
}

echo notes > notes.md;                                   expect allow "markdown note" git add notes.md
mkdir -p python/lessons/001-x/exercises/01-a/data
echo "a,b" > python/lessons/001-x/exercises/01-a/data/d.csv;    expect allow "exercise data" git add python/lessons/001-x/exercises/01-a/data/d.csv
echo '{}' > python/lessons/001-x/exercises/01-a/package.json;   expect allow "package.json in an exercise" git add python/lessons/001-x/exercises/01-a/package.json
echo "a,b" > leak.csv;                                   expect block "data file at root" git add leak.csv
echo "a,b" > dump.JSON;                                  expect block "uppercase data extension" git add dump.JSON
mkdir -p python/lessons/001-x && echo '{}' > python/lessons/001-x/dump.json; expect block "data file in a lesson" git add python/lessons/001-x/dump.json
expect block "data file renamed out of data/" git mv python/lessons/001-x/exercises/01-a/data/d.csv moved.csv
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
echo 'select 1;' > python/lessons/001-x/lab.sql;                expect allow "sql lab in a lesson" git add python/lessons/001-x/lab.sql
echo x > backup.zip;                                     expect block "archive" git add backup.zip
mkdir -p a/b/lessons/x/exercises/y/data && echo a > a/b/lessons/x/exercises/y/data/d.csv
expect block "lessons/ deeper than a subject folder" git add a/b/lessons/x/exercises/y/data/d.csv
mkdir -p lessons/001-x/exercises/01-a/data && echo a > lessons/001-x/exercises/01-a/data/d.csv
expect block "exercise data outside a subject folder" git add lessons/001-x/exercises/01-a/data/d.csv
mkdir -p lessons/001-x && echo 'select 1;' > lessons/001-x/lab.sql;               expect block "lesson sql outside a subject folder" git add lessons/001-x/lab.sql
mkdir -p tools/lessons/x/exercises/y/data && echo a > tools/lessons/x/exercises/y/data/d.csv
expect block "exercise data under a folder with no LEARNING.md" git add tools/lessons/x/exercises/y/data/d.csv
mkdir -p .vscode/lessons/a && echo 'select 1;' > .vscode/lessons/a/dump.sql
expect block "lesson sql under a folder with no LEARNING.md" git add .vscode/lessons/a/dump.sql
mkdir -p rust/lessons/001-x/exercises/01-a/data && echo "# rust" > rust/LEARNING.md && echo a > rust/lessons/001-x/exercises/01-a/data/d.csv
expect allow "exercise data in a subject added in the same commit" git add rust
mkdir -p old-repo && git -C old-repo init -qb main && git -C old-repo -c user.email=t@example.com -c user.name=t commit -q --allow-empty -m x
expect block "embedded git repo" git add old-repo
rm -rf old-repo
msg=$(echo "a,b" > python/leak.csv && git add python/leak.csv && git commit -qm leak 2>&1 || true); git reset -q --hard HEAD; rm -f python/leak.csv
if [[ "$msg" == *"<subject>/scratch/"* ]]; then echo "  ok   message points to <subject>/scratch/"; else echo "  FAIL message: $msg" >&2; exit 1; fi
# "?sub" read as a glob would match the gitlink "0sub", which sorts first: the gitlink check must read the path literally.
mkdir -p 0sub && git -C 0sub init -qb main && git -C 0sub -c user.email=t@example.com -c user.name=t commit -q --allow-empty -m x
git -c core.hooksPath=/dev/null add 0sub && git -c core.hooksPath=/dev/null commit -qm "gitlink present (bypassing guard)"
echo x > "?sub";                                          expect allow "glob characters in a filename next to a gitlink" git add "?sub"

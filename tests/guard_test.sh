#!/usr/bin/env bash
# Exercises the pre-commit guard in a throwaway repo.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
cd "$tmp"
git init -qb main
git config user.email test@example.com; git config user.name test
mkdir -p tools && cp "$root/skills/init/templates/tools/guard.sh" tools/
ln -s ../../tools/guard.sh .git/hooks/pre-commit

expect() { # expect <allow|block> <description> <files...>
  local want=$1 desc=$2; shift 2
  git add -- "$@"
  if git commit -qm "$desc" >/dev/null 2>&1; then got=allow; else got=block; git reset -q; fi
  if [ "$got" = "$want" ]; then echo "  ok   $want: $desc"; else echo "  FAIL wanted $want, got $got: $desc" >&2; exit 1; fi
}

echo "notes" > notes.md;                         expect allow "markdown note" notes.md
mkdir -p lessons/001-x/exercises/01-a/data
echo "a,b" > lessons/001-x/exercises/01-a/data/d.csv; expect allow "exercise data" lessons/001-x/exercises/01-a/data/d.csv
echo "a,b" > leak.csv;                           expect block "data file at root" leak.csv
mkdir -p lessons/001-x && echo '{}' > lessons/001-x/dump.json; expect block "data file in a lesson" lessons/001-x/dump.json
head -c 1100000 /dev/zero > big.bin;             expect block "file over 1 MB" big.bin

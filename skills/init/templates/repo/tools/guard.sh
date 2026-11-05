#!/usr/bin/env bash
# Pre-commit guard for a learning repo: keeps project data and secrets out of history.
# Checks the staged blobs, not the working tree, so what is checked is what gets committed.
set -euo pipefail
shopt -s nocasematch

fail=0
max_bytes=1048576
data_ext='\.(csv|tsv|parquet|feather|arrow|json|jsonl|ndjson|geojson|xlsx|xls|sqlite|sqlite3|db|duckdb|dump|bak|sql|sql\.gz|zip|gz|tgz|tar|7z|bz2|xz|avro|orc|shp|gpkg|pkl|pickle|pt|joblib|npy|npz|h5|hdf5)$'
allowed_data='^[^/]+/lessons/[^/]+/exercises/[^/]+/data/'
lesson_sql='^[^/]+/lessons/.+\.sql$'
config_json='(^|/)(package\.json|package-lock\.json|tsconfig[^/]*\.json|jsconfig\.json|deno\.json|composer\.json|\.vscode/(settings|extensions|launch|tasks)\.json|\.claude/settings\.json|\.devcontainer/devcontainer\.json)$'

while IFS= read -r -d '' f; do
  # Exercise data and lesson SQL count only inside a subject: a top-level folder with a staged LEARNING.md.
  in_subject=0
  if [[ "$f" == */* ]] && git cat-file -e ":${f%%/*}/LEARNING.md" 2>/dev/null; then in_subject=1; fi
  if [[ "$f" =~ $data_ext ]] && ! { [ "$in_subject" -eq 1 ] && { [[ "$f" =~ $allowed_data ]] || [[ "$f" =~ $lesson_sql ]]; }; } && ! [[ "$f" =~ $config_json ]]; then
    echo "guard: data file outside an exercise data/ dir: $f" >&2; fail=1
  fi
  # An embedded git repo (gitlink) means a folder with its own .git was added, e.g. a standalone learning repo.
  if [[ "$(git ls-files -s -- ":(literal)$f")" == 160000* ]]; then
    echo "guard: embedded git repo: $f (move it out, or migrate it with /learn:init migrate)" >&2; fail=1; continue
  fi
  size=$(git cat-file -s ":$f" 2>/dev/null) || continue
  if [ "$size" -gt "$max_bytes" ]; then
    echo "guard: file over 1 MB: $f ($size bytes)" >&2; fail=1
  fi
done < <(git diff --cached --name-only --no-renames --diff-filter=ACMT -z)

if command -v gitleaks >/dev/null 2>&1; then
  if gitleaks git --help >/dev/null 2>&1; then
    gitleaks git --staged --no-banner --redact || fail=1
  else
    gitleaks protect --staged --no-banner --redact || fail=1
  fi
fi

if [ "$fail" -ne 0 ]; then
  echo "guard: commit blocked. Move real data to <subject>/scratch/ (gitignored) or generate synthetic data." >&2
  exit 1
fi

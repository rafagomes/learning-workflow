#!/usr/bin/env bash
# Pre-commit guard for a learning repo: keeps project data and secrets out of history.
set -euo pipefail

fail=0
data_ext='\.(csv|tsv|parquet|feather|arrow|json|jsonl|ndjson|xlsx|xls|sqlite|db|duckdb|dump|sql\.gz|geojson|shp|gpkg|pkl|pt|joblib)$'
allowed_data='^lessons/[^/]+/exercises/[^/]+/data/'

while IFS= read -r -d '' f; do
  [ -f "$f" ] || continue
  if [[ "$f" =~ $data_ext ]] && ! [[ "$f" =~ $allowed_data ]]; then
    echo "guard: data file outside an exercise data/ dir: $f" >&2; fail=1
  fi
  size=$(wc -c <"$f")
  if [ "$size" -gt 1048576 ]; then
    echo "guard: file over 1 MB: $f ($size bytes)" >&2; fail=1
  fi
done < <(git diff --cached --name-only --diff-filter=ACM -z)

if command -v gitleaks >/dev/null 2>&1; then
  gitleaks protect --staged --no-banner --redact || fail=1
fi

if [ "$fail" -ne 0 ]; then
  echo "guard: commit blocked. Move real data to scratch/ (gitignored) or generate synthetic data." >&2
  exit 1
fi

#!/usr/bin/env bash
# Pre-commit guard for a learning repo: keeps project data and secrets out of history.
# Checks the staged blobs, not the working tree, so what is checked is what gets committed.
set -euo pipefail
shopt -s nocasematch

fail=0
max_bytes=1048576
data_ext='\.(csv|tsv|parquet|feather|arrow|json|jsonl|ndjson|geojson|xlsx|xls|sqlite|sqlite3|db|duckdb|dump|sql\.gz|shp|gpkg|pkl|pickle|pt|joblib|npy|npz|h5|hdf5)$'
allowed_data='^lessons/[^/]+/exercises/[^/]+/data/'
config_json='(^|/)(package\.json|package-lock\.json|tsconfig[^/]*\.json|jsconfig\.json|deno\.json|composer\.json|\.vscode/[^/]+\.json|\.claude/[^/]+\.json|\.devcontainer/[^/]+\.json)$'

while IFS= read -r -d '' f; do
  if [[ "$f" =~ $data_ext ]] && ! [[ "$f" =~ $allowed_data ]] && ! [[ "$f" =~ $config_json ]]; then
    echo "guard: data file outside an exercise data/ dir: $f" >&2; fail=1
  fi
  # Submodule entries (gitlinks) have no blob to size.
  size=$(git cat-file -s ":$f" 2>/dev/null) || continue
  if [ "$size" -gt "$max_bytes" ]; then
    echo "guard: file over 1 MB: $f ($size bytes)" >&2; fail=1
  fi
done < <(git diff --cached --name-only --no-renames --diff-filter=ACMT -z)

if command -v gitleaks >/dev/null 2>&1; then
  gitleaks protect --staged --no-banner --redact || fail=1
fi

if [ "$fail" -ne 0 ]; then
  echo "guard: commit blocked. Move real data to scratch/ (gitignored) or generate synthetic data." >&2
  exit 1
fi

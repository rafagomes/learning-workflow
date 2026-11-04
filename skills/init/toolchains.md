# Default toolchains

`/learn:init` proposes one of these and records it in the learning repo's `LEARNING.md`. Labs and exercises use the recorded commands, so any language works; this table only supplies sensible defaults. Prefer the toolchain the linked project already uses.

| Subject | Lab file | Run | Test | Notes |
|---|---|---|---|---|
| Python, data, ML | `lab.py` with an inline [PEP 723](https://peps.python.org/pep-0723/) dependency block | `uv run lab.py` | `uv run --with pytest pytest <dir>` | Pin versions in the script block |
| JavaScript / TypeScript | `lab.ts` | `bun lab.ts` | `bun test <dir>` | `node`/`npx tsx` and `vitest` also fine |
| Rust | `src/bin/lab.rs` in a lesson crate | `cargo run --bin lab` | `cargo test` | One crate per lesson keeps builds small |
| Go | `lab/main.go` | `go run ./lab` | `go test ./...` | |
| Java / Kotlin | `Lab.java` | `java Lab.java` | `gradle test` | Single-file source launch for labs |
| C / C++ | `lab.c` | `cc -O2 lab.c -o /tmp/lab && /tmp/lab` | a tiny assert-based runner | |
| SQL | `lab.sql` | `duckdb < lab.sql` | expected-output diff | DuckDB needs no server |
| Shell | `lab.sh` | `bash lab.sh` | `bats <dir>` | |
| Maths, statistics | `lab.py` (as Python) or a notebook | as Python | as Python | Or `none` for pen-and-paper |
| No code (music theory, history, design, languages) | `none` | — | — | Labs become worked problems; exercises become problem sets checked in conversation |

Rules for any toolchain:

- **Self-contained.** A lab runs from its own folder with one command and no global setup beyond the toolchain itself.
- **Pinned.** Dependency versions are pinned so a lab gives the same output months later.
- **Seeded.** Any randomness or generated data uses a fixed seed.

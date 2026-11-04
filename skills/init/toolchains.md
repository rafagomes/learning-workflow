# Default toolchains

`/learn:init` proposes one of these and records it in the learning repo's `LEARNING.md`. Labs and exercises use the recorded commands, so any language works; this table only supplies sensible defaults. Prefer the toolchain the linked project already uses.

| Subject | Lab file | Run | Test | Notes |
|---|---|---|---|---|
| Python, data, ML | `lab.py` with an inline [PEP 723](https://peps.python.org/pep-0723/) dependency block | `uv run lab.py` | `uv run --with pytest --with-requirements <dir>/requirements.txt pytest <dir>` | Pin lab deps in the script block; each exercise pins its deps in `requirements.txt` (may be empty) |
| JavaScript / TypeScript | `lab.ts` | `bun lab.ts` | `bun test <dir>` | `node`/`npx tsx` and `vitest` also fine |
| Rust | `src/bin/lab.rs` in a lesson crate | `cargo run --bin lab` | `cargo test` | One crate per lesson keeps builds small |
| Go | `lab/main.go` in a lesson module | `go run ./lab` | `go test ./...` | Each lesson folder has its own `go.mod` (`go mod init lesson<NNN>`) |
| Kotlin | `lab.main.kts` | `kotlin lab.main.kts` | `mkdir -p out && kotlinc solution.kt test.kt -include-runtime -d out/test.jar && java -ea -jar out/test.jar` | Script for labs; tests as a `main` with `check(...)` calls; the jar goes to the gitignored `out/` |
| Java | `Lab.java` | `java Lab.java` | `javac -d out *.java && java -ea -cp out TestSolution` | Run from the exercise folder; assert-based tests, no build tool; works on JDK 17+ (`out/` is gitignored) |
| C | `lab.c` | `cc -O2 lab.c -o lab.out && ./lab.out` | `cc test.c solution.c -o test.out && ./test.out` | Binaries land in the lesson folder and are gitignored (`*.out`) |
| C++ | `lab.cpp` | `c++ -std=c++20 -O2 lab.cpp -o lab.out && ./lab.out` | `c++ -std=c++20 test.cpp solution.cpp -o test.out && ./test.out` | Same; assert-based tests |
| SQL | `lab.sql` | `duckdb < lab.sql` | expected-output diff | DuckDB needs no server |
| Shell | `lab.sh` | `bash lab.sh` | `bats <dir>` | |
| Maths, statistics | `lab.py` (as Python) or a notebook | as Python | as Python | Or `none` for pen-and-paper |
| No code (music theory, history, design, languages) | `none` | — | — | Labs become worked problems; exercises become problem sets checked in conversation |

Rules for any toolchain:

- **Self-contained.** A lab runs from its own folder with one command and no global setup beyond the toolchain itself.
- **Pinned.** Dependency versions are pinned so a lab gives the same output months later.
- **Seeded.** Any randomness or generated data uses a fixed seed.

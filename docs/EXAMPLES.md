# Examples

Three walkthroughs, from no project at all to a work project. Output is abbreviated.

## 1. Learning Python from zero, no project

```
/learn:init python
```

Claude asks your level (*new*), depth (*practical first*), lesson language, and proposes the Python toolchain (`uv run lab.py`, `uv run --with pytest pytest`). It creates `~/Learning/python` and commits.

```
/learn:curriculum "automate the reports I build in spreadsheets every week"
```

No plan exists, so it asks which outcomes matter (read and clean CSVs, compute summaries, write an Excel file, run on a schedule), then writes `curriculum/spreadsheet-automation.md`:

| # | Topic | Needs |
|---|---|---|
| 1 | Values, variables and types | — |
| 2 | Lists, dicts and loops | 1 |
| 3 | Functions and modules | 2 |
| 4 | Reading and writing files, CSV | 2, 3 |
| 5 | Errors and exceptions | 3 |
| … | … | … |

```
/learn:teach spreadsheet-automation/1
```

The lesson is a conversation. Before the lab prints `type(0.1 + 0.2)` and `0.1 + 0.2 == 0.3`, you're asked what you expect. The surprise about floats becomes a flashcard.

```
/learn:practice 1        # stubs + failing tests in lessons/001-values-and-types/exercises/
/learn:quiz 1            # 9/10, both critical right → ready
/learn:quiz review       # tomorrow, two minutes
```

## 2. Learning Rust while building a personal project

```
/learn:init rust ~/code/ray-tracer
```

The project's `Cargo.toml` makes Claude propose the Rust toolchain. The project is linked as `personal`.

```
/learn:curriculum ~/code/ray-tracer/PLAN.md
```

The plan's phases (vector math, camera, materials, parallel rendering) become a track. The self-assessment shows you already know structs and traits, so those get quizzes, not lessons. Lessons cite your own code (`ray-tracer:src/vec3.rs@a1b2c3d`), and exercises are small crates under `lessons/`.

When phase 1 is built:

```
/learn:reflect "vector math" 3f2e1d0..HEAD
```

You predicted operator overloading would be the hard part; it was lifetimes in the iterator. That becomes a new topic and two flashcards.

## 3. Learning a technique for work

Your team is moving to the transactional-outbox pattern and you'll build the first slice.

```
/learn:init distributed-systems ~/work/payments
```

The remote belongs to your employer's organisation, so the project is linked as `work`.

```
/learn:curriculum ~/work/payments/docs/design/outbox.md
```

The track covers dual writes and why they fail, idempotency keys, at-least-once delivery, ordering, and change-data-capture vs polling. Lessons explain the pattern with synthetic tables. When they point at your code, they cite `payments:src/orders/repository.ts@9c8b7a6` and paraphrase it rather than pasting. Labs use an in-memory SQLite, never the company database.

When `/learn:quiz` says the phase is ready, you build it in `~/work/payments` through the team's normal process. The learning repo is never mentioned there. After the PR merges:

```
/learn:reflect outbox https://github.com/acme/payments/pull/412
```

The reflection records aggregate results only (for example "duplicate deliveries in staging: 0 over 3 days"), never records.

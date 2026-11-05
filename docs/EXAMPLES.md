# Examples

Four walkthroughs: three for the study loop, from no project at all to a work project, and one for build mode. Output is abbreviated.

## 1. Learning Python from zero, no project

```
/learn:init python
```

Claude asks your level (*new*), depth (*practical first*), lesson language, and proposes the Python toolchain (`uv run lab.py` for labs, `uv run --with pytest --with-requirements <dir>/requirements.txt pytest <dir>` for tests, and `uv run --with pytest --with-requirements requirements.txt pytest -q` run from inside an exercise folder). It creates the learning repo at `~/Learning` (only the first time), adds `~/Learning/python/`, lists it in the root `README.md`, and commits.

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
/learn:practice 1                      # stubs + failing tests in lessons/001-values-and-types/exercises/
```

Each exercise README starts with what to do first (abbreviated):

````markdown
# 01 · Close enough

Trains: comparing floats with a tolerance.

## Start here

1. Open a terminal in this exercise's folder. From the learning repo root:
   `cd python/lessons/001-values-and-types/exercises/01-close-enough`
2. Run the tests once, before writing anything: `uv run --with pytest pytest -q`.
   Expect `4 failed`, each with `NotImplementedError` — expected, the functions are empty.
   Wrong folder? If uv can't find `requirements.txt` or pytest stops with collection errors naming other exercises' files, check that your prompt (or `pwd`) ends in `01-close-enough`, then `cd` there.
3. Open `solution.py`. In each function, replace the line marked `# TODO: replace with your code`.
   Keep the names and signatures. Don't edit `test_solution.py`: it's the answer checker.
4. Start with `is_close`, then `average`. Re-run the tests after each.
5. You're done when the run ends with `4 passed`.

## Reading a failing test

```
>       assert is_close(0.1 + 0.2, 0.3)
E       assert False
E        +  where False = is_close((0.1 + 0.2), 0.3)
FAILED test_solution.py::test_float_sum_is_close_not_equal - assert False
1 failed, 3 passed in 0.01s
```

Your `is_close(0.1 + 0.2, 0.3)` returned `False` but should be `True`; the test name says which idea is checked.

## Task · Examples · Stuck?
…
````

In chat, Claude walks you through steps 1 and 2, says to start with `is_close`, then asks whether the instructions are clear.

```
/learn:quiz spreadsheet-automation/1   # 9/10, both critical right → ready
/learn:quiz review                     # tomorrow, two minutes
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

## 4. Build mode: learn while building a feature

You need to add search to a personal notes app, and you've never built full-text search.

```
/learn:init search ~/code/notes-app      # level default: adaptive
/learn:plan "add full-text search to the notes app"
```

There's no written plan, so Claude asks two questions (what to search, how many notes) and proposes steps. It reads the code they'll touch and writes `plans/notes-search.md`:

| Step | What gets built | Level | New concepts |
|---|---|---|---|
| S1 | Tokenizer and inverted index | adaptive | tokenization, inverted index |
| S2 | Ranking | you | TF-IDF, BM25 (`deep`: worth a `/learn:teach` first) |
| S3 | Wiring the search box | claude | debouncing |

```
/learn:build S1
```

Learn mode turns on for the project, and from here you just prompt:

> **You:** let's add the index module
> **Claude:** writes the module skeleton and storage plumbing, and leaves `build_index()` with a `TODO(learner)` body for you.
> ▸ concept: **inverted index**: a map from each term to the notes that contain it, so a query reads a few short lists instead of scanning every note. That's why `build_index()` returns `dict[str, set[int]]`. Want a deeper dive?

You write the function and Claude reviews it. Before running the tests:

> **Claude:** What do you expect `search("Running")` to return for a note containing "run"?
> **You:** nothing, we don't stem
> **Claude:** runs the tests: right, no match. A stemming note goes to the step's follow-ups.

While a slow indexing benchmark runs in the background, Claude offers a 3-minute look at why lowercasing happens at both index and query time, then asks one "is this clear?" question.

> **You:** S1 is done

Claude asks four questions about the code you built, one at a time. You answer the tokenization questions but miss one on how the inverted index grows with vocabulary, which becomes a flashcard. Claude checks the project for leftover `TODO(learner)` markers (none), writes `builds/2026-11-06-S1.md`, and in `PROGRESS.md` marks tokenization `built` and the inverted index back to `learning`. It then commits in the learning repo, and turns learn mode off. The notes app now has the index, and nothing in it mentions any of this.

---
name: practice
description: "Give the learner hands-on exercises for a topic, each with failing tests they make pass (in any language), seeded synthetic data, and a graded hint ladder. Use when the user says 'give me exercises', 'let me practise X', 'I want to code this myself', or after a /learn:teach lesson. Writes lessons/<NNN>-<topic>/exercises/ and never reveals a solution unless asked explicitly."
argument-hint: "<topic or lesson number> [easy|medium|hard]"
---
Set exercises for a topic. Argument: $ARGUMENTS

Resolve the subject as `/learn:init` describes and find the topic's lesson folder (create a minimal one, with the next free NNN, if the topic is `claimed` and has none).

## Write the exercises

Create 2–4 exercises, increasing in difficulty, under `lessons/<NNN>-<topic>/exercises/<NN>-<slug>/`:

| File | Contents |
|---|---|
| `README.md` | The exercise's instructions, in the structure below. No solution. |
| solution stub | Signatures and doc comments with a not-implemented body, named the toolchain's way (`solution.py`, `solution.ts`, `src/lib.rs`, …). Each placeholder body carries the comment `TODO: replace with your code` in the toolchain's comment syntax (`raise NotImplementedError  # TODO: replace with your code`, `todo!() // TODO: replace with your code`). The learner edits this file. |
| tests | Tests in the toolchain's test framework that fail on the stub and pass on a correct solution: normal cases, an edge case, and one property or tolerance check where it fits. Test names say which idea each one checks. |
| data generator | Seeded synthetic data generator, only if the exercise needs data; writes to `data/`. |
| dependency file | Whatever the toolchain needs to pin the exercise's dependencies (`requirements.txt`, `package.json`, `Cargo.toml`, `go.mod`, …); may be empty. |

- Exercises mirror the shape of a linked project's problem when there is one, but never use its data.

**In-folder test command.** The learner runs the tests from inside the exercise folder, so derive a short command from the recorded test command: a `<dir>` argument becomes `.` or is dropped, paths become relative. Python: `uv run --with pytest pytest -q`, adding `--with-requirements requirements.txt` only when that file isn't empty; TypeScript `bun test`; Rust `cargo test`; Go `go test ./...`; toolchains that already run from the exercise folder (Java, C, …) as recorded. Never send the learner to the subject root.

**README structure**, in this order:

1. The title and a one-line **Trains:** naming the idea.
2. **Start here**, five numbered steps:
   1. `cd` into the exercise folder, as a full path they can copy.
   2. Run the tests once before writing anything, with the in-folder command, and what that first run shows, as observed on the stub: "`4 failed`, each with `NotImplementedError` — expected, the functions are empty" (for a test program that stops at its first failed check, that first failure).
   3. The file to edit (the stub) and exactly what to replace: the placeholder line marked `TODO: replace with your code`. Keep the names and signatures; don't edit the test file, it's the answer checker.
   4. A suggested order of the functions, easiest first, re-running the tests after each.
   5. The finish line: "done when the run ends with `4 passed`" (the toolchain's own all-pass line).
3. Optional, where it helps: **What a finished function looks like** (a short, fully worked function that isn't part of the exercise and doesn't give its answer away, showing the idioms the exercise needs, such as returning `None` for an undefined result), or **What the input looks like** (how the data arrives in this language: unpacking a tuple, a useful standard-library tool).
4. **Reading a failing test**: an excerpt of real output from a deliberately wrong solution (see below), never invented, then a one-line translation: "your `recall(30, 30)` returned 0.667 but should be 0.5; the test name says which idea is checked".
5. **Task**: each function and what it must do.
6. **Examples**: inputs and expected outputs, with every example's data shown in full (no "the table from lesson 001").
7. **Stuck?**: ask for a hint (one rung at a time, see below), or ask me to run your tests.

**Before handing over**, check every exercise (the solutions below live in a copy of the exercise folder under `scratch/` and are never committed):

- Run the exact Start-here command from inside the exercise folder on the stub: the result matches step 2's count and error. If it doesn't, fix the README.
- Write a reference solution and run the in-folder command against it: the tests pass.
- Write a deliberately wrong solution (one plausible mistake, not the stub), run the tests, and paste an excerpt of that output into **Reading a failing test**.

With toolchain `none`, write a problem set in `README.md` instead (no stub or tests): **Start here** says where the problems are, how to answer (in `answers.md` in the exercise folder, or in chat), the suggested order and the finish line ("done when every answer is checked Correct"); then the problems, with their data in full, and **Stuck?**. Keep the answer key in `scratch/`, and check answers in conversation, each reply opening with its verdict (`/learn:init` → **Questions and examples**).

## Hand over

1. Walk the learner through the first step in chat, not only the command: the `cd` line, the first test run and what it will show (and why that's expected), and which function to start with. End the turn without a dialog, on one line: "Run it, then say *next* (or paste what you see)."
2. Next turn, ask only "are these instructions clear?" with AskUserQuestion (`Practice · question · `), with options such as "Clear, I'm starting", "Not sure which file or lines to change", "Not sure how to run the tests". It's a feedback question (`/learn:init` → **Questions and examples**): no verdict, not recorded. If something is unclear, explain it in chat and fix that part of the README before they continue.

## While they work

- Run their tests when asked and explain failures in terms of the concept, not just the assertion.
- **Hint ladder**, one rung per request: (1) a question that points at the concept (plain text, never options that name the approach), (2) the approach in words, (3) a partial snippet. Give the full solution only when the learner explicitly asks for it.
- Review a passing solution like a code review: correctness, clarity, complexity, what a production version would add.

## Finish

Update `PROGRESS.md` (a `todo` or `learning` topic → `practised` when all exercises pass; any other status stays, since only a quiz confirms a `claimed` topic and practice is never evidence for a demotion), add a flashcard for each mistake that taught something, log the session, and commit `feat(<subject>): exercises for <topic>` (the learner's solutions are committed too, as their work).

---
name: practice
description: "Give the learner hands-on exercises for a topic, each with failing tests they make pass (in any language), seeded synthetic data, and a graded hint ladder. Use when the user says 'give me exercises', 'let me practise X', 'I want to code this myself', or after a /learn:teach lesson. Writes lessons/<NNN>-<topic>/exercises/ and never reveals a solution unless asked explicitly."
argument-hint: "<topic or lesson number> [easy|medium|hard]"
---
Set exercises for a topic. Argument: $ARGUMENTS

Resolve the subject as `/learn:init` describes, pull the learning repo as its **Sync** says, and find the topic's lesson folder (create a minimal one, with the next free NNN, if the topic is `claimed` and has none).

## Write the exercises

Create 2–4 exercises, increasing in difficulty, under `lessons/<NNN>-<topic>/exercises/<NN>-<slug>/`:

| File | Contents |
|---|---|
| `README.md` | The task, the inputs and expected outputs, and what it trains, with every example's data shown in full (no "the table from lesson 001"). No solution. |
| solution stub | Signatures and doc comments with a not-implemented body, named the toolchain's way (`solution.py`, `solution.ts`, `src/lib.rs`, …). The learner edits this file. |
| tests | Tests in the toolchain's test framework that fail on the stub and pass on a correct solution: normal cases, an edge case, and one property or tolerance check where it fits. |
| data generator | Seeded synthetic data generator, only if the exercise needs data; writes to `data/`. |
| dependency file | Whatever the toolchain needs to pin the exercise's dependencies (`requirements.txt`, `package.json`, `Cargo.toml`, `go.mod`, …); may be empty. |

- Exercises mirror the shape of a linked project's problem when there is one, but never use its data.
- Before handing over, write a reference solution in `scratch/`, run the toolchain's test command against it, confirm the tests pass, then confirm they fail on the stub. Never commit the reference solution.
- Tell the learner the exact test command for the exercise folder.
- With toolchain `none`, write a problem set in `README.md` instead (no stub or tests), keep the answer key in `scratch/`, and check answers in conversation, each reply opening with its verdict (`/learn:init` → **Questions and examples**).

## While they work

- Run their tests when asked and explain failures in terms of the concept, not just the assertion.
- **Hint ladder**, one rung per request: (1) a question that points at the concept (plain text, never options that name the approach), (2) the approach in words, (3) a partial snippet. Give the full solution only when the learner explicitly asks for it.
- Review a passing solution like a code review: correctness, clarity, complexity, what a production version would add.

## Finish

Update `PROGRESS.md` (a `todo` or `learning` topic → `practised` when all exercises pass; any other status stays, since only a quiz confirms a `claimed` topic and practice is never evidence for a demotion), add a flashcard for each mistake that taught something, log the session, and commit `feat(<subject>): exercises for <topic>` (the learner's solutions are committed too, as their work), then push as `/learn:init` → **Sync** says.

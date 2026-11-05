# 009 — Exercises that say what to do first

Status: implemented in Unreleased

## Problem

After `/learn:practice`, a learner said: "It is not actually clear for me what to do, we need to make it more user friendly... I didn't actually get what to really do in the file."

The exercise `README.md` described the task and the functions, but never said, step by step:

- which folder to open, and which file to edit;
- which lines in that file to replace;
- where to run the tests from (the command was a long one-liner run from the subject root);
- what the first run looks like before any code is written;
- how to read a failing test.

The skill only said "tell the learner the exact test command", so the handover was a command, not a starting point.

## Design

All in `skills/practice/SKILL.md`. Toolchain-agnostic: everything is derived from the subject's recorded toolchain in `LEARNING.md`.

### README structure

Every exercise `README.md` has these sections, in this order:

1. Title and a one-line **Trains:** naming the idea.
2. **Start here**, five numbered steps:
   1. `cd` into the exercise folder, as a full copy-pasteable path.
   2. Run the tests once before writing anything, with the **in-folder test command** (below), and what to expect: the observed result on the stub, e.g. "`4 failed`, each with `NotImplementedError` — expected, the functions are empty". For assert-based test programs that stop at the first failure (Kotlin, Java, C, C++ defaults), the expectation is the first failing check as observed.
   3. Which file to edit (the stub) and exactly what to replace: the placeholder body marked with the TODO comment; keep names and signatures; don't edit the test file ("it's the answer checker").
   4. A suggested order of the functions, easiest first, re-running the tests after each.
   5. The finish line: "done when the run ends with `4 passed`" (or the toolchain's own all-pass line).
3. Optional, where it helps: **What a finished function looks like** (a short, fully worked function that is not part of the exercise and does not give its answer away, showing the language idioms the exercise needs, such as returning `None` for an undefined result), or **What the input looks like** (how the data arrives in this language: unpacking a tuple, a useful standard-library tool).
4. **Reading a failing test**: a real failure excerpt, captured by running the tests against a deliberately wrong solution in `scratch/` (never invented), followed by a one-line translation ("your `recall(30, 30)` returned 0.667 but should be 0.5; the test name says which idea is checked").
5. **Task**: the functions and what they must do.
6. **Examples**: inputs and expected outputs, every example's data shown in full (the existing rule).
7. **Stuck?**: the hint ladder (ask for a hint, one rung at a time) and "ask me to run your tests".

There is no "run the tests from the subject root" section any more.

### In-folder test command

The toolchain's recorded test command, rewritten to run from inside the exercise folder: a `<dir>` argument becomes `.` or is dropped, and paths become relative. Examples: Python `uv run --with pytest pytest -q` (add `--with-requirements requirements.txt` when the requirements file is not empty); TypeScript `bun test`; Rust `cargo test`; Go `go test ./...`; Java and C as recorded, since they already run from the exercise folder. The README shows this command, not the subject-root one.

### Stub

Each placeholder body carries a TODO marker comment in the toolchain's comment syntax, `TODO: replace with your code` (e.g. `raise NotImplementedError  # TODO: replace with your code`, `throw new Error("not implemented"); // TODO: replace with your code`, `todo!() // TODO: replace with your code`). The README's step 3 names that marker.

### Verification before handover

Extends the existing reference-solution step:

- Reference solution in `scratch/`: the in-folder command passes (as before).
- The stub: run the exact Start-here command from inside the exercise folder and confirm the result matches what step 2 states (count and error). Fix the README if it doesn't.
- A deliberately wrong solution in `scratch/` (one plausible mistake, not a stub): run the tests, and paste an excerpt of the real output into **Reading a failing test**.
- Neither the reference nor the wrong solution is committed.

### Toolchain `none`

The problem set's README keeps the same shape, adapted: **Start here** says where the problems are, how to answer (write answers in `answers.md` in the exercise folder, or reply in chat), the suggested order, and the finish line ("done when every answer is checked Correct"); **Stuck?** as above. No test run, stub or failure excerpt.

### Handover in chat

The handover walks the learner through the first step in chat, not only the command: the `cd` line, the first test run and what it will show, and which function to start with and why it's the easiest. The turn ends without a dialog, on one line: "Run it, then say *next* (or paste what you see)."

The next turn asks one question, "are these instructions clear?", with AskUserQuestion (`Practice · question · `), options such as "Clear, I'm starting", "Not sure which file or lines to change", "Not sure how to run the tests". This is feedback with no right answer, so it follows the shared question format and **Content before the dialog**, but gets no verdict and isn't recorded as evidence. An unclear answer gets an explanation in chat, and the README is fixed for that point before the learner continues. Without AskUserQuestion, plain text.

`skills/init/SKILL.md` → **Questions and examples** gets one line for this kind of question (feedback with no right answer: format and content-before-dialog apply; no verdict, no record), so the shared contract stays the single definition.

## Affected files

- `skills/practice/SKILL.md`: README structure, stub TODO marker, in-folder command, verification, toolchain `none`, handover.
- `skills/init/SKILL.md`: one line in **Questions and examples** for feedback questions.
- `docs/ARCHITECTURE.md`: contract item 4 mentions feedback questions; the layout's exercise README line.
- `docs/SKILLS.md`, `docs/EXAMPLES.md`, `README.md`, `CHANGELOG.md` (Unreleased; no version bump, see below).
- `tests/run.sh`: a check that the practice skill keeps "Start here", "Reading a failing test" and the TODO marker.

`docs/WORKFLOW.md` and the diagrams don't change: the loop is the same.

## Version

PR #11 (spec 008) is open and will release 0.8.0. This change goes under `## [Unreleased]` in `CHANGELOG.md` with no `plugin.json` bump, so whichever merges second takes the next version at release time.

## Verification

1. `/learn:practice <topic>` in a Python subject: each exercise README opens with the title, **Trains:**, then **Start here** with the five steps; the `cd` path is the full exercise path; the test command is `uv run --with pytest pytest -q` (with `--with-requirements requirements.txt` only when that file is not empty).
2. Running that command from the exercise folder on the stub gives exactly the "N failed" count and error the README states.
3. Every placeholder body in the stub carries `# TODO: replace with your code`, and step 3 names it.
4. **Reading a failing test** contains output that matches a real run against a wrong solution (re-run it to compare), plus a one-line translation.
5. The README ends with **Stuck?**; every example's data is shown in full; there is no subject-root run section.
6. In a TypeScript, Rust or Go subject, the Start-here command is the recorded test command run from the exercise folder (`bun test`, `cargo test`, `go test ./...`), and the TODO marker uses `//`.
7. With toolchain `none`, the README has **Start here** with how-to-answer steps and **Stuck?**, and no test command.
8. The handover message shows the `cd`, the first run and the first function, ends on "say *next*" without a dialog; the next turn is one "are these instructions clear?" question with no verdict.
9. `bash tests/run.sh` and `claude plugin validate .` pass.

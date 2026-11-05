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

The full README structure and the checks live only in `skills/practice/SKILL.md` (**Write the exercises**, **Hand over**); this spec records the decisions.

- **README structure.** Every exercise README opens with **Start here**: open a terminal in the exercise folder (path relative to the learning repo root, never absolute), run the data generator if there is one, run the tests once with the in-folder command and what that first run shows (as observed), which file and which `TODO: replace with your code` lines to replace (never the test file), an easiest-first order, and the finish line (the success signal observed on the reference run, e.g. `4 passed`, or "exits with no output" for assert-based programs). Then, where it helps, a worked function or input example that isn't the answer; **Reading a failing test** (real output from a deliberately wrong solution plus a one-line translation); the task; examples with their data in full; **Stuck?**. No subject-root run section.
- **Stub.** Each placeholder body carries `TODO: replace with your code` in the toolchain's comment syntax.
- **In-folder test command, recorded per toolchain.** `skills/init/toolchains.md` gets an **Exercises** table: per toolchain, the exercise layout, the in-folder test command (runs only this exercise's tests: Rust exercises are their own small crates, Go runs `go test .` in the exercise's package inside the lesson module), and the scratch copy the checks need (the exercise folder, or the whole lesson folder for Go, which holds `go.mod`). `/learn:init` records the in-folder command in `LEARNING.md` next to run and test; a subject set up earlier gets it derived once by practice and recorded. Practice holds no per-language command list.
- **Checks before handover.** The stub is checked as the learner will meet it: generated data deleted, then the Start-here steps followed exactly as written; the first-run result must match the README. The reference solution passes in the scratch copy, and its success output becomes the finish line; the wrong solution's real output becomes the failure excerpt. Nothing from `scratch/` is committed.
- **Toolchain `none`.** Same Start here shape with how-to-answer steps (`answers.md` or chat), no test run.
- **Handover.** Walks through the first step in chat (the `cd`, the generator if any, the first run, the first function) and ends on "say *next*", no dialog. Pasted output that doesn't match the README is a teaching turn (diagnose, fix, fix the README if wrong, no dialog) until the first run looks right. Only then, in its own turn, one "are these instructions clear?" question.
- **Feedback question vs comprehension check** (shared contract, `skills/init/SKILL.md` → **Questions and examples**). Build mode's "is this clear?" is a comprehension check on a concept, with a right option: verdict and record as before. Practice's handover question is a **feedback question** about the materials: no right answer, so the question format and content-before-dialog rule apply, but no verdict and no record. Its prefix is `Practice · feedback · `.

## Affected files

- `skills/practice/SKILL.md`: README structure, stub marker, in-folder command lookup, checks, toolchain `none`, handover.
- `skills/init/SKILL.md`: records the in-folder test command; the feedback-question vs comprehension-check line.
- `skills/init/toolchains.md`: **Exercises** table. `skills/init/templates/subject/LEARNING.md`: an In-folder test row.
- `docs/ARCHITECTURE.md`, `docs/SKILLS.md`, `docs/EXAMPLES.md`, `README.md`, `CHANGELOG.md` (Unreleased; no version bump, see below).
- `tests/run.sh`: checks the practice headings and README markers, and the init feedback-question line.

`docs/WORKFLOW.md` and the diagrams don't change: the loop is the same.

## Version

PR #11 (spec 008) is open and will release 0.8.0. This change goes under `## [Unreleased]` in `CHANGELOG.md` with no `plugin.json` bump, so whichever merges second takes the next version at release time.

## Verification

1. `/learn:practice <topic>` in a Python subject: each exercise README opens with the title, **Trains:**, then **Start here**; step 1's `cd` is relative to the learning repo root; the test command is the subject's recorded in-folder test command.
2. From a fresh state (generated data deleted), following the Start-here steps exactly gives the first-run count and error the README states.
3. Every placeholder body in the stub carries `# TODO: replace with your code`, and Start here names it.
4. **Reading a failing test** matches a real run against a wrong solution; the finish line matches the reference run's output.
5. The README ends with **Stuck?**; every example's data is shown in full; there is no subject-root run section.
6. In a Rust subject, `cargo test` from an exercise folder runs only that exercise's tests; in a Go subject, `go test .` runs only that exercise's package, and the scratch checks run in a copy of the whole lesson folder.
7. An exercise with a data generator has a generator step before the first run.
8. With toolchain `none`, the README has **Start here** with how-to-answer steps and **Stuck?**, and no test command.
9. The handover shows the `cd`, the first run and the first function and ends on "say *next*" without a dialog; pasted output that differs from the README gets a fix, no dialog; the "are these instructions clear?" question comes alone afterwards, with no verdict. Build mode's "is this clear?" checks still get verdicts.
10. A subject whose `LEARNING.md` has no In-folder test row gets one recorded on its first practice.
11. `bash tests/run.sh` and `claude plugin validate .` pass.

# Skills reference

All skills resolve the learning repo the same way ([ARCHITECTURE.md](ARCHITECTURE.md#the-shared-contract)) and end by updating `PROGRESS.md` and committing. Questions are asked one at a time; decisions use Claude Code's question prompt.

## `/learn:init`

```
/learn:init <subject> [project paths…]
/learn:init add <project path>
/learn:init migrate [path]
```

Adds a subject to the learning repo as its own folder (creating the repo the first time), links another project to a subject, or migrates a v0.1.0 one-repo-per-subject learning repo into it.

- **Asks** (only what's missing): subject slug, projects to link, location of the learning repo, only the first time (default `~/Learning`, never inside a project), level, depth, lesson language, toolchain (proposed from [toolchains.md](../skills/init/toolchains.md) or detected from a linked project's manifest).
- **Creates**, the first time, the learning repo root: `README.md` (subject index), `CLAUDE.md`, `.gitignore`, `tools/guard.sh` with `tools/hooks/pre-commit` (enabled via repo-local `core.hooksPath`).
- **Adds** a `<subject>/` folder: `LEARNING.md` (including the default hands-on level for build mode), `PROGRESS.md`, `flashcards/deck.md`, and empty `curriculum/`, `plans/`, `builds/`, `lessons/`, `reflections/`, `scratch/`; and a row in `README.md`. An existing folder is never overwritten.
- **Registers** the repo and the subject in `spaces.json` under `$LEARNING_WORKFLOW_HOME` (default `~/.config/learning-workflow/`).
- **Migrates** (`migrate`) a standalone v0.1.0 repo into `<subject>/` with its git history (subtree merge), drops its own guard, `.gitignore` and `CLAUDE.md`, copies its `scratch/`, and repoints the registry. The old repo is deleted only if you confirm.
- **Never** creates a remote unless you confirm; it offers a private GitHub repo.
- Per linked project it records slug, path, remote, default branch and sensitivity (`work` by default for org-owned repos) in the subject's registry entry; the subject's `LEARNING.md` gets only the slug, sensitivity and a neutral one-line description.

## `/learn:plan`

```
/learn:plan <spec path | plan path | artifact URL | goal> [plan name]
```

Links a project's development plan (read-only, stays in the project) to a learning plan in `plans/<plan>.md`, by step ID.

- Keeps the dev plan's step IDs, or assigns `S1…` for a plain goal (after 1–2 questions).
- Reads the code each step will touch. For each step it lists 2–6 precise concepts, each marked `known` (from `PROGRESS.md` or a quick self-check) or `new`; `new` concepts too big for a note are flagged `deep`, with a `/learn:teach` suggestion.
- Per step: hands-on level (subject default unless changed) and 3–5 done-check questions answerable from the built code.

## `/learn:build`

```
/learn:build <step ID> [plan name] [claude|adaptive|you]
```

Turns learn mode on for one step in the current project.

1. **Start:** requires the project to be linked (offers `/learn:init add`), checks for an already-active step (offers `/learn:off` for it), asks up to 3 due flashcards, sets the level, marks the step `in progress`, and writes the state file (the plugin's `UserPromptSubmit` hook re-injects it on every prompt in that project).
2. **While on:** normal pair programming under the project's own rules, plus:
   - code at the hands-on level (overridable per prompt);
   - a `▸ concept:` note (2–4 lines) only when a decision depends on a `new` concept not yet shown;
   - a one-line prediction before tests, evals or benchmarks;
   - during background waits, one offer of a 2–5 minute deep dive with 1–2 "is this clear?" questions.
3. **Done-check** when you say the step is done or its PR opens: the step's questions, one at a time; misses become flashcards.
4. **Wrap-up:** sweeps the project for `TODO(learner)` markers, writes `builds/<date>-<step>.md`, sets the step `done`, records each concept in `PROGRESS.md` → Concepts (answered correctly → `built`; missed → a flashcard, and back to `learning` unless already `built`/`reflected`; shown but unchecked → `learning` if it was `todo`), commits in the learning repo, and deletes the state file.

With no plan, it can create a one-step plan from your description.

## `/learn:off`

```
/learn:off [no-wrapup]
```

Ends learn mode early: sweeps `TODO(learner)` markers, saves a paused build log (no done-check, so nothing is promoted; shown `todo` concepts → `learning`; the step stays `in progress`), then deletes the state file. `/learn:build <step>` resumes later.

## `/learn:curriculum`

```
/learn:curriculum <plan path | URL | spec | issue | topic> [track name]
```

Builds a track in `curriculum/<track>.md`.

- Reads the source; for a bare topic, asks which outcomes you want.
- Runs a multi-select self-assessment of the 6–10 load-bearing concepts; ticked ones get a quiz instead of a lesson.
- Each topic: why it matters here, 2–3 checkable "ready when" abilities, a lab idea, a project touchpoint (if linked), and 1–3 primary readings.
- 5–15 topics per track, ordered by dependency then by the source's phases; larger sources split into several tracks.

## `/learn:teach`

```
/learn:teach <track>/<topic-number> | <topic>
```

With no argument, picks the first `todo` topic whose prerequisites are all `ready`, `claimed`, `built` or `reflected`. Writes `lessons/<NNN>-<topic>/lesson.md` while teaching.

| Part | Content |
|---|---|
| 1. The problem | The situation in your project, or your goal, that needs this |
| 2. Intuition | Plain-language picture and a tiny worked example |
| 3. Mechanism | How it actually works, step by step |
| 4. Lab | Runnable demonstration in your toolchain, including one failure mode; you predict first |
| 5. In the project | Where a linked project uses it, cited `slug:path@sha` |
| 6. Pitfalls | 3–5 real mistakes with symptoms |
| 7. Vocabulary | Term → one-line definition |
| 8. Check | 3 questions; results recorded |

Adds 3–6 flashcards. Status `todo` → `learning`; other statuses stay.

## `/learn:practice`

```
/learn:practice <topic or lesson number> [easy|medium|hard]
```

Writes 2–4 exercises of rising difficulty, each with a task README, a stub, failing tests and (if needed) a seeded data generator.

- The tests are run against a reference solution in `scratch/` (never committed) and against the stub before you see them, so they're known to be fair.
- Hint ladder, one rung per request: a pointing question → the approach in words → a partial snippet. Full solution only on explicit request.
- A passing solution gets a short code review.
- Toolchain `none`: a problem set with the answer key kept in `scratch/`.

Status `todo`/`learning` → `practised` when every exercise passes; other statuses stay.

## `/learn:quiz`

```
/learn:quiz <track>/<n> | <topic>
/learn:quiz review
```

**Topic mode:** 8–12 questions covering every "ready when" item, 2–3 marked critical, in mixed formats (explain, predict-the-output, spot-the-bug, choose-and-justify, calculate). Adaptive: two misses on a sub-idea bring an easier follow-up. **Ready** at ≥ 80% and all critical questions right; otherwise you get the exact lesson part or exercise to revisit. Misses become flashcards.

**Review mode:** asks every due card, at most 20. Right moves a card up a box (max 5); wrong sends it to box 1.

| Box | Review interval |
|---|---|
| 1 | every session / 1 day |
| 2 | 2 days |
| 3 | 4 days |
| 4 | 8 days |
| 5 | 16 days |

## `/learn:reflect`

```
/learn:reflect <topic or phase> [PR URL | commit range]
```

After you build something in a project. Reads the PR or commits (read-only), your predictions and quiz answers, and the results you report as aggregates. Talks through expected vs actual, the biggest gap and its cause, what you'd change, and what you now understand; adds its own read of the diff. Writes `reflections/<date>-<topic>.md`, adds flashcards and new topics, and marks topics `built` → `reflected`. Follow-ups for the project are phrased as tasks for that project's own workflow.

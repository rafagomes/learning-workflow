# Skills reference

All skills resolve the learning repo the same way ([ARCHITECTURE.md](ARCHITECTURE.md#the-shared-contract)) and end by updating `PROGRESS.md` and committing. Questions are asked one at a time; decisions use Claude Code's question prompt.

## `/learn:init`

```
/learn:init <subject> [project paths…]
/learn:init add <project path>
```

Creates a learning repo for a subject, or links another project to an existing one.

- **Asks** (only what's missing): subject slug, projects to link, location (default `~/Learning/<slug>`, never inside a project), level, depth, lesson language, toolchain (proposed from [toolchains.md](../skills/init/toolchains.md) or detected from a linked project's manifest).
- **Creates**: `LEARNING.md`, `PROGRESS.md`, `CLAUDE.md`, `.gitignore`, `flashcards/deck.md`, `tools/guard.sh` (installed as the pre-commit hook), and empty `curriculum/`, `lessons/`, `reflections/`, `scratch/`.
- **Registers** the repo in `~/.config/learning-workflow/spaces.json`.
- **Never** creates a remote unless you confirm; it offers a private GitHub repo.
- Per linked project it records slug, path, remote, default branch and sensitivity (`work` by default for org-owned repos).

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

With no argument, picks the first `todo` topic whose prerequisites are `ready`. Writes `lessons/<NNN>-<topic>/lesson.md` while teaching.

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

Adds 3–6 flashcards. Status → `learning`.

## `/learn:practice`

```
/learn:practice <topic or lesson number> [easy|medium|hard]
```

Writes 2–4 exercises of rising difficulty, each with a task README, a stub, failing tests and (if needed) a seeded data generator.

- The tests are run against a reference solution in `scratch/` (never committed) and against the stub before you see them, so they're known to be fair.
- Hint ladder, one rung per request: a pointing question → the approach in words → a partial snippet. Full solution only on explicit request.
- A passing solution gets a short code review.
- Toolchain `none`: a problem set with the answer key kept in `scratch/`.

Status → `practised` when every exercise passes.

## `/learn:quiz`

```
/learn:quiz <topic>
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

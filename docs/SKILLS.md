# Skills reference

All skills resolve the learning repo the same way ([ARCHITECTURE.md](ARCHITECTURE.md#the-shared-contract)) and end by updating `PROGRESS.md` and committing. When the learning repo has a remote, every skill pulls it (`pull --rebase`) before reading and pushes after each commit; it asks before pulling over uncommitted changes, brings a conflict to you instead of resolving it, says so in one line when offline, and never force-pushes. Without a remote it doesn't mention syncing. Questions are asked one at a time, and decisions use Claude Code's question prompt. So do the questions that check what you learned (lesson predictions and checks, quiz questions, build mode's predictions and done-check): you pick one of 2–4 options (none marked recommended) or type your own answer or a "why…?" via Other, and any table or snippet the question needs is shown beside the options. Flashcards, hints and reflect's open questions stay plain text. Build mode's "is this clear?" questions are comprehension checks with a right answer; practice's "are these instructions clear?" after handing over exercises is a feedback question about the materials, with no right answer, so it gets no verdict and isn't recorded. Every reply to your answer starts with an unhedged verdict, **Correct.**, **Incorrect.** or **Partly correct.** (a multi-part answer, or a right pick with the wrong reason), then explains: the right answer and why the wrong one was tempting, or which part was right. That verdict is the one recorded and scored. Teaching and questions never share a turn: an explanation, table, video or lab output ends with "say *next* when you've read it", and the question comes on its own in the next turn with everything it needs in it, because an open question dialog can hide the text above it. In a lesson, each part asks at most one question, never two on the same idea; a `deep` lesson goes deeper, not longer on questions. You always know where you are: a lesson opens with a one-line roadmap of its parts and marks each one (`[3/9 · Mechanism]`), and a lesson check, quiz or done-check says how many questions it has and numbers each (`Question 2/3`). Examples always show all their data where they're used: re-shown in full when a lesson builds on them, or a fresh small example (≤ 6 rows) for a new concept. Without the prompt (headless), questions are plain text.

## `/learn:init`

```
/learn:init <subject> [project paths…]
/learn:init add <project path>
/learn:init migrate [path]
/learn:init remote
```

Adds a subject to the learning repo as its own folder (creating the repo the first time), links another project to a subject, migrates a v0.1.0 one-repo-per-subject learning repo into it, or gives the learning repo a private remote.

- **Asks** (only what's missing): subject slug, projects to link, location of the learning repo, only the first time (default `~/Learning`, never inside a project), level, depth, lesson language, toolchain (proposed from [toolchains.md](../skills/init/toolchains.md) or detected from a linked project's manifest), recorded as run, test and in-folder test commands.
- **Creates**, the first time, the learning repo root: `README.md` (subject index), `CLAUDE.md`, `.gitignore`, `tools/guard.sh` with `tools/hooks/pre-commit` (enabled via repo-local `core.hooksPath`).
- **Adds** a `<subject>/` folder: `LEARNING.md` (including the default hands-on level for build mode), `PROGRESS.md`, `flashcards/deck.md`, and empty `curriculum/`, `plans/`, `builds/`, `lessons/`, `reflections/`, `scratch/`; and a row in `README.md`. An existing folder is never overwritten.
- **Registers** the repo and the subject in `spaces.json` under `$LEARNING_WORKFLOW_HOME` (default `~/.config/learning-workflow/`).
- **Migrates** (`migrate`) a standalone v0.1.0 repo into `<subject>/` with its git history (subtree merge), drops its own guard, `.gitignore` and `CLAUDE.md`, copies its `scratch/`, and repoints the registry. The old repo is deleted only if you confirm.
- **Offers a private GitHub remote**, recommended so the repo syncs across machines; created only after you confirm, and local-only stays a valid choice. If the name is taken on your account, it asks whether to pick another name or rename the existing repo (checking first whether the rename would break a Pages site, base paths, workflows or webhooks); the learning repo never takes the old name, so GitHub's redirect keeps working. `remote` does the same for an existing learning repo.
- **On another machine**, give a clone of the learning repo as the location: it's registered with its subjects instead of created.
- Per linked project it records slug, path, remote, default branch and sensitivity (`work` by default for org-owned repos) in the subject's registry entry; the subject's `LEARNING.md` gets only the slug, sensitivity and a neutral one-line description.

## `/learn:plan`

```
/learn:plan <spec path | plan path | artifact URL | goal> [plan name]
/learn:plan [existing plan name]
```

Links a project's development plan (read-only, stays in the project) to a learning plan in `plans/<plan>.md`, by step ID. Given the name of an existing plan (or nothing, when plans exist), it shows that plan instead; see **Plan view** below.

- Keeps the dev plan's step IDs, or assigns `S1…` for a plain goal (after 1–2 questions).
- Reads the code each step will touch. For each step it lists 2–6 precise concepts, each marked `known` (from `PROGRESS.md` or a quick self-check) or `new`; `new` concepts too big for a note are flagged `deep`, with a `/learn:teach` suggestion.
- Per step: hands-on level (subject default unless changed) and 3–5 done-check questions answerable from the built code.

**Plan view** (read-only): every concept of every step is an item, shown in plan order with its status from `PROGRESS.md` → Concepts (`✓` taught, `★` ready or built, `·` todo, `–` skipped, `○` known), its lesson and quiz score, which steps are ready to build (every item taught or known), and the next item. Then one question: **continue** (`/learn:teach <plan>`), **recheck an item** (re-teach or quiz it), **build a step** (`/learn:build <step>` from the project) or **done**.

```
Zone classification · 2 of 30 items covered · 0 ready · 0 skipped
Z0 · Funnel + "Industrial" definition                todo
  ✓ learning   zoning vs land use                   lesson 001
  ✓ learning   precision vs recall           deep   lesson 002
  ·  todo      label definition
Next: label definition (Z0)
```

## `/learn:build`

```
/learn:build <step ID> [plan name] [claude|adaptive|you]
```

Turns learn mode on for one step in the current project.

1. **Start:** requires the project to be linked (offers `/learn:init add`), checks for an already-active step (offers `/learn:off` for it), asks up to 3 due flashcards, sets the level, marks the step `in progress`, and writes the state file (the plugin's `UserPromptSubmit` hook re-injects it on every prompt in that project).
2. **While on:** normal pair programming under the project's own rules, plus:
   - code at the hands-on level (overridable per prompt);
   - a `▸ concept:` note (2–4 lines) only when a decision depends on a `new` concept not yet shown;
   - a prediction (pick an outcome) before tests, evals or benchmarks;
   - during background waits, one offer of a 2–5 minute deep dive with 1–2 "is this clear?" questions.
3. **Done-check** when you say the step is done or its PR opens: the step's questions, one at a time, each needing the right reason as well as the right pick; misses (and right picks with a wrong reason) become flashcards.
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
/learn:teach <step> | <plan> | <plan>/<step>/<concept>
/learn:teach
```

Writes `lessons/<NNN>-<topic>/lesson.md` while teaching. The conversation only teaches; a background writer agent records each part as it's taught, then adds the flashcards, updates `PROGRESS.md` and commits (one commit per lesson, sha shown in one line), so the next question or lesson never waits on a write. Video search and reading the linked project's code also run in the background at lesson start, and Claude re-reads every cited line before teaching it. After a lesson is saved in a long session, it suggests `/compact`, or `/clear` then `/learn:teach <plan>` to resume (a skill can't run either). Another `/learn` skill starts only once the last sha is in. Without the Agent tool or SendMessage, or if the writer can't write, it writes inline.

| Argument | Teaches |
|---|---|
| `<track>/<n>`, `<topic>` | That curriculum topic or free topic |
| `<step>` (e.g. `Z0`) | The step's concepts from its learning plan, in order, skipping those already taught |
| `<plan>` | The whole plan in order, from the first untaught concept; stop any time and resume later |
| `<plan>/<step>/<concept>`, or a concept name | That one concept, even if taught or skipped (a recheck); one lesson updates every step that lists it |
| nothing | Asks which plan or track to continue (lists them with progress) |

Plan concepts are taught **one per lesson**, then it offers the next one (continue, skip, stop). A `deep` concept gets the full lesson below. Others get a short lesson: problem, worked intuition, an optional video, in the project, one pitfall, a 2-question check (a lab only if asked or if the check misses).

| Part | Content |
|---|---|
| 1. The problem | The situation in your project, or your goal, that needs this |
| 2. Intuition | Plain-language picture and a tiny worked example |
| 3. Mechanism | How it actually works, step by step |
| 4. Watch (optional) | 1–2 free videos of ≤ 15 min (or a ≤ 15-min segment from its chapters or timestamps) on this concept and a bit more, found by web search and checked; never invented. Off with `Videos in lessons: off` in `LEARNING.md` |
| 5. Lab | Runnable demonstration in your toolchain, including one failure mode; you predict first |
| 6. In the project | Where a linked project uses it, cited `slug:path@sha` |
| 7. Pitfalls | 3–5 real mistakes with symptoms |
| 8. Vocabulary | Term → one-line definition |
| 9. Check | 3 questions; results recorded |

Adds 3–6 flashcards. Status `todo` → `learning`; other statuses stay. A plan concept's row in `PROGRESS.md` → Concepts records its lesson number.

## `/learn:practice`

```
/learn:practice <topic or lesson number> [easy|medium|hard]
```

Writes 2–4 exercises of rising difficulty, each with a README, a stub, failing tests and (if needed) a seeded data generator.

- Each README opens with **Start here**: open a terminal in the exercise folder, run the data generator if there is one, run the tests once with the subject's in-folder test command (and what that first run shows, plus what it looks like from the wrong folder), which `TODO: replace with your code` lines to replace, the order, and the finish line. It then shows how to read a failing test, from real output. The full structure is in [`skills/practice/SKILL.md`](../skills/practice/SKILL.md).
- Before you see them, the Start-here steps are followed on the stub from a fresh state, and the tests are run against a reference solution and a deliberately wrong one in `scratch/` (never committed), so they're fair and the README's first run, finish line and failure excerpt are real.
- The handover walks you through the first step in chat. If your first run doesn't match the README, that gets fixed first; then you're asked whether the instructions are clear (a feedback question, no verdict).
- Toolchain `none`: a problem set whose Start here says how to answer, with the answer key kept in `scratch/`.

Status `todo`/`learning` → `practised` when every exercise passes; other statuses stay.

## `/learn:quiz`

```
/learn:quiz <track>/<n> | <topic>
/learn:quiz <step> | <plan> | <plan>/<step>/<concept>
/learn:quiz review
```

**Plan mode:** quizzes the taught concepts of a step or plan (3–5 questions each), or one concept (8–12). Ready-when comes from the concept's lesson check and its `why:` in the plan; critical questions are the ones the step's done-check depends on. Scores are recorded on each concept's row.

**Topic mode:** 8–12 questions covering every "ready when" item, 2–3 marked critical, in mixed formats (explain, predict-the-output, spot-the-bug, choose-and-justify, calculate). Adaptive: two misses on a sub-idea bring an easier follow-up. Explain, choose-and-justify and critical questions also need the right reason (a "why?" pick or a typed explanation), so a lucky pick can't make a topic ready. **Ready** at ≥ 80% and all critical questions right; otherwise you get the exact lesson part or exercise to revisit. Misses become flashcards.

**Review mode:** asks every due card, at most 20. Correct moves a card up a box (max 5); Incorrect sends it to box 1.

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

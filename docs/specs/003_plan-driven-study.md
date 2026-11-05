# 003 — Study a learning plan in order

Status: implemented in Unreleased

## Problem

`/learn:plan` lists, per step, the concepts a dev step needs and flags the `deep` ones with "suggest `/learn:teach`". To study them, the learner has to retype each concept as a free-text topic (`/learn:teach precision and recall`). There is no way to:

- teach a step's concepts by its ID (`/learn:teach Z0`);
- work through a whole plan in order and pick up where they stopped;
- see which items of a plan are done, or go back and recheck one.

## Design

### Plan items

An **item** is one concept listed under a step in `plans/<plan>.md`, addressed as `<plan>/<step>/<concept>`. In conversation, the step ID or the concept name alone is enough when it's unambiguous. Items are in **plan order**: steps in the order of the plan's table, and concepts in the order they are listed under each step.

Item status lives in **one** place: the subject's `PROGRESS.md` → **Concepts** table, with `Step` = `<plan>/<step>`. It uses the existing statuses (`todo` → `learning` → `practised` → `ready` → `built` → `reflected`, and `claimed`). An item with no row is `todo`, unless the plan marks it `known`, which counts as `claimed`. The `Note` column records the lesson and quiz (`lesson 004 · quiz 9/10`). The plan file itself is not rewritten by study skills, apart from the step **Log** line that `/learn:build` already writes.

A concept shared by two steps or plans gets one row per `<plan>/<step>`. Teaching it once marks every row with the same concept name.

### `/learn:teach`

New argument forms; the existing ones (`<track>/<n>`, `<topic>`) are unchanged:

| Argument | Teaches |
|---|---|
| `<step>` (e.g. `Z0`) | That step's items in plan order, skipping items at `learning` or beyond. If several plans have the step, ask which one. |
| `<plan>` (e.g. `zone-classification`) | The whole plan from the first `todo` item, step by step. Say when it crosses into the next step. |
| `<plan>/<step>/<concept>` or a concept name that matches an item | That item, even if it's already taught (a recheck). |
| none | If plans have `todo` items, or tracks have `todo` topics, ask which plan or track to continue (one question listing them with their progress). Then continue that one. With only one candidate, continue it after saying which. |

For each item:

- **One concept per lesson.** A `deep` item gets the full lesson structure (problem, intuition, mechanism, lab, in the project, pitfalls, vocabulary, check). Any other item gets a **short lesson**: problem, intuition with a tiny worked example, in the project, one pitfall, and a check of 2 questions. There's no lab unless the learner asks. Both write `lessons/<NNN>-<concept-slug>/lesson.md`.
- The "problem" and "in the project" parts start from the item's `why:` line and the step's **Builds** line, so the lesson is about the step the learner will build.
- `known` items are skipped. If the learner asks, one check question confirms one.
- After each item: update its Concepts row (`todo` → `learning`, Note = lesson number), add flashcards, log, and commit `docs(<subject>): lesson <NNN> <concept>`. Then offer the next item by name: continue, stop, or skip it. Stopping is always fine; the next `/learn:teach <plan>` resumes at the first `todo` item.
- When every item of a step is at `learning` or beyond, say the step is ready to build (`/learn:build <step>`, from the project).

### `/learn:quiz`

Accepts `<step>`, `<plan>` and items too. It quizzes the taught items (`learning` or beyond) of the step or plan, or just the one item. For an item, the ready-when comes from its lesson's check and its `why:` line. Critical questions are the ones the step's done-check depends on. Pass → the item's row becomes `ready`. Fail → as today (`ready` → `learning`, `claimed` → `todo`; `built`/`reflected` unchanged), and the Note gets the score.

### `/learn:plan <existing plan>`: the plan view

When the argument names an existing plan in `plans/` (or there's no argument and plans exist: list them and ask), `/learn:plan` doesn't build a new plan. It shows the existing one, read-only:

```
Zone classification · 3 of 30 items taught · 0 ready · step Z0 ready to build
Z0 · Funnel + "Industrial" definition                      todo
  ✓ learning   zoning vs land use                   lesson 001
  ✓ learning   precision vs recall           deep   lesson 002
  ·  todo      label definition
  ·  todo      coverage funnel
Z1 · Golden sets + baseline scorecard                      todo
  ·  todo      golden set and the label guideline
  …
Next: label definition (Z0)
```

Marks: `✓` taught (`learning`, `practised`), `★` `ready` or beyond, `·` `todo`, `○` `known`/`claimed`. Then it asks one question: **continue** (the next `todo` item, as `/learn:teach <plan>`), **recheck an item** (pick it, then re-teach or quiz it), **build a step** (prints `/learn:build <step>` to run from the project), or **done**. The chosen action runs by invoking that skill (Skill tool) with the matching argument.

### `/learn:build`

When it builds a plan step, concepts already at `learning` or beyond count as taught: a decision that depends on one gets a one-line reminder that points to its lesson, not a full concept note.

## Out of scope

- Reordering, adding or deleting plan items from the view (edit the plan file, or re-run `/learn:plan <dev plan>`).
- Teaching several concepts in one lesson.
- A separate status command; the view lives in `/learn:plan`.

## Verification

| Check | Expected |
|---|---|
| `bash tests/run.sh`, `claude plugin validate .` | Pass |
| `skills/teach/SKILL.md` | Documents the four argument forms in the table above, plan order, the short vs full lesson by `deep`, resuming at the first `todo` item, and the Concepts-row update |
| `skills/quiz/SKILL.md` | Accepts step, plan and item; the ready-when and critical questions come from the item |
| `skills/plan/SKILL.md` | Existing plan name, or no argument with plans present → read-only view with the marks above and the four actions; a dev-plan argument still builds a plan |
| `skills/build/SKILL.md` | Taught concepts get a one-line reminder |
| Docs | `README.md`, `docs/SKILLS.md`, `docs/WORKFLOW.md`, `CHANGELOG.md` show `/learn:teach <step>`, `/learn:teach <plan>` and the plan view |
| Walkthrough, by hand | In a scratch subject with a two-step plan: `/learn:teach S1` teaches S1's items in order and marks them `learning`; `/learn:plan <plan>` shows them taught and offers the next item; picking "recheck" on a taught item quizzes it and records the score |

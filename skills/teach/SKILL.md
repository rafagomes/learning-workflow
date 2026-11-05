---
name: teach
description: "Teach one topic in depth as an interactive lesson: intuition, the mechanism, a runnable lab with real numbers, how it shows up in the linked project, pitfalls, and a check for understanding. Also works through a learning plan in order: a step ID ('/learn:teach Z0') teaches that step's concepts, a plan name teaches the whole plan and resumes where the learner stopped. Use when the user says 'teach me X', 'explain X properly', 'deep dive on X', 'next lesson', 'teach me Z0', 'continue the plan', or names a curriculum topic, plan step or plan. Writes lessons/<NNN>-<topic>/ in the subject's folder of the learning repo."
argument-hint: "<track>/<topic-number> | <topic> | <plan step> | <plan> | <plan>/<step>/<concept>"
---
Teach a topic. Argument: $ARGUMENTS

Resolve the subject and current project as `/learn:init` describes. Read `LEARNING.md` (profile, toolchain, data policy) and, if the topic is in a track, its entry in `curriculum/<track>.md` (why it matters, ready-when, touchpoint).

## What to teach

Match the argument in this order:

1. `<track>/<n>`: that curriculum topic.
2. **A plan step ID** (`Z0`, `P1`, `S2`) found in `plans/*.md`: that step's items, in plan order (see **Plan items**), skipping items at `learning` or beyond. If several plans have that step, ask which one.
3. **A plan name** (a file `plans/<plan>.md`): the whole plan, from the first `todo` item, step by step. Say so when it moves into the next step.
4. `<plan>/<step>/<concept>`, or a concept name that matches exactly one plan item: that item, **even if it's already taught**. This is a recheck: teach it again from a new angle and record the new lesson.
5. Anything else: a free topic, as before.
6. **No argument:** gather what can be continued: plans with `todo` items (with their counts, e.g. "zone-classification · 3 of 30 taught · next: label definition (Z0)") and tracks with `todo` topics whose prerequisites are `ready`, `claimed`, `built` or `reflected`. With several, ask which one (one question). With one, say which and continue it. With none, suggest `/learn:plan` or `/learn:curriculum`.

### Plan items

An **item** is one concept listed under a step's **Concepts** in `plans/<plan>.md`, addressed as `<plan>/<step>/<concept>`. **Plan order** means the steps in the order of the plan's table, then the concepts in the order they're listed under each step. An item's status is its row in `PROGRESS.md` → **Concepts**, where `Step` is `<plan>/<step>`. No row means `todo`; an item marked `known` in the plan counts as `claimed` and is skipped (if the learner wants, confirm it with one check question). A concept that appears in several steps or plans is taught once, and every row with that concept name is updated.

Teach **one item per lesson**. After each, offer the next item by name and ask: continue, skip it, or stop. Stopping is always fine: `/learn:teach <plan>` (or `/learn:plan <plan>` to see where you are) resumes at the first `todo` item. A `deep` item gets the full **Lesson structure** below. Any other item gets a **short lesson** (see below). Start the lesson's problem and "in the project" parts from the item's `why:` line and the step's **Builds** line, so it's about what the learner will build. When every item of a step is at `learning` or beyond, say the step is ready to build: `/learn:build <step>`, from the project.

## How to teach

This is a conversation, not a document dump.

- **One concept at a time.** Explain a step, then ask one question (prediction, or "what would happen if…"), and wait for the answer before continuing. Correct misconceptions directly and say why the wrong idea was tempting.
- **Predict before running.** Before every lab run, ask the learner to predict the result. Compare afterwards.
- **Never state a number you haven't computed.** Run the lab or a snippet and quote its output.
- Match the profile's depth and language. Define every term the first time it appears.
- If the learner already knows a part, skip it after one check question.

## Lesson structure

Work through these parts, writing `lessons/<NNN>-<topic-slug>/lesson.md` as you go (NNN = next free number):

1. **The problem**: the concrete situation in the linked project, or the learner's goal, that needs this. Cite `<project-slug>:path@shortsha` when relevant; obey the data policy.
2. **Intuition**: a plain-language picture or analogy, and a tiny worked example by hand.
3. **Mechanism**: how it actually works, step by step: the algorithm, the math, the language rule, the runtime behaviour. Explain notation; derive what is short enough to derive.
4. **Lab**: a self-contained program in the repo's toolchain (`LEARNING.md` → Toolchain), with pinned dependencies and seeded synthetic data, run with the recorded run command. It demonstrates the mechanism and one way it fails. Keep it under ~120 lines and print labelled results. With toolchain `none`, the lab is a worked problem the learner solves step by step, and you check each step.
5. **In the project**: how a linked project uses (or should use) this, and what to look for when reading its code. Read-only. Skip when no project is linked.
6. **Pitfalls**: the 3–5 mistakes practitioners actually make, each with a symptom to recognise it.
7. **Vocabulary**: a term → one-line definition table.
8. **Check**: 3 short questions answered in the conversation; record which ones the learner got right.

### Short lesson (plan items not flagged `deep`)

Same rules (one idea at a time, predict before running, never state an uncomputed number). Write `lessons/<NNN>-<concept-slug>/lesson.md` with: **The problem** (from the item's `why:`), **Intuition** with a tiny worked example by hand, **In the project**, **One pitfall** with its symptom, and a **Check** of 2 questions. There's no lab unless the learner asks for one or the check shows the idea didn't land; then add one and treat it as a full lesson.

## Finish

- Add 3–6 flashcards for the core ideas to `flashcards/deck.md` (box 1, next = today).
- Update `PROGRESS.md`: a `todo` topic → `learning` (any other status stays, since teaching isn't evidence of a gap). For a plan item, update (or add) its **Concepts** row: `Concept` = the concept name as written in the plan, `Step` = `<plan>/<step>`, status `todo` → `learning` (others stay), `Note` = `lesson <NNN>` (a recheck appends it: `lesson 002, 011`). Log the session with one line on what clicked and what didn't.
- Commit `docs(<subject>): lesson <NNN> <topic>`, one commit per lesson, so stopping between items loses nothing.
- Suggest the next step: `/learn:practice <topic>`, or `/learn:quiz <topic>` if the check went perfectly. When working through a plan, offer the next item first (continue, skip, stop).

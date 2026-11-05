---
name: quiz
description: "Check readiness for a topic with an adaptive quiz, or run a spaced-repetition flashcard review. Also quizzes a learning plan's step, whole plan or single item ('/learn:quiz Z0'). Use when the user says 'quiz me', 'test me on X', 'am I ready to build this', 'recheck X', 'review my flashcards', or after practice. Marks a topic ready at ≥ 80% with every critical question right, and turns misses into flashcards."
argument-hint: "<track>/<n> | <topic> | <plan step> | <plan> | <plan>/<step>/<concept> | review"
---
Quiz the learner. Argument: $ARGUMENTS

Resolve the subject as `/learn:init` describes. Every question, card included, is asked and recorded as `/learn:init` → **Questions and examples** says: one AskUserQuestion with 2–4 options, its data in the preview, Other for a typed answer.

## Review mode (`review`)

Read `flashcards/deck.md`, take every card whose `next` date is today or earlier (box 1 first), and ask them one at a time, with the card's answer among options drawn from its likely confusions. A typed answer (Other) is judged on its meaning, not the wording. Right → box +1 (max 5), next = today + interval for that box (1, 2, 4, 8, 16 days). Wrong → box 1, next = tomorrow, and explain briefly. Stop after 20 cards or when the learner says so. Update the deck, log, commit `docs(<subject>): flashcard review`.

## Plan mode (a plan step, a plan, or a plan item)

Match the argument as `/learn:teach` does (step ID, plan name, `<plan>/<step>/<concept>` or a concept name); items, concept names, status lookup and shared concepts are defined in `/learn:teach` → **Plan items**. Quiz the **taught** items (`learning` or beyond) of the step or plan, in plan order, one concept at a time; a single named item is quizzed whatever its status. If none are taught, say so and offer `/learn:teach` with the same argument. For a whole plan, say how many items that is and ask whether to do all of them or one step.

Run it like topic mode below, with these differences:

- **Ready when** for an item comes from its lesson's **Check** (if it has a lesson) and its `why:` line in the plan. **Critical** questions are the ones the step's **Done-check** depends on.
- Plan 3–5 questions per item (8–12 for a single item), still asked one at a time.
- **Save after each item**, so stopping loses nothing: write `quiz.md` in the item's lesson folder (an item with no lesson, e.g. a `claimed` one, gets a new `lessons/<NNN>-<concept-slug>/` to hold it), update the Concepts rows of every item with that concept name and its same-named Tracks topic with the status rules below, append the dated score to `Note` (`quiz 4/5 2026-11-04`) and drop a `skipped <date>` mark if the status is no longer `todo`, add flashcards for misses, and commit `docs(<subject>): quiz <concept>`. Then offer the next item: continue or stop. A later quiz of the same plan or step skips items already quizzed that day.
- After the quiz, say whether each step involved is **ready to build**, with the definition in `/learn:teach` → **Plan items** (every item covered), and separately which items are now `ready`. A failed item that drops to `todo` (a disproven `known`) is taught again by the next `/learn:teach <plan>`.

## Topic mode

1. Read the topic's "ready when" from the curriculum and its lesson, if it has one. A `claimed` topic may have no lesson folder: create `lessons/<NNN>-<topic>/` (next free NNN) to hold `quiz.md`. Plan 8–12 questions covering every ready-when item; mark 2–3 as **critical** (the ideas the project phase depends on).
2. Mix formats: explain-in-your-words (options are approaches or partial claims; say a typed explanation is welcome), predict-the-output (the snippet in the preview; run it afterwards to confirm), spot-the-bug, choose-and-justify (a design decision from the project phase), and calculation with numbers you computed. Each question shows all the data it needs, never "the table from the lesson".
3. Ask **one question at a time**. After each answer: right/partly/wrong, and the one-sentence reason. Adapt: two misses on a sub-idea → one easier follow-up on it.
4. Do not reveal upcoming questions or hint at answers in the question wording.

**Score:** ready at ≥ 80% **and** all critical questions right. Otherwise list the gaps and point to the exact lesson part or exercise to revisit.

Write `lessons/<NNN>-<topic>/quiz.md` (date; per question its data, options, the learner's pick or typed answer summarised, and the verdict; score; gaps). Add a flashcard per miss. Update `PROGRESS.md`: passed → `ready`, except a `built` or `reflected` topic, which keeps its status (the score is still recorded); failed `claimed` → `todo`; failed `ready` (a re-check) → `learning`; failed `built` or `reflected` → unchanged (the gaps become flashcards), log, commit `docs(<subject>): quiz <topic>`. Plan mode uses the same rules.

When a whole phase's topics are `ready`, say so: the learner can now build that phase in the project, through the project's own workflow. After building it, `/learn:reflect` records the result and moves those topics to `built` and `reflected`.

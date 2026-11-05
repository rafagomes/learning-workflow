---
name: quiz
description: "Check readiness for a topic with an adaptive quiz, or run a spaced-repetition flashcard review. Also quizzes a learning plan's step, whole plan or single item ('/learn:quiz Z0'). Use when the user says 'quiz me', 'test me on X', 'am I ready to build this', 'recheck X', 'review my flashcards', or after practice. Marks a topic ready at ≥ 80% with every critical question right, and turns misses into flashcards."
argument-hint: "<track>/<n> | <topic> | <plan step> | <plan> | <plan>/<step>/<concept> | review"
---
Quiz the learner. Argument: $ARGUMENTS

Resolve the subject as `/learn:init` describes.

## Review mode (`review`)

Read `flashcards/deck.md`, take every card whose `next` date is today or earlier (box 1 first), and ask them one at a time. The learner answers in their own words; judge the meaning, not the wording. Right → box +1 (max 5), next = today + interval for that box (1, 2, 4, 8, 16 days). Wrong → box 1, next = tomorrow, and explain briefly. Stop after 20 cards or when the learner says so. Update the deck, log, commit `docs(<subject>): flashcard review`.

## Plan mode (a plan step, a plan, or a plan item)

Match the argument as `/learn:teach` does (step ID, plan name, `<plan>/<step>/<concept>` or a concept name matching one item; ask when ambiguous). Quiz the **taught** items it covers (`learning` or beyond in `PROGRESS.md` → **Concepts**, `Step` = `<plan>/<step>`), in plan order; a single named item is quizzed whatever its status. If none are taught, say so and offer `/learn:teach` with the same argument.

Run it like topic mode below, with these differences:

- **Ready when** for an item comes from its lesson's **Check** and its `why:` line in the plan. **Critical** questions are the ones the step's **Done-check** depends on.
- Plan 3–5 questions per item (8–12 for a single item), still asked one at a time.
- Write `quiz.md` in each item's lesson folder. Update each item's Concepts row with the same rules as topics (passed → `ready`; failed `claimed` → `todo`; failed `ready` → `learning`; failed `built`/`reflected` unchanged), and append the score to its `Note` (`quiz 4/5`). Commit `docs(<subject>): quiz <plan or step>`.
- When every item of a step is `ready` or beyond, say the step is ready to build: `/learn:build <step>`, from the project.

## Topic mode

1. Read the topic's "ready when" from the curriculum and its lesson, if it has one. A `claimed` topic may have no lesson folder: create `lessons/<NNN>-<topic>/` (next free NNN) to hold `quiz.md`. Plan 8–12 questions covering every ready-when item; mark 2–3 as **critical** (the ideas the project phase depends on).
2. Mix formats: explain-in-your-words, predict-the-output (show a short snippet; run it afterwards to confirm), spot-the-bug, choose-and-justify (a design decision from the project phase), and calculation with numbers you computed.
3. Ask **one question at a time**. After each answer: right/partly/wrong, and the one-sentence reason. Adapt: two misses on a sub-idea → one easier follow-up on it.
4. Do not reveal upcoming questions or hint at answers in the question wording.

**Score:** ready at ≥ 80% **and** all critical questions right. Otherwise list the gaps and point to the exact lesson part or exercise to revisit.

Write `lessons/<NNN>-<topic>/quiz.md` (date, questions, learner's answers summarised, score, gaps). Add a flashcard per miss. Update `PROGRESS.md`: passed → `ready`; failed `claimed` → `todo`; failed `ready` (a re-check) → `learning`; failed `built` or `reflected` → unchanged (the gaps become flashcards), log, commit `docs(<subject>): quiz <topic>`.

When a whole phase's topics are `ready`, say so: the learner can now build that phase in the project, through the project's own workflow. After building it, `/learn:reflect` records the result and moves those topics to `built` and `reflected`.

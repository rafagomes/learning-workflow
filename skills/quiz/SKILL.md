---
name: quiz
description: "Check readiness for a topic with an adaptive quiz, or run a spaced-repetition flashcard review. Use when the user says 'quiz me', 'test me on X', 'am I ready to build this', 'review my flashcards', or after practice. Marks a topic ready at ≥ 80% with every critical question right, and turns misses into flashcards."
argument-hint: "<track>/<n> | <topic> | review"
---
Quiz the learner. Argument: $ARGUMENTS

Resolve the learning repo as `/learn:init` describes.

## Review mode (`review`)

Read `flashcards/deck.md`, take every card whose `next` date is today or earlier (box 1 first), and ask them one at a time. The learner answers in their own words; judge the meaning, not the wording. Right → box +1 (max 5), next = today + interval for that box (1, 2, 4, 8, 16 days). Wrong → box 1, next = tomorrow, and explain briefly. Stop after 20 cards or when the learner says so. Update the deck, log, commit `docs: flashcard review`.

## Topic mode

1. Read the topic's "ready when" from the curriculum and its lesson, if it has one. A `claimed` topic may have no lesson folder: create `lessons/<NNN>-<topic>/` (next free NNN) to hold `quiz.md`. Plan 8–12 questions covering every ready-when item; mark 2–3 as **critical** (the ideas the project phase depends on).
2. Mix formats: explain-in-your-words, predict-the-output (show a short snippet; run it afterwards to confirm), spot-the-bug, choose-and-justify (a design decision from the project phase), and calculation with numbers you computed.
3. Ask **one question at a time**. After each answer: right/partly/wrong, and the one-sentence reason. Adapt: two misses on a sub-idea → one easier follow-up on it.
4. Do not reveal upcoming questions or hint at answers in the question wording.

**Score:** ready at ≥ 80% **and** all critical questions right. Otherwise list the gaps and point to the exact lesson part or exercise to revisit.

Write `lessons/<NNN>-<topic>/quiz.md` (date, questions, learner's answers summarised, score, gaps). Add a flashcard per miss. Update `PROGRESS.md`: passed → `ready`; failed `claimed` → `todo`; failed `ready` (a re-check) → `learning`, log, commit `docs: quiz <topic>`.

When a whole phase's topics are `ready`, say so: the learner can now build that phase in the project, through the project's own workflow. After building it, `/learn:reflect` records the result and moves those topics to `built` and `reflected`.

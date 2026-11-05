# 006 — Questions with options, and examples that carry their own data

Status: implemented in Unreleased

## Problem

Two things slowed a real lesson down.

1. **Typing every answer.** Predictions, "your turn" questions, checks and quiz items were all asked in plain text. The learner typed each answer, and when unsure typed a question back to work out what was being asked. Most of these questions have a small set of plausible answers, so picking one would have been faster, with typing kept for when the learner wants to explain or ask.
2. **Data that wasn't on screen.** Lesson 001 used a parcels table (`Parcel | Zoning | Land use | Zoned? | Used?`). A later question showed only a derived table (`Land-use record | Which step decides | Filter says`) without the `Zoning` column; the learner read "Filter says Industrial" as the zoning and answered wrong. Lesson 002 then referred to "the parcels from our table" next to a new ground-truth table, so the learner had to scroll back to an earlier lesson to answer. The second concept didn't need the old table at all: a fresh small example would have been clearer.

## Design

Both rules apply to every study skill's conversation, so they are part of the shared contract, defined once in `skills/init/SKILL.md` (new section **Questions and examples**) and referenced, not restated, by `teach`, `quiz`, `build` and `practice`. `docs/ARCHITECTURE.md` and the repo's `CLAUDE.md` list it as the contract's fourth part. Two restatements are deliberate, both for a context that never loads init: build's state-file line (see below) and the teach writer's brief, which repeats the citation-only rule for project code.

### A. Questions are asked with AskUserQuestion

Covers every question that asks the learner to answer, predict or explain: teach's predictions, "your turn" questions and Check; quiz questions (topic and plan mode); build's predictions, "is this clear?" questions and done-check. Setup questions that already use AskUserQuestion (init, curriculum, plan) are unchanged.

Three kinds stay in plain text, because options would defeat them:
- **Flashcards** (quiz review mode, build's spaced review) train recall: with the answer among the options the learner only recognises it, and the Leitner box promotes a card that was never recalled.
- **Hints** (practice's first rung, a question pointing at the concept): options would name the approach that rung 2 is meant to hold back.
- **Open questions** that ask for the learner's account (reflect's talk-through questions).

- **One question per call**, so it stays one question at a time.
- **2–4 options, none marked "(Recommended)"**, and no order or wording that gives the right one away (the right answer's position varies; options are similar in length and tone).
- **Distractors are real misconceptions**: a swapped formula, the tempting wrong idea, an off-by-one, the confusion the lesson just warned about. Each option is short (a label of a few words, a one-line description at most).
- **"Other" is the free answer.** The automatic Other lets the learner type an answer or a "why…?" question. A typed reply is judged as the answer, or, when it's a question, the question is rephrased or explained and asked again.
- **Data goes in the preview.** When the question needs data (a table, a snippet, output), put it in the option `preview` as markdown, so it shows in a monospace box beside the options. Use the same preview on every option, or a different one per option when the options are alternative tables, outputs or code.
- **Questions where options would give the answer away** (explain why, derive) are still asked with AskUserQuestion: the options are approaches or partial claims to choose between, and the question says that typing a full explanation via Other is welcome.
- **Record the pick**: for each question, the data shown, the options, the one picked (or the typed text) and right / partly / wrong. teach sends this to the writer with the part (so it reaches `lesson.md` and the Check result), quiz writes it to `quiz.md` and counts it in the score, build records it in the build log. **Data policy:** synthetic or lesson data is recorded in full; a linked project's code or output, which a done-check or "In the project" question may show (within the policy's few-lines limit for `work` projects), is recorded only as its `<slug>:path@sha` citation and a paraphrase, never pasted into the learning repo.
- **Picking isn't enough for an ability.** With options, the quiz's ready bar or a done-check's `built` could be reached by recognising or guessing. So a pick that is evidence of an ability (a quiz's explain, choose-and-justify and critical questions; every done-check question) counts as right only with the right reason: after a right pick, a "why?" follow-up whose options are candidate reasons, or a typed explanation. The follow-up is part of the same question and scored once with it. Right pick, wrong reason is **partly**: in quiz it scores 0.5 and fails a critical question; in a done-check it counts as a miss (no `built`, a flashcard).
- **Build mode after compaction.** The hook re-injects only the state file's rule line, not the skill, so that line carries the essentials itself, limited to predictions, "is this clear?" and done-check questions (ordinary pair-programming decisions are unaffected): one question per call, 2–4 options, none recommended, position varied, real-misconception distractors, data in the preview within the data policy, Other handled, picks recorded, plain-text fallback.
- **Fallback**: without AskUserQuestion (headless, or a denied tool), ask in plain text with the same options listed, data shown above the question.

### B. Examples carry their own data

- Every question and explanation shows **all the data it relies on, right there**. Never refer back to an earlier table ("the parcels from our table") without showing it again.
- **Building on an example re-shows it whole**, with the new columns added, never a partial or derived table that drops a column the question depends on.
- **A new concept that doesn't need the old example gets a fresh, small one.** Each lesson starts with its own self-contained example; it may reuse a running example, but shows it again in full.
- **Small**: at most 6 rows, so it fits in a preview.

Applied to the lesson above: the question would have shown `Parcel | Zoning | Land use | Which step decides | Filter says` in its preview, and lesson 002 would have opened either with the parcels table re-shown alongside the ground truth in one table, or with a fresh four-row example for the new concept.

### Fit with background writing (spec 005)

The writer records only what it is sent. Each part sent to it now carries, per question: the question, its preview data, the options, the pick (or typed text) and the verdict. `lesson.md` therefore keeps the data each question showed, so the lesson file is self-contained too, and the Check result in **Finish** counts the picks.

## Affected files

- `skills/init/SKILL.md`: new **Questions and examples** section in the shared contract.
- `CLAUDE.md`: the contract's list.
- `skills/teach/SKILL.md`: How to teach, the writer's message and brief, Short lesson, Check.
- `skills/quiz/SKILL.md`: the reference, review mode stays plain text, the "why?" rule, recording in `quiz.md`.
- `skills/build/SKILL.md`: spaced review stays plain text, state-file rule line, predictions, done-check, build log.
- `skills/practice/SKILL.md`: the first hint rung stays plain text; exercise READMEs carry their own data.
- `docs/ARCHITECTURE.md`, `docs/SKILLS.md`, `docs/WORKFLOW.md`, `README.md`: the new rule where questions are described.
- `CHANGELOG.md`: Unreleased → Changed.

## Verification

1. `/learn:teach <topic>`: each prediction, "your turn" and Check question arrives as one AskUserQuestion call with 2–4 options, none labelled "(Recommended)"; across a lesson the right answer is not always in the same position.
2. A question that depends on a table shows that table in the option preview, with every column the question needs; the learner can answer without scrolling.
3. Typing "why is B wrong?" via Other gets an explanation and the question again, not a "wrong" verdict.
4. An explain-why question offers approaches or partial claims as options and says typing via Other is welcome.
5. A lesson building on an earlier example re-shows the full table with the new columns; a lesson on an unrelated concept uses a fresh example of ≤ 6 rows; no question says "from our earlier table" without showing it.
6. The committed `lesson.md` records, per question, the data shown, the options, the pick and the verdict; `quiz.md` does the same and its score matches the picks.
7. `/learn:build`: the done-check and predictions use AskUserQuestion, also after `/compact`; the build log records the picks, citing project code as `slug:path@sha` rather than pasting it.
8. `/learn:quiz review` and build's spaced review ask cards in plain text; practice's first hint is a plain question.
9. A quiz where the learner picks the right option on a critical explain question but the wrong reason in the "why?" follow-up scores it **partly** (one question, 0.5) and the topic is not marked ready; the same in a done-check is a miss and the concept doesn't become `built`.
10. With AskUserQuestion unavailable, questions are asked in plain text with the options listed and the data shown above them.
11. `bash tests/run.sh` and `claude plugin validate .` pass.

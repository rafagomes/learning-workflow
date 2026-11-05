# 007 — Explicit verdicts: Correct, Incorrect or Partly correct first

Status: implemented in Unreleased

## Problem

Feedback on an answer is soft: "Half right", "Not quite", "Right on both counts". The learner has to read the explanation to find out whether they got it, and a hedge can hide a wrong answer that was scored as wrong. The learner asked: "Be more assertive when you answer: say Correct or INCORRECT, then explain."

## Design

A shared study-question rule, so it goes in `skills/init/SKILL.md` → **Questions and examples**, next to the question rules from spec 006, and in the two places that restate those rules for a context that never loads init: build's state-file rule line and teach's writer brief.

- **Verdict first.** Every reply to an answer (a teach prediction, "your turn" question or Check; a quiz question; a build prediction, "is this clear?" question or done-check question; a flashcard; practice's answer check with toolchain `none`) opens with its verdict in bold, as the very first words: **Correct.**, **Incorrect.** or **Partly correct.**
- **Partly correct** only for a multi-part answer with some parts right, or a right pick with the wrong reason (spec 006's "why?" rule). Flashcards are Correct or Incorrect (the Leitner box is binary).
- **Then the explanation.** Incorrect: the right answer and why the tempting wrong one was tempting. Partly correct: which part was right and which wasn't.
- **No hedge in place of a verdict** ("not quite", "close", "half right", "almost"). Kindness is fine after the verdict.
- **The verdict is the record.** Never soften Incorrect into Partly correct. The verdict said is the one recorded (lesson, `quiz.md`, build log) and scored: Correct 1, Partly correct 0.5 in a quiz (and fails a critical question), Incorrect 0; Partly correct and Incorrect are both misses (a flashcard; in a done-check, no `built`). Records use the same words in place of 0.6.0's right / partly / wrong.
- **After a "why?" follow-up.** A right pick on a question that needs the right reason gets no verdict until the reason is in; then one verdict covers both.
- **Predictions** are Correct when the result falls within the option picked, so numeric options are non-overlapping ranges.
- **No verdict** for a typed Other that is a question (it's answered and re-asked), hints, or reflect's open questions.

## Affected files

- `skills/init/SKILL.md`: a **Verdict first** bullet; the record and "why?" bullets use the verdict words.
- `skills/teach/SKILL.md`: How to teach, the writer's message and brief.
- `skills/quiz/SKILL.md`: review mode, step 3, score.
- `skills/build/SKILL.md`: state-file rule line, predictions, done-check.
- `skills/practice/SKILL.md`: toolchain `none` answer checks.
- `docs/ARCHITECTURE.md`, `docs/SKILLS.md`, `README.md`, `CHANGELOG.md`.

## Verification

1. In `/learn:teach`, `/learn:quiz` and `/learn:build`, every reply to an answer starts with **Correct.**, **Incorrect.** or **Partly correct.**; none starts with "Not quite", "Close" or "Half right".
2. An Incorrect reply names the right answer and why the wrong one was tempting; a Partly correct reply says which part was right and which wasn't.
3. A right pick with a wrong "why?" reason is **Partly correct.**, scored 0.5 in a quiz and a miss in a done-check; a single-part wrong answer is never Partly correct.
4. `lesson.md`, `quiz.md` and the build log record the same verdict word the learner was told, and the quiz score matches them.
5. After `/compact` in build mode, done-check replies still open with the verdict (the state-file line carries the rule).
6. A typed "why is B wrong?" via Other gets an explanation and the question again, with no verdict.
7. `bash tests/run.sh` and `claude plugin validate .` pass.

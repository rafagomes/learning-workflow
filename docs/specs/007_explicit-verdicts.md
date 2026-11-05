# 007 — Explicit verdicts, knowing where you are, and content before questions

Status: implemented in Unreleased

## Problem

Feedback on an answer is soft: "Half right", "Not quite", "Right on both counts". The learner has to read the explanation to find out whether they got it, and a hedge can hide a wrong answer that was scored as wrong. The learner asked: "Be more assertive when you answer: say Correct or INCORRECT, then explain."

The learner also couldn't tell where they were in a lesson or quiz: "we also want more predictability on what we are doing: like question 1/3, and when we start, say it will be intro, deep explanation, time for video, questions, etc."

Two more came from a real lesson. The Mechanism and Watch parts were written as text right before an AskUserQuestion call in the same turn; while the dialog was open the learner saw only the dialog, so they never saw those parts and got only questions. And lessons asked too many questions, sometimes two on the same idea.

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

### Position (shared contract) and roadmap (teach)

- **Counted questions** (a lesson's Check, a quiz, a done-check) give their count in the first question's text (`Check · 3 questions · Question 1/3 · `), and each later question's text starts with `Question 2/3 · `, so no count line is hidden by the dialog. A "why?" follow-up keeps its number; an adaptive follow-up shows the new total in its prefix. Other questions start with what they belong to (`Mechanism · question · `, `Prediction · `). In init next to the verdict rule, restated in build's state-file line.
- **Lesson roadmap** (teach): one line at the start listing the parts that will happen, with the check's count, e.g. `Problem → Intuition → Mechanism → Watch → Lab → In the project → Pitfalls → Vocabulary → Check (3 questions)`; a short lesson lists its own parts. Parts left out: Watch when no video would help or videos are off, In the project with no linked project, a short lesson's Lab unless added. Each part opens with `[3/9 · Mechanism]` and ends with one line on what's next; a changed plan restates the roadmap. Conversation only: `lesson.md` keeps its headings, and the writer's brief says to leave the markers and question prefixes out. A dropped Watch's "No video" line goes in the restated roadmap.
- **Quiz** gives its count in the first question (`Quiz · 10 questions · Question 1/10`); plan mode's first question per item starts `Item 2/4 · <concept> · 4 questions · `; flashcard review says how many cards it will ask (due, at most 20, and how many wait) and numbers them against that, `Card 3/12`. **Build's done-check** says its count first.

### Content before the dialog (shared contract)

- A turn that teaches (an explanation, a table, video links, lab output) ends **without** a dialog, on one line such as "Say *next* when you've read it, or ask anything."
- The question comes in the **next** turn, which only asks it: everything it needs is in the question text and option previews.
- A verdict is content too: it comes first in the next question's text, before the position (`**Incorrect.** <why> · Question 3/10 · `), or opens a teaching turn. Part markers, counts and the answer to a typed "why…?" follow the same split: counts and the Check's marker go in the question text. The plain-text fallback has no dialog, so the rule doesn't apply there.
- Never teaching content and a dialog in the same turn. In init, restated in build's state-file line; teach's writer brief drops a verdict that leads a question.

### Question budget (teach)

- At most one question per lesson part, never two on the same idea; an idea the learner got right is not drilled again. A `deep` lesson adds depth (mechanism, maths, a lab, the next idea), not questions. The lab's question is its prediction. The Check keeps its fixed count.

## Affected files

- `skills/init/SKILL.md`: **Verdict first**, **Position** and **Content before the dialog** bullets; the record and "why?" bullets use the verdict words.
- `skills/teach/SKILL.md`: How to teach, the writer's message and brief, the lesson roadmap and part markers, the question budget.
- `skills/quiz/SKILL.md`: review mode, plan mode, step 3, score.
- `skills/build/SKILL.md`: state-file rule line, predictions, done-check (count and numbering).
- `skills/practice/SKILL.md`: toolchain `none` answer checks.
- `docs/ARCHITECTURE.md`, `docs/SKILLS.md`, `README.md`, `CHANGELOG.md`.

## Verification

1. In `/learn:teach`, `/learn:quiz` and `/learn:build`, every reply to an answer starts with **Correct.**, **Incorrect.** or **Partly correct.**; none starts with "Not quite", "Close" or "Half right".
2. An Incorrect reply names the right answer and why the wrong one was tempting; a Partly correct reply says which part was right and which wasn't.
3. A right pick with a wrong "why?" reason is **Partly correct.**, scored 0.5 in a quiz and a miss in a done-check; a single-part wrong answer is never Partly correct.
4. `lesson.md`, `quiz.md` and the build log record the same verdict word the learner was told, and the quiz score matches them.
5. After `/compact` in build mode, done-check replies still open with the verdict (the state-file line carries the rule).
6. A typed "why is B wrong?" via Other gets an explanation and the question again, with no verdict.
7. A lesson opens with a one-line roadmap that leaves out skipped parts (no Watch when no video, no In the project with no linked project); each part opens with `[n/N · <part>]`; the Check announces its count and numbers each question `Question n/N · `.
8. `/learn:quiz <topic>`'s first question text carries the count and every question is numbered; an adaptive follow-up's prefix shows the new total. Build's done-check does the same, also after `/compact`.
9. In a lesson, no turn has both teaching text and an AskUserQuestion call: each teaching turn ends with a "say next" line, and the following turn only asks, with the data in the question and previews. The same holds in build mode for concept notes and deep dives, also after `/compact`.
10. A lesson asks at most one question per part (the Check excepted), never two on the same idea, and a `deep` lesson doesn't ask more than a short one per part.
11. `bash tests/run.sh` and `claude plugin validate .` pass.

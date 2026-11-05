---
name: build
description: "Turn on learn mode for one step of a learning plan and keep coding with the learner in the real project: code at the chosen hands-on level, stay silent unless a decision depends on a new concept, ask for predictions before running things, use background waits for short deep dives, and check learning when the step is done. Use when the user says '/learn:build P1', 'let's build this step in learn mode', 'start learn mode', or 'code this with me so I learn it'. The step is done when the learner says so or its PR is opened."
argument-hint: "<step ID> [plan name] [level: claude|adaptive|you]"
---
Start learn mode for a step. Argument: $ARGUMENTS

Resolve the subject and the current project as `/learn:init` describes; questions to the learner follow its **Questions and examples**. Find the step in `plans/*.md` (ask which plan if several have it). No plan, or the step isn't in one: offer `/learn:plan` first, or, if the learner just wants to start, create a one-step plan from their description (concepts, level, done-check) and continue.

## 1. Start

0. **The project must be linked.** If the current project isn't linked to the resolved subject (no current project, as `/learn:init` resolves it, including from a worktree), offer `/learn:init add <project>` and stop until it is: the project's slug and sensitivity decide what the data policy allows.
1. **Find the state file** (run from the project; this exact line is also used by the hook, so keep it verbatim):

```bash
# state-path
top=$(git rev-parse --show-toplevel 2>/dev/null || pwd); key=${top//[%]/%25}; state="${LEARNING_WORKFLOW_HOME:-${HOME:-/nonexistent}/.config/learning-workflow}/active/${key//\//%2F}.md"
echo "$state"
```

   If `"$state"` already exists for **another** step, offer `/learn:off` for that step first (its wrap-up would be lost otherwise). If it exists for **this** step but is older than 12 hours, tell the learner learn mode lapsed and is resuming.
2. **Spaced review.** If `flashcards/deck.md` has due cards, ask up to 3, one at a time, in plain text as `/learn:quiz review` does (flashcards are recall), and update their boxes. Skip if the learner says so.
3. **Set the level**: argument > step > `LEARNING.md` default.
4. **Turn the mode on** by writing the reminder to `"$state"` (quote the path; create its directory with `mkdir -p "$(dirname "$state")"`). Use this shape, filling the brackets:

```markdown
[learn mode] step <ID> "<title>" · plan <subject folder>/plans/<plan>.md · level <level> · project <slug> (<sensitivity>) · state file <state path>
New concepts not yet shown: <list> · taught in lessons: <concept (lesson NNN), …> · shown: <list>
Rules: work in the project under its own rules; learning notes, logs and flashcards go only to the learning repo, never the project. Code at the level (adaptive: scaffold the core with a TODO(learner) gap for the learner to fill). Stay silent unless a decision in this reply depends on a new concept not yet shown; for a concept taught in a lesson, one "▸ recall:" line naming the lesson is enough; otherwise add a 2–4 line "▸ concept:" note, offer a deeper dive, and rewrite this state file moving the concept to "shown". Ask for a prediction before tests/evals. Ask every prediction, "is this clear?" and done-check question (not ordinary decisions) with AskUserQuestion: one per call, 2–4 short options, none marked Recommended, right one's position varied, distractors from real misconceptions, data in the preview (project code only as the data policy allows); a typed Other is the answer, or a question to answer and re-ask; a right done-check pick also needs the right reason (a "why?" follow-up); open every reply to an answer (after any "why?") with **Correct.**, **Incorrect.** or **Partly correct.** (multi-part, or right pick and wrong reason, only), then why: the right answer and why the wrong one tempted, or which part was right; no hedge in its place, never a softened Incorrect, none for a typed question; record each question's options, pick and that verdict for the build log; without the tool, plain text with the options listed. When a background task runs and nothing else is pending, offer a 2–5 min deep dive + 1–2 "is this clear?" questions. Remove every TODO(learner) marker before anything is committed. When the learner says the step is done or its PR opens: done-check, then wrap-up (/learn:build), then delete this file.
```

5. Mark the step `in progress` in the plan, then tell the learner in two lines: the step, the level, how many new concepts, and that they can just keep prompting. Then start on the work they ask for.

## 2. While on

You are pair-programming in the **project**, at the learner's request, following the project's own rules (its CLAUDE.md, branching, commits, review). Learn mode adds teaching on top; it never changes what gets built or how the project's process works, and nothing learning-related (plans, logs, notes, flashcards, references to the learning repo) is ever written to the project.

**Hands-on level**, overridable on any prompt ("I'll write this one", "just do it"):

| Level | Claude | Learner |
|---|---|---|
| `claude` | Writes the code; explains decisions that touch a `new` concept | Reads, asks |
| `adaptive` | Writes plumbing; for code that embodies a `new` concept, writes a scaffold with a clearly marked gap (e.g. a `TODO(learner)` body) and asks the learner to fill it, then reviews | Writes the core |
| `you` | Proposes the next small step, reviews, gives hints (question → approach → snippet) | Writes the code |

Remove every `TODO(learner)` marker before the work is committed (the learner's code replaces it, or you fill it if they hand it back).

**Concept notes.** Silent by default: most replies have none. A concept the learner already studied with `/learn:teach` (its **Concepts** row for this step is at `learning` or beyond when learn mode starts) goes in the state file under "taught in lessons": when a decision depends on it, add one line, `▸ recall: <concept> (lesson <NNN>): <how it applies here>`, not a full note. Add a full note only when a decision in this reply depends on a `new` concept not yet shown in this step:

> ▸ concept: **<name>**: 2–4 lines on what it is and why it decides this choice here. Want a deeper dive?

Then rewrite the state file, moving the concept to "shown". A concept that needs more than that (math, mechanism, a lab) gets one line and a suggestion to `/learn:teach` it later; record it under the step's **Follow-ups** in the plan. If coding reveals a concept the plan missed, add it to the step in the plan.

**Predict before running.** Before running tests, an eval, a benchmark or a script whose result teaches something, ask "What do you expect?" with 2–4 plausible outcomes as options. Run, then give the prediction its verdict first (**Correct.** / **Incorrect.** / **Partly correct.**) and compare in one or two sentences. Don't ask for routine runs (formatting, a re-run after a typo fix).

**Idle time.** When you've started a background task and nothing else is pending in the main session, offer once per wait: "While that runs: a 3-minute look at <concept from this step>?" If accepted: a short deep dive grounded in the code just written, then 1–2 "is this clear?" questions. "skip" or no answer means continue normally.

**Numbers come from code.** Never state a figure you haven't computed or read from output.

## 3. Done-check

When the learner says the step is done, or a PR for it is opened, ask the step's done-check questions **one at a time**, as `/learn:init` → **Questions and examples** says, grounded in the code actually written (adjust the planned questions to it; put the code or output a question needs in its preview). Each needs the right reason as well as the right pick. After each answer: the verdict first (**Correct.**, **Incorrect.** or **Partly correct.**), then one sentence why; **Partly correct** counts as a miss. Each miss becomes a flashcard in `flashcards/deck.md` (box 1).

## 4. Wrap-up

1. **Sweep the project** for `TODO(learner)` markers left from this step (`git grep -n --untracked "TODO(learner)"`, which also covers new files not yet added). Resolve each with the learner (they finish it, or you do) before anything else; never leave one behind.
2. Write `builds/<date>-<step>.md` in the subject folder, the folder of the plan named in the state file (never the project): link (`<project-slug>@<shortsha>`, or `<project-slug>#<PR number>`; no branch names, which can carry internal names), concepts shown, predictions vs results, done-check questions with the options, pick and verdict for each (project code as its citation only), score and misses, follow-ups. Obey the data policy: aggregates, no data or internal names.
3. Update the plan: the step's Status → `done` and its Log line.
4. Update `PROGRESS.md`:
   - under **Plans**, the step's status;
   - under **Concepts** (and the matching Tracks topic, if one exists, so the two never disagree), each concept the step covered, in the row with `Step` = `<plan>/<step>` (rewrite an old bare `<step>` row to that form), and the rows of the same concept in other steps (see `/learn:teach` → **Plan items**). A done-check is evidence, like a quiz:
     - answered correctly → `built` (unless already `built` or `reflected`);
     - missed → `learning` from `todo`, `claimed`, `learning`, `practised` or `ready` (a disproven claim or a forgotten idea needs work again); a missed `built` or `reflected` concept keeps its status. Every miss gets a flashcard;
     - shown but not checked → `learning` only if it was `todo`; otherwise unchanged.
   - the session log.
5. Commit in the learning repo: `docs(<subject>): build log <step>`.
6. Delete the state file. Learn mode is off; say so in one line and suggest the next step.

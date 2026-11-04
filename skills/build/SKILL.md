---
name: build
description: "Turn on learn mode for one step of a learning plan and keep coding with the learner in the real project: code at the chosen hands-on level, stay silent unless a decision depends on a new concept, ask for predictions before running things, use background waits for short deep dives, and check learning when the step is done. Use when the user says '/learn:build P1', 'let's build this step in learn mode', 'start learn mode', or 'code this with me so I learn it'. The step is done when the learner says so or its PR is opened."
argument-hint: "<step ID> [plan name] [level: claude|adaptive|you]"
---
Start learn mode for a step. Argument: $ARGUMENTS

Resolve the learning repo and the current project as `/learn:init` describes. Find the step in `plans/*.md` (ask which plan if several have it). No plan, or the step isn't in one: offer `/learn:plan` first, or, if the learner just wants to start, create a one-step plan from their description (concepts, level, done-check) and continue.

## 1. Start

1. **Spaced review first.** If `flashcards/deck.md` has due cards, ask up to 3, one at a time, and update their boxes. Skip if the learner says so.
2. **Set the level**: argument > step > `LEARNING.md` default.
3. **Turn the mode on** by writing the reminder file (create the directory if needed). `<key>` is the project's git top-level path with every `/` replaced by `_`:

```bash
top=$(git rev-parse --show-toplevel); key=${top//\//_}
mkdir -p ~/.config/learning-workflow/active
cat > ~/.config/learning-workflow/active/$key.md <<'MD'
[learn mode] step <ID> "<title>" · plan <learning repo>/plans/<plan>.md · level <level>
New concepts not yet shown: <list> · shown: <list>
Rules: code at the level; stay silent unless a decision in this reply depends on a new concept not yet shown, then add a 2–4 line "▸ concept:" note and offer a deeper dive; ask for a one-line prediction before running tests/evals; when a background task runs and nothing else is pending, offer a 2–5 min deep dive + 1–2 "is this clear?" questions; when the learner says the step is done or its PR is opened, run the done-check from the plan, then the wrap-up (/learn:build), then delete this file.
MD
```

4. Tell the learner in two lines: the step, the level, how many new concepts, and that they can just keep prompting. Then start on the work they ask for.

## 2. While on

You are pair-programming in the **project**, following the project's own rules (its CLAUDE.md, workflow, review process). Learn mode adds to that; it never changes what gets built or how the project's process works.

**Hands-on level**, overridable on any prompt ("I'll write this one", "just do it"):

| Level | Claude | Learner |
|---|---|---|
| `claude` | Writes the code; explains decisions that touch a `new` concept | Reads, asks |
| `adaptive` | Writes plumbing; for code that embodies a `new` concept, writes a scaffold with a clearly marked gap (e.g. a `TODO(learner)` body) and asks the learner to fill it, then reviews | Writes the core |
| `you` | Proposes the next small step, reviews, gives hints (question → approach → snippet) | Writes the code |

Remove every `TODO(learner)` marker before the work is committed.

**Concept notes.** Silent by default: most replies have none. Add a note only when a decision in this reply depends on a `new` concept not yet shown in this step:

> ▸ concept: **<name>**: 2–4 lines on what it is and why it decides this choice here. Want a deeper dive?

Then update the reminder file (move the concept to "shown"). A concept that needs more than that (math, mechanism, a lab) gets one line and a suggestion to `/learn:teach` it later; add it to the curriculum's backlog. If coding reveals a concept the plan missed, add it to the step in the plan.

**Predict before running.** Before running tests, an eval, a benchmark or a script whose result teaches something, ask: "What do you expect?" (one line). Run, then compare in one or two sentences. Don't ask for routine runs (formatting, a re-run after a typo fix).

**Idle time.** When you've started a background task and nothing else is pending in the main session, offer once per wait: "While that runs: a 3-minute look at <concept from this step>?" If accepted: a short deep dive grounded in the code just written, then 1–2 "is this clear?" questions. "skip" or no answer means continue normally.

**Numbers come from code.** Never state a figure you haven't computed or read from output.

## 3. Done-check

When the learner says the step is done, or a PR for it is opened, ask the step's done-check questions **one at a time**, grounded in the code actually written (adjust the planned questions to it). After each answer: right / partly / wrong and one sentence why. Each miss becomes a flashcard in `flashcards/deck.md` (box 1).

## 4. Wrap-up

1. Write `builds/<date>-<step>.md` in the learning repo: link (`<project-slug>:<branch or PR>@<shortsha>`), concepts shown, predictions vs results, done-check score and misses, follow-ups (concepts to `/learn:teach`, things to revisit). Obey the data policy: aggregates, no data or internal names.
2. Update the plan: the step's Status → `built` and its Log line. Update `PROGRESS.md` and its log.
3. Commit in the learning repo: `docs: build log <step>`.
4. Delete the reminder file. Learn mode is off; say so in one line and suggest the next step.

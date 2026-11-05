---
name: reflect
description: "After building a phase in a real project, compare what the learner predicted with what actually happened, capture lessons, and close the loop in the curriculum. Use when the user says 'I shipped X, let's reflect', 'retro on this phase', 'what did I learn building X', or links a merged PR. Writes reflections/<date>-<topic>.md and never edits the project."
argument-hint: "<topic or phase> [PR URL or project commit range]"
---
Reflect on a built phase. Argument: $ARGUMENTS

Resolve the subject and current project as `/learn:init` describes. Before reading anything from the learning repo, pull it as `/learn:init` → **Sync** says.

## 1. Gather

- What was built: read the PR (`gh pr view <url> --json title,body,files`) or `git -C <project> log --stat <range>`. Read-only.
- What was expected: the topic's ready-when, the lesson's predictions, quiz answers, and any numbers the learner predicted.
- Results: metrics, eval output or behaviour the learner reports. Ask for them if missing. Obey the data policy: record aggregate numbers, never records.

## 2. Talk it through

Ask, one at a time:
1. What did you expect, and what happened?
2. Where was the gap biggest, and why do you think it happened?
3. What would you do differently on the next phase?
4. What do you now understand that you didn't before?

Add your own read of the diff: one thing done well, one risk or shortcut worth revisiting, one concept that the code shows is still shaky.

## 3. Write

`reflections/<date>-<topic>.md`: link (PR or `<project-slug>@<range>`), prediction vs result table, the gaps and their causes, follow-ups. Follow-ups that belong in the project are phrased as tasks for the project's own workflow (an issue or spec), not done from here.

Add flashcards for the new understanding, set the phase's topics to `built` (if they aren't already) and then `reflected` in `PROGRESS.md`, add new topics to the curriculum if the build revealed gaps, log, commit `docs(<subject>): reflect on <topic>`, and push as `/learn:init` → **Sync** says.

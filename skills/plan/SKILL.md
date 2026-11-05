---
name: plan
description: "Connect a development plan to a learning plan: split a project's spec, roadmap or goal into steps and, for each step, work out the concepts it needs, which are new to the learner, who writes the code, and the questions that check learning when the step is done. Use when the user says 'plan the learning for this spec', 'what do I need to learn to build X', 'I want to learn while building this', or before /learn:build. Writes plans/<plan>.md in the subject's folder of the learning repo; never edits the project. With the name of an existing plan (or no argument), shows that plan's progress, item by item, and lets the learner continue, recheck an item or build a step."
argument-hint: "<spec path | plan path | artifact URL | goal> [plan name] | <existing plan name>"
---
Build a learning plan linked to a development plan. Argument: $ARGUMENTS

Resolve the subject and the current project as `/learn:init` describes. If there's no subject, offer `/learn:init` and stop. If the dev plan belongs to a project not linked to that subject, offer `/learn:init add <project>` first. Before reading anything from the learning repo, pull it as `/learn:init` → **Sync** says (the plan view too).

**Existing plan, or no argument: show it instead.** When the argument is the name of a file in `plans/` (with or without `.md`), or there's no argument and plans exist, don't build a plan: show one (see **Plan view** at the end). With no argument and several plans, ask which. Anything else builds a new plan as below.

The **development plan stays where it is**: in the project's docs, specs or issues, owned by the team. This skill only reads it, and writes the learning side in the subject's folder of the learning repo. The two are linked by step ID.

## 1. Read the development plan

- A path: read it. A claude.ai artifact URL: use the Artifact tool's `read` action. An issue or PR: `gh`. A plain goal ("build a recommendation feed for the app"): ask 1–2 questions to pin down what will be built, then propose steps for the learner to confirm.
- Keep the plan's own step IDs (`P1`, `Z2`, `Phase 3`, …). If it has none, assign `S1, S2, …` and show the mapping.
- Read the code the steps will touch (read-only) so concepts come from what will actually be written, not from the topic in general.

## 2. Work out what each step needs

For each step, list the 2–6 concepts a competent engineer would need to make its decisions well. Name them precisely ("isotonic calibration of classifier scores", not "ML"). Then mark each:

- `known`: a topic or concept already `ready`, `claimed`, `built` or `reflected` in `PROGRESS.md` (Tracks or Concepts), or the learner confirms it in a quick multi-select (one AskUserQuestion per plan, not per step);
- `new`: everything else.

A `new` concept that is too big for a 2–4 line note while coding (it needs a mechanism, math, or a lab to be understood) is flagged `deep`; suggest a `/learn:teach` session before or during that step.

## 3. Level and checks per step

- **Level**: the subject default from `LEARNING.md` (`claude`, `adaptive` or `you`) unless the learner wants a different one for this step. Suggest `you` or `adaptive` for steps rich in `new` concepts the learner wants to own.
- **Done-check**: 3–5 questions about what this step will produce (why this design, what breaks if…, explain this part, what would you change for 10× data). They must be answerable from the built code, not trivia.

## 4. Write `plans/<plan>.md`

```markdown
# <Plan name>

Dev plan: <project-slug>:<path or issue>@<shortsha> · Created <date>

| Step | What gets built | Level | New concepts | Status |
|---|---|---|---|---|
| P1 | Candidate generation | adaptive | approximate nearest neighbours, recall@k | todo |

Step status: `todo` → `in progress` → `done`.

## P1 · <title>
- **Builds:** one line, from the dev plan.
- **Level:** adaptive
- **Concepts:**
  - `new` approximate nearest neighbours: why: P1 decides which items can ever be recommended.
  - `new` `deep` recall@k: why: the step is done when recall@100 meets the plan's target. Suggest /learn:teach first.
  - `known` vector embeddings
- **Done-check:**
  1. …
- **Follow-ups:** (filled by /learn:build: deep concepts to /learn:teach, things to revisit)
- **Log:** (filled by /learn:build: date, concepts shown, check score)
```

Obey the data policy: for a `work` project, describe steps and concepts in general terms; no data, hostnames or internal names beyond what the citation needs.

## Finish

Update `PROGRESS.md` (under **Plans**: the plan and its steps, `todo`), commit `docs(<subject>): learning plan <plan>` and push as `/learn:init` → **Sync** says, and say how to start: `/learn:teach <plan>` to study its concepts in order, or `/learn:build <first step>` to learn while building; mention any `deep` concepts worth a lesson first.

## Plan view

Read-only: it changes no file. Read `plans/<plan>.md` and the subject's `PROGRESS.md`. Items, their status (including old rows with a bare step ID), **covered** and skipped items are defined in `/learn:teach` → **Plan items**. The step status is from the plan's table.

Print it as a compact text block:

```
<Plan name> · <n> of <total> items covered · <n> ready · <n> skipped · <next step to build, if any>
Z0 · <step title>                                   <step status>
  ✓ learning   zoning vs land use                   lesson 001
  ✓ learning   precision vs recall           deep   lesson 002 · quiz 4/5
  ·  todo      label definition
Z1 · …
Next: <first todo item> (<step>)
```

Marks: `✓` taught (`learning`, `practised`), `★` `ready`, `built` or `reflected` (say which), `·` `todo`, `–` skipped, `○` `known` / `claimed`. "Covered" counts items that are `claimed` or at `learning` or beyond. A step is **ready to build** when all its items are covered. Show the step's done-check score from its **Log** if it was built. `Next:` is the first `todo` item that isn't skipped.

Then ask one question (AskUserQuestion) and act on the answer by invoking that skill with the Skill tool:

- **Continue**: the next `todo` item → `/learn:teach <plan>`.
- **Recheck an item**: ask which item (list the taught ones), then whether to **re-teach** it (`/learn:teach <plan>/<step>/<concept>`) or **quiz** it (`/learn:quiz <plan>/<step>/<concept>`). A whole step can be quizzed too (`/learn:quiz <step>`).
- **Build a step**: say to run `/learn:build <step>` from a session in the project (build mode works in the project, not here).
- **Done**: stop.

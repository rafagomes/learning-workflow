---
name: plan
description: "Connect a development plan to a learning plan: split a project's spec, roadmap or goal into steps and, for each step, work out the concepts it needs, which are new to the learner, who writes the code, and the questions that check learning when the step is done. Use when the user says 'plan the learning for this spec', 'what do I need to learn to build X', 'I want to learn while building this', or before /learn:build. Writes plans/<plan>.md in the learning repo; never edits the project."
argument-hint: "<spec path | plan path | artifact URL | goal> [plan name]"
---
Build a learning plan linked to a development plan. Argument: $ARGUMENTS

Resolve the learning repo and the current project as `/learn:init` describes. If there's no learning repo, offer `/learn:init` and stop.

The **development plan stays where it is**: in the project's docs, specs or issues, owned by the team. This skill only reads it, and writes the learning side in the learning repo. The two are linked by step ID.

## 1. Read the development plan

- A path: read it. A claude.ai artifact URL: use the Artifact tool's `read` action. An issue or PR: `gh`. A plain goal ("build the owner-matching agent"): ask 1–2 questions to pin down what will be built, then propose steps for the learner to confirm.
- Keep the plan's own step IDs (`P1`, `Z2`, `Phase 3`, …). If it has none, assign `S1, S2, …` and show the mapping.
- Read the code the steps will touch (read-only) so concepts come from what will actually be written, not from the topic in general.

## 2. Work out what each step needs

For each step, list the 2–6 concepts a competent engineer would need to make its decisions well. Name them precisely ("isotonic calibration of classifier scores", not "ML"). Then mark each:

- `known`: already `ready`, `claimed`, `built` or `reflected` in `PROGRESS.md`, or the learner confirms it in a quick multi-select (one AskUserQuestion per plan, not per step);
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
| P1 | Candidate blocking | adaptive | blocking keys, recall@k | todo |

## P1 · <title>
- **Builds:** one line, from the dev plan.
- **Level:** adaptive
- **Concepts:**
  - `new` blocking keys and candidate generation: why: P1 decides which pairs are ever compared.
  - `new` `deep` recall@k: why: the exit criterion is recall@20 ≥ 99%. Suggest /learn:teach first.
  - `known` hash joins
- **Done-check:**
  1. …
- **Log:** (filled by /learn:build: date, concepts shown, check score)
```

Obey the data policy: for a `work` project, describe steps and concepts in general terms; no data, hostnames or internal names beyond what the citation needs.

## Finish

Update `PROGRESS.md` (plan listed, steps `todo`), commit `docs: learning plan <plan>`, and say how to start: `/learn:build <first step>`; mention any `deep` concepts worth a `/learn:teach` first.

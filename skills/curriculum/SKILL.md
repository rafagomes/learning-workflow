---
name: curriculum
description: "Build a learning track from a project plan, spec, design doc, claude.ai artifact or plain topic: phases, topics, prerequisites, and a concrete 'ready when' per topic, mapped to what the learner will build. Use when the user says 'make a curriculum for X', 'what do I need to learn to build this', 'turn this plan into lessons', or starts learning a new area. Writes curriculum/<track>.md in the learning repo."
argument-hint: "<plan path | artifact URL | spec | topic> [track name]"
---
Build a learning track. Argument: $ARGUMENTS

Resolve the learning repo and the current project as `/learn:init` describes. If there's no learning repo, offer `/learn:init` and stop.

## 1. Read the source

- A file path: read it. A claude.ai artifact URL: read it with the Artifact tool's `read` action. A spec, issue or PR: read it with the tools that fit (`gh` for GitHub).
- A plain topic: ask what the learner wants to be able to *do* with it, one AskUserQuestion with 2–4 concrete outcomes.
- If the source belongs to a `work` project, keep the track's wording generic enough to obey the data policy: name techniques and the plan's phase names, not its data.
- With no plan at all ("I want to learn Python"), build the track from the outcomes the learner picked, ordered from fundamentals to the first thing they can build.

## 2. Find the gaps

Read `LEARNING.md` (profile) and `PROGRESS.md` (what's already `ready`). Ask a short self-assessment (one AskUserQuestion, multiSelect) listing the 6–10 load-bearing concepts the source depends on: "Which of these could you explain to a colleague today?" Ticked items get status `claimed`: they count as met prerequisites, and get a quiz instead of a lesson (`claimed` → `ready` on a pass, → `todo` on a fail).

## 3. Write the track

`curriculum/<track>.md`:

```markdown
# <Track title>

Source: <path, URL or topic> · Built from: <project-slug>@<shortsha> (if any) · Created <date>

## Goal
One paragraph: what the learner will be able to build or judge at the end.

## Map
| # | Phase (from the source) | Topic | Needs | Status |
|---|---|---|---|---|
| 1 | Phase 1: CLI skeleton | Ownership and borrowing | — | todo |
| 2 | Phase 1: CLI skeleton | Error handling with `Result` and `?` | 1 | todo |

## Topics
### 1. <Topic>
- **Why it matters here:** the decision in the source that depends on it.
- **Ready when:** 2–3 observable abilities ("can explain why this borrow fails to compile and fix it two ways", "scores ≥ 80% on the quiz").
- **Lab idea:** the smallest runnable experiment (or worked problem, for subjects without code) that shows it.
- **Project touchpoint:** `<project-slug>:path` the learner will meet it in (read-only); omit when no project is linked.
- **Reading:** 1–3 primary sources (papers, official docs, a textbook chapter). No listicles.
```

Rules:
- Order by dependency, then by the source's phases. Every topic serves a phase; drop interesting-but-unused material.
- 5–15 topics per track. If more, split into tracks by phase.
- Each "ready when" must be checkable by `/learn:quiz` or `/learn:practice`.
- Reading links must be real; cite only sources you can name precisely (title, author, year or official doc URL).

## 4. Record

Add the track to `PROGRESS.md` (`## Tracks` with a row per topic and its status), log the session, commit `docs: add <track> curriculum`. Tell the learner the first topic and the command: `/learn:teach <track>/<topic-number>`.

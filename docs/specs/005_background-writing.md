# 005 — Teaching in the foreground, writing in the background

Status: implemented in Unreleased

## Problem

`/learn:teach` writes `lesson.md` part by part, then the flashcards, the `PROGRESS.md` rows, the log line and a commit. All of it happens in the conversation, so the learner waits for file edits between questions and at the end of every lesson before the next one starts. Research at lesson start (videos, reading the linked project's code) has the same effect. Each write also puts file contents into the main context, which fills faster and makes long plan walks slow.

## Design

The main conversation only teaches: it explains, asks, reacts to answers and runs the lab with the learner (predict, then run). Background agents do the rest. Without the Agent tool and SendMessage, or once a background agent can't write or run git (a denied permission), the skill writes inline as before, in the same order.

**Research at lesson start.** In parallel, in background agents:
- the video search (spec 004), given only the general field term and the checks;
- a code reader for **In the project**, given the project's path, the concept in general terms and the data policy. It returns only `path:start-end@shortsha` ranges with a line on what each shows, never data, secrets or hostnames.

The main context teaches the problem and intuition meanwhile. It re-reads every cited range itself before teaching it, because a summary can be wrong: in a real lesson a file's header comment contradicted the code below it, and only reading the code caught it.

**One writer per session.** A single background agent writes everything in the learning repo: `lesson.md` part by part, flashcards, `PROGRESS.md` (including skip rows) and the one commit per lesson. It is started at the first lesson and continued with SendMessage. After each part the main context sends it the part as taught (explanation, worked example, quoted lab output, questions, the learner's answers and how they did) and goes on teaching without waiting. A skip is sent the same way and committed on its own (`docs(<subject>): skip <concept>`), so stopping right after a skip loses nothing.

Reusing one writer, rather than starting one per lesson, is the simplest rule that keeps writes safe: messages are handled in order, the writer commits a lesson before acting on anything about the next, so two commits never run at once and nothing else touches the repo's files or git. The plan walk moves to the next item at once; the previous lesson's commit lands meanwhile. As a second guard, the writer stages only the lesson's paths (`lessons/<NNN>-<slug>/`, `flashcards/deck.md`, `PROGRESS.md`) and reports changes it didn't make instead of committing them. The main context tracks what this session taught and skipped itself, to pick the next item and lesson number, because `PROGRESS.md` may lag behind the writer.

**Nothing else writes until the last sha is in.** Before another `/learn` skill runs (the suggested `/learn:practice` or `/learn:quiz` also write the deck, `PROGRESS.md` and lesson folders), before the session ends, and before a replacement writer starts (for instance when `/compact` lost the writer's ID), the main context waits for the writer's last sha. If the writer reports an error, it has stopped: the main context sends it nothing more, fixes the error inline and writes inline for the rest of the session, so two writers never share the index.

**The writer's brief.** It has a fresh context, so the brief carries: the subject folder's absolute path; per lesson, its number, slug and parts in order; the data policy as the subject's `LEARNING.md` records it (from the shared contract in `skills/init/SKILL.md`: for `work`, paraphrase, cite `slug:path@sha`, quote a few lines at most, never data, real-valued schemas, secrets, internal URLs or hostnames; for `personal`, code may be quoted, data stays out), with each linked project's slug and sensitivity; the Finish rules and the Plan items rules they rely on; the card format in `flashcards/deck.md`; the commit messages; the commit rule from `/learn:init`, narrowed to the commit's own paths (no run artefacts); and the rule that **it never invents content**: it writes only what it was sent, reworded at most, with no number it wasn't given. After each commit it reports the short sha in one line; on any error it reports it and stops. The main context says `Lesson 012 saved · a1b2c3d` when a sha arrives.

**The lab.** The main context writes the lab file itself in the lesson folder, so what runs is exactly what it wrote, and runs it live. The writer commits it with the lesson, without run artefacts.

**Context between lessons.** A skill can't run `/compact` or `/clear`: the skills docs (code.claude.com/docs/en/skills, "Restrict Claude's skill access") say built-ins such as `/compact` aren't available through the Skill tool, and no hook output field starts a compaction. Since all state is in the repo, the skill suggests it instead: after a lesson's sha is confirmed and when the conversation is long (several lessons in, or after a lab with long output), one line says everything is saved and offers `/compact`, or `/clear` then `/learn:teach <plan>`, which resumes at the next item. At most once per lesson, never mid-lesson. Because the writer keeps file contents and git output out of the main context, the context also grows more slowly, so the suggestion is needed less often.

## Affected files

- `skills/teach/SKILL.md`: new **Teaching and writing in parallel** section; Lesson structure, Short lesson, Videos and Finish point to the writer.
- `docs/SKILLS.md`, `README.md`, `docs/ARCHITECTURE.md`, `docs/WORKFLOW.md`: how teach writes.
- `CHANGELOG.md`: Unreleased → Changed (background writing) and Added (the `/compact` suggestion).

## Verification

1. `/learn:teach <plan>` with the Agent tool: between questions, the main conversation makes no Write/Edit/git call on `lesson.md`, the deck or `PROGRESS.md`; a background writer does, and `lesson.md` contains only what was taught.
2. At the end of a lesson, the next item starts before the commit lands; a line `Lesson <NNN> saved · <sha>` appears, and `git log` shows one `docs(<subject>): lesson <NNN> <topic>` commit per lesson, each containing only that lesson's paths plus the deck and `PROGRESS.md`.
3. Two lessons in a row never produce overlapping commits (no `index.lock` error), and the second lesson's file never lands in the first lesson's commit.
4. A lesson with a linked project: the code reader returns ranges with `@sha`; the main context reads those lines before the In the project part; nothing quoted breaks the data policy.
5. Stopping mid-plan: the session ends only after the last sha is reported; `/learn:teach <plan>` in a fresh session resumes at the next item.
6. After a long session (several lessons in), one line suggests `/compact` or `/clear` + `/learn:teach <plan>`, only after a sha, never mid-lesson, at most once per lesson.
7. With the Agent tool unavailable, or the writer denied Write or git, the lesson is written and committed inline as before.
8. A skip followed by stopping: a `docs(<subject>): skip <concept>` commit exists. Accepting the suggested `/learn:quiz` right after a lesson: quiz starts only after the lesson's sha is shown.
9. A concept listed under two steps: after teaching it in the first, the walk passes over the second even if `PROGRESS.md` hasn't been updated yet.
10. `bash tests/run.sh` and `claude plugin validate .` pass.

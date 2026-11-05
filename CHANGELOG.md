# Changelog

All notable changes are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Changed

- `/learn:teach` keeps the conversation on teaching. A background writer agent, reused for the session, records each lesson part as it's taught, then adds the flashcards, updates `PROGRESS.md` and makes the one commit per lesson; Claude shows its sha in one line and moves to the next item without waiting. It writes only what it was sent, stages only that commit's paths, commits skips on their own, and nothing else writes to the learning repo until its last sha is in (another `/learn` skill waits for it). It falls back to inline writing if it can't write. Video search and reading the linked project's code run in background agents at lesson start; Claude re-reads every cited line before teaching it. Without the Agent tool, lessons are written inline as before.

### Added

- After a lesson is saved in a long session, `/learn:teach` suggests `/compact`, or `/clear` then `/learn:teach <plan>` to resume at the next item (a skill can't run either itself). At most once per lesson, never mid-lesson.

## [0.4.0] - 2026-11-04

### Added

- Lessons can include a **Watch** part: one or two free videos of about 15 minutes or less (or a timestamped segment of a longer one) on the concept and a bit more. Claude finds them with web search, checks the title, channel and length before showing them, never invents a link, and leaves the part out when a video wouldn't help (or says "No video" in one line when one would but none qualifies). Searches use general terms only, never project names; turn videos off per subject with `Videos in lessons: off` in `LEARNING.md`.

## [0.3.0] - 2026-11-04

### Added

- Study a learning plan in order: `/learn:teach <step>` teaches a plan step's concepts (`/learn:teach Z0`), `/learn:teach <plan>` walks the whole plan one concept per lesson and resumes where you stopped, `/learn:teach` alone asks which plan or track to continue. Non-`deep` concepts get a short lesson. `/learn:quiz` accepts steps, plans and single concepts. `/learn:plan <existing plan>` shows the plan as a checklist (taught, ready, todo) and offers continue, recheck a concept (re-teach or quiz) or build a step. Status lives in `PROGRESS.md` → Concepts; build mode recalls taught concepts in one line.

## [0.2.0] - 2026-11-04

### Changed

- One learning repo for every subject: `/learn:init <subject>` creates the learning repo the first time (default `~/Learning`, with a `README.md` subject index, shared `CLAUDE.md`, `.gitignore` and guard) and adds each subject as its own folder (`<subject>/LEARNING.md`, `PROGRESS.md`, `curriculum/`, `lessons/`, …). Skills resolve the **subject** from the nearest `LEARNING.md` and commit with a subject scope (`docs(<subject>): …`). The registry gains a top-level `repo`. Templates split into `templates/repo/` and `templates/subject/`.
- The guard allows exercise data and lesson SQL only under `<subject>/lessons/` of a folder with a `LEARNING.md`, blocks embedded git repos, and points blocked data to `<subject>/scratch/`.

### Added

- `/learn:init migrate [path]`: folds a v0.1.0 one-repo-per-subject learning repo into the learning repo as a subject folder, keeping its git history; the old repo is deleted only on confirmation. Standalone repos keep working until migrated.

## [0.1.0] - 2026-11-04

### Added

- `learn` plugin with nine skills: `init`, `plan`, `build`, `off`, `curriculum`, `teach`, `practice`, `quiz`, `reflect`.
- Build mode: learn while coding in a real project. `/learn:plan` links a dev plan to a learning plan by step ID; `/learn:build` pair-programs at a hands-on level (`claude`/`adaptive`/`you`), adds concept notes only when a decision needs them, asks for predictions, offers deep dives during background waits, and runs a done-check and wrap-up when the step is done. A `UserPromptSubmit` hook keeps the mode alive across prompts and compaction.
- Learning repos per subject, linking any number of projects (`work` or `personal`) read-only, with a registry at `~/.config/learning-workflow/spaces.json`.
- Toolchain-agnostic labs and exercises: run and test commands recorded per learning repo, defaults for Python, JS/TS, Rust, Go, Java/Kotlin, C/C++, SQL, shell, and `none` for subjects without code.
- Learning-repo templates and a pre-commit guard against data files, large files and secrets.
- Docs: workflow, architecture, skills reference, data policy, examples, FAQ.
- CI: manifest and frontmatter checks, guard behaviour tests, shellcheck.

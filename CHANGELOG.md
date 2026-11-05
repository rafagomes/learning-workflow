# Changelog

All notable changes are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.8.0] - 2026-11-05

### Added

- The learning repo syncs like a notes vault. When it has a remote, every `/learn` skill pulls it (`git pull --rebase`) before reading anything and pushes after every commit, so each machine and session works on the latest lessons and progress. With uncommitted changes in the learning repo, the skill shows them and asks: commit them first, or continue without pulling. A conflict is never resolved for you: the rebase is aborted and brought to you. A rejected push is retried once after a rebase; offline, the skill says so in one line and the next session pushes. Nothing ever force-pushes. Without a remote, nothing changes and nothing nags. The learn-mode hook never syncs, so prompts stay fast.
- `/learn:init remote` gives an existing learning repo a private GitHub remote. On another machine, give `/learn:init` a clone of the learning repo as the location and it registers the repo and its subjects instead of refusing the folder.

### Changed

- `/learn:init` now recommends a private GitHub remote when it creates the learning repo (still only after you confirm; local-only stays a valid choice). If the name is taken on your account, it asks whether to pick another name or rename the existing repo, checking first whether the rename would break a GitHub Pages site, base paths, workflows or webhooks. The learning repo never takes a renamed repo's old name, so GitHub's redirect keeps working.
- New learning repos' `CLAUDE.md` carries the sync rule, so sessions opened in the learning repo without a skill pull, push and never force-push too. An existing learning repo can copy the **Sync** line from `skills/init/templates/repo/CLAUDE.md`; the skills follow the rule either way.

## [0.7.0] - 2026-11-04

### Changed

- Verdicts come first. Every reply to your answer (lesson predictions and checks, quiz questions and flashcards, build mode's predictions and done-check) opens with **Correct.**, **Incorrect.** or **Partly correct.**, then explains: for Incorrect, the right answer and why the wrong one was tempting; for Partly correct, which part was right and which wasn't. Partly correct is only for a multi-part answer or a right pick with the wrong reason, never a softened Incorrect, and no "not quite" or "close" replaces the verdict. A question that needs the right reason gets its one verdict after the "why?" follow-up. Lessons, `quiz.md` and build logs record the same word, and it's what the score counts.
- You always know where you are. A lesson opens with a one-line roadmap of its parts (only the ones that will happen, with the check's question count), each part opens with its position (`[3/9 · Mechanism]`) and ends with a line on what's next. A lesson check, quiz or done-check gives its count in its first question (`Check · 3 questions · Question 1/3`) and numbers each one; other questions name their part (`Mechanism · question`). Flashcard reviews count cards (`Card 3/12`), and plan quizzes number items (`Item 2/4`).
- You see the content before you're asked about it. An open question dialog can hide the text written above it in the same turn, which once hid a lesson's whole Mechanism and Watch parts. Now a turn that teaches (an explanation, a table, video links, lab output) ends with "say *next* when you've read it", and the question comes alone in the next turn with everything it needs in its text and previews.
- Fewer, better questions in lessons: at most one per part, never two on the same idea, and none on an idea you've already got right. A `deep` lesson adds depth (mechanism, maths, a lab), not questions. The check keeps its count.

## [0.6.0] - 2026-11-04

### Changed

- Questions are picked, not typed. Every question a study skill asks you to answer (lesson predictions and checks, quiz questions, build mode's predictions and done-check) is one question prompt with 2–4 short options: none marked recommended, the right one's position varied, distractors drawn from real misconceptions. Type your own answer or a "why…?" via Other. Any table or snippet the question needs is shown beside the options, and your pick and its verdict are recorded in the lesson, quiz or build log. Explain, choose-and-justify and critical quiz questions, and every done-check question, also need the right reason (a "why?" follow-up), so a lucky pick can't make a topic ready or a concept built. Flashcards, hints and reflect's open questions stay plain text. Without the prompt (headless), questions are plain text.
- Examples carry their own data. A question never points back to "the table from earlier": building on an example re-shows the whole table with the new columns, a concept that doesn't need it gets a fresh example, each lesson opens with its own, and examples stay at 6 rows or fewer.

## [0.5.0] - 2026-11-04

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

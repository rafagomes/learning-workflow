# FAQ

**Is this for learning AI?**
No. It's a learning workflow that uses an AI (Claude Code) as the tutor. The subject can be anything: a programming language, a framework, maths, system design, or something with no code at all.

**How do I turn learn mode on and off?**
Learn mode is per step of a plan. `/learn:build <step>` turns it on for the project you're in, and it stays on across prompts (and survives context compaction) until you finish the step: you say it's done or its PR is opened, the done-check runs, the wrap-up is saved, and the mode turns off. `/learn:off` stops it early. No learn-mode state is written to the project: it's a small file in `~/.config/learning-workflow/active/` (or `$LEARNING_WORKFLOW_HOME/active/`) that a plugin hook reads, and refreshes, on each prompt. After 12 hours without a prompt it's ignored; the next `/learn:build` for that step tells you it lapsed and resumes it. Without learn mode, the plugin does nothing until you run a `/learn:` command or ask something like "teach me X properly".

To keep the skills from triggering at all in one project, set `"enabledPlugins": {"learn@learning-workflow": false}` in that project's `.claude/settings.local.json`. To turn the plugin off everywhere: `claude plugin disable learn@learning-workflow`.

**Build mode or the study loop?**
Use build mode when you have real work to do and want to learn what it needs as you go. Use the study loop for foundations you want before starting, or for a `deep` concept that build mode flagged. They share one learning repo, deck and progress file.

**I don't know what I need to learn for this work.**
That's what `/learn:plan` is for. Point it at the spec, plan or goal; it reads the code the steps will touch and lists, per step, the concepts a competent engineer would need. A quick self-check marks which ones are new to you. Gaps found while coding are added to the plan as you go.

**Will learn mode slow down the work?**
Rarely. It's silent by default: a concept note appears only when a decision depends on something new to you, and deeper dives are offers, not interruptions. Background waits are the natural time for them. At level `claude`, delivery speed is about the same as without the plugin.

**Do I need a project?**
No. `/learn:init <subject>` with no paths creates a learning repo for the subject alone, and `/learn:curriculum` can build a track from a goal in plain words. Linking projects makes lessons concrete, but it's optional.

**Can one learning repo serve several projects?**
Yes. A learning repo is per **subject** and links any number of projects (`/learn:init add <path>`). Lessons can draw on whichever one illustrates the idea best.

**Will it touch my project?**
The study skills never do: they only read. Build mode codes in your project because you asked it to, following the project's own rules, exactly like a normal Claude Code session. What it never does, in any mode, is write learning material (plans, logs, notes, flashcards), learn-mode state, leftover `TODO(learner)` scaffolds, or any reference to the learning repo into the project.

**Can I use it on my employer's code?**
Link the project as `work` (the default for organisation-owned repos). Lessons cite and paraphrase rather than paste, no project data is committed, and the guard blocks data files and secrets. Keep the learning repo private. Check your employer's policy on using AI tools with their code first; the plugin can't do that for you. See [DATA-POLICY.md](DATA-POLICY.md).

**Which languages work for labs and exercises?**
Any language that has a run command and a test command. [toolchains.md](../skills/init/toolchains.md) has defaults for Python, JS/TS, Rust, Go, Java/Kotlin, C/C++, SQL and shell, plus `none` for subjects without code.

**How is this different from asking Claude to explain something?**
Explanations alone fade. Here the order comes from what you're about to build. You predict before you run, you're checked with tests and quizzes, readiness is gated, ideas come back on a spaced-repetition schedule, and everything is kept in git. See [WORKFLOW.md](WORKFLOW.md).

**Does it cost anything beyond Claude Code?**
No. There are no extra services or APIs; labs run on your machine with your toolchain.

**Where's my progress?**
`PROGRESS.md` in the learning repo has a status per topic and a session log. `git log` is the full history.

**Can I skip a lesson for something I already know?**
Yes. The curriculum's self-assessment marks known topics, and they get a quiz instead of a lesson. During a lesson, say you know a part; one check question confirms it and the lesson moves on.

**Why Leitner boxes and not SM-2/FSRS?**
Leitner is simple enough to live in a Markdown file you can read and edit, and it's good enough for a personal deck. A smarter scheduler is a welcome contribution if it stays plain-text.

**Can I make my learning repo public?**
Yes, if it links only `personal` projects and you've checked its history. See [DATA-POLICY.md](DATA-POLICY.md#publishing-a-learning-repo).

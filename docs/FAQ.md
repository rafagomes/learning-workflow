# FAQ

**Is this for learning AI?**
No. It's a learning workflow that uses an AI (Claude Code) as the tutor. The subject can be anything: a programming language, a framework, maths, system design, or something with no code at all.

**Do I need a project?**
No. `/learn:init <subject>` with no paths creates a learning repo for the subject alone, and `/learn:curriculum` can build a track from a goal in plain words. Linking projects makes lessons concrete, but it's optional.

**Can one learning repo serve several projects?**
Yes. A learning repo is per **subject** and links any number of projects (`/learn:init add <path>`). Lessons can draw on whichever one illustrates the idea best.

**Will it touch my project?**
No. Linked projects are read-only from every skill. The plugin never edits, commits to, branches or opens PRs in them, and they never reference the learning repo.

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

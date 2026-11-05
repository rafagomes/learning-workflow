# Learning repo

This is a private learning repo managed by the `learn` plugin. It holds every subject the learner studies, one folder per subject (`<subject>/`), listed in `README.md`. Shared tooling (`tools/`, `.gitignore`) sits at the root; everything else belongs to a subject.

Work inside a subject folder. Read its `LEARNING.md` first: it lists the learner profile, the toolchain, the linked projects and the data policy for that subject. All subject paths (`curriculum/`, `lessons/`, `PROGRESS.md`, …) are relative to that folder.

## Rules

- From this repo, linked projects are **read-only**: never edit, commit, branch or open PRs in them from a study session. Cite code as `<slug>:path@shortsha`. (Coding in a project happens only in build mode, started from the project with `/learn:build`, under that project's own rules.)
- Follow the subject's data policy in its `LEARNING.md` strictly. Real data goes only in `<subject>/scratch/` (gitignored). Exercises generate seeded synthetic data.
- Keep subjects apart: a subject's files live only in its folder. Add a subject with `/learn:init <subject>`, which also adds its row to `README.md`.
- Never state a number you haven't computed: run the lab or a snippet and quote its output.
- Teach one concept at a time and check understanding before moving on. Ask the learner to predict before running anything.
- Labs and exercises use the toolchain in the subject's `LEARNING.md` (its run and test commands). Pin dependency versions and seed anything random.
- Update the subject's `PROGRESS.md` at the end of every session; commit with conventional messages scoped by subject (`docs(<subject>): …`, `feat(<subject>): …`, `chore(<subject>): …`).
- **Sync.** This repo is edited from several machines and sessions. At session start, if the branch has an upstream, `git pull --rebase` before reading anything; with uncommitted changes, don't pull over them: show them and ask whether to commit them first or continue without pulling. Push after every commit. Never force-push. A conflict: `git rebase --abort` and bring it to the learner; offline: say so and work locally (the next session pushes). No upstream: skip syncing; `/learn:init remote` adds a private remote.
- The pre-commit guard runs through `git config core.hooksPath tools/hooks`. If `git config core.hooksPath` doesn't print `tools/hooks` (e.g. on a fresh clone), set it before committing.

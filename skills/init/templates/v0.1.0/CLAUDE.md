# Learning repo

This is a private learning repo managed by the `learn` plugin. Read `LEARNING.md` first: it lists the learner profile, the linked projects and the data policy.

## Rules

- From this repo, linked projects are **read-only**: never edit, commit, branch or open PRs in them from a study session. Cite code as `<slug>:path@shortsha`. (Coding in a project happens only in build mode, started from the project with `/learn:build`, under that project's own rules.)
- Follow the data policy in `LEARNING.md` strictly. Real data goes only in `scratch/`. Exercises generate seeded synthetic data.
- Never state a number you haven't computed: run the lab or a snippet and quote its output.
- Teach one concept at a time and check understanding before moving on. Ask the learner to predict before running anything.
- Labs and exercises use the toolchain in `LEARNING.md` (its run and test commands). Pin dependency versions and seed anything random.
- Update `PROGRESS.md` at the end of every session; commit with conventional messages (`docs:`, `feat:`, `chore:`).
- The pre-commit guard runs through `git config core.hooksPath tools/hooks`. If `git config core.hooksPath` doesn't print `tools/hooks` (e.g. on a fresh clone), set it before committing.

# learning-workflow

This repo is the `learn` Claude Code plugin: the learning **workflow** only. It must never contain lessons, learner progress, or anything from a real project; those belong in learning repos created by `/learn:init`.

## Layout

- `.claude-plugin/`: `plugin.json` (plugin `learn`) and `marketplace.json` (marketplace `learning-workflow`).
- `skills/<name>/SKILL.md`: one skill per directory; frontmatter `name`, `description` with trigger phrases, `argument-hint`.
- `skills/init/templates/`: files copied into a new learning repo. `skills/init/toolchains.md`: default run/test commands.
- `docs/`: WORKFLOW, ARCHITECTURE, SKILLS, DATA-POLICY, EXAMPLES, FAQ.
- `tests/`: shell checks run by CI.

## Rules

- The shared contract (learning-repo resolution, current project, data policy) is defined only in `skills/init/SKILL.md`. Change it there and check every skill and `docs/ARCHITECTURE.md` still agree.
- Skills stay subject-agnostic (use the recorded toolchain, never assume a language) and project-agnostic (no real employer, client or project names).
- A behaviour change updates `README.md`, `docs/SKILLS.md`, `docs/WORKFLOW.md` when the loop changes, and `CHANGELOG.md`.
- Before committing: `bash tests/run.sh` and `claude plugin validate .`.
- Conventional commits.

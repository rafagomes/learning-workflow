# Contributing to learning-workflow

Thanks for helping. This guide covers issues, ideas and changes.

## Reporting bugs

Open a [bug report](https://github.com/rafagomes/learning-workflow/issues/new?template=bug_report.md) with what happened, what you expected, the steps (which `/learn:` command, which subject and toolchain), and your environment.

## Suggesting features

Open a [feature request](https://github.com/rafagomes/learning-workflow/issues/new?template=feature_request.md). Toolchain additions are especially welcome: give the subject, the run command and the test command.

## Making changes

```bash
git clone https://github.com/<you>/learning-workflow.git
cd learning-workflow
git checkout -b feat/<slug>
```

Try your change in a real session, with a throwaway learning repo:

```bash
claude --plugin-dir .
# then: /learn:init demo-subject   (choose a location under /tmp)
```

Run the checks before opening a PR:

```bash
bash tests/run.sh            # manifests, frontmatter, guard and hook behaviour, home-path/email scan
claude plugin validate .
```

### Rules for skills

- **Subject-agnostic.** Nothing may assume a language, field or tool beyond the learning repo's recorded toolchain. Examples should vary subjects.
- **Project-agnostic.** No real employer, client or project names, paths or data anywhere in this repo.
- **One contract.** Learning-repo resolution, current-project resolution and the data policy live in `skills/init/SKILL.md`. Other skills refer to them; they don't restate them.
- **Projects stay clean.** Study skills only read linked projects. Build mode (`build`, `off`) may code in the project at the learner's request, under the project's own rules, but must never leave learning artefacts, learn-mode state, `TODO(learner)` scaffolds or references to the learning repo there.
- **Frontmatter**: `name`, `description` (with trigger phrases), `argument-hint`.

A behaviour change updates `README.md` (skill table), `docs/SKILLS.md`, `docs/WORKFLOW.md` when the loop changes, and `CHANGELOG.md`.

### Diagrams

The README and WORKFLOW diagrams are SVGs generated in light and dark versions by `docs/diagrams/render.py` (no dependencies). Edit the script, run `python3 docs/diagrams/render.py`, and commit the script and the SVGs together; `tests/run.sh` fails if they drift. Other diagrams are Mermaid, styled with the same `classDef` palette.

### Commits and PRs

[Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, `ci:`), split by concern, each leaving the plugin working. One concern per PR. The PR template asks for the why, the decisions and how to verify.

## Code of Conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md).

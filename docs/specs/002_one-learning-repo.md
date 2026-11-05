# 002 — One learning repo, one folder per subject

Status: implemented in Unreleased

## Problem

`/learn:init <subject>` creates a separate git repo for every subject (`~/Learning/python`, `~/Learning/rust`, …). A learner who studies several subjects ends up with several repos, each with its own copy of the guard, `.gitignore` and `CLAUDE.md`, its own hook setup after every clone, and its own remote to create. They want **one** private learning repo that holds every subject in its own folder, organised the same way each time.

## Design

### Layout

```
~/Learning/                  the learning repo (one per learner, one git repo)
├── README.md                index of subjects (one row each)
├── CLAUDE.md                rules for any Claude session in the repo
├── .gitignore
├── tools/guard.sh, tools/hooks/pre-commit
└── <subject>/               one folder per subject, e.g. machine-learning/
    ├── LEARNING.md          profile, toolchain, linked projects, data policy
    ├── PROGRESS.md
    ├── curriculum/  plans/  builds/  lessons/  reflections/
    ├── flashcards/deck.md
    └── scratch/             gitignored
```

Everything a subject owns stays in its folder; only the shared tooling sits at the root.

### Terms

- **Learning repo**: the single git repo above.
- **Subject**: one folder in it, identified by the `LEARNING.md` it holds. Every path a study skill writes (`curriculum/…`, `lessons/…`, `PROGRESS.md`, …) is relative to the resolved subject folder. Commits are made in the learning repo and scoped by subject: `docs(<subject>): …`.

### Resolution

Unchanged in shape, now resolving the **subject**: nearest `LEARNING.md` in the current directory or an ancestor → registry subjects whose linked projects contain the current directory (ask if several) → the only registered subject → ask. A project can be linked to several subjects; resolution then asks which.

### Registry

`spaces.json` gains a top-level `"repo"` (absolute path of the learning repo). Each entry in `spaces` is a subject; its `path` is the subject folder. An entry whose folder is its own git root is a **standalone** repo from v0.1.0, wherever it sits; skills keep working with it (its `LEARNING.md` resolves the same way) and `/learn:init` offers to migrate it.

### `/learn:init`

- `/learn:init <subject> [projects…]`: if the registry has no `repo`, ask where to create it (default `~/Learning`, never inside a project). The location must be missing or empty; v0.1.0 repos inside it (the old default was `~/Learning/<slug>`) are first moved to `<location>.v0/`, and anything else stops for another location. Then create the root files, `git init`, enable the hook. Slugs are `^[a-z0-9][a-z0-9-]*$`, not `tools`, and not ignored by the root `.gitignore`. Then add `<subject>/` from the subject templates, add a row to `README.md`, register the subject, commit `chore(<subject>): add subject`. A subject folder that already exists is never overwritten.
- `/learn:init add <project>`: unchanged, against the resolved subject.
- `/learn:init migrate [<path>]`: fold a standalone v0.1.0 repo into the learning repo as `<slug>/`, **keeping its history**, with a subtree merge (fetch into a temporary ref, `merge -s ours --allow-unrelated-histories --no-commit`, `read-tree --prefix=<slug>/ -u`), drop its own `tools/`, `.gitignore` and `CLAUDE.md` (the root ones apply) but keep the learner's additions to them as slimmed `<slug>/.gitignore` / `<slug>/CLAUDE.md`, repoint active learn-mode state files, copy its `scratch/` across, update the registry entry's `path`, and add the README row. The standalone repo is left untouched; deleting it is offered, never done without confirmation. Refuses if either repo has uncommitted changes, or if the old repo has other branches or stashes the learner hasn't agreed to leave behind, or `<slug>/` exists and is not the standalone repo itself. When the standalone repo sits inside the chosen learning repo location (e.g. at `<repo>/<slug>`), it is first moved aside to `<old>.v0`, so creating the learning repo doesn't commit it as an embedded repo.

### Guard

Exercise data and lesson SQL are allowed only in a subject: `^[^/]+/lessons/[^/]+/exercises/[^/]+/data/` and `^[^/]+/lessons/.+\.sql$`, where the top-level folder has a `LEARNING.md` in the index. Embedded git repos are blocked. The block message points to `<subject>/scratch/`.

### Templates

`templates/` splits into `templates/repo/` (`README.md`, `CLAUDE.md`, `gitignore`, `tools/`) and `templates/subject/` (`LEARNING.md`, `PROGRESS.md`, `deck.md`). The subject no longer gets its own `CLAUDE.md`; Claude Code loads the root one from any subfolder.

### Build mode

From a project, the subject is fixed when learn mode starts: the folder of the plan named in the state file. `/learn:build`'s wrap-up and `/learn:off` write there, never relative to the project.

### Other skills

Each says "resolve the subject" instead of "the learning repo" where it means the folder its paths are relative to, and commits with the subject scope. No other behaviour changes. The learn-mode hook and state are keyed by project and unaffected.

## Out of scope

- Sharing a toolchain or learner profile across subjects (each `LEARNING.md` keeps its own).
- Removing or renaming a subject (do it by hand; the registry needs the matching edit).
- Cross-subject flashcard review.

## Verification

| Check | Expected |
|---|---|
| `bash tests/guard_test.sh` | Allows `python/lessons/001-x/exercises/01-a/data/d.csv` and `python/lessons/001-x/lab.sql` (with `python/LEARNING.md`); blocks `lessons/001-x/exercises/01-a/data/d.csv` (no subject), `a/b/lessons/x/exercises/y/data/d.csv` (too deep), `tools/lessons/…/data/d.csv` and `.vscode/lessons/a/dump.sql` (no `LEARNING.md`), an embedded git repo, `python/lessons/001-x/dump.json` and every case it blocked before |
| `bash tests/run.sh`, `claude plugin validate .` | Pass |
| Templates | `templates/repo/` and `templates/subject/` exist; no `{{…}}` placeholder is left unexplained in `skills/init/SKILL.md` |
| Contract | `skills/init/SKILL.md`, every other `SKILL.md`, `docs/ARCHITECTURE.md`, `README.md`, `docs/SKILLS.md`, `docs/WORKFLOW.md`, `docs/FAQ.md`, `docs/EXAMPLES.md` and the repo-model diagram describe one repo with subject folders; none says "one repo per subject" |
| Migrate, by hand in a temp dir | A standalone repo with two commits migrated into a learning repo gives `<slug>/LEARNING.md` and its exercise data, no `<slug>/tools/`, `.gitignore` or `CLAUDE.md` under `<slug>/`, a clean working tree, and `git log` lists both original commits |

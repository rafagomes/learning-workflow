---
name: init
description: "Create the learning repo and add a subject to it as its own folder, link the projects a subject learns from, or migrate an older one-repo-per-subject learning repo into it. Use when the user says 'set up learning for <projects or subject>', 'start a learning repo', 'add <subject> to my learning', 'I want to learn while building X', 'add this project to my learning', 'migrate my learning repo', or runs another /learn skill and no learning repo is registered yet. One learning repo holds every subject; it never lives inside a project."
argument-hint: "[subject] [project paths...] | add <project path> | migrate [path]"
---
Create the learning repo, add a subject, link a project, or migrate. Argument: $ARGUMENTS

The **learning repo** is one private git repo per learner. It holds every subject the learner studies (e.g. `python`, `rust`, `machine-learning`, `statistics`, `music-theory`), each in its own **subject folder** with its curriculum, lessons, exercises, quizzes, flashcards and reflections. The **projects** hold the real code and data. Each subject links any number of projects, from work repos and personal repos alike. Links are by reference only, so every project stays clean and the learning stays private.

```
<learning repo>/            default ~/Learning
├── README.md               index of subjects
├── CLAUDE.md  .gitignore
├── tools/guard.sh  tools/hooks/pre-commit
└── <subject>/
    ├── LEARNING.md  PROGRESS.md
    ├── curriculum/  plans/  builds/  lessons/  reflections/
    ├── flashcards/deck.md
    └── scratch/            gitignored
```

## 1. Mode

- `add <project path>` or "add this project": **link a project** to an existing subject (resolve it as below; ask which one if several). Skip to step 5.
- `migrate [path]` or "migrate my learning repo": **fold a standalone repo** from v0.1.0 (one git repo per subject) into the learning repo. Skip to step 6.
- Otherwise: **add a subject**. Check the registry first:
  - The subject is already registered inside the learning repo: offer to link the new projects to it instead.
  - It is registered as a **standalone** repo (its `path` is not inside the registry's `repo`): offer `migrate` instead of creating a second one.
  - The registry has no `repo` but has standalone entries: create the learning repo (step 3), then offer to migrate each standalone entry.

## 2. Ask only what is missing

Use AskUserQuestion for anything the argument doesn't give:

1. **Subject and slug** (e.g. `python`, `distributed-systems`). The slug is the folder name.
2. **Projects to link**: paths to git repos. Offer the current repo if the session is inside one. Zero is fine (a pure-subject folder); more can be added later with `add`.
3. **Location of the learning repo**, only when the registry has no `repo` yet. Default `~/Learning`. Never inside a project.
4. **Learner profile** for this subject: current level (new / some experience / working knowledge), preferred depth (practical first / theory first / balanced), lesson language, and the default **hands-on level** for build mode: `claude` (Claude codes and explains), `adaptive` (Claude writes plumbing, the learner writes the core), or `you` (the learner codes, Claude coaches). When another subject exists, offer its language and hands-on level as the default.
5. **Toolchain** for labs and exercises: propose the default for the subject from this skill's `toolchains.md` (or detect it from a linked project's manifest: `pyproject.toml`, `package.json`, `Cargo.toml`, `go.mod`, …) and confirm. Record a run command and a test command. Use `none` for subjects without code; labs then become worked problems and exercises become problem sets checked in conversation.

## 3. Create the learning repo (first time only)

Skip when the registry already has a `repo` that exists on disk. Otherwise copy this skill's `templates/repo/`:

| Template | Becomes |
|---|---|
| `README.md` | `README.md`: subject index and layout |
| `CLAUDE.md` | `CLAUDE.md`: rules for any Claude session opened in the learning repo or a subject folder |
| `gitignore` | `.gitignore` |
| `tools/guard.sh`, `tools/hooks/pre-commit` | the guard and the hook that runs it |

```bash
git init -b main
chmod +x tools/guard.sh tools/hooks/pre-commit
git config core.hooksPath tools/hooks   # repo-local, so a global core.hooksPath can't bypass the guard
git add -A && git commit -m "chore: initialize learning repo"
```

Record `"repo": "<absolute path>"` at the top level of the registry. `core.hooksPath` is local git config, not committed: after cloning the learning repo on another machine, run that `git config` line again (the repo's `CLAUDE.md` says so).

Do not create a remote. If the user wants one, offer a **private** GitHub repo and create it only after they confirm (`gh repo create <name> --private --source . --push`).

## 4. Add the subject folder

Never overwrite: if `<slug>/` already exists, stop and ask. Copy this skill's `templates/subject/`, filling the placeholders:

| Template | Becomes |
|---|---|
| `LEARNING.md` | `<slug>/LEARNING.md`: identity, learner profile, toolchain, linked projects table, data policy |
| `PROGRESS.md` | `<slug>/PROGRESS.md` |
| `deck.md` | `<slug>/flashcards/deck.md` |

Create the empty directories `curriculum/`, `plans/`, `builds/`, `lessons/` and `reflections/` (each with a `.gitkeep`) and `scratch/` inside `<slug>/`. Add a row to the root `README.md` subjects table: `| <Subject> | [<slug>/](<slug>/LEARNING.md) | <date> |`, keeping rows sorted by slug. Register the subject (see Registry) and commit: `chore(<slug>): add subject`.

## 5. Link a project

For each project:

- Record its `slug` (repo directory name unless the user names it), absolute path, `git remote get-url origin` (if any), default branch, and **sensitivity**: `work` (employer or client code, the default for repos under an org remote) or `personal`.
- Store path, remote and branch **only in the registry**, in the subject's entry. In the subject's `LEARNING.md` add just a row with the slug, sensitivity and a one-line neutral description, so no absolute paths or work remotes are ever committed.
- Commit: `chore(<subject>): link <project-slug>`.

A project may be linked to several subjects; each subject records it separately. Sensitivity changes how much may be quoted (see the policy). When in doubt, use `work`.

## 6. Migrate a standalone repo

For a v0.1.0 learning repo that is its own git repo (a `LEARNING.md` at its root, `path` outside the registry's `repo`). Resolve it from the argument, the current directory, or the registry's standalone entries (ask which if several). Create the learning repo first (steps 2.3 and 3) if there is none.

Refuse and explain if `<slug>/` already exists in the learning repo or the standalone repo has uncommitted changes (`git -C <old> status --porcelain` not empty). Then, from the learning repo, keeping the standalone repo's history:

```bash
git fetch <old path> <its branch>:refs/learn-migrate/<slug>
git merge -s ours --no-commit --allow-unrelated-histories refs/learn-migrate/<slug>
git read-tree --prefix=<slug>/ -u refs/learn-migrate/<slug>
git rm -rqf --ignore-unmatch <slug>/tools <slug>/.gitignore <slug>/CLAUDE.md   # the root ones apply
git commit -m "chore(<slug>): migrate subject from its standalone repo"
git update-ref -d refs/learn-migrate/<slug>
```

Then:

- Copy the standalone repo's `scratch/` (gitignored, so not in its history) to `<slug>/scratch/`. Create the empty directories from step 4 that are missing.
- Fix `<slug>/LEARNING.md` wording that calls it a standalone repo (the title and intro line), add the `README.md` row, and commit: `docs(<slug>): adapt subject to the learning repo`.
- Update the registry entry's `path` to `<learning repo>/<slug>` (keep its projects).
- Check: `git log --oneline` lists the standalone repo's commits under the merge, and `<slug>/tools/` does not exist. (Per-file history before the move sits under the old paths: `git log <merge commit>^2 -- LEARNING.md`.)
- Leave the standalone repo untouched. Offer to delete it (and its remote, if any) and do so only after the learner confirms.

## Data policy (applies to every linked project)

- Study skills (`curriculum`, `teach`, `practice`, `quiz`, `reflect`, `plan`) treat every project as **read-only**. Lessons cite code as `<project-slug>:path@shortsha` (sha from `git -C <path> rev-parse --short HEAD`).
- **Build mode** (`/learn:build`) is the exception: at the learner's request it codes in the project under that project's own rules (its CLAUDE.md, branches, commits, review). Even then, no learning artefact, learn-mode state, `TODO(learner)` scaffold or reference to the learning repo is ever left in the project.
- `work` projects: cite and paraphrase; quote at most a few lines when the lesson needs them. Never commit their data, schemas with real values, secrets, customer or personal data, or internal URLs and hostnames.
- `personal` projects: code may be quoted freely; data still stays out unless the user says that dataset is public.
- Real data samples for labs go only into the subject's `scratch/` (gitignored). Exercises use **synthetic data** generated by a seeded script in the exercise.
- No project ever references the learning repo. Outside build mode, anything learned that should reach a project is rewritten there through that project's normal workflow (spec, branch, PR).
- Never loosen this policy unless the user writes the exception themselves; record it in the subject's `LEARNING.md`.

`tools/guard.sh` enforces the mechanical part on the staged content: it blocks data files outside `<subject>/lessons/*/exercises/*/data/` (common config files such as `package.json` are allowed), files over 1 MB, and anything gitleaks flags when gitleaks is installed.

## Registry

`${LEARNING_WORKFLOW_HOME:-~/.config/learning-workflow}/spaces.json` (the same root the learn-mode state uses). Each entry in `spaces` is a subject:

```json
{
  "repo": "/home/me/Learning",
  "spaces": [
    {
      "slug": "rust",
      "path": "/home/me/Learning/rust",
      "created": "2026-11-04",
      "projects": [
        {"slug": "billing-service", "path": "/home/me/work/billing-service",
         "remote": "git@github.com:acme/billing-service.git", "branch": "main", "sensitivity": "work"},
        {"slug": "ray-tracer", "path": "/home/me/code/ray-tracer",
         "remote": null, "branch": "main", "sensitivity": "personal"}
      ]
    }
  ]
}
```

Create the file if missing; add or extend entries; never remove anything without asking. An entry whose `path` is not inside `repo` (or a registry with no `repo`) is a standalone v0.1.0 repo: it still resolves and works, and `/learn:init` offers to migrate it.

**Resolving the subject (every /learn skill does this):**
1. A `LEARNING.md` in the current directory or an ancestor: its folder is the subject.
2. Else every subject whose `projects[].path` contains the current directory. If one, use it; if several, ask.
3. Else the only registered subject.
4. Else ask which one. If none is registered, offer `/learn:init`.

Every path a skill writes (`curriculum/`, `plans/`, `builds/`, `lessons/`, `reflections/`, `flashcards/deck.md`, `PROGRESS.md`, `scratch/`) is relative to the resolved **subject folder**, and its data policy is the one in that folder's `LEARNING.md`. Commits go to the learning repo that contains it (`git -C <subject folder> …`), scoped by subject: `docs(<subject>): …`. For a standalone v0.1.0 repo the subject folder is the repo root and the scope may be dropped.

The **current project** is the linked project whose path contains the current directory (compare whole path components, so `/x/app` doesn't match `/x/app2`), or, inside a git worktree, the project whose path is that repo's main worktree (the first entry of `git worktree list --porcelain`), or the one the user names. Skills that cite code use it.

## Finish

Report the learning repo path, the subject folder, the linked projects with their sensitivity, and the next step: `/learn:curriculum <plan, spec or topic>` to build the subject's first track. After a migration, also report the commits carried over and whether the standalone repo was kept.

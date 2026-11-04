---
name: init
description: "Create a learning repo and link the projects it learns from, or link another project to an existing one. Use when the user says 'set up learning for <projects or subject>', 'start a learning repo', 'I want to learn while building X', 'add this project to my learning', or runs another /learn skill and no learning repo is registered yet. A learning repo can link many projects (work and personal); it never lives inside any of them."
argument-hint: "[subject] [project paths...] | add <project path>"
---
Create or extend a learning repo. Argument: $ARGUMENTS

A learning repo holds what the learner studies: curriculum, lessons, exercises, quizzes, flashcards, reflections. The **projects** hold the real code and data. A learning repo is organised by **subject** (e.g. "python", "rust", "machine-learning", "statistics", "music-theory") and links any number of projects the learner builds in, from work repos and personal repos alike. Links are by reference only, so every project stays clean and the learning stays private.

## 1. Mode

- `add <project path>` or "add this project": **link a project** to an existing learning repo (resolve it as below; ask which one if several). Skip to step 4.
- Otherwise: **create** a learning repo for a subject. Check the registry first; if one already exists for this subject, offer to link the new projects to it instead of creating a second repo.

## 2. Ask only what is missing

Use AskUserQuestion for anything the argument doesn't give:

1. **Subject and slug** (e.g. `python`, `distributed-systems`).
2. **Projects to link**: paths to git repos. Offer the current repo if the session is inside one. Zero is fine (a pure-subject repo); more can be added later with `add`.
3. **Location.** Default `~/Learning/<slug>`. Never inside a linked project.
4. **Learner profile**: current level (new / some experience / working knowledge), preferred depth (practical first / theory first / balanced), lesson language, and the default **hands-on level** for build mode: `claude` (Claude codes and explains), `adaptive` (Claude writes plumbing, the learner writes the core), or `you` (the learner codes, Claude coaches).
5. **Toolchain** for labs and exercises: propose the default for the subject from this skill's `toolchains.md` (or detect it from a linked project's manifest: `pyproject.toml`, `package.json`, `Cargo.toml`, `go.mod`, …) and confirm. Record a run command and a test command. Use `none` for subjects without code; labs then become worked problems and exercises become problem sets checked in conversation.

## 3. Create it

Copy the templates from this skill's `templates/` directory, filling the placeholders:

| Template | Becomes |
|---|---|
| `LEARNING.md` | `LEARNING.md`: identity, learner profile, toolchain, linked projects table, data policy |
| `PROGRESS.md` | `PROGRESS.md` |
| `CLAUDE.md` | `CLAUDE.md`: rules for any Claude session opened in the learning repo |
| `gitignore` | `.gitignore` |
| `tools/guard.sh`, `tools/hooks/pre-commit` | the guard and the hook that runs it |
| `deck.md` | `flashcards/deck.md` |

Create the empty directories `curriculum/`, `plans/`, `builds/`, `lessons/`, `reflections/` and `scratch/`. Then:

```bash
git init -b main
chmod +x tools/guard.sh tools/hooks/pre-commit
git config core.hooksPath tools/hooks   # repo-local, so a global core.hooksPath can't bypass the guard
git add -A && git commit -m "chore: initialize <slug> learning repo"
```

`core.hooksPath` is local git config, not committed: after cloning the learning repo on another machine, run that `git config` line again (the repo's `CLAUDE.md` says so).

Do not create a remote. If the user wants one, offer a **private** GitHub repo and create it only after they confirm (`gh repo create <name> --private --source . --push`).

## 4. Link a project

For each project:

- Record its `slug` (repo directory name unless the user names it), absolute path, `git remote get-url origin` (if any), default branch, and **sensitivity**: `work` (employer or client code, the default for repos under an org remote) or `personal`.
- Store path, remote and branch **only in the registry**. In `LEARNING.md` add just a row with the slug, sensitivity and a one-line neutral description, so no absolute paths or work remotes are ever committed.
- Commit: `chore: link <project-slug>`.

Sensitivity changes how much may be quoted (see the policy). When in doubt, use `work`.

## Data policy (applies to every linked project)

- Study skills (`curriculum`, `teach`, `practice`, `quiz`, `reflect`, `plan`) treat every project as **read-only**. Lessons cite code as `<project-slug>:path@shortsha` (sha from `git -C <path> rev-parse --short HEAD`).
- **Build mode** (`/learn:build`) is the exception: at the learner's request it codes in the project under that project's own rules (its CLAUDE.md, branches, commits, review). Even then, no learning artefact, learn-mode state, `TODO(learner)` scaffold or reference to the learning repo is ever left in the project.
- `work` projects: cite and paraphrase; quote at most a few lines when the lesson needs them. Never commit their data, schemas with real values, secrets, customer or personal data, or internal URLs and hostnames.
- `personal` projects: code may be quoted freely; data still stays out unless the user says that dataset is public.
- Real data samples for labs go only into `scratch/` (gitignored). Exercises use **synthetic data** generated by a seeded script in the exercise.
- No project ever references the learning repo. Outside build mode, anything learned that should reach a project is rewritten there through that project's normal workflow (spec, branch, PR).
- Never loosen this policy unless the user writes the exception themselves; record it in `LEARNING.md`.

`tools/guard.sh` enforces the mechanical part on the staged content: it blocks data files outside `lessons/*/exercises/*/data/` (common config files such as `package.json` are allowed), files over 1 MB, and anything gitleaks flags when gitleaks is installed.

## Registry

`~/.config/learning-workflow/spaces.json`:

```json
{
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

Create the file if missing; add or extend entries; never remove anything without asking.

**Resolving the learning repo (every /learn skill does this):**
1. A `LEARNING.md` in the current directory or an ancestor.
2. Else every space whose `projects[].path` contains the current directory. If one, use it; if several, ask.
3. Else the only registered space.
4. Else ask which one. If none is registered, offer `/learn:init`.

The **current project** is the linked project containing the current directory, or the one the user names. Skills that cite code use it.

## Finish

Report the path, the linked projects with their sensitivity, and the next step: `/learn:curriculum <plan, spec or topic>` to build the first track.

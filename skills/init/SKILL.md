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
  - It is registered as a **standalone** repo (see Registry: its folder is its own git root): offer `migrate` instead of creating a second one.
  - The registry has no `repo` but has standalone entries: create the learning repo (step 3), then offer to migrate each standalone entry.

## 2. Ask only what is missing

Use AskUserQuestion for anything the argument doesn't give:

1. **Subject and slug** (e.g. `python`, `distributed-systems`). The slug is the folder name: lowercase letters, digits and hyphens (`^[a-z0-9][a-z0-9-]*$`) and not `tools`. Step 4 also checks it against the root `.gitignore`.
2. **Projects to link**: paths to git repos. Offer the current repo if the session is inside one. Zero is fine (a pure-subject folder); more can be added later with `add`.
3. **Location of the learning repo**, only when the registry has no `repo` yet. Default `~/Learning`. Never inside a project.
4. **Learner profile** for this subject: current level (new / some experience / working knowledge), preferred depth (practical first / theory first / balanced), lesson language, and the default **hands-on level** for build mode: `claude` (Claude codes and explains), `adaptive` (Claude writes plumbing, the learner writes the core), or `you` (the learner codes, Claude coaches). When another subject exists, offer its language and hands-on level as the default.
5. **Toolchain** for labs and exercises: propose the default for the subject from this skill's `toolchains.md` (or detect it from a linked project's manifest: `pyproject.toml`, `package.json`, `Cargo.toml`, `go.mod`, …) and confirm. Record a run command and a test command. Use `none` for subjects without code; labs then become worked problems and exercises become problem sets checked in conversation.

## 3. Create the learning repo (first time only)

Skip when the registry already has a `repo` that exists on disk.

**Check the location first, and move nothing until the whole check passes.** It must not exist, be an empty directory, or hold only v0.1.0 learning repos. v0.1.0 put them at `~/Learning/<slug>`, inside the new default, and `git add -A` would commit them as broken embedded repos. A v0.1.0 learning repo is a folder that is its own git root **and** has a `LEARNING.md` at that root (usually also a registered standalone entry). Anything else in the location (files, plain folders, other git repos such as a course clone or a linked project) means: stop and ask for another location, before moving anything. When the check passes, move each v0.1.0 learning repo aside (see **Moving a standalone repo aside** below) and offer `migrate` for each after the learning repo exists.

### Moving a standalone repo aside

The one rule for a standalone repo that sits inside the learning repo's location (step 3, and migrate when the learning repo already exists around it):

1. `mkdir -p <location>.v0 && mv -T <location>/<name> <location>.v0/<name>`: beside the location, never inside it. If `<location>.v0/<name>` already exists, stop and ask (an earlier attempt or a backup); never move into it.
2. Set its registry entry's `path` to `<location>.v0/<name>`.
3. Repoint active learn mode from the old path to the new one (see **Repointing learn mode**).
4. Tell the learner where it went and that `/learn:init migrate` will bring it in.

### Repointing learn mode

Whenever a subject's registry `path` changes, replace the path it had **before the change** with the new one in every state file in `${LEARNING_WORKFLOW_HOME:-~/.config/learning-workflow}/active/` that names it. Match whole path components: search for and replace `<old path>/` with the trailing slash (`grep -lF "<old path>/"`), so `~/Learning.v0/ml` never rewrites `~/Learning.v0/ml-ops/…`. so the hook, the build wrap-up and `/learn:off` keep writing to the subject's real folder.

### Then create it

Copy this skill's `templates/repo/`:

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

Never overwrite: if `<slug>/` already exists, stop and ask. Then check the slug against the root `.gitignore`: `git -C <learning repo> check-ignore -q <slug>/LEARNING.md` exit 1 means not ignored and is the only pass; exit 0 means ignored (e.g. `build`, `out`, `target`, `scratch`, `node_modules`), so propose a variant (`build-systems`) and ask; any other exit is an error to report. Copy this skill's `templates/subject/`, filling the placeholders:

| Template | Becomes |
|---|---|
| `LEARNING.md` | `<slug>/LEARNING.md`: identity, learner profile, toolchain, linked projects table, data policy |
| `PROGRESS.md` | `<slug>/PROGRESS.md` |
| `deck.md` | `<slug>/flashcards/deck.md` |

Create the empty directories `curriculum/`, `plans/`, `builds/`, `lessons/` and `reflections/` (each with a `.gitkeep`) and `scratch/` inside `<slug>/`. Add a row to the root `README.md` subjects table: `| <Subject> | [<slug>/](<slug>/LEARNING.md) | <date> |`, keeping rows sorted by slug. Register the subject (see Registry) and commit only the subject and the index (`git add <slug> README.md`): `chore(<slug>): add subject`.

## 5. Link a project

For each project:

- Record its `slug` (repo directory name unless the user names it), absolute path, `git remote get-url origin` (if any), default branch, and **sensitivity**: `work` (employer or client code, the default for repos under an org remote) or `personal`.
- Store path, remote and branch **only in the registry**, in the subject's entry. In the subject's `LEARNING.md` add just a row with the slug, sensitivity and a one-line neutral description, so no absolute paths or work remotes are ever committed.
- Commit: `chore(<subject>): link <project-slug>`.

A project may be linked to several subjects; each subject records it separately. Sensitivity changes how much may be quoted (see the policy). When in doubt, use `work`.

## 6. Migrate a standalone repo

For a v0.1.0 learning repo that is its own git repo (a `LEARNING.md` at its root, which is its git top level). Resolve it from the argument, the current directory, or the registry's standalone entries (ask which if several). Create the learning repo first (steps 2.3 and 3) if there is none; step 3 moves standalone repos that sit inside its location aside. `<old>` is the standalone repo's registry `path` (after any move) and `<slug>` its slug. v0.1.0 had no slug rule, so apply both checks here: step 2.1's format (`^[a-z0-9][a-z0-9-]*$`, not `tools`) and step 4's `.gitignore` check. If either fails, offer a new slug; the folder and the commit scope use it.

First, if the standalone repo sits **inside the existing learning repo** (e.g. at `<learning repo>/<slug>`, its own git root, showing as `?? <slug>/` in `git status`), move it aside (see **Moving a standalone repo aside**, with `<location>` = the learning repo) and continue from its new path. Then check before touching anything else, and refuse and explain on any failure:

- The standalone repo is clean: `git -C <old> status --porcelain` prints nothing.
- The learning repo is clean: `git status --porcelain` prints nothing (otherwise the migration commit would sweep in unrelated changes).
- `<slug>/` doesn't exist in the learning repo.
- Only the current branch (`git -C <old> branch --show-current`) is migrated. List anything else that would be left behind: other local branches (`git -C <old> branch --format='%(refname:short)'`), stashes (`git -C <old> stash list`) and commits not on any remote (`git -C <old> log --branches --not --remotes --oneline`, when it has a remote). If there are other branches or stashes, show them and continue only when the learner says to leave them behind or has merged them into the current branch.

Then, from the learning repo, keeping the standalone repo's history:

```bash
git fetch <old> <current branch>:refs/learn-migrate/<slug>
git merge -s ours --no-commit --allow-unrelated-histories refs/learn-migrate/<slug>
git read-tree --prefix=<slug>/ -u refs/learn-migrate/<slug>
git rm -rqf --ignore-unmatch <slug>/tools <slug>/.gitignore <slug>/CLAUDE.md   # the root ones apply
# customisations (below): write the slimmed <slug>/.gitignore and <slug>/CLAUDE.md if any, then
git add -A -- <slug>
git commit -m "chore(<slug>): migrate subject from its standalone repo"
git update-ref -d refs/learn-migrate/<slug>
```

If any of these fails (for example the guard blocks the commit because gitleaks flags an old file, or a file over 1 MB was committed with `--no-verify` in v0.1.0), undo it and report what blocked it: `git merge --abort; git update-ref -d refs/learn-migrate/<slug>`. The learning repo is then as it was, and the standalone repo was never touched.

**Customisations.** Learner additions are found by comparing with the v0.1.0 templates in this skill's `templates/v0.1.0/` (`gitignore`, `CLAUDE.md`, and `CLAUDE.earlier.md` for repos created by an earlier v0.1.0 build: a line in either template is not an addition), read from the old repo: `git -C <old> show HEAD:.gitignore` and `HEAD:CLAUDE.md`. Lines added to `.gitignore` go into a new `<slug>/.gitignore` holding only those lines (a nested `.gitignore` applies to its folder, so their meaning is unchanged). Rules added to `CLAUDE.md` are shown to the learner and, if they want them, go into a new `<slug>/CLAUDE.md` holding only those rules (Claude Code loads it with the root one). Write these after the `git rm` and stage them with the `git add` line, so the migration commit holds them and the tree ends clean.

Then:

- Copy the standalone repo's `scratch/` (gitignored, so not in its history) to `<slug>/scratch/`. Create the empty directories from step 4 that are missing.
- Fix `<slug>/LEARNING.md` wording that calls it a standalone repo (the title and intro line), add the `README.md` row, and commit: `docs(<slug>): adapt subject to the learning repo`.
- Update the registry entry's `path` from `<old>` to `<learning repo>/<slug>` (keep its projects), and repoint learn mode from `<old>` (see **Repointing learn mode**).
- Check: `git log --oneline` lists the standalone repo's commits under the merge, `<slug>/tools/` does not exist, and `git status --porcelain` prints nothing. (Per-file history before the move sits under the old paths: `git log <merge commit>^2 -- LEARNING.md`.)
- Leave the standalone repo untouched. Offer to delete it (and its remote, if any) only after repeating what would be lost with it (the branches, stashes and unpushed commits listed above, and its `scratch/` if not copied), and delete only after the learner confirms.

## Data policy (applies to every linked project)

- Study skills (`curriculum`, `teach`, `practice`, `quiz`, `reflect`, `plan`) treat every project as **read-only**. Lessons cite code as `<project-slug>:path@shortsha` (sha from `git -C <path> rev-parse --short HEAD`).
- **Build mode** (`/learn:build`) is the exception: at the learner's request it codes in the project under that project's own rules (its CLAUDE.md, branches, commits, review). Even then, no learning artefact, learn-mode state, `TODO(learner)` scaffold or reference to the learning repo is ever left in the project.
- `work` projects: cite and paraphrase; quote at most a few lines when the lesson needs them. Never commit their data, schemas with real values, secrets, customer or personal data, or internal URLs and hostnames.
- `personal` projects: code may be quoted freely; data still stays out unless the user says that dataset is public.
- Real data samples for labs go only into the subject's `scratch/` (gitignored). Exercises use **synthetic data** generated by a seeded script in the exercise.
- No project ever references the learning repo. Outside build mode, anything learned that should reach a project is rewritten there through that project's normal workflow (spec, branch, PR).
- Web searches (e.g. `/learn:teach` looking for a short video) use only general field terms: never a project's name, codenames, internal terms or data. A subject can turn videos off in `LEARNING.md` (`Videos in lessons: off`).
- Never loosen this policy unless the user writes the exception themselves; record it in the subject's `LEARNING.md`.

`tools/guard.sh` enforces the mechanical part on the staged content: it blocks data files outside `<subject>/lessons/*/exercises/*/data/` (common config files such as `package.json` are allowed), files over 1 MB, and anything gitleaks flags when gitleaks is installed.

## Questions and examples (every study skill)

**Questions.** Every question that asks the learner to answer, predict or explain (a lesson's predictions, "your turn" questions and check, quiz questions and flashcards, build mode's predictions, "is this clear?" questions and done-check, practice's pointing hint) is one AskUserQuestion call, so answering is a pick, not typing:

- One question per call; 2–4 short options. Never mark one "(Recommended)", and never let order or wording give the right one away: vary its position, keep options alike in length and tone.
- Distractors are real misconceptions: a swapped formula, the tempting wrong idea, an off-by-one, the confusion just warned about.
- When the question needs data (a table, snippet or output), put it in the options' `preview` as markdown, the same on each option, or different per option when the options are alternative tables, outputs or code. The learner then sees the data beside the options.
- Where options would give the answer away (explain why, derive), offer approaches or partial claims, and say in the question that typing an explanation via Other is welcome.
- The automatic Other is the learner's free answer: judge a typed reply as the answer, or, if it's a question ("why…?"), explain or rephrase and ask again.
- Record, per question, the data shown, the options, the pick (or the typed text) and right / partly / wrong: it's the evidence a check, quiz score or done-check counts.
- Without AskUserQuestion (headless, or denied), ask in plain text with the data above the question and the options listed.

Open questions that ask for the learner's account rather than an answer (reflect's "what happened?") stay in plain text.

**Examples.** Every question and explanation shows all the data it relies on, right there:

- Never refer back to an earlier table ("the parcels from our table") without showing it again.
- To build on an example, re-show it whole with the new columns added; never a partial or derived table that drops a column the question depends on.
- A concept that doesn't need the old example gets a fresh one. Each lesson opens with its own self-contained example; it may reuse a running example, shown again in full.
- Keep examples to 6 rows or fewer, so they fit in a preview.

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

Create the file if missing; add or extend entries; never remove anything without asking. An entry whose folder is its own git root (`git -C <path> rev-parse --show-toplevel` prints `<path>` itself) is a **standalone** v0.1.0 repo, wherever it sits, even inside `repo`'s directory: it still resolves and works, and `/learn:init` offers to migrate it. A subject of the learning repo has `repo` as its git top level.

**Resolving the subject (every /learn skill does this):**
1. A `LEARNING.md` in the current directory or an ancestor: its folder is the subject.
2. Else every subject whose `projects[].path` contains the current directory. If one, use it; if several, ask.
3. Else the only registered subject.
4. Else ask which one. If none is registered, offer `/learn:init`.

Every path a skill writes (`curriculum/`, `plans/`, `builds/`, `lessons/`, `reflections/`, `flashcards/deck.md`, `PROGRESS.md`, `scratch/`) is relative to the resolved **subject folder**, and its data policy is the one in that folder's `LEARNING.md`. Commits go to the learning repo that contains it (`git -C <subject folder> …`), scoped by subject: `docs(<subject>): …`. Stage only that subject's paths (`git add -A -- <subject folder>`, plus `README.md` when the index changes), never `git add -A` on the whole repo, so another subject's uncommitted work never lands in this subject's commit. For a standalone v0.1.0 repo the subject folder is the repo root and the scope may be dropped.

From a project in build mode, the subject is fixed when learn mode starts: it is the folder of the plan named in the state file (`plan <subject folder>/plans/<plan>.md`). `/learn:build`'s wrap-up and `/learn:off` use that folder, never the project's directory.

The **current project** is the linked project whose path contains the current directory (compare whole path components, so `/x/app` doesn't match `/x/app2`), or, inside a git worktree, the project whose path is that repo's main worktree (the first entry of `git worktree list --porcelain`), or the one the user names. Skills that cite code use it.

## Finish

Report the learning repo path, the subject folder, the linked projects with their sensitivity, and the next step: `/learn:curriculum <plan, spec or topic>` to build the subject's first track. After a migration, also report the commits carried over and whether the standalone repo was kept.

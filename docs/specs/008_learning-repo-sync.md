# 008 — The learning repo syncs like an Obsidian vault

Status: implemented in Unreleased

## Problem

The learner edits one learning repo from several machines and sessions. Nothing in the plugin pulls or pushes it, so a session works on a stale copy, a second machine never sees today's lesson, and two copies drift until a manual merge. `/learn:init` also tells Claude not to create a remote at all, so a new learner ends up with a local-only repo by default and nothing to sync with.

## Design

Syncing becomes part of the shared contract: one named section, **Sync (every /learn skill)**, in `skills/init/SKILL.md`. Every skill that reads or writes the learning repo refers to it in one line at its start and one line at its commit step; the rule is not copied into the skills. Two contexts that never load init restate the part they need: teach's background writer brief (it makes the commits) and the learning repo's `CLAUDE.md` template (sessions opened in the learning repo without a skill).

### Pull at session start

Before reading anything from the learning repo (the git repo that holds the subject folder; for a standalone v0.1.0 repo, that repo):

1. **No upstream** (`git -C <repo> rev-parse --abbrev-ref @{u}` fails): skip syncing silently. A local-only repo is a valid choice.
2. **A rebase or merge already in progress**: stop and bring it to the learner.
3. **Uncommitted changes** (`git -C <repo> status --porcelain` prints anything): don't pull over them. Show the list and ask (AskUserQuestion): commit them (`chore: save local changes`, then pull) or leave them and continue without pulling this session.
4. `git -C <repo> pull --rebase`.
   - **Conflict** (the pull fails and a rebase is in progress): `git -C <repo> rebase --abort`, stop, and bring it to the learner with the conflicting files.
   - **Network or auth failure** (fails with no rebase in progress): say so in one line and continue on the local copy.
5. If the branch is still ahead of its upstream (commits from an offline session), push them as below.

Skills that pull: init (`add`, `migrate`, `remote`, and adding a subject to an existing repo), curriculum, plan (including the read-only plan view), teach, practice, quiz, reflect, build (at start and again before the wrap-up writes), off.

### Push after every commit

Every commit a skill makes to the learning repo is followed by `git -C <repo> push` when the branch has an upstream.

- **Rejected** because the remote moved on: `pull --rebase`, then push once more. A conflict is aborted and brought to the learner, as above.
- **Network failure**: say so in one line; the commit stays local and the next session's pull/push carries it.
- **Never force-push.**
- In a session that skipped the pull because of uncommitted changes, a rejected push is not followed by a pull (it would run over them): say in one line that the commit stays local until those changes are dealt with.

### The hook does no sync

`hooks/learn-mode.sh` runs on every prompt. It must stay fast and silent, so it never runs `git pull`, `git push`, `git fetch` or any network call. A test checks this.

### Remote setup

`/learn:init` step 3 no longer says "do not create a remote". It offers a **private** GitHub remote, recommended so the repo syncs across machines; local-only stays a valid answer, and nothing is created until the learner confirms.

1. `gh auth status` must pass; otherwise say how to log in and offer `/learn:init remote` for later.
2. Owner = the authenticated account (`gh api user --jq .login`); default name = the location's folder name, lowercased.
3. **Name taken?** `gh repo view <owner>/<name>` succeeding means taken. Ask (AskUserQuestion): **choose another name** (offer two, e.g. `learning-vault`, `<name>-notes`, plus Other) or **rename the existing repo**.
4. **Renaming the existing repo**: first check what it could break, and stop (back to choosing another name) if it would break anything live: a GitHub Pages site (`gh api repos/<owner>/<name>/pages`; a project site's URL moves with no redirect), a hard-coded base path or the repo name in its config, workflows that name the repo, webhooks (`gh api repos/<owner>/<name>/hooks`), a `homepage` pointing at it. Rename only after the learner confirms (`gh repo rename <new> -R <owner>/<name>`). Never create a repo with the old name afterwards: that would break GitHub's redirect from the old name. So the learning repo takes a different name either way.
5. Create it: `gh repo create <owner>/<name> --private --source <repo> --remote origin --push`, then check `gh repo view <owner>/<name> --json visibility` says `PRIVATE`.

**Existing learning repos** (created before this, migrated, or kept local-only): a new mode, `/learn:init remote`, runs the same steps for the registered learning repo. With an `origin` already set it only makes sure the branch tracks it (`git push -u origin <branch>`). No other skill nags about a missing remote; init's **Finish** mentions `/learn:init remote` once when the learning repo has no remote.

Decision: a `remote` mode rather than "run init again with no subject", because init with no subject already means "ask for one", and a named mode matches `add` and `migrate`.

### Template

`skills/init/templates/repo/CLAUDE.md` gets the rule in short: pull with rebase at session start (unless there are uncommitted changes: ask), push after every commit, never force-push, conflicts go to the learner. New learning repos get it; existing ones keep their `CLAUDE.md` (the skills follow the rule regardless).

## Affected files

- `skills/init/SKILL.md`: **Sync** section; `remote` mode; step 3's remote setup; pull/push lines in add, migrate and subject creation; Finish.
- `skills/{build,off,curriculum,plan,teach,practice,quiz,reflect}/SKILL.md`: one line at start, one at each commit step; teach's writer brief carries the push rule.
- `skills/init/templates/repo/CLAUDE.md`, `skills/init/templates/repo/README.md`.
- `tests/run.sh`: every committing skill references **Sync**; the hook has no git sync or network call; the template carries the rule.
- `docs/ARCHITECTURE.md`, `docs/WORKFLOW.md`, `docs/SKILLS.md`, `docs/FAQ.md`, `README.md`, `CHANGELOG.md`, version 0.8.0.

No diagram shows commits or remotes, so `docs/diagrams/` is unchanged.

## Verification

1. With an upstream that has a commit the local copy lacks, `/learn:teach …` pulls it before reading `PROGRESS.md` (the lesson number accounts for it).
2. With no upstream, no skill mentions syncing.
3. With an uncommitted change in the learning repo, a skill shows it and asks; choosing "leave them" continues without pulling; choosing "commit" commits, pulls and pushes.
4. With a conflicting remote commit, the skill runs `git rebase --abort`, stops, and names the conflicting files; the repo is left as before the pull.
5. Offline, a skill says so in one line, works on the local copy, and its commit stays local; the next online session pushes it.
6. After every skill commit with an upstream, `git status -sb` shows the branch even with its upstream. A rejected push is retried once after `pull --rebase`. No command uses `--force`.
7. `hooks/learn-mode.sh` contains no `git pull`, `git push`, `git fetch`, `curl` or `wget` (test).
8. `/learn:init` on a new machine offers a private remote, recommended; declining leaves a local-only repo. A taken name asks rename-or-other-name; renaming checks Pages, base paths, workflows and webhooks first, and the learning repo never takes the old name.
9. `/learn:init remote` adds a private remote to an existing local-only learning repo.
10. `bash tests/run.sh` and `claude plugin validate .` pass.

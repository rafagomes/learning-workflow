# {{SUBJECT}}

Subject folder in the learning repo, created {{DATE}} with the `learn` plugin (`/learn:init`): lessons, exercises, quizzes and reflections for **{{SUBJECT}}**. Paths below are relative to this folder.

## Learner

| | |
|---|---|
| Level | {{LEVEL}} |
| Depth | {{DEPTH}} |
| Language | {{LANGUAGE}} |
| Hands-on level (build mode) | {{LEVEL_DEFAULT}} |

## Toolchain

| | |
|---|---|
| Toolchain | {{TOOLCHAIN}} |
| Run | `{{RUN_CMD}}` |
| Test | `{{TEST_CMD}}` |

## Linked projects

Read-only references. Cite code as `<slug>:path@shortsha`. Paths and remotes live only in the local registry (`~/.config/learning-workflow/spaces.json`), never in the learning repo.

| Slug | Sensitivity | What it is (one line, no internal names) |
|---|---|---|
{{PROJECT_ROWS}}

## Data policy

- Every linked project is read-only from here (study sessions); no project references this repo.
- Build mode (`/learn:build`, started from a project) is the one exception: it codes in that project at the learner's request under the project's own rules, and never leaves learning artefacts, learn-mode state, `TODO(learner)` scaffolds or references to this repo there.
- `work` projects: cite and paraphrase, quote only a few lines; never commit their data, real schema values, secrets, personal or customer data, or internal hostnames.
- `personal` projects: code may be quoted; data stays out unless marked public below.
- Real data samples go only in `scratch/` (gitignored). Exercises generate seeded synthetic data.
- What should reach a project is rewritten there through its own workflow (spec, branch, PR).

### Exceptions (written by the learner)

None.

## Layout

| Path | Holds |
|---|---|
| `curriculum/<track>.md` | A track: phases → topics → prerequisites → "ready when" |
| `plans/<plan>.md` | Learning plan linked by step ID to a project's dev plan |
| `builds/<date>-<step>.md` | Build-mode logs: concepts met, predictions, done-check |
| `lessons/<NNN>-<topic>/` | `lesson.md`, the lab (file per the toolchain), `exercises/`, `quiz.md` |
| `flashcards/deck.md` | Leitner deck, reviewed by `/learn:quiz review` |
| `reflections/<date>-<topic>.md` | Prediction vs result after building |
| `PROGRESS.md` | Where the learner is, per track |
| `scratch/` | Gitignored. Anything real or throwaway |

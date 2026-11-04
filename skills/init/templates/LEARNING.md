# {{SUBJECT}} — learning repo

Created {{DATE}} with the `learn` plugin (`/learn:init`). Private study space: lessons, exercises, quizzes and reflections for **{{SUBJECT}}**.

## Learner

| | |
|---|---|
| Level | {{LEVEL}} |
| Depth | {{DEPTH}} |
| Language | {{LANGUAGE}} |

## Toolchain

| | |
|---|---|
| Toolchain | {{TOOLCHAIN}} |
| Run | `{{RUN_CMD}}` |
| Test | `{{TEST_CMD}}` |

## Linked projects

Read-only references. Cite code as `<slug>:path@shortsha`.

| Slug | Path | Remote | Sensitivity |
|---|---|---|---|
{{PROJECT_ROWS}}

## Data policy

- Every linked project is read-only from here; no project references this repo.
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
| `lessons/<NNN>-<topic>/` | `lesson.md`, `lab.py`, `exercises/`, `quiz.md` |
| `flashcards/deck.md` | Leitner deck, reviewed by `/learn:quiz review` |
| `reflections/<date>-<topic>.md` | Prediction vs result after building |
| `PROGRESS.md` | Where the learner is, per track |
| `scratch/` | Gitignored. Anything real or throwaway |

# 001 — Build mode: learn while you code

Status: implemented in v0.1.0

## Problem

The study loop (`curriculum → teach → practice → quiz`) assumes you know what to learn and stop to learn it. Most learning happens while building: you're coding a feature in a real project, you don't know which concepts it needs, and you don't want to switch into a course. You want Claude to keep coding with you, surface a concept only when a decision depends on it, and check what you learned when a goal is done.

## Design

Two pieces, linked by step ID:

| | Lives in | Written by |
|---|---|---|
| **Development plan**: steps with IDs (e.g. `P1 blocking`) | The project's own docs/specs, unchanged | The team, as usual |
| **Learning plan**: per step, the concepts it needs, the hands-on level, the done-check | Learning repo `plans/<plan>.md` | `/learn:plan` |

### Skills

- `/learn:plan <spec | plan | artifact | goal>`: reads the dev plan (read-only), splits it into steps (keeping the plan's own IDs, or assigning `S1…`), and for each step lists the concepts it needs, marked `known` (already `ready`/`claimed` in PROGRESS, or self-assessed) or `new`, plus the hands-on level and 3–5 done-check questions. When you can't say what you need to learn, this is where it gets worked out.
- `/learn:build <step>`: turns learn mode on for that step in the current project. Stays on across prompts until the step is done and checked, or `/learn:off`.
- `/learn:off`: ends learn mode early; the wrap-up still runs.

### Behaviour while on

1. **Hands-on level** (`claude` / `adaptive` / `you`): default per subject in `LEARNING.md`, overridable per plan step and per prompt ("I'll write this one", "you write it").
   - `claude`: Claude writes the code and explains decisions that touch a `new` concept.
   - `adaptive`: Claude writes plumbing; for code that embodies a `new` concept it writes a scaffold with a clearly marked gap and asks you to fill it, then reviews.
   - `you`: you write; Claude plans the next small step, reviews and hints.
2. **Silent by default.** A concept note (2–4 lines, marked `▸ concept:`) appears only when a decision in the current response depends on a `new` concept not yet shown in this step. It offers a deeper dive; nothing more unless accepted.
3. **Predict before running.** Before running tests, evals or a script whose outcome teaches something, Claude asks for a one-line prediction, then compares.
4. **Idle time.** When Claude has started a background task and has nothing else to do in the main session, it offers a 2–5 minute deep dive on a concept from the step plus 1–2 "is this clear?" questions. One word ("skip") declines.
5. **Done-check.** When you say the step is done, or a PR for it is opened, Claude asks the step's 3–5 questions about what was built (why this design, what breaks if…, explain this line), one at a time. Misses become flashcards.
6. **Wrap-up.** Writes `builds/<date>-<step>.md` in the learning repo (concepts met, predictions vs results, check results, follow-ups), updates the plan and `PROGRESS.md`, commits, and turns the mode off.
7. **Spaced review.** The next `/learn:build` starts with up to 3 due flashcards.

New concepts discovered while coding are added to the step in the plan. A concept that needs more than a note becomes a curriculum topic for `/learn:teach` later.

### Staying on across prompts

Skill instructions can be lost when the context is compacted, so the mode is backed by state outside every repo:

- `/learn:build` writes `~/.config/learning-workflow/active/<project-key>.md`: a short reminder with the step, level, learning repo, concepts shown and pending, and the condensed rules. `<project-key>` is the git top-level path with `/` replaced by `_`, so separate worktrees are separate.
- A plugin `UserPromptSubmit` hook (`hooks/learn-mode.sh`) prints that file as added context on every prompt in that project. No file → no output. A file untouched for 12 hours is treated as stale and ignored.
- The skill rewrites the file as concepts are shown; `/learn:off` and the wrap-up delete it.

Nothing is written to the project.

## Verification

- With no active file, the hook prints nothing and exits 0.
- With an active file for the current project, the hook prints it; for another project it prints nothing; a file older than 12 h prints nothing.
- `claude plugin validate .` accepts `hooks/hooks.json`.
- Skills `plan`, `build`, `off` have valid frontmatter (tests/run.sh).
- Manual: `/learn:plan` on a small spec, `/learn:build S1`, a few prompts (silent unless a `new` concept is involved), "done" → done-check → `builds/` file written, active file removed.

## Out of scope

Automatic detection of "step done" from CI; per-session (rather than per-project) activation; a scheduler smarter than Leitner.

---
name: off
description: "Turn learn mode off in the current project before the step is finished, saving a wrap-up of what was covered so far. Use when the user says '/learn:off', 'stop learn mode', 'turn off learning', 'just code normally now'."
argument-hint: "[no-wrapup]"
---
Turn learn mode off. Argument: $ARGUMENTS

1. Find the state file, from the project, with the same line `/learn:build` and the hook use:

```bash
# state-path
top=$(git rev-parse --show-toplevel 2>/dev/null || pwd); key=${top//[%]/%25}; state="${LEARNING_WORKFLOW_HOME:-${HOME:-/nonexistent}/.config/learning-workflow}/active/${key//\//%2F}.md"
echo "$state"
```

   If `"$state"` doesn't exist, say learn mode isn't on here and stop. Otherwise the **subject folder** is the folder of the plan named on the state file's first line (`plan <subject folder>/plans/<plan>.md`); every path below is relative to it, never to the project, and `<subject>` is its folder name.
2. Sweep the project for `TODO(learner)` markers (`git grep -n --untracked "TODO(learner)"`) and resolve or report each one, with or without `no-wrapup`.
3. Unless the argument is `no-wrapup`, save a partial wrap-up. This is not `/learn:build` section 4: there is no done-check, so nothing is promoted. First pull the learning repo as `/learn:init` → **Sync** says.
   - Write `builds/<date>-<step>.md` with the concepts shown so far and any predictions, marked as paused.
   - In the plan, the step **stays `in progress`**; add a Log line saying it was paused.
   - In `PROGRESS.md`, concepts shown but still `todo` → `learning`; no other status changes.
   - Commit in the learning repo: `docs(<subject>): build log <step> (paused)`, then push as `/learn:init` → **Sync** says.
4. Delete the state file (`rm -f "$state"`) and confirm in one line. The next `/learn:build <step>` resumes the step.

---
name: off
description: "Turn learn mode off in the current project before the step is finished, saving a wrap-up of what was covered so far. Use when the user says '/learn:off', 'stop learn mode', 'turn off learning', 'just code normally now'."
argument-hint: "[no-wrapup]"
---
Turn learn mode off. Argument: $ARGUMENTS

1. Find the state file, from the project, with the same line `/learn:build` and the hook use:

```bash
# state-path
top=$(git rev-parse --show-toplevel 2>/dev/null || pwd); state="${LEARNING_WORKFLOW_HOME:-${HOME:-/nonexistent}/.config/learning-workflow}/active/${top//\//_}.md"
echo "$state"
```

   If `"$state"` doesn't exist, say learn mode isn't on here and stop.
2. Unless the argument is `no-wrapup`, run the wrap-up from `/learn:build` (section 4), including the `TODO(learner)` sweep (`git grep -n --untracked "TODO(learner)"`), with the step left `in progress` rather than `done`, and skip the done-check. With `no-wrapup`, still run the `TODO(learner)` sweep. Concepts shown so far and any predictions still go into `builds/<date>-<step>.md`.
3. Delete the state file (`rm -f "$state"`) and confirm in one line. The next `/learn:build <step>` resumes the step.

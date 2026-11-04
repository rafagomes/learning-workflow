---
name: off
description: "Turn learn mode off in the current project before the step is finished, saving a wrap-up of what was covered so far. Use when the user says '/learn:off', 'stop learn mode', 'turn off learning', 'just code normally now'."
argument-hint: "[no-wrapup]"
---
Turn learn mode off. Argument: $ARGUMENTS

1. Find the reminder file: `~/.config/learning-workflow/active/<key>.md`, where `<key>` is the current project's git top-level path with every `/` replaced by `_`. If it doesn't exist, say learn mode isn't on here and stop.
2. Unless the argument is `no-wrapup`, run the wrap-up from `/learn:build` (section 4) with the step marked `in progress` rather than `built`, and skip the done-check. Concepts shown so far and any predictions still go into `builds/<date>-<step>.md`.
3. Delete the reminder file and confirm in one line. The next `/learn:build <step>` resumes the step.

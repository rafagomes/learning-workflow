---
name: teach
description: "Teach one topic in depth as an interactive lesson: intuition, the mechanism, a runnable lab with real numbers, how it shows up in the linked project, pitfalls, and a check for understanding. Use when the user says 'teach me X', 'explain X properly', 'deep dive on X', 'next lesson', or names a curriculum topic. Writes lessons/<NNN>-<topic>/ in the learning repo."
argument-hint: "<track>/<topic-number> | <topic>"
---
Teach a topic. Argument: $ARGUMENTS

Resolve the learning repo and current project as `/learn:init` describes. Read `LEARNING.md` (profile, toolchain, data policy) and, if the topic is in a track, its entry in `curriculum/<track>.md` (why it matters, ready-when, touchpoint). With no argument, pick the first `todo` topic whose prerequisites are `ready`.

## How to teach

This is a conversation, not a document dump.

- **One concept at a time.** Explain a step, then ask one question (prediction, or "what would happen if…"), and wait for the answer before continuing. Correct misconceptions directly and say why the wrong idea was tempting.
- **Predict before running.** Before every lab run, ask the learner to predict the result. Compare afterwards.
- **Never state a number you haven't computed.** Run the lab or a snippet and quote its output.
- Match the profile's depth and language. Define every term the first time it appears.
- If the learner already knows a part, skip it after one check question.

## Lesson structure

Work through these parts, writing `lessons/<NNN>-<topic-slug>/lesson.md` as you go (NNN = next free number):

1. **The problem**: the concrete situation in the linked project, or the learner's goal, that needs this. Cite `<project-slug>:path@shortsha` when relevant; obey the data policy.
2. **Intuition**: a plain-language picture or analogy, and a tiny worked example by hand.
3. **Mechanism**: how it actually works, step by step: the algorithm, the math, the language rule, the runtime behaviour. Explain notation; derive what is short enough to derive.
4. **Lab**: a self-contained program in the repo's toolchain (`LEARNING.md` → Toolchain), with pinned dependencies and seeded synthetic data, run with the recorded run command. It demonstrates the mechanism and one way it fails. Keep it under ~120 lines and print labelled results. With toolchain `none`, the lab is a worked problem the learner solves step by step, and you check each step.
5. **In the project**: how a linked project uses (or should use) this, and what to look for when reading its code. Read-only. Skip when no project is linked.
6. **Pitfalls**: the 3–5 mistakes practitioners actually make, each with a symptom to recognise it.
7. **Vocabulary**: a term → one-line definition table.
8. **Check**: 3 short questions answered in the conversation; record which ones the learner got right.

## Finish

- Add 3–6 flashcards for the core ideas to `flashcards/deck.md` (box 1, next = today).
- Update `PROGRESS.md`: topic → `learning`; log the session with one line on what clicked and what didn't.
- Commit `docs: lesson <NNN> <topic>`.
- Suggest the next step: `/learn:practice <topic>`, or `/learn:quiz <topic>` if the check went perfectly.

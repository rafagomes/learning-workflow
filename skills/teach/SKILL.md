---
name: teach
description: "Teach one topic in depth as an interactive lesson: intuition, the mechanism, a runnable lab with real numbers, a short free video when one helps, how it shows up in the linked project, pitfalls, and a check for understanding. Also works through a learning plan in order: a step ID ('/learn:teach Z0') teaches that step's concepts, a plan name teaches the whole plan and resumes where the learner stopped. Use when the user says 'teach me X', 'explain X properly', 'deep dive on X', 'next lesson', 'teach me Z0', 'continue the plan', or names a curriculum topic, plan step or plan. Writes lessons/<NNN>-<topic>/ in the subject's folder of the learning repo."
argument-hint: "<track>/<topic-number> | <topic> | <plan step> | <plan> | <plan>/<step>/<concept>"
---
Teach a topic. Argument: $ARGUMENTS

Resolve the subject and current project as `/learn:init` describes. Read `LEARNING.md` (profile, toolchain, data policy) and, if the topic is in a track, its entry in `curriculum/<track>.md` (why it matters, ready-when, touchpoint).

## What to teach

Match the argument in this order:

1. `<track>/<n>`: that curriculum topic.
2. **A plan step ID** (`Z0`, `P1`, `S2`) found in `plans/*.md`: that step's items, in plan order (see **Plan items**), passing over items that are covered or skipped, as a plan walk does; the step's skipped items are offered at the end. If several plans have that step, ask which one.
3. **A plan name** (a file `plans/<plan>.md`): the whole plan, from the first `todo` item, step by step. Say so when it moves into the next step.
4. `<plan>/<step>/<concept>`, or a concept name that matches one or more plan items: that concept, **even if it's already taught**, or skipped. A taught one is a recheck: teach it again from a new angle and record the new lesson. A concept listed under several steps is still one lesson; it updates every matching item (see **Plan items**).
5. Anything else: a free topic, as before.
6. **No argument:** gather what can be continued: plans with `todo` items (with their counts, e.g. "zone-classification · 3 of 30 taught · next: label definition (Z0)") and tracks with `todo` topics whose prerequisites are `ready`, `claimed`, `built` or `reflected`. With several, ask which one (one question). With one, say which and continue it. With none, suggest `/learn:plan` or `/learn:curriculum`.

### Plan items

An **item** is one concept listed under a step's **Concepts** in `plans/<plan>.md`, addressed as `<plan>/<step>/<concept>`. Its **concept name** is the bullet's text after the `new` / `known` / `deep` marks and before `: why:`; two items are the same concept when their names match, ignoring case. **Plan order** means the steps in the order of the plan's table, then the concepts in the order they're listed under each step.

**Status.** An item's status is its row in `PROGRESS.md` → **Concepts**, where `Step` is `<plan>/<step>`. **A row always wins over the plan's mark.** With no row, an item marked `known` in the plan counts as `claimed` and any other item as `todo`. A `known` item is passed over only while it is `claimed`: once a failed quiz turns it `todo`, it is taught like any other item. A row from before plans were studied may have a bare step ID in `Step` (`Z0`): it counts for the one plan that has that step, and is rewritten as `<plan>/<step>` the next time it's updated. If several plans have that step ID, ask the learner which plan the old rows belong to (once per step ID), then rewrite them. An item is **covered** when it is `claimed`, or at `learning` or beyond.

**Same concept, several items.** Teaching a concept updates the row of **every** item with that concept name in the subject's plans, creating the rows that don't exist yet, and the **Tracks** topic with the same name if there is one, so `PROGRESS.md` never contradicts itself. A concept already covered elsewhere is not taught again when the plan reaches it; say so in one line and move on.

**Skipping.** A skipped item gets a row with status `todo` and `Note` = `skipped <date>`. Resuming takes the first `todo` item that isn't skipped. When nothing else is left, list the skipped items and offer them. Naming a skipped item (rule 4) teaches it and clears the skip. Status wins over the skip mark: an item counts as skipped only while its status is `todo`; any skill that moves it past `todo` drops `skipped <date>` from its `Note`.

Teach **one item per lesson**. After each, offer the next item by name and ask: continue, skip it, or stop. Stopping is always fine: `/learn:teach <plan>` (or `/learn:plan <plan>` to see where you are) resumes at the first `todo` item. A `deep` item gets the full **Lesson structure** below. Any other item gets a **short lesson** (see below). Start the lesson's problem and "in the project" parts from the item's `why:` line and the step's **Builds** line, so it's about what the learner will build. **Ready to build** has one meaning everywhere: every item of the step is covered. Then say so: `/learn:build <step>`, from the project.

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
4. **Watch** (optional): one or two free, short videos on this concept, right after the mechanism so the learner can see it before the lab. See **Videos** below.
5. **Lab**: a self-contained program in the repo's toolchain (`LEARNING.md` → Toolchain), with pinned dependencies and seeded synthetic data, run with the recorded run command. It demonstrates the mechanism and one way it fails. Keep it under ~120 lines and print labelled results. With toolchain `none`, the lab is a worked problem the learner solves step by step, and you check each step.
6. **In the project**: how a linked project uses (or should use) this, and what to look for when reading its code. Read-only. Skip when no project is linked.
7. **Pitfalls**: the 3–5 mistakes practitioners actually make, each with a symptom to recognise it.
8. **Vocabulary**: a term → one-line definition table.
9. **Check**: 3 short questions answered in the conversation; record which ones the learner got right.

### Short lesson (plan items not flagged `deep`)

Same rules (one idea at a time, predict before running, never state an uncomputed number). Write `lessons/<NNN>-<concept-slug>/lesson.md` with: **The problem** (from the item's `why:`), **Intuition** with a tiny worked example by hand, **Watch** (optional, see **Videos**), **In the project**, **One pitfall** with its symptom, and a **Check** of 2 questions. There's no lab unless the learner asks for one or the check shows the idea didn't land; then add one and treat it as a full lesson. A lesson has at most one **Watch** part: when a short lesson grows, it stays where it is (before the lab).

### Videos

A **Watch** part appears only when a video would help: a visual or dynamic idea, a mechanism easier to see than to read, or a known explainer of exactly this concept. Otherwise leave it out entirely. Skip it too when `LEARNING.md` → Learner says `Videos in lessons: off` (a missing row means on).

**Find them early.** Start the search when the lesson starts, with the searches sent in parallel, or hand it to a background agent if one is available, so the lesson doesn't stall at the Watch part. Offer the result ("watch now or after the lesson") and don't wait for the learner to watch.

**What qualifies.**
- **Free**: no paywall, login or course sign-up.
- **Short**: about 15 minutes or less. A longer video qualifies only as a segment of 15 minutes or less whose start and end come from its chapter list, description timestamps or transcript, seen in a fetched page. Never guess timestamps.
- **On this concept, and a bit more**: it covers what the lesson covered plus one adjacent idea, angle or worked example. "Shows" and "Adds" describe what the title, description, chapters or transcript actually say.
- In the lesson's language when one exists, else English (say so).

**Never invent a link or a fact about it.** Find videos with web search now, never from memory. Before showing one, check it:
- It's available: for YouTube, fetch `https://www.youtube.com/oembed?url=<video url>&format=json`; it returns the title and channel (`author_name`) for a public video and an error for a removed or private one. A watch page that loads with "Video unavailable" doesn't count. Elsewhere, the fetched page shows the video and its title.
- The title and channel you write are the ones returned.
- The length comes from a fetched source (the search result, the page or its metadata), never from memory. If no source gives it, don't list the video.

**Data policy.** Web searches leave the machine: build the query from the general field term ("precision recall tradeoff"), never a linked project's name, codenames, internal terms or data. If a plan concept's name is internal, rephrase it in general terms first, or skip the video.

With web tools unavailable or nothing passing, a lesson where a video would have helped gets one line: "No video: none found that's short, free and on this concept." Write each video as: `- [<title>](<url>) · <channel> · <length or start–end>. Shows: <what>. Adds: <the extra>.` A recheck may reuse an earlier lesson's video after checking it again.

## Finish

- Add 3–6 flashcards for the core ideas to `flashcards/deck.md` (box 1, next = today).
- Update `PROGRESS.md`: a `todo` topic → `learning` (any other status stays, since teaching isn't evidence of a gap). For a plan item, update (or add) the **Concepts** row of every item with that concept name (see **Plan items**): `Concept` = the concept name as written in the plan, `Step` = `<plan>/<step>`, status `todo` → `learning` (others stay), `Note` = `lesson <NNN>` (a recheck appends it: `lesson 002, 011`; a cleared skip drops `skipped`). Update the same-named Tracks topic the same way. Log the session with one line on what clicked and what didn't.
- Commit `docs(<subject>): lesson <NNN> <topic>`, one commit per lesson, so stopping between items loses nothing.
- Suggest the next step: `/learn:practice <topic>`, or `/learn:quiz <topic>` if the check went perfectly. When working through a plan, offer the next item first (continue, skip, stop).

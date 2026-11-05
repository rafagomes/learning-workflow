# 004 — Short videos in lessons

Status: implemented in Unreleased

## Problem

`/learn:teach` explains a concept in text, a lab and conversation. Some ideas land faster when you see them animated or drawn: a confusion matrix filling in, gradient descent moving down a loss surface, attention weights. Good short explainers exist for free, but the learner has to go and find them, and a random search returns long courses, paywalled content or videos about a neighbouring idea.

## Design

Lessons get an optional **Watch** part: one or two free, short videos about this concept, chosen and checked by Claude.

**When.** Only when a video would actually help: a visual or dynamic idea, a mechanism that is easier to see than to read, or a well-known explainer of exactly this concept. Otherwise there is no Watch part at all. Placed right after **Mechanism** (before the lab) in a full lesson and after **Intuition** in a short lesson; a lesson has one Watch part, which stays put if a short lesson grows a lab. It's offered ("watch now or after the lesson"), never a gate. The search starts when the lesson starts (parallel searches, or a background agent), so the lesson doesn't stall. A subject turns videos off with `Videos in lessons: off` in `LEARNING.md` (a missing row means on). This extends the lesson structures of spec 003.

**What qualifies.**
- **Free to watch**: no paywall, no login, no course sign-up. YouTube, conference talks, university lecture pages and similar.
- **Short**: about 15 minutes or less. A longer video qualifies only as a segment of 15 minutes or less whose start and end come from its chapters, description timestamps or transcript in a fetched page; timestamps are never guessed.
- **On this concept**, covering what the lesson covered and a bit more: one adjacent idea, a different angle or a worked example the lesson didn't do. Say what that extra is.
- In the lesson's language when one exists; otherwise English, and say so.

**Never invent a link.** Videos are found with web search (WebSearch, WebFetch) at teach time, never from memory. Each link is checked before it's shown. For YouTube, the oEmbed endpoint (`https://www.youtube.com/oembed?url=…&format=json`) returns the title and channel for a public video and an error for a removed or private one (a watch page returns 200 even then). The length comes from a fetched source (search result, page, metadata), never memory; a video whose length can't be confirmed isn't listed. "Shows" and "Adds" describe what the title, description, chapters or transcript say. With no web tools, or nothing that passes, a lesson where a video would have helped says so in one line ("No video: none found that's short, free and on this concept") and the lesson goes on.

**Data policy.** Search queries use only the general field term ("precision recall tradeoff"), never a linked project's name, codenames, internal terms or data; an internal concept name is rephrased in general terms or the video is skipped. The rule lives in the shared contract (`skills/init/SKILL.md`), the subject `LEARNING.md` template and `docs/DATA-POLICY.md`.

**Recorded in `lesson.md`:**

```markdown
## Watch
- [Precision and recall, clearly explained](https://www.youtube.com/watch?v=…) · <channel> · 9 min. Shows: the trade-off as a moving threshold. Adds: the PR curve, which this lesson didn't draw.
```

A recheck (teaching a concept again) may reuse the earlier lesson's video if it still passes the check, or find a different one for the new angle.

## Affected files

- `skills/teach/SKILL.md`: the Watch part in the lesson structure and the short lesson, with the rules above.
- `skills/init/SKILL.md`, `skills/init/templates/subject/LEARNING.md`, `docs/DATA-POLICY.md`, `docs/ARCHITECTURE.md`: the search rule and the off switch.
- `docs/SKILLS.md`, `README.md`: the lesson parts.
- `CHANGELOG.md`: Unreleased → Added.

## Verification

1. `/learn:teach` on a visual concept (e.g. "gradient descent") with web tools: the lesson has a **Watch** part with 1–2 links. Each opens a free video of ≤ 15 min (or a ≤ 15-min timestamped segment), with title and channel as written, and an "Adds:" line.
2. The same with web tools disallowed: the Watch part is one "No video" line; no URL appears in the lesson. With `Videos in lessons: off`, no search is made and there is no Watch part.
3. A concept from a `work` project's plan: the search queries contain only the general concept.
4. A lesson where a video wouldn't help (e.g. a naming convention): no Watch part at all.
5. `bash tests/run.sh` and `claude plugin validate .` pass.

# 004 — Short videos in lessons

Status: implemented in Unreleased

## Problem

`/learn:teach` explains a concept in text, a lab and conversation. Some ideas land faster when you see them animated or drawn: a confusion matrix filling in, gradient descent moving down a loss surface, attention weights. Good short explainers exist for free, but the learner has to go and find them, and a random search returns long courses, paywalled content or videos about a neighbouring idea.

## Design

Lessons get an optional **Watch** part: one or two free, short videos about this concept, chosen and checked by Claude.

**When.** Only when a video would actually help: a visual or dynamic idea, a mechanism that is easier to see than to read, or a well-known explainer of exactly this concept. Not for every lesson. Placed after **Mechanism** in a full lesson and after **Intuition** in a short lesson. It's offered ("watch now or after the lesson"), never a gate: the conversation doesn't wait for it.

**What qualifies.**
- **Free to watch**: no paywall, no login, no course sign-up. YouTube, conference talks, university lecture pages and similar.
- **Short**: about 15 minutes or less. A longer video qualifies only as a timestamped segment of 15 minutes or less (a `t=` link plus the end time).
- **On this concept**, covering what the lesson covered and a bit more: one adjacent idea, a different angle or a worked example the lesson didn't do. Say what that extra is.
- In the lesson's language when one exists; otherwise English, and say so.

**Never invent a link.** Videos are found with web search (WebSearch, WebFetch) at teach time, never from memory. Each link is checked before it's shown: the page resolves, and the title, channel and length match what is claimed. A video whose length can't be confirmed isn't listed. With no web tools, or nothing that passes, the part says so in one line ("No video: none found that's short, free and on this concept") and the lesson goes on.

**Data policy.** Search queries use only the general concept ("precision recall tradeoff"), never a linked project's name, internal terms or data.

**Recorded in `lesson.md`:**

```markdown
## Watch
- [Precision and recall, clearly explained](https://www.youtube.com/watch?v=…) · <channel> · 9 min. Shows: the trade-off as a moving threshold. Adds: the PR curve, which this lesson didn't draw.
```

A recheck (teaching a concept again) may reuse the earlier lesson's video if it still passes the check, or find a different one for the new angle.

## Affected files

- `skills/teach/SKILL.md`: the Watch part in the lesson structure and the short lesson, with the rules above.
- `docs/SKILLS.md`, `README.md`: the lesson parts.
- `CHANGELOG.md`: Unreleased → Added.

## Verification

1. `/learn:teach` on a visual concept (e.g. "gradient descent") with web tools: the lesson has a **Watch** part with 1–2 links. Each opens a free video of ≤ 15 min (or a ≤ 15-min timestamped segment), with title and channel as written, and an "Adds:" line.
2. The same with web tools disallowed: the Watch part is one "No video" line; no URL appears in the lesson.
3. A concept from a `work` project's plan: the search queries contain only the general concept.
4. A lesson where a video wouldn't help (e.g. a naming convention): no Watch part, or the one-line skip.
5. `bash tests/run.sh` and `claude plugin validate .` pass.

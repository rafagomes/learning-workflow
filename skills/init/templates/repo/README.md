# Learning

Private study space managed by the `learn` plugin, one folder per subject. Each subject has its own `LEARNING.md` (profile, toolchain, linked projects, data policy) and `PROGRESS.md`.

## Subjects

| Subject | Folder | Started |
|---|---|---|

## Layout

```
README.md            this index
CLAUDE.md            rules for Claude sessions in this repo
tools/               pre-commit guard, shared by every subject
<subject>/
  LEARNING.md        profile, toolchain, linked projects, data policy
  PROGRESS.md        where you are, per track
  curriculum/        tracks: phases → topics → "ready when"
  plans/             learning plans linked to a project's dev plan
  builds/            build-mode logs
  lessons/           lesson, lab, exercises, quiz per topic
  flashcards/deck.md Leitner deck
  reflections/       prediction vs result after building
  scratch/           gitignored: anything real or throwaway
```

Add a subject with `/learn:init <subject>`. The `/learn` skills pull before they read and push after they commit; `/learn:init remote` adds a private remote if there is none. On another machine, clone this repo and run `/learn:init` and give its path as the location (it registers the subjects and sets `git config core.hooksPath tools/hooks`).

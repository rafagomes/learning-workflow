# Changelog

All notable changes are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).

## [0.1.0] - 2026-11-04

### Added

- `learn` plugin with nine skills: `init`, `plan`, `build`, `off`, `curriculum`, `teach`, `practice`, `quiz`, `reflect`.
- Build mode: learn while coding in a real project. `/learn:plan` links a dev plan to a learning plan by step ID; `/learn:build` pair-programs at a hands-on level (`claude`/`adaptive`/`you`), adds concept notes only when a decision needs them, asks for predictions, offers deep dives during background waits, and runs a done-check and wrap-up when the step is done. A `UserPromptSubmit` hook keeps the mode alive across prompts and compaction.
- Learning repos per subject, linking any number of projects (`work` or `personal`) read-only, with a registry at `~/.config/learning-workflow/spaces.json`.
- Toolchain-agnostic labs and exercises: run and test commands recorded per learning repo, defaults for Python, JS/TS, Rust, Go, Java/Kotlin, C/C++, SQL, shell, and `none` for subjects without code.
- Learning-repo templates and a pre-commit guard against data files, large files and secrets.
- Docs: workflow, architecture, skills reference, data policy, examples, FAQ.
- CI: manifest and frontmatter checks, guard behaviour tests, shellcheck.

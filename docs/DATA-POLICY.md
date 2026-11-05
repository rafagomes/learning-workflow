# Data policy

A learning repo often sits next to code you don't own: your employer's, a client's, an open-source project with its own rules. The policy below is the default for every learning repo the plugin creates. It's written into each subject's `LEARNING.md` and followed by every skill.

## Rules

| | `work` project | `personal` project |
|---|---|---|
| Read code to teach from it | Yes, read-only | Yes, read-only |
| Cite location | `slug:path@sha` | `slug:path@sha` |
| Quote code | A few lines, only when the lesson needs them; prefer paraphrase | Freely |
| Commit project data (rows, dumps, exports, real schema values) | **Never** | Only data you mark public in `LEARNING.md` |
| Secrets, credentials, personal or customer data | **Never** | **Never** |
| Internal hostnames, URLs, ticket contents | **Never** | Your call |
| Project names or internal terms in web searches (lesson videos) | **Never**: general field terms only | Never the project name; general terms only |
| Real samples for a lab | The subject's `scratch/` only (gitignored) | The subject's `scratch/` only |
| Edit, commit, branch or open PRs in the project | Study skills: **never**. Build mode: yes, at your request, under the project's own rules | Same |
| Write learning artefacts (plans, logs, notes, flashcards) or mention the learning repo in the project | **Never**, including in build mode | **Never** |
| Leave `TODO(learner)` scaffolds in the project | **Never**: swept before every commit and at wrap-up | **Never** |

Exercises always generate **seeded synthetic data** shaped like the real problem.

**Build mode is the one place Claude works in a project**: it's ordinary pair programming you asked for, following the project's own CLAUDE.md, branching, commits and review. The teaching layer stays outside: learning artefacts go to the learning repo and the learn-mode state to `~/.config/learning-workflow/active/`.

Nothing flows back automatically. What you learn reaches a project when you write it there yourself, through that project's process (issue, spec, branch, PR, review), and the project never links to the learning repo.

## Defaults when unsure

- A project whose remote belongs to an organisation defaults to `work`.
- If a lesson can't be taught without quoting more than a few lines of `work` code, it describes the pattern instead.
- Loosening the policy is something only you do: write the exception under **Exceptions** in `LEARNING.md`. The skills never loosen it on their own.

## Enforcement

The pre-commit guard installed by `/learn:init` blocks:

- data-like files (any case) outside `<subject>/lessons/*/exercises/*/data/`, except named config files (`package.json`, `tsconfig*.json`, `.vscode/settings.json`, …), and SQL scripts under `<subject>/lessons/` (a subject is a top-level folder with a `LEARNING.md`); embedded git repos are blocked; archives and dumps (`zip`, `gz`, `sql`, `bak`, …) are blocked too;
- files over 1 MB;
- secrets flagged by [gitleaks](https://github.com/gitleaks/gitleaks), when it's installed (recommended).

The guard catches mistakes; it can't recognise a pasted snippet of proprietary code. The policy is the real protection, so keep the learning repo **private** unless it only links `personal` projects and you've checked its history.

## Publishing a learning repo

If you want to make a learning repo public:

1. Check every subject's `LEARNING.md` → Linked projects: any `work` project in any subject means don't publish.
2. Search the history, not just the tree: `git log -p | grep -i -E '<employer>|<client>|internal'`, and run `gitleaks detect`.
3. Remember that citations name paths and commit shas of linked projects.

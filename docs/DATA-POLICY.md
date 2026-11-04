# Data policy

A learning repo often sits next to code you don't own: your employer's, a client's, an open-source project with its own rules. The policy below is the default for every learning repo the plugin creates. It's written into each repo's `LEARNING.md` and followed by every skill.

## Rules

| | `work` project | `personal` project |
|---|---|---|
| Read code to teach from it | Yes, read-only | Yes, read-only |
| Cite location | `slug:path@sha` | `slug:path@sha` |
| Quote code | A few lines, only when the lesson needs them; prefer paraphrase | Freely |
| Commit project data (rows, dumps, exports, real schema values) | **Never** | Only data you mark public in `LEARNING.md` |
| Secrets, credentials, personal or customer data | **Never** | **Never** |
| Internal hostnames, URLs, ticket contents | **Never** | Your call |
| Real samples for a lab | `scratch/` only (gitignored) | `scratch/` only |
| Edit, commit, branch or open PRs in the project | **Never** from a learning session | **Never** from a learning session |

Exercises always generate **seeded synthetic data** shaped like the real problem.

Nothing flows back automatically. What you learn reaches a project when you write it there yourself, through that project's process (issue, spec, branch, PR, review), and the project never links to the learning repo.

## Defaults when unsure

- A project whose remote belongs to an organisation defaults to `work`.
- If a lesson can't be taught without quoting more than a few lines of `work` code, it describes the pattern instead.
- Loosening the policy is something only you do: write the exception under **Exceptions** in `LEARNING.md`. The skills never loosen it on their own.

## Enforcement

The pre-commit guard installed by `/learn:init` blocks:

- data-like files (any case) outside `lessons/*/exercises/*/data/`, except common config files such as `package.json`;
- files over 1 MB;
- secrets flagged by [gitleaks](https://github.com/gitleaks/gitleaks), when it's installed (recommended).

The guard catches mistakes; it can't recognise a pasted snippet of proprietary code. The policy is the real protection, so keep the learning repo **private** unless it only links `personal` projects and you've checked its history.

## Publishing a learning repo

If you want to make a learning repo public:

1. Check `LEARNING.md` → Linked projects: any `work` project means don't publish.
2. Search the history, not just the tree: `git log -p | grep -i -E '<employer>|<client>|internal'`, and run `gitleaks detect`.
3. Remember that citations name paths and commit shas of linked projects.

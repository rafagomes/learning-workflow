# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it responsibly.

**Do not open a public issue.**

Instead, use [GitHub's private vulnerability reporting](https://github.com/rafagomes/learning-workflow/security/advisories/new) to submit your report. This ensures the issue is handled privately until a fix is available.

### What to Include

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if you have one)

### What to Expect

- **Acknowledgment** within 48 hours
- **Status update** within 7 days
- **Fix or mitigation** as soon as practical, depending on severity

### Scope

This project is a Claude Code plugin (Markdown skills, templates, one shell hook). Relevant vulnerabilities include:

- Command injection or unsafe file handling in `skills/init/templates/repo/tools/guard.sh`
- Skill instructions that could write to a linked project, leak project data into a learning repo, or bypass the guard
- Sensitive data exposure through default configurations
- Skill or agent definitions that could lead to unintended code execution

### Out of Scope

- Vulnerabilities in Claude Code itself — report those to [Anthropic](https://docs.anthropic.com/en/docs/claude-code)
- Issues in third-party dependencies not bundled in this repo

## Supported Versions

Only the latest version on the `main` branch is supported with security updates.

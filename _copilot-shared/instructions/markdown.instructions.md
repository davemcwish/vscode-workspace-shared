---
applyTo: "**/*.md"
description: "Markdown style for project documentation."
---

# Markdown Standards

- Use ATX headings with hash signs.
- One H1 per document.
- Wrap prose at around 100 characters where practical.
- Fence code blocks with language identifiers such as python, bash, json, or text.
- Use relative links between project docs.
- Use tables only when comparing three or more items; otherwise use lists.

## Special Characters

- **Never use em-dashes or en-dashes** (the long and medium dashes).
  Use a plain hyphen surrounded by spaces (` - `) instead.
  Em-dashes and en-dashes cause encoding corruption when files pass
  through tools that assume Windows-1252 instead of UTF-8.
- Prefer ASCII punctuation over Unicode equivalents (e.g. `"` not smart quotes).
- Curly/smart quotes must not appear - use straight quotes (`'`, `"`) only.

## Repository Documentation Filenames

Use these canonical root documentation filenames:

- `README.md`
- `CONTRIBUTING.md`
- `Changelog.md`
- `architecture.md`
- `dependency_management.md`


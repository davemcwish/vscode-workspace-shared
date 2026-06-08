# Skill: Project Documentation Writing

## Purpose

This skill defines the writing standard for all project documentation — guides,
README, CONTRIBUTING, Changelog, architecture docs, and any other Markdown files
in the project. It is the single source of truth used by both `doc-writer.agent.md`
and `doc-writer.chatmode.md`.

---

## Audience

All documentation must be written for **complete beginners** simultaneously:

- **Complete beginner coders** — can copy-paste a command but may not know what
  it does without an explanation.
- **Complete beginner Python developers** — knows Python basics but hasn't used
  virtual environments, type hints, or package management before.
- **Complete beginner domain users** — uses the project's domain system
  day-to-day but has never written a query, used the CLI, or dealt with API
  concepts.

The test: "Could a person who has never written Python, never used this project's
domain APIs, and never worked in a software team understand this?" If not, rewrite.

---

## Writing Rules

### Plain English first

- Write as if explaining to a smart colleague who has never coded before.
- Avoid jargon unless it is immediately explained at the point it appears.
- Prefer short sentences. One idea per sentence.
- Use active voice: "Run this command" not "This command should be run".

### Explain every technical term on first use

Every acronym, domain-specific object name, or unfamiliar concept must be
explained **at the point it first appears** — not only in a Glossary at the end.

```markdown
<!-- Bad -->
The script queries ContentDocumentLink records.

<!-- Good -->
The script queries **ContentDocumentLink** records (the Salesforce object that
links an uploaded file to a record — think of it as a join table between
"files" and "records").
```

### Always include

- **Prerequisites** — what the reader needs before starting (tools, accounts, files).
- **Step-by-step instructions** — numbered steps for any procedure.
- **Command examples** — full commands, not just flag names.
- **Expected output** — what success looks like.
- **Troubleshooting** — at least the two or three most common failure modes.
- **Glossary or key concepts** — at the end of any guide longer than two sections.

### Security and PII

- Mention security implications whenever a function, script, or step touches
  credentials, tokens, or personal data.
- Explain what PII means in context ("names and email addresses — treat as
  confidential").
- Never include real usernames, passwords, tokens, or personal directory paths
  in examples. Use `<your-alias>`, `<username>`, or `<your-path>`.

---

## Markdown Format Rules

These rules match `.github/instructions/markdown.instructions.md`:

- One H1 per document.
- Use ATX headings (`#`, `##`) — not underline style.
- Fence code blocks with a language identifier:
  ` ```python `, ` ```bash `, ` ```text `.
- Wrap prose at approximately 100 characters.
- Use relative links between project docs (not absolute paths).
- Tables for 3+ comparable items; bullet lists otherwise.
- No trailing whitespace on any line.
- End file with a single newline.

---

## Changelog Format

All Changelog entries must follow **Keep a Changelog** format:

```markdown
## [YYYY-MM-DD] — short description

### Added
- **`path/to/file.py`** — one sentence explaining what was added and why.

### Changed
- **`path/to/file.py`** — one sentence explaining what changed.

### Fixed
- **`path/to/file.py`** — one sentence describing the bug and the fix.

### Removed
- **`path/to/file.py`** — one sentence explaining what was removed and why.
```

Rules:

- Use today's date, not a version number.
- Every entry must reference the exact file path(s) affected.
- Plain English descriptions — no commit-message shorthand.
- One entry per session/PR — not one entry per file.

---

## What to Update for Each Change Type

| Change type | Documents to update |
| --- | --- |
| New script | `docs/<script>_guide.md` (create), `README.md` script list, `architecture.md` |
| New CLI argument | Relevant guide's CLI table, `docs/running-the-scripts-guide.md` |
| New module in `src/` | `architecture.md`, relevant guide |
| New/changed tests | Any guide that mentions test count |
| Removed file | Remove from all references in docs, add Removed entry to Changelog |
| New `.env` variable | `.env.example`, `docs/running-the-scripts-guide.md` |
| Config change | `CONTRIBUTING.md`, relevant guides |
| Dependency added/removed | `requirements/` notes, `dependency_management.md` if present |
| Instruction/skill/workflow change | `Changelog.md` entry; `README.md` if user-visible |

---

## Critical Constraints

- **Never invent** features or behavior — only document what exists in code.
- **Never remove** security warnings or PII handling notes.
- **Never update** docs for changes that haven't been implemented yet.
- Always check `architecture.md` is still accurate after structural changes.
- Always update test counts in guides if tests were added or removed.
- The Changelog is **mandatory** after every session — not optional.

---

## Reference Files

When writing documentation, load these before editing:

- `.github/instructions/docs.instructions.md` — audience and tone rules
- `.github/instructions/markdown.instructions.md` — Markdown style rules
- `.github/instructions/security.instructions.md` — secrets and PII rules
- `architecture.md` — current module structure
- `Changelog.md` — existing entries to match format

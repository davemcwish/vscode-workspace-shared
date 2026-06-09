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

## Accuracy Before Wording

A beginner trusts the documentation completely and cannot spot an invented flag
or a wrong default. So accuracy is enforced first, and beginner-friendly wording
is applied on top of confirmed facts — never instead of them.

Two distinct jobs, never mixed:

1. **WHAT exists** (flags, defaults, choices, behaviour) — a matter of fact,
   extracted deterministically from the code. Never guessed.
2. **HOW to explain it** (prose, examples, troubleshooting) — where your
   language skill applies, but only to facts confirmed in job 1.

### CLI Accuracy (read before writing any argument table)

Whenever you write or update a command-line argument table:

1. Run the script's own help output first and treat it as the ONLY source of
   truth:

   ```bash
   python scripts/<script_name>.py --help
   ```

2. Perform a 1:1 audit between `--help` and the table:
   - Every flag in `--help` must appear in the table (no omissions).
   - Every row in the table must exist in `--help` (no inventions).
   - Defaults and choices must match `--help` exactly.

3. Never copy a CLI table from a sibling guide. Similar-looking scripts (e.g.
   an order report and a user report) often have legitimately different flags.
   Copying one into the other propagates errors.

4. If you cannot run `--help`, stop and flag it for manual review. Do not fall
   back to reading the source by eye, and do not fall back to a sibling doc.

This rule exists because of a real defect: a guide documented flags that did not exist (--no-excel, --attach-excel) while omitting flags that did (--use-outlook, --email-intro). Extracting from --help and auditing 1:1 prevents both failure modes. A matching automated test (tests/test_docs_cli_contract.py) enforces this in CI.

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

### Always include
- Prerequisites — what the reader needs before starting (tools, accounts, files).
- Step-by-step instructions — numbered steps for any procedure.
- Command examples — full commands, not just flag names.
- Expected output — what success looks like.
- Troubleshooting — at least the two or three most common failure modes.
- Glossary or key concepts — at the end of any guide longer than two sections.

### Security and PII
- Mention security implications whenever a function, script, or step touches credentials, tokens, or personal data.
- Explain what PII means in context ("names and email addresses — treat as confidential").
- Never include real usernames, passwords, tokens, or personal directory paths in examples. Use <your-alias>, <username>, or <your-path>.

## Markdown Format Rules
These rules match .github/instructions/markdown.instructions.md:

- One H1 per document.
- Use ATX headings (#, ##) — not underline style.
- Fence code blocks with a language identifier: ```python, ```bash, ```text.
- Surround every heading with one blank line above and below (MD022).
- Surround every list with one blank line above and below (MD032).
- Wrap prose at approximately 100 characters.
- Use relative links between project docs (not absolute paths).
- Tables for 3+ comparable items; bullet lists otherwise.
- No trailing whitespace on any line.
- End file with a single newline.

MD022 and MD032 are the two most common lint failures. They are auto-fixed by markdownlint-cli2 --fix in the local quality gate, but writing them correctly keeps diffs clean.

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

### Rules:

- Use today's date, not a version number.
- Every entry must reference the exact file path(s) affected.
- Plain English descriptions — no commit-message shorthand.
- One entry per session/PR — not one entry per file.

## What to Update for Each Change Type

| Change type | Documents to update |
| --- | --- |
| New script | `docs/<script_name>_guide.md` (create), README.md script list, architecture.md |
| New/changed CLI argument | Relevant guide's CLI table (re-run `--help`), `docs/running-the-scripts-guide.md` |
| New module in `src/` | architecture.md, relevant guide |
| New/changed tests | Any guide that mentions test count |
| Removed file | Remove from all references in docs, add Removed entry to Changelog |
| New `.env` variable | `.env.example`, `docs/running-the-scripts-guide.md` |
| Config change | CONTRIBUTING.md, relevant guides |
| Dependency added/removed | `requirements/` notes, `dependency_management.md` if present |
| Instruction/skill/workflow change | Changelog.md entry; README.md if user-visible |

## New Script Guide Template

When creating a guide for a new script, use this structure. The CLI Arguments
table MUST be populated from `--help` (see CLI Accuracy above) — never from
memory or a sibling guide.

```text
# Script Name Guide

## What This Script Does
One plain-English paragraph. No jargon without explanation.

## Prerequisites
- Virtual environment activated.
- CLI tool authenticated.
- Required environment variables set in .env.

## How to Run It
python scripts/script_name.py --required-arg VALUE

## CLI Arguments
| Argument | Required | Default | Description |
(Populate every row from `python scripts/script_name.py --help`.)

## Expected Output
What success looks like.

## Troubleshooting
Common error message: cause and fix.

## Security and Data Notes
Whether the script reads or writes sensitive data. How to handle output safely.

## Critical Constraints
- Never invent features or behavior — only document what --help and the code confirm.
- Never copy CLI details from a sibling guide — they may be wrong.
- Never remove security warnings or PII handling notes.
- Never update docs for changes that haven't been implemented yet.
- Always run --help and audit 1:1 before finalising any CLI table.
- Always check architecture.md is still accurate after structural changes.
- Always update test counts in guides if tests were added or removed.
- The Changelog is mandatory after every session — not optional.

## Reference Files
When writing documentation, load these before editing:

- .github/instructions/docs.instructions.md — audience, tone, accuracy rules
- .github/instructions/markdown.instructions.md — Markdown style rules
- .github/instructions/security.instructions.md — secrets and PII rules
- architecture.md — current module structure
- Changelog.md — existing entries to match format

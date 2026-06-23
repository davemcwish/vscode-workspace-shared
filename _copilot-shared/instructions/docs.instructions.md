---
applyTo: "docs/**/*.md,*.md,CONTRIBUTING.md,README.md"
description: "Audience, tone, and accuracy rules for all project documentation."
---

# Documentation Audience, Tone & Accuracy Standards

## Target Audience

All documentation in this project must be written for **complete beginners**.
The bar is: "could a person who has never written Python, never used Salesforce
APIs, and never worked in a software team understand this?" If not, rewrite it.

More specifically, write for these three overlapping audiences simultaneously:

- **Complete beginner coders** - someone who can copy-paste a command but may
  not know what it does without an explanation.
- **Complete beginner Python developers** - someone who knows Python basics but
  hasn't used virtual environments, type hints, or package management before.
- **Complete beginner Salesforce users** - someone who uses Salesforce
  day-to-day but has never written a SOQL query, used the CLI, or dealt with
  API concepts like ContentDocumentLink, org aliases, or access tokens.

## Accuracy Comes First

Beginner-friendly wording is worthless if the facts are wrong. A beginner
trusts the documentation completely - they cannot spot an invented flag or a
wrong default the way an expert can. So accuracy and beginner-friendliness are
BOTH mandatory, and accuracy is enforced first.

### The golden rule for anything factual

For CLI flags, defaults, choices, environment variable names, file paths, and
behaviour: **document only what the code itself confirms.** Never guess, never
infer from similar projects, and never copy from a sibling document.

### CLI documentation must come from `--help`

Whenever you write or update a table of command-line arguments:

1. Run the script's own help output first and treat it as the only source of
   truth:

   ```bash
   python scripts/<script_name>.py --help
   ```

2. Perform a 1:1 audit between --help and the table:

   - Every flag in --help must appear in the table (no omissions).
   - Every row in the table must exist in --help (no inventions).
   - Defaults and choices must match --help exactly.

3. Never copy a CLI table from a sibling guide. Two scripts that look similar (for example an "order" report and a "user" report) often have legitimately different flags. Copying one into the other propagates errors.

This rule exists because of a real defect: a guide once documented flags that did not exist in the code (--no-excel, --attach-excel) while omitting flags that did (--use-outlook, --email-intro). Both failures are prevented by extracting from --help and auditing 1:1.

### Never invent to fill a gap

If you are unsure whether a feature, flag, or behaviour exists, do NOT write a plausible-sounding description. Either confirm it from the code, or leave it out and flag it for manual review. A missing note is recoverable; a confidently wrong note misleads a beginner.

## Writing Rules

### Plain English first

- Write as if explaining to a smart colleague who has never coded before.
- Avoid jargon unless it is immediately explained in brackets or a callout.
- Prefer short sentences. One idea per sentence.

### Explain every technical term on first use

Every acronym, Salesforce-specific object name, or unfamiliar concept must be
explained **at the point it first appears** - not only in a Glossary at the end.

```markdown
<!-- Bad -->
The script queries ContentDocumentLink records.

<!-- Good -->
The script queries **ContentDocumentLink** records (the Salesforce object that
links an uploaded file to a record - think of it as a join table between
"files" and "records").

### Salesforce-specific terms to always explain inline
Term Plain-English explanation to include
__c suffix "(the __c suffix means this is a custom object, not a standard Salesforce one)"
SOQL "(Salesforce Object Query Language - Salesforce's version of SQL for querying its database)"
Org "(an 'org' is a single Salesforce environment - you typically have a Production org and one or more sandbox orgs for testing)"
ContentDocumentLink "(the Salesforce object that links an uploaded file to a record)"
ContentVersion "(represents one version of an uploaded file in Salesforce)"
Visualforce "(a Salesforce page-rendering technology - similar to a server-side HTML template)"
Access token / session "(a temporary password-like string that proves you are logged in - it expires and must be refreshed)"
CLI alias "(a short nickname you give to an org when you log in, so you don't have to type a long URL each time)"

### Python-specific terms to always explain inline
Term Plain-English explanation to include
Virtual environment "(an isolated folder of Python packages - prevents conflicts between projects)"
pip install -e . "(installs the local package in editable mode - code changes take effect immediately without reinstalling)"
pip-compile "(a tool that reads your loose dependency list and produces an exact pinned version lock file)"
Type hint "(a label on a function parameter that tells the reader - and the type checker - what kind of value is expected)"
Decorator "(a function that wraps another function to add behaviour - e.g. timing, retry logic)"
monkeypatch "(a pytest tool that temporarily replaces a real function with a fake one during testing)"
Mocking "(replacing a real dependency - like a network call - with a controlled fake during testing)"


**Part 4 of 4**

```markdown
### Acronyms

Expand every acronym on first use in each document:

```markdown
<!-- Bad -->
Files are uploaded to EDMS after zipping.

<!-- Good -->
Files are uploaded to EDMS (the Electronic Document Management System) after zipping.

### Structure
Every guide must have: a one-paragraph plain-English summary at the top, Prerequisites, a step-by-step walkthrough, and Troubleshooting.
Guides must also include either a Glossary section or a Key Concepts for Beginners section. Both serve the same purpose: explaining terms for readers who scroll past inline definitions. Either name is acceptable.
The concepts/glossary section must repeat definitions that also appear inline - this is intentional. Readers who scroll straight there must not be left guessing.
Use numbered lists for steps that must be done in order; bullet lists otherwise.
Avoid walls of text - break up paragraphs with headers, tables, or code blocks.

### Project Dependencies in Script Guides

Every script guide must include a **"How This Script Works (Dependencies)"**
subsection within Prerequisites. This section must:

- List every `src/sf_admin_utils/` module the script imports.
- Provide a one-sentence plain-English explanation of each module's role.
- Explain the call chain in beginner-friendly terms (e.g. "the script calls
  `user_snapshot.py` to fetch data, then passes it to `user_report.py` to
  build the summary").
- Use a table for three or more dependencies; a bullet list for fewer.

Example:

```markdown
### How This Script Works (Dependencies)

This script does not do everything itself. It relies on helper modules in the
`src/sf_admin_utils/` folder:

| Module | What it does |
| --- | --- |
| `user_snapshot.py` | Fetches all User records from Salesforce and saves them as dated JSON files |
| `user_report.py` | Compares two snapshots to find status changes, builds DataFrames and text summaries |
| `email_sender.py` | Sends the formatted report via Outlook or SMTP |
| `excel_report.py` | Builds the Excel workbook with Summary, Chart, and Detail sheets |
```

**Why this matters:** A beginner who opens a script and sees `from sf_admin_utils.user_snapshot import fetch_all_users` has no idea what that module does or where to find it. The dependency table gives them a map before they start reading code.

### Markdown formatting that linters enforce

These two rules cause the most frequent markdownlint failures, so apply them deliberately:

- MD022 - surround every heading with one blank line above and below.
- MD032 - surround every list with one blank line above and below.
These are auto-fixed by markdownlint-cli2 --fix in the local quality gate, but writing them correctly avoids noisy diffs.

### Character Encoding in Documentation

- **Never use em-dashes, en-dashes or fancy long dashes** in markdown files. Use a plain hyphen (`-`) or double-hyphen (`--`) instead.
- **Never use smart/curly quotes** (`\u2018`, `\u2019`, `\u201c`, `\u201d`). Use straight ASCII quotes (`'`, `"`) only.
- **Avoid all non-ASCII punctuation** in markdown: no Unicode arrows, tick marks, bullet symbols, or typographic characters.

These characters cause encoding corruption when files move between Windows (which may default to cp1252) and Linux (GitHub Actions, CI runners) where UTF-8 is assumed. Markdown editors often auto-convert `--` to em-dashes as a "nice" typography feature - disable this in your editor settings, or paste your text through a plain-text tool before committing.

### Transcript-Derived Guides

When documentation is created from a transcript, support log, Copilot session, or LLM conversation:

- Preserve the chronological order of events.
- Include dates and times where available.
- Explain what each command did before or after showing it.
- Include errors exactly enough that a beginner can recognize them.
- Explain the cause of each error in plain English.
- Include the final working command or final working file content.
- Clearly separate what happened from what the reader should do now.
- Include a "Final Working State" section.
- Include an "Errors and Fixes" table.
- Include a "Security and Privacy Notes" section.

### Repository Documentation Filenames

Use these canonical root documentation filenames:

- README.md
- CONTRIBUTING.md
- Changelog.md
- architecture.md
- dependency_management.md

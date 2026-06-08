---
applyTo: "docs/**/*.md,*.md,CONTRIBUTING.md,README.md"
description: "Audience and tone rules for all project documentation."
---

# Documentation Audience & Tone Standards

## Target Audience

All documentation in this project must be written for three overlapping audiences:

- **Beginner/novice coders** — someone who can copy-paste a command but may not
  know what it does without an explanation.
- **Beginner/novice Python developers** — someone who knows Python basics but
  hasn't used virtual environments, type hints, or package management before.
- **Beginner Salesforce users** — someone who uses Salesforce day-to-day but has
  never written a SOQL query, used the CLI, or dealt with API concepts like
  ContentDocumentLink, org aliases, or access tokens.

## Writing Rules

### Plain English first

- Write as if explaining to a smart colleague who has never coded before.
- Avoid jargon unless it is immediately explained in brackets or a callout.
- Prefer short sentences. One idea per sentence.

### Explain every technical term on first use

Every acronym, Salesforce-specific object name, or unfamiliar concept must be
explained **at the point it first appears** — not only in a Glossary at the end.

```markdown
<!-- Bad -->
The script queries ContentDocumentLink records.

<!-- Good -->
The script queries **ContentDocumentLink** records (the Salesforce object that
links an uploaded file to a record — think of it as a join table between
"files" and "records").
```

### Salesforce-specific terms to always explain inline

| Term | Plain-English explanation to include |
| ---- | ------------------------------------ |
| `__c` suffix | "(the `__c` suffix means this is a custom object, not a standard Salesforce one)" |
| SOQL | "(Salesforce Object Query Language — Salesforce's version of SQL for querying its database)" |
| Org | "(an 'org' is a single Salesforce environment — you typically have a Production org and one or more sandbox orgs for testing)" |
| ContentDocumentLink | "(the Salesforce object that links an uploaded file to a record)" |
| ContentVersion | "(represents one version of an uploaded file in Salesforce)" |
| Visualforce | "(a Salesforce page-rendering technology — similar to a server-side HTML template)" |
| Access token / session | "(a temporary password-like string that proves you are logged in — it expires and must be refreshed)" |
| CLI alias | "(a short nickname you give to an org when you log in, so you don't have to type a long URL each time)" |

### Python-specific terms to always explain inline

| Term | Plain-English explanation to include |
| ---- | ------------------------------------ |
| Virtual environment | "(an isolated folder of Python packages — prevents conflicts between projects)" |
| `pip install -e .` | "(installs the local package in editable mode — code changes take effect immediately without reinstalling)" |
| `pip-compile` | "(a tool that reads your loose dependency list and produces an exact pinned version lock file)" |
| Type hint | "(a label on a function parameter that tells the reader — and the type checker — what kind of value is expected)" |
| Decorator | "(a function that wraps another function to add behaviour — e.g. timing, retry logic)" |
| `monkeypatch` | "(a pytest tool that temporarily replaces a real function with a fake one during testing)" |
| Mocking | "(replacing a real dependency — like a network call — with a controlled fake during testing)" |

### Acronyms

Expand every acronym on first use in each document:

```markdown
<!-- Bad -->
Files are uploaded to EDMS after zipping.

<!-- Good -->
Files are uploaded to EDMS (the Electronic Document Management System) after zipping.
```

### Structure

- Every guide must have: a one-paragraph plain-English summary at the top,
  Prerequisites, a step-by-step walkthrough, and Troubleshooting.
- Guides must also include either a **Glossary** section or a **Key Concepts
  for Beginners** section. Both serve the same purpose: explaining terms for
  readers who scroll past inline definitions. Either name is acceptable; pick
  the one that fits the guide's audience and tone.
- The concepts/glossary section must repeat definitions that also appear
  inline — this is intentional. Readers who scroll straight there must not
  be left guessing.
- Use numbered lists for steps that must be done in order; bullet lists otherwise.
- Avoid walls of text — break up paragraphs with headers, tables, or code blocks.

## Transcript-Derived Guides

When documentation is created from a transcript, support log, Copilot session, or
LLM conversation:

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

## Repository Documentation Filenames

Use these canonical root documentation filenames:

- `README.md`
- `CONTRIBUTING.md`
- `Changelog.md`
- `architecture.md`
- `dependency_management.md`

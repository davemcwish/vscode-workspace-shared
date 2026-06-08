# Workflow: Documentation Writing

## Purpose

Use this workflow when you need to write or update project documentation after
code changes. It covers creating new guides, updating existing docs, and
ensuring the Changelog is always current.

This workflow is designed for beginners. It explains what to do, why each step
matters, and which Copilot assets to use at each stage.

## When To Use This Workflow

Use this workflow when you are:

- adding a new script and need a guide for it,
- changing an existing script's CLI arguments or behavior,
- adding a new module in `src/` that other developers need to understand,
- completing a PR and needing to update `Changelog.md`,
- improving the README or CONTRIBUTING guide,
- onboarding a new team member and identifying documentation gaps,
- preparing documentation as part of the standard change workflow (Step 8).

For docstring improvements to Python files, use
`workflows/docstring-remediation.workflow.md` instead.

---

## Standards Reference

Before writing anything, load these files:

- `.github/skills/doc-writing.skill.md` -- **all writing rules, format rules,
  and Changelog format** (read this first)
- `.github/instructions/docs.instructions.md` -- audience and tone rules
- `.github/instructions/markdown.instructions.md` -- Markdown style rules
- `.github/instructions/security.instructions.md` -- secrets and PII rules
- `architecture.md` -- current module and script structure

---

## Overview

```text
Identify what changed
  -> Load the writing standards
  -> Identify affected documents
  -> Write or update each document
  -> Update Changelog.md (mandatory)
  -> Run quality checks
  -> Review the diff
  -> Report
```

---

## Step 1: Identify What Changed

Determine which code, configuration, or tooling changed in the current session
or branch.

**With Copilot:** ask the `doc-writer` agent or chatmode to run:

```bash
git diff --name-only HEAD~1
```

**Manually:** review your recent edits and list:

- new files added,
- files deleted,
- files with logic or CLI argument changes,
- new environment variables,
- new or removed dependencies,
- changed test counts.

---

## Step 2: Load the Writing Standards

Open and read `.github/skills/doc-writing.skill.md` before writing anything.

It contains the audience definition, plain English rules, Markdown format
rules, Changelog format rules, and the "what to update for each change type"
table.

If you skip this step, you risk writing documentation that is too technical,
incorrectly formatted, or missing required sections.

---

## Step 3: Identify Affected Documents

Use the change type table from `doc-writing.skill.md` to decide which
documents need updating.

Quick reference:

| Change type | Minimum documents to update |
| --- | --- |
| New script | Create `docs/<script_name>_guide.md`, update `README.md`, update `architecture.md` |
| Changed script behavior | Update `docs/<script_name>_guide.md` |
| New CLI argument | Update relevant guide's CLI table |
| New module in `src/` | Update `architecture.md` |
| New `.env` variable | Update `.env.example` and running guide |
| Removed file | Remove all references across docs |
| Any change | Update `Changelog.md` |

When in doubt, update the document. Accurate documentation is always
better than assuming something is still correct.

---

## Step 4: Write or Update Each Document

### 4a. Creating a new guide

New script guides must follow this structure:

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

## Expected Output
What success looks like.

## Troubleshooting
Common error message: cause and fix.

## Security and Data Notes
Whether the script reads or writes sensitive data. How to handle output safely.
```

### 4b. Updating an existing guide

- Read the current guide first.
- Make the smallest accurate change that brings it in sync with the code.
- Do not rewrite sections that are still accurate.
- Update CLI tables if arguments changed.
- Update example output if behavior changed.

### 4c. Updating README.md

- Add new scripts to the script list table.
- Update "What it does" descriptions if behavior changed.
- Update test counts if visible in the README.

### 4d. Updating architecture.md

- Add new modules or scripts with a one-line description.
- Remove deleted files.
- Update dependency relationships if they changed.

---

## Step 5: Update Changelog.md (Mandatory)

> **This step is mandatory. Do not skip it.**
>
> The Changelog must be updated after every session that changes code,
> configuration, documentation, or tooling. Skipping it is a process defect
> caught by the pre-commit-check gate.

Add a new entry at the top of `Changelog.md` using the format in
`.github/skills/doc-writing.skill.md` (Changelog Format section).

---

## Step 6: Run Quality Checks

```bash
ruff format --check src tests scripts
ruff check src tests scripts
mypy
pytest --tb=short -q
```

If a Markdown linter is available:

```bash
markdownlint docs/ README.md CONTRIBUTING.md Changelog.md
```

---

## Step 7: Review the Diff

Before committing, confirm:

- [ ] Every changed file is intentional -- no accidental edits.
- [ ] No secrets, tokens, or real usernames appear in examples.
- [ ] Technical terms are explained at first use.
- [ ] Command examples are accurate and complete.
- [ ] Changelog entry references correct file paths.
- [ ] Markdown format is consistent with the rest of the project.

---

## Step 8: Report

```text
Documentation Update Summary

Files Created:    | File | Purpose |
Files Updated:    | File | What Changed |
Not Changed:      | File | Reason |
Changelog entry:  [date] added.
Quality checks:   ruff format / ruff lint / mypy / pytest -- PASS or FAIL
```

---

## Done Checklist

- [ ] Standards loaded (`doc-writing.skill.md`).
- [ ] All affected documents identified.
- [ ] New guides created where needed.
- [ ] Existing guides updated where needed.
- [ ] `README.md` updated if script list or test counts changed.
- [ ] `architecture.md` updated if structure changed.
- [ ] `Changelog.md` updated (mandatory).
- [ ] No secrets or real paths in examples.
- [ ] Quality checks pass.
- [ ] Summary produced.

---

## Copilot Assets for This Workflow

| Asset | When to use |
| --- | --- |
| `agents/doc-writer.agent.md` | Automated documentation update after a change |
| `chatmodes/doc-writer.chatmode.md` | Interactive documentation writing session |
| `prompts/docs-update.prompt.md` | Quick targeted docs update prompt |
| `skills/doc-writing.skill.md` | Writing standards reference (load before editing) |
| `instructions/docs.instructions.md` | Audience and tone rules |
| `instructions/markdown.instructions.md` | Markdown style rules |
| `workflows/docstring-remediation.workflow.md` | For Python docstring work specifically |
| `workflows/standard-change.workflow.md` | Step 8 of the full standard change workflow |

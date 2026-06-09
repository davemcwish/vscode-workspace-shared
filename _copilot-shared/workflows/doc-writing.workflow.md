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
`workflows/docstring-writing.workflow.md` (for new code) or
`workflows/docstring-remediation.workflow.md` (for existing code) instead.

For auditing an existing guide's accuracy against the code (rather than writing
new content), use `workflows/doc-writer-remediation.workflow.md`.

---

## Standards Reference

Before writing anything, load these files:

- `.github/skills/doc-writing.skill.md` -- **all writing rules, format rules,
  accuracy rules, and Changelog format** (read this first)
- `.github/instructions/docs.instructions.md` -- audience, tone, accuracy rules
- `.github/instructions/markdown.instructions.md` -- Markdown style rules
- `.github/instructions/security.instructions.md` -- secrets and PII rules
- `architecture.md` -- current module and script structure

---

## Overview

```text
Establish CLI ground truth (--help)
  -> Identify what changed
  -> Load the writing standards
  -> Identify affected documents
  -> Write or update each document
  -> Update Changelog.md (mandatory)
  -> Run quality checks (including markdownlint)
  -> Review the diff
  -> Report

## Step 0: Establish CLI Ground Truth (Do This First)
For any script whose documentation you will touch, run its own help output BEFORE writing anything. This is the single most important accuracy step.

Bash

python scripts/<script_name>.py --help
Treat that output as the only source of truth for which flags exist, their exact spelling, their choices, and their defaults.

Rules:

- Never copy a CLI table from a sibling guide -- similar scripts often have legitimately different flags, and the sibling may itself be wrong.
- Never infer flags from memory or from similar projects.
- If --help cannot be run, stop and flag it for manual review.
You will use this captured output again in Step 4 (writing the table) and Step 7 (the 1:1 audit).

## Step 1: Identify What Changed
Determine which code, configuration, or tooling changed in the current session or branch.

With Copilot: ask the doc-writer agent or chatmode to discover changes robustly (do not rely on HEAD~1, which misses multi-commit or uncommitted work):

git diff --name-only main...HEAD
git status --short

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

It contains the audience definition, accuracy rules (including the CLI `--help`
rule), plain English rules, Markdown format rules, Changelog format rules, and
the "what to update for each change type" table.

If you skip this step, you risk writing documentation that is too technical,
incorrectly formatted, factually wrong, or missing required sections.

---

## Step 3: Identify Affected Documents

Use the change type table from `doc-writing.skill.md` to decide which
documents need updating.

Quick reference:

| Change type | Minimum documents to update |
| --- | --- |
| New script | Create `docs/<script_name>_guide.md`, update `README.md`, update `architecture.md` |
| Changed script behavior | Update `docs/<script_name>_guide.md` |
| New/changed CLI argument | Update relevant guide's CLI table (from `--help`) |
| New module in `src/` | Update `architecture.md` |
| New `.env` variable | Update `.env.example` and running guide |
| Removed file | Remove all references across docs |
| Any change | Update `Changelog.md` |

When in doubt, update the document. Accurate documentation is always
better than assuming something is still correct.

---

## Step 4: Write or Update Each Document

### 4a. Creating a new guide

Follow the New Script Guide Template in `doc-writing.skill.md`. Populate the CLI
Arguments table from the Step 0 `--help` output -- never from memory or a
sibling guide.

### 4b. Updating an existing guide

- Read the current guide first.
- Make the smallest accurate change that brings it in sync with the code.
- Do not rewrite sections that are still accurate.
- Update CLI tables from the Step 0 `--help` output if arguments changed.
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

Run the code quality gate:

```bash
ruff format --check src tests scripts
ruff check src tests scripts
mypy
pytest --tb=short -q

Then run the Markdown lint gate. This is mandatory, not optional -- it auto-fixes the two most common failures (MD022 blank lines around headings, MD032 blank lines around lists) and then fails if anything non-auto-fixable remains:

npx markdownlint-cli2 --fix "docs/**/*.md" "*.md"
npx markdownlint-cli2 "docs/**/*.md" "*.md"

The pytest run also executes tests/test_docs_cli_contract.py, which fails if a guide invents or omits a CLI flag. If it fails, return to Step 0 and re-audit.


**Part 5 of 5**

```markdown
## Step 7: Review the Diff

Before committing, confirm:

- [ ] Every changed file is intentional -- no accidental edits.
- [ ] No secrets, tokens, or real usernames appear in examples.
- [ ] Technical terms are explained at first use.
- [ ] Command examples are accurate and complete.
- [ ] **CLI tables pass the 1:1 audit against `--help`** (no invented rows,
      no omitted flags, defaults and choices match).
- [ ] Changelog entry references correct file paths.
- [ ] Markdown format is consistent and markdownlint passes.

---

## Step 8: Report

```text
Documentation Update Summary

Files Created:    | File | Purpose |
Files Updated:    | File | What Changed |
Not Changed:      | File | Reason |
CLI audit:        | Script | Flags confirmed | Mismatches fixed |
Changelog entry:  [date] added.
Quality checks:   ruff / mypy / pytest / markdownlint -- PASS or FAIL


## Done Checklist
 - CLI ground truth captured via --help (Step 0).
 - Standards loaded (doc-writing.skill.md).
 - All affected documents identified.
 - New guides created where needed.
 - Existing guides updated where needed.
 - CLI tables audited 1:1 against --help.
 - README.md updated if script list or test counts changed.
 - architecture.md updated if structure changed.
 - Changelog.md updated (mandatory).
 - No secrets or real paths in examples.
 - Code quality checks pass.
 - markdownlint passes (mandatory).
 - `test_docs_cli_contract.py` passes.
 - Summary produced.

## Copilot Assets for This Workflow

| Asset | When to use |
| --- | --- |
| `agents/doc-writer.agent.md` | Automated documentation update after a change |
| `chatmodes/doc-writer.chatmode.md` | Interactive documentation writing session |
| `prompts/docs-update.prompt.md` | Quick targeted docs update prompt |
| `prompts/docs-audit.prompt.md` | One-command accuracy audit of an existing guide |
| `skills/doc-writing.skill.md` | Writing standards reference (load before editing) |
| `instructions/docs.instructions.md` | Audience, tone, accuracy rules |
| `instructions/markdown.instructions.md` | Markdown style rules |
| `workflows/doc-writer-remediation.workflow.md` | Verify/fix an existing guide against the code |
| `workflows/docstring-writing.workflow.md` | For writing new Python docstrings |
| `workflows/docstring-remediation.workflow.md` | For remediating existing Python docstrings |
| `workflows/standard-change.workflow.md` | Step 8 of the full standard change workflow |


# Workflow: Documentation Remediation

## Purpose

Use this workflow to review and correct existing project documentation so it
matches the code exactly. Unlike `doc-writing.workflow.md` (which CREATES or
updates docs as part of a change), this workflow VERIFIES docs that already
exist and fixes any drift between what the docs claim and what the code does.

The goal is accuracy first, then beginner-friendliness. A beginner trusts the
documentation completely and cannot spot an invented flag or a wrong default, so
correctness is the priority of this workflow.

## Why This Workflow Is Different

A normal documentation pass and a remediation pass must use DIFFERENT methods,
or they fail the same way.

- The writing pass reads code and produces beginner prose.
- This remediation pass extracts ground truth deterministically (from `--help`,
  the argument parser, `.env.example`, and the test suite) and DIFFS the docs
  against it.

If a remediation pass simply re-reads the prose and rewrites it, it will repeat
the original hallucination -- two LLM passes using the same method produce
correlated errors, not independent ones. This workflow therefore anchors every
check to a program-generated source of truth, never to another document.

## When To Use This Workflow

Use this workflow when:

- a guide is suspected of being inaccurate (wrong, missing, or invented flags),
- onboarding revealed that the docs and the code disagree,
- before a release, to confirm all guides match shipped behaviour,
- after a refactor that changed CLI arguments or environment variables,
- periodically, as a scheduled documentation health check.

For writing brand-new documentation, use `doc-writing.workflow.md` instead.
For writing new Python docstrings, use `docstring-writing.workflow.md` instead.
For remediating existing Python docstrings, use
`docstring-remediation.workflow.md` instead.

---

## Primary Rule

Documentation remediation is anchored to authoritative, program-generated
sources -- never to another document.

Authoritative sources, in priority order:

1. **`python scripts/<name>.py --help`** -- the truth for CLI flags, choices,
   and defaults.
2. **The argument parser in the script's source** -- used only to confirm
   defaults and choices that `--help` formats ambiguously.
3. **`.env.example`** -- the truth for environment variable names.
4. **The test suite / `pytest --collect-only`** -- the truth for test counts.
5. **`architecture.md`** -- the truth for module and script structure.

You must NEVER treat a sibling guide, the README, or any other prose document as
a source of truth. Those are the things being checked, not the things you check
against.

---

## Standards Reference

Before remediating, load these files:

- `.github/skills/doc-writing.skill.md` -- writing, accuracy, and format rules
- `.github/instructions/docs.instructions.md` -- audience, tone, accuracy rules
- `.github/instructions/markdown.instructions.md` -- Markdown style rules
- `.github/instructions/security.instructions.md` -- secrets and PII rules

---

## Step 1: Choose the Scope

Decide what to remediate:

- one guide,
- all guides for a folder of scripts,
- every guide in `docs/`,
- the README and CONTRIBUTING,
- the whole documentation set.

Recommended beginner-friendly starting point:

```text
Remediate one script guide at a time.

---

## Step 2: Capture Ground Truth

For each script whose guide you are remediating, capture the authoritative
sources verbatim BEFORE looking at the guide's claims.

```bash
python scripts/<script_name>.py --help

Record:

- the exact set of flags (long and short),
- each flag's choices (e.g. text, csv, html),
- each flag's default value,
- whether each flag is required.

If the guide references environment variables, also capture them:

type .env.example   REM Windows
cat .env.example    # macOS/Linux

If the guide states a test count, capture the real number:

pytest --collect-only -q

Do not proceed until you have the ground truth in hand. Everything in the next step is a comparison against what you captured here.

## Step 3: Diff the Guide Against Ground Truth
Compare what the guide claims against what you captured. Do this comparison mechanically -- treat it as set arithmetic, not as a read-through.

For CLI flags:

- Invented = flags in the guide but NOT in --help.
- Omitted = flags in --help but NOT in the guide.
- Wrong default = flag present in both, default disagrees.
- Wrong choices = flag present in both, choices disagree.
- Wrong required/optional = flag present in both, requiredness disagrees.

For environment variables:
- variables named in the guide but absent from .env.example (or vice versa).

For test counts:
- the number stated in the guide vs the real collected count.

---

## Step 4: Categorise Findings

Use this table format (mirrors the docstring remediation categories):

| Category | Meaning | Example |
| --- | --- | --- |
| Invented | Documented but not in code | Guide lists `--no-excel`; `--help` has no such flag |
| Omitted | In code but not documented | `--use-outlook` exists but is missing from the table |
| Wrong default | Default disagrees with `--help` | Guide says default 30; `--help` says 90 |
| Wrong choices | Choices disagree with `--help` | Guide says `text, csv`; `--help` says `text, csv, html` |
| Wrong required | Requiredness disagrees | Guide marks `--recipients` optional; it is required |
| Stale env var | `.env` name disagrees | Guide says `SF_ALIAS`; `.env.example` says `SF_CLI_ALIAS` |
| Stale count | Test count disagrees | Guide says 142 tests; real count is 158 |
| Beginner gap | Accurate but not beginner-friendly | Uses SOQL with no inline explanation |

The first six categories are accuracy defects and must be fixed. The last is a
clarity defect -- fix it too, but never let a clarity rewrite introduce a new
accuracy defect.

---

## Step 5: Apply Fixes

For each finding:

1. Make the smallest change that corrects the fact.
2. Re-derive the corrected value from the ground truth captured in Step 2 --
   never from another document.
3. For omitted flags, write a new beginner-friendly row: explain what the flag
   does in plain English, give its default and choices, and say when a beginner
   would use it.
4. For invented flags, remove the row entirely (do not try to "make it true").
5. For beginner gaps, add inline explanations per `docs.instructions.md`
   (explain every technical term on first use).

Preserve all existing security and PII warnings. Never remove them.

---

## Step 6: Beginner-Friendliness Pass

Accuracy fixes can leave terse, technical wording behind. After the facts are
correct, confirm the guide still meets the beginner bar:

- [ ] One-paragraph plain-English summary at the top.
- [ ] Prerequisites listed.
- [ ] Step-by-step instructions with full command examples.
- [ ] Expected output shown.
- [ ] Troubleshooting for the two or three most common errors.
- [ ] A Glossary or Key Concepts section.
- [ ] Every technical term explained on first use (SOQL, org, alias, virtual
      environment, type hint, etc.).
- [ ] No real usernames, tokens, or personal paths in examples.

This pass is mandatory. Accuracy without beginner-friendliness fails the
project's documentation standard, and vice versa.

---

## Step 7: Run Validation

```bash
pytest tests/test_docs_cli_contract.py -q
npx markdownlint-cli2@0.22.1 --fix "docs/**/*.md" "*.md"
npx markdownlint-cli2@0.22.1 "docs/**/*.md" "*.md"

The contract test confirms your flag fixes are correct against --help. The markdownlint pair auto-fixes MD022/MD032 and then fails on anything remaining.

If you changed any embedded Python examples, also run the full gate:

ruff format --check src tests scripts
ruff check src tests scripts
mypy
pytest --tb=short -q

## Step 8: Update Changelog (Mandatory)
Do not skip this step.

Add a Changed or Fixed entry to Changelog.md describing the correction, referencing the exact guide path(s). Use the Keep a Changelog format from doc-writing.skill.md.

---

## Step 9: Review the Diff

Confirm:

- [ ] Every corrected fact was re-derived from ground truth, not a sibling doc.
- [ ] No invented flags remain.
- [ ] No real flags are omitted.
- [ ] Defaults, choices, and requiredness match `--help`.
- [ ] Environment variable names match `.env.example`.
- [ ] Test counts match the real collected count.
- [ ] Security and PII warnings are intact.
- [ ] Beginner-friendliness checklist passed.
- [ ] markdownlint and the contract test pass.

---

## Step 10: Report the Result

Use this format:

```markdown
# Documentation Remediation Summary

## Scope

[Guides reviewed.]

## Ground Truth Sources Used

- python scripts/<name>.py --help
- .env.example
- pytest --collect-only

## Findings and Fixes

| Guide | Category | Detail | Action |
| --- | --- | --- | --- |

## Beginner-Friendliness

[Confirmed pass, or list of clarity fixes made.]

## Validation

| Check | Result |
| --- | --- |
| test_docs_cli_contract.py | PASS/FAIL |
| markdownlint-cli2 | PASS/FAIL |

## Changelog

[Entry added - date and file paths.]

## Done Checklist
 - Scope selected.
 - Standards loaded.
 - Ground truth captured from --help, .env.example, test suite.
 - Guide diffed against ground truth (set arithmetic).
 - Findings categorised.
 - Accuracy fixes applied (re-derived from ground truth).
 - Beginner-friendliness pass completed.
 - Validation passed (contract test + markdownlint).
 - Changelog updated (mandatory).
 - Diff reviewed.
 - Summary produced.

## Copilot Assets for This Workflow
Asset When to use
prompts/docs-audit.prompt.md One-command trigger for this audit
agents/doc-writer.agent.md Apply the fixes after the audit identifies them
skills/doc-writing.skill.md Writing and accuracy standards reference
instructions/docs.instructions.md Audience, tone, accuracy rules
workflows/doc-writing.workflow.md For creating/updating docs during a change
workflows/docstring-remediation.workflow.md For Python docstring work specifically


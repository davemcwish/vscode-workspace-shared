---
description: "Audit an existing guide for accuracy against the script's own --help, then report and fix drift."
mode: agent
---

<!-- markdownlint-disable MD041 -->

Audit the accuracy of an existing documentation guide against the code it
describes. Do NOT rewrite the guide from scratch and do NOT trust any sibling
document - verify everything against program-generated ground truth.

Follow `workflows/doc-writer-remediation.workflow.md` for the full method.

## Step 1: Capture ground truth

For the script(s) behind the guide under review, run and capture verbatim:

```bash
python scripts/<script_name>.py --help
```

If the guide mentions environment variables, also read .env.example. If the guide states a test count, run pytest --collect-only -q.

Treat these program-generated sources as the ONLY source of truth. Never treat a sibling guide, the README, or any prose document as authoritative.

## Step 2: Diff the guide against ground truth

Compare the guide's CLI table to --help as set arithmetic:

Invented - in the guide but not in --help.
Omitted - in --help but not in the guide.
Wrong default - default disagrees with --help.
Wrong choices - choices disagree with --help.
Wrong required - requiredness disagrees with --help.
Also check environment variable names against .env.example and any stated test count against the real collected count.

## Step 3: Report findings

Produce this table before changing anything:

| Guide | Category | Detail | Suggested fix |
| --- | --- | --- | --- |

## Step 4: Apply fixes

For each accuracy finding:

1. Make the smallest change that corrects the fact.
2. Re-derive every corrected value from the ground truth captured in Step 1  -
   never from another document.
3. For omitted flags, add a beginner-friendly row: explain in plain English what
   the flag does, its default and choices, and when a beginner would use it.
4. For invented flags, remove the row entirely.
5. Preserve all existing security and PII warnings.

## Step 5: Beginner-friendliness check

After facts are correct, confirm the guide still explains every technical term
on first use (SOQL, org, alias, virtual environment, type hint, etc.) and keeps
its summary, prerequisites, steps, expected output, troubleshooting, and
glossary sections.

## Step 6: Validate and record

Run:

```bash
pytest tests/test_docs_cli_contract.py -q
npx markdownlint-cli2@0.22.1 --fix "docs/**/*.md" "*.md"
npx markdownlint-cli2@0.22.1 "docs/**/*.md" "*.md"
```

Then add a Fixed or Changed entry to Changelog.md referencing the exact guide path(s).

## Output

Summarise: guides audited, findings by category, fixes applied, validation result (contract test + markdownlint), and the Changelog entry added.

## Output format

Return:

```markdown
# Documentation Audit

## Verdict

PASS / NEEDS FIXES / HIGH DRIFT

## Summary

Short plain-English summary of accuracy and completeness across the guides
reviewed.

## Ground Truth Sources

| Source | Command or File | Captured? |
| --- | --- | --- |

## Findings

| Guide | Category | Detail | Suggested Fix |
| --- | --- | --- | --- |

## Fixes Applied

| Guide | Line/Section | Change Made | Derived From |
| --- | --- | --- | --- |

## Validation Results

| Check | Status | Notes |
| --- | --- | --- |
| Contract test (test_docs_cli_contract.py) | PASS/FAIL/SKIPPED |  |
| markdownlint | PASS/FAIL |  |

## Changelog Entry

[Entry added to Changelog.md, or explanation if not added.]

## Remaining Issues

| Guide | Issue | Why Not Fixed | Recommended Next Step |
| --- | --- | --- | --- |
```

## Output style rules

Use beginner-friendly language.

Explain what "drift" means: the documentation says something different from what
the code actually does.

Do not invent ground-truth output, test results, or CLI flags.

Do not change runtime behaviour while fixing documentation.

Clearly separate accuracy fixes (facts wrong) from clarity improvements (prose
weak).

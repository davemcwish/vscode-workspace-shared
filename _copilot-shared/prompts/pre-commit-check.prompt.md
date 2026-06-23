---
description: "Run and interpret the full project sanity checks before commit."
mode: agent
---

<!-- markdownlint-disable MD041 -->

Run the project's pre-commit sanity workflow.

## Canonical Quality Gate

Run `sanity.bat` from the project root - it mirrors `ci.yml` and runs the full
gate (ruff format, ruff lint, mypy, bandit, detect-secrets, pytest + coverage
with `--cov-fail-under=90`). If `sanity.bat` is unavailable, run the equivalent
commands listed in `copilot-instructions.md` § Canonical Quality Gate.

If any command fails:

- Stop.
- Explain the failure in beginner-friendly terms.
- Identify the likely cause.
- Propose the smallest safe fix.
- Do not continue to later steps until the failure is addressed.

If everything passes:

- Summarize the result.
- Suggest a conventional commit message.
- Remind the user not to commit `.env`, generated reports, logs, CSVs, ZIPs, or PDFs.

## Output format

Return:

```markdown
# Pre-Commit Check

## Verdict

PASS / FAIL

## Summary

Short plain-English summary of what happened and whether it is safe to commit.

## Gate Results

| Step | Tool | Status | Notes |
| --- | --- | --- | --- |
| 1 | ruff format | PASS/FAIL |  |
| 2 | ruff check | PASS/FAIL |  |
| 3 | mypy | PASS/FAIL |  |
| 4 | bandit | PASS/FAIL |  |
| 5 | detect-secrets | PASS/FAIL |  |
| 6 | pytest + coverage | PASS/FAIL |  |

## Failures (if any)

| Step | Error | Beginner Explanation | Suggested Fix |
| --- | --- | --- | --- |

## Coverage Summary

| Metric | Value |
| --- | --- |
| Overall coverage | X% |
| Threshold | 90% |
| Status | PASS/FAIL |

## Suggested Commit Message

[Conventional commit format: type(scope): description]

## Reminders

- [ ] Do not commit `.env`, generated reports, logs, CSVs, ZIPs, or PDFs.
- [ ] Review staged files before committing.
```

## Output style rules

Use beginner-friendly language.

Explain linter and type-checker errors in plain English.

Do not suggest suppressing warnings unless the suppression is justified and safe.

Do not continue past a failure without explaining it.

Do not invent test results, coverage numbers, or error messages.

---
description: "Improve beginner-friendly Python docstrings without changing runtime behavior."
mode: agent
---

Improve docstrings in the selected Python file, folder, or changed files.

## Primary Goal

Make the code easier for beginner developers and beginner Salesforce users to
understand — while ensuring every claim is accurate.

Do not change runtime behavior.

## Accuracy Before Prose (The Two Jobs)

Docstrings have two distinct jobs:

1. **WHAT the code does** — parameters, returns, exceptions, side effects.
   A matter of FACT. Read the implementation to confirm.
2. **HOW to explain it** — beginner prose, examples, domain context.
   Applied ONLY to facts confirmed in job 1.

**Before improving any docstring, read the function's implementation to
establish ground truth.** Never improve wording while leaving inaccurate
facts intact — fix facts first, then improve clarity.

### Never Invent to Fill a Gap

If you are unsure whether a function raises a particular exception, returns a
specific type, or has a certain side effect — do NOT write a plausible-sounding
description. Either confirm it from the code, or leave it out and flag it for
manual review.

### Never Copy from a Sibling Function

Similar functions often have different behavior. Always read the target
function's own implementation.

## Allowed Changes

You may change:

- module docstrings,
- class docstrings,
- function and method docstrings,
- complex pytest fixture docstrings,
- explanatory comments that clarify business rules, Salesforce safety, or PII
  handling.

You must not change:

- executable code,
- imports,
- function signatures,
- type hints,
- CLI arguments,
- tests,
- configuration,
- output formats,
- behavior.

If you believe code behavior should change, stop and ask whether to create a
separate code-change task.

## Standards To Follow

Use:

- `.github/instructions/python.instructions.md`
- `.github/instructions/docstrings.instructions.md`
- `.github/skills/docstring.skill.md`
- `.github/instructions/salesforce.instructions.md`
- `.github/instructions/security.instructions.md`
- `.github/instructions/testing.instructions.md`

If one of those files does not exist, follow the closest available project
standard.

## What To Improve

For each selected Python file:

1. **Read the implementation first** — establish ground truth.
2. Then check the existing docstring using a 1:1 audit:
   - **Invented** — claims something the code does not do → remove.
   - **Omitted** — code does something undocumented → add.
   - **Wrong type** — disagrees with implementation → correct.
   - **Stale** — describes old behaviour → rewrite from implementation.
   - **Too terse** — useless to a beginner → expand with plain English.
   - **Missing** — no docstring → add.

Also check:

3. Module docstring.
4. Class docstrings.
5. Function and method docstrings.
6. CLI `parse_args()` docstring.
7. CLI `main()` docstring.
8. Complex pytest fixture docstrings.
9. Missing `Args`, `Returns`, `Raises`, or `Example` sections.
10. Salesforce terms that need plain-English explanation.
11. PII, Production, dry-run, or security behavior that needs explanation.

## Required Style

Use Google-style docstrings.

Example:

```python
def write_csv_report(rows: list[dict[str, object]], output_path: Path) -> None:
    """Write report rows to a CSV file.

    This function creates a comma-separated values file that can be opened in
    Excel. The rows may contain Salesforce data, so callers must avoid writing
    the file to a public or shared location unless the data has been approved
    for sharing.

    Args:
        rows: Report rows to write. Each dictionary represents one CSV row.
        output_path: File path where the CSV file should be created.

    Returns:
        None. The function writes the report to `output_path`.

    Raises:
        OSError: Raised when the file cannot be written, for example because the
            folder does not exist or the user does not have permission.

    Example:
        ```python
        write_csv_report(rows, Path("output/report.csv"))
        ```
    """
```

## Beginner-Friendly Requirements

Docstrings should:

- explain what the function does,
- explain why it exists,
- explain each argument in plain English,
- explain return values,
- explain exceptions,
- explain Salesforce terms on first use (see term tables in `docstring.skill.md`),
- explain Python terms on first use for less common concepts,
- explain safety behavior,
- avoid unexplained acronyms,
- avoid saying only "does X" when the purpose is not obvious.

## Salesforce-Specific Requirements

If code touches Salesforce, explain:

- whether it is read-only or mutating,
- which Salesforce object is queried or changed,
- whether Production is allowed,
- whether dry-run is supported,
- whether records may contain PII,
- whether API calls are retried,
- whether pagination is handled.

## Test-Specific Requirements

For test files:

- add a module docstring explaining what is under test,
- add fixture docstrings for non-trivial fixtures,
- explain mocks in plain English,
- explain that tests must not contact real Salesforce orgs.

## Output

After editing, return:

```markdown
# Docstring Improvement Summary

## Ground Truth Method

All docstrings re-derived from reading each function's implementation.
No existing docstring or sibling function used as source of truth.

## Files Updated

| File | What Changed |
| --- | --- |

## Accuracy Fixes

| File | Function | Category | Detail |
| --- | --- | --- | --- |

## Files Reviewed But Not Changed

| File | Reason |
| --- | --- |

## Behavior Change

None. This was a docstring/comment-only update.

## Follow-Up Recommendations

- [Any code behavior that was unclear but not changed.]
```

## Validation

After editing, run or ask the user to run:

```bash
ruff format --check src tests scripts
ruff check src tests scripts
mypy
pytest --tb=short -q
```

If a validation failure appears unrelated to the docstring changes, report it
clearly instead of changing unrelated code.

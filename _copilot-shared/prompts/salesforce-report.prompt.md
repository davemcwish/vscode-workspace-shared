---
description: "Create a read-only Salesforce reporting script with CSV output."
mode: agent
---

<!-- markdownlint-disable MD041 -->

Create a read-only Salesforce reporting script.

The script must:

1. Use `build_client(org)` from `sf_admin_utils.salesforce_client`.
2. Use `with_retry()` for Salesforce API calls.
3. Accept `--org {uat,prod}`.
4. Accept `--output` for optional CSV output.
5. Not modify Salesforce data.
6. Log only record IDs and counts by default.
7. Write PII only to an explicit output file.
8. Include summary statistics.
9. Create parent directories for output files.
10. Include beginner-friendly Google-style docstrings and type hints.

Docstring requirements:

1. Add beginner-friendly Google-style docstrings for every new module, class,
   function, and complex test fixture.
2. Review nearby existing docstrings and improve any that are missing, stale,
   misleading, or too terse.
3. Do not change runtime behaviour while improving docstrings.
4. Explain Salesforce, Python, and business terms in plain English.

The tests must:

1. Mock Salesforce calls.
2. Verify SOQL query construction.
3. Verify CSV output.
4. Verify summary statistics.
5. Verify empty-result behavior.
6. Verify argument parsing.
7. Verify no real org is contacted.

The documentation must include:

1. Purpose.
2. Prerequisites.
3. CLI examples.
4. CSV columns.
5. Troubleshooting.
6. PII handling notes.

## Output format

After completing the script, return:

```markdown
# Salesforce Report Script Summary

## Script Created

| Field | Value |
| --- | --- |
| Script path | `scripts/<name>.py` |
| Purpose | [One sentence] |
| Salesforce objects | [Objects queried] |
| Read-only | Yes |
| CSV output | [Columns produced] |
| PII handling | [How PII is handled] |

## SOQL Query

[The query used, with explanation of what it retrieves.]

## Implementation Decisions

| Decision | Reasoning |
| --- | --- |

## Reused Modules

| Module | What Was Reused |
| --- | --- |

## Tests Created

| Test File | Key Cases | Coverage |
| --- | --- | --- |

## Documentation Created

| File | What It Covers |
| --- | --- |

## Validation Results

| Check | Status |
| --- | --- |
| ruff format | PASS/FAIL |
| ruff check | PASS/FAIL |
| pytest | PASS/FAIL |
| mypy | PASS/FAIL |

## Risks or Limitations

| Risk | Mitigation |
| --- | --- |

## Next Steps

1. [Any follow-up actions needed]
```

## Output style rules

Use beginner-friendly language.

Explain Salesforce objects, SOQL syntax, and API behaviour in plain English.

Do not invent test results, SOQL responses, or validation outcomes.

Do not claim the script is Production-safe without evidence from the
implementation and tests.

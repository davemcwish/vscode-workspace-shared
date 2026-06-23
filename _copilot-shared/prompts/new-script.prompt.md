---
description: "Scaffold a new Salesforce admin utility script."
mode: agent
---

<!-- markdownlint-disable MD041 -->

Create a new script under `scripts/` that performs the task I describe next.

Before editing files:

1. Present a numbered plan.
2. List existing modules that can be reused.
3. Identify whether the script is read-only or mutating.
4. Identify Production safety risks.
5. List tests to add or update.

Implementation requirements:

1. Use `argparse`.
2. Include `--org {uat,prod}`.
3. For read-only scripts, make `--apply` either absent or a clearly logged no-op.
4. For mutating scripts, default to dry-run behavior and require `--apply`.
5. Use `build_client(org)` from `sf_admin_utils.salesforce_client`.
6. Use `with_retry()` for Salesforce API calls.
7. Use `configure_logging()` from `sf_admin_utils.logging_setup`.
8. Add a module-level logger.
9. Add type hints.
10. Add beginner-friendly Google-style docstrings.
11. Include `main()` and an `if __name__ == "__main__"` guard.
12. Do not log PII unless explicitly required by the task.

Docstring requirements:

1. Add beginner-friendly Google-style docstrings for every new module, class,
   function, and complex test fixture.
2. Review nearby existing docstrings and improve any that are missing, stale,
   misleading, or too terse.
3. Do not change runtime behaviour while improving docstrings.
4. Explain Salesforce, Python, and business terms in plain English.

Testing requirements:

1. Create tests under `tests/test_<script_name>.py`.
2. Use `pytest`.
3. Mock Salesforce calls.
4. Mock subprocess or CLI auth if needed.
5. Cover success paths, empty results, invalid arguments, and error paths.
6. Aim for at least 90% coverage for the new script.

Documentation requirements:

1. Create or update a Markdown guide under `docs/`.
2. Explain the script for beginner Python and Salesforce users.
3. Include setup, command examples, output, troubleshooting, and glossary.
4. Update `README.md` usage section.
5. Update `Changelog.md` if present.
6. Update `CONTRIBUTING.md` if the workflow changes.

Before finishing, run or ask the user to run:

```bat
ruff check src tests scripts
ruff format src tests scripts
pytest
mypy src tests scripts
```

## Output format

After completing the script, return:

```markdown
# New Script Summary

## Script Created

| Field | Value |
| --- | --- |
| Script path | `scripts/<name>.py` |
| Purpose | [One sentence] |
| Read-only or mutating | [Read-only / Mutating (dry-run by default)] |
| Salesforce objects | [Objects queried or modified] |
| Production safety | [Safe / Requires --apply / Not applicable] |

## Implementation Decisions

| Decision | Reasoning |
| --- | --- |

## Reused Modules

| Module | What Was Reused |
| --- | --- |

## Tests Created

| Test File | Coverage | Key Cases |
| --- | --- | --- |

## Documentation Created or Updated

| File | Change |
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

Explain Salesforce objects, API behaviour, and Python patterns in plain English.

Do not invent test results or validation outcomes.

Do not claim Production safety without evidence from the implementation.

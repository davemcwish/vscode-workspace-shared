---
description: "Add or improve pytest coverage for a selected module."
mode: agent
---

For the file currently in focus:

1. Identify whether the file is:
   - shared library code under `src/`,
   - a standalone script under `scripts/`,
   - a test helper,
   - documentation-adjacent code.

2. Report current coverage for the relevant file.

3. List untested:
   - success paths,
   - empty inputs,
   - invalid inputs,
   - exception paths,
   - logging behavior,
   - Production-safety behavior,
   - Salesforce API edge cases.

4. Add or update pytest tests.

5. For Salesforce-related code (follow `salesforce.instructions.md`):
   - never hit a real org,
   - mock `subprocess.run` during module load (prevents CLI auth),
   - mock `requests.get` and `requests.Session` for all HTTP calls,
   - do NOT use or mock `simple_salesforce` - this project uses `requests`
     directly via `sf_get()` / `build_client()`,
   - use `sf_env` for alias environment variables.

6. For standalone scripts in `scripts/`, load modules with `importlib` if direct
   import is not appropriate.

7. Prefer parametrized tests for repeated input/output cases.

8. Docstring requirements:
   - Add beginner-friendly Google-style docstrings to every new or modified
     test fixture.
   - Review existing fixture and test module docstrings and improve any that
     are missing, stale, misleading, or too terse.
   - Do not change runtime behaviour while improving docstrings.
   - Explain Salesforce, Python, and business terms in plain English.

9. Re-run:

```bat
ruff check src tests scripts
pytest
mypy src tests scripts
```

## Output format

Return:

```markdown
# Test Coverage Summary

## Verdict

PASS / NEEDS MORE COVERAGE / BLOCKED

## Summary

Short plain-English summary of what was tested and the coverage outcome.

## File Under Test

| Field | Value |
| --- | --- |
| File | [path] |
| Type | [Library / Script / Helper] |
| Previous coverage | [X% or Unknown] |
| New coverage | [X%] |

## Tests Added

| Test File | Test Name | What It Covers |
| --- | --- | --- |

## Paths Covered

| Path Type | Covered? | Notes |
| --- | --- | --- |
| Success paths | Yes/Partial/No |  |
| Empty inputs | Yes/Partial/No/N/A |  |
| Invalid inputs | Yes/Partial/No/N/A |  |
| Exception paths | Yes/Partial/No |  |
| Logging behaviour | Yes/Partial/No/N/A |  |
| Production-safety | Yes/Partial/No/N/A |  |
| Salesforce edge cases | Yes/Partial/No/N/A |  |

## Mocks Used

| Mock Target | Why Mocked |
| --- | --- |

## Validation Results

| Check | Status |
| --- | --- |
| ruff check | PASS/FAIL |
| pytest | PASS/FAIL |
| mypy | PASS/FAIL |

## Remaining Gaps

| Gap | Why Not Covered | Recommended Action |
| --- | --- | --- |
```

## Output style rules

Use beginner-friendly language.

Explain what each mock does and why it exists in plain English.

Do not invent coverage numbers or test results.

Do not claim full coverage without evidence from the test run.

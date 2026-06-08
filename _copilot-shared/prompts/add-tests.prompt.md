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

5. For Salesforce-related code:
   - never hit a real org,
   - mock `subprocess.run`,
   - mock `simple_salesforce.Salesforce`,
   - mock `requests.get` and `requests.Session` where used,
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

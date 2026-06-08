---
description: "Run and interpret the full project sanity checks before commit."
mode: agent
---

Run the project's pre-commit sanity workflow.

##  Canonical Quality Gate

Use this order:

ruff format --check src tests scripts
ruff check src tests scripts
mypy
bandit -c pyproject.toml -r src scripts --exclude scripts/archive,tests
python -m detect_secrets scan --baseline .secrets.baseline
pytest --tb=short -q
pytest --cov=src --cov=scripts --cov-report=term-missing --cov-fail-under=90

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

---
description: "Run and interpret the full project sanity checks before commit."
mode: agent
---

Run the project's pre-commit sanity workflow.

##  Canonical Quality Gate

Run `sanity.bat` from the project root — it mirrors `ci.yml` and runs the full
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

# Contributing Guide

<!--
  SCAFFOLD TEMPLATE - fill in the sections marked [FILL IN].
  This file was copied from _copilot-shared\scaffold\CONTRIBUTING.md.
-->

Thank you for contributing to [Project Name]. This guide explains how to set up
a development environment, what standards the project follows, and how to get
your changes merged.

---

## Setting Up the Development Environment

[FILL IN: Step-by-step from a fresh clone to a working local environment.
 Include how to install a virtual environment, dependencies, and run the tests
 once to confirm everything works.]

---

## Code Standards

This project follows the standards in `.github/copilot-instructions.md`. Key
points:

- Language: [FILL IN: e.g. Python 3.13+]
- Formatter / linter: [FILL IN: e.g. ruff]
- Type checking: [FILL IN: e.g. mypy]
- Testing: [FILL IN: e.g. pytest with ≥90% coverage]
- Docstrings: written for complete beginners - explain every parameter, return
  value, and exception in plain English
- Secrets: never commit credentials, tokens, or real usernames
- Cross-platform: code must run on both Windows (local dev) and Linux
  (CI/CD and security scanning); use `pathlib.Path` for paths and always
  specify `encoding='utf-8'` on file opens

---

## Running the Quality Gate

Run the full quality gate before every commit:

```bat
sanity.bat
```

This runs: ruff format check, ruff lint, mypy, bandit, detect-secrets, and
pytest. All checks must pass before raising a pull request. The same checks
run automatically in CI (`ci.yml`).

For verbose output (useful when debugging a failure):

```bat
sanity_v.bat
```

---

## Pull Request Process

1. Create a branch from `main` with a descriptive name.
2. Make your changes, add or update tests, and update documentation.
3. Run `sanity.bat` - all checks must pass locally before opening a PR.
4. Open a pull request with a clear description of what changed and why.
5. Address any review comments.
6. A maintainer will merge once all checks pass and the review is approved.

**Note:** Cycode security scanning runs automatically on every PR and blocks
merge on any finding. Cycode violations are treated as 🔴 CRITICAL and must
be fixed before merge. See `security.instructions.md` for the patterns that
satisfy Cycode's SAST rules.

---

## Updating Dependencies

See [UPDATING_DEPENDENCIES.md](./UPDATING_DEPENDENCIES.md).

---

## Reporting Issues

[FILL IN: Where and how to report bugs (e.g. GitHub Issues, internal tracker).
 Include what information to include in a bug report.]

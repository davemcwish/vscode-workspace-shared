<!-- markdownlint-disable MD024 -->
# PR Group B Review - CI and Quality Gates

**Project:** eu-crm-sf-admin-utils
**Prepared by:** Release / PR Planner (GitHub Copilot)
**Date:** 2026-05-29
**Status:** ✅ Complete - branch `chore/group-b-ci`, PR open, CI green (pending merge).
All 468 tests pass locally. 20 cross-platform failures (Linux CI vs Windows dev)
fixed on this branch before push.

---

## What Is This Document?

This document is the planning and review pack for **PR Group B - CI and Quality
Gates**. It is written for three audiences:

- **Developers** implementing the changes.
- **Test engineers** writing or updating the test harnesses.
- **Beginners** who may not be familiar with CI or YAML configuration files.

Read the whole document before starting any work. Items B1, B2, and B3 are
tightly related and should be implemented on a **single branch** in one PR.

> **Recommendation:** Use the `infra-guide` chat mode for the implementation.
> It will explain each step in plain English before asking you to write any
> code. See [Starting the Implementation](#starting-the-implementation) at the
> bottom of this document.

---

## Plain-English Summary

Group B adds automated CI (Continuous Integration) to the repository. Right
now, code quality checks only run when a developer remembers to run
`sanity.bat` locally. If they forget, broken code - failing tests, type errors,
security findings - can reach the repository undetected.

GitHub Actions solves this by running the same six checks automatically every
time a commit is pushed. No manual step required.

**B1** creates the workflow file.
**B2** ensures `sanity.bat` and the workflow use identical commands.
**B3** documents the new workflow in `CONTRIBUTING.md`.

All three items belong in one PR because they form a single coherent change: a
CI workflow that does not exist yet should not be merged without its
documentation, and the commands in `sanity.bat` should be aligned at the same
time to avoid a two-PR window where they are out of sync.

---

## Pre-Work Checks

Run these before creating the branch to confirm the starting state.

| Check | Expected result | Command |
| --- | --- | --- |
| On `main`, clean tree | No staged or unstaged changes | `git status` |
| `sanity.bat` passes | Exit code 0 | `.\sanity.bat` |
| `.github/workflows/` does not exist | Directory absent | `Test-Path .github\workflows` -> `False` |
| No existing CI workflow | No `.yml` files in `.github/workflows/` | (directory does not exist yet) |

> **If `sanity.bat` is red before you start, stop.** Fix the pre-existing
> failure on `main` before opening the Group B branch.

---

## Recommended Implementation Order

```text
B1 (create ci.yml)
  -> B2 (align sanity.bat commands)
    -> B3 (document in CONTRIBUTING.md)
```

All three are implemented on one branch (`chore/group-b-ci`) and merged in a
single PR.

---

## ⚠️ Command Discrepancy - Action Required in B2

The `docs/github-actions-guide.md` published in commit 5f1663d contains
simplified example commands that **do not exactly match** what `sanity.bat`
runs. The table below shows the differences. The **sanity.bat column is the
source of truth** - `ci.yml` must match `sanity.bat`, not the guide examples.

| Step | `sanity.bat` (source of truth) | `github-actions-guide.md` example | Action |
| --- | --- | --- | --- |
| ruff format | `ruff format --check src tests scripts` | `ruff format --check .` | Use `sanity.bat` command in `ci.yml`; fix guide in B2 |
| ruff lint | `ruff check src tests scripts` | `ruff check .` | Use `sanity.bat` command in `ci.yml`; fix guide in B2 |
| mypy | `mypy` | `mypy` | ✅ Match |
| bandit | `bandit -c pyproject.toml -r src scripts --exclude scripts/archive,tests --quiet` | `bandit -r src/ scripts/ -ll` | Use `sanity.bat` command in `ci.yml`; fix guide in B2 |
| detect-secrets | `detect_secrets scan --baseline .secrets.baseline` | `detect-secrets audit .secrets.baseline` | Use `sanity.bat` command in `ci.yml`; fix guide in B2 |
| pytest | `pytest -n auto --cov=src --cov=scripts --cov-report=term-missing` | `pytest --tb=short` | Use `sanity.bat` command in `ci.yml`; fix guide in B2 |

> The `-n auto` flag on pytest requires the `pytest-xdist` package.
> Confirm it is in `requirements-dev.txt` before using it in CI - if not,
> drop the flag in `ci.yml` only and note the difference.

**Additional B2 action:** Update `docs/github-actions-guide.md` to replace all
incorrect example commands with the correct `sanity.bat` equivalents. This is a
doc fix, not a behaviour change, and belongs in the same PR.

---

## Item B1 - Add GitHub Actions CI Workflow

### Goal

Create `.github/workflows/ci.yml` that runs the same six quality-gate steps as
`sanity.bat` automatically on every push and pull request.

### Size

**S** - One new file, ~45 lines of YAML. No Python changes.

### Branch

`chore/group-b-ci`

### Files to Create or Change

| File | Change type | Description |
| --- | --- | --- |
| `.github/workflows/ci.yml` | **Create** | New GitHub Actions workflow |

### Correct ci.yml Content

```yaml
name: CI

on:
  push:
    branches: ["**"]
  pull_request:
    branches: ["**"]

jobs:
  quality-gate:
    name: Quality Gate
    runs-on: ubuntu-latest

    steps:
      - name: Check out code
        uses: actions/checkout@v4

      - name: Set up Python 3.12
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements-dev.txt
          pip install -e .

      - name: ruff format check
        run: ruff format --check src tests scripts

      - name: ruff lint
        run: ruff check src tests scripts

      - name: mypy type check
        run: mypy

      - name: bandit security scan
        run: bandit -c pyproject.toml -r src scripts --exclude scripts/archive,tests --quiet

      - name: detect-secrets scan
        run: python -m detect_secrets scan --baseline .secrets.baseline

      - name: pytest
        run: pytest -n auto --cov=src --cov=scripts --cov-report=term-missing
```

> **Note on `detect_secrets`:** `sanity.bat` invokes it as `detect_secrets`
> (underscores) via `%PY_CMD% -m detect_secrets`. In the workflow, use
> `python -m detect_secrets` for the same behaviour. Do not use the
> `detect-secrets` hyphenated form as a bare command - it may not be on `PATH`
> in the CI runner.
>
> **Note on `-n auto`:** This requires `pytest-xdist`. Verify with:
> `grep pytest-xdist requirements-dev.txt`. If absent, use `pytest` with no
> parallel flag in `ci.yml` and add a note in the PR description.

### How to Implement

1. Create branch: `git checkout -b chore/group-b-ci`
2. Create directory: `New-Item -ItemType Directory -Path .github\workflows`
3. Create `.github/workflows/ci.yml` with the content above.
4. Validate YAML syntax:

   ```powershell
   py -3.12 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"
   ```

5. Commit this file alone before starting B2.

### Gotchas

- YAML uses spaces for indentation - never tabs. One wrong space breaks the
  entire file silently until GitHub tries to parse it.
- `actions/checkout@v4` and `actions/setup-python@v5` are pinned to major
  versions. This is intentional - major versions receive security patches
  without breaking changes.
- The `pip install -e .` step is required. Without it, `import sf_admin_utils`
  fails in tests because the package is not on the runner's Python path.

### Risks

| Risk | Mitigation |
| --- | --- |
| YAML syntax error blocks all PRs after merge | Validate locally before pushing; test on the feature branch first |
| `pytest-xdist` not available in CI | Check `requirements-dev.txt` before writing the `pytest` step |
| `detect_secrets` module name vs command name confusion | Always use `python -m detect_secrets` in the workflow |

### Rollback

Delete `.github/workflows/ci.yml` and push. The workflow disappears immediately.
No other files are affected.

### Tests for the Test Engineer

B1 introduces no Python source changes. No new unit tests are required.
The validation is observational: push the branch to GitHub and confirm the
Actions tab shows a green run.

---

## Item B2 - Align sanity.bat and CI Commands

### Goal

Ensure `sanity.bat` and `ci.yml` run identical commands for every step, so a
green local run predicts a green CI run. Also fix the incorrect example commands
in `docs/github-actions-guide.md`.

### Size

**XS** - Comparison and possible one-line tweaks to `sanity.bat` plus doc
corrections. No logic changes.

### Branch

Same branch: `chore/group-b-ci`

### Files to Create or Change

| File | Change type | Description |
| --- | --- | --- |
| `sanity.bat` | **Possibly edit** | Update any flags that differ from `ci.yml` |
| `docs/github-actions-guide.md` | **Edit** | Replace simplified example commands with correct `sanity.bat` equivalents |

### How to Implement

1. Open `sanity.bat` and `ci.yml` side by side.
2. Compare each step using the discrepancy table in the
   [⚠️ Command Discrepancy](#️-command-discrepancy--action-required-in-b2) section above.
3. The current `sanity.bat` commands are already correct - `ci.yml` must be
   written to match them (done in B1 above using the correct commands).
4. Update `docs/github-actions-guide.md`:
   - Replace `ruff format --check .` with `ruff format --check src tests scripts`
   - Replace `ruff check .` with `ruff check src tests scripts`
   - Replace `bandit -r src/ scripts/ -ll` with
     `bandit -c pyproject.toml -r src scripts --exclude scripts/archive,tests --quiet`
   - Replace `detect-secrets audit .secrets.baseline` with
     `python -m detect_secrets scan --baseline .secrets.baseline`
   - Replace `pytest --tb=short` with
     `pytest -n auto --cov=src --cov=scripts --cov-report=term-missing`
   - Update the comparison table in the "Step 5 - Align" section to reflect the
     correct commands.
5. Commit the guide fix: `docs: fix command examples in github-actions-guide.md`

### Gotchas

- `sanity.bat` is the source of truth. If the commands differ, update `ci.yml`
  to match `sanity.bat` - not the other way around.
- The `detect-secrets` package installs both `detect-secrets` (CLI entry point)
  and the `detect_secrets` Python module. On Linux CI runners, the entry point
  may not be on `PATH` - use `python -m detect_secrets` to be safe.

### Risks

| Risk | Mitigation |
| --- | --- |
| Divergence reintroduced in the future | Add a comment in both files: "Keep this command in sync with the other file" |

### Rollback

Revert the guide file change. `sanity.bat` changes (if any) are trivial to
revert with `git checkout -- sanity.bat`.

### Tests for the Test Engineer

No new unit tests. Verification: run `.\sanity.bat` locally (green) and confirm
it predicts the CI result after push.

---

## Item B3 - Document CI Workflow in CONTRIBUTING.md

### Goal

Add a section to `CONTRIBUTING.md` that explains the GitHub Actions CI workflow
to future contributors: what it checks, how to interpret its output, and how
both CI and Cycode must pass before a PR can be merged.

### Size

**XS** - Documentation only. No code changes.

### Branch

Same branch: `chore/group-b-ci`

### Files to Create or Change

| File | Change type | Description |
| --- | --- | --- |
| `CONTRIBUTING.md` | **Edit** | Add "Automated CI Checks" section after the existing quality checks table |

### Correct CONTRIBUTING.md Addition

Insert the following section immediately after the "If a check fails" table
(after the existing `sanity.bat` step table, before "Adding new code"):

```markdown
### Automated CI Checks

Every push to any branch triggers a **GitHub Actions** workflow
(`.github/workflows/ci.yml`) that runs the same six checks as `sanity.bat`:

| Step | Tool | What it checks |
| --- | --- | --- |
| 1 | ruff format | Code formatting |
| 2 | ruff lint | Code style and imports |
| 3 | mypy | Type hints |
| 4 | bandit | Security anti-patterns |
| 5 | detect-secrets | Accidentally committed secrets |
| 6 | pytest | Test suite and coverage |

The workflow runs on a clean Ubuntu virtual machine, so it catches problems
that only appear when starting from scratch (missing imports, wrong package
versions, etc.).

**Both of the following must be green before a PR can be merged:**

- ✅ GitHub Actions (the CI workflow above)
- ✅ Cycode SAST and Secrets scans (run automatically by Ford on every PR)

If CI is red, click the **Actions** tab on your PR to see which step failed
and what the error message says. Fix the failure locally, run `sanity.bat`
to confirm, and push again.
```

### How to Implement

1. Open `CONTRIBUTING.md`.
2. Find the "If a check fails" table (around line 87).
3. Insert the new section immediately after that table and before the
   "Adding new code" heading.
4. Run `.\sanity.bat` (ruff will check the markdown indirectly via any embedded
   code blocks - ensure no new lint errors).
5. Commit: `docs: document GitHub Actions CI workflow in CONTRIBUTING.md (B3)`

### Gotchas

- The new section must sit under `### Development Workflow` -> `#### Running the
  quality checks` so it flows naturally after the `sanity.bat` explanation.
- Do not duplicate the tool configuration table - it already exists in the
  "Tool configuration" section below. Just reference the workflow file.

### Risks

| Risk | Mitigation |
| --- | --- |
| Future tool additions not reflected in the table | The "How to Maintain" section in `docs/github-actions-guide.md` instructs maintainers to keep both files in sync |

### Rollback

`git checkout -- CONTRIBUTING.md`. Documentation-only change; zero code risk.

### Tests for the Test Engineer

No new unit tests. Verify: read the updated `CONTRIBUTING.md` and confirm the
new section appears in the correct location and is accurate.

---

## Combined Commit and PR Plan

### Suggested Commit Messages

```text
chore: add GitHub Actions CI workflow (B1)
docs: fix command examples in github-actions-guide.md (B2)
docs: document GitHub Actions CI workflow in CONTRIBUTING.md (B3)
```

Or, if squashing into one commit:

```text
chore: add GitHub Actions CI workflow and documentation (B1/B2/B3)
```

### Suggested PR Title

```text
chore: add GitHub Actions CI workflow (B1/B2/B3)
```

### Suggested PR Description

```text
Adds a GitHub Actions CI workflow that mirrors `sanity.bat`, ensuring the
six quality-gate steps (ruff format, ruff lint, mypy, bandit, detect-secrets,
pytest) run automatically on every push and PR.

Also corrects the example commands in docs/github-actions-guide.md (B2) and
documents the new workflow for future contributors in CONTRIBUTING.md (B3).

All three items are in one PR because they form a single coherent change.

Checklist:
- [x] .github/workflows/ci.yml created
- [x] Commands in ci.yml match sanity.bat exactly
- [x] docs/github-actions-guide.md examples corrected
- [x] CONTRIBUTING.md updated with CI section
- [x] sanity.bat green locally
- [x] CI green on this branch
- [x] Cycode SAST green
- [x] Cycode Secrets green
```

---

## Validation Commands

### Local (before pushing)

```powershell
# Confirm on main and clean
git status

# Run all six quality-gate checks
.\sanity.bat

# Validate YAML syntax (after creating ci.yml)
py -3.12 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"
```

### GitHub (after pushing)

1. Open the PR on `ford-innersource/eu-crm-sf-admin-utils`.
2. Check the **Actions** tab - the `CI / Quality Gate` job must be green.
3. Check **Cycode SAST** - must be green.
4. Check **Cycode Secrets** - must be green.
5. All three green -> request review -> merge.

---

## After Merge - Housekeeping

- [ ] `git checkout main && git pull`
- [ ] `.\sanity.bat` passes on `main`
- [ ] `docs/pr-roadmap-section-8-4.md` - mark B1, B2, B3 done with date and commit ref
- [ ] `Changelog.md` - add `[2026-XX-XX]` entry under `[Unreleased]`
- [ ] Remote branch `chore/group-b-ci` deleted on GitHub

---

## Starting the Implementation

Use the `infra-guide` chat mode. Paste this prompt:

```text
I need to implement B1/B2/B3 - GitHub Actions CI workflow - from
docs/pr-group-b-review.md on branch chore/group-b-ci.

Before we write any code, please teach me:
1. What GitHub Actions is, in plain English.
2. Why this project needs it right now.
3. When it is the right choice (and when it is not).
4. The benefits.
5. The risks and how to recover if something goes wrong.

Then guide me through the implementation step by step using the
correct commands from docs/pr-group-b-review.md - specifically the
⚠️ Command Discrepancy section. Reference docs/github-actions-guide.md
where relevant, but use the commands in pr-group-b-review.md as the
source of truth.
```

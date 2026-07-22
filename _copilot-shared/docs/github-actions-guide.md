# GitHub Actions CI Guide

This guide explains what GitHub Actions is, why this project is adding it,
and how to set it up step by step. It covers Group B items (B1, B2, B3) from
[`docs/pr-roadmap-section-8-4.md`](pr-roadmap-section-8-4.md).

Written for someone who has never built an automated pipeline before.
If you already know CI/CD basics, jump to [Step-by-Step Setup](#step-by-step-setup).

---

## Prerequisites

Before starting Group B work:

- Group A is merged to `main` (all four items done - see roadmap).
- You have a local clone of `ford-innersource/eu-crm-sf-admin-utils`.
- `.\sanity.bat` passes on `main` with no errors.
- You have permission to push branches and open PRs on the Ford InnerSource repo.
- Python 3.13 and the virtual environment are set up (see
  [`docs/running-the-scripts-guide.md`](running-the-scripts-guide.md)).

---

## What Is GitHub Actions?

**GitHub Actions** is a built-in automation system on GitHub. You write a
configuration file (called a **workflow**) that tells GitHub:

- When to run (for example: every time someone pushes a commit).
- What machine to use (called a **runner** - GitHub spins up a fresh virtual
  machine for each run).
- What commands to execute (install Python, run tests, check for security issues).

Think of it as `sanity.bat`, but it runs automatically in the cloud every time
code is pushed - you do not have to remember to run it yourself.

**Key vocabulary:**

| Term | Plain-English meaning |
| --- | --- |
| CI | Continuous Integration - automatically running tests every time code is pushed |
| CD | Continuous Deployment - automatically releasing code after tests pass (not used here yet) |
| Workflow | A YAML file that defines when and how automation runs |
| YAML | A plain-text configuration format that uses indentation to show structure |
| Runner | The temporary virtual machine GitHub creates to run your workflow |
| Job | A group of steps that run together on one runner |
| Step | A single command or action inside a job |
| Action | A reusable piece of workflow logic published on the GitHub Marketplace |
| Secret | A value (like a password) stored securely in GitHub so workflows can use it without exposing it in code |

---

## Why Does This Project Need It?

Right now, the only quality gate is `.\sanity.bat`, which runs locally on your
machine. That means:

- If you forget to run it before pushing, broken code can reach the repository.
- Other contributors have no automated guarantee that the code they receive is
  passing tests.
- Cycode scans run on PRs, but test failures and type errors are only caught if
  the developer remembered to run `sanity.bat`.

GitHub Actions CI solves this by running the same checks automatically every
time a commit is pushed. No one has to remember.

---

## What sanity.bat Does Today

Understanding what `sanity.bat` does helps you understand what the CI workflow
will replicate. Here is the pipeline in order:

| Step | Tool | What it checks |
| --- | --- | --- |
| 1 | `ruff format` | Code is consistently formatted |
| 2 | `ruff check` | Code style and lint rules pass |
| 3 | `mypy` | Type hints are correct (checks `src/` and `scripts/`) |
| 4 | `bandit` | No common security anti-patterns in the code |
| 5 | `detect-secrets` | No accidentally committed secrets or tokens |
| 6 | `pytest` | All tests pass (target: ≥ 90% coverage) |
| 7 | `markdownlint-cli2` | Markdown docs follow the style rules |

The CI workflow will run these same seven steps every time code is pushed to
any branch. (CI runs the Markdown lint first; `sanity.bat` runs it last as
step 7 - the commands are identical, only the order differs.)

---

## When to Use GitHub Actions

Use GitHub Actions when:

- You want checks to run automatically without relying on any individual developer.
- You want new contributors to get instant feedback on their changes.
- You want a visible green/red status badge on every PR before it is reviewed.

You would not use GitHub Actions for:

- Tasks that require live Salesforce credentials in CI (this project avoids that
  by keeping production credentials out of the workflow entirely).
- One-off manual administrative tasks (those stay as `scripts/` files run locally).

---

## Benefits

- **Automatic safety net:** Tests and lint run on every push - no manual step needed.
- **Confidence during PR review:** Reviewers can see a green CI badge before they
  even read the code.
- **Catches environment drift:** CI runs on a clean Linux machine every time, so
  it catches problems that only appear when starting fresh (missing imports,
  wrong package versions, etc.).
- **Free for InnerSource repos:** GitHub Actions is included for Ford InnerSource
  repositories.

---

## Risks and Mitigations

| Risk | Likelihood | Mitigation |
| --- | --- | --- |
| CI uses different OS than developer (Linux vs Windows) | Medium | `sanity.bat` stays as the Windows gate; CI adds the Linux gate |
| Secrets accidentally committed in workflow YAML | Low | Use `${{ secrets.SECRET_NAME }}` syntax only; Cycode will catch plain-text secrets |
| CI passes but `sanity.bat` fails locally | Low | Both use the same tools and `requirements-dev.txt` - keep them in sync (B2) |
| Workflow file syntax errors block all PRs | Low | Test on a feature branch before merging to `main` |

---

## Step-by-Step Setup

Follow these steps on branch `chore/group-b-ci`. Do not commit directly to `main`.

### Step 1 - Create the branch

**What you are doing:** Creating an isolated branch so CI work does not affect `main` until it is reviewed.

```bash
git checkout main
git pull
git checkout -b chore/group-b-ci
```

**Success:** `git branch` shows `* chore/group-b-ci`.

---

### Step 2 - Create the workflow directory

**What you are doing:** GitHub Actions looks for workflow files in a specific
folder: `.github/workflows/`. This folder may not exist yet.

```bash
mkdir .github\workflows
```

On Windows PowerShell, this creates `.github\workflows\` in your project root.

**Success:** The folder exists. It can be empty for now.

---

### Step 3 - Create the CI workflow file (B1)

**What you are doing:** Writing the YAML file that tells GitHub Actions what to
run. This file mirrors the seven steps in `sanity.bat`.

Create `.github/workflows/ci.yml` with the following content:

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

      - name: Set up Python 3.13
        uses: actions/setup-python@v5
        with:
          python-version: "3.13"

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements-dev.txt
          pip install -e .

      - name: Markdown lint
        # markdownlint-cli2 is pinned to @0.22.1 so CI matches the local gate
        # (sanity.bat step 7). The ubuntu-latest runner already has Node.js and
        # npx preinstalled, so no separate setup-node step is required.
        run: npx markdownlint-cli2@0.22.1 "docs/**/*.md" "*.md"

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
        # Coverage flags live in pyproject.toml [tool.pytest.ini_options]
        # addopts and are inherited automatically. Only -n auto is added here.
        run: pytest -n auto
```

**What each section means:**

- `on: push / pull_request` - run this workflow whenever code is pushed or a
  PR is opened, on any branch.
- `runs-on: ubuntu-latest` - use a fresh Linux virtual machine for each run.
- `actions/checkout@v4` - a reusable action that downloads your code onto the
  runner. `@v4` means version 4 of that action.
- `actions/setup-python@v5` - installs Python 3.13 on the runner.
- `pip install -r requirements-dev.txt` - installs the same dev tools that
  `sanity.bat` uses locally.
- `pip install -e .` - installs the local `sf_admin_utils` package so imports
  work in tests (the `-e` flag means "editable" - the package points to your
  source files directly).
- `npx markdownlint-cli2@0.22.1` - lints the Markdown docs. `npx` runs the
  pinned tool using the Node.js already installed on the runner; the `@0.22.1`
  pin keeps CI on the same rule set as `sanity.bat`.
- Each subsequent step maps directly to one step in `sanity.bat`.

**Success:** The file exists at `.github/workflows/ci.yml`.

---

### Step 4 - Verify the workflow file syntax

**What you are doing:** Checking for YAML syntax errors before pushing. YAML is
sensitive to indentation - one wrong space can break the whole file.

```bash
python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"
```

**Success:** No output (no errors). If you see a `ScannerError`, check the
indentation around the reported line.

---

### Step 5 - Align sanity.bat and CI commands (B2)

**What you are doing:** Making sure `sanity.bat` and `ci.yml` run the same
commands in the same order. If they diverge, a developer could see green
locally and red in CI (or vice versa).

Open `sanity.bat` and compare it to the CI steps. The commands should match:

| sanity.bat step | ci.yml step |
| --- | --- |
| `ruff format --check src tests scripts` | `ruff format --check src tests scripts` |
| `ruff check src tests scripts` | `ruff check src tests scripts` |
| `mypy` | `mypy` |
| `bandit -c pyproject.toml -r src scripts --exclude scripts/archive,tests --quiet` | `bandit -c pyproject.toml -r src scripts --exclude scripts/archive,tests --quiet` |
| `python -m detect_secrets scan --baseline .secrets.baseline` | `python -m detect_secrets scan --baseline .secrets.baseline` |
| `pytest -n auto` | `pytest -n auto` |
| `npx markdownlint-cli2@0.22.1 "docs/**/*.md" "*.md"` | `npx markdownlint-cli2@0.22.1 "docs/**/*.md" "*.md"` |

If `sanity.bat` uses different flags, update it to match. Keeping them
identical means a green `sanity.bat` locally predicts a green CI run. (CI runs
the Markdown lint first while `sanity.bat` runs it last as step 7 - only the
order differs, not the command.)

---

### Step 6 - Document the CI workflow in CONTRIBUTING.md (B3)

**What you are doing:** Updating `CONTRIBUTING.md` so future contributors know
the CI workflow exists, what it checks, and how to interpret its output.

Add a section to `CONTRIBUTING.md`:

```markdown
## Automated CI Checks

Every push to any branch triggers a GitHub Actions workflow that runs the same
checks as `sanity.bat`:

1. ruff format - code formatting
2. ruff lint - code style
3. mypy - type checking
4. bandit - security scan
5. detect-secrets - secret detection
6. pytest - test suite
7. markdownlint - Markdown documentation style

The workflow must be green before a PR can be merged. If CI is red, check the
"Actions" tab on your PR for the error details.

In addition, Cycode SAST and Secrets scans run automatically on every PR.
Both Cycode gates must also pass before merge.
```

---

### Step 7 - Run sanity.bat locally before pushing

**What you are doing:** Confirming that your local changes pass all checks
before CI sees them.

```powershell
.\sanity.bat
```

**Success:** All seven steps exit with code 0. You should see no errors.

---

### Step 8 - Commit and push

```bash
git add .github/workflows/ci.yml CONTRIBUTING.md
git commit -m "chore: add GitHub Actions CI workflow and update CONTRIBUTING.md (B1/B2/B3)"
git push -u origin chore/group-b-ci
```

**Success:** The branch appears on GitHub. Within a minute or two, you will
see a yellow circle (running) turn into a green checkmark (passed) on the
Actions tab of the repository.

---

### Step 9 - Open the PR and wait for both gates

**What you are doing:** Opening a PR so the team can review the CI configuration.

1. Go to `ford-innersource/eu-crm-sf-admin-utils` on GitHub.
2. Click **Compare & pull request** on the `chore/group-b-ci` branch.
3. Use the title: `chore: add GitHub Actions CI workflow (B1/B2/B3)`.
4. Wait for:
   - ✅ GitHub Actions (your new CI workflow) - green
   - ✅ Cycode SAST - green
   - ✅ Cycode Secrets - green
5. Request a review, then merge.

---

## How to Maintain the Workflow

After setup, you should update `.github/workflows/ci.yml` when:

- You add a new quality-gate tool to `sanity.bat` - add the matching step to CI.
- You change Python version - update `python-version: "3.13"` to match.
- You pin a new version of a tool in `requirements-dev.txt` - CI picks it up
  automatically on the next run.

Always keep `sanity.bat` and `ci.yml` in sync. The rule is: if it runs locally,
it runs in CI.

---

## How to Repeat This Without Copilot

Use this checklist for any future CI changes:

- [ ] Create branch from `main`.
- [ ] Edit `.github/workflows/ci.yml`.
- [ ] Validate YAML syntax (`python -c "import yaml; ..."`).
- [ ] Verify `sanity.bat` commands match CI commands.
- [ ] Run `.\sanity.bat` locally - must be green.
- [ ] Commit and push.
- [ ] Confirm CI turns green on GitHub Actions tab.
- [ ] Open PR, wait for Cycode, request review.

---

## Key Concepts for Beginners

**GitHub Actions** - GitHub's built-in automation system. Workflows live in
`.github/workflows/` as YAML files.

**CI (Continuous Integration)** - A practice where code is automatically
tested every time it is pushed, catching problems early.

**YAML** - A plain-text configuration format. Indentation (spaces, not tabs)
controls the structure. One wrong space causes a parse error.

**Runner** - A temporary virtual machine that GitHub creates for each workflow
run. It is discarded after the run finishes.

**`actions/checkout`** - A GitHub-provided action that downloads your repository
code onto the runner so the rest of the steps can use it.

**`pip install -e .`** - Installs the local package (`sf_admin_utils`) in
editable mode. Editable means changes to the source files take effect immediately
without reinstalling.

**GitHub secret** - A value stored securely in GitHub repository settings. Workflows
reference secrets as `${{ secrets.MY_SECRET }}` - GitHub replaces the placeholder
at runtime without exposing the value in logs.

**Cycode** - Ford's SAST (Static Application Security Testing) and Secrets
scanning tool. It runs automatically on every PR and checks for security
vulnerabilities and accidentally committed credentials.

---

## Errors and Fixes

| Error / Symptom | Cause | Fix | How to Verify |
| --- | --- | --- | --- |
| `yaml.ScannerError` on validation | Indentation error in `ci.yml` | Check the line number in the error; ensure all indentation uses spaces, not tabs | Re-run the `python -c "import yaml..."` check |
| CI red: `ModuleNotFoundError: sf_admin_utils` | `pip install -e .` step missing or failed | Confirm the `pip install -e .` step is in the workflow | Check the "Install dependencies" step log in GitHub Actions |
| CI red: `detect-secrets audit` fails | `.secrets.baseline` is out of date | Run `detect-secrets scan > .secrets.baseline` locally, commit the updated baseline | CI passes after the updated baseline is pushed |
| CI green locally, red in GitHub | `sanity.bat` uses different flags than `ci.yml` | Compare commands side-by-side; update `sanity.bat` to match | Run `.\sanity.bat` locally; it should now predict CI results |
| CI red: `RuntimeError: Salesforce CLI ('sf') not found on PATH` in tests | A test class that calls `main()` is missing the `_mock_sf_cli` autouse fixture. `shutil.which("sf")` returns `None` on the Ubuntu CI runner because `sf` is not installed there - but returns a real path on Windows where `sf` is installed, so the test passes locally. | Add `@pytest.fixture(autouse=True)` / `_mock_sf_cli` to the failing class (see `TestGetCliOrgAuth` in `test_export_quote_pdfs.py` as a reference). Run `grep -n "def _mock_sf_cli\|module.main(" tests/test_export_quote_pdfs.py` to verify every class that calls `main()` has the fixture. | CI passes after the fixture is added and pushed |
| `permission denied` on push | Branch protection rules or missing fork access | Check with the repo admin; ensure you have write access to the Ford InnerSource repo | `git push` exits 0 |

---

## Known Limitations of `sanity.bat`

`sanity.bat` runs every quality check on your **local Windows machine**, where the
Salesforce CLI (`sf`) is installed and on `PATH`. This means `shutil.which("sf")`
always returns a real path locally, and any test that calls `module.main()` will
pass - even if the test class is missing the `_mock_sf_cli` autouse fixture.

On the **Ubuntu CI runner**, `sf` is not installed, so `shutil.which("sf")`
returns `None`. Scripts that call `which("sf")` early in `main()` will raise
`RuntimeError: Salesforce CLI ('sf') not found on PATH` before reaching any code
under test, causing the test to fail on CI but pass locally.

### How to catch this gap before pushing

After writing or reviewing tests for any `export_*_pdfs_prod.py` script, run:

```powershell
Select-String -Path "tests\test_export_*_pdfs_prod.py" -Pattern "def _mock_sf_cli|module\.main\("
```

Every test **class** that contains a call to `module.main(...)` must also define
an `_mock_sf_cli` fixture decorated with `@pytest.fixture(autouse=True)`.
See `TestGetCliOrgAuth` in `tests/test_export_quote_pdfs.py` for a reference
implementation.

> **Why `sanity.bat` cannot fix this automatically:** The check would need to
> parse Python AST to associate method calls with their enclosing class and then
> cross-reference fixture scopes - that is beyond a batch-file quality gate. The
> manual `Select-String` check above is the lightweight alternative.

---

## Related Documents

- [`docs/pr-roadmap-section-8-4.md`](pr-roadmap-section-8-4.md) - Group B items B1/B2/B3
- [`docs/salesforce-admin-utilities-guide.md`](salesforce-admin-utilities-guide.md) - §6.2 Cycode Scans
- [`CONTRIBUTING.md`](../CONTRIBUTING.md) - Updated in B3 with CI section
- [`docs/workflow-prompts.md`](workflow-prompts.md) - Step-by-step Copilot workflow cheat sheet

# Scaffold Files - What They Are and What to Customise

These files were copied into your project from `_copilot-shared\scaffold\`
when the project was first created.  They are starter templates - your project
owns them, and you should edit them to match your project's actual layout and
dependencies.

---

## Files in this scaffold

| File | Purpose |
| --- | --- |
| `sanity.bat` | Local quality gate - run this before every commit |
| `sanity_v.bat` | Verbose version of `sanity.bat` - use when debugging a failure |
| `update_packages.bat` | Safely upgrade all dependencies (Windows) |
| `update_packages.py` | Core upgrade logic - handles pip-tools recompile and verification |
| `pyproject.toml` | All Python tool configuration (ruff, mypy, pytest, bandit) |
| `requirements.in` | Loose-pinned list of runtime dependencies (Python template) |
| `requirements-dev.in` | Loose-pinned list of dev/test dependencies (Python template) |
| `README.md` | Project overview - what it does, who it is for, how to use it |
| `ARCHITECTURE.md` | System design, components, data flows, platform and security notes |
| `CHANGELOG.md` | Version history in Keep a Changelog format |
| `CONTRIBUTING.md` | Developer setup, standards, quality gate, PR process |
| `SECURITY.md` | Security policy, vulnerability reporting, known controls |
| `UPDATING_DEPENDENCIES.md` | How to add, update, and remove dependencies safely |
| `scaffold-README.md` | This file - explains what to customise |

**Language note:** `sanity.bat`, `requirements.in`, and `requirements-dev.in`
are Python-specific templates. For other languages (Java, Node.js, etc.) replace
them with the equivalent tooling. The documentation files (`README.md`,
`ARCHITECTURE.md`, etc.) are language-agnostic.

**Platform note:** All documentation templates reflect the project's CI/CD
environment: GitHub Actions runs on `ubuntu-latest` (Linux), and the Cycode
security scanner also runs on Linux. Code must work cross-platform. This is
noted explicitly in `ARCHITECTURE.md` and `CONTRIBUTING.md`.

---

## `sanity.bat` and `sanity_v.bat`

These scripts run the six quality checks that CI also runs, in the same
order, so local results match what the pipeline will report.

### What to customise in the gate scripts

#### Directory list (steps 1, 2, and 4)

The scripts scan `src tests scripts` by default.  If your project uses
different directory names, update all three steps consistently:

```bat
REM Step 1
%PY_CMD% -m ruff format --check src tests scripts
REM Step 2
%PY_CMD% -m ruff check src tests scripts
REM Step 4
%PY_CMD% -m bandit -c pyproject.toml -r src scripts --exclude tests --quiet
```

Common variants:

- Single source package: `src tests`
- No scripts folder: `src tests`
- Flat layout: `mypackage tests`

#### Bandit exclusions (step 4)

`--exclude tests` is the standard minimum (test code is not deployed, so
bandit findings there are low value).  Add more exclusions if your project
has generated or archived directories you do not want scanned:

```bat
--exclude tests,scripts/archive,generated
```

#### Python version

Both files auto-detect the project `.venv` first, then fall back to the
Windows Python Launcher for Python 3.13 (`py -3.13`). If this project runs on
a different Python version, update the `PY_CMD` detection block near the top of
each file (the `for %%V in (3.13)` line):

```bat
set PY_CMD=py -3.11
```

### Maintenance rule

`sanity.bat` and `sanity_v.bat` must always have the same six steps in the
same order.  The only permitted differences between them are the verbose flags
(e.g. `--verbose`, `-v`, `--tb=short`).  When you change a step in
`sanity.bat`, apply the same change in `sanity_v.bat` immediately.

Coverage flags (`--cov`, `--cov-report`, `--cov-fail-under`) must live in
`pyproject.toml` under `[tool.pytest.ini_options] addopts` only.  Never
pass them directly to pytest in these scripts or in `ci.yml`.

---

## `pyproject.toml`

This file is the single source of truth for all Python tool configuration:
ruff (linting and formatting), mypy (static type checking), pytest and
coverage, bandit (security linter), and pip-tools settings.

### One-time copy, never overwritten

`pyproject.toml` is **copied once when the project is created** and then
owned by the project. The sync script never overwrites it after that first
copy, because it contains project-specific metadata (package name, version,
description) mixed in with the shared tool config.

This is different from `.github/` artefacts (agents, instructions, prompts)
which are synced on every run.

### What to customise in `pyproject.toml`

Every section marked `# CUSTOMISE THIS:` must be edited before first use:

| Setting | Where | What to change |
| --- | --- | --- |
| `name` | `[project]` | Your package name (e.g. `my-salesforce-utils`) |
| `version` | `[project]` | Start at `0.1.0` |
| `description` | `[project]` | One-sentence summary |
| `where = ["src"]` | `[tool.setuptools.packages.find]` | Your source root if not `src/` |
| `files = ["src", "scripts"]` | `[tool.mypy]` | Directories mypy should check |
| `mypy_path = ["src"]` | `[tool.mypy]` | Where your importable package lives |
| `known-first-party` | `[tool.ruff.lint.isort]` | Your package name(s) |
| `addopts` | `[tool.pytest.ini_options]` | `--cov` paths and `--cov-fail-under` threshold |
| `source` | `[tool.coverage.run]` | Same directories as `addopts` |

### Adding untyped third-party libraries

When mypy reports "Library stubs not installed" for a new dependency:

1. Add the library to the `[[tool.mypy.overrides]]` `ignore_missing_imports`
   block in `pyproject.toml`.
2. If the module also needs an inline `# type: ignore[import-untyped]` comment
   so the VS Code extension stays silent, add a matching
   `warn_unused_ignores = false` override for that module (see the commented
   template in `pyproject.toml`).
3. **Cross-project check:** apply the same fix to every other project in this
   workspace that uses the same library. See "Cross-project drift" below.

---

## Cross-project drift

`pyproject.toml` is owned by each project, but the tool-config sections are
intended to be identical across all projects in this workspace. Over time they
will drift as individual projects add new ignores, overrides, or thresholds.

### The drift rule

Whenever you make a tool-config change in `pyproject.toml` that is not
project-specific (i.e. it is not the `[project]` section), ask:

> "Should every other project in this workspace have this change too?"

Common answers:

| Change | Apply to other projects? |
| --- | --- |
| Add a mypy override for a new untyped library | Yes - if they use the same library |
| Raise or lower `--cov-fail-under` | No - each project sets its own threshold |
| Add a new ruff `ignore` rule | Yes - shared code standards |
| Add a `per-file-ignores` entry for a new folder | No - project-specific layout |
| Add a new bandit `skips` entry | Yes - if the false-positive applies everywhere |

### How to propagate a shared change

1. Make the change in the affected project's `pyproject.toml`.
2. Copy the same section or entry to every other project's `pyproject.toml`.
3. Run `sanity.bat` in each project to confirm nothing broke.
4. Commit all affected projects in the same PR or back-to-back PRs with a
   note: "propagating shared pyproject.toml change from [project name]".

**Note:** This is a manual step because `pyproject.toml` cannot be
auto-synced (it contains project-specific fields). The sync script only
manages `.github/` artefacts. Consider this the cost of not having a
monorepo - it is low if changes are propagated immediately rather than
allowed to accumulate.

---

## `requirements.in`

This file lists the packages your code needs to **run** in production.
It uses loose version pins (`requests`, not `requests==2.32.0`) so that
`pip-compile` can resolve the best compatible set.

### What to customise in `requirements.in`

Remove the starter packages you do not need.  Add the packages you do need.
Uncomment the relevant lines in the "COMMON ADDITIONS" section if applicable.

### After editing `requirements.in`

Run:

```powershell
pip-compile requirements.in
```

This generates (or regenerates) `requirements.txt` with exact version pins
for every package and its dependencies.  Commit `requirements.txt`.

---

## `requirements-dev.in`

This file lists the packages needed to **develop** the project: test
framework, linters, type checkers, security scanners.  It includes
`requirements.in` via `-r requirements.in`, so installing from
`requirements-dev.txt` installs everything.

### What to customise in `requirements-dev.in`

- Add type stubs for any typed third-party library you use (uncomment the
  relevant line in the "COMMON ADDITIONS" section, or add a new `types-X`
  package).
- Add test helpers you need (e.g. `responses` for HTTP mocking).
- If your internal package mirror does not carry `pip-audit`, leave it
  commented out and note it in `README.md`.

### After editing `requirements-dev.in`

Run:

```powershell
pip-compile requirements-dev.in
```

This generates (or regenerates) `requirements-dev.txt`.  Commit
`requirements-dev.txt`.

---

## Documentation files

`README.md`, `ARCHITECTURE.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
`SECURITY.md`, and `UPDATING_DEPENDENCIES.md` are generic starter templates.
Every section marked `[FILL IN]` must be completed for your project.

### Minimum viable documentation

At a minimum, ensure that:

- `README.md` answers: what does this project do, who uses it, and how do they
  run it?
- `ARCHITECTURE.md` has a components diagram and a Security Considerations
  section that describes what data is handled and where trust boundaries are.
- `SECURITY.md` names a contact for reporting vulnerabilities.
- `CHANGELOG.md` has at least one entry before the first release.
- `CONTRIBUTING.md` has accurate setup and quality-gate instructions.

A reviewer with no prior knowledge of the project should be able to read these
five files and understand the project's purpose, structure, and security model
without asking anyone.

---

## `update_packages.bat`, `update_packages.py`, and `update_packages.sh`

These three files work together to safely upgrade Python dependencies.

### Why this matters

Python packages (dependencies) are maintained by the open-source community.
Like all software, they occasionally have security bugs. Keeping them updated
protects against exploits. However, newer versions may have bugs or introduce
breaking changes. This script handles the upgrade safely:

1. Compiles newer versions into `requirements.txt` and `requirements-dev.txt`.
2. Shows you what changed (so you can review it).
3. Asks for confirmation before installing.
4. Installs the new versions.
5. Runs the full test suite (`sanity.bat` / `sanity.sh`) to confirm nothing broke.

### How to use it

**Windows:**

```powershell
.venv\Scripts\Activate.ps1
.\update_packages.bat
```

**Linux/macOS:**

```bash
source .venv/bin/activate
bash update_packages.sh
```

Or run the Python script directly on any platform:

```bash
python scripts/update_packages.py
```

### What to customise

These files require **no customisation** - they work as-is. The upgrade logic
uses `pip-tools` to recompile `requirements.in` and `requirements-dev.in` into
exact-version lock files.

**Important:** Your project must have:

- `requirements.in` and/or `requirements-dev.in` in the project root (loose
  versions, e.g. `flask>=3.0`).
- `scripts/` directory (for the update_packages.py script).
- `sanity.bat` or `sanity.sh` (the gate scripts run after upgrade to verify).

If you're using a different dependency system (Poetry, Pipenv, Conda), replace
these files with the equivalent for your system.

---

## Safe to delete

Once you have customised these files, `scaffold-README.md` has done its job.
You may delete it if you prefer a clean project root - or keep it as a
reference for future maintainers.

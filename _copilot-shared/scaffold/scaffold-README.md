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

Both files use `py -3.12`.  If this project runs on a different Python
version, update the `PY_CMD` line at the top of each file:

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

## Safe to delete

Once you have customised these files, `scaffold-README.md` has done its job.
You may delete it if you prefer a clean project root - or keep it as a
reference for future maintainers.

# Beginner's Guide - update_packages.py

This guide explains how the `update_packages.py` script works, what you need
before running it, and how each piece fits together. It is written for people
who are new to Python scripting and package management.

---

## Table of Contents

- [What This Script Does](#what-this-script-does)
- [Prerequisites](#prerequisites)
- [Running the Script](#running-the-script)
- [Code Walkthrough](#code-walkthrough)
- [Output](#output)
- [Troubleshooting](#troubleshooting)
- [Glossary](#glossary)

---

## What This Script Does

The script automates the chore of keeping Python dependencies up to date using
**pip-tools** (a tool that reads a loose dependency list and produces an exact
pinned version lock file - a file that records every package and its exact
version, making installs reproducible).

It:

1. Records the current pinned versions from `requirements.txt` and
   `requirements-dev.txt`.
2. Runs `pip-compile --upgrade` on `requirements.in` and `requirements-dev.in`
   to recalculate the latest compatible versions of all dependencies.
3. Shows you a diff - which packages changed version, which were added, and
   which were removed.
4. Installs the newly compiled packages into the active virtual environment.

It is a **local maintenance tool** - it has nothing to do with Salesforce.
No Salesforce CLI, credentials, or network access to Salesforce is required.

---

## Prerequisites

| Requirement | Why |
| --- | --- |
| Python 3.12+ | The script uses modern type hints and f-strings. |
| Virtual environment activated | Upgrades run inside the venv so they do not affect system Python. |
| `pip-tools` installed | Provides the `pip-compile` command used to recalculate pinned versions. |
| Internet access to PyPI or Ford JFrog mirror | `pip-compile` needs to reach the package index to discover newer versions. |

### Quick Setup

```bash
# From the project root
python -m venv .venv
.venv\Scripts\activate
pip install -e .
pip install -r requirements-dev.txt
```

> **Note:** No Salesforce CLI setup is needed for this script.

---

## Running the Script

```bash
# From the project root with the venv activated:
python scripts/update_packages.py
```

The script is fully automatic - no command-line arguments required.

---

## Code Walkthrough

### Constants

| Name | Value | Purpose |
| --- | --- | --- |
| `REQUIREMENTS_FILE` | `"requirements.txt"` | Runtime dependency pins (compiled from `requirements.in`) |
| `DEV_REQUIREMENTS_FILE` | `"requirements-dev.txt"` | Development dependency pins (compiled from `requirements-dev.in`) |

---

### `read_pins(filepath)`

**Purpose:** Read a pip-compile output file and return a dictionary mapping
package names to their pinned versions.

**How it works:**

1. Opens the file and reads it line by line.
2. Skips blank lines, comments (`#`), and pip directives (`--index-url`, `-r`, `-e`).
3. Uses a regex to match lines like `requests==2.31.0`.
4. Normalises package names to lowercase for consistent comparison.
5. Strips environment markers (e.g. `; python_version >= "3.8"`) so only the
   version string is stored.

**Returns:** `dict[str, str]` - e.g. `{"requests": "2.32.3", "pytest": "9.0.3"}`

---

### `run(command, check=True)`

**Purpose:** Run an external command (like `pip-compile`) as a subprocess and
return its exit code.

**How it works:**

1. Validates that the command is an allowlisted safe command.
2. Calls `subprocess.run()` with the given command list.
3. If `check=True` and the command exits with a non-zero code, calls
   `sys.exit()` with that code.

**Returns:** `int` - the exit code (0 = success).

---

### `compile_upgrade(requirements_in_file)`

**Purpose:** Run `pip-compile --upgrade` on a `.in` file to recalculate the
latest compatible pinned versions and overwrite the corresponding `.txt` file.

**pip-compile** (part of pip-tools) reads a loose requirement like `requests`
and works out the exact latest version that is compatible with all other
dependencies, then writes the result to `requirements.txt`. The `--upgrade`
flag tells it to recalculate all versions, not just missing ones.

---

### `diff_pins(before, after)`

**Purpose:** Compare two pin maps and report what changed.

**Returns:** a tuple of three lists:

- `upgraded` - packages whose version changed: `[("requests", "2.31.0", "2.32.3")]`
- `added` - packages only in `after`: `["new-pkg==1.0.0"]`
- `removed` - packages only in `before`: `["old-pkg==0.9.0"]`

---

### `print_section(title)` and `print_diff(label, before, after)`

**Purpose:** Format and log progress output so the user can see what changed
at each stage.

---

### `main()`

**Purpose:** Orchestrate the full workflow.

**Step-by-step:**

1. **Check pip-tools is installed** - exits with code 1 if `pip-compile` is
   not available.
2. **Read current pins** - calls `read_pins()` on both `requirements.txt` and
   `requirements-dev.txt` to snapshot the before state.
3. **Compile runtime deps** - runs `pip-compile --upgrade requirements.in`.
4. **Compile dev deps** - runs `pip-compile --upgrade requirements-dev.in`.
5. **Diff** - calls `diff_pins()` for both files and logs what changed.
6. **Install** - runs `pip install -r requirements-dev.txt` to apply the new
   pins to the active virtual environment.

---

## Output

### Example Console Output

```text
============================================================
 Runtime Dependencies
============================================================
INFO  Upgraded:
INFO    requests  2.31.0  ->  2.32.3
INFO  Added:
INFO    new-pkg==1.0.0
INFO  No packages removed.

============================================================
 Dev Dependencies
============================================================
INFO  No changes.

============================================================
 Install
============================================================
INFO  Running: pip install -r requirements-dev.txt
...
INFO  Done.
```

### Exit Codes

| Code | Meaning |
| --- | --- |
| `0` | Script completed successfully. |
| `1` | pip-tools not installed, or pip-compile failed. |

---

## Important Notes

- **Run from the project root.** The script reads `requirements.txt` and
  `requirements-dev.txt` relative to the working directory.
- **Test after upgrading.** Run `pytest` and `mypy` to confirm nothing broke
  with the newer package versions. The full quality gate is `sanity.bat`.
- **Corporate proxy / Ford JFrog.** If pip-compile cannot reach the package
  index, ensure the proxy or JFrog mirror is configured in `pip.ini`.
- **Commit the updated `.txt` files.** After running this script, the
  `requirements.txt` and `requirements-dev.txt` files will have new version
  pins. Commit them so CI and other developers use the same versions.

---

## Troubleshooting

### `pip-tools is not installed`

The script checks for pip-tools at startup and exits with code 1 if it is
not found. Install it:

```bash
pip install pip-tools
```

### `pip-compile failed` / non-zero exit code

Common causes:

- No internet / proxy not configured - check Ford JFrog mirror settings.
- Dependency conflict - two packages require incompatible versions of a shared
  dependency. Read the pip-compile error output carefully; it will name the
  conflicting packages.

### `requirements.txt` or `requirements-dev.txt` not found

Make sure you are running the script from the project root directory:

```bash
cd <project-root>
python scripts/update_packages.py
```

### `ModuleNotFoundError: No module named 'sf_admin_utils'`

Ensure the package is installed in editable mode in the active venv:

```bash
pip install -e .
```

### Nothing appears to have changed

If both before/after pin maps are identical, the script logs "No changes" for
each file. This means all packages are already at their latest compatible
versions - no action needed.

---

## Glossary

| Term | Meaning |
| --- | --- |
| `requirements.in` | A loose list of direct runtime dependencies (e.g. `requests`). You edit this file to add/remove packages. |
| `requirements.txt` | A fully pinned lock file generated by `pip-compile` from `requirements.in`. Records exact versions for every package and its transitive dependencies. |
| `requirements-dev.in` | Loose list of development-only dependencies (e.g. `pytest`, `ruff`). Not needed in production. |
| `requirements-dev.txt` | Pinned lock file for development dependencies, generated from `requirements-dev.in`. |
| pip-tools | A package that provides `pip-compile` (generates pinned `.txt` from loose `.in`) and `pip-sync` (installs exactly what is in `.txt`). |
| pip-compile | The pip-tools command that reads a `.in` file and resolves the latest compatible versions, writing the result to a `.txt` file. |
| Pinned version | A dependency locked to a specific version with `==` (e.g. `requests==2.32.3`). Makes installs reproducible. |
| Virtual environment (venv) | An isolated Python installation for one project. Prevents version conflicts between projects. |
| Transitive dependency | A package that your packages depend on, even though you did not list it yourself. pip-compile records these too. |
| Editable install | `pip install -e .` -- links your own package so code changes take effect immediately without reinstalling. |

# Beginner's Guide - test_update_packages.py

This guide explains the test suite for the `update_packages.py` script. It is
written for people who are new to Python testing and want to understand how each
test works, how to run them, and how to add new ones.

---

## Table of Contents

- [What This File Tests](#what-this-file-tests)
- [Prerequisites](#prerequisites)
- [Running the Tests](#running-the-tests)
- [Key Concepts](#key-concepts)
- [Code Walkthrough](#code-walkthrough)
- [How to Add a New Test](#how-to-add-a-new-test)
- [Troubleshooting](#troubleshooting)
- [Glossary](#glossary)

---

## What This File Tests

`test_update_packages.py` validates every function in
`scripts/update_packages.py`:

| Function | What Is Tested |
| --- | --- |
| `parse_requirements()` | Correct parsing, comment/blank/editable skipping, normalisation |
| `get_outdated_packages()` | JSON parsing from pip, exit on failure |
| `upgrade_package()` | Success/failure return values, argument passing |
| `main()` | End-to-end orchestration: missing file, up-to-date, selective upgrades, failure reporting |

The tests **never** call real `pip` or reach the network. All subprocess calls
are monkeypatched to return fake data.

---

## Prerequisites

| Requirement | Why |
| --- | --- |
| Python 3.12+ | Matches the project minimum |
| Virtual environment activated | Tests use pytest and project fixtures |
| `pip install -e .` | Makes `sf_admin_utils` importable (needed by conftest) |
| `pip install -r requirements-dev.txt` | Installs pytest and coverage tools |

You do **not** need internet access, pip connectivity, or any lock file - the
tests create temporary files as needed.

---

## Running the Tests

```bash
# Run only this test file
pytest tests/test_update_packages.py -v

# Run a single test class
pytest tests/test_update_packages.py::TestParseRequirements -v

# Run a single test by name
pytest tests/test_update_packages.py -k "test_skips_comments"
```

Expected output:

```text
tests/test_update_packages.py::TestParseRequirements::test_parses_standard_lines PASSED
tests/test_update_packages.py::TestParseRequirements::test_skips_comments PASSED
...
tests/test_update_packages.py::TestMain::test_reports_failures PASSED
============================= 18 passed in 0.30s ==============================
```

---

## Key Concepts

### Module Loading with importlib

The `scripts/` directory is not a Python package (no `__init__.py`). We use
`importlib.util` to load the script as a module so we can call its functions
directly in tests:

```python
_spec = importlib.util.spec_from_file_location("update_packages", _SCRIPT_PATH)
_module = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_module)
```

### Monkeypatching subprocess

Every test that would normally call `pip` instead injects a fake
`subprocess.run` that returns a pre-built `CompletedProcess`:

```python
monkeypatch.setattr(subprocess, "run", lambda *_a, **_k: _completed("[]"))
```

### Temporary Files (tmp_path)

Pytest's built-in `tmp_path` fixture provides a fresh temporary directory for
each test. Lock files are written there so tests are isolated and leave no
artefacts behind.

### Test Classes

Related tests are grouped into classes (`TestParseRequirements`,
`TestGetOutdatedPackages`, etc.) for organisation. Each class tests one
function.

---

## Code Walkthrough

### Fixtures

| Fixture | Purpose |
| --- | --- |
| `lock_file` | Creates a realistic `requirements-lock.txt` in a temp directory with comments, blanks, editable installs, and real package lines |

### Helper Functions

| Helper | Purpose |
| --- | --- |
| `_completed(stdout, returncode)` | Builds a fake `subprocess.CompletedProcess` for mocking pip |

---

### TestParseRequirements (8 tests)

| Test | Scenario |
| --- | --- |
| `test_parses_standard_lines` | All four packages in the fixture file are parsed correctly |
| `test_skips_comments` | Lines starting with `#` are ignored |
| `test_skips_blank_lines` | Empty / whitespace-only lines are ignored |
| `test_skips_editable_installs` | Lines starting with `-e` are ignored |
| `test_normalises_names_to_lowercase` | `Requests` becomes `requests` |
| `test_raises_file_not_found` | Non-existent path raises `FileNotFoundError` |
| `test_handles_dots_and_underscores_in_names` | Package names with `.` `_` `-` are parsed |
| `test_empty_file_returns_empty_dict` | An empty file returns `{}` |

---

### TestGetOutdatedPackages (3 tests)

| Test | Scenario |
| --- | --- |
| `test_returns_parsed_json` | Valid pip JSON output is returned as a list of dicts |
| `test_returns_empty_list_when_all_current` | `[]` from pip means nothing outdated |
| `test_exits_on_pip_failure` | Non-zero pip exit triggers `sys.exit(1)` |

---

### TestUpgradePackage (3 tests)

| Test | Scenario |
| --- | --- |
| `test_returns_true_on_success` | Exit code 0 -> `True` |
| `test_returns_false_on_failure` | Exit code 1 -> `False` |
| `test_passes_package_name_to_pip` | The name and `--upgrade` flag appear in subprocess args |

---

### TestMain (4 tests)

| Test | Scenario |
| --- | --- |
| `test_exits_when_lock_file_missing` | Missing lock file -> `sys.exit(1)` |
| `test_reports_all_up_to_date` | No outdated packages -> returns normally |
| `test_upgrades_only_locked_packages` | Only packages in the lock file are upgraded; others are skipped |
| `test_reports_failures` | Failed upgrades appear in the console summary |

---

## How to Add a New Test

1. Identify which function you want to test and find its test class.
1. Write a new method starting with `test_`.
1. Use `monkeypatch` to control subprocess behaviour or `tmp_path` for files.
1. Assert the expected outcome.

Template:

```python
def test_my_scenario(self, monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    """Describe what happens when <condition>."""
    # Arrange - create a lock file or mock subprocess
    lock = tmp_path / "requirements-lock.txt"
    lock.write_text("my-pkg==1.0.0\n", encoding="utf-8")

    # Act - call the function
    result = parse_requirements(str(lock))

    # Assert - verify the outcome
    assert result == {"my-pkg": "1.0.0"}
```

---

## Troubleshooting

### `ModuleNotFoundError: No module named 'sf_admin_utils'`

Run `pip install -e .` from the project root.

### Coverage warning: "No data was collected"

This is expected when running only this file - the coverage configuration
tracks `src/sf_admin_utils/` which is not exercised by these tests. Ignore it
or run the full suite (`pytest`) to see combined coverage.

### Tests are slow

If a test takes more than a second, check that `subprocess.run` is properly
monkeypatched - a real `pip list --outdated` call would add several seconds.

---

## Glossary

| Term | Meaning |
| --- | --- |
| Monkeypatch | Temporarily replace a function or variable during a test |
| Fixture | A reusable piece of setup logic that pytest injects by name |
| `tmp_path` | Pytest fixture providing a unique temporary directory per test |
| `CompletedProcess` | Python's representation of a finished subprocess |
| importlib | Standard library module for dynamically loading Python files |
| Lock file | A file pinning every package to an exact version (`name==version`) |
| Test class | A group of related test methods collected under one class |

# Beginner's Guide - Testing the Agency ZIP Script (Contract PDFs)

This guide explains how the `test_create_agency_zips_contract.py` test suite works,
how to run it, and how to add new tests. It is written for people who are new to
Python testing and pytest.

---

## Table of Contents

- [What This Test Suite Does](#what-this-test-suite-does)
- [Prerequisites](#prerequisites)
- [Running the Tests](#running-the-tests)
- [Test Structure Walkthrough](#test-structure-walkthrough)
- [How to Add a New Test](#how-to-add-a-new-test)
- [Key Concepts for Beginners](#key-concepts-for-beginners)
- [Troubleshooting](#troubleshooting)

---

## What This Test Suite Does

This file contains **automated tests** that verify the `create_agency_zips_contract.py`
script works correctly. Each test exercises one specific function or behaviour in
isolation - without needing Salesforce access, network connections, or real PDF files.

Tests give you confidence that:

- Code changes do not break existing behaviour.
- Edge cases (empty inputs, invalid folder names) are handled gracefully.
- ZIP archives contain the expected files.
- Manifest CSVs are formatted correctly.

---

## Prerequisites

| Requirement | Why |
| --- | --- |
| Python 3.12+ | Matches the project's minimum version. |
| Virtual environment activated | Tests need `pytest` installed. |
| No Salesforce CLI needed | Tests never connect to Salesforce. |

### First-Time Setup

```bash
cd C:\Users\dwishar1\Downloads\Python
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements-dev.txt
```

The `requirements-dev.txt` file includes `pytest` and any other testing tools.

---

## Running the Tests

### Run All Tests

```bash
pytest tests/test_create_agency_zips_contract.py -v
```

### Run a Single Test Class

```bash
pytest tests/test_create_agency_zips_contract.py::TestParseFolderName -v
```

### Run a Single Test

```bash
pytest tests/test_create_agency_zips_contract.py::TestParseFolderName::test_valid_simple_name -v
```

### Run With Coverage

```bash
pytest tests/test_create_agency_zips_contract.py --cov=scripts --cov-report=term-missing
```

---

## Test Structure Walkthrough

### Module Loading Fixture

```python
@pytest.fixture(scope="module")
def module():
```

Because the script under test is a standalone `.py` file (not an installed package),
the tests use `importlib` to load it as a module. This fixture runs once per test
session and makes all the script's functions available via `module.function_name()`.

### Test Classes

Each class groups tests for one function. The naming convention is:

```text
test_<function_name>_<scenario>_<expected_result>
```

| Test Class | Function Under Test | What It Verifies |
| --- | --- | --- |
| `TestFormatElapsed` | `format_elapsed()` | Time formatting for seconds, minutes, and hours. |
| `TestParseFolderName` | `parse_folder_name()` | Parsing valid folders, rejecting invalid ones. |
| `TestSafeZipFilename` | `safe_zip_filename()` | Cleaning agency names for use as ZIP filenames. |
| `TestDiscoverAgencyFolders` | `discover_agency_folders()` | Grouping folders, skipping non-matching, error handling. |
| `TestCreateAgencyZip` | `create_agency_zip()` | ZIP creation, empty folders, error cleanup, nested files. |
| `TestWriteManifest` | `write_manifest()` | CSV header and row writing. |
| `TestEnrichSourceManifest` | `enrich_source_manifest_with_zip_names()` | Adding ZipFileName column, unmatched rows, missing columns. |
| `TestTimedDecorator` | `@timed` | Decorator preserves return value, name, and logs timing. |
| `TestTimerContextManager` | `timer()` | Context manager logs label and elapsed time. |
| `TestLogSummary` | `log_summary()` | Outputs key metrics; handles zero-byte edge case. |
| `TestMainOrchestration` | `main()` | End-to-end: no folders, creates ZIPs, enriches manifest, preserves `AccountName` and `AccountSCAID` columns. |

### How Tests Use `tmp_path`

Many tests create real files and folders on disk using pytest's built-in `tmp_path`
fixture. This gives each test a unique temporary directory that is automatically
cleaned up afterwards. For example:

```python
def test_groups_folders_by_agency(self, module, tmp_path):
    (tmp_path / "00000001_Agency A_a0A8d00000DK2smEAD").mkdir()
    result = module.discover_agency_folders(tmp_path)
    assert "Agency A" in result
```

---

## How to Add a New Test

1. **Identify the function** you want to test.
1. **Find or create the test class** for that function.
1. **Write a test method** following the naming pattern:

```python
def test_<function>_<scenario>_<expected>(self, module: Any, tmp_path: Path) -> None:
    """One-sentence description of the behaviour being tested."""
    # Arrange - set up inputs
    # Act - call the function
    # Assert - check the result
```

1. **Run the test** to confirm it passes:

```bash
pytest tests/test_create_agency_zips_contract.py::<YourTestClass>::<your_test> -v
```

### Example: Testing a New Edge Case

```python
def test_parse_folder_name_unicode_agency(self, module: Any) -> None:
    """Folder names with unicode characters are parsed correctly."""
    result = module.parse_folder_name("00000001_Ünited Ägency_a0A8d00000DK2smEAD")
    assert result is not None
    assert result[1] == "Ünited Ägency"
```

---

## Key Concepts for Beginners

### What is pytest?

`pytest` is a testing framework for Python. You write functions that start with
`test_` and pytest automatically discovers and runs them, reporting pass/fail.

### What is a Fixture?

A fixture is a reusable piece of setup code. In this file, the `module` fixture
loads the script so every test can call its functions. The `tmp_path` fixture
provides a fresh temporary directory.

### What Does `assert` Do?

`assert` checks that a condition is true. If it is false, the test fails with a
clear error message showing what was expected vs. what actually happened.

### Why Group Tests in Classes?

Classes group related tests together. This makes it easy to run all tests for one
function and keeps the file organised as it grows.

### What is `scope="module"`?

It means the fixture is created once and shared across all tests in the file,
rather than being recreated for every single test. This speeds up the test suite
because loading the script (which creates directories and sets up logging) only
happens once.

---

## Troubleshooting

### "ModuleNotFoundError: No module named 'pytest'"

Activate your virtual environment and install dev dependencies:

```bash
.venv\Scripts\activate
pip install -r requirements-dev.txt
```

### Tests fail with "Could not load module spec"

Ensure the script file exists at the expected path. The test looks for:

```text
scripts/create_agency_zips_contract.py
```

### Tests create folders in unexpected places

The script creates `OUTPUT_DIR` at import time. This is a known side effect of
loading the module during tests. The directory is harmless and can be deleted.

### A test fails after changing the script

This is the test suite working as intended. Read the assertion error to understand
what changed, then either fix the script or update the test if the new behaviour
is correct.

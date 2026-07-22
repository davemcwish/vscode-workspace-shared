# Beginner's Guide - Testing the List Inactive Users Script

This guide explains how the `test_list_inactive_users.py` test suite works, how to
run it, and how to add new tests. It is written for people who are new to Python
testing and pytest.

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

This file contains **automated tests** that verify the `list_inactive_users.py`
script works correctly. Each test exercises one specific function or behaviour in
isolation - without needing Salesforce access, network connections, or real user
data.

The tests use **mocking** to simulate Salesforce client responses, so you can run
them safely on any machine at any time.

Tests give you confidence that:

- The cutoff date calculation is accurate.
- Command-line arguments are parsed and validated correctly.
- The SOQL query template is well-formed.
- The main function orchestrates everything and returns the correct exit code.
- No mutations occur (even with `--apply`).

---

## Prerequisites

| Requirement | Why |
| --- | --- |
| Python 3.13+ | Matches the project's minimum version. |
| Virtual environment activated | Tests need `pytest` and project dependencies installed. |
| No Salesforce access needed | All Salesforce calls are mocked. |
| No network needed | All external calls are mocked. |

### First-Time Setup

```bash
cd C:\Users\dwishar1\Downloads\Python
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements-dev.txt
```

---

## Running the Tests

### Run All Tests in This File

```bash
pytest tests/test_list_inactive_users.py -v
```

### Run a Single Test Class

```bash
pytest tests/test_list_inactive_users.py::TestCutoffIso -v
```

### Run a Single Test

```bash
pytest tests/test_list_inactive_users.py::TestParseArgs::test_minimal_valid_args -v
```

### Run With Coverage

```bash
pytest tests/test_list_inactive_users.py --cov=scripts --cov-report=term-missing
```

---

## Test Structure Walkthrough

### Test Classes

Each class groups tests for one function or component:

| Test Class | Function Under Test | What It Verifies |
| --- | --- | --- |
| `TestCutoffIso` | `_cutoff_iso()` | ISO date formatting, correctness of date arithmetic. |
| `TestParseArgs` | `parse_args()` | Argument parsing, defaults, validation, error handling. |
| `TestFindInactiveUsers` | `find_inactive_users()` | Salesforce client construction, query execution, result mapping. |
| `TestMain` | `main()` | Orchestration, exit codes, logging output. |
| `TestSoqlTemplate` | `_USER_QUERY_TEMPLATE` | Template correctness, placeholder formatting. |

### How Mocking Works in These Tests

The tests use `unittest.mock.patch` to replace real dependencies with controlled
fakes:

- **`build_client`** is patched to prevent real Salesforce connections.
- **`with_retry`** is patched to return fake query results directly.
- **`configure_logging`** is patched to prevent logging configuration side effects.

This means tests are:

- **Fast** - no network or I/O.
- **Reliable** - not affected by expired sessions or Salesforce outages.
- **Safe** - never touch real user data.

### How caplog Works

The `TestMain` class uses pytest's `caplog` fixture to capture log output. This
lets you assert that specific messages (like user IDs) appear in the logs without
inspecting stderr directly.

---

## How to Add a New Test

1. **Identify the function** you want to test.
1. **Find or create the test class** for that function.
1. **Write a test method** following the naming pattern:

```python
def test_<function>_<scenario>_<expected>(self) -> None:
    """One-sentence description of the behaviour being tested."""
    # Arrange - set up inputs
    # Act - call the function
    # Assert - check the result
```

1. **Run the test** to confirm it passes:

```bash
pytest tests/test_list_inactive_users.py::<YourTestClass>::<your_test> -v
```

### Example: Testing a New Edge Case

```python
def test_cutoff_iso_one_day(self) -> None:
    """Cutoff for 1 day is approximately 24 hours ago."""
    result = list_inactive_users._cutoff_iso(1)
    parsed = datetime.strptime(result, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=UTC)
    expected = datetime.now(tz=UTC) - timedelta(days=1)
    assert abs((parsed - expected).total_seconds()) < 2
```

### Example: Testing With a Mocked Client

```python
@patch("scripts.list_inactive_users.build_client")
@patch("scripts.list_inactive_users.with_retry")
def test_find_inactive_users_with_many_records(
    self, mock_with_retry: MagicMock, mock_build_client: MagicMock
) -> None:
    """Large result sets are returned in full."""
    records = [{"Id": f"005{i:015d}", "Username": f"u{i}@t.com", "LastLoginDate": None}
               for i in range(500)]
    mock_with_retry.return_value = {"records": records}

    result = list_inactive_users.find_inactive_users("uat", 90)

    assert len(result) == 500
```

---

## Key Concepts for Beginners

### What is pytest?

`pytest` is a testing framework for Python. You write functions that start with
`test_` and pytest automatically discovers and runs them, reporting pass/fail.

### What is Mocking?

Mocking replaces a real dependency (like a Salesforce API call) with a fake object
you control. This lets you test your code's logic without relying on external
systems.

### What is a Fixture?

A fixture is a reusable piece of setup code. The `conftest.py` file provides shared
fixtures like `mock_sf` and `sf_env` that are available to all test files.

### What Does `@patch` Do?

The `@patch` decorator temporarily replaces a function or object with a
`MagicMock`. When the test finishes, the original is automatically restored. You
specify the patch target as the import path where the function is **used**, not
where it is **defined**.

### Why Group Tests in Classes?

Classes group related tests together. This makes it easy to run all tests for one
function and keeps the file organised as it grows.

---

## Troubleshooting

### "ModuleNotFoundError: No module named 'pytest'"

Activate your virtual environment and install dev dependencies:

```bash
.venv\Scripts\activate
pip install -r requirements-dev.txt
```

### "ModuleNotFoundError: No module named 'scripts'"

Ensure the project is installed in editable mode:

```bash
pip install -e .
```

Or run pytest from the project root so Python can find the `scripts` package.

### "ModuleNotFoundError: No module named 'sf_admin_utils'"

Install the project package:

```bash
pip install -e .
```

### A test fails after changing the script

This is the test suite working as intended. Read the assertion error to understand
what changed, then either fix the script or update the test if the new behaviour
is correct.

# Beginner's Guide - Testing the Export Contract PDFs Script

This guide explains how the `test_export_contract_pdfs.py` test suite works,
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

This file contains **automated tests** that verify the `export_contract_pdfs.py`
script works correctly. Each test exercises one specific function or behaviour in
isolation - without needing Salesforce access, network connections, or real PDF files.

The tests use **mocking** to simulate Salesforce CLI responses and HTTP calls, so
you can run them safely on any machine at any time.

Tests give you confidence that:

- The manifest CSV includes `AccountName` and `AccountSCAID` in the correct column positions.
- Utility functions (filename cleaning, time formatting, chunking) behave correctly.
- Sensitive data (session tokens) is properly redacted before logging.
- The Salesforce session class initialises and refreshes credentials.
- The HTTP helper validates inputs and handles errors appropriately.
- File downloads succeed, retry on failure, and clean up temporary files on error.
- Output paths are built correctly for both normal and short-path fallback scenarios.
- Single-PDF processing handles missing data, path-length errors, and fallback logic.
- The main orchestration function queries agencies, orders, and PDF links, then
  writes a manifest CSV - even when individual download threads raise exceptions.

---

## Prerequisites

| Requirement | Why |
| --- | --- |
| Python 3.13+ | Matches the project's minimum version. |
| Virtual environment activated | Tests need `pytest` and `requests` installed. |
| No Salesforce CLI needed | All CLI calls are mocked - tests never hit real orgs. |
| No network needed | All HTTP calls are mocked. |

> **Virtual environment** means an isolated folder of Python packages that prevents
> conflicts between projects. Activate it before running any commands.

### First-Time Setup

```bash
cd C:\Users\dwishar1\Downloads\Python
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements-dev.txt
```

The `requirements-dev.txt` file includes `pytest`, `requests`, and any other
testing tools.

---

## Running the Tests

### Run All Tests in This File

```bash
pytest tests/test_export_contract_pdfs.py -v
```

### Run a Single Test Class

```bash
pytest tests/test_export_contract_pdfs.py::TestSafeFilename -v
```

### Run a Single Test

```bash
pytest tests/test_export_contract_pdfs.py::TestSafeFilename::test_safe_filename_removes_invalid_characters -v
```

### Run With Coverage

```bash
pytest tests/test_export_contract_pdfs.py --cov=scripts --cov-report=term-missing
```

---

## Test Structure Walkthrough

### Module Loading Fixture

```python
@pytest.fixture(scope="module")
def module():
```

Because the script under test is a standalone `.py` file that performs side effects
at import time (CLI authentication, directory creation), the fixture:

1. Uses `importlib` to load the script as a module.
1. **Patches `subprocess.run`** so the Salesforce CLI (the command-line tool used
   to log in to a Salesforce org - a single Salesforce environment) is never
   actually called.
1. Provides fake credentials that the script uses during its initialisation.

This fixture runs once per test session and makes all the script's functions
available via `module.function_name()`.

### Test Classes

Each class groups tests for one function or class:

| Test Class | Function / Class Under Test | What It Verifies |
| --- | --- | --- |
| `test_manifest_columns_include_account_name` | `MANIFEST_COLUMNS` | Verifies `AccountName` is present and positioned after `OrderNumber`. |
| `test_manifest_columns_include_account_scaid` | `MANIFEST_COLUMNS` | Verifies `AccountSCAID` is present and positioned after `AccountName`. |
| `TestFormatElapsed` | `format_elapsed()` | Time formatting for seconds, minutes, hours, and zero. |
| `TestSafeFilename` | `safe_filename()` | Invalid chars, empty input, truncation, whitespace collapsing, trailing dots. |
| `TestEnsurePdfExtension` | `ensure_pdf_extension()` | Adding `.pdf`, avoiding duplicate extensions, case handling. |
| `TestChunked` | `chunked()` | Even splits, remainders, empty lists. |
| `TestSoqlIdList` | `soql_id_list()` | Formatting IDs for SOQL (Salesforce Object Query Language) `IN` clauses - single-quoted and comma-separated. |
| `TestRedactSensitiveText` | `redact_sensitive_text()` | Removing session tokens (temporary password-like strings) from log messages. |
| `TestGetStr` | `_get_str()` | Safe string extraction from Salesforce records with `None` and missing-key handling. |
| `TestSalesforceSession` | `SalesforceSession` | Credential initialisation and token refresh. |
| `TestSfGet` | `sf_get()` | Input validation, successful HTTP responses, and 401 (session expired) handling. |
| `TestTimedDecorator` | `@timed` decorator | Decorated functions return their original value and write a `[TIMER]` log entry. |
| `TestQueryAll` | `query_all()` | Single-page SOQL results and multi-page pagination via `nextRecordsUrl`. |
| `TestGetCliOrgAuth` | `get_cli_org_auth()` | Returns `(token, url)` on success; raises `RuntimeError` when the access token is missing or the status is non-zero. |
| `TestDownloadContentVersionOnce` | `download_content_version_once()` | Downloads and writes file content; raises on empty `version_id`; cleans up temp files on write failure. |
| `TestDownloadWithRetries` | `download_content_version_with_retries()` | Succeeds on the first attempt; retries and raises after all attempts fail. |
| `TestOutputPathBuilders` | `build_normal_output_path()` / `build_fallback_output_path()` | Normal path structure under `OUTPUT_DIR`; fallback path includes `_short_path_fallback`. |
| `TestBuildAgencyMap` | `build_agency_map()` | Creates a lookup dict keyed by record `Id`; returns empty dict for empty input. |
| `TestProcessSinglePdf` | `process_single_pdf()` | Downloads PDF and returns success result dict; handles missing `LatestPublishedVersionId` with an error result. |
| `TestQueryAgencyPrivacyRecords` | `query_agency_privacy_records()` | Queries `AgencyPrivacyData__c` records (the `__c` suffix means this is a custom Salesforce object, not a standard one); respects `TARGET_AGENCY_RECORD_ID` filter. |
| `TestQueryOrdersById` | `query_orders_by_id()` | Returns empty dict for empty input; returns dict keyed by Order ID otherwise. |
| `TestQueryPdfLinks` | `query_pdf_links_for_agency_records()` | Returns empty list for empty agency IDs; returns `ContentDocumentLink` records (the Salesforce object that links an uploaded file to a record) otherwise. |
| `TestLogExportSummary` | `log_export_summary()` | Logs all key batch metrics: agency count, order count, link count, downloads, skips, fallbacks, and errors. |
| `TestMainOrchestration` | `main()` - full flow | Queries agencies, orders, and PDF links; downloads files concurrently; writes a manifest CSV. |
| `TestProcessSinglePdfFallback` | `process_single_pdf()` - errno-2 fallback | Falls back to a short output path on Windows path-length errors (`errno=2`); skips when fallback file exists; returns error when both paths fail; skips fallback for non-path errors. |
| `TestMainAdditional` | `main()` - thread error handling | Counts thread-level errors and still writes the manifest CSV even when `process_single_pdf` raises unexpectedly. |

### How Mocking Works in These Tests

The tests use `unittest.mock` to replace real dependencies with controlled fakes.
**Mocking** means swapping a real function or object for a fake one that returns
whatever the test needs, without doing any real work.

- **`subprocess.run`** is patched during module loading to prevent real Salesforce
  CLI calls.
- **`requests.get`** is patched to simulate HTTP responses for queries and downloads.
- **`get_cli_org_auth`** is patched in `TestSalesforceSession` to control what
  credentials are returned.
- **`MagicMock` response objects** simulate HTTP responses with custom status codes,
  headers, and streaming content.
- **`patch.object`** swaps out individual functions on the loaded module, allowing
  tests to isolate one function at a time without affecting others.
- **`monkeypatch`** temporarily replaces module-level constants (`OUTPUT_DIR`,
  `FORCE_REDOWNLOAD`, etc.) so tests can control script behaviour without editing
  source files.

This means tests are:

- **Fast** - no network or disk I/O (except `tmp_path` for file-writing tests).
- **Reliable** - not affected by expired sessions or API outages.
- **Safe** - never touch production Salesforce data.

---

## How to Add a New Test

1. **Identify the function** you want to test.
1. **Find or create the test class** for that function.
1. **Write a test method** following the naming pattern:

```python
def test_<function>_<scenario>_<expected>(self, module: Any) -> None:
    """One-sentence description of the behaviour being tested."""
    # Arrange - set up inputs
    # Act - call the function
    # Assert - check the result
```

1. **Run the test** to confirm it passes:

```bash
pytest tests/test_export_contract_pdfs.py::<YourTestClass>::<your_test> -v
```

### Example: Testing a New Edge Case

```python
def test_safe_filename_handles_only_spaces(self, module: Any) -> None:
    """A filename of only spaces returns 'Untitled'."""
    assert module.safe_filename("     ") == "Untitled"
```

### Example: Testing With Mocked HTTP

```python
@patch("requests.get")
def test_sf_get_builds_full_url_from_path(self, mock_get: MagicMock, module: Any) -> None:
    """Relative paths are prefixed with instance_url."""
    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.ok = True
    mock_get.return_value = mock_response

    module.sf_get("token", "https://inst.sf.com", "/services/data/v66.0/query")

    called_url = mock_get.call_args[0][0]
    assert called_url == "https://inst.sf.com/services/data/v66.0/query"
```

### Example: Testing With a File on Disk

Some tests need to write real files. Use the `tmp_path` fixture - pytest creates a
temporary folder and cleans it up after the test automatically:

```python
@patch("requests.get")
def test_downloads_to_path(self, mock_get: MagicMock, module: Any, tmp_path: Path) -> None:
    """Downloaded bytes are written to output_path."""
    mock_resp = MagicMock()
    mock_resp.status_code = 200
    mock_resp.ok = True
    mock_resp.iter_content.return_value = [b"%PDF-1.4"]
    mock_resp.close = MagicMock()
    mock_get.return_value = mock_resp

    output = tmp_path / "contract.pdf"
    module.download_content_version_once("tok", "https://x.com", "068xx", output)
    assert output.read_bytes() == b"%PDF-1.4"
```

---

## Key Concepts for Beginners

### What is pytest?

`pytest` is a testing framework for Python. You write functions that start with
`test_` and pytest automatically discovers and runs them, reporting pass/fail.

### What is Mocking?

Mocking replaces a real dependency (like an HTTP call or CLI command) with a fake
object you control. This lets you test your code's logic without relying on
external systems.

### What is a Fixture?

A fixture is a reusable piece of setup code. The `module` fixture loads the script
once so every test can call its functions without re-running the expensive import.

### What is `scope="module"`?

It means the fixture is created once and shared across all tests in the file,
rather than being recreated for every single test. This is important here because
loading the script module is slow (it authenticates, patches `subprocess`, etc.).

### What is `MagicMock`?

A `MagicMock` is a fake object that accepts any attribute access or method call.
You configure it with `.return_value` or `.iter_content.return_value = [...]` to
simulate real HTTP response behaviour.

### What is `monkeypatch`?

`monkeypatch` is a pytest fixture that temporarily replaces constants, attributes,
or functions on a module for the duration of one test. For example,
`monkeypatch.setattr(module, "OUTPUT_DIR", tmp_path)` redirects all file output
to a temporary folder instead of your real output directory.

### What is `errno=2`?

On Windows, creating a file at a path longer than ~260 characters raises an
`OSError` with `errno=2` (meaning "No such file or directory" - confusingly, this
is Windows reporting a path-too-long failure). The fallback path tests exercise
exactly this scenario.

### What Does `# noqa: S105` Mean?

It tells the linter to ignore the "possible hardcoded password" warning on that
line. In tests, we deliberately use fake token strings - they are not real secrets.

---

## Troubleshooting

### "ModuleNotFoundError: No module named 'pytest'"

Activate your virtual environment (the isolated folder of Python packages) and
install dev dependencies:

```bash
.venv\Scripts\activate
pip install -r requirements-dev.txt
```

### "ModuleNotFoundError: No module named 'requests'"

The script under test imports `requests`. Install it:

```bash
pip install -r requirements.txt
```

### Tests fail with "Could not load module spec"

Ensure the script file exists at the expected path:

```text
scripts/export_contract_pdfs.py
```

### Ruff reports S105 "Possible hardcoded password"

This is a false positive on test assertion lines that compare against fake token
strings. The `# noqa: S105` comment suppresses it. Do not remove those comments.

### A test fails after changing the script

This is the test suite working as intended. Read the assertion error to understand
what changed, then either fix the script or update the test if the new behaviour
is correct.

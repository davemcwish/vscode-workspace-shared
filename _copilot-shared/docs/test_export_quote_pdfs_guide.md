# Beginner's Guide - Testing the Export Quote PDFs Script

This guide explains how the `test_export_quote_pdfs.py` test suite works, how
to run it, and how to add new tests. It is written for people who are new to Python
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

This file contains **automated tests** that verify the `export_quote_pdfs.py`
script works correctly. Each test exercises one specific function or behaviour in
isolation - without needing Salesforce access, network connections, or real PDF files.

The tests use **mocking** to simulate Salesforce CLI responses and HTTP calls, so
you can run them safely on any machine at any time.

Tests give you confidence that:

- The manifest CSV includes `AccountName` and `AccountSCAID` in the correct column positions.
- Validation functions reject bad input and accept good input.
- Utility functions (filename cleaning, SOQL escaping, chunking) behave correctly.
- Sensitive data (session tokens) is properly redacted before logging.
- URL decoding and redirect extraction work against real Salesforce HTML patterns.
- PDF detection correctly identifies PDF responses vs. HTML wrappers.
- The Salesforce session class initialises and refreshes credentials.
- The HTTP helper validates inputs and handles errors appropriately.
- Quote PDF downloads fall back gracefully when the primary download method fails.
- The main orchestration function writes a manifest CSV and handles errors correctly.

---

## Prerequisites

| Requirement | Why |
| --- | --- |
| Python 3.12+ | Matches the project's minimum version. |
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
pytest tests/test_export_quote_pdfs.py -v
```

### Run a Single Test Class

```bash
pytest tests/test_export_quote_pdfs.py::TestValidateSalesforceId -v
```

### Run a Single Test

```bash
pytest tests/test_export_quote_pdfs.py::TestSoqlEscape::test_escapes_single_quotes -v
```

### Run With Coverage

```bash
pytest tests/test_export_quote_pdfs.py --cov=scripts --cov-report=term-missing
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
| `test_manifest_columns_include_account_name` | `MANIFEST_COLUMNS` | Verifies `AccountName` is present and positioned after `QuoteName`. |
| `test_manifest_columns_include_account_scaid` | `MANIFEST_COLUMNS` | Verifies `AccountSCAID` is present and positioned after `AccountName`. |
| `TestFormatElapsed` | `format_elapsed()` | Time formatting for seconds, minutes, hours, and zero. |
| `TestValidateSalesforceId` | `validate_salesforce_id()` | Accepts valid 15/18-char Salesforce record IDs; rejects invalid ones. |
| `TestValidateSalesforceFieldApiName` | `validate_salesforce_field_api_name()` | Guards against SOQL injection in field names. SOQL (Salesforce Object Query Language) is Salesforce's version of SQL. |
| `TestValidateSalesforceObjectApiName` | `validate_salesforce_object_api_name()` | Guards against SOQL injection in object names. |
| `TestSafeFilename` | `safe_filename()` | Invalid chars, empty input, truncation, whitespace collapsing, trailing dots. |
| `TestSoqlEscape` | `soql_escape()` | Escaping single quotes and backslashes for safe SOQL strings. |
| `TestChunkList` | `chunk_list()` | Even splits, remainders, empty lists, invalid chunk sizes. |
| `TestBuildVisualforceQuotePdfPath` | `build_visualforce_quote_pdf_path()` | Correct Visualforce (Salesforce server-side HTML template technology) path construction and ID validation. |
| `TestGetQuoteOfferNumber` | `get_quote_offer_number()` | Extracting offer numbers from quote records, with fallback for missing values. |
| `TestRedactSensitiveText` | `redact_sensitive_text()` | Removing session tokens (temporary password-like strings) from log messages. |
| `TestDecodeSalesforceRedirectUrl` | `decode_salesforce_redirect_url()` | HTML entity decoding and escaped slash handling in Salesforce redirect URLs. |
| `TestResponseLooksLikePdf` | `response_looks_like_pdf()` | PDF magic bytes (`%PDF`) and `Content-Type` header detection. |
| `TestExtractEmbeddedPdfCandidateUrl` | `extract_embedded_pdf_candidate_url()` | Parsing iframe/embed URLs from Salesforce HTML wrapper pages. |
| `TestExtractJavascriptRedirectUrl` | `extract_javascript_redirect_url()` | Finding `window.location` redirect patterns in Salesforce HTML. |
| `TestSalesforceSession` | `SalesforceSession` | Credential initialisation and token refresh. |
| `TestSfGet` | `sf_get()` | Input validation, successful HTTP responses, and 401 (session expired) handling. |
| `TestCollectQuoteIds` | `collect_quote_ids()` | Deduplication of Quote IDs, skipping `None` values, empty input. |
| `TestTimedDecorator` | `@timed` decorator | Decorated functions return their original value and write a `[TIMER]` log entry. |
| `TestTimerContextManager` | `timer()` context manager | The context manager logs its label when the block exits. |
| `TestQueryAll` | `query_all()` | Single-page SOQL results and multi-page pagination via `nextRecordsUrl`. |
| `TestGetCliOrgAuth` | `get_cli_org_auth()` | Returns `(token, url)` on success; raises `RuntimeError` when the access token is missing. |
| `TestQuotePdfOutputPaths` | `build_quote_pdf_output_path()` / `build_quote_pdf_fallback_output_path()` | Normal path structure and short fallback path naming. |
| `TestBuildManifestRow` | `build_manifest_row()` | Output is a flat list of strings suitable for CSV writing, containing record and status fields. |
| `TestQueryAgencyPrivacyRecords` | `query_agency_privacy_records()` | Queries and returns `AgencyPrivacyData__c` records. The `__c` suffix means this is a custom Salesforce object, not a standard one. |
| `TestQueryQuotesByIds` | `query_quotes_by_ids()` | Returns an empty dict for an empty ID list; returns a dict keyed by Quote ID otherwise. |
| `TestValidatePdfResponse` | `validate_pdf_response()` | Returns bytes when the response is a PDF; raises `RuntimeError` when it is not. |
| `TestSaveDebugResponse` | `save_debug_response()` | Saves HTML responses as `.html` and binary responses as `.bin` debug files. |
| `TestDownloadQuoteCustomPdfOnce` | `download_quote_custom_pdf_once()` | Validates `output_path`, downloads via the first available method, and writes the file. |
| `TestDownloadQuoteCustomPdfOnceFallback` | `download_quote_custom_pdf_once()` - fallback logic | Falls back through three download methods in order; raises and cleans up temp files when all three fail. |
| `TestDownloadQuoteCustomPdfWithRetries` | `download_quote_custom_pdf_with_retries()` | Succeeds on the first attempt; retries and raises after all attempts fail. |
| `TestGetResponseFollowingSalesforceJavascriptRedirects` | `get_response_following_salesforce_javascript_redirects()` | Follows `window.location.replace()` and iframe redirects to reach the final PDF; detects and stops redirect loops. |
| `TestGetQuotePdfViaFrontdoor` | `get_quote_pdf_response_via_frontdoor()` | Input validation and PDF retrieval via the Salesforce `frontdoor.jsp` login path. |
| `TestGetQuotePdfViaVisualforceSession` | `get_quote_pdf_response_via_visualforce_session()` | Input validation and PDF retrieval via the Visualforce session path. |
| `TestGetQuotePdfViaBearer` | `get_quote_pdf_response_via_bearer()` | Input validation and PDF retrieval via a direct Bearer token (an access token passed in the HTTP `Authorization` header). |
| `TestLogBatchSummary` | `log_batch_summary()` | Logs all key batch metrics: total, downloaded, skipped, and error counts. |
| `TestGetRecordName` | `get_record_name()` | Returns the `Name` field value; returns empty string for missing `Name`. |
| `TestExportOneAgencyPrivacyQuotePdf` | `export_one_agency_privacy_quote_pdf()` | Skips when no Quote lookup, errors when quote not in map, skips existing files, and downloads successfully. |
| `TestExportOneAgencyPrivacyQuotePdfFallback` | `export_one_agency_privacy_quote_pdf()` - short-path fallback | Falls back to a short output path when the normal path fails; skips when the fallback file already exists; returns `Error` when both paths fail. |
| `TestProcessSingleQuotePdf` | `process_single_quote_pdf()` | Returns a result dict with `manifest_row` and `status`; catches exceptions and reports `Error` status. |
| `TestMainOrchestration` | `main()` - early exit | Exits early with a warning when no `AgencyPrivacyData__c` records are found. |
| `TestMainWithQuoteRecords` | `main()` - full run | Runs the concurrent download flow and writes a manifest CSV; raises `RuntimeError` when `FAIL_SCRIPT_ON_RECORD_ERRORS` is `True` and errors are found. |

### How Mocking Works in These Tests

The tests use `unittest.mock` to replace real dependencies with controlled fakes.
**Mocking** means swapping a real function or object for a fake one that returns
whatever the test needs, without doing any real work.

- **`subprocess.run`** is patched during module loading to prevent real Salesforce
  CLI calls.
- **`requests.get`** / **`requests.Session`** are patched to simulate HTTP responses.
- **`get_cli_org_auth`** is patched in `TestSalesforceSession` to control what
  credentials are returned.
- **`MagicMock` response objects** simulate HTTP responses with custom headers and
  content for PDF detection and URL extraction tests.
- **`patch.object`** swaps out individual functions on the loaded module, allowing
  tests to isolate one function at a time.

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
pytest tests/test_export_quote_pdfs.py::<YourTestClass>::<your_test> -v
```

### Example: Testing a New Validation Rule

```python
def test_validate_salesforce_id_exactly_15_chars(self, module: Any) -> None:
    """A 15-character alphanumeric string passes validation."""
    module.validate_salesforce_id("0Q0Ab0000012345")
```

### Example: Testing With a Mocked HTTP Response

```python
def test_response_looks_like_pdf_empty_content(self, module: Any) -> None:
    """Empty response content is not detected as PDF."""
    response = MagicMock()
    response.headers = {"Content-Type": "application/octet-stream"}
    response.content = b""
    assert module.response_looks_like_pdf(response) is False
```

### Example: Testing With a File on Disk

Some tests need to write real files. Use the `tmp_path` fixture - pytest creates a
temporary folder and cleans it up after the test automatically:

```python
def test_saves_debug_file(self, module: Any, tmp_path: Path, monkeypatch: Any) -> None:
    """Debug response is saved to the debug directory."""
    monkeypatch.setattr(module, "DEBUG_RESPONSE_DIR", tmp_path)
    response = MagicMock()
    response.content = b"<html>Error</html>"
    response.headers = {"Content-Type": "text/html"}
    path = module.save_debug_response(response, "0Q0xx", "test")
    assert path.exists()
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
You configure it with `.return_value` or `.headers = {...}` to simulate the real
object's behaviour.

### What is `monkeypatch`?

`monkeypatch` is a pytest fixture that lets you temporarily replace constants,
attributes, or functions on a module for the duration of one test. For example,
`monkeypatch.setattr(module, "OUTPUT_DIR", tmp_path)` redirects all file output
to a temporary folder instead of your real output directory.

### What is `ClassVar`?

`ClassVar[T]` is a type annotation (a hint to type checkers like mypy) that marks
an attribute as belonging to the class itself rather than to an instance of it.
It must be imported from `typing` at the **module level**, not inside a class body.

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
scripts/export_quote_pdfs.py
```

### Ruff reports S105 "Possible hardcoded password"

This is a false positive on test assertion lines that compare against fake token
strings. The `# noqa: S105` comment suppresses it. Do not remove those comments.

### A test fails after changing the script

This is the test suite working as intended. Read the assertion error to understand
what changed, then either fix the script or update the test if the new behaviour
is correct.

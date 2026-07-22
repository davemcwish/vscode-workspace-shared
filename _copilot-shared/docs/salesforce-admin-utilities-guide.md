# Salesforce Admin Utilities - Complete Project Guide

## About This Guide

This document consolidates the full development history, architecture, and
operational knowledge of the Salesforce Admin Utilities project. It is structured
for someone with minimal Python, Salesforce, or coding experience to read from
start to finish and understand how to set up, run, maintain, and extend the
project.

**Project goal:** Beginner-friendly Python utilities for exporting Salesforce PDF
documents (Contracts and Quotes), zipping them by agency, and running quality
checks.

**Date range covered:** 2026-05-09 to 2026-05-27

**AI assistants used:** GPT 5.5 (FordLLM), Claude 4.7 Opus, Claude 4.6 Sonnet,
Gemma 4, GitHub Copilot (Claude Opus 4.6)

---

## Part 1 - Environment Setup

### 1.1 Prerequisites

| Tool | Version | Purpose |
| --- | --- | --- |
| Windows 11 | - | Operating system |
| Python | 3.13 | Runtime (project target) |
| pip | bundled | Package installer |
| pip-tools | 7.4+ | Dependency locking (`pip-compile`, `pip-sync`) |
| Salesforce CLI (`sf`) | latest | Authentication to Salesforce orgs |
| VS Code | latest | IDE |
| Git | latest | Version control |

### 1.2 Why Python 3.13

Python 3.13 is the project target because:

- It is the version installed on the maintainer's development machine.
- `pyproject.toml` is configured with `requires-python = ">=3.13"`.
- mypy is configured with `python_version = "3.13"`.
- Ruff is configured with `target-version = "py313"`.

If Ford's JFrog Artifactory mirror lacks a wheel for a dependency on 3.13,
pin an available version in `requirements*.txt` or raise it through the approved
package-review process rather than downgrading the interpreter.

### 1.3 Virtual Environment Setup

```batch
:: Create virtual environment
py -m venv .venv

:: Activate (PowerShell)
.venv\Scripts\Activate.ps1

:: Activate (Command Prompt)
.venv\Scripts\activate.bat

:: Install all dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

### 1.4 Ford JFrog Artifactory Notes

Ford's internal PyPI mirror does not carry all packages or versions. Known
constraints discovered during setup:

| Package | Issue | Resolution |
| --- | --- | --- |
| `pytest==8.3.3` | Exact version not on mirror | Use `~=8.3` (flexible) |
| `responses==0.25.3` | Not available | Pin to `==0.20.0` |
| `pip-audit` | Not on mirror at all | Removed from requirements |
| `interrogate` | Not on mirror | Use `ruff check --select D --statistics` instead |
| `vulture` | Not on mirror | Use `ruff check --select F401,F841,ARG,ERA` instead |

If a package is unavailable, submit a PyServ request through Ford's internal
process to get it added.

### 1.5 Dependency Management with pip-tools

```batch
:: Compile loose requirements into pinned lock file
pip-compile requirements.in -o requirements.txt

:: Compile dev dependencies
pip-compile requirements-dev.in -o requirements-dev.txt

:: Sync environment to match lock file exactly
pip-sync requirements.txt requirements-dev.txt

:: Upgrade outdated packages (custom script)
update_packages.bat
```

### 1.6 Salesforce CLI Authentication

```batch
:: Login to Production Salesforce org
sf org login web --alias AXP_PROD

:: Login to UAT (User Acceptance Testing) sandbox org
sf org login web --alias AXP_UAT --instance-url https://test.salesforce.com

:: Login to SIT (System Integration Testing) sandbox org
sf org login web --alias AXP_SIT --instance-url https://test.salesforce.com

:: Verify current orgs
sf org list

:: Check active session (redact accessToken before sharing output)
sf org display --target-org AXP_PROD --json
```

---

## Part 2 - VS Code and Copilot Configuration

### 2.1 Recommended Extensions

| Extension | Purpose |
| --- | --- |
| GitHub Copilot + Chat | AI code assistant |
| Python (ms-python) | Language support, debugging |
| Pylance | Type checking in editor |
| Ruff | Linting + formatting |
| markdownlint | Markdown quality |
| GitLens | Git blame and history |
| Code Spell Checker | Typo detection |

### 2.2 Copilot Instruction Files

The project uses a layered instruction system:

| File | Scope | Purpose |
| --- | --- | --- |
| `.github/copilot-instructions.md` | All Copilot interactions | Master rules (auto-discovered) |
| `.github/instructions/python.instructions.md` | `**/*.py` | Python coding standards |
| `.github/instructions/testing.instructions.md` | `tests/**/*.py` | pytest conventions |
| `.github/instructions/salesforce.instructions.md` | `src/**/*.py`, `scripts/**/*.py` | Salesforce API safety |
| `.github/instructions/security.instructions.md` | `**` | Secrets handling |
| `.github/instructions/markdown.instructions.md` | `**/*.md` | Documentation style |
| `.github/instructions/docs.instructions.md` | `docs/**/*.md` | Audience and tone |
| `.github/instructions/transcript-extraction.instructions.md` | Transcripts | Parsing rules |

### 2.3 Prompt Files and Chat Modes

| File | Purpose |
| --- | --- |
| `.github/prompts/add-tests.prompt.md` | Generate tests for a script |
| `.github/prompts/new-script.prompt.md` | Scaffold a new admin script |
| `.github/prompts/website-review.prompt.md` | Code review against standards |
| `.github/chatmodes/sf-safe-ops.chatmode.md` | Salesforce-aware chat mode |

---

## Part 3 - Project Architecture

### 3.1 Directory Structure

```text
c:\Users\dwishar1\Downloads\Python\
+-- .github/
|   +-- copilot-instructions.md
|   +-- instructions/          (scoped instruction files)
|   +-- prompts/               (reusable prompt templates)
|   +-- chatmodes/             (custom chat modes)
+-- src/
|   +-- sf_admin_utils/        (shared library)
|       +-- __init__.py
|       +-- config.py          (org alias resolution from .env)
|       +-- logging_setup.py   (standardized logging)
|       +-- query_helpers.py   (SOQL queries via raw requests + CLI auth)
+-- scripts/
|   +-- export_contract_pdfs.py
|   +-- export_quote_pdfs.py
|   +-- create_agency_zips_contract.py
|   +-- create_agency_zips_quote.py
|   +-- list_inactive_users.py
|   +-- merge_bookmarks_structured.py
|   +-- archive/               (old versioned scripts)
+-- tests/                     (pytest test files)
+-- docs/                      (beginner-friendly guides per script)
+-- transcripts/               (development history)
+-- pyproject.toml             (all tool configuration)
+-- requirements.in            (loose runtime deps)
+-- requirements.txt           (pinned runtime deps)
+-- requirements-dev.in        (loose dev deps)
+-- requirements-dev.txt       (pinned dev deps)
+-- requirements-lock.txt      (full environment snapshot)
+-- sanity.bat                 (6-step quality gate)
+-- setup.bat                  (first-time environment setup)
+-- README.md
```

### 3.2 Shared Library (`src/sf_admin_utils/`)

| Module | Responsibility |
| --- | --- |
| `config.py` | Reads `SF_PROD_ALIAS`, `SF_UAT_ALIAS`, and `SF_SIT_ALIAS` from `.env`, returns `OrgConfig` dataclass |
| `query_helpers.py` | Calls `sf org display --json` via subprocess, makes authenticated SOQL queries via raw `requests`, includes transient retry (429/503) with exponential backoff |
| `logging_setup.py` | Provides standardized stderr logging format |

### 3.3 How the Scripts Fit Together

```text
+---------------------+    +--------------------------+
| Salesforce CLI Auth  |--->|  export_contract_pdfs    |--> PDF folders + manifest
|  (sf org display)    |    |  export_quote_pdf        |--> PDF folders + manifest
+---------------------+    +--------------------------+
                                       |
                                       v
                           +--------------------------+
                           |  create_agency_zips_*     |--> ZIP per agency + manifest
                           +--------------------------+
                                       |
                                       v
                           +--------------------------+
                           |  Upload ZIPs to EDMS      |   (manual step)
                           +--------------------------+
```

### 3.4 Key Design Patterns

| Pattern | Where used | Why |
| --- | --- | --- |
| `@timed` decorator | All major functions | Logs elapsed time for performance monitoring |
| `timer()` context manager | Download loops | Times blocks of code without decorating a function |
| `SalesforceSession` class | Quote PDF script | Manages token refresh for long-running Visualforce downloads |
| `ThreadPoolExecutor` | Contract + Quote scripts | Concurrent downloads (3-5 workers) |
| `FORCE_REDOWNLOAD` flag | Both export scripts | Enables safe resume after interruption |
| `_short_path_fallback` | Both export scripts | Handles Windows 260-char path limit |
| `redact_sensitive_text()` | Both export scripts | Strips `sid=` tokens from logs |
| Manifest CSV with `finally:` | Both export scripts | Guarantees every record is logged regardless of success/failure |

---

## Part 4 - Salesforce Scripts: Development Journey

### 4.1 Chronological Development

| Date | Script | Milestone |
| --- | --- | --- |
| 2026-05-11 | Contract PDF export | First working version - discovered PDFs are on `AgencyPrivacyData__c`, not Orders |
| 2026-05-12 | Bookmark merge | Side project: merged 6,408 bookmarks from 6 browser exports |
| 2026-05-13 | (Standards) | Established 22 Python coding standards for the project |
| 2026-05-15 | Quote PDF export (v10) | Discovered Visualforce iframe approach for Quote PDFs |
| 2026-05-15-18 | Both scripts aligned | Consistent folder naming, manifests, retry logic, fallback paths |
| 2026-05-18 | Contract performance | Identified sequential download bottleneck; added `ThreadPoolExecutor` |
| 2026-05-18 | Agency ZIP scripts | Created ZIP-per-agency for EDMS upload (16 agencies, 6,725 folders) |
| 2026-05-19 | DNS failure diagnosed | Corporate DNS broke CLI auth; fixed by switching networks |
| 2026-05-19 | Quote v11 validated | 250 records, 0 errors, 3 workers, 120s timeout |
| 2026-05-19-20 | Full refactoring | Copilot-driven: PEP 8, docstrings, type hints, consistent structure |
| 2026-05-20 | Quality pipeline | `sanity.bat` with ruff, mypy, bandit, detect-secrets, pytest |
| 2026-05-20-21 | Package updater | `update_packages.py` + batch wrapper |
| 2026-05-21 | All green | 316 tests, 85% coverage, all 6 quality gates passing |
| 2026-05-27 | Cross-script consistency audit | CLI aligned; samples rewritten; 431 tests, 95%+ coverage |

### 4.2 Contract PDF Export (`export_contract_pdfs.py`)

**What it does:** Downloads PDFs stored as Salesforce Files (ContentDocumentLink)
attached to `AgencyPrivacyData__c` records that have an associated Order.

**Tip:** To see all command-line arguments (including `--output-dir`, `--sf-alias`, `--workers`, and `--yes`), run:
`python scripts/export_contract_pdfs.py --help`

> **Production guardrail:** When the org alias contains "PROD" and `--dry-run`
> is not active, the script prints a warning banner and requires the operator
> to type the alias to confirm before any files are downloaded. Pass `--yes` to
> bypass this in CI or automation pipelines.

For a full walkthrough including common commands, pipeline order, and troubleshooting,
see [`docs/running-the-scripts-guide.md`](running-the-scripts-guide.md).

**Download flow:**

```text
sf org display -> access_token + instance_url
  -> SOQL: AgencyPrivacyData__c WHERE Order__c != null
  -> SOQL: Orders by batch
  -> SOQL: ContentDocumentLink WHERE LinkedEntityId IN (agency IDs)
  -> GET /services/data/v66.0/sobjects/ContentVersion/<id>/VersionData
  -> Save PDF to disk
```

**Key configuration:**

```python
AGENCY_LIMIT = None          # No limit by default; use --limit 5/10/etc. for testing
MAX_WORKERS = 3              # Concurrent download threads
DOWNLOAD_TIMEOUT = 60        # Seconds per request
FORCE_REDOWNLOAD = False     # Skip existing files
YES_FLAG = False             # Set True via --yes to skip Production confirmation prompt
```

### 4.3 Quote PDF Export (`export_quote_pdfs.py`)

**What it does:** Downloads Visualforce-rendered Quote PDFs. These are NOT stored
as Salesforce Files - they are generated dynamically by a custom Visualforce
page.

**Tip:** To see all command-line arguments (including `--output-dir`, `--sf-alias`, `--workers`, and `--yes`), run:
`python scripts/export_quote_pdfs.py --help`

> **Production guardrail:** Same safeguard as the contract export - the script
> prompts for the org alias before a live Production run. Pass `--yes` to bypass
> in CI or automation. Quote downloads are heavier (Visualforce-rendered on
> demand), so using `--dry-run --limit 5` first is especially recommended.

For a full walkthrough including common commands, pipeline order, and troubleshooting,
see [`docs/running-the-scripts-guide.md`](running-the-scripts-guide.md).

**Download flow (more complex - requires browser-style session):**

```text
sf org display -> access_token + instance_url
  -> SOQL: AgencyPrivacyData__c WHERE Quote__c != null
  -> SOQL: Quotes by batch (get QuoteNumber/Name for filenames)
  -> frontdoor.jsp (establish browser session with cookies)
  -> Follow JavaScript redirect: window.location.replace(...)
  -> /apex/quotecustompdf?Id=<QuoteId>  (HTML wrapper page)
  -> Extract iframe src="/apex/QuoteCustomPDFPrivateFile?id=<QuoteId>"
  -> Download PDF bytes from iframe URL
  -> Validate %PDF magic bytes
  -> Save to disk
```

**Why this is complex:** Visualforce pages require cookies (not just bearer
tokens), execute JavaScript redirects that Python `requests` cannot follow
automatically, and wrap the real PDF inside an iframe.

### 4.4 Agency ZIP Scripts (`create_agency_zips_*.py`)

**What they do:** Group exported PDF folders by agency name and create one ZIP
per agency for bulk upload to EDMS (Electronic Document Management System).

**How they parse folder names:**

```text
Folder: 00038935_Dekkerautogr. Alkmaar_a0AJw00000CBLtRMAX
Regex:  ^(\d+)_(.+)_(a0[A-Za-z0-9]{16})$
Result: OrderNumber=00038935, Agency="Dekkerautogr. Alkmaar", ID=a0AJw00000CBLtRMAX
```

### 4.5 List Inactive Users (`list_inactive_users.py`)

Queries Salesforce for users who are inactive and exports them to CSV. Uses the
shared `sf_admin_utils` library for authentication.

---

## Part 5 - Testing and Coverage

### 5.1 Test Architecture

- **Framework:** pytest with `pytest-cov` and `pytest-xdist`
- **Strategy:** Mock all Salesforce calls; test logic in isolation
- **Module loading:** Scripts with spaces in filenames use `importlib.util` to
  load as modules (handled in `conftest.py`)

### 5.2 Running Tests

```batch
:: Run all tests with coverage
pytest

:: Run specific test file
pytest tests/test_export_contract_pdfs.py -v

:: Run in parallel (uses all cores)
pytest -n auto

:: Run with coverage report
pytest --cov=src --cov=scripts --cov-report=term-missing
```

### 5.3 Test Files

| Test File | Tests For |
| --- | --- |
| `test_export_contract_pdfs.py` | Contract PDF export logic |
| `test_export_quote_pdfs.py` | Quote PDF export + VF redirect handling |
| `test_create_agency_zips_contract.py` | Contract ZIP creation |
| `test_create_agency_zips_quote.py` | Quote ZIP creation |
| `test_list_inactive_users.py` | User query and CSV output |
| `test_salesforce_client.py` | Shared library auth functions |
| `test_config.py` | Environment config loading |
| `test_update_packages.py` | Package updater script |
| `test_merge_bookmarks_structured.py` | Bookmark merge logic |

### 5.4 Coverage Results (2026-05-27)

| Scope | Coverage |
| --- | --- |
| `src/sf_admin_utils/` | 100% (all modules) |
| `scripts/` | 93-100% per script |
| Total tests | 431 passing |
| Execution time | ~4s (14 parallel workers) |

### 5.5 Key Testing Patterns

```python
# Loading a script with spaces in the filename
import importlib.util
spec = importlib.util.spec_from_file_location("module_name", SCRIPT_PATH)
assert spec is not None
module = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(module)

# Mocking Salesforce CLI output
@pytest.fixture
def mock_sf_cli(monkeypatch):
    def fake_run(*args, **kwargs):
        return subprocess.CompletedProcess(
            args=args,
            returncode=0,
            stdout='{"result": {"accessToken": "fake", "instanceUrl": "https://test.sf.com"}}',
        )
    monkeypatch.setattr(subprocess, "run", fake_run)
```

---

## Part 6 - Code Quality Pipeline

### 6.1 The `sanity.bat` Pipeline

```batch
@echo off
echo === Step 1/6: Ruff format check ===
ruff format --check src tests scripts

echo === Step 2/6: Ruff lint ===
ruff check src tests scripts

echo === Step 3/6: Mypy type check ===
mypy src

echo === Step 4/6: Bandit security scan ===
bandit -c pyproject.toml -r src scripts --exclude scripts/archive,tests --quiet

echo === Step 5/6: detect-secrets baseline ===
detect-secrets scan --baseline .secrets.baseline

echo === Step 6/6: Pytest ===
pytest -n auto --cov=src --cov=scripts --cov-report=term-missing
```

### 6.2 Cycode Scans (GitHub - required on every PR)

Two Cycode scans run automatically when a PR is opened on GitHub and are
required before merge. They cannot be run locally.

| Scan | What it checks |
| --- | --- |
| **Cycode: SAST** | Static code analysis for security vulnerability patterns |
| **Cycode: Secrets** | Detects accidentally committed credentials, tokens, or keys |

If a scan fails, fix the flagged lines and push - the scans re-run
automatically on the updated commit.

### 6.3 Tool Configuration (all in `pyproject.toml`)

| Tool | Key Settings |
| --- | --- |
| **Ruff** | `target-version = "py313"`, `line-length = 100`, Google docstring convention, 20+ rule families enabled |
| **Mypy** | `strict = true` for `src/` only; relaxed for `tests/` and `scripts/` |
| **Bandit** | Skips B101/B105/B404/B603/B608 (test asserts, CLI subprocess, SOQL) |
| **detect-secrets** | Baseline file at `.secrets.baseline` |
| **pytest** | `testpaths = ["tests"]`, `pythonpath = ["src"]`, branch coverage, parallel |

### 6.3 Common Lint/Type Errors Encountered and Fixed

| Category | Count | Examples |
| --- | --- | --- |
| Unreachable statements | 5 | Code after `raise`/`return` |
| Missing generic type params | 4 | `dict` -> `dict[str, Any]` |
| `Optional[X]` -> `X \| None` | 3 | Modern Python 3.10+ syntax |
| Unused `type: ignore` | 4 | Comments left after code was fixed |
| Mutable class defaults | 1 | `[]` -> `field(default_factory=list)` |
| `logging.error` -> `.exception` | 3 | Preserves stack trace in except blocks |
| `open()` -> `Path.open()` | 2 | Pathlib preferred |
| Markdown formatting | 3 | Multiple blank lines, table alignment |

---

## Part 7 - Troubleshooting and Operations

### 7.1 DNS / Network Failures

**Symptom:** `getaddrinfo ENOTFOUND login.salesforce.com` during `sf org login web`

**Root cause:** Ford DNS server (`ldndns102c.ldn1.ford.com`) not resolving
Salesforce domains from command-line tools. Browser works via proxy/PAC file.

**Diagnosis:**

```batch
nslookup login.salesforce.com
:: Bad: shows Name but no Addresses
:: Good: shows Addresses: 160.8.232.2, 160.8.233.2, etc.
```

**Fix:** Switch to a different network (or VPN reconnect), then:

```batch
ipconfig /flushdns
sf org login web --alias AXP_PROD
```

### 7.2 Salesforce Session Failures

| Symptom | Cause | Fix |
| --- | --- | --- |
| PDF response is HTML "Reset Your Password" page | Session handoff failed | Re-authenticate CLI; reduce `MAX_WORKERS` |
| `IncompleteRead(1938 bytes read, 8302 more expected)` | Connection dropped | Transient; script auto-retries |
| `ConnectTimeoutError` after 60s | Network instability or high concurrency | Increase `DOWNLOAD_TIMEOUT` to 120; reduce workers to 3 |
| Bearer method returns login page | Visualforce requires cookies, not bearer | Script uses frontdoor.jsp as primary method |

### 7.3 Resuming Interrupted Runs

The scripts are **safely resumable** thanks to:

- `FORCE_REDOWNLOAD = False` - skips files that already exist and are > 0 bytes
- `RUN_DATE_TEXT` - freeze to a prior date to resume into an existing folder
- Manifest is written incrementally in `finally:` block - never lost

To resume into an existing folder, set the date constant to the original run date:

```python
RUN_DATE_TEXT = "2026.05.18"  # Instead of date.today()
```

### 7.4 Performance Tuning

| Setting | Conservative | Aggressive | Notes |
| --- | --- | --- | --- |
| `MAX_WORKERS` | 3 | 8 | Reduce if HTTP 429 or timeouts appear |
| `DOWNLOAD_TIMEOUT` | 120 | 60 | VF pages can be slow under load |
| `DOWNLOAD_PAUSE_SECONDS` | 0.05 | 0 | Remove if no rate limiting observed |
| `--limit` | 10 | 0 (no limit) | Always test small first (e.g. `--limit 5`) |

### 7.5 Windows Path Length Issues

Windows has a 260-character path limit. When folder + filename exceeds this:

- The script catches `errno 2` / "No such file or directory"
- Falls back to `_short_path_fallback/` with a shorter filename
- Manifest records which files used the fallback path

---

## Part 8 - GitHub Integration and Next Steps

### 8.1 Current Git State

- **Branch:** `main`
- **Commits:** Multiple clean commits (initial scaffold, formatting, tests, docs)
- **`.gitignore`:** Covers `.venv/`, `__pycache__/`, `.coverage`, generated
  CSVs/PDFs/ZIPs/logs, `.env`, `.secrets.baseline`

### 8.2 Push to Ford InnerSource (GitHub.com)

1. Create repository on Ford's InnerSource GitHub organization
2. Add remote: `git remote add origin https://github.ford.com/<org>/sf-admin-utils.git`
3. Push: `git push -u origin main`
4. Add `CODEOWNERS` file for review requirements
5. Enable branch protection on `main`

### 8.3 Pending Enhancement: Manifest CSV Changes

The following scripts need manifest CSV updates to **add customer name** and
**remove unnecessary fields**:

- `export_contract_pdfs.py`
- `export_quote_pdfs.py`
- `create_agency_zips_contract.py`
- `create_agency_zips_quote.py`

This requires:

1. Identifying the Salesforce field that holds the customer name (likely
   `Account.Name` via the Order or Opportunity relationship)
2. Adding a SOQL query for Account records or including it in existing queries
3. Adding `CustomerName` column to manifest
4. Removing columns the team no longer needs (to be specified)
5. Updating associated test files to match new column structure

### 8.4 Recommended Improvements (with Rationale)

> The suggested pull-request grouping for this work is in
> [`docs/pr-roadmap-section-8-4.md`](pr-roadmap-section-8-4.md).

| # | Improvement | Rationale | Effort |
| --- | --- | --- | --- |
| 1 | **Refactor scripts to use `src/sf_admin_utils/`** | Both export scripts duplicate auth, SOQL, timing, and download logic. Extract into shared modules: `sf_admin_utils.auth` (replaces inline `get_cli_org_auth`), `sf_admin_utils.query` (replaces inline `query_all`/`chunked`/`soql_id_list`), `sf_admin_utils.download` (shared retry/fallback/redaction). Eliminates ~500 lines of duplication. | High |
| 2 | **Remove hardcoded `SF_CLI_PATH`** | Both `export_contract_pdfs.py` (line 82) and `export_quote_pdfs.py` (line 92) had `SF_CLI_PATH = r"C:\Program Files\sf\bin\sf.cmd"` hardcoded. Both scripts now resolve the CLI via `shutil.which("sf")` inside `get_cli_org_auth()`, raising a `RuntimeError` with an install hint when `sf` is not on PATH. Mirrors the pattern in `salesforce_client.py`. | ✅ Done |
| 3 | **Remove hardcoded `OUTPUT_BASE_DIR`** | The user-specific path `C:\Users\dwishar1\Downloads\AXP Decom 2026` is baked into scripts. Move to `.env` or accept as a CLI argument so other team members can use the scripts without editing source. `--output-dir` CLI arg added to all four scripts. `SF_CLI_PATH` is now also resolved dynamically - see improvement #2. | ✅ Done |
| 4 | **Expand the CLI interface** | All four scripts now have a full argparse CLI. Export scripts support `--output-dir`, `--sf-alias`, `--workers`, `--limit`, and `--force-redownload`. ZIP scripts support `--source-dir` (required), `--source-manifest`, `--output-dir`, and `--compression`. `--limit` defaults to **no limit** on both export scripts so a plain run exports all records; pass `--limit 250` (or any positive integer) for a capped test run. No script constants need editing for normal runs. | ✅ Done |
| 5 | **Consolidate the two export scripts** | The Contract and Quote scripts share ~70% of their code (auth, session, timing, manifest writing, fallback logic). Extract shared logic into a base class or shared module, leaving only the download-method-specific code in each script. | High |
| 6 | **Add `--dry-run` mode** | Allow users to see what would be downloaded without actually downloading. Reduces risk for new users running against Production. `DRY_RUN = False` constant, `--dry-run` CLI arg, and `_log_dry_run_*_plan()` helper functions added to both export scripts. ZIP steps skipped automatically in `run_full_pipeline.ps1`. 6 new tests. | ✅ Done |
| 7 | **Replace `scripts/archive/` with Git history** | The archive folder contains 20+ old versioned files (~25 files). Git already preserves this history. Remove the folder and rely on `git log`/`git diff` for history. Reduces clutter and lint noise. | ✅ Done - folder did not exist; no action needed (2026-05-28) |
| 8 | **Add GitHub Actions CI** | `.github/workflows/ci.yml` created; commands aligned with `sanity.bat`; CONTRIBUTING.md updated with "Automated CI Checks" section. Ford JFrog Artifactory DNS issue resolved with `grep -v "index-url"` pipe. 20 cross-platform test failures fixed across 5 test files. | ✅ Done (2026-05-29) |
| 9 | **Type-check scripts too** | `scripts/` added to mypy `files` list in `pyproject.toml`; 12 files checked, no errors. | ✅ Done (2026-05-28) |
| 10 | **Add integration test with sandbox** | One optional test that actually calls the UAT sandbox (behind a `@pytest.mark.integration` marker) would validate the full auth -> query -> download flow end-to-end. | Medium |
| 11 | **Add `tests/test_security.py`** ✅ Done (2026-05-27) | `src/sf_admin_utils/security.py` had 65% line coverage - the only `src/` module below 100%. The `TypeError` branch of `validate_salesforce_alias`, the explicit-`base_dir` path of `resolve_safe_path`, and the path-traversal / cross-drive raises were completely untested. A dedicated test file (31 tests) brings `security.py` to 100% coverage. | ✅ Done |
| 12 | **Move `validate_subprocess_command` from `update_packages.py` to `src/sf_admin_utils/security.py`** | `update_packages.py` contained its own inline allow-list-based command validator. This security-sensitive code now lives in `security.py` alongside `validate_salesforce_alias` and `resolve_safe_path`, where it is properly tested and reusable by any future script that builds subprocess commands. `update_packages.py` now imports `validate_subprocess_command` from `security.py`. 9 new tests added to `test_security.py`. | ✅ Done |
| 13 | **Rename `list_inactive_users._parse_args` to `parse_args`** | Renamed to `parse_args` for consistency with all other scripts. 4 files, 11 lines changed, zero logic change. | ✅ Done (2026-05-28) |
| 14 | **Extend mypy `files` to include `scripts/`** | `"scripts"` added to `files` list in `pyproject.toml`. 12 files checked, no errors. | ✅ Done (2026-05-28) |
| 15 | **Replace `print()` with `logging` in `update_packages.py`** | All `print()` calls replaced with `logging`; `TestPrintHelpers` rewritten with `caplog`; `test_main_calls_configure_logging` added; guide updated. | ✅ Done (2026-05-28) |
| 16 | ~~**Add argparse CLI to `merge_bookmarks_structured.py`**~~ | ~~Archived 2026-06-01. Script moved to `archive/bookmarks/`. Not part of Salesforce admin utilities scope.~~ | ~~Archived~~ |
| 17 | **Add SIT (System Integration Testing) org support** | `SF_SIT_ALIAS` added to `.env.example`; `OrgName` Literal extended to `"uat" \| "prod" \| "sit"` in `config.py`; `load_org_config("sit")` validated; `sf_env` fixture updated; 1 new test added to `test_config.py` | ✅ Done |
| 18 | **REQ-E: Weekly Order Status Report** | New script `scripts/order_status_report.py` queries Salesforce Order records weekly, calculates status deltas (changed and new orders), groups open orders by Status × Agency, generates an Excel workbook (Summary pivot table, stacked bar Chart, Detail sheet) via `pandas` + `openpyxl`, and emails a formatted summary to a configurable distribution list via Ford SMTP relay. Four new shared library modules added: `email_sender.py`, `excel_report.py`, `order_report.py`, `order_snapshot.py`. 71 new tests across 4 test files. Total: 576 tests. | ✅ Done (2026-06-02) |
| 19 | **REQ-F: Generalise `excel_report.py` for reuse across report types** | Add `sf_object`, `detail_columns`, and `detail_col_widths` keyword parameters to `build_order_report_workbook`. Chart titles become `f"AXP Netherlands {sf_object} Status Trend - ..."`, default Notes heading becomes `f"AXP {sf_object} Status Report - Workbook Notes"`. All new params have defaults that reproduce current Order Report behaviour exactly - zero changes to existing callers. Unblocks REQ-G. See `requirements/REQ-F-excel-report-generalisation/`. | ✅ Done (2026-06-04) |
| 20 | **REQ-G: Weekly User Status Report** | New script `scripts/user_status_report.py` mirroring REQ-E but querying Salesforce User records. Reuses `email_sender.py`, `excel_report.py` (via REQ-F `sf_object="User"`), SMTP delivery, and snapshot pattern. Requires new `user_snapshot.py`, `user_report.py` modules. SOQL fields, status grouping, and SOQL filter TBD with business owner. See `requirements/REQ-G-user-status-report/`. | ✅ Done (2026-06-04) |
| 21 | **REQ-H: Object Data Extract** | New script `scripts/extract_object_data.py` downloads all records from any queryable Salesforce object into CSV (with optional Excel). Interactive object picker, field auto-discovery, row-count warning, `--where`/`--limit`/`--output` CLI args. New library module `src/sf_admin_utils/data_export.py`. 42 tests (25 library + 17 CLI). See `requirements/REQ-H-object-data-extract/`. | ✅ Done (2026-06-09) |

### 8.5 Completed Follow-Up Tasks (from earlier sessions)

| Task | Status | When |
| --- | --- | --- |
| Run `py_compile` on both scripts | ✅ Done | 2026-05-18 |
| Controlled test run (25-250 records) | ✅ Done | 2026-05-19 |
| Add unit tests (90% coverage target) | ✅ Done (400 tests, 95% overall) | 2026-05-19-20 / 2026-05-27 |
| PEP 8 formatting via ruff | ✅ Done | 2026-05-19 |
| Remove commented code | ✅ Done | 2026-05-19 |
| Add type hints to Contract script | ✅ Done | 2026-05-19 |
| Move scripts to `scripts/` folder | ✅ Done | 2026-05-19 |
| Rename scripts (remove version suffixes) | ✅ Done | 2026-05-19 |
| Set up ruff, mypy, bandit, detect-secrets | ✅ Done | 2026-05-20 |
| Create `sanity.bat` pipeline | ✅ Done | 2026-05-20 |
| Create `update_packages.py` | ✅ Done | 2026-05-20 |
| Upgrade outdated packages | ✅ Done | 2026-05-21 |
| Create beginner guide Markdown files | ✅ Done | 2026-05-19-20 |
| Refactor README.md | ✅ Done | 2026-05-19-20 |
| Incorporate standards into copilot-instructions.md | ✅ Done | 2026-05-19 |
| Replace `black` with `ruff format` | ✅ Done | 2026-05-19 |
| Add mypy to quality checks | ✅ Done | 2026-05-20 |
| Create per-topic instruction files | ✅ Done | 2026-05-19 |
| Delete debug HTML files with session tokens | ✅ Done | 2026-05-19 |
| Update script docstrings from "3.8+" to "3.12+" | ✅ Done | 2026-05-20 |
| Cross-script consistency audit: naming aligned (`parse_args`, `_configure_logging`, `chunk_list`) | ✅ Done | 2026-05-27 |
| Unified `format_elapsed` precision to `.2f` across all four scripts | ✅ Done | 2026-05-27 |
| Removed stale dead-code constants from `create_agency_zips_quote.py` | ✅ Done | 2026-05-27 |
| Updated all four test files to match renamed functions and new precision | ✅ Done | 2026-05-27 |
| Expanded CLI across all four scripts (`--output-dir`, `--limit`, `--force-redownload`, etc.) | ✅ Done | 2026-05-27 |
| Rewrote all five sample scripts with headers, error-level checks, and `--limit 0` | ✅ Done | 2026-05-27 |
| Created `docs/samples_guide.md` overview guide for sample scripts | ✅ Done | 2026-05-27 |
| Updated all ZIP and export guides with full CLI tables and `--help` tips | ✅ Done | 2026-05-27 |
| Created `tests/test_security.py` (31 tests); `security.py` coverage 65% -> 100% | ✅ Done | 2026-05-27 |
| Removed hardcoded `SF_CLI_PATH` from both export scripts; resolved via `shutil.which("sf")` | ✅ Done | 2026-05-28 |
| Changed `AGENCY_LIMIT` default from `250` to `None` on both export scripts; `--limit` now defaults to no limit so a plain run exports all records; `test_parse_args_default_limit_is_none` added to both test suites | ✅ Done | 2026-05-28 |
| Created `docs/running-the-scripts-guide.md` - beginner-friendly usage guide covering all four scripts, the `.env` file, full pipeline walkthrough, and troubleshooting | ✅ Done | 2026-05-28 |
| Updated `.env.example` with expanded plain-English comments covering every variable | ✅ Done | 2026-05-28 |
| Added `--dry-run` mode to both export scripts; `_log_dry_run_contract_plan()` and `_log_dry_run_quote_plan()` helpers extracted; 6 new tests; `run_export_contracts.bat`, `run_export_quotes.bat`, and `run_full_pipeline.ps1` updated with dry-run support; 441 tests passing | ✅ Done | 2026-05-28 |
| Added SIT (System Integration Testing) org support: `SF_SIT_ALIAS` added to `.env.example`; `OrgName` Literal extended to `"uat" \| "prod" \| "sit"` in `config.py`; `load_org_config("sit")` validated; `sf_env` fixture updated; 1 new test added to `test_config.py` | ✅ Done | 2026-05-28 |
| Added production confirmation guardrail (`_confirm_production_run`, `--yes` flag) to both export scripts; 16 new tests; all guides and README updated | ✅ Done | 2026-05-28 |
| Pushed to Ford InnerSource GitHub repo (`ford-innersource/eu-crm-sf-admin-utils`) | ✅ Done | 2026-05-28 |
| Renamed `list_inactive_users._parse_args` -> `parse_args` (4 files, 11 lines, zero logic change) | ✅ Done | 2026-05-28 |
| Extended mypy `files` to include `scripts/` (12 files checked, no errors) | ✅ Done | 2026-05-28 |
| Replaced `print()` with `logging` in `update_packages.py`; `TestPrintHelpers` rewritten with `caplog` | ✅ Done | 2026-05-28 |
| Added GitHub Actions CI workflow (`.github/workflows/ci.yml`); aligned with `sanity.bat`; CONTRIBUTING.md updated | ✅ Done | 2026-05-29 |
| Fixed 20 cross-platform test failures (Linux CI vs Windows dev) across 5 test files | ✅ Done | 2026-05-29 |
| REQ-E E1: Added `src/sf_admin_utils/order_snapshot.py` - SOQL query + JSON snapshot I/O; `tests/test_order_snapshot.py` (16 tests) | ✅ Done | 2026-06-02 |
| REQ-E E2: Added `src/sf_admin_utils/order_report.py` - delta calculation (`calculate_status_changes`, `find_new_orders`, `group_open_orders`), report formatting (`format_report`, `ReportMetadata`); `tests/test_order_report.py` (28 tests) | ✅ Done | 2026-06-02 |
| REQ-E E3: Added `src/sf_admin_utils/email_sender.py` - recipient file loading, email composition, SMTP delivery, Production confirmation prompt; `tests/test_email_sender.py` (16 tests) | ✅ Done | 2026-06-02 |
| REQ-E E4: Added `scripts/order_status_report.py` - full CLI with `--sf-alias`, `--since`, `--dry-run`, `--yes`, `--quiet`, `--export-detail`, `--threshold`, `--retain-weeks`, `--format`, `--recipients`, `--no-excel`, `--attach-excel`; exit codes 0/1/2; frequency check; Production confirmation guard; run summary log line | ✅ Done | 2026-06-02 |
| REQ-E E7/E8: Added `src/sf_admin_utils/excel_report.py` - `build_order_report_workbook()` produces three-sheet `.xlsx` (Summary pivot, stacked bar Chart, Detail); `--no-excel` / `--attach-excel` wired into CLI; `tests/test_excel_report.py` (11 tests using real in-memory workbook) | ✅ Done | 2026-06-02 |
| REQ-E E6: Added `docs/order_status_report_guide.md` - beginner-friendly usage guide; updated `README.md`, `architecture.md`, `docs/salesforce-admin-utilities-guide.md`, and `Changelog.md` | ✅ Done | 2026-06-02 |
| Added `src/sf_admin_utils/py.typed` marker (PEP 561 - enables mypy strict checking for library consumers) | ✅ Done | 2026-06-02 |
| Updated `.env.example` with `SMTP_HOST`, `SMTP_PORT`, `REPORT_FROM_ADDRESS` for REQ-E | ✅ Done | 2026-06-02 |

### 8.6 Open Follow-Up Tasks

| # | Task | Priority | Notes |
| --- | --- | --- | --- |
| 1 | ~~Push to Ford InnerSource GitHub repo~~ | ~~High~~ | ✅ Done - 2026-05-28 |
| 2 | ~~Manifest CSV enhancement (add customer name, remove fields)~~ | ~~High~~ | ✅ Done - `AccountName` and `AccountSCAID` added (2026-05-28, commit 505a701) |
| 3 | Refactor scripts to use `src/sf_admin_utils/` | High | See improvement #1 above |
| 4 | ~~Remove hardcoded paths (CLI path + output dir)~~ | ~~Medium~~ | ✅ Done - `--output-dir` added to all four scripts (improvement #3); `SF_CLI_PATH` removed from both export scripts and resolved via `shutil.which("sf")` (improvement #2, 2026-05-28) |
| 5 | ~~Add argparse CLI interface~~ | ~~Medium~~ | ✅ Done - see improvement #4 above |
| 6 | ~~Add GitHub Actions CI workflow~~ | ~~Medium~~ | ✅ Done - `.github/workflows/ci.yml` created (2026-05-29); see improvement #8 |
| 7 | ~~Delete `scripts/archive/` folder~~ | ~~Low~~ | ✅ Done - folder did not exist (2026-05-28); see improvement #7 |
| 8 | Report Ford DNS issue to IT | Low | `ldndns102c` doesn't resolve Salesforce |
| 16 | **REQ-F: Generalise `excel_report.py`** | High | Add `sf_object`, `detail_columns`, `detail_col_widths` params. ~2 h. Unblocks REQ-G. See `requirements/REQ-F-excel-report-generalisation/`. |
| 17 | **REQ-G: Weekly User Status Report** | Medium | New script mirroring REQ-E for Salesforce User object. Blocked on REQ-F + business confirmation of User fields/filters. See `requirements/REQ-G-user-status-report/`. |
| 9 | ~~Add `--dry-run` mode~~ | ~~Low~~ | ✅ Done - see improvement #6 (2026-05-28) |
| 10 | ~~Increase test coverage from 85% to 90%+~~ | ~~Medium~~ | ✅ Done - 95% coverage, 400 tests (2026-05-27) |
| 11 | ~~Move `validate_subprocess_command` to `security.py`~~ | ~~Low~~ | ✅ Done - see improvement #12 (2026-05-28) |
| 12 | ~~Rename `list_inactive_users._parse_args` -> `parse_args`~~ | ~~Low~~ | ✅ Done - see improvement #13 (2026-05-28) |
| 13 | ~~Extend mypy `files` to include `scripts/`~~ | ~~Low~~ | ✅ Done - see improvement #14 (2026-05-28) |
| 14 | ~~Replace `print()` with `logging` in `update_packages.py`~~ | ~~Low~~ | ✅ Done - see improvement #15 (2026-05-28) |
| 15 | ~~Add argparse CLI to `merge_bookmarks_structured.py`~~ | ~~Medium~~ | Archived 2026-06-01 - script moved to `archive/bookmarks/`; out of scope |

---

## Consolidated Timeline

| Date | Key Event |
| --- | --- |
| 2026-05-09 | First Copilot session: analysed `export_agency_privacy_pdfs_prod v7.py` |
| 2026-05-11 | Built first Contract PDF export script; discovered PDFs are on `AgencyPrivacyData__c` |
| 2026-05-12 | Merged 6,408 bookmarks from 6 browser exports (side project) |
| 2026-05-13 | Established 22 Python development standards; SOQL audit queries for API Enabled |
| 2026-05-15 | Discovered Visualforce iframe approach for Quote PDFs; first successful download |
| 2026-05-15-18 | Converted debug scripts to production; aligned Contract + Quote scripts |
| 2026-05-18 | Created agency ZIP scripts; identified performance improvements |
| 2026-05-19 | Diagnosed DNS failure; validated v11 scripts (250 records, 0 errors) |
| 2026-05-19 | Copilot-driven refactoring: consistent structure, docstrings, type hints |
| 2026-05-19 | Project scaffold: src layout, tests, pyproject.toml, instruction files |
| 2026-05-20 | Full quality pipeline: ruff + mypy + bandit + detect-secrets + pytest |
| 2026-05-20 | Created `update_packages.py`; README and CONTRIBUTING.md refactored |
| 2026-05-21 | Package upgrades; 316 tests passing; all quality gates green |
| 2026-05-22 | Guide consolidation and improvement planning |
| 2026-05-27 | Cross-script consistency audit: `parse_args`, `_configure_logging`, `chunk_list` naming aligned; `format_elapsed` precision unified to `.2f`; dead code removed from ZIP quote script; all five sample scripts rewritten with error handling and `--limit 0`; `docs/samples_guide.md` created; all guides updated with full CLI tables; 400 tests passing, 95% coverage |
| 2026-05-28 | Removed hardcoded `SF_CLI_PATH` from both export scripts; CLI now resolved via `shutil.which("sf")` with a clear `RuntimeError` if not installed; `test_raises_when_sf_not_on_path` added to both test suites; changed `AGENCY_LIMIT` default to `None` on both export scripts so plain runs export all records; `test_parse_args_default_limit_is_none` added to both test suites; created `docs/running-the-scripts-guide.md` and expanded `.env.example`; added `--dry-run` mode to both export scripts with helper functions `_log_dry_run_contract_plan()` and `_log_dry_run_quote_plan()`; updated `run_export_contracts.bat`, `run_export_quotes.bat`, and `run_full_pipeline.ps1` with dry-run support; added SIT org support (`SF_SIT_ALIAS`) to `config.py`, `conftest.py`, `test_config.py`, and `.env.example`; moved `validate_subprocess_command` to `security.py` with 9 new tests; 451 tests passing |
| 2026-05-29 | PR Group B complete: `.github/workflows/ci.yml` created; `sanity.bat` and CI commands aligned; CONTRIBUTING.md updated with "Automated CI Checks" section; Ford JFrog Artifactory DNS issue resolved with `grep -v "index-url"` pipe; 20 cross-platform test failures (Linux CI vs Windows dev) fixed across 5 test files |
| 2026-06-02 | REQ-E complete: `scripts/order_status_report.py` (weekly order status report, Excel workbook, SMTP email); 4 new `src/sf_admin_utils/` modules (`email_sender`, `excel_report`, `order_report`, `order_snapshot`); 71 new tests; total 576 tests; `docs/order_status_report_guide.md` created; `.env.example` updated with SMTP variables |

---

## Security and Privacy Notes

- **Never commit:** `.env`, access tokens, session IDs, PDFs, CSVs, ZIPs, logs
- **Redaction:** Scripts use `redact_sensitive_text()` to strip `sid=` from logs
- **Authentication:** Salesforce CLI OAuth only - no passwords in code
- **Output data:** Exported PDFs contain customer/dealer PII - treat as confidential
- **Debug files:** `_debug_responses/` may contain redacted session references -
  delete after troubleshooting
- **Internal references:** Salesforce org URL (`fordeurope.my.salesforce.com`),
  username (`dwishar1@retailcrm.com`), and Ford DNS servers are internal details
- **Dependency security:** Use `bandit` and `detect-secrets` in `sanity.bat`;
  run `pip-audit` when available on Ford mirror

---

## Glossary

| Term | Explanation |
| --- | --- |
| `AgencyPrivacyData__c` | Custom Salesforce object representing an agency/dealer privacy record. Links to Quotes and Orders. The `__c` suffix means it's custom. |
| ContentDocumentLink | Salesforce junction object linking a file to a record (like a join table between "files" and "records") |
| ContentVersion | Represents one version of an uploaded file in Salesforce. Has a `VersionData` endpoint for binary download. |
| Delta | The difference between two order snapshots - which orders changed status, and which are new in the reporting period. |
| EDMS | Electronic Document Management System - long-term archive for exported PDFs |
| `frontdoor.jsp` | Salesforce URL that establishes a browser session from an access token. Required for Visualforce pages. |
| iframe | HTML element embedding another page. Salesforce wraps Quote PDFs in iframes. |
| `openpyxl` | Python library for reading and writing Excel `.xlsx` files. Used by `excel_report.py` to build the order status workbook and insert the stacked bar chart. |
| Org | A single Salesforce environment (Production, UAT sandbox, SIT sandbox, etc.) |
| `pandas` | Python library for tabular data manipulation. Used by `excel_report.py` to build the pivot summary table (`pivot_table()`) for the Excel workbook. |
| pip-tools | A set of tools (`pip-compile`, `pip-sync`) for deterministic dependency management |
| Pivot table | A summary grid that reorganises data. In the order report: rows = agencies, columns = statuses, values = order counts. |
| `requests.Session` | Python HTTP client that persists cookies across requests. Essential for Salesforce session handling. |
| Snapshot | A dated JSON file capturing the complete list of all Salesforce Order records at the time the script ran. Used to calculate what changed between weekly runs. |
| SMTP | Simple Mail Transfer Protocol - the standard for sending email. Ford's internal SMTP relay accepts connections from inside Ford's network without a password. |
| SOQL | Salesforce Object Query Language - Salesforce's version of SQL |
| Visualforce | Salesforce page-rendering technology. Quote PDFs are dynamically generated by a VF page, not stored as files. |
| Virtual environment | Isolated Python installation for a project. Prevents dependency conflicts. Create with `py -m venv .venv`. |

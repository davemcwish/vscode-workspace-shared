# Beginner's Guide - Export Contract PDFs from Salesforce

This guide explains how the `export_contract_pdfs.py` script works, what you
need before running it, and how each piece fits together. It is written for people
who are new to Python scripting and Salesforce administration.

---

## Table of Contents

- [What This Script Does](#what-this-script-does)
- [Prerequisites](#prerequisites)
- [Salesforce CLI Setup](#salesforce-cli-setup)
- [Running the Script](#running-the-script)
- [Configuration Reference](#configuration-reference)
- [Code Walkthrough](#code-walkthrough)
- [Output Files](#output-files)
- [Troubleshooting](#troubleshooting)
- [Glossary](#glossary)

---

## What This Script Does

The script connects to a Salesforce Production org, finds all **AgencyPrivacyData__c**
records that have a related **Order**, locates the PDF files attached to those records
(via **ContentDocumentLink** - the Salesforce object that links an uploaded file to a
record, similar to a join table), and downloads every PDF to your local machine.

It also writes a **manifest CSV** listing every file it processed - including its
Salesforce IDs, download path, and status (downloaded, skipped, or errored).

---

## Prerequisites

Before running this script you need:

| Requirement | Why |
| --- | --- |
| Python 3.12+ | The script uses modern Python type hints and standard library features. |
| Salesforce CLI (`sf`) | Used to authenticate to the Salesforce org without storing passwords. |
| `requests` library | Handles HTTP calls to the Salesforce REST API. |
| Network access to Salesforce | Your machine must reach `*.salesforce.com` over HTTPS. |
| Sufficient disk space | Each PDF is typically 50-500 KB; thousands of records may need several GB. |

### Installing Python

1. Download Python 3.12+ from <https://www.python.org/downloads/>.
2. During installation tick **"Add Python to PATH"**.
3. Verify in a terminal:

```bash
python --version
```

### Installing the `requests` Library

From the project root (where `requirements.txt` lives):

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

---

## Salesforce CLI Setup

The script authenticates by calling the **Salesforce CLI** (`sf`). It never stores
passwords or tokens - it reads a temporary session from the CLI's credential store.

### Step 1 - Install the Salesforce CLI

Download from <https://developer.salesforce.com/tools/salesforcecli> and run the
installer. After installation, confirm it works:

```bash
sf --version
```

### Step 2 - Authenticate to the Production Org

Open a terminal and run:

```bash
sf org login web --alias AXP_PROD
```

This opens your browser. Log in with your **Production** credentials. After a
successful login the CLI stores a session token locally (encrypted by your OS
keychain). The alias `AXP_PROD` is what the script looks for by default.

### Step 3 - Verify Your Session

```bash
sf org display --target-org AXP_PROD --json
```

You should see JSON output containing `"accessToken"` and `"instanceUrl"`. If you
see an error, re-run `sf org login web`.

### How Re-Authentication Works

Sessions expire (typically after 2-12 hours). The script detects HTTP 401 errors and
automatically calls `sf org display` again up to 3 times. If that still fails, re-run
`sf org login web` manually and restart the script.

---

## Running the Script

> **Safety first (recommended for your first run):**
> Run a dry run with a small limit to confirm authentication and scope before
> downloading thousands of PDFs:
>
> ```bash
> python scripts/export_contract_pdfs.py --sf-alias AXP_PROD --dry-run --limit 5
> ```
>
> When you run against a Production org (any alias containing "PROD") without
> `--dry-run`, the script will print a **Production warning** and ask you to type
> the org alias to confirm. This prevents accidental full exports.
> Use `--yes` to skip the prompt in CI or automation pipelines.
>
> Then remove `--dry-run` (and set `--limit 0` or omit `--limit`) for a full export.

```bash
cd C:\Users\dwishar1\Downloads\Python
.venv\Scripts\activate
python scripts/export_contract_pdfs.py --sf-alias AXP_PROD --workers 3
```

### Command-line arguments

The script supports these optional CLI arguments:

**Tip:** Run `--help` to see all options at any time:

```bash
python scripts/export_contract_pdfs.py --help
```

| Argument | Required | Default | What it controls |
| --- | --- | --- | --- |
| `--output-dir` | No | Current working directory | Base output directory. The script creates a dated `AXP_Contract_PDFs_Prod_YYYY.MM.DD` subfolder here. |
| `--sf-alias` | No | `AXP_PROD` | Salesforce CLI org alias to authenticate with. |
| `--workers` | No | `3` | Number of concurrent PDF download threads. Increase for faster downloads; reduce if you see HTTP 429 errors. |
| `--limit` | No | *(no limit)* | Maximum number of AgencyPrivacyData__c records to query. Omit (or use `0`) for a full run. Useful for testing: `--limit 10`. |
| `--force-redownload` | No | `False` (flag) | Re-download PDFs that already exist locally. Omit this flag to skip already-downloaded files (safe resume). |
| `--dry-run` | No | `False` (flag) | Query Salesforce and log what would be downloaded, but do not write any files to disk. Safe to run against Production at any time. |
| `--yes` | No | `False` (flag) | Skip the interactive Production confirmation prompt. Use in CI or automation where interactive input is not available. Has no effect when `--dry-run` is active. |

Example - safety check (recommended first run):

```bash
python scripts/export_contract_pdfs.py --sf-alias AXP_PROD --dry-run --limit 5
```

Example - full production run:

```bash
python scripts/export_contract_pdfs.py --sf-alias AXP_PROD --workers 3
```

Example - test with 10 records into a custom folder:

```bash
python scripts/export_contract_pdfs.py --output-dir "C:\Users\<you>\Downloads" --limit 10
```

The script will:

1. Authenticate via the Salesforce CLI.
2. Query AgencyPrivacyData__c records.
3. Query related Order records.
4. Query ContentDocumentLink records (PDF attachments).
5. Download all PDFs concurrently (3 threads by default).
6. Write a manifest CSV and a log file.

Expect the full run to take **30-90 minutes** depending on how many records exist
and your network speed.

---

## Configuration Reference

Some configuration is set via command-line arguments (recommended). Other
behaviour is controlled by constants near the top of the script.

| Constant | Purpose | Default |
| --- | --- | --- |
| `SF_ALIAS` | Salesforce CLI org alias | `"AXP_PROD"` |
| `SF_CLI_PATH` | Full path to the `sf` CLI executable | `C:\Program Files\sf\bin\sf.cmd` |
| `OUTPUT_BASE_DIR` | Parent folder for output (overridden by `--output-dir`) | Current working directory |
| `TARGET_AGENCY_RECORD_ID` | Set to a single ID for testing; `None` for all records | `None` |
| `AGENCY_LIMIT` | Max records to query (overridden by `--limit`); `None` for all | `None` |
| `AGENCY_WHERE_CLAUSE` | Extra SOQL filter | `"Order__c != null"` |
| `MAX_WORKERS` | Number of concurrent download threads (overridden by `--workers`) | `3` |
| `DOWNLOAD_RETRIES` | How many times to retry a failed download | `3` |
| `FORCE_REDOWNLOAD` | Re-download files that already exist locally (overridden by `--force-redownload`) | `False` |

### Testing With a Single Record

Set `TARGET_AGENCY_RECORD_ID` to a valid 18-character Salesforce ID to download
only one record. This is useful to verify your setup before a full run:

```python
TARGET_AGENCY_RECORD_ID = "a0A8d00000DK2smEAD"
```

---

## Code Walkthrough

The script is organised into logical sections. Here is what each piece does.

### Timing Utilities

| Name | Type | Purpose |
| --- | --- | --- |
| `format_elapsed()` | Function | Converts seconds into a human-readable string (e.g. `"2m 15.30s"`). |
| `timed()` | Decorator | Wraps a function to log how long it took. |
| `timer()` | Context manager | Logs how long a `with` block took. |

### Helper Functions

| Name | Purpose |
| --- | --- |
| `_get_str()` | Safely reads a string from a Salesforce record dict (handles `None`). |
| `safe_filename()` | Removes invalid Windows filename characters and truncates length. |
| `ensure_pdf_extension()` | Guarantees a filename ends with `.pdf`. |
| `chunked()` | Splits a list into smaller batches (used for SOQL `IN` clauses). |
| `soql_id_list()` | Formats a list of IDs as `'id1','id2'` for SOQL queries. |
| `redact_sensitive_text()` | Removes session tokens from text before logging. |

### Authentication

| Name | Type | Purpose |
| --- | --- | --- |
| `get_cli_org_auth()` | Function | Runs `sf org display` and returns the access token and instance URL. |
| `SalesforceSession` | Class | Holds credentials and provides thread-safe `refresh()` when they expire. |

### HTTP Layer

| Name | Purpose |
| --- | --- |
| `sf_get()` | Makes a GET request to Salesforce with automatic 401 retry. |
| `download_content_version_once()` | Streams a single file to disk atomically (temp file -> rename). |
| `download_content_version_with_retries()` | Wraps the above with exponential-backoff retry logic. |

### Salesforce Queries

| Name | Purpose |
| --- | --- |
| `query_all()` | Executes a SOQL query and follows pagination (`nextRecordsUrl`). |
| `query_agency_privacy_records()` | Fetches AgencyPrivacyData__c records matching the configured filters. |
| `query_orders_by_id()` | Fetches Order records for a list of Order IDs. |
| `query_pdf_links_for_agency_records()` | Fetches ContentDocumentLink records (PDF only) for agency IDs. |

### Output Path Builders

| Name | Purpose |
| --- | --- |
| `build_normal_output_path()` | Constructs a folder/file path using order number, agency name, and IDs. |
| `build_fallback_output_path()` | Shorter path used when Windows rejects a long filename. |
| `build_agency_map()` | Creates an ID->info lookup dict from agency records. |

### Download Orchestration

| Name | Purpose |
| --- | --- |
| `process_single_pdf()` | Downloads one PDF, handles fallback logic, and returns a result dict. Designed to run in a thread. |
| `log_export_summary()` | Prints a final count of downloads, skips, and errors. |
| `main()` | Top-level orchestration: authenticate -> query -> download -> write manifest. |

### Concurrency Model

The script uses Python's `ThreadPoolExecutor` with `MAX_WORKERS` threads. Each
thread downloads one PDF at a time. The `SalesforceSession` class uses a
`threading.Lock` so only one thread refreshes the token if it expires - all other
threads wait and then use the new token.

---

## Output Files

After a successful run the output folder (e.g.
`AXP_Contract_PDFs_Prod_2026.05.19`) contains:

```text
AXP_Contract_PDFs_Prod_2026.05.19/
+-- 00000124_Misker Emmen_a0A8d00000DK2smEAD/
|   +-- 0695x00000ABC_068ABC_ContractDocument.pdf
+-- 00000258_Another Agency_a0AJw000000uWq1MAE/
|   +-- ...
+-- _short_path_fallback/          <- only if long paths failed
|   +-- ...
+-- export_contract_pdf_manifest_prod_2026.05.19.csv
+-- export_contract_pdf_prod_2026.05.19.log
```

### Manifest CSV Columns

| Column | Description |
| --- | --- |
| `AgencyPrivacyDataId` | Salesforce record ID of the AgencyPrivacyData__c record. |
| `AgencyPrivacyDataName` | Human-readable agency/dealer name. |
| `Country` | Country field value. |
| `OrderId` / `OrderNumber` | Related Order identifiers. |
| `AccountName` | Customer/account name from the related Order's Account. |
| `AccountSCAID` | Account SCAID (dealer code) from the related Order's Account. |
| `OrderCreatedDate` | When the Order was created in Salesforce. |
| `OrderStatus` | Current status of the Order. |
| `OpportunityId` | Related Opportunity ID. |
| `QuoteId` | Related Quote ID (if any). |
| `AgencyGroupId` | Agency group identifier. |
| `ContentDocumentLinkId` | Salesforce ID of the link between file and record. |
| `ContentDocumentId` | Salesforce ID of the attached document. |
| `LatestPublishedVersionId` | Version ID used for the download URL. |
| `Title` | Document title in Salesforce. |
| `FileType` / `FileExtension` | File format metadata. |
| `ContentSize` | File size in bytes. |
| `ContentDocumentCreatedDate` | When the file was uploaded to Salesforce. |
| `LocalPath` | Where the file was saved on disk. |
| `Status` | `Downloaded`, `Skipped - already exists`, or `Error`. |
| `Error` | Error details (empty on success). |

---

## Troubleshooting

### "No accessToken returned by Salesforce CLI"

Your CLI session has expired. Re-authenticate:

```bash
sf org login web --alias AXP_PROD
```

### Script downloads zero files

- Check `AGENCY_WHERE_CLAUSE` - it may filter out all records.
- Try a small test run using the CLI limit, for example:
  `python scripts/export_contract_pdfs.py --limit 10`
- Look at the log file for SOQL query details.

### "WinError 206" or path-too-long errors

Windows has a 260-character path limit. The script automatically falls back to a
shorter path in `_short_path_fallback/`. If you still see errors, move
`OUTPUT_BASE_DIR` closer to `C:\`.

### HTTP 429 (Too Many Requests)

Salesforce is rate-limiting you. Reduce `MAX_WORKERS` (e.g. from 3 to 1) and
re-run. Already-downloaded files will be skipped automatically.

### Partial run / interrupted

Re-run the script. It checks whether each PDF already exists on disk (and is
non-empty) and skips it. Only missing files are re-downloaded.

---

## Glossary

| Term | Meaning |
| --- | --- |
| **AgencyPrivacyData__c** | A custom Salesforce object representing an agency/dealer privacy record. |
| **ContentDocumentLink** | A Salesforce junction object that links a file to a record. |
| **ContentVersion** | A Salesforce object representing a specific version of an uploaded file. |
| **SOQL** | Salesforce Object Query Language - similar to SQL but for Salesforce data. |
| **Salesforce CLI (`sf`)** | A command-line tool for interacting with Salesforce orgs. |
| **OAuth access token** | A temporary credential that grants API access without a password. |
| **Instance URL** | The base URL of your Salesforce org (e.g. `https://mycompany.my.salesforce.com`). |
| **ThreadPoolExecutor** | A Python standard-library class that runs functions in parallel threads. |
| **Exponential backoff** | A retry strategy where wait times double after each failure (3s, 6s, 12s). |

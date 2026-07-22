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
- [Filename Scheme](#filename-scheme)
- [How Downloads Are Verified](#how-downloads-are-verified)
- [End-of-Run Reconciliation](#end-of-run-reconciliation)
- [OneDrive and Cloud Placeholder Files](#onedrive-and-cloud-placeholder-files)
- [PII and Generated Reports](#pii-and-generated-reports)
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

Every downloaded PDF is **verified** the moment it lands (see
[How Downloads Are Verified](#how-downloads-are-verified)) - a file is only marked
`Downloaded` after it passes a series of integrity checks. At the very end of the run
the script performs a **three-way reconciliation** (see
[End-of-Run Reconciliation](#end-of-run-reconciliation)) that compares what Salesforce
said existed, what the manifest recorded, and what is actually on disk. If anything
does not line up, the script writes a report and **exits with a non-zero code** so an
automated pipeline can detect the failure.

It also writes a **manifest CSV** listing every file it processed - including its
Salesforce IDs, download path, integrity fingerprints, and status (downloaded,
skipped, or errored).

---

## Prerequisites

Before running this script you need:

| Requirement | Why |
| --- | --- |
| Python 3.13+ | The script uses modern Python type hints and standard library features. |
| Salesforce CLI (`sf`) | Used to authenticate to the Salesforce org without storing passwords. |
| `requests` library | Handles HTTP calls to the Salesforce REST API. |
| `pikepdf` (or `pypdfium2`) | Reads each downloaded PDF to confirm it is structurally valid (Tier 3 verification). `pikepdf==9.11.0` is preferred; `pypdfium2==5.0.0` is a weaker fallback. Both are pinned in `requirements.txt`. |
| Network access to Salesforce | Your machine must reach `*.salesforce.com` over HTTPS. |
| Sufficient disk space | Each PDF is typically 50-500 KB; thousands of records may need several GB. |

### Installing Python

1. Download Python 3.13+ from <https://www.python.org/downloads/>.
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
| `--allow-onedrive` | No | `False` (flag) | Permit an output directory managed by OneDrive. By default the export refuses a OneDrive output directory (unless you confirm at the prompt), because OneDrive can evict files to the cloud and leave incomplete placeholders. Set the folder to "Always keep on this device" in OneDrive before using this flag. See [OneDrive and Cloud Placeholder Files](#onedrive-and-cloud-placeholder-files). |

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

## Filename Scheme

Each downloaded Contract PDF is named:

```text
<ContentDocumentId>_<shortened document title>.pdf
```

Two rules make this safe:

- **The `.pdf` extension is never truncated.** Only the human-readable title
  (the "stem") is shortened to fit a length budget
  (`CONTRACT_MAX_PDF_FILENAME_LEN`). The `ContentDocumentId` prefix and the
  `.pdf` suffix are always kept in full. This fixes a real defect where a very
  long title could push the `.pdf` off the end of the name.
- **Uniqueness is guaranteed.** The `ContentDocumentId` (the stable Salesforce id
  that groups every version of one file) is kept as a prefix, so two different
  documents can never collide even if their titles shorten to the same text.

The `LatestPublishedVersionId` (the exact version downloaded) is intentionally
**dropped from the filename** to keep names short - it is still recorded in the
manifest's `LatestPublishedVersionId` column, so no information is lost.

If Windows rejects a path (the 260-character limit), the script falls back to a
`_short_path_fallback/` folder and names the file
`<ContentDocumentId>_<VersionId>_<shortened order/agency>.pdf`, again always
keeping the `.pdf` extension.

---

## How Downloads Are Verified

A file is only marked `Downloaded` (or `Skipped - already exists`) after it
passes a series of integrity checks. The same checks run on the **skip path**
too: an already-present file is re-proven rather than trusted blindly, so a
corrupt or truncated leftover from an earlier run is caught and re-downloaded.
The checks are grouped into four tiers, cheapest first:

| Tier | What it proves | Contract specifics |
| --- | --- | --- |
| **Tier 1 - metadata + header** | The file exists, ends in `.pdf`, and starts with the `%PDF-` marker. | The file size must also match Salesforce's reported `ContentSize`. |
| **Tier 2 - full read-back** | Every byte is read back off disk, the trailing `%%EOF` marker is present, and a SHA-256 fingerprint is computed and stored. | The bytes are also checked against the HTTP `Content-Length` / `Content-MD5` the server sent, and against Salesforce's own `ContentVersion.Checksum` (an MD5 hash). |
| **Tier 3 - structural parse** | A real PDF engine (`pikepdf`, or `pypdfium2` as a fallback) opens the file and confirms it has at least one page. | Same for both scripts. The engine is imported lazily, so a missing wheel only fails at parse time, never at import. A file that is **valid but password-protected (encrypted)** cannot be opened for its page count, but it is a genuine, byte-complete download - it is kept, marked `Downloaded`, counts as complete, and is flagged in the `Encrypted` manifest column. |
| **Tier 4 - OneDrive placeholder guard** | On a OneDrive folder, the file is real local bytes and not a cloud-only placeholder. | See [OneDrive and Cloud Placeholder Files](#onedrive-and-cloud-placeholder-files). |

The SHA-256 fingerprint from Tier 2 is written to the manifest's `Sha256` column,
and the Salesforce checksum to `ContentVersionChecksum`, so a later run (or the
reconciliation step) can re-prove every file without re-downloading it.

If any mandatory check fails, the row is marked `Error` with a clear message and
the file is never reported as `Downloaded`.

---

## End-of-Run Reconciliation

After all downloads finish, the script performs a **three-way reconciliation**
and writes a report named:

```text
reconciliation_report_contract_prod_YYYY.MM.DD.md
```

It compares three independent views of the run and fails closed (exits non-zero)
if any of them disagree:

1. **Master (Salesforce)** - every `ContentDocumentLink` the query said should
   exist.
2. **Manifest** - every row the script wrote (keyed by `ContentDocumentLinkId`).
3. **Disk** - every `.pdf` file actually present in the output folder, re-hashed
   with SHA-256 and compared to the manifest `Sha256`.

The report flags: a master item with no manifest row; a `Downloaded`/`Skipped`
row with no file on disk; any `Error` row; an **orphan** `.pdf` on disk with no
manifest row; two rows resolving to the **same** path; and any SHA-256 mismatch.

There is also an **independent aggregate `COUNT()`** leg: the script issues a
separate `SELECT COUNT()` (outside the per-record download loop) and confirms it
matches both the number of master items processed and the manifest row count. A
silent row drop upstream (for example a pagination bug) makes these disagree and
the run fails. This proves *completeness of retrieval*; it does not prove the
query *filter* itself is correct - that still needs human sign-off.

A fully matching run exits `0` and the report is all-green. There is no
`--allow-partial` flag: a discrepancy always fails the run.

---

## OneDrive and Cloud Placeholder Files

OneDrive (and similar cloud-sync tools) can replace a real file on disk with a
tiny **placeholder** - the file *looks* present in Explorer but its bytes live in
the cloud until something opens it. Writing thousands of PDFs into such a folder
risks an export that looks complete but is not.

To prevent this:

- If the output directory is detected as OneDrive-managed, the script prints a
  prominent warning and **aborts** unless you confirm at the prompt or pass
  `--allow-onedrive`.
- With `--allow-onedrive`, the export continues but every file still gets a
  per-file **placeholder check** (Tier 4): a file whose bytes are cloud-only is
  marked `Error`, never `Downloaded`.

**Recommendation:** before exporting into a OneDrive folder, right-click it and
choose **"Always keep on this device"**, then run with `--allow-onedrive`. This
detection is Windows-only; on other platforms Tier 4 is a no-op.

---

## PII and Generated Reports

The manifest CSV, the log file, and the reconciliation report all contain
**business-derived data** - agency names, account names, order numbers, and file
paths that may reveal customer information (PII). Treat them as confidential:

- **Never commit** a real manifest, log, or reconciliation report to version
  control. Only tiny, sanitised fixtures belong in the repository.
- Store the output folder somewhere access-controlled.
- When sharing a report for troubleshooting, redact names and IDs first.

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
| `safe_filename_with_extension()` | Like `safe_filename` but shortens only the stem and always keeps the extension and a unique prefix (see [Filename Scheme](#filename-scheme)). |
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
| `main()` | Top-level orchestration: authenticate -> query -> download -> verify -> write manifest -> reconcile. |

### Shared Integrity Modules (REQ-T)

These live under `src/sf_admin_utils/` and are shared with the Quote exporter so
the two scripts can never drift apart in how they verify or reconcile:

| Module | What it does |
| --- | --- |
| `pdf_verification.py` | Tier 1-3 per-file checks (`verify_pdf_bytes`, `verify_pdf_on_disk`) returning a `VerificationResult`. |
| `onedrive_guard.py` | Detects a OneDrive output folder and the Tier 4 per-file placeholder check (Windows-only). |
| `pdf_reconciliation.py` | End-of-run three-way reconciliation (`reconcile`, `write_report`). |

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
|   +-- 069ABC123_ContractDocument.pdf
+-- 00000258_Another Agency_a0AJw000000uWq1MAE/
|   +-- ...
+-- _short_path_fallback/          <- only if long paths failed
|   +-- ...
+-- export_contract_pdf_manifest_prod_2026.05.19.csv
+-- reconciliation_report_contract_prod_2026.05.19.md
+-- export_contract_pdf_prod_2026.05.19.log
```

Each PDF is named `<ContentDocumentId>_<shortened title>.pdf` (see
[Filename Scheme](#filename-scheme)). The reconciliation report is a Markdown
file (see [End-of-Run Reconciliation](#end-of-run-reconciliation)).

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
| `Sha256` | SHA-256 fingerprint of the verified file (Tier 2). Blank if no file was produced. |
| `ContentVersionChecksum` | Salesforce's own MD5 checksum of the stored file, used to cross-check the download (Contract only). |
| `Encrypted` | `yes` when the downloaded PDF is valid but **password-protected**; blank otherwise. An encrypted file is still a complete, genuine download - this flag just tells you it needs a password to open. |

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
| **SHA-256** | A cryptographic fingerprint of a file's bytes. If two files have the same SHA-256, they are identical; any change produces a different fingerprint. |
| **MD5 / Checksum** | An older, shorter fingerprint. Salesforce stores an MD5 `Checksum` for each `ContentVersion`; the script compares it to the download as an extra integrity check. |
| **`%%EOF` marker** | The text a valid PDF must contain near its end. A missing `%%EOF` usually means the download was cut short. Some Salesforce files pad the end with harmless NUL bytes, so the check looks past any trailing NUL/whitespace before deciding the marker is missing. |
| **Encrypted (password-protected) PDF** | A valid PDF whose contents are locked behind a password. It downloads completely and passes reconciliation; it simply cannot be opened or page-counted without the password. Flagged in the `Encrypted` manifest column. |
| **pikepdf / pypdfium2** | Python libraries that open a PDF and confirm it is structurally valid (Tier 3). `pikepdf` is preferred; `pypdfium2` is a weaker fallback. |
| **Reconciliation** | Comparing independent records of the same run (Salesforce, manifest, disk) to prove nothing was lost. |
| **OneDrive placeholder** | A cloud-only stand-in for a file: it appears in Explorer but its bytes are not on disk until opened. Tier 4 rejects these. |
| **PII** | Personally Identifiable Information - data that can identify a person or customer. Manifests and reports may contain it and must not be committed. |

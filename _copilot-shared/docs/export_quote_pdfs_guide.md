# Beginner's Guide - Export Quote PDFs from Salesforce

This guide explains how the `export_quote_pdfs.py` script works, what you need
before running it, and how each piece fits together. It is written for people who
are new to Python scripting and Salesforce administration.

---

## Table of Contents

- [What This Script Does](#what-this-script-does)
- [How It Differs From the Contract PDF Script](#how-it-differs-from-the-contract-pdf-script)
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
records that have a related **Quote**, then downloads the custom Visualforce-rendered
Quote PDF for each record.

Unlike the contract PDF script (which downloads pre-existing file attachments), this
script must **render the PDF on demand** by navigating Salesforce's Visualforce page
(`/apex/quotecustompdf?Id=<QuoteId>`). This involves following JavaScript redirects,
extracting iframe URLs, and handling Salesforce's frontdoor authentication flow.

It writes a **manifest CSV** listing every record processed - including Salesforce IDs,
download path, and status.

---

## How It Differs From the Contract PDF Script

| Aspect | Contract PDF Script | Quote PDF Script |
| --- | --- | --- |
| PDF source | Pre-uploaded files (ContentVersion) | Dynamically rendered Visualforce page |
| Download method | Direct REST API download | Browser-like session with redirect following |
| Authentication flow | Bearer token on REST API | frontdoor.jsp + cookie-based session |
| Fallback strategies | Retry with backoff | Three methods: frontdoor -> VF session -> bearer |
| Related object | Order | Quote |

---

## Prerequisites

Before running this script you need:

| Requirement | Why |
| --- | --- |
| Python 3.12+ | The script uses modern type hints and standard library features. |
| Salesforce CLI (`sf`) | Used to authenticate without storing passwords. |
| `requests` library | Handles HTTP calls and cookie-based browser sessions. |
| Network access to Salesforce | Your machine must reach `*.salesforce.com` and `*.force.com`. |
| Sufficient disk space | Each Quote PDF is typically 50-500 KB. |

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
passwords or tokens directly - it reads a temporary session from the CLI's credential
store.

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
automatically re-authenticates up to 3 times. Between download retries it also
refreshes the session proactively. If that still fails, re-run `sf org login web`
manually and restart the script.

---

## Running the Script

> **Safety first (recommended for your first run):**
> Run a dry run with a small limit to confirm authentication and scope before
> downloading many Visualforce-generated PDFs:
>
> ```bash
> python scripts/export_quote_pdfs.py --sf-alias AXP_PROD --dry-run --limit 5
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
python scripts/export_quote_pdfs.py --sf-alias AXP_PROD --workers 3
```

### Command-line arguments

The script supports these optional CLI arguments:

**Tip:** Run `--help` to see all options at any time:

```bash
python scripts/export_quote_pdfs.py --help
```

| Argument | Required | Default | What it controls |
| --- | --- | --- | --- |
| `--output-dir` | No | Current working directory | Base output directory. The script creates a dated `AXP_Quote_PDFs_Prod_YYYY.MM.DD` subfolder here. |
| `--sf-alias` | No | `AXP_PROD` | Salesforce CLI org alias to authenticate with. |
| `--workers` | No | `3` | Number of concurrent download threads. Increase for faster downloads; reduce if you see HTTP 429 errors. |
| `--limit` | No | *(no limit)* | Maximum number of AgencyPrivacyData__c records to query. Omit (or use `0`) for a full run. Useful for testing: `--limit 10`. |
| `--force-redownload` | No | `False` (flag) | Re-download PDFs that already exist locally. Omit to skip already-downloaded files (safe resume). |
| `--dry-run` | No | `False` (flag) | Query Salesforce and log what would be downloaded, but do not write any files to disk. Safe to run against Production at any time. |
| `--yes` | No | `False` (flag) | Skip the interactive Production confirmation prompt. Use in CI or automation where interactive input is not available. Has no effect when `--dry-run` is active. |

Example - safety check (recommended first run):

```bash
python scripts/export_quote_pdfs.py --sf-alias AXP_PROD --dry-run --limit 5
```

Example - full production run:

```bash
python scripts/export_quote_pdfs.py --sf-alias AXP_PROD --workers 3
```

Example - test with 10 records:

```bash
python scripts/export_quote_pdfs.py --limit 10
```

The script will:

1. Authenticate via the Salesforce CLI.
2. Query AgencyPrivacyData__c records that have a Quote lookup.
3. Query related Quote metadata in bulk.
4. Download Visualforce-generated Quote PDFs concurrently (3 threads).
5. Write a manifest CSV and a log file.

Expect the full run to take **1-3 hours** depending on record count and network
speed (Visualforce rendering is slower than direct file downloads).

---

## Configuration Reference

Some configuration is set via command-line arguments (recommended). Other
behaviour is controlled by constants near the top of the script.

| Constant | Purpose | Default |
| --- | --- | --- |
| `SF_ALIAS` | Salesforce CLI org alias | `"AXP_PROD"` |
| `SF_CLI_PATH` | Full path to the `sf` CLI executable | `C:\Program Files\sf\bin\sf.cmd` |
| `OUTPUT_BASE_DIR` | Parent folder for output (overridden by `--output-dir`) | Current working directory |
| `AGENCY_PRIVACY_QUOTE_FIELD` | API name of the Quote lookup field | `"Quote__c"` |
| `AGENCY_PRIVACY_EXTRA_WHERE` | Extra SOQL WHERE filter | `""` (empty = no filter) |
| `AGENCY_LIMIT` | Max records to query; `None` for all | `None` |
| `MAX_WORKERS` | Number of concurrent download threads (overridden by `--workers`) | `3` |
| `DOWNLOAD_RETRIES` | How many times to retry a failed download | `3` |
| `FORCE_REDOWNLOAD` | Re-download files that already exist locally | `False` |
| `FAIL_SCRIPT_ON_RECORD_ERRORS` | Exit non-zero if any record fails | `False` |

### Testing With a Small Batch

Use `--limit` to download only a few records first:

```bash
python scripts/export_quote_pdfs.py --limit 5
```

---

## Code Walkthrough

The script is organised into logical sections. Here is what each piece does.

### Timing Utilities

| Name | Type | Purpose |
| --- | --- | --- |
| `format_elapsed()` | Function | Converts seconds into a readable string (e.g. `"2m 15.30s"`). |
| `timed()` | Decorator | Wraps a function to log how long it took. |
| `timer()` | Context manager | Logs how long a `with` block took. |

### Validation Helpers

| Name | Purpose |
| --- | --- |
| `validate_salesforce_id()` | Checks that a string looks like a 15/18-char Salesforce ID. |
| `validate_salesforce_field_api_name()` | Guards against SOQL injection in field names. |
| `validate_salesforce_object_api_name()` | Guards against SOQL injection in object names. |

### String and Path Utilities

| Name | Purpose |
| --- | --- |
| `safe_filename()` | Removes invalid Windows filename characters and truncates length. |
| `soql_escape()` | Escapes single quotes and backslashes for SOQL literals. |
| `chunk_list()` | Splits a list into smaller batches for SOQL `IN` clauses. |
| `redact_sensitive_text()` | Removes session tokens from text before logging. |
| `decode_salesforce_redirect_url()` | Decodes HTML entities and escaped slashes in URLs. |

### Authentication

| Name | Type | Purpose |
| --- | --- | --- |
| `get_cli_org_auth()` | Function | Runs `sf org display` and returns the access token + instance URL. |
| `SalesforceSession` | Class | Holds credentials; provides thread-safe `refresh()` on expiry. |

### HTTP Layer

| Name | Purpose |
| --- | --- |
| `sf_get()` | Makes a GET request to Salesforce with automatic 401 retry. |
| `query_all()` | Executes a SOQL query and follows pagination. |

### Salesforce Data Queries

| Name | Purpose |
| --- | --- |
| `build_agency_privacy_soql()` | Constructs the SOQL query with configured filters. |
| `query_agency_privacy_records()` | Fetches AgencyPrivacyData__c records with a Quote lookup. |
| `collect_quote_ids()` | Extracts unique Quote IDs from the agency records. |
| `query_quotes_by_ids()` | Bulk-fetches Quote metadata by ID. |

### Visualforce PDF Download (the complex part)

This is the most intricate section. Salesforce does not expose Visualforce-rendered
PDFs through a simple REST endpoint. Instead, the script mimics a browser:

| Name | Purpose |
| --- | --- |
| `build_visualforce_quote_pdf_path()` | Builds `/apex/quotecustompdf?Id=<QuoteId>`. |
| `response_looks_like_pdf()` | Checks magic bytes (`%PDF`) or Content-Type header. |
| `extract_embedded_pdf_candidate_url()` | Parses iframe/embed/object URLs from HTML. |
| `extract_javascript_redirect_url()` | Finds `window.location.replace(...)` in HTML. |
| `get_response_following_salesforce_javascript_redirects()` | Follows JS redirects and iframe links until a PDF is found. |

### Three Download Methods (Fallback Chain)

The script tries three authentication strategies in order. If one fails, it moves
to the next:

1. **`get_quote_pdf_response_via_frontdoor()`** - Uses `frontdoor.jsp?sid=<token>`
   to establish a cookie-based session, then navigates to the Visualforce page.
2. **`get_quote_pdf_response_via_visualforce_session()`** - Uses the
   `/visualforce/session` endpoint with a Bearer header.
3. **`get_quote_pdf_response_via_bearer()`** - Sends a Bearer token directly to
   the Visualforce URL (simplest, but not always accepted).

### Download Orchestration

| Name | Purpose |
| --- | --- |
| `download_quote_custom_pdf_once()` | Tries all three methods for one Quote; saves PDF atomically. |
| `download_quote_custom_pdf_with_retries()` | Adds exponential-backoff retry + session refresh. |
| `export_one_agency_privacy_quote_pdf()` | Full logic for one record: skip check, download, fallback path. |
| `process_single_quote_pdf()` | Thread-safe wrapper that returns a result dict for the manifest. |

### Output Path Builders

| Name | Purpose |
| --- | --- |
| `build_quote_pdf_output_path()` | Normal path: `OfferNum_AgencyName_AgencyId/QuoteNum_QuoteName.pdf`. |
| `build_quote_pdf_fallback_output_path()` | Short path: `_short_path_fallback/OfferNum_AgencyId_QuoteId.pdf`. |
| `get_quote_offer_number()` | Extracts the offer number for folder naming. |

### Manifest and Summary

| Name | Purpose |
| --- | --- |
| `build_manifest_row()` | Assembles one CSV row from record data and status. |
| `log_batch_summary()` | Prints final counts of downloads, skips, and errors. |
| `main()` | Top-level orchestration: auth -> query -> download -> write manifest. |

### Concurrency Model

The script uses Python's `ThreadPoolExecutor` with `MAX_WORKERS` threads. Each
thread processes one AgencyPrivacyData__c record at a time (including the full
redirect-following flow). The `SalesforceSession` class uses a `threading.Lock` so
only one thread refreshes the token if it expires - all other threads wait and then
use the new token.

---

## Output Files

After a successful run the output folder (e.g. `AXP_Quote_PDFs_Prod_2026.05.19`)
contains:

```text
AXP_Quote_PDFs_Prod_2026.05.19/
+-- Q-12345_Agency Name_a0A8d00000DK2smEAD/
|   +-- Q-12345_Quote Name_0Q0xxx_QuoteCustomPDF.pdf
+-- Q-67890_Another Agency_a0AJw000000uWq1MAE/
|   +-- ...
+-- _short_path_fallback/          <- only if long paths failed
|   +-- ...
+-- _debug_responses/              <- non-PDF responses saved for investigation
|   +-- debug_frontdoor_0Q0xxx.html
+-- export_quote_pdf_manifest_prod_2026.05.19.csv
+-- export_quote_pdfs_2026.05.19.log
```

### Manifest CSV Columns

| Column | Description |
| --- | --- |
| `AgencyPrivacyDataId` | Salesforce record ID of the AgencyPrivacyData__c record. |
| `AgencyPrivacyDataName` | Human-readable agency/dealer name. |
| `Country` | Country field value. |
| `AgencyPrivacyDataCreatedDate` | When the AgencyPrivacyData__c record was created. |
| `AgencyPrivacyDataLastModifiedDate` | When the AgencyPrivacyData__c record was last modified. |
| `OpportunityId` | Related Opportunity ID. |
| `QuoteLookupField` | The Quote lookup field value on AgencyPrivacyData__c. |
| `QuoteId` | Salesforce Quote ID. |
| `QuoteNumber` | Quote number (offer number). |
| `QuoteName` | Quote Name field value. |
| `AccountName` | Customer/account name from the related Quote's Account. |
| `AccountSCAID` | Account SCAID (dealer code) from the related Quote's Account. |
| `QuoteStatus` | Quote status (e.g. Draft, Approved). |
| `QuoteCreatedDate` | When the Quote was created. |
| `QuoteLastModifiedDate` | When the Quote was last modified. |
| `QuoteOpportunityId` | Opportunity linked to the Quote. |
| `AgencyGroupId` | Agency group identifier. |
| `VisualforcePath` | The VF URL path used to render the PDF. |
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

### "All Quote PDF download methods failed"

This means frontdoor, visualforce/session, and bearer all failed. Common causes:

- **Session expired mid-run** - the script should auto-refresh, but if all three
  methods fail, re-authenticate and restart.
- **Visualforce page error** - check the `_debug_responses/` folder for the HTML
  Salesforce returned. It may contain an error message or permission issue.
- **Quote has no rendered PDF** - some Quotes may not have a Visualforce page
  configured.

### Script downloads zero files

- Check that `AGENCY_PRIVACY_QUOTE_FIELD` matches your org's field API name.
- Try setting `AGENCY_PRIVACY_QUERY_LIMIT = 5` to confirm records exist.
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
non-empty) before attempting download. Only missing files are re-processed.

### Debug responses folder

When Salesforce returns HTML instead of a PDF, the response is saved to
`_debug_responses/`. Open these files in a browser to see what Salesforce
actually returned (session tokens are automatically redacted).

---

## Glossary

| Term | Meaning |
| --- | --- |
| **AgencyPrivacyData__c** | A custom Salesforce object representing an agency/dealer privacy record. |
| **Quote** | A standard Salesforce object representing a pricing proposal. |
| **Visualforce** | A Salesforce framework for rendering custom HTML/PDF pages server-side. |
| **frontdoor.jsp** | A Salesforce endpoint that establishes a browser session from an access token. |
| **SOQL** | Salesforce Object Query Language - similar to SQL but for Salesforce data. |
| **Salesforce CLI (`sf`)** | A command-line tool for interacting with Salesforce orgs. |
| **OAuth access token** | A temporary credential that grants API access without a password. |
| **Instance URL** | The base URL of your Salesforce org (e.g. `https://mycompany.my.salesforce.com`). |
| **ThreadPoolExecutor** | A Python standard-library class that runs functions in parallel threads. |
| **Exponential backoff** | A retry strategy where wait times double after each failure (3s, 6s, 12s). |
| **iframe** | An HTML element that embeds another page; Salesforce uses these to wrap PDFs. |

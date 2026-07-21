# Beginner's Guide - Export Non-Visualforce (Stored) Quote PDFs from Salesforce

This guide explains how the `export_non_vf_quote_pdfs.py` script works, what you
need before running it, and how each piece fits together. It is written for people
who are new to Python scripting and Salesforce administration.

---

## Table of Contents

- [What This Script Does](#what-this-script-does)
- [How It Differs From `export_quote_pdfs.py`](#how-it-differs-from-export_quote_pdfspy)
- [Prerequisites](#prerequisites)
- [Salesforce CLI Setup](#salesforce-cli-setup)
- [Running the Script](#running-the-script)
- [Configuration Reference](#configuration-reference)
- [Filename Scheme](#filename-scheme)
- [The Non-Collision Guard](#the-non-collision-guard)
- [How Downloads Are Verified](#how-downloads-are-verified)
- [End-of-Run Reconciliation](#end-of-run-reconciliation)
- [OneDrive and Cloud Placeholder Files](#onedrive-and-cloud-placeholder-files)
- [PII and Generated Reports](#pii-and-generated-reports)
- [Running From the Web Frontend](#running-from-the-web-frontend)
- [Output Files](#output-files)
- [Troubleshooting](#troubleshooting)
- [Glossary](#glossary)

---

## What This Script Does

The script connects to a Salesforce Production org, finds all
**AgencyPrivacyData__c** records that have a **Quote** lookup populated
(`Quote__c != null`), locates the **stored** PDF files attached to those records
(via **ContentDocumentLink** - the Salesforce object that links an uploaded file
to a record, similar to a join table), and downloads every PDF to your local
machine. In this org the stored file is the DocuSign **"Quote #..."** snapshot -
a real, already-generated PDF that Salesforce keeps as a **ContentVersion** (one
version of an uploaded file).

Every downloaded PDF is **verified** the moment it lands (see
[How Downloads Are Verified](#how-downloads-are-verified)) - a file is only marked
`Downloaded` after it passes a series of integrity checks. Because the file is
stored (not generated on the fly), Salesforce knows its exact byte length and an
MD5 fingerprint, so this exporter can prove each downloaded file is
**byte-perfect** - the strongest completeness verdict this project records.

At the very end of the run the script performs a **three-way reconciliation**
(see [End-of-Run Reconciliation](#end-of-run-reconciliation)) that compares what
Salesforce said existed, what the manifest recorded, and what is actually on
disk. If anything does not line up, the script writes a report and **exits with a
non-zero code** so an automated pipeline can detect the failure.

It also writes a **manifest CSV** listing every file it processed - including its
Salesforce IDs, download path, integrity fingerprints, and status (downloaded,
skipped, or errored).

The script is **read-only against Salesforce**: it only queries and downloads. It
never edits, deletes, or uploads anything.

---

## How It Differs From `export_quote_pdfs.py`

The project has two Quote PDF exporters. They sound similar but do very different
things - read this before choosing one.

| | `export_quote_pdfs.py` (VF) | `export_non_vf_quote_pdfs.py` (this script) |
| --- | --- | --- |
| What it downloads | A **live Visualforce** page (`/apex/quotecustompdf`) **rendered fresh** into a PDF on every request. | The **already-stored** file - a Salesforce `ContentVersion` (the DocuSign "Quote #..." snapshot). |
| Is the file stored in Salesforce? | No - it is generated on demand and never saved. | Yes - it is a real uploaded/generated file with its own history. |
| Does Salesforce hold a size and checksum? | No - so the download can only be **wire-proven** (checked against what the HTTP server sent). | Yes - so the download can be **md5-proven** (checked against Salesforce's own stored byte length and MD5). |
| Output folder prefix | `AXP_Quote_PDFs_Prod_...` | `AXP_NonVF_Quote_PDFs_Prod_...` (deliberately different - see [The Non-Collision Guard](#the-non-collision-guard)). |

In short: if you need the **stored** PDF that a person can already open in
Salesforce, use **this** script. If you need a **freshly rendered** copy of the
live Quote page, use `export_quote_pdfs.py`.

---

## Prerequisites

Before running this script you need:

| Requirement | Why |
| --- | --- |
| Python 3.12+ | The script uses modern Python type hints and standard library features. |
| Salesforce CLI (`sf`) | Used to authenticate to the Salesforce org without storing passwords. |
| `requests` library | Handles HTTP calls to the Salesforce REST API. |
| `pikepdf` (or `pypdfium2`) | Reads each downloaded PDF to confirm it is structurally valid (Tier 3 verification). `pikepdf==9.11.0` is preferred; `pypdfium2==5.0.0` is a weaker fallback. Both are pinned in `requirements.txt`. |
| Network access to Salesforce | Your machine must reach `*.salesforce.com` over HTTPS. |
| Sufficient disk space | Each PDF is typically 50-500 KB; thousands of records may need several GB. |

### Installing Python

1. Download Python 3.12+ from <https://www.python.org/downloads/>.
2. During installation tick **"Add Python to PATH"**.
3. Verify in a terminal:

```bash
python --version
```

### Installing the Dependencies

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

Sessions expire (typically after 2-12 hours). The script detects HTTP 401 errors
and automatically calls `sf org display` again. If that still fails, re-run
`sf org login web` manually and restart the script.

---

## Running the Script

> **Safety first (recommended for your first run):**
> Run a dry run with a small limit to confirm authentication and scope before
> downloading thousands of PDFs:
>
> ```bash
> python scripts/export_non_vf_quote_pdfs.py --sf-alias AXP_PROD --dry-run --limit 5
> ```
>
> When you run against a Production org (any alias containing "PROD") without
> `--dry-run`, the script prints a **Production warning** and asks you to confirm.
> This prevents accidental full exports. Use `--yes` to skip the prompt in CI or
> automation pipelines.
>
> Then remove `--dry-run` (and set `--limit 0` or omit `--limit`) for a full
> export.

```bash
cd C:\Users\<you>\Documents\Salesforce
.venv\Scripts\activate
python scripts/export_non_vf_quote_pdfs.py --sf-alias AXP_PROD --workers 3
```

### Command-line arguments

**Tip:** Run `--help` to see all options at any time:

```bash
python scripts/export_non_vf_quote_pdfs.py --help
```

| Argument | Required | Default | What it controls |
| --- | --- | --- | --- |
| `--sf-alias` | No | `AXP_PROD` | Salesforce CLI org alias to authenticate with. |
| `--output-dir` | No | Current working directory | Base output directory. The script creates a dated `AXP_NonVF_Quote_PDFs_Prod_YYYY.MM.DD` subfolder here. |
| `--workers` | No | `3` | Number of concurrent PDF download threads. Increase for faster downloads; reduce if you see HTTP 429 errors. |
| `--limit` | No | *(no limit)* | Maximum number of AgencyPrivacyData__c records to query. Omit (or use `0`) for a full run. Useful for testing: `--limit 10`. A limited run is a test, not a completeness claim (it skips the independent count leg of reconciliation). |
| `--force-redownload` | No | `False` (flag) | Re-download PDFs that already exist locally. Omit this flag to skip already-downloaded files (safe resume). |
| `--dry-run` | No | `False` (flag) | Query Salesforce and log what would be downloaded, but do not write any files to disk. Safe to run against Production at any time. |
| `--yes` | No | `False` (flag) | Skip the interactive Production confirmation prompt. Use in CI or automation where interactive input is not available. Has no effect when `--dry-run` is active. |
| `--allow-onedrive` | No | `False` (flag) | Permit an output directory managed by OneDrive. By default the export refuses a OneDrive output directory (unless you confirm at the prompt), because OneDrive can evict files to the cloud and leave incomplete placeholders. Set the folder to "Always keep on this device" in OneDrive before using this flag. See [OneDrive and Cloud Placeholder Files](#onedrive-and-cloud-placeholder-files). |

Example - full production run:

```bash
python scripts/export_non_vf_quote_pdfs.py --sf-alias AXP_PROD --workers 3
```

Example - test with 10 records into a custom folder:

```bash
python scripts/export_non_vf_quote_pdfs.py --output-dir "C:\Users\<you>\Downloads" --limit 10
```

The script will:

1. Authenticate via the Salesforce CLI.
2. Query AgencyPrivacyData__c records that have a Quote lookup.
3. Query the stored ContentDocumentLink / ContentVersion records (PDF only).
4. Download all PDFs concurrently (3 threads by default).
5. Verify every file (Tiers 1-4).
6. Write a manifest CSV and a log file.
7. Reconcile master vs manifest vs disk and exit non-zero on any mismatch.

Expect a full run to take **30-90 minutes** depending on how many records exist
and your network speed.

---

## Configuration Reference

Some behaviour is set via command-line arguments (recommended). Other behaviour is
controlled by constants near the top of the script.

| Constant | Purpose | Default |
| --- | --- | --- |
| `SF_ALIAS` | Salesforce CLI org alias (overridden by `--sf-alias`) | `"AXP_PROD"` |
| `AGENCY_PRIVACY_OBJECT` | The custom object queried | `"AgencyPrivacyData__c"` |
| `AGENCY_PRIVACY_QUOTE_FIELD` | The Quote lookup field that defines the in-scope population | `"Quote__c"` |
| `AGENCY_PRIVACY_WHERE` | The fixed SOQL filter that isolates the population | `"Quote__c != null"` |
| `PDF_FILE_TYPE` | Only files of this `ContentDocument.FileType` are in scope | `"PDF"` |
| `AGENCY_LIMIT` | Max records to query (overridden by `--limit`); `None` for all | `None` |
| `BATCH_SIZE` | How many IDs are sent in one SOQL `IN (...)` clause | `200` |
| `MAX_WORKERS` | Number of concurrent download threads (overridden by `--workers`) | `3` |
| `DOWNLOAD_TIMEOUT` | Seconds to wait for one HTTP download | `60` |
| `DOWNLOAD_RETRIES` | How many times to retry a failed download | `3` |
| `MAX_PDF_FILENAME_LEN` | Longest filename stem before the prefix and `.pdf` are added | `150` |
| `FORCE_REDOWNLOAD` | Re-download files that already exist locally (overridden by `--force-redownload`) | `False` |
| `FRONTEND_JOB_TIMEOUT_SECONDS` | How long the web frontend may let the job run | `86400` (24 h) |

### The Manual `WHERE` Sign-Off Gate

`AGENCY_PRIVACY_WHERE` is a fixed, developer-controlled literal
(`Quote__c != null`) - it is **never** built from user input, so it is safe to
embed directly in SOQL. Even so, **before the first Production run a human must
confirm this filter against the live query**: it must select exactly the stored
non-VF Quote documents that must be archived (the DocuSign "Quote #..." snapshots)
and nothing else. Do **not** widen it into a broad org-wide `ContentVersion` scan.
The reconciliation step proves *completeness of retrieval* - it does **not** prove
the filter itself is correct. That is why the human sign-off is required.

---

## Filename Scheme

Each downloaded Quote PDF is named:

```text
<ContentDocumentId>_<shortened document title>.pdf
```

Two rules make this safe:

- **The `.pdf` extension is never truncated.** Only the human-readable title (the
  "stem") is shortened to fit a length budget (`MAX_PDF_FILENAME_LEN`, 150
  characters). The `ContentDocumentId` prefix and the `.pdf` suffix are always
  kept in full.
- **Uniqueness is guaranteed.** The `ContentDocumentId` (the stable Salesforce id
  that groups every version of one file) is kept as a prefix, so two different
  documents can never collide even if their titles shorten to the same text.

If Windows rejects a path (the 260-character limit), the script falls back to a
shorter path, again always keeping the `.pdf` extension.

---

## The Non-Collision Guard

This exporter and the Visualforce exporter (`export_quote_pdfs.py`) must **never
share an output folder** - if they did, one could overwrite the other's files and
a reconciliation could not tell them apart.

Two layers enforce this:

1. **A distinct output root name.** This script writes into
   `AXP_NonVF_Quote_PDFs_Prod_YYYY.MM.DD`, whereas the VF exporter uses
   `AXP_Quote_PDFs_Prod_YYYY.MM.DD`. The names can never be equal.
2. **An explicit guard assertion.** Before writing, the script confirms its
   resolved output directory is **not** inside any known VF exporter root. If a
   misconfiguration ever pointed it at the VF folder, it refuses to run rather
   than risk an overwrite.

The reconciliation's orphan leg (below) adds a third safety net: a stray
VF-scheme-named `.pdf` accidentally dropped into this script's output folder is
flagged as an **orphan** because it has no matching manifest row.

---

## How Downloads Are Verified

A file is only marked `Downloaded` (or `Skipped - already exists`) after it passes
a series of integrity checks. The same checks run on the **skip path** too: an
already-present file is re-proven rather than trusted blindly, so a corrupt or
truncated leftover from an earlier run is caught and re-downloaded. The checks are
grouped into four tiers, cheapest first:

| Tier | What it proves | Non-VF Quote specifics |
| --- | --- | --- |
| **Tier 1 - metadata + header** | The file exists, ends in `.pdf`, and starts with the `%PDF-` marker. | **Stronger here:** the file size must match Salesforce's stored `ContentSize` **and** the file's MD5 must match Salesforce's stored `ContentVersion.Checksum`. Passing both earns the `md5-proven` completeness verdict. |
| **Tier 2 - full read-back** | Every byte is read back off disk, the trailing `%%EOF` marker is present, and a SHA-256 fingerprint is computed and stored. | The SHA-256 is written to the manifest `Sha256` column for later re-proof. |
| **Tier 3 - structural parse** | A real PDF engine (`pikepdf`, or `pypdfium2` as a fallback) opens the file and confirms it has at least one page. | The engine is imported lazily, so a missing wheel only fails at parse time, never at import. A **valid but password-protected (encrypted)** PDF cannot be page-counted, but it is a genuine, byte-complete download - it is kept, marked `Downloaded`, counts as complete, and is flagged in the `Encrypted` manifest column. |
| **Tier 4 - OneDrive placeholder guard** | On a OneDrive folder, the file is real local bytes and not a cloud-only placeholder. | See [OneDrive and Cloud Placeholder Files](#onedrive-and-cloud-placeholder-files). |

### Completeness Verdicts

The manifest records a **`Completeness`** value for each verified file:

- **`md5-proven`** - the bytes on disk match **both** Salesforce's stored
  `ContentSize` and its MD5 `Checksum`. This is the strongest verdict: the file is
  provably the exact document Salesforce holds. Every in-scope file is expected to
  reach this.
- **`size-only`** - a defensive fallback used only if a stored file somehow has no
  MD5 checksum. The 2026-07-17 investigation confirmed every in-scope file has one,
  so this value should not normally appear.

If any mandatory check fails, the row is marked `Error` with a clear message and
the file is never reported as `Downloaded`.

---

## End-of-Run Reconciliation

After all downloads finish, the script performs a **three-way reconciliation** and
writes a report named:

```text
export_non-VF_quote_reconciliation_prod_YYYY.MM.DD.md
```

It compares three independent views of the run and fails closed (exits non-zero)
if any of them disagree:

1. **Master (Salesforce)** - every `ContentDocumentLink` the query said should
   exist, keyed by its unique `ContentDocumentLinkId`.
2. **Manifest** - every row the script wrote (also keyed by
   `ContentDocumentLinkId`).
3. **Disk** - every `.pdf` file actually present in the output folder, re-hashed
   with SHA-256 and compared to the manifest `Sha256`.

The report flags: a master item with no manifest row; a `Downloaded`/`Skipped` row
with no file on disk; any `Error` row; an **orphan** `.pdf` on disk with no
manifest row (this also catches a stray VF-scheme file - see
[The Non-Collision Guard](#the-non-collision-guard)); two rows resolving to the
**same** path; and any SHA-256 mismatch.

There is also an **independent aggregate `COUNT()`** leg: the script issues a
separate `SELECT COUNT()` (outside the per-record download loop) and confirms it
matches the number of master items and the manifest row count. A silent row drop
upstream (for example a pagination bug) makes these disagree and the run fails.
This proves *completeness of retrieval*; it does **not** prove the query *filter*
itself is correct - that still needs the human sign-off described above.

The independent count leg runs only on a **full** run. On a `--limit` run the
count would be a partial number and is deliberately skipped.

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
**business-derived data** - agency names, quote identifiers, and file paths that
may reveal customer information (PII). Treat them as confidential:

- **Never commit** a real manifest, log, or reconciliation report to version
  control. Only tiny, sanitised fixtures belong in the repository.
- Store the output folder somewhere access-controlled.
- When sharing a report for troubleshooting, redact names and IDs first.

---

## Running From the Web Frontend

The local web frontend (see the frontend guide) discovers this script
**automatically** - no frontend code change is needed. Its script-discovery engine
reads each script's `build_parser()` for the argument list and its module-level
`FRONTEND_JOB_TIMEOUT_SECONDS` for how long the job may run.

This script declares `FRONTEND_JOB_TIMEOUT_SECONDS = 86400` (24 hours) because a
full Production export can download tens of thousands of PDFs and legitimately run
for many hours. The job runner caps any declared value at its 24-hour hard
ceiling. If a script declares no timeout, the frontend uses its short default
instead, which would stop a long export almost immediately - hence the explicit
24-hour value here.

---

## Output Files

After a successful run the output folder (e.g.
`AXP_NonVF_Quote_PDFs_Prod_2026.07.20`) contains:

```text
AXP_NonVF_Quote_PDFs_Prod_2026.07.20/
+-- <ContentDocumentId>_Quote #12345.pdf
+-- <ContentDocumentId>_Quote #12346.pdf
+-- ...
+-- export_non-VF_quote_pdf_manifest_prod_2026.07.20.csv
+-- export_non-VF_quote_reconciliation_prod_2026.07.20.md
+-- export_non-VF_quote_pdfs_2026.07.20.log
```

Each PDF is named `<ContentDocumentId>_<shortened title>.pdf` (see
[Filename Scheme](#filename-scheme)). The reconciliation report is a Markdown file
(see [End-of-Run Reconciliation](#end-of-run-reconciliation)).

### Manifest CSV Columns

| Column | Description |
| --- | --- |
| `AgencyPrivacyId` | Salesforce record ID of the AgencyPrivacyData__c record. |
| `AgencyPrivacyName` | Human-readable agency/dealer name. |
| `QuoteId` | The related Quote lookup value. |
| `ContentDocumentLinkId` | Salesforce ID of the link between the file and the record. This is the **master grain** used by reconciliation. |
| `ContentDocumentId` | Salesforce ID of the attached document (also the filename prefix). |
| `ContentVersionId` | Salesforce ID of the exact stored version downloaded. |
| `Title` | Document title in Salesforce. |
| `FileExtension` | File extension metadata (`pdf`). |
| `ContentSize` | File size in bytes, as reported by Salesforce. |
| `ContentVersionChecksum` | Salesforce's own MD5 checksum of the stored file, used for the Tier 1 `md5-proven` check. |
| `LocalPath` | Where the file was saved on disk. |
| `Status` | `Downloaded`, `Skipped - already exists`, or `Error`. |
| `Error` | Error details (empty on success). |
| `Sha256` | SHA-256 fingerprint of the verified file (Tier 2). Blank if no file was produced. |
| `Completeness` | `md5-proven` or `size-only` (see [Completeness Verdicts](#completeness-verdicts)). |
| `Encrypted` | `yes` when the downloaded PDF is valid but **password-protected**; blank otherwise. An encrypted file is still a complete, genuine download - this flag just tells you it needs a password to open. |

---

## Troubleshooting

### "No accessToken returned by Salesforce CLI"

Your CLI session has expired. Re-authenticate:

```bash
sf org login web --alias AXP_PROD
```

### Script downloads zero files

- Check `AGENCY_PRIVACY_WHERE` - it may filter out all records, or the Quote
  lookup field may have a different API name in your org.
- Try a small test run: `python scripts/export_non_vf_quote_pdfs.py --limit 10`.
- Look at the log file for SOQL query details.

### "WinError 206" or path-too-long errors

Windows has a 260-character path limit. The script shortens the filename stem
automatically and keeps the `.pdf` extension. If you still see errors, move the
output directory closer to `C:\`.

### HTTP 429 (Too Many Requests)

Salesforce is rate-limiting you. Reduce `--workers` (e.g. from 3 to 1) and re-run.
Already-downloaded files will be skipped automatically.

### The run exits non-zero but files look present

That is the reconciliation failing closed. Open
`export_non-VF_quote_reconciliation_prod_YYYY.MM.DD.md` and read which leg
disagreed (missing file, orphan, duplicate path, hash mismatch, or count
mismatch). Fix the cause and re-run; a clean run exits `0`.

### Partial run / interrupted

Re-run the script. It checks whether each PDF already exists on disk (and passes
verification) and skips it. Only missing or failing files are re-downloaded.

---

## Glossary

| Term | Meaning |
| --- | --- |
| **AgencyPrivacyData__c** | A custom Salesforce object representing an agency/dealer privacy record. The `__c` suffix marks it as custom. |
| **Quote__c** | The lookup field on AgencyPrivacyData__c that points at a Quote. Records where it is populated are this script's in-scope population. |
| **ContentDocument** | The logical file in Salesforce. |
| **ContentVersion** | One specific version of an uploaded file. This script downloads the latest published version's bytes. |
| **ContentDocumentLink** | A Salesforce junction object that links a file to a record. Its `Id` is the reconciliation master grain. |
| **Stored vs live (Visualforce)** | A *stored* file is a real saved file with a size and checksum. A *live Visualforce* PDF is rendered fresh on each request and never saved. |
| **SOQL** | Salesforce Object Query Language - similar to SQL but for Salesforce data. |
| **Salesforce CLI (`sf`)** | A command-line tool for interacting with Salesforce orgs. |
| **OAuth access token** | A temporary credential that grants API access without a password. |
| **SHA-256** | A cryptographic fingerprint of a file's bytes. Identical bytes give an identical fingerprint; any change produces a different one. |
| **MD5 / Checksum** | An older, shorter fingerprint. Salesforce stores an MD5 `Checksum` for each `ContentVersion`; this script compares it to the download for the `md5-proven` verdict. |
| **`%%EOF` marker** | The text a valid PDF must contain near its end. A missing `%%EOF` usually means the download was cut short. Some Salesforce files pad the end with harmless NUL bytes, so the check looks past any trailing NUL/whitespace before deciding the marker is missing. |
| **Encrypted (password-protected) PDF** | A valid PDF whose contents are locked behind a password. It downloads completely and passes reconciliation; it simply cannot be opened or page-counted without the password. Flagged in the `Encrypted` manifest column. |
| **pikepdf / pypdfium2** | Python libraries that open a PDF and confirm it is structurally valid (Tier 3). `pikepdf` is preferred; `pypdfium2` is a weaker fallback. |
| **Reconciliation** | Comparing independent records of the same run (Salesforce, manifest, disk) to prove nothing was lost. |
| **OneDrive placeholder** | A cloud-only stand-in for a file: it appears in Explorer but its bytes are not on disk until opened. Tier 4 rejects these. |
| **PII** | Personally Identifiable Information - data that can identify a person or customer. Manifests and reports may contain it and must not be committed. |

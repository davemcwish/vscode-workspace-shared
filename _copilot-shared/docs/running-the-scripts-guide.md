# Running the Scripts - Beginner's Usage Guide

## What This Guide Covers

This guide explains how to run every script in this project from the command
line. It explains each argument in plain English, shows the most common
commands, and describes what you should see when everything is working.

You do **not** need to edit any Python files to run a normal export. Every
setting that you might need to change is available as a command-line argument
or, optionally, as a variable in your `.env` file.

**Date range covered:** 2026-05-28

---

## Prerequisites

Before running any script you need to have completed the one-time setup
described in `README.md`:

1. Python 3.12 installed and available as `py` or `python`.
2. Virtual environment created and activated (`.venv\Scripts\Activate.ps1`).
3. Salesforce CLI (`sf`) installed and on your PATH.
4. At least one Salesforce org alias set up with `sf org login web`.

If you are unsure whether these are ready, run the sanity check:

```batch
sanity.bat
```

All six steps must pass before running production scripts.

---

## Part 1 - Environment File (Optional but Recommended)

### What the `.env` file is

A `.env` file is a plain-text file that lives in the project root folder. It
stores settings like your Salesforce org alias so you do not have to type them
on the command line every time.

The project provides a template at `.env.example`. Copy it to `.env` and edit
it once:

```powershell
# PowerShell
Copy-Item .env.example .env
notepad .env
```

```batch
:: Command Prompt
copy .env.example .env
notepad .env
```

### What to put in `.env`

Open `.env` in any text editor. You will see:

```text
SF_PROD_ALIAS=AXP_PROD
SF_UAT_ALIAS=AXP_UAT
SF_SIT_ALIAS=AXP_SIT
LOG_LEVEL=INFO
```

- **`SF_PROD_ALIAS`** - the alias you used when you ran
  `sf org login web --alias AXP_PROD`. Change this if your alias is different.
- **`SF_UAT_ALIAS`** - the alias for your UAT (User Acceptance Testing) sandbox.
- **`SF_SIT_ALIAS`** - the alias for your SIT (System Integration Testing) sandbox.
- **`LOG_LEVEL`** - how much detail is printed. `INFO` is the right level for
  normal use. Use `DEBUG` only if you are troubleshooting a problem.

### What the `.env` file does NOT do

The `.env` file does **not** store passwords, tokens, or API keys. Those are
managed entirely by the Salesforce CLI (`sf`). This project only reads the alias
name from `.env` - not any secret.

The main export scripts (`export_contract_pdfs.py` and
`export_quote_pdfs.py`) also accept the alias on the command line via
`--sf-alias`, so the `.env` file is optional for those scripts.

---

## Part 2 - Export Contract PDFs

**Script:** `scripts/export_contract_pdfs.py`

**What it does:** Downloads all AgencyPrivacyData__c contract PDFs
(Salesforce Files - ContentDocumentLink records) linked to Orders in your
Production org. Saves them to a dated folder and writes a manifest CSV.

### See all contract export options

```powershell
python scripts\export_contract_pdfs.py --help
```

### Contract export arguments

| Argument | Type | Default | What it does |
| --- | --- | --- | --- |
| `--sf-alias` | text | `AXP_PROD` | Salesforce CLI org alias to authenticate with |
| `--output-dir` | folder path | current working directory | Where to create the dated output folder |
| `--workers` | number | `3` | How many PDFs to download at the same time |
| `--limit` | number | *(no limit)* | Maximum number of records to query; omit for a full run |
| `--force-redownload` | flag | off | Re-download PDFs that already exist locally |
| `--dry-run` | flag | off | Query Salesforce and log what would be downloaded without writing any files to disk. Safe to run against Production at any time. |
| `--yes` | flag | off | Skip the interactive Production confirmation prompt. Use in CI or automation. Has no effect when `--dry-run` is active. |

### Common contract export commands

> **Production confirmation prompt:** When you run a live export against an org
> alias that contains "PROD" (e.g. `AXP_PROD`), the script will print a warning
> banner and ask you to type the alias to confirm before downloading anything.
> This prevents accidental full-Production exports. Pass `--yes` to skip the
> prompt in CI or automation.

**Full production run - export everything:**

```powershell
python scripts\export_contract_pdfs.py --output-dir "C:\Downloads\AXP Decom 2026"
```

**Test run - first 50 records only:**

```powershell
python scripts\export_contract_pdfs.py `
    --output-dir "C:\Downloads\AXP Decom 2026" `
    --limit 50
```

**Different org alias (e.g. UAT sandbox):**

```powershell
python scripts\export_contract_pdfs.py `
    --sf-alias AXP_UAT `
    --output-dir "C:\Downloads\AXP_UAT_Test" `
    --limit 10
```

**Resume an interrupted run (re-downloads nothing that already exists):**

```powershell
python scripts\export_contract_pdfs.py --output-dir "C:\Downloads\AXP Decom 2026"
```

> The script skips files that already exist and are larger than 0 bytes.
> Just re-run with the same `--output-dir` and it will pick up where it
> left off.

**Force re-download everything:**

```powershell
python scripts\export_contract_pdfs.py `
    --output-dir "C:\Downloads\AXP Decom 2026" `
    --force-redownload
```

**Increase download speed (more workers = faster, but watch for rate-limit errors):**

```powershell
python scripts\export_contract_pdfs.py `
    --output-dir "C:\Downloads\AXP Decom 2026" `
    --workers 5
```

**Preview what would be downloaded without writing any files (dry run):**

```powershell
python scripts\export_contract_pdfs.py `
    --output-dir "C:\Downloads\AXP Decom 2026" `
    --dry-run
```

> Run this before your first Production export to confirm you can authenticate
> and see how many PDFs exist. No files are written and no folders are created.

### What successful contract export output looks like

```text
2026-05-28 14:00:01 [INFO] Using Salesforce CLI authentication.
2026-05-28 14:00:01 [INFO] Username: yourname@fordeurope.com
2026-05-28 14:00:01 [INFO] Querying AgencyPrivacyData__c records...
2026-05-28 14:00:03 [INFO] Found 1842 AgencyPrivacyData__c records.
2026-05-28 14:00:04 [INFO] Querying 1842 related Order records...
2026-05-28 14:00:07 [INFO] Querying PDF ContentDocumentLink records...
2026-05-28 14:00:10 [INFO] Found 3604 PDF file links.
2026-05-28 14:00:10 [INFO] Downloading 3604 PDFs using 3 workers...
2026-05-28 14:00:10 [INFO] [1/3604] Downloaded: 00038935_Dekkerautogr._...
...
2026-05-28 15:12:44 [INFO] Export complete.
2026-05-28 15:12:44 [INFO] PDF files downloaded: 3604
2026-05-28 15:12:44 [INFO] PDF files skipped because already present: 0
2026-05-28 15:12:44 [INFO] Errors: 0
```

### Contract export output folder structure

```text
C:\Downloads\AXP Decom 2026\
+-- AXP_Contract_PDFs_Prod_2026.05.28\
    +-- 00038935_Dekkerautogr. Alkmaar_a0AJw00000CBLtRMAX\
    |   +-- 069Jw00000ABC_057Jw00000XYZ_AgencyPrivacy_Contract.pdf
    |   +-- ...
    +-- _short_path_fallback\            <- only if a path exceeded 260 chars
    +-- export_contract_pdf_manifest_prod_2026.05.28.csv
    +-- export_contract_pdf_prod_2026.05.28.log
```

---

## Part 3 - Export Quote PDFs

**Script:** `scripts/export_quote_pdfs.py`

**What it does:** Downloads Visualforce-generated Quote PDFs for
AgencyPrivacyData__c records that have a linked Quote. These PDFs are
rendered on demand by a custom Salesforce page - they are not stored as
files like contract PDFs.

### See all quote export options

```powershell
python scripts\export_quote_pdfs.py --help
```

### Quote export arguments

| Argument | Type | Default | What it does |
| --- | --- | --- | --- |
| `--sf-alias` | text | `AXP_PROD` | Salesforce CLI org alias to authenticate with |
| `--output-dir` | folder path | current working directory | Where to create the dated output folder |
| `--workers` | number | `3` | How many PDFs to download at the same time |
| `--limit` | number | *(no limit)* | Maximum number of records to query; omit for a full run |
| `--force-redownload` | flag | off | Re-download PDFs that already exist locally |
| `--dry-run` | flag | off | Query Salesforce and log what would be downloaded without writing any files to disk. Safe to run against Production at any time. |
| `--yes` | flag | off | Skip the interactive Production confirmation prompt. Use in CI or automation. Has no effect when `--dry-run` is active. |

### Common quote export commands

> **Production confirmation prompt:** When you run a live export against an org
> alias that contains "PROD" (e.g. `AXP_PROD`), the script will print a warning
> banner and ask you to type the alias to confirm before downloading anything.
> This prevents accidental full-Production exports. Pass `--yes` to skip the
> prompt in CI or automation.

**Full production run:**

```powershell
python scripts\export_quote_pdfs.py --output-dir "C:\Downloads\AXP Decom 2026"
```

**Test run - first 25 records:**

```powershell
python scripts\export_quote_pdfs.py `
    --output-dir "C:\Downloads\AXP_Quote_Test" `
    --limit 25
```

> **Note:** Quote downloads are slower than contract downloads because each
> PDF is generated on demand by Salesforce. Expect roughly 1-3 seconds per
> PDF. Reduce `--workers` to 2 if you see HTTP 429 (rate limit) errors.

**Preview what would be downloaded without writing any files (dry run):**

```powershell
python scripts\export_quote_pdfs.py `
    --output-dir "C:\Downloads\AXP Decom 2026" `
    --dry-run
```

> Run this before your first Production export to confirm you can authenticate
> and see how many Quote PDFs exist. No files are written and no folders are
> created.

### Quote export output folder structure

```text
C:\Downloads\AXP Decom 2026\
+-- AXP_Quote_PDFs_Prod_2026.05.28\
    +-- Q-12345_Dekkerautogr. Alkmaar_a0AJw00000CBLtRMAX\
    |   +-- Q-12345_Agency Quote_0Q0Jw0000001ABCDEF_QuoteCustomPDF.pdf
    +-- _short_path_fallback\
    +-- _debug_responses\                <- saved if a non-PDF response is received
    +-- export_quote_pdf_manifest_prod_2026.05.28.csv
    +-- export_quote_pdfs_2026.05.28.log
```

---

## Part 4 - Create Agency ZIP Files (Contracts)

**Script:** `scripts/create_agency_zips_contract.py`

**What it does:** Reads the output folder from the contract PDF export and
groups the PDFs into one ZIP file per agency. These ZIPs are then uploaded to
EDMS (the Electronic Document Management System).

### See all contract ZIP options

```powershell
python scripts\create_agency_zips_contract.py --help
```

### Contract ZIP arguments

| Argument | Type | Default | What it does |
| --- | --- | --- | --- |
| `--source-dir` | folder path | **required** | The dated contract PDF folder from the export step |
| `--source-manifest` | file path | auto-discover | Path to the manifest CSV; found automatically if omitted |
| `--output-dir` | folder path | dated sibling folder | Where to write the ZIP files |
| `--compression` | number 0-9 | `6` | ZIP compression level (0 = no compression, 9 = maximum) |

### Common contract ZIP commands

**Standard run after a contract export:**

```powershell
python scripts\create_agency_zips_contract.py `
    --source-dir "C:\Downloads\AXP Decom 2026\AXP_Contract_PDFs_Prod_2026.05.28"
```

**Custom output location:**

```powershell
python scripts\create_agency_zips_contract.py `
    --source-dir "C:\Downloads\AXP Decom 2026\AXP_Contract_PDFs_Prod_2026.05.28" `
    --output-dir "C:\Downloads\AXP Decom 2026\Contract_ZIPs_2026.05.28"
```

---

## Part 5 - Create Agency ZIP Files (Quotes)

**Script:** `scripts/create_agency_zips_quote.py`

**What it does:** Same as the contract ZIP script but for the Quote PDF export
output.

### See all quote ZIP options

```powershell
python scripts\create_agency_zips_quote.py --help
```

### Quote ZIP arguments

Same as the contract ZIP script - see the table in Part 4. The argument names
and defaults are identical.

### Common quote ZIP commands

**Standard run after a quote export:**

```powershell
python scripts\create_agency_zips_quote.py `
    --source-dir "C:\Downloads\AXP Decom 2026\AXP_Quote_PDFs_Prod_2026.05.28"
```

---

## Part 6 - Running the Full Pipeline

Run the scripts in this order. Each step depends on the output of the previous
one.

```text
Step 1  Export contract PDFs  ->  AXP_Contract_PDFs_Prod_YYYY.MM.DD\
Step 2  Export quote PDFs     ->  AXP_Quote_PDFs_Prod_YYYY.MM.DD\
Step 3  ZIP contracts         ->  AXP_Contract_ZIPs_YYYY.MM.DD\
Step 4  ZIP quotes            ->  AXP_Quote_ZIPs_YYYY.MM.DD\
Step 5  Upload ZIPs to EDMS   ->  (manual - outside this project)
```

**PowerShell example - all four steps with a shared output folder:**

```powershell
$OutputBase = "C:\Downloads\AXP Decom 2026"
$Today = Get-Date -Format "yyyy.MM.dd"

# Step 1 - Contract PDFs
python scripts\export_contract_pdfs.py --output-dir $OutputBase

# Step 2 - Quote PDFs
python scripts\export_quote_pdfs.py --output-dir $OutputBase

# Step 3 - Contract ZIPs
python scripts\create_agency_zips_contract.py `
    --source-dir "$OutputBase\AXP_Contract_PDFs_Prod_$Today"

# Step 4 - Quote ZIPs
python scripts\create_agency_zips_quote.py `
    --source-dir "$OutputBase\AXP_Quote_PDFs_Prod_$Today"
```

> See `scripts/samples/run_full_pipeline.ps1` for a ready-to-run version of
> this pipeline with error-level checking.

---

## Part 7 - Resuming an Interrupted Run

All four scripts are safe to re-run after an interruption.

- **Export scripts** skip files that already exist with content (size > 0 bytes).
  Just re-run with the same `--output-dir` and the same date will be used for
  the folder name.
- **ZIP scripts** overwrite existing ZIPs for any agency that changed. This is
  safe to repeat.

No records are lost. The manifest CSV is written inside a `finally:` block, so
even a hard crash preserves everything that was processed before the failure.

---

## Part 8 - Checking the Manifest CSV

After each export, open the manifest CSV in Excel to review results.

**Contract manifest columns:**

| Column | What it contains |
| --- | --- |
| `AgencyPrivacyDataId` | Salesforce record ID |
| `AgencyPrivacyDataName` | Human-readable agency name |
| `Country` | Country code |
| `OrderId` | Related Salesforce Order ID |
| `OrderNumber` | Human-readable order number |
| `AccountName` | Customer account name |
| `LocalPath` | Full path to the downloaded PDF on your machine |
| `Status` | `Downloaded`, `Skipped`, or `Error` |
| `Error` | Error message if `Status` is `Error`, otherwise blank |

Filter `Status = Error` first. A handful of errors is normal (e.g. a record
that has no PDF attached). More than a few percent errors warrants investigation.

---

## Part 9 - Troubleshooting

### "Salesforce CLI ('sf') not found on PATH"

The Salesforce CLI is not installed or not on your PATH.

1. Check: `sf --version` in a new terminal window.
2. If not found: download from <https://developer.salesforce.com/tools/salesforcecli>
   and re-open your terminal.

### "RuntimeError: No accessToken returned by Salesforce CLI"

Your org session has expired.

```powershell
sf org login web --alias AXP_PROD
```

### "getaddrinfo ENOTFOUND login.salesforce.com"

Ford's DNS server is not resolving Salesforce domains. This is a known
intermittent issue on the corporate network.

1. Try `ipconfig /flushdns` in an administrator Command Prompt.
2. Switch to a different network or reconnect your VPN.
3. Re-run `sf org login web`.

See section 7.1 of `salesforce-admin-utilities-guide.md` for full details.

### PDF download is an HTML page instead of a PDF

Your Salesforce session expired mid-run. The script will re-authenticate
automatically up to three times. If it keeps happening:

1. Reduce `--workers` to `2` or `1`.
2. Re-authenticate manually and re-run (skipping already-downloaded files).

### Output folder already contains files from a previous run

That is fine. Re-run the export with the same `--output-dir`. The script skips
files that are already present and larger than 0 bytes.

---

## Key Concepts for Beginners

| Term | Plain-English explanation |
| --- | --- |
| `--flag` | A command-line argument you type after the script name to change its behaviour |
| argparse | Python's built-in library for reading command-line arguments |
| `.env` file | A plain-text file of `KEY=VALUE` settings loaded by the script at startup |
| Salesforce CLI alias | A short nickname for a Salesforce org (e.g. `AXP_PROD`) set when you log in |
| `sf org login web` | Opens a browser window to log in to Salesforce and saves the session locally |
| `ContentDocumentLink` | The Salesforce object linking an uploaded file to a record (used for contract PDFs) |
| Visualforce | Salesforce's server-side page technology; used to render quote PDFs on demand |
| Manifest CSV | A spreadsheet written by the script listing every record processed, its local path, and whether it succeeded or failed |
| `--limit` | Caps the number of records queried; useful for a safe test run before committing to a full export |
| `--force-redownload` | Makes the script overwrite files it has already downloaded; normally you leave this off |
| `--dry-run` | Runs the authentication and Salesforce query steps but writes nothing to disk; safe to use against Production at any time |
| EDMS | Electronic Document Management System - the long-term archive for exported ZIPs |

# Sample Scripts Guide

The `scripts/samples/` folder contains ready-to-run wrapper scripts for the four
main Python scripts in this project. They are designed so that non-developers can
run a full export or ZIP creation by editing a single variable and double-clicking
the file - no need to type Python commands manually.

---

## Table of Contents

- [Overview](#overview)
- [Before You Start](#before-you-start)
- [Individual Scripts](#individual-scripts)
  - [run_export_contracts.bat](#run_export_contractsbat)
  - [run_export_quotes.bat](#run_export_quotesbat)
  - [run_zip_contracts.bat](#run_zip_contractsbat)
  - [run_zip_quotes.bat](#run_zip_quotesbat)
  - [run_full_pipeline.ps1](#run_full_pipelineps1)
- [Typical Workflows](#typical-workflows)
- [Customising the Scripts](#customising-the-scripts)
- [Troubleshooting](#troubleshooting)

---

## Overview

| File | Type | Purpose |
| --- | --- | --- |
| `run_export_contracts.bat` | Batch | Download Contract PDFs from Salesforce |
| `run_export_quotes.bat` | Batch | Download Quote PDFs from Salesforce |
| `run_zip_contracts.bat` | Batch | ZIP downloaded Contract PDF folders by agency |
| `run_zip_quotes.bat` | Batch | ZIP downloaded Quote PDF folders by agency |
| `run_full_pipeline.ps1` | PowerShell | Run all four steps in sequence automatically |

The `.bat` files are designed to be run individually (one task at a time). The
`.ps1` file chains all four steps together and stops immediately if any step fails.

---

## Before You Start

These steps are required before running **any** sample script.

### 1 - Activate the virtual environment

Open a terminal in the project root and run:

```batch
.venv\Scripts\activate
```

If the virtual environment does not exist yet, run `setup.bat` first.

### 2 - Authenticate with Salesforce

```batch
sf org login web --alias AXP_PROD
```

A browser window opens. Sign in with your Salesforce Production credentials.
After closing the browser, verify the session is active:

```batch
sf org list
```

You should see `AXP_PROD` with a current access token.

### 3 - Verify Python is on your PATH

```batch
python --version
```

Expected output: `Python 3.13.x`

---

## Individual Scripts

### `run_export_contracts.bat`

**What it does:** Calls `export_contract_pdfs.py` to download all
AgencyPrivacyData__c Contract PDFs from Salesforce into a dated folder.

**Variables to edit (at the top of the file):**

| Variable | Default | When to change |
| --- | --- | --- |
| `BASE_DIR` | `C:\Users\<you>\Documents` | Change to your preferred output location |
| `SF_ALIAS` | `AXP_PROD` | Change if your CLI alias is different |
| `WORKERS` | `3` | Increase for faster downloads (try 5); reduce if errors appear |
| `LIMIT` | `0` (all records) | Set to `10` for a test run before a full export |

**Output created:**

```text
C:\Users\<you>\Documents\
+-- AXP_Contract_PDFs_Prod_YYYY.MM.DD\
    +-- 00000124_Agency Name_<SalesforceID>\
    |   +-- contract.pdf
    +-- ...
    +-- export_contract_pdf_manifest_prod_YYYY.MM.DD.csv
    +-- export_contract_pdf_prod_YYYY.MM.DD.log
```

**Typical runtime:** 30-90 minutes for a full production run.

---

### `run_export_quotes.bat`

**What it does:** Calls `export_quote_pdfs.py` to download all
AgencyPrivacyData__c Quote PDFs from Salesforce. Quote PDFs are generated
dynamically by a Visualforce page and are therefore slower to download than
Contract PDFs.

**Variables to edit (at the top of the file):**

| Variable | Default | When to change |
| --- | --- | --- |
| `BASE_DIR` | `C:\Users\<you>\Documents` | Change to your preferred output location |
| `SF_ALIAS` | `AXP_PROD` | Change if your CLI alias is different |
| `WORKERS` | `3` | Increase for faster downloads (try 5); reduce if errors appear |
| `LIMIT` | `0` (all records) | Set to `10` for a test run before a full export |

**Output created:**

```text
C:\Users\<you>\Documents\
+-- AXP_Quote_PDFs_Prod_YYYY.MM.DD\
    +-- 00000124_Agency Name_<SalesforceID>\
    |   +-- Q-12345_QuoteName_QuoteCustomPDF.pdf
    +-- ...
    +-- export_quote_pdf_manifest_prod_YYYY.MM.DD.csv
    +-- export_quote_pdfs_YYYY.MM.DD.log
```

**Typical runtime:** 1-3 hours for a full production run (Visualforce rendering
is slower than file download).

---

### `run_zip_contracts.bat`

**What it does:** Calls `create_agency_zips_contract.py` to scan the Contract
PDF export folder and create one `.zip` file per agency. Run this **after**
`run_export_contracts.bat` has completed successfully.

**Variables to edit (at the top of the file):**

| Variable | Default | When to change |
| --- | --- | --- |
| `SOURCE_DIR` | `...\AXP_Contract_PDFs_Prod_YYYY.MM.DD` | **Required** - replace `YYYY.MM.DD` with the actual export date |
| `COMPRESSION` | `6` | Lower for faster creation; raise for smaller files |

> **Important:** You must edit `SOURCE_DIR` to point to the folder that was
> created by the export script. The script will not start if the folder does
> not exist.

**Output created (in a dated sibling folder):**

```text
C:\Users\<you>\Documents\
+-- AXP_Contract_PDFs_Zipped_YYYY.MM.DD\
    +-- Agency Name 1.zip
    +-- Agency Name 2.zip
    +-- ...
    +-- create_contract_zips_manifest_YYYY.MM.DD.csv
    +-- create_contract_zips_YYYY.MM.DD.log
    +-- export_contract_manifest_prod_with_zips_YYYY.MM.DD.csv
```

**Typical runtime:** 5-30 minutes.

---

### `run_zip_quotes.bat`

**What it does:** Calls `create_agency_zips_quote.py` to scan the Quote PDF
export folder and create one `.zip` file per agency. Run this **after**
`run_export_quotes.bat` has completed successfully.

**Variables to edit (at the top of the file):**

| Variable | Default | When to change |
| --- | --- | --- |
| `SOURCE_DIR` | `...\AXP_Quote_PDFs_Prod_YYYY.MM.DD` | **Required** - replace `YYYY.MM.DD` with the actual export date |
| `COMPRESSION` | `6` | Lower for faster creation; raise for smaller files |

> **Important:** You must edit `SOURCE_DIR` to point to the folder that was
> created by the export script. The script will not start if the folder does
> not exist.

**Output created (in a dated sibling folder):**

```text
C:\Users\<you>\Documents\
+-- AXP_Quote_PDFs_Zipped_YYYY.MM.DD\
    +-- Agency Name 1.zip
    +-- Agency Name 2.zip
    +-- ...
    +-- create_quote_zips_manifest_YYYY.MM.DD.csv
    +-- create_quote_zips_YYYY.MM.DD.log
    +-- export_quote_manifest_prod_with_zips_YYYY.MM.DD.csv
```

**Typical runtime:** 5-30 minutes.

---

### `run_full_pipeline.ps1`

**What it does:** Runs all four steps (export contracts -> ZIP contracts -> export
quotes -> ZIP quotes) in sequence. If **any** step fails, the pipeline stops
immediately and reports which step failed with the exit code. This is the
recommended way to run a full production export.

**How to run it:**

Open a PowerShell terminal in the project root and run:

```powershell
.venv\Scripts\Activate.ps1
.\scripts\samples\run_full_pipeline.ps1
```

Or pass parameters directly to override defaults without editing the file:

```powershell
.\scripts\samples\run_full_pipeline.ps1 -Limit 10 -Workers 5 -BaseDir "C:\Temp\test"
```

**Parameters:**

| Parameter | Default | Description |
| --- | --- | --- |
| `-BaseDir` | `C:\Users\<you>\Documents` | Parent folder for all output. |
| `-SfAlias` | `AXP_PROD` | Salesforce CLI org alias. |
| `-Workers` | `3` | Concurrent download threads per export step. |
| `-Limit` | `0` (all records) | Max records per export. Use `10` for a test run. |
| `-Compression` | `6` | ZIP compression level `0`-`9`. |

**Execution policy note:** If PowerShell blocks the script with an
`UnauthorizedAccess` error, run this once to allow local scripts:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

**Typical runtime:** 2-5 hours for a full production run (dominated by the
Quote PDF export step).

---

## Typical Workflows

### Full production run (recommended)

```powershell
.venv\Scripts\Activate.ps1
sf org login web --alias AXP_PROD
.\scripts\samples\run_full_pipeline.ps1
```

### Test run before production

```powershell
# Export 10 contract records only
run_export_contracts.bat   # with LIMIT=10
# Inspect the output folder
# Then zip them
run_zip_contracts.bat      # with SOURCE_DIR updated
```

### Re-run just the ZIP step after a partial failure

If the export ran successfully but the ZIP step failed (e.g. out of disk space):

1. Edit `SOURCE_DIR` in `run_zip_contracts.bat` to point to the existing export folder.
2. Re-run `run_zip_contracts.bat` - the ZIP script overwrites any partial ZIPs.

### Resume an interrupted export

The export scripts skip files that already exist (unless `--force-redownload` is
passed). To resume into an existing folder, simply re-run the export script with
the same `BASE_DIR`. It picks up where it left off.

---

## Customising the Scripts

### Run without sample scripts (advanced)

All four scripts support full CLI argument control. Use `--help` to see all
available options:

```batch
python scripts/export_contract_pdfs.py --help
python scripts/export_quote_pdfs.py --help
python scripts/create_agency_zips_contract.py --help
python scripts/create_agency_zips_quote.py --help
```

### Change compression level

PDFs are already compressed internally, so ZIP compression savings are typically
modest (10-30%). If speed matters more than file size:

```batch
set "COMPRESSION=0"  :: store only - fastest, no compression
```

If minimising upload size is more important:

```batch
set "COMPRESSION=9"  :: maximum compression - slowest
```

---

## Troubleshooting

### "python is not recognized"

Python is not on your `PATH`. Either activate the virtual environment first, or
specify the full path:

```batch
.venv\Scripts\python.exe scripts/export_contract_pdfs.py --help
```

### "sf is not recognized" or authentication fails

Ensure the Salesforce CLI is installed and you have authenticated:

```batch
sf --version
sf org login web --alias AXP_PROD
sf org list
```

If `sf` is not found, install it from <https://developer.salesforce.com/tools/salesforcecli>.

### PowerShell "scripts are disabled on this system"

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### Export downloads fewer records than expected

The export scripts only limit the run when you pass a limit.

- In the sample `.bat` files, this is controlled by the `LIMIT` variable.
- When running the Python scripts directly, it is controlled by `--limit`.

For a full production run, use `LIMIT=0` in the `.bat` files or omit `--limit`
(or pass `--limit 0`) when running the Python script directly.

### ZIP script says "Source directory not found"

The `SOURCE_DIR` variable still contains `YYYY.MM.DD`. Edit the file and replace it
with the actual date of your export run (e.g. `2026.05.27`).

### "Access is denied" or path errors on Windows

Windows limits file paths to 260 characters. The export scripts handle this
automatically using a `_short_path_fallback` folder. If you see issues, check:

1. You have write permissions to `BASE_DIR`.
2. The output path is not excessively long.

---

## See Also

| Guide | Description |
| --- | --- |
| [Export Contract PDFs Guide](./export_contract_pdfs_guide.md) | Full explanation of `export_contract_pdfs.py`. |
| [Export Quote PDFs Guide](./export_quote_pdfs_guide.md) | Full explanation of `export_quote_pdfs.py`. |
| [Create Agency ZIPs - Contract Guide](./create_agency_zips_contract_guide.md) | Full explanation of `create_agency_zips_contract.py`. |
| [Create Agency ZIPs - Quote Guide](./create_agency_zips_quote_guide.md) | Full explanation of `create_agency_zips_quote.py`. |
| [README](../README.md) | Project overview and quick-start. |

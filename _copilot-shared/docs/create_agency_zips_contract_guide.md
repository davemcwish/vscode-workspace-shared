# Beginner's Guide - Create Agency ZIP Archives (Contract PDFs)

This guide explains how the `create_agency_zips_contract.py` script works, what you
need before running it, and how each piece fits together. It is written for people
who are new to Python scripting and Salesforce administration.

---

## Table of Contents

- [What This Script Does](#what-this-script-does)
- [Prerequisites](#prerequisites)
- [Running the Script](#running-the-script)
- [Configuration Reference](#configuration-reference)
- [Code Walkthrough](#code-walkthrough)
- [Output Files](#output-files)
- [Troubleshooting](#troubleshooting)
- [Glossary](#glossary)

---

## What This Script Does

After the `export_contract_pdfs.py` script downloads thousands of individual
PDF files into separate folders, this script **groups them into ZIP archives** - one
ZIP per agency/dealer. This makes the final upload to EDMS manageable: instead of
thousands of folders you upload a small number of ZIP files.

The script:

1. Scans the downloaded PDF folder structure.
2. Groups subfolders by **AgencyPrivacyDataName** (the dealer/agency name embedded
   in each folder name).
3. Creates one `.zip` file per agency containing all of that agency's order folders.
4. Writes a manifest CSV recording what was zipped.
5. Optionally enriches the original export manifest with a `ZipFileName` column so
   you can look up which ZIP contains a specific PDF.

---

## Prerequisites

| Requirement | Why |
| --- | --- |
| Python 3.12+ | The script uses modern type hints and standard library features. |
| No extra packages | This script uses **only the Python standard library** - no `pip install` needed. |
| Completed PDF export | You must have already run `export_contract_pdfs.py` to download the PDFs. |
| Sufficient disk space | The ZIP files will be roughly 30-70% the size of the originals. |

### About the Salesforce CLI

This script does **not** connect to Salesforce directly. It only reads files that
were previously downloaded by `export_contract_pdfs.py`. However, if you need
to re-run the export first, see the
[Export Contract PDFs Guide](./export_contract_pdfs_guide.md) for Salesforce CLI
setup instructions.

### Installing Python

1. Download Python 3.12+ from <https://www.python.org/downloads/>.
2. During installation tick **"Add Python to PATH"**.
3. Verify in a terminal:

```bash
python --version
```

---

## Running the Script

`--source-dir` is the only required argument - it points to the folder created by
`export_contract_pdfs.py`.

**Tip:** Run `--help` to see all options at any time:

```bash
python scripts/create_agency_zips_contract.py --help
```

### Command-line arguments

| Argument | Required | Default | What it controls |
| --- | --- | --- | --- |
| `--source-dir` | ✅ Yes | - | Folder containing the exported Contract PDF agency subfolders. |
| `--source-manifest` | No | Auto-discovered in `--source-dir` | Path to the export manifest CSV. Used to create the enriched manifest. |
| `--output-dir` | No | Auto-created dated sibling of `--source-dir` | Where ZIP files, the manifest, and the log are written. |
| `--compression` | No | `6` | ZIP compression level from `0` (no compression, fastest) to `9` (maximum compression, slowest). |

### Example commands

Minimal (required argument only):

```bash
python scripts/create_agency_zips_contract.py --source-dir "C:\Users\<you>\Downloads\AXP_Contract_PDFs_Prod_2026.05.27"
```

Full example with all arguments:

```bash
python scripts/create_agency_zips_contract.py ^
    --source-dir "C:\Users\<you>\Downloads\AXP_Contract_PDFs_Prod_2026.05.27" ^
    --output-dir "C:\Users\<you>\Downloads\AXP_Contract_Zips" ^
    --compression 6
```

No virtual environment activation is needed because the script has no third-party
dependencies.

The script will:

1. Scan the `--source-dir` for PDF subfolders.
2. Group them by agency name.
3. Create ZIP archives in the output directory.
4. Write a manifest CSV and a log file.

A typical run completes in **5-30 minutes** depending on the number and size of PDFs.

---

## Configuration Reference

All runtime configuration is passed via command-line arguments (see above). The
constants below appear at the top of the script and control defaults that apply when
you do not pass the corresponding argument.

| Constant | Purpose | Default |
| --- | --- | --- |
| `DEFAULT_ZIP_COMPRESSION_LEVEL` | Default compression level (overridden by `--compression`) | `6` |
| `DEFAULT_SOURCE_MANIFEST_FILE_NAME` | Filename the script looks for inside `--source-dir` when `--source-manifest` is not given | `export_contract_pdf_manifest_prod.csv` |
| `FOLDER_NAME_PATTERN` | Regex used to parse folder names into order number, agency name, and Salesforce ID | See below |

### Folder Name Format

The script expects subfolders named:

```text
{OrderNumber}_{AgencyPrivacyDataName}_{SalesforceID}
```

For example:

```text
00000124_Misker Emmen_a0A8d00000DK2smEAD
```

Folders that do not match this pattern (e.g. `_short_path_fallback`) are silently
skipped.

---

## Code Walkthrough

The script is organised into logical sections.

### Timing Utilities

| Name | Type | Purpose |
| --- | --- | --- |
| `format_elapsed()` | Function | Converts seconds into a readable string (e.g. `"2m 15.30s"`). |
| `timed()` | Decorator | Wraps a function to log how long it took. |
| `timer()` | Context manager | Logs how long a `with` block took. |

### Folder Name Parsing

| Name | Purpose |
| --- | --- |
| `parse_folder_name()` | Splits a folder name into (order_number, agency_name, salesforce_id) using the regex. Returns `None` for non-matching names. |
| `safe_zip_filename()` | Converts a raw agency name into a clean Windows-safe ZIP filename. Reverses the underscore substitution made by the export script. |

### Folder Discovery

| Name | Purpose |
| --- | --- |
| `discover_agency_folders()` | Scans the source directory, groups matching subfolders by agency name, and returns a dictionary mapping agency name -> list of folder paths. |

### ZIP Creation

| Name | Purpose |
| --- | --- |
| `create_agency_zip()` | Creates one ZIP archive for a single agency. Adds all files from the agency's folders, preserving folder structure inside the ZIP. Cleans up partial files on error. |

### Reporting

| Name | Purpose |
| --- | --- |
| `write_manifest()` | Writes the run manifest as a UTF-8 BOM CSV (opens cleanly in Excel). |
| `enrich_source_manifest_with_zip_names()` | Reads the original export manifest and writes a copy with an added `ZipFileName` column, so you can look up which ZIP contains a specific PDF. |
| `log_summary()` | Prints a final human-readable summary to the log. |

### Main Orchestration

| Name | Purpose |
| --- | --- |
| `main()` | Ties everything together: discover folders -> create ZIPs -> write manifests -> log summary. |

### How the ZIP Internal Structure Works

Each ZIP preserves the original folder name inside it:

```text
Misker Emmen.zip/
+-- 00000124_Misker Emmen_a0A8d00000DK2smEAD/
|   +-- contract_document.pdf
+-- 00000258_Misker Emmen_a0AJw000000uWq1MAE/
    +-- another_document.pdf
```

This means the order number and Salesforce ID remain visible after extraction,
supporting traceability in EDMS.

---

## Output Files

After a successful run the output folder contains:

```text
AXP_Contract_PDFs_Zipped_2026.05.19/
+-- Misker Emmen.zip
+-- Zeeuw & Zeeuw Utrecht.zip
+-- Hedin Automotive - Hoofddorp.zip
+-- ...
+-- create_contract_zips_manifest_2026.05.19.csv
+-- create_contract_zips_2026.05.19.log
+-- export_contract_manifest_prod_with_zips_2026.05.19.csv   <- enriched manifest
```

### Manifest CSV Columns

| Column | Description |
| --- | --- |
| `AgencyPrivacyDataName` | Raw agency name as extracted from folder names. |
| `ZipFileName` | Name of the created ZIP file. |
| `SourceFolderCount` | Number of order folders included in this ZIP. |
| `TotalFileCount` | Total number of files added to the ZIP. |
| `TotalUncompressedBytes` | Original size of all files before compression. |
| `ZipSizeBytes` | Final compressed size on disk. |
| `Status` | `Created` or `Error`. |
| `Error` | Error details (empty on success). |

### Enriched Export Manifest

If the original export manifest CSV exists, the script writes a copy with an extra
`ZipFileName` column appended. This lets you search for any PDF by Salesforce ID
and immediately see which ZIP archive contains it.

---

## Troubleshooting

### "Source directory does not exist"

Ensure `SOURCE_DIR` points to the folder created by `export_contract_pdfs.py`.
The default expects:

```text
C:\Users\dwishar1\Downloads\AXP Decom 2026\AXP_Contract_PDFs_Prod
```

### "No matching folders found"

- Verify the downloaded folders follow the expected naming pattern.
- Check for typos in `SOURCE_DIR`.
- The export script may have saved everything in `_short_path_fallback` - those
  folders are intentionally skipped because they lack agency grouping info.

### ZIP file is unexpectedly large

Lower the compression level for faster runs or raise it for smaller files:

```python
ZIP_COMPRESSION_LEVEL = 9  # maximum compression (slower)
```

PDFs are already compressed, so ZIP savings are typically modest (10-30%).

### "'LocalPath' column not found in source manifest"

The enrichment step expects the original export manifest to have a column named
`LocalPath`. If the export script used a different column name, update the
`enrich_source_manifest_with_zip_names()` function or skip enrichment by removing
or renaming the `SOURCE_PDF_MANIFEST_CSV` file.

### Re-running after a partial failure

The script overwrites any existing ZIP with the same name in the output folder.
Simply fix the issue and re-run - no manual cleanup needed.

---

## Glossary

| Term | Meaning |
| --- | --- |
| **AgencyPrivacyData__c** | A custom Salesforce object representing an agency/dealer privacy record. |
| **EDMS** | Electronic Document Management System - the final destination for these archives. |
| **ZIP archive** | A compressed file format that bundles multiple files into one `.zip` file. |
| **Manifest CSV** | A spreadsheet listing every item processed, with status and metadata. |
| **UTF-8 BOM** | A text encoding that includes a byte-order mark so Excel opens CSVs correctly. |
| **Regex** | A pattern-matching language used to parse structured text like folder names. |
| **Salesforce ID** | A unique 18-character alphanumeric identifier for every record in Salesforce. |

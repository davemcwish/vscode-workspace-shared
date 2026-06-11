# Prototype Excel Chart Guide

`scripts/prototype_excel_chart.py` is a **design-review tool** that generates
a realistic Excel workbook using hard-coded mock data -- without needing a live
Salesforce connection. Run it whenever you want to inspect chart layout, sheet
structure, or styling changes to the order status report workbook before wiring
up the real Salesforce pipeline. It produces the exact same `.xlsx` format as
the production `order_status_report.py` script, so what you see here is what
the real report will look like.

---

## Table of Contents

- [What This Script Does](#what-this-script-does)
- [Prerequisites](#prerequisites)
- [Running the Script](#running-the-script)
- [CLI Arguments](#cli-arguments)
- [Output Files](#output-files)
- [How the Mock Data Works](#how-the-mock-data-works)
- [Troubleshooting](#troubleshooting)
- [Security and Data Notes](#security-and-data-notes)
- [Related Files](#related-files)
- [Glossary](#glossary)

---

## What This Script Does

Each time you run `prototype_excel_chart.py` it:

1. Builds a **mock Summary DataFrame** (a table in Python memory) with eight
   weekly snapshots of AXP Netherlands order counts across eight statuses.
2. Builds a **mock Detail DataFrame** with approximately 7,628 fictional order
   records spread across ten fictional dealerships.
3. Passes both DataFrames into the production workbook builder
   (`build_order_report_workbook` from `sf_admin_utils.excel_report`).
4. Saves the resulting `.xlsx` file to the output directory you specify (or the
   current directory by default).
5. Applies an XML patch (`patch_chartsheet_drawing_extents`) that fixes a chart
   rendering issue in some versions of Excel.

The workbook contains the same sheets as the production report: Summary, a bar
chart sheet, and a Detail sheet.

---

## Prerequisites

| Requirement | Why |
| --- | --- |
| Python 3.12+ | The script uses modern type hints and standard library features. |
| Virtual environment activated | The script requires `pandas` and `openpyxl` from `requirements.txt`. |
| No Salesforce CLI needed | All data is hard-coded -- no network calls are made. |
| No `.env` file needed | No environment variables are required. |

### Installing Dependencies

From the project root with the virtual environment activated:

```bash
pip install -r requirements.txt
```

---

## Running the Script

```bash
# Generate workbook in the current directory
python scripts/prototype_excel_chart.py

# Generate workbook in a specific output folder
python scripts/prototype_excel_chart.py --out ./reports/order_status/
```

The script logs progress to stdout and writes one `.xlsx` file.

---

## CLI Arguments

| Argument | Required | Default | Description |
| --- | --- | --- | --- |
| `--out` | No | Current directory (`.`) | Directory where the `.xlsx` file is saved. Created automatically if it does not exist. |

---

## Output Files

| File | Description |
| --- | --- |
| `prototype_order_report.xlsx` | Excel workbook with Summary sheet, chart sheet, and Detail sheet. Written to the `--out` directory. |

The filename is always `prototype_order_report.xlsx` -- it is overwritten on
each run.

---

## How the Mock Data Works

The mock data is intentionally static and deterministic so every run produces
the same workbook, making it easy to compare changes.

### Summary Data

Eight weekly snapshots of order counts are hard-coded in the `_MOCK_COUNTS`
constant at the top of the script. Each row represents one week, and each
column represents one order status:

| Status | Meaning |
| --- | --- |
| `Submitted` | Order created, awaiting confirmation |
| `Confirmed` | Order confirmed by agency |
| `InProduction` | Order in production |
| `OnItsWay` | Order shipped |
| `AgentDelivered` | Delivered to agent |
| `HandoverCompleted` | Handed over to customer |
| `CancellationRequested` | Customer requested cancellation |
| `Cancelled` | Order cancelled |

The counts are based on the known Production shape (~7,628 total orders) with
plausible week-over-week movement.

### Detail Data

The Detail sheet contains approximately 7,628 fictional order records
generated with a fixed random seed (42 -- using `random.Random(42)` so the
seed is isolated to this function and does not affect other random operations).
A fixed seed means every run produces identical rows, which keeps the workbook
stable for review comparisons.

- Ten fictional Dutch dealerships from the `_MOCK_AGENCIES` list.
- Three fictional agents per agency.
- `CreatedDate` spread randomly across the prior 52 weeks.

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
| --- | --- | --- |
| `ModuleNotFoundError: No module named 'pandas'` | Virtual environment not activated or dependencies not installed. | Activate the venv and run `pip install -r requirements.txt`. |
| `ModuleNotFoundError: No module named 'sf_admin_utils'` | Package not installed in editable mode. | Run `pip install -e .` from the project root. |
| `ModuleNotFoundError: No module named 'openpyxl'` | Same as above -- `openpyxl` is in `requirements.txt`. | Run `pip install -r requirements.txt`. |
| Output directory not created | `pathlib.Path.mkdir` will create it automatically. If it fails, check disk permissions. | Check you have write access to the target folder. |
| Workbook opens but chart is blank | Chart XML patch not applied or Excel version issue. | Check the log -- `patch_chartsheet_drawing_extents` logs how many files it patched. |

---

## Security and Data Notes

- **No real data** -- all data in the workbook is fictional. The script never
  contacts Salesforce or any other network service.
- **Not for production use** -- this script is a design and review tool only.
  Use `order_status_report.py` for real Salesforce data.
- **Output files are safe to share** -- the workbook contains no PII (Personally
  Identifiable Information) and no real order data.

---

## Related Files

| File | Purpose |
| --- | --- |
| `src/sf_admin_utils/excel_report.py` | Production workbook builder. This script calls `build_order_report_workbook` from that module. |
| `scripts/order_status_report.py` | The production script that uses real Salesforce data. |
| `tests/test_prototype_excel_chart.py` | Unit tests for this script. |
| `docs/order_status_report_guide.md` | Guide for the production order status report. |

---

## Glossary

| Term | Meaning |
| --- | --- |
| DataFrame | A table of data in Python memory, provided by the `pandas` library. Think of it as a spreadsheet in code -- rows and columns that you can filter, sort, and transform. |
| `pandas` | A Python library for working with tabular data. Used here to build the Summary and Detail tables before passing them to the Excel builder. |
| `openpyxl` | A Python library for reading and writing Excel `.xlsx` files. Used by `excel_report.py` to create the workbook, sheets, charts, and styling. |
| Mock data | Fictional, hard-coded data used for testing and design review. It mimics the shape and scale of real data without containing any real information. |
| Fixed random seed | A starting value for a random number generator that ensures the same sequence of "random" numbers is produced every time. Here, seed 42 ensures the Detail sheet is identical on every run. |
| XML patch | A direct edit to the internal XML files inside the `.xlsx` archive. Applied here to fix a chart rendering issue in some Excel versions where drawing extents are not set correctly by `openpyxl`. |
| ChartSheet | An Excel sheet that contains only a chart (no cells). The Summary chart in this workbook uses a chartsheet. |
| PII | Personally Identifiable Information -- data that can identify an individual person. This script produces none. |
| Virtual environment (venv) | An isolated Python installation for one project. Prevents version conflicts between different projects on the same machine. |

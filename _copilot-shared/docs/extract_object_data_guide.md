# Extract Object Data Guide

`scripts/extract_object_data.py` lets you download every record from any
queryable Salesforce object (such as Account, Order, or a custom object like
`AgencyPrivacyData__c`) into a CSV file on your local machine. If the data
fits within Excel's limits, it also produces an `.xlsx` copy. You can either
pick the object interactively from a numbered list, or pass its name directly
on the command line. No Salesforce configuration beyond the CLI alias is
needed -- the script discovers all available fields automatically.

---

## What This Script Does

`scripts/extract_object_data.py` connects to a Salesforce org, discovers all
queryable objects, lets you pick one (or specify it on the command line), and
downloads every field into a local CSV file. If the data fits within Excel's
limits, an `.xlsx` copy is also produced.

**Key features:**

- **Interactive object picker** - browse all queryable objects if you don't
  know the API name.
- **Automatic field discovery** - queries the object's metadata to include
  every queryable field (excluding compound address/location fields that
  Salesforce does not allow in bulk SELECT).
- **Row-count warning** - warns you before downloading more than 10,000 rows.
- **CSV-first strategy** - always produces CSV (no row/column limits), then
  attempts Excel conversion.
- **Production guard** - prompts for confirmation when targeting a production
  org.

---

## Prerequisites

1. Python 3.12+ with the project virtual environment activated.
2. Salesforce CLI (`sf`) installed and on your PATH.
3. An authenticated Salesforce org alias (run `sf org login web --alias
   AXP_UAT` if not already authenticated).

---

## Quick Start

```powershell
# Activate the virtual environment
.\.venv\Scripts\Activate.ps1

# Download all Account records from UAT
python scripts/extract_object_data.py --sf-alias AXP_UAT --object Account

# Interactive mode - browse and pick an object
python scripts/extract_object_data.py --sf-alias AXP_UAT
```

---

## Command-Line Arguments

| Argument | Required | Default | Description |
| --- | --- | --- | --- |
| `--sf-alias` | Yes | - | Salesforce org alias (e.g. `AXP_UAT`, `AXP_PROD`). |
| `--object` | No | - | API name of the object to extract (e.g. `Account`, `Order`). If omitted, you pick interactively. |
| `--where` | No | - | Optional SOQL WHERE clause (without the `WHERE` keyword). Example: `"Status = 'Active'"`. |
| `--limit` | No | No limit | Maximum number of records to download. |
| `--output` | No | `output/<Object>_YYYY-MM-DD.csv` | Output file path. Use `.csv` or `.xlsx` extension. |
| `--yes` | No | `False` | Skip all confirmation prompts (production guard, row-count warning). |

---

## Examples

### Download all active Accounts

```powershell
python scripts/extract_object_data.py `
    --sf-alias AXP_UAT `
    --object Account `
    --where "IsActive__c = true"
```

### Limit to 500 records for a quick test

```powershell
python scripts/extract_object_data.py `
    --sf-alias AXP_UAT `
    --object Order `
    --limit 500
```

### Specify output path

```powershell
python scripts/extract_object_data.py `
    --sf-alias AXP_UAT `
    --object Contact `
    --output reports/contacts_export.xlsx
```

### Non-interactive (CI/scripting) mode

```powershell
python scripts/extract_object_data.py `
    --sf-alias AXP_PROD `
    --object AgencyPrivacyData__c `
    --yes
```

---

## Output Files

| File | Always produced? | Description |
| --- | --- | --- |
| `<Object>_YYYY-MM-DD.csv` | Yes | UTF-8 CSV with all downloaded records. |
| `<Object>_YYYY-MM-DD.xlsx` | When data fits | Excel workbook (skipped if rows exceed 1,048,575 or columns exceed 16,384). |

Cell values longer than 32,767 characters are truncated in the Excel version
(CSV retains full values).

---

## Exit Codes

| Code | Meaning |
| --- | --- |
| 0 | Success - files written. |
| 1 | Error - authentication failure, no fields found, or runtime error. |
| 2 | User declined - production confirmation or row-count warning rejected. |

---

## How It Works (Technical Summary)

1. **Authenticate** - calls `SalesforceSession(alias)` which uses `sf org
   display --json` under the hood.
2. **List objects** (if `--object` not given) - `GET /sobjects/` REST API.
3. **Discover fields** - `GET /sobjects/<Object>/describe/` REST API; filters
   out compound (address/location) fields.
4. **Estimate row count** - `SELECT COUNT() FROM <Object>` with any WHERE
   clause.
5. **Download records** - `query_all()` with automatic pagination (handles
   `nextRecordsUrl`).
6. **Write CSV** - standard library `csv.DictWriter`.
7. **Convert to Excel** - `openpyxl` with cell-length truncation if needed.

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
| --- | --- | --- |
| `RuntimeError: sf CLI not found` | Salesforce CLI not installed or not on PATH. | Install from <https://developer.salesforce.com/tools/salesforcecli> and restart your terminal. |
| `RuntimeError: Auth failed` | Org alias expired or not authenticated. | Run `sf org login web --alias AXP_UAT`. |
| `No queryable fields found` | Object has no fields your user can read, or the API name is wrong. | Check your Salesforce profile permissions and verify the object API name. |
| Excel file not produced | Data exceeds Excel limits (rows > 1,048,575 or columns > 16,384). | Use the CSV file instead, or add `--where`/`--limit` to reduce the result set. |
| `UserWarning: N cell(s) truncated` | One or more field values exceeded Excel's 32,767 character limit. | Use the CSV file for the affected fields -- it retains full values. |
| `User declined large download` (exit code 2) | Row count exceeded the 10,000 warning threshold and you typed `n`. | Add `--yes` to skip the confirmation, or use `--where`/`--limit` to reduce row count. |
| `ModuleNotFoundError: No module named 'sf_admin_utils'` | Virtual environment not activated or package not installed. | Run `pip install -e .` from the project root. |

---

## Security and Data Notes

- **Downloaded data may contain PII** (Personally Identifiable Information) --
  names, email addresses, phone numbers, and other personal fields depending on
  which Salesforce object you extract. Store output files securely and do not
  share them beyond their intended audience.
- **Production guard** -- when `--sf-alias` contains "prod" (case-insensitive),
  the script prompts for confirmation before proceeding. Use `--yes` only in
  automated/scripted contexts where you have already verified the intent.
- **CSV and Excel files are not committed to git** -- `output/` is listed in
  `.gitignore`. Never commit extracted data files.
- **Read-only** -- this script only runs SELECT queries. It never creates,
  updates, or deletes any Salesforce records.

---

## Related Files

| File | Purpose |
| --- | --- |
| `src/sf_admin_utils/data_export.py` | Core library -- object listing, field discovery, download, CSV/Excel writing. |
| `tests/test_data_export.py` | Unit tests for the library module. |
| `tests/test_extract_object_data.py` | Unit tests for the CLI script. |
| `requirements/REQ-H-object-data-extract/requirements.md` | Functional requirements document. |

---

## Glossary

| Term | Meaning |
| --- | --- |
| Salesforce CLI (`sf`) | The official command-line tool for Salesforce. Used here for authentication -- it holds your session securely in the OS keychain so no passwords appear in scripts. |
| Org alias | A short name you give to a logged-in Salesforce org (e.g. `AXP_UAT`). Used instead of typing a full URL each time. |
| SOQL | Salesforce Object Query Language -- Salesforce's version of SQL for querying its database. Example: `SELECT Name FROM Account`. |
| Object | A Salesforce "table" -- for example, `Account`, `Order`, or `AgencyPrivacyData__c`. Standard objects come built in; objects ending in `__c` are custom ones added by your organisation. |
| `__c` suffix | Marks a custom object or field created specifically for your Salesforce organisation, as opposed to a standard built-in one. |
| Field | A column within a Salesforce object -- for example, `Name`, `Email`, `Status`. |
| Compound field | A Salesforce field that groups multiple sub-fields (e.g. `BillingAddress` contains street, city, country). These cannot be queried directly in bulk and are automatically excluded. |
| `describe` endpoint | A Salesforce REST API call that returns the list of all fields for a given object, including their data types. Used by this script for automatic field discovery. |
| CSV | Comma-Separated Values -- a plain-text file format readable by Excel, Google Sheets, and most data tools. |
| Excel limits | Excel supports a maximum of 1,048,576 rows and 16,384 columns per sheet, and a maximum of 32,767 characters per cell. |
| PII | Personally Identifiable Information -- data that can identify an individual person, such as name, email, or phone number. |
| Virtual environment (venv) | An isolated Python installation for one project. Prevents version conflicts between different projects on the same machine. |

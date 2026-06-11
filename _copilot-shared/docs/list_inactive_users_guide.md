# Beginner's Guide - List Inactive Salesforce Users

This guide explains how the `list_inactive_users.py` script works, what you need
before running it, and how each piece fits together. It is written for people who
are new to Python scripting and Salesforce administration.

---

## Table of Contents

- [What This Script Does](#what-this-script-does)
- [Prerequisites](#prerequisites)
- [Configuration Reference](#configuration-reference)
- [Running the Script](#running-the-script)
- [Code Walkthrough](#code-walkthrough)
- [Output](#output)
- [Troubleshooting](#troubleshooting)
- [Glossary](#glossary)

---

## What This Script Does

The script connects to a Salesforce org (UAT or Production), queries all active
users who have **not logged in** for a specified number of days, and reports them
in three ways:

1. **Console log** - one line per user (ID + last login date only).
1. **Summary stats** - buckets users by how long they have been inactive.
1. **Optional CSV report** - full details (username, email, profile, role,
   manager) written to a file path you supply with `--output`.

It is a **read-only** script - it never deactivates or modifies any user
accounts. The `--apply` flag exists for interface consistency with sibling
scripts that perform mutations but has no effect here (it logs a warning).

Typical use cases:

- Auditing user activity before a licence review.
- Identifying candidates for deactivation.
- Generating reports for security/compliance reviews.
- Producing a CSV for the user-management team to action.

---

## Prerequisites

| Requirement | Why |
| --- | --- |
| Python 3.12+ | The script uses modern type hints and standard library features. |
| Virtual environment activated | The script uses packages from `requirements.txt`. |
| Salesforce CLI installed | Authentication is delegated to the `sf` CLI. |
| CLI logged in to each org | One-time browser login per org; the CLI stores the session in the OS keychain. |
| Network access to Salesforce | Your machine must reach `*.salesforce.com` over HTTPS. |

### Installing Dependencies

From the project root:

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -e .
pip install -r requirements-dev.txt
```

---

## Configuration Reference

### Command-Line Arguments

| Argument | Required | Default | Purpose |
| --- | --- | --- | --- |
| `--sf-alias` | Yes | - | Salesforce CLI org alias (e.g. `AXP_UAT`, `AXP_PROD`). Identifies which org to query. |
| `--days` | No | `90` | Inactivity threshold in days. Users with no login in this many days are reported. |
| `--output` | No | - | Optional path to write a CSV report of matching users. |
| `--apply` | No | `False` | Accepted for consistency with sibling scripts; no effect on this read-only script. |

### Environment Variables

| Variable | Purpose |
| --- | --- |
| `LOG_LEVEL` | Optional. `DEBUG`, `INFO`, `WARNING`, `ERROR`. Default `INFO`. |

No passwords, security tokens, or private keys are stored in the project. The
Salesforce CLI holds the session in your operating-system keychain.

---

## Running the Script

```bash
# Basic -- find users inactive for 90+ days in UAT
python scripts/list_inactive_users.py --sf-alias AXP_UAT --days 90

# With CSV output
python scripts/list_inactive_users.py --sf-alias AXP_PROD --days 60 --output reports/inactive.csv
```

---

## Code Walkthrough

The script is organised into small, focused functions.

### Argument Parsing

| Function | Purpose |
| --- | --- |
| `parse_args()` | Parses `--org`, `--days`, `--output`, and `--apply` from the command line. |

### Date Calculation

| Function | Purpose |
| --- | --- |
| `_cutoff_iso()` | Calculates the cutoff timestamp (now minus N days) and formats it as ISO-8601 for SOQL. |
| `_parse_sf_datetime()` | Null-safe parser for Salesforce's `+0000` offset format. |

### Salesforce Query

| Function | Purpose |
| --- | --- |
| `find_inactive_users()` | Authenticates via the CLI alias, constructs the SOQL query using the cutoff timestamp, calls `query_all()` for paginated retrieval, and returns the matching records. |

#### SOQL Query Template

**SOQL** (Salesforce Object Query Language) is Salesforce's version of SQL - the
language used to ask Salesforce for data. If you've never used SQL before, think of
it as a structured question: "give me these columns from this table where this
condition is true."

The script pulls a richer field set than just usernames - relationship
"dot-walks" (e.g. `Profile.Name` means "get the Name field from the linked Profile
record") avoid follow-up queries:

```sql
SELECT Id, Username, Email, LastLoginDate,
       Profile.Name, UserRole.Name, Manager.Name, Manager.Email
FROM User
WHERE IsActive = TRUE
AND (LastLoginDate < {cutoff} OR LastLoginDate = NULL)
```

This finds:

- Active users whose last login is older than the cutoff date.
- Active users who have never logged in (`NULL` LastLoginDate).

### Flattening and CSV Output

| Function | Purpose |
| --- | --- |
| `_flatten_record()` | Converts nested relationship dicts into flat columns, with null-safe lookups for users with no manager / role / profile. |
| `write_csv()` | Writes the flattened records to a UTF-8 CSV with a stable column order. Creates parent directories automatically. |

### Summary Buckets

| Function | Purpose |
| --- | --- |
| `summarise()` | Counts users in three buckets: `never_logged_in`, `between_{days}_and_{2x_days}_days`, and `over_{2x_days}_days`. Buckets scale with the chosen threshold. |

### Main Orchestration

| Function | Purpose |
| --- | --- |
| `main()` | Parses arguments, configures logging, queries inactive users, logs each (ID + date), prints the summary, and optionally writes the CSV. |

### Privacy Consideration

The console log shows only user IDs and last login dates - not usernames or
emails - because that output often ends up in shared logs or screenshots. PII
(usernames, emails, manager details) only appears in the CSV file when you
explicitly request one with `--output`.

---

## Output

### Console / Stderr

Per-user lines plus a summary at the end. Example:

```text
2026-05-20 13:25:18 INFO     query_helpers -- Resolving session for alias=AXP_UAT
2026-05-20 13:25:22 INFO     query_helpers -- Connected to org AXP_UAT
2026-05-20 13:25:22 INFO     __main__ -- Found 54 inactive users for alias=AXP_UAT
2026-05-20 13:25:22 INFO     __main__ -- Inactive user id=0053H000003Lq5GQAS last_login=2026-01-23
...
2026-05-20 13:25:22 INFO     __main__ -- Summary for alias=AXP_UAT threshold=90 days:
2026-05-20 13:25:22 INFO     __main__ --   between_90_and_180_days                    18
2026-05-20 13:25:22 INFO     __main__ --   never_logged_in                            12
2026-05-20 13:25:22 INFO     __main__ --   over_180_days                              24
2026-05-20 13:25:22 INFO     __main__ --   TOTAL                                      54
```

### CSV File (when `--output` is supplied)

| Column | Source Field |
| --- | --- |
| `Id` | `User.Id` |
| `Username` | `User.Username` |
| `Email` | `User.Email` |
| `LastLoginDate` | `User.LastLoginDate` (ISO-8601, blank if never) |
| `ProfileName` | `User.Profile.Name` |
| `UserRoleName` | `User.UserRole.Name` |
| `ManagerName` | `User.Manager.Name` |
| `ManagerEmail` | `User.Manager.Email` |

Empty values are written as empty cells (not `None`).

### Exit Codes

| Code | Meaning |
| --- | --- |
| `0` | Script completed successfully. |
| Non-zero | An unhandled exception occurred (check stderr for details). |

---

## Troubleshooting

### `ConfigError: Required environment variable 'SF_UAT_ALIAS' is not set`

Copy `.env.example` to `.env` and ensure the alias variables are set.

### `ConfigError: Salesforce CLI (sf) not found on PATH`

Install the Salesforce CLI from
<https://developer.salesforce.com/tools/salesforcecli>, then open a fresh
Command Prompt so the updated PATH is picked up.

### `Have you run sf org login web --alias <alias>?`

Your CLI session for that alias has expired or never existed. Re-run:

```bash
sf org login web --alias AXP_UAT --instance-url https://test.salesforce.com
sf org login web --alias AXP_PROD
```

### `INVALID_SESSION_ID` during the SOQL query

The CLI token expired between when it was fetched and when the API call ran.
Re-authenticate as above and re-run the script.

### Script reports zero inactive users

- Verify the `--days` threshold is reasonable (e.g. 90, not 9000).
- Confirm you are querying the correct org (`--org uat` vs `--org prod`).
- In a freshly-refreshed sandbox, everyone may legitimately have recent logins.

### `ModuleNotFoundError: No module named 'sf_admin_utils'`

Ensure the package is installed in editable mode:

```bash
pip install -e .
```

### CSV is empty or has only a header

`find_inactive_users()` returned zero records. Check the console log - if the
"Found N inactive users" line shows N = 0, the query genuinely matched nothing.

---

## Glossary

| Term | Meaning |
| --- | --- |
| Salesforce CLI | The official `sf` command-line tool used here for authentication. |
| CLI alias | A short name you assign to a logged-in org (e.g. `AXP_UAT`) for easy reference. |
| SOQL | Salesforce Object Query Language - SQL-like syntax for querying Salesforce data. |
| Dot-walk | SOQL syntax (e.g. `Profile.Name`) that pulls fields from a parent record in one query. |
| User object | A standard Salesforce object representing a login account. |
| LastLoginDate | The timestamp of the user's most recent login to Salesforce. |
| IsActive | Boolean field indicating whether a user account is active or deactivated. |
| PII | Personally Identifiable Information - data that can identify an individual. |
| Dry run | Running a script without making changes, to preview what would happen. |

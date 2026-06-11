# User Status Report Guide

This guide explains how to run `scripts/user_status_report.py` - a weekly
report script that queries Salesforce **User** records (the Salesforce object
that represents user accounts), tracks **IsActive** status changes (`True`
means the user can log in; `False` means the account is deactivated), identifies
users with stale logins (no login for 60+ days), generates an Excel workbook,
and emails a formatted summary to a defined distribution list.

The documentation is written for readers who are new to Python, Salesforce, and
command-line tools. Every technical term is explained on first use.

---

## Table of Contents

- [What This Script Does](#what-this-script-does)
- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
- [Recipient Configuration](#recipient-configuration)
- [Running the Script](#running-the-script)
- [All CLI Arguments](#all-cli-arguments)
- [How Snapshots Work](#how-snapshots-work)
- [The Excel Workbook](#the-excel-workbook)
- [Email Templates](#email-templates)
- [Output Files](#output-files)
- [Exit Codes](#exit-codes)
- [Scheduling with Windows Task Scheduler](#scheduling-with-windows-task-scheduler)
- [Troubleshooting](#troubleshooting)
- [Security and Data Handling](#security-and-data-handling)
- [Key Concepts for Beginners](#key-concepts-for-beginners)

---

## What This Script Does

Each time you run `user_status_report.py` it:

1. Connects to Salesforce and queries all User records (Id, IsActive, Username,
   Name, Profile.Name, LastLoginDate).
2. Saves a dated JSON snapshot (a saved copy of the data) of every user to
   `output/user_snapshots/<ORG_ALIAS>/`.
3. Compares the new snapshot against the previous one to find users whose
   `IsActive` status changed since the last run (the "delta").
4. Identifies "stale" users - those who have not logged in for more than 60 days
   (configurable with `--stale-days`) or have never logged in.
5. Generates an Excel workbook (`.xlsx`) with six sheets - Summary, Chart-Line,
   Chart-Bar, Detail, Stale Logins, and Notes.
6. Emails the report to everyone in `config/user_report_recipients.txt`.

Run it weekly to monitor licence usage and identify users who should be
deactivated.

---

## Prerequisites

Before running this script you need:

- **Python 3.12+** installed and available on your PATH.
- A **virtual environment** (`.venv`) with dependencies installed - run
  `setup.bat` if you have not done this already.
- **Salesforce CLI** (`sf`) installed and logged in to the target org. Run
  `sf org display --target-org AXP_PROD` to verify your session is active.
- A `.env` file in the project root with these variables set:

  ```ini
  SMTP_HOST=your-ford-smtp-relay.ford.com
  SMTP_PORT=25
  REPORT_FROM_ADDRESS=your-team@ford.com
  ```

- A recipients file at `config/user_report_recipients.txt` (see
  [Recipient Configuration](#recipient-configuration)).

---

## Environment Setup

1. Copy `.env.example` to `.env` and fill in the SMTP values.
2. Copy `config/user_report_recipients.txt.example` to
   `config/user_report_recipients.txt` and add real email addresses.
3. Activate your virtual environment:

   ```powershell
   .\.venv\Scripts\Activate.ps1
   ```

---

## Recipient Configuration

Create `config/user_report_recipients.txt` with one email address per line.
Lines starting with `#` are comments. Lines starting with `cc:` are CC
recipients.

```text
# User Status Report distribution list
manager@ford.com
team-lead@ford.com
cc: analyst@ford.com
```

---

## Running the Script

### Basic run (Production org)

```powershell
python scripts/user_status_report.py --sf-alias AXP_PROD
```

### Dry run (no email sent)

```powershell
python scripts/user_status_report.py --sf-alias AXP_PROD --dry-run
```

### Custom stale threshold (90 days)

```powershell
python scripts/user_status_report.py --sf-alias AXP_PROD --stale-days 90
```

### Automated run (no prompts, via Outlook)

```powershell
python scripts/user_status_report.py --sf-alias AXP_PROD --use-outlook --yes --quiet
```

---

## All CLI Arguments

| Argument | Type | Default | Purpose |
| --- | --- | --- | --- |
| `--sf-alias ALIAS` | string | *(required)* | Salesforce CLI org alias (e.g. `AXP_PROD`). |
| `--output-dir DIR` | path | `output/user_snapshots` | Directory for snapshot JSON and Excel files. |
| `--retain-weeks N` | integer | `12` | Prune snapshots older than this many weeks. |
| `--stale-days N` | integer | `60` | Days of inactivity before a user appears in the Stale Logins sheet. |
| `--format {text,csv}` | choice | `text` | Email body format. |
| `--recipients PATH` | path | `config/user_report_recipients.txt` | Path to the email recipients file. |
| `--dry-run` | flag | off | Generate report and workbook but do not send email. |
| `--yes` | flag | off | Skip interactive confirmation and frequency prompts. |
| `--quiet` | flag | off | Suppress console report output (email and workbook still generated). |
| `--use-outlook` | flag | off | Send email via Outlook 365 COM automation instead of SMTP relay. Requires `pywin32` and Outlook installed. |
| `--email-intro PATH` | path | `config/user_report_email_intro.txt` | Path to the first-run email body template. |
| `--email-update PATH` | path | `config/user_report_email_update.txt` | Path to the update (subsequent run) email body template. |

---

## How Snapshots Work

Each run produces a JSON file named `snapshot_<YYYY-MM-DD>.json` inside
`output/user_snapshots/<ORG_ALIAS>/`. The script automatically:

- **Creates** the snapshot directory if it does not exist.
- **Never overwrites** existing snapshots - each date gets its own file.
- **Prunes** snapshots older than `--retain-weeks` (default 12 weeks).
- **Warns** you if you run more than once per week (unless `--yes` is passed).

Snapshots are used to detect week-over-week `IsActive` changes and to build
the multi-week Summary trend in the Excel workbook.

---

## The Excel Workbook

The workbook (`user_status_report_<YYYY-MM-DD>.xlsx`) contains:

| Sheet | Content |
| --- | --- |
| **Summary** | Weekly pivot: Active vs Inactive user counts over time, with week-over-week variance columns using traffic-light conditional formatting. |
| **Chart-Line** | Stacked line chart showing the Active/Inactive trend. |
| **Chart-Bar** | Stacked column chart showing composition at each snapshot. |
| **Detail** | All User records from the latest snapshot (Id, IsActive, Username, Name, Profile, LastLoginDate). |
| **Stale Logins** | Users with no login for > *stale_days* days or who have never logged in. Sorted by DaysSinceLogin descending. Dark-red header signals action required. |
| **Notes** | Workbook metadata (date range, snapshot count). |

---

## Email Templates

The script uses plain-text template files for the email body so business users
can customise the wording without touching Python code.

- **First run** (no previous snapshot exists): uses the `--email-intro` template.
- **Subsequent runs** (previous snapshot found): uses the `--email-update`
  template.

If the template file is missing, the script falls back to the formatted report
text.

Templates support these placeholder variables (wrapped in `{braces}`):

| Placeholder | Value |
| --- | --- |
| `{run_date}` | Today's date in ISO format (e.g. `2026-06-02`). |
| `{org_alias}` | The Salesforce org alias (e.g. `AXP_PROD`). |
| `{total_count}` | Total number of users queried. |
| `{stale_count}` | Number of users with stale logins. |
| `{stale_days}` | The stale-days threshold used for this run. |
| `{changed_count}` | Number of users whose IsActive status changed since the last run. |

---

## Output Files

After a successful run:

```text
output/user_snapshots/AXP_PROD/
+-- snapshot_2026-05-26.json
+-- snapshot_2026-06-02.json
+-- user_status_report_2026-06-02.xlsx
```

---

## Exit Codes

| Code | Meaning |
| --- | --- |
| 0 | Success - report generated and emailed. |
| 1 | Error - authentication failure, SMTP error, missing recipients, disk error. |
| 2 | User declined - frequency prompt or Production confirmation. |

---

## Scheduling with Windows Task Scheduler

To run automatically every Monday at 08:00:

1. Open Task Scheduler -> Create Basic Task.
2. Set the trigger to **Weekly**, Monday, 08:00.
3. Action: **Start a program**.
4. Program: `C:\Users\<you>\Documents\...\Salesforce\.venv\Scripts\python.exe`
5. Arguments: `scripts/user_status_report.py --sf-alias AXP_PROD --yes --quiet`
6. Start in: `C:\Users\<you>\Documents\...\Salesforce`

Pass `--yes` and `--quiet` so the script runs non-interactively.

---

## Troubleshooting

| Problem | Solution |
| --- | --- |
| `RuntimeError: auth failed` | Run `sf org display --target-org AXP_PROD` to refresh your session. |
| `FileNotFoundError: Recipients file not found` | Create `config/user_report_recipients.txt` - see [Recipient Configuration](#recipient-configuration). |
| `ConnectionError: Failed to connect to SMTP relay` | Check `SMTP_HOST` and `SMTP_PORT` in `.env`. Verify network connectivity. |
| `REPORT_FROM_ADDRESS not set` | Add `REPORT_FROM_ADDRESS=your-email@ford.com` to `.env`. |
| `User declined` (exit code 2) | You ran the script within 7 days of the last run. Pass `--yes` to skip. |
| Outlook send failed (with `--use-outlook`) | Ensure Outlook is running and `pywin32` is installed in the virtual environment. |

---

## Security and Data Handling

- **No secrets in code** - SMTP settings come from `.env` (environment
  variables), and the Salesforce org alias comes from the `--sf-alias`
  command-line argument.
- **Usernames are PII-adjacent** - logged only at DEBUG level; only counts
  appear at INFO.
- **Snapshot files** contain usernames and profile names - they must not be
  committed to git. The `output/` directory is in `.gitignore`.
- **Recipients file** contains email addresses - also excluded from git.
- **Production guard** - when targeting a Production org without `--yes`, the
  script prompts for confirmation before sending.

---

## Key Concepts for Beginners

| Term | Meaning |
| --- | --- |
| **CLI** | Command-Line Interface - running programs by typing commands in a terminal. |
| **Salesforce org** | A Salesforce environment (e.g. Production, UAT, SIT). |
| **Org alias** | A short nickname for a Salesforce org (e.g. `AXP_PROD`). |
| **SOQL** | Salesforce Object Query Language - Salesforce's version of SQL for querying data. |
| **Snapshot** | A dated copy of all User records saved as JSON, used for comparison. |
| **Delta** | The difference between two snapshots (what changed). |
| **IsActive** | A Salesforce User field - `True` means the account can log in; `False` means deactivated. |
| **Stale user** | An active user who has not logged in for more than the threshold number of days. |
| **SMTP relay** | A mail server that forwards email - Ford's internal relay sends without authentication. |
| **Dry run** | A test run that does everything except actually send the email. |
| **PII** | Personally Identifiable Information - names, emails, phone numbers. |
| **COM automation** | A Windows technology that lets one program control another. `--use-outlook` uses COM to tell Outlook to send an email on your behalf. |
| **Email template** | A plain-text file with placeholder variables (like `{run_date}`) that the script fills in before sending. Allows business users to customise the email body without editing Python code. |

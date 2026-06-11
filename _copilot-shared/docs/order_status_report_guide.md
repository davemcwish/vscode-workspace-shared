# Order Status Report Guide

This guide explains how to run `scripts/order_status_report.py` - a weekly
report script that queries Salesforce **Order** records (the Salesforce object
that represents customer orders), tracks status changes over time, generates an
Excel workbook, and emails a formatted summary to a defined distribution list.

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

Each time you run `order_status_report.py` it:

1. Connects to Salesforce and queries all Order records (Id, OrderNumber,
   Status, CreatedDate, Agent name, Agency name).
2. Saves a dated JSON snapshot (a saved copy of the data) of every order to
   `output/order_snapshots/<ORG_ALIAS>/`.
3. Compares the new snapshot against the previous one to find orders whose
   Status changed since the last run (the "delta").
4. Counts new orders - those with Status `Submitted` created in the last 7 days
   (configurable with `--since`).
5. Groups open orders by Status and Agency so you can see where orders are
   stuck.
6. Generates an Excel workbook (`.xlsx`) with Summary, Chart-Line, Chart-Bar,
   Detail, and Notes sheets and saves it alongside the snapshot.
7. Emails the report to everyone in `config/order_report_recipients.txt`.

Run it weekly (Monday morning) to track progress toward closing all orders.

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

  Ask your team lead for the correct values if you are unsure.

- A `config/order_report_recipients.txt` file listing who should receive the
  report. See [Recipient Configuration](#recipient-configuration).

If you haven't set up the project yet, follow the [First-Time Setup](../README.md#first-time-setup)
instructions in the README before continuing.

---

## Environment Setup

The script reads three values from your `.env` file (a local configuration file
in the project root - see `.env.example` for a template):

```bash
# Ford internal SMTP relay hostname.
SMTP_HOST=smtp.internal.ford.com

# SMTP relay port (typically 25 for unauthenticated internal relay).
SMTP_PORT=25

# Sender address shown on the report email.
REPORT_FROM_ADDRESS=sf-admin-noreply@ford.com
```

> **What is SMTP?** SMTP (Simple Mail Transfer Protocol) is the standard
> protocol for sending email. Ford's internal network provides an SMTP relay
> server - a trusted server that delivers email on your behalf. No username or
> password is needed because it only accepts connections from inside the Ford
> network.

To set these values:

1. Copy `.env.example` to `.env` (if you haven't already):

   ```powershell
   Copy-Item .env.example .env
   ```

2. Open `.env` in a text editor and fill in the correct values for your
   environment. Ask your team lead if you are unsure of the SMTP hostname.

3. **Never commit `.env` to Git.** It is already listed in `.gitignore`.

---

## Recipient Configuration

The script reads email addresses from `config/order_report_recipients.txt`. This file
is **not committed to Git** (it is in `.gitignore` to protect email addresses).

A template is provided at `config/order_report_recipients.txt.example`. Copy and edit
it:

```powershell
Copy-Item config\order_report_recipients.txt.example config\order_report_recipients.txt
```

File format:

```text
# Lines starting with # are ignored.
# Plain lines are To: recipients.
# Lines starting with cc: are CC: recipients.

manager@ford.com
team-lead@ford.com
cc: analyst@ford.com
```

Rules:

- At least one To recipient must be present (the script exits with an error
  otherwise).
- CC recipients are optional.
- Blank lines and lines starting with `#` are ignored.

---

## Running the Script

### Activate the virtual environment first

```powershell
.venv\Scripts\activate
```

> **What is a virtual environment?** A virtual environment is an isolated folder
> of Python packages for this project. Activating it ensures the script uses the
> correct version of every dependency (like `pandas` and `openpyxl`).

### Basic run (recommended for weekly use)

```powershell
python scripts/order_status_report.py --sf-alias AXP_PROD
```

Expected output (to console):

```text
Weekly Order Status Report - 2026-06-02
=======================================
Run date : 2026-06-02
Period   : 2026-05-26 -> 2026-06-02
Org      : AXP_PROD
Total orders: 7,628

⚠  WARNING: 6,019 open orders exceed threshold of 500.

New Orders (Submitted since 2026-05-26): 4
  Order 00039001  |  Agency Alpha   |  Agent Smith
  ...

Status Changes since last run: 12
  Order 00038900  |  Agency Beta    |  Submitted -> Confirmed
  ...

Open Orders by Status:
  Submitted           |  15 orders  (Agency A: 8, Agency B: 7)
  Confirmed           |  73 orders  (...)
  InProduction        |  88 orders  (...)
  ...

2026-06-02 08:00:01 [INFO] Snapshot saved: snapshot_2026-06-02.json (7628 orders)
2026-06-02 08:00:02 [INFO] Email sent via SMTP relay smtp.internal.ford.com:25
2026-06-02 08:00:02 [INFO] Run summary: new=4, changed=12, open=6019, to=2, cc=1
```

### Dry run (test without sending email)

Use `--dry-run` to generate the report and print it to the console **without**
sending an email. Useful for checking the output before a real run:

```powershell
python scripts/order_status_report.py --sf-alias AXP_PROD --dry-run
```

### Skip confirmation prompts (for automation)

When running against a Production org (any alias containing "PROD"), the script
asks you to confirm before sending. Use `--yes` to skip prompts - required for
scheduled runs:

```powershell
python scripts/order_status_report.py --sf-alias AXP_PROD --yes
```

### Export a full detail CSV

Use `--export-detail` to write a CSV file containing every Order record
alongside the snapshot:

```powershell
python scripts/order_status_report.py --sf-alias AXP_PROD --export-detail
```

### Send via Outlook instead of SMTP

Use `--use-outlook` to send the email using Outlook 365 COM automation instead
of the SMTP relay. This is useful when the SMTP relay is unavailable or when
you need the email to appear in your Outlook Sent Items:

```powershell
python scripts/order_status_report.py --sf-alias AXP_PROD --use-outlook
```

> **Requires:** `pywin32` package and Microsoft Outlook installed on this
> machine. Only works on Windows.

### Custom email body template

Use `--email-intro` (first run) or `--email-update` (subsequent runs) to
provide a custom plain-text template file for the email body:

```powershell
python scripts/order_status_report.py --sf-alias AXP_PROD --email-update ./templates/custom.txt
```

### Automated run (no prompts, via Outlook, quiet)

```powershell
python scripts/order_status_report.py --sf-alias AXP_PROD --use-outlook --yes --quiet
```

### See all available options

```powershell
python scripts/order_status_report.py --help
```

---

## All CLI Arguments

| Argument | Type | Default | Purpose |
| --- | --- | --- | --- |
| `--sf-alias ALIAS` | string | *(required)* | Salesforce CLI org alias (e.g. `AXP_PROD`). |
| `--output-dir DIR` | path | `output/order_snapshots` | Directory where snapshot JSON and Excel files are saved. |
| `--retain-weeks N` | integer | `12` | Prune snapshots older than this many weeks. |
| `--since YYYY-MM-DD` | date | 7 days ago | Start of the "new orders" reporting window. |
| `--format {text,csv,html}` | choice | `text` | Report output format. |
| `--export-detail` | flag | off | Write a full CSV of all orders alongside the summary. |
| `--threshold N` | integer | `500` | Show a warning if open order count exceeds this value. |
| `--recipients PATH` | path | `config/order_report_recipients.txt` | Path to the email recipients file. |
| `--dry-run` | flag | off | Generate the report but do not send email. |
| `--yes` | flag | off | Skip interactive confirmation and frequency prompts. |
| `--quiet` | flag | off | Suppress console report output (email still sends). |
| `--use-outlook` | flag | off | Send email via Outlook 365 COM automation instead of SMTP relay. Requires `pywin32` and Outlook installed. |
| `--email-intro PATH` | path | `config/order_report_email_intro.txt` | Path to the first-run email body template. |
| `--email-update PATH` | path | `config/order_report_email_update.txt` | Path to the update (subsequent run) email body template. |

---

## How Snapshots Work

A **snapshot** is a JSON file that captures a complete list of all Salesforce
Order records at the moment the script ran. Snapshots are the mechanism that
allows the report to detect changes - it compares "what did orders look like last
week?" against "what do they look like now?".

### Snapshot file naming

Each run produces one file named after today's date:

```text
output/order_snapshots/AXP_PROD/
+-- snapshot_2026-05-26.json
+-- snapshot_2026-06-02.json   <- today's snapshot
```

### First run behaviour

On the very first run there is no previous snapshot to compare against. The
script will:

- Report zero status changes (because there is nothing to compare).
- Report new orders using the `--since` date window only.
- Save the first snapshot for next week's run.

After the first run, every subsequent run will produce a full delta comparison.

### Frequency prompt

If you run the script less than 7 days after the previous run, it will ask:

```text
Your last report was run on 2026-05-31. Are you sure you need one so soon? [y/N]
```

Type `y` to continue or press Enter to exit. Use `--yes` to skip this prompt in
scheduled runs.

### Snapshot retention

Old snapshots are automatically pruned (deleted) after `--retain-weeks` weeks
(default: 12 weeks). This keeps the `output/order_snapshots/` folder from
growing indefinitely.

### Corrupted snapshot recovery

If the most recent snapshot file is corrupted (contains invalid JSON), the script
logs a warning and automatically falls back to the next-oldest valid snapshot.
This means a single corrupted file will not break the weekly report.

---

## The Excel Workbook

The script always generates an Excel workbook named
`order_status_report_<YYYY-MM-DD>.xlsx` and saves it to the `--output-dir`.
The workbook is also attached to the email automatically.

The workbook contains these sheets:

| Sheet | Content |
| --- | --- |
| **Summary** | Weekly pivot: statuses as columns, snapshot dates as rows, order counts as cell values. Includes week-over-week variance columns with traffic-light conditional formatting. |
| **Chart-Line** | Stacked line chart showing the status trend over time. |
| **Chart-Bar** | Stacked column chart showing composition at each snapshot. |
| **Detail** | Full raw order list - OrderNumber, Status, CreatedDate, Agency, Agent. Same data as `--export-detail` but embedded in the workbook. |
| **Notes** | Workbook metadata (date range, snapshot count). |

> **What is a pivot table?** A pivot table reorganises data into a summary grid.
> In this case, rows are weekly snapshots and columns are order statuses, so each
> cell shows "how many orders were in this status on this date?" at a glance.

### Large-volume behaviour

The Detail sheet is designed to handle 100,000+ records efficiently. If the
number of orders exceeds the Excel row limit (1,048,575 rows per sheet), the
detail data is automatically split across multiple numbered sheets
(`Detail (1 of N)`, `Detail (2 of N)`, ...) and a warning is logged.

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
| `{total_count}` | Total number of orders queried. |
| `{open_orders}` | Number of open (non-closed) orders. |
| `{new_orders}` | Number of new orders since the `--since` date. |
| `{changed_count}` | Number of orders whose status changed since the last run. |

---

## Output Files

After a successful run:

```text
output/order_snapshots/AXP_PROD/
+-- snapshot_2026-06-02.json              - today's full order snapshot
+-- order_status_report_2026-06-02.xlsx   - Excel workbook
+-- orders_detail_2026-06-02.csv          - full CSV (only with --export-detail)
```

Snapshot files are retained for 12 weeks by default and then automatically
pruned.

> **Security note:** These files contain Agency and Agent names, which are
> confidential business data. They must **not** be committed to Git.
> `output/order_snapshots/` is already listed in `.gitignore`.

---

## Exit Codes

| Code | Meaning |
| --- | --- |
| `0` | Success - report generated and email sent (or `--dry-run` completed). |
| `1` | Error - authentication failure, SMTP error, missing recipients file, or other unexpected failure. Check the log for details. |
| `2` | User declined - you answered "N" to the frequency prompt or the Production confirmation, or `--yes` was not passed in a non-interactive run. |

In a scheduled run (`--yes`), only codes `0` and `1` are possible.

---

## Scheduling with Windows Task Scheduler

To run the report every Monday at 8:00 AM automatically:

1. Open **Task Scheduler** (search for it in the Windows Start menu).
2. Click **Create Basic Task** and follow the wizard:
   - Name: `Weekly Order Status Report`
   - Trigger: Weekly, Monday, 08:00
   - Action: Start a Program
   - Program: `C:\path\to\project\.venv\Scripts\python.exe`
   - Arguments:

     ```text
     scripts/order_status_report.py --sf-alias AXP_PROD --yes --quiet
     ```

   - Start in: `C:\path\to\project\` (the project root folder)
3. Tick **"Open the Properties dialog for this task when I click Finish"** and
   make sure the task runs whether the user is logged on or not, if needed.

> **Note:** `--yes` skips all interactive prompts so the task can run
> unattended. `--quiet` suppresses console output (the email is still sent).

---

## Troubleshooting

### Script says "SMTP_HOST not set"

Your `.env` file is missing the `SMTP_HOST` variable. Add it:

```bash
SMTP_HOST=smtp.internal.ford.com
```

Then re-run. See [Environment Setup](#environment-setup) for the full list of
required variables.

### Script says "No To recipients found"

Your `config/order_report_recipients.txt` file is empty or contains only `#` comments.
Add at least one email address (one per line, no `cc:` prefix).

### Script says "Recipients file not found"

The file `config/order_report_recipients.txt` does not exist. Copy the example:

```powershell
Copy-Item config\order_report_recipients.txt.example config\order_report_recipients.txt
```

Then edit it with the correct addresses.

### Script says "Failed to connect to SMTP relay"

Possible causes:

- You are not on the Ford internal network (or VPN). The SMTP relay is only
  accessible from inside Ford's network.
- The `SMTP_HOST` or `SMTP_PORT` value in `.env` is incorrect. Ask your team
  lead for the correct relay address.

### "No previous snapshot found - skipping delta calculation"

This is normal on the first run. The report will show zero status changes.
After the first run, a snapshot is saved and future runs will show deltas.

### Salesforce CLI login has expired

Re-authenticate:

```powershell
sf org login web --alias AXP_PROD
```

Then re-run the script.

### The frequency prompt appears unexpectedly

The script found a snapshot dated less than 7 days ago. If you genuinely need
to run again today (for example, after fixing a configuration error), type `y`
at the prompt, or add `--yes` to skip the check:

```powershell
python scripts/order_status_report.py --sf-alias AXP_PROD --yes
```

### Excel file is very large or slow to save

This can happen with 10,000+ orders. The script automatically skips per-row
alternating shading above 10,000 rows to keep file size manageable.

### Outlook send failed (with `--use-outlook`)

Ensure Microsoft Outlook is running and the `pywin32` package is installed in
your virtual environment. `--use-outlook` uses COM automation (a Windows
technology that lets one program control another) to tell Outlook to send on
your behalf. It only works on Windows.

---

## Security and Data Handling

- **Read-only Salesforce access.** The script only runs SOQL queries. It does
  not create, update, or delete any Salesforce records.
- **PII-adjacent data.** Agency names and Agent names are confidential business
  data. The script logs only record counts - never the full record list.
- **Email addresses.** Recipient addresses are read from a local file that is
  excluded from Git. Do not commit `config/order_report_recipients.txt`.
- **Snapshots.** JSON snapshot files contain full order data. They are stored in
  `output/order_snapshots/`, which is excluded from Git. Do not move them to a
  shared drive or public folder.
- **SMTP relay.** Ford's internal relay uses unauthenticated plaintext SMTP.
  This is standard practice for internal tools on Ford's network. The relay is
  not accessible from outside the network.
- **`.env` file.** Never commit `.env`. Use `.env.example` as a safe template
  (it contains only placeholder values).

---

## Key Concepts for Beginners

| Term | Plain-English Explanation |
| --- | --- |
| Snapshot | A dated file that records the complete state of all orders at a point in time. Used to calculate what changed between runs. |
| Delta | The difference between two snapshots - which orders changed status, and which are new. |
| SOQL | Salesforce Object Query Language - Salesforce's version of SQL (Structured Query Language), used to query records. |
| Org | A single Salesforce environment. "Production" is the live org with real data. |
| CLI alias | A short nickname you gave to a Salesforce org when you logged in (e.g. `AXP_PROD`). |
| SMTP | Simple Mail Transfer Protocol - the standard for sending email. Ford's internal SMTP relay accepts connections from inside the Ford network without a password. |
| Virtual environment | An isolated folder of Python packages for this project. Activate it with `.venv\Scripts\activate` before running any script. |
| `pandas` | A Python library for working with tabular data. This script uses it to build the pivot summary table in the Excel workbook. |
| `openpyxl` | A Python library for reading and writing Excel `.xlsx` files. This script uses it to create the workbook and insert the bar chart. |
| Pivot table | A summary grid that reorganises data. Here: rows = agencies, columns = statuses, values = order counts. |
| Dry run | A mode where the script generates the report and prints it but does not send any email. Safe for testing. |
| Exit code | A number the script returns when it finishes. `0` = success, `1` = error, `2` = user declined. |
| COM automation | A Windows technology that lets one program control another. `--use-outlook` uses COM to tell Outlook to send an email on your behalf. |
| Email template | A plain-text file with placeholder variables (like `{run_date}`) that the script fills in before sending. Allows business users to customise the email body without editing Python code. |

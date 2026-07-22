# Beginner's Guide - sf_admin_utils Package

This guide introduces the **sf_admin_utils** shared library that lives in
`src/sf_admin_utils/`. Every script in this repository imports from this package
rather than duplicating connection logic, configuration loading, or logging
setup. If you are new to Python, Salesforce APIs, or this project, start here.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Package Overview](#package-overview)
- [Module-by-Module Walkthrough](#module-by-module-walkthrough)
- [How Scripts Use This Package](#how-scripts-use-this-package)
- [Glossary](#glossary)
- [Troubleshooting](#troubleshooting)
- [Further Reading](#further-reading)

---

## Prerequisites

Before working with this code you need:

1. **Python 3.13+** installed and available on your PATH.
1. **Git** for cloning the repository.
1. The **Salesforce CLI** (`sf`) installed and on your PATH. Download it from
   <https://developer.salesforce.com/tools/salesforcecli>.
1. A **virtual environment** created and activated (see `setup.bat` or the
   project README).
1. All dependencies installed:

   ```bash
   pip install -e .
   pip install -r requirements-dev.txt
   ```

1. The **Salesforce CLI logged in** once per org. Each command opens a browser
   for you to sign in; the resulting session is stored in your operating-system
   keychain by the CLI itself:

   ```bash
   sf org login web --alias AXP_PROD
   sf org login web --alias AXP_UAT --instance-url https://test.salesforce.com
   ```

   - The alias is a short name you will use to refer to that org.
   - `--instance-url https://test.salesforce.com` is required for sandboxes.
     Production uses the default endpoint and does not need the flag.

1. A `.env` file (or real environment variables) mapping the logical org names
   used by the scripts to the CLI aliases. Copy `.env.example` to `.env`:

   | Variable | Purpose |
   | --- | --- |
   | `SF_UAT_ALIAS` | The CLI alias for the UAT (User Acceptance Testing) sandbox (e.g. `AXP_UAT`) |
   | `SF_PROD_ALIAS` | The CLI alias for Production (e.g. `AXP_PROD`) |
   | `SF_SIT_ALIAS` | The CLI alias for the SIT (System Integration Testing) sandbox (e.g. `AXP_SIT`) |
   | `LOG_LEVEL` | Optional - `DEBUG`, `INFO`, `WARNING`, `ERROR` (default `INFO`) |

   No passwords, security tokens, or private keys are stored anywhere in this
   project. The Salesforce CLI owns the credential lifecycle.

1. **Network access** to `test.salesforce.com` (UAT) or
   `login.salesforce.com` (Production). On a corporate network you may need
   VPN or proxy configuration.

### Verifying Your Setup

```bash
sf org list
```

You should see all three aliases marked **Connected**. If a session has expired,
re-run the appropriate `sf org login web ...` command.

---

## Package Overview

```text
src/sf_admin_utils/
+-- __init__.py            # Package marker; exports version string
+-- config.py              # Loads CLI alias mappings from environment variables
+-- download_helpers.py    # Timing, filenames, logging config, production guard
+-- logging_setup.py       # Configures consistent logging for all scripts
+-- query_helpers.py       # Auth via sf CLI, SOQL execution, pagination, chunking
+-- salesforce_client.py   # Builds authenticated Salesforce connections via the CLI
+-- security.py            # Path validation, alias validation, subprocess guard
```

The package is installed in **editable mode** (`pip install -e .`) so Python
finds it regardless of which directory you run a script from.

---

## Module-by-Module Walkthrough

### `__init__.py`

```python
__version__ = "0.1.0"
```

This file makes `src/sf_admin_utils/` a Python package. It exports a single
`__version__` string used for tracking which version is deployed.

---

### `config.py` - Configuration Loader

**Purpose:** Centralise all environment-variable access in one place so no
other module calls `os.getenv` directly.

#### Config Key Types

| Name | Kind | Description |
| --- | --- | --- |
| `OrgName` | Type alias | `Literal["uat", "prod", "sit"]` - restricts org values to known strings |
| `OrgConfig` | Frozen dataclass | Holds the logical org name and its CLI alias |
| `ConfigError` | Exception | Raised when a required variable is missing or empty |

#### Config Functions

| Function | What It Does |
| --- | --- |
| `_require_env(name)` | Reads one env var; raises `ConfigError` if blank or missing |
| `load_org_config(org)` | Returns an `OrgConfig` for `"uat"`, `"prod"`, or `"sit"` |
| `get_log_level()` | Returns `LOG_LEVEL` env var (default `"INFO"`) |

#### How Config Loading Works

1. On first import, `python-dotenv` loads `.env` if present (will not override
   real env vars already set).
1. `load_org_config("uat")` reads `SF_UAT_ALIAS` and wraps it in an `OrgConfig`.
   Likewise, `load_org_config("sit")` reads `SF_SIT_ALIAS`, and
   `load_org_config("prod")` reads `SF_PROD_ALIAS`.
1. If the variable is empty you get a clear `ConfigError` message telling you
   exactly which variable is missing.

#### Config Usage Example

```python
from sf_admin_utils.config import load_org_config

cfg = load_org_config("uat")
print(cfg.org)     # "uat"
print(cfg.alias)   # e.g. "AXP_UAT"
```

---

### `logging_setup.py` - Logging Configuration

**Purpose:** Give every script the same log format and destination (stderr) so
output is predictable and easy to search.

#### Logging Function

| Function | What It Does |
| --- | --- |
| `configure_logging(level=None)` | Sets up Python's root logger with a timestamp + level format |

#### How Logging Works

1. Call `configure_logging()` once at the top of your script's `main()`.
1. It reads the log level from `LOG_LEVEL` env var (or accepts an override).
1. All subsequent `logging.getLogger(__name__)` calls inherit this config.

#### Log Format

```text
2026-05-20 14:30:01,234 INFO     scripts.my_script - Connected to org=uat
```

#### Logging Usage Example

```python
import logging
from sf_admin_utils.logging_setup import configure_logging

configure_logging()
logger = logging.getLogger(__name__)
logger.info("Script started")
```

---

---

### `query_helpers.py` - Authentication, SOQL, and Pagination

**Purpose:** Provide a single, tested implementation of Salesforce CLI
authentication, SOQL query execution with automatic pagination, and common
SOQL utility functions. Both export scripts (`export_contract_pdfs.py`
and `export_quote_pdfs.py`) import from this module instead of
duplicating their own copies of these functions.

#### Query Helper Exports

| Name | Kind | What It Does |
| --- | --- | --- |
| `chunk_list(items, size)` | Function | Split a sequence into smaller batches of `size` items |
| `soql_id_list(ids)` | Function | Format a list of IDs as a SOQL `IN` clause string |
| `soql_escape(value)` | Function | Escape single quotes in strings for SOQL literals |
| `redact_sensitive_text(value)` | Function | Strip sid= session IDs from text before logging |
| `get_cli_org_auth(alias)` | Function | Run `sf org display --json` and return `(access_token, instance_url)` |
| `SalesforceSession` | Class | Hold credentials and refresh them on 401 errors (thread-safe) |
| `sf_get(token, url, path, ...)` | Function | Make an authenticated GET request with automatic 401 retry |
| `query_all(token, url, soql, ...)` | Function | Execute SOQL and follow `nextRecordsUrl` pagination to get all records |

#### Query Helpers Usage Example

```python
from sf_admin_utils.query_helpers import (
    SalesforceSession,
    query_all,
    chunk_list,
)

session = SalesforceSession("AXP_PROD")

records = query_all(
    session.access_token,
    session.instance_url,
    "SELECT Id, Name FROM Account LIMIT 10",
    session=session,
)

for batch in chunk_list(records, 50):
    print(f"Processing {len(batch)} records...")
```

---

### `download_helpers.py` - Timing, Filenames, Logging, and Production Guard

**Purpose:** Provide shared utility functions for timing operations, building
safe filenames, configuring logging, and prompting for confirmation before
running against Production orgs. These were previously duplicated in both
export scripts.

#### Download Helper Exports

| Name | Kind | What It Does |
| --- | --- | --- |
| `format_elapsed(seconds)` | Function | Convert seconds to human-readable string (`"2m 15.30s"`) |
| `timed(func)` | Decorator | Log how long a function takes to run |
| `timer(label)` | Context manager | Log how long a code block takes |
| `get_str(record, key)` | Function | Safely extract a string value from a dictionary |
| `safe_filename(value, max_len)` | Function | Convert text into a Windows-safe filename |
| `ensure_pdf_extension(name)` | Function | Append `.pdf` if not already present |
| `configure_logging(dir, file, tag)` | Function | Set up console + file logging for a script run |
| `confirm_production_run(alias, dry_run, yes)` | Function | Prompt for confirmation before live Production exports |
| `is_production_alias(alias)` | Function | Check if an alias looks like a Production org |

#### Example

```python
from sf_admin_utils.download_helpers import (
    configure_logging,
    confirm_production_run,
    safe_filename,
    timed,
)

configure_logging(output_dir, "my_script.log", "_my_handler")
confirm_production_run("AXP_PROD", dry_run=False, yes=False)

@timed
def do_work():
    filename = safe_filename("My Report: Q1/Q2 (Draft)", max_len=80)
    # Returns: "My Report_ Q1_Q2 (Draft)"
```

---

### `security.py` - Path and Input Validation

**Purpose:** Validate file paths, Salesforce CLI aliases, and other inputs
to prevent path-traversal attacks, command injection, and accidental writes
outside the project directory.

#### Security Exports

| Name | Kind | What It Does |
| --- | --- | --- |
| `resolve_safe_path(path)` | Function | Validate that a path is safe to use (no traversal) |
| `validate_salesforce_alias(alias)` | Function | Ensure an alias contains only safe characters |

---

## How Scripts Use This Package

A typical script follows this pattern:

```python
"""One-sentence description of what the script does."""

import logging

from sf_admin_utils.logging_setup import configure_logging
from sf_admin_utils.salesforce_client import build_client, with_retry

logger = logging.getLogger(__name__)


def main() -> None:
    configure_logging()
    sf = build_client("uat")

    results = with_retry(lambda: sf.query("SELECT Id FROM Account"))
    logger.info("Retrieved %d records", results["totalSize"])


if __name__ == "__main__":
    main()
```

---

## Glossary

| Term | Meaning |
| --- | --- |
| Org | A Salesforce instance (Production, UAT sandbox, or SIT sandbox) |
| Salesforce CLI | The official `sf` command-line tool, used here for authentication |
| CLI alias | A short name you assign to a logged-in org during `sf org login web` |
| Access token | A short-lived credential issued by Salesforce after login |
| Instance URL | The org-specific endpoint (e.g. `https://fordeurope--uat.sandbox.my.salesforce.com`) |
| Dataclass | A Python class that automatically generates `__init__`, `__repr__`, etc. |
| Frozen dataclass | A dataclass whose fields cannot be changed after creation (immutable) |
| Exponential backoff | Waiting progressively longer between retries (1 s, 2 s, 4 s) |
| Editable install | `pip install -e .` links the package so code changes take effect immediately |

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
| --- | --- | --- |
| `ConfigError: Required environment variable 'SF_UAT_ALIAS' is not set` | Missing `.env` file or variable | Copy `.env.example` to `.env` and fill in the alias names |
| `ConfigError: Salesforce CLI (sf) not found on PATH` | CLI not installed, or PATH not refreshed | Install the CLI, open a new shell |
| `Have you run sf org login web --alias <alias>?` | CLI session expired or never created | Re-run `sf org login web --alias <alias>` |
| `FileNotFoundError: [WinError 2]` when shelling out to `sf` | Windows: `sf` is actually `sf.cmd` | Already handled in `_resolve_sf_cli()` |
| `INVALID_SESSION_ID` mid-script | CLI token expired between fetch and API call | Re-authenticate and re-run |
| `ModuleNotFoundError: No module named 'sf_admin_utils'` | Package not installed | Run `pip install -e .` from the project root |
| `ConnectionError: Failed to resolve '*.salesforce.com'` | VPN/proxy not connected | Connect to corporate VPN or configure proxy |

---

## Further Reading

- [python-dotenv](https://saurabh-kumar.com/python-dotenv/)
- [Salesforce CLI documentation](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/)

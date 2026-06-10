---
applyTo: "src/**/*.py,scripts/**/*.py"
description: "Salesforce API usage and production-safety rules."
---

# Salesforce Integration Rules

## Authentication

- Authenticate using the Salesforce CLI (`sf org display --json`) via the
  `get_cli_org_auth(alias)` helper. Never construct raw credential strings
  by hand.
- Store the returned `(access_token, instance_url)` pair in a
  `SalesforceSession` object (defined in `salesforce_client.py`).
  This object exposes a `refresh()` method to re-authenticate when a
  session expires (HTTP 401).
- CLI org aliases (the short nickname given to an org at login) must be
  read from environment variables (`SF_UAT_ALIAS`, `SF_PROD_ALIAS`).
  Never hard-code them.

## HTTP Calls

- All Salesforce REST API calls must go through the `sf_get()` helper,
  which attaches the `Authorization: Bearer <token>` header, validates
  inputs, and handles 401 session-expiry by refreshing and retrying once.
- Do not use `simple_salesforce` or any third-party Salesforce client.
  Use the `requests` library directly via `sf_get()`.
- Use `requests.Session` for multi-step flows that require cookie persistence
  (e.g. frontdoor.jsp login followed by a Visualforce page request).

## Querying (SOQL)

- SOQL (Salesforce Object Query Language - Salesforce's version of SQL)
  queries must select only the fields actually needed:
  `SELECT Id, Name FROM Object__c`, never `SELECT *`-equivalent patterns.
- For unbounded result sets, use `query_all()` which follows
  `nextRecordsUrl` pagination automatically.
- Always escape string values inserted into SOQL with `soql_escape()` to
  prevent injection.

## Production Safeguards

- Any function that **writes** to Salesforce must accept `dry_run: bool = True`.
- When targeting the production org, require an explicit `confirm: bool = False`
  flag and log a WARNING showing the record count before proceeding.
- Bulk operations must batch records (use `chunk_list()` or `chunked()`);
  never loop single REST calls for >200 records.

## Rate Limits & Retries

- Wrap download and API calls with a retry helper using exponential back-off
  for transient HTTP 503/429 responses.
- Log API call counts at INFO level; warn at 80% of the daily API limit.

## Data Hygiene

- Never log full record payloads containing PII (Personally Identifiable
  Information - names, emails, phone numbers, etc.). Log record IDs and
  counts only.
- Redact `access_token` and session cookie values before writing to any
  log output. Use `redact_sensitive_text()` for URL strings.

## Testing Isolation

- **Never** hit real Salesforce orgs from tests. Mock `subprocess.run`
  during module load (to prevent CLI auth) and patch `requests.get` and
  `requests.Session` for all HTTP calls.
- Provide a `sf_env` fixture in `conftest.py` that sets the required
  `SF_UAT_ALIAS` and `SF_PROD_ALIAS` environment variables.

## Preferred Salesforce Access Pattern

Use the highest-level helper that fits the task:

1. For new scripts, use `build_client(org)` from
   `sf_admin_utils.salesforce_client`.
2. Inside shared library code, use lower-level helpers such as `sf_get()`,
   `query_all()`, and `get_cli_org_auth()` only when implementing or extending
   the Salesforce client layer itself.
3. Do not call `subprocess.run("sf ...")` directly from feature scripts unless
   no existing helper supports the required operation.

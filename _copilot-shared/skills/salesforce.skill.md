# Skill: Salesforce API & CLI

## Authentication

- Use Salesforce CLI (`sf org display --target-org <alias>`) to obtain access
  tokens. Never store tokens in code.
- Resolve CLI path via `shutil.which("sf")`; raise `RuntimeError` if absent.
- Org aliases defined in `.env` (`SF_UAT_ALIAS`, `SF_PROD_ALIAS`, `SF_SIT_ALIAS`).

## SOQL Queries

- SOQL (Salesforce Object Query Language) is Salesforce's SQL variant.
- Use `requests` library with session management for REST API calls.
- Endpoint pattern: `{instance_url}/services/data/<API_VERSION>/query?q=...`
  (the current version is defined by `API_VERSION` in `sf_admin_utils.query_helpers`; update that constant when upgrading the API version).
- Handle pagination via `nextRecordsUrl`.
- Chunk large ID lists into groups of 200 for `WHERE Id IN (...)` clauses.

## Key Salesforce Objects

| Object | Purpose |
| ------ | ------- |
| `AgencyPrivacyData__c` | Custom object linking agencies to Orders/Quotes |
| `ContentDocumentLink` | Junction linking files to records |
| `ContentVersion` | One version of an uploaded file; `VersionData` for binary |
| `Order` | Standard object; related to Account |
| `Quote` | Standard object; related to Opportunity -> Account |

## Download Patterns

- **Contract PDFs:** Direct binary download from `ContentVersion.VersionData`.
- **Quote PDFs:** Visualforce-rendered; requires `frontdoor.jsp` session then
  iframe extraction. Uses `requests.Session` for cookie persistence.

## Production Safety

- Always require `--yes` flag or interactive confirmation before Production runs.
- `--dry-run` mode must log the plan without downloading.
- Never mutate Production data from utility scripts (read-only operations only).
- Treat Salesforce record data (usernames, emails, IDs) as confidential.

## Validation Commands

```bash
pytest tests/test_salesforce_client.py --tb=short -q
mypy src/sf_admin_utils/salesforce_client.py
```

## Preferred Salesforce Access Pattern

Use the highest-level helper that fits the task:

1. For new scripts, use `build_client(org)` from
   `sf_admin_utils.salesforce_client`.
2. Inside shared library code, use lower-level helpers such as `sf_get()`,
   `query_all()`, and `get_cli_org_auth()` only when implementing or extending
   the Salesforce client layer itself.
3. Do not call `subprocess.run("sf ...")` directly from feature scripts unless
   no existing helper supports the required operation.

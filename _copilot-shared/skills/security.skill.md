# Skill: Security

## Secrets

- Never commit credentials, tokens, session IDs, or `.env` files.
- Use `python-dotenv` for local development; document vars in `.env.example`.
- Validate Salesforce aliases with `validate_salesforce_alias()` from
  `src/sf_admin_utils/security.py`.

## Path Safety

- Use `resolve_safe_path()` from `security.py` to prevent path traversal.
- Never write files outside the designated output directory.
- Reject paths containing `..` or crossing drive boundaries.

## Subprocess Safety

- Use `validate_subprocess_command()` from `security.py` for allow-list
  validation before spawning subprocesses.
- Never use `shell=True` with user-provided input.
- Never use `eval()` or `exec()`.

## Logging & Redaction

- Redact access tokens, session IDs, and passwords before logging.
- Treat Salesforce usernames, emails, and org IDs as confidential.
- Do not log full API responses containing record data.

## Dependencies

- Pin exact versions in `requirements*.txt`.
- Run `pip-audit` (or document internal review process) before adding packages.
- Verify new dependencies are actively maintained.

## Code Review Triggers

Flag any change that:

- Introduces a new outbound network call.
- Reads or writes files outside the project directory.
- Spawns subprocesses.
- Disables TLS verification.

## Generated Files

- Do not commit CSV, Excel, PDF, ZIP, or log files unless intentionally sanitized.
- Add generated output directories to `.gitignore`.

## Validation Commands

```bash
bandit -r src/ scripts/ -c pyproject.toml
detect-secrets scan
pytest tests/test_security.py --tb=short -q
```

# Skill: Security

## Secrets

- Never commit credentials, tokens, session IDs, or `.env` files.
- Use `python-dotenv` for local development; document required vars in `.env.example`.
- Validate tainted inputs with project-specific allowlist functions before use.

## Path Safety

- Use a `resolve_safe_path()` function (or equivalent) to prevent path traversal.
- Never write files outside the designated output directory.
- Reject paths containing `..` or crossing drive boundaries.

## Subprocess Safety

- Validate all CLI arguments and external inputs with an allowlist function
  before passing them to `subprocess.run` / `subprocess.Popen`.
- Never use `shell=True` with user-provided input.
- Never use `eval()` or `exec()`.
- The allowlist validator must return `match.group(0)` to break Cycode's
  intra-procedural taint chain.
- Add a local inline re-verification in the same function scope before calling
  `subprocess.run` (see `security.instructions.md` for the full pattern).

## Logging & Redaction

- Redact access tokens, session IDs, and passwords before logging.
- Treat user data (names, emails, IDs) as confidential unless explicitly public.
- Do not log full API responses containing record data.

## Dependencies

- Pin exact versions in locked requirements files.
- Run `pip-audit` (or the approved internal review process) before adding packages.
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
detect-secrets scan --baseline .secrets.baseline
pytest tests/ --tb=short -q
```

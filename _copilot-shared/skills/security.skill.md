---
name: security
description: "Human-facing security onboarding skill. Narrative overview of the repository's security expectations; the normative rules live in the instruction files."
owner: "TODO: team-or-DL"
lastReviewed: "2026-07-01"
reviewCadence: "quarterly"
---

# Skill: Security

> **Role & precedence.** This skill is *explanatory* (human onboarding). The
> **normative** rules and canonical code snippets live in:
>
> 1. `security.instructions.md` - canonical Cycode/SAST rules (source of truth)
> 2. `security.instructions.owasp-expanded.md` - broad OWASP/CWE coverage
> 3. `ci-cd.instructions.md` - pipeline hardening
>
> Where this summary and an instruction file differ, **follow the instruction
> file and the stricter rule.** Do not copy code snippets from here into the
> codebase - take them from `security.instructions.md` so they cannot drift.

## Secrets

- Never commit credentials, tokens, session IDs, certificates, or `.env` files.
- Use `python-dotenv` for local development only; document required vars in
  `.env.example` with placeholders. Production secrets come from the approved
  secrets manager.
- Validate tainted inputs with project-specific allow-list functions before use.

## Path Safety

- Use `resolve_safe_path()` (canonical in `security.instructions.md`) to prevent
  path traversal; it performs a **real containment check**, not a string prefix
  test.
- Never write files outside the designated output directory.
- Reject paths containing `..`, absolute paths, or paths crossing drive
  boundaries.

## Subprocess Safety

- Validate all CLI arguments and external inputs with an allow-list function
  before passing them to `subprocess.run` / `subprocess.Popen`.
- Always use list-form arguments; pass `shell=False` explicitly; set a timeout.
- Never use `shell=True` with user-provided input.
- Never use `eval()` or `exec()`.
- The allow-list validator must be **genuinely restrictive** - it must reject
  dangerous input (separators, `..`), not merely pass a value through.

> **Breaking Cycode's intra-procedural taint chain (what actually passes the
> gate).** Cycode analyses each function in isolation, so it does not follow a
> validator that lives in another module. Cycode-SAST is the authority here,
> and the idiom proven to clear its "Unsanitized dynamic input" findings across
> this codebase routes the value through a regex match and feeds
> **`match.group(0)`** - which the scanner treats as sanitised - into the sink:
>
> 1. **Subprocess / alias inputs:** the allow-list validator (e.g.
>    `validate_salesforce_alias`) is already genuinely restrictive, so returning
>    `match.group(0)` is simultaneously real validation *and* the taint break.
> 2. **File paths:** use a **two-step** pattern in the function that owns the
>    sink - call `resolve_safe_path()` first (the real `os.path.commonpath`
>    containment check, which is the actual traversal defence), then re-verify
>    the resolved path locally against a module-level `_SAFE_PATH_PATTERN` and
>    rebuild it from `match.group(0)` before it reaches `open()` / `zipfile` /
>    `shutil`.
>
> For paths the permissive regex is defence-in-depth, **not** the traversal
> defence - `resolve_safe_path()` is - so step 2 must always follow it and never
> replace it. If your Cycode tenant registers these validators as custom
> sanitizers the local re-verification becomes unnecessary; absent that
> configuration, the `match.group(0)` idiom is what actually passes the gate.
>
> See "Resolving Cycode False Positives Correctly" in `security.instructions.md`.

## Logging & Redaction

- Redact access/refresh tokens, session IDs, cookies, and passwords before logging.
- Treat user data (names, emails, IDs) and Salesforce records as confidential
  unless explicitly public.
- Log counts and generic event names at INFO; do not log full API responses,
  recipient lists, raw CLI output, or full file paths.

## Dependencies

- Pin exact versions in locked requirements files; commit lockfiles.
- Run `pip-audit` (or the approved internal review process) before adding packages.
- Verify new dependencies are actively maintained **and that the package
  actually exists as the intended project** - guard against typo-squats and
  AI-hallucinated / "slop-squatted" names.

## Code Review Triggers

Flag any change that:

- Introduces a new outbound network call.
- Reads or writes files outside the project directory.
- Spawns subprocesses or uses `eval` / `exec`.
- Disables TLS verification.
- Sends email or reads recipient lists.
- Parses XML/YAML/pickle, or extracts/rewrites archives and Office files.
- Edits a CI/CD workflow, action pinning, or pipeline permissions.
- Is authored by an AI assistant and touches any sink above.

## Generated Files

- Do not commit CSV, Excel, PDF, ZIP, or log files unless intentionally sanitized.
- Add generated output directories to `.gitignore`.

## AI / LLM-Generated Code (Copilot workstream)

- Verify AI-suggested packages exist and are the intended, maintained project.
- Have a human review AI-authored code that touches subprocess, file I/O,
  network, deserialization, XML/ZIP parsing, or auth.
- Never accept an AI-suggested SAST suppression without confirming it is a true
  false positive and recording the rationale.

## Validation Commands

```bash
bandit -r src/ scripts/ -c pyproject.toml
detect-secrets scan --baseline .secrets.baseline
pip-audit                      # or the approved internal review process
pytest tests/ --tb=short -q
```

> Note: `bandit` and `# nosec` suppressions do **not** affect Cycode findings.
> Fix Cycode issues at the code level, via sanitizer config, or with a documented
> Cycode suppression - not with bandit directives.

## OWASP/CWE Expanded Review

For broader application-security coverage, also apply
`security.instructions.owasp-expanded.md`.

In particular, flag changes involving:

- SQL, SOQL, query construction, or dynamic filters.
- Outbound HTTP requests or user-controlled URLs (SSRF).
- XML, YAML, pickle, marshal, archive extraction, or generated Office files.
- Browser DOM manipulation, HTML templates, JavaScript, CSS, or third-party scripts.
- CORS, CSP, cookies, CSRF, authentication, authorization, or localhost binding.
- SMTP, Outlook automation, email recipients, or generated report delivery.
- Large files, uploads, retries, subprocess timeouts, or other resource limits.
- Error handling that may expose stack traces, paths, tokens, or raw API responses.
- CI/CD workflows: unpinned actions, over-privileged tokens, or workflow injection
  (see `ci-cd.instructions.md`).

Prefer allow-list validation, safe framework APIs, secure defaults, timeouts,
redaction, and fail-closed behavior - and remember that a fix must provide **real
protection**, not merely satisfy the scanner.

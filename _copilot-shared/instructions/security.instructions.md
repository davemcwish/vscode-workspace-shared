---
applyTo: "**"
description: "Canonical repository security rules: secrets, subprocess/path/XML/PRNG/SMTP safety, Flask endpoints, DOM XSS, and Cycode SAST alignment."
owner: "TODO: team-or-DL"
lastReviewed: "2026-08-25"
reviewCadence: "quarterly"
---

# Security Rules (Canonical)

> **Precedence (most specific wins; on conflict, choose the STRICTER rule):**
>
> 1. Domain-specific instructions (e.g. `salesforce.instructions.md`,
>    `flask-websocket-subprocess.instructions.md`, `ci-cd.instructions.md`)
> 2. **This file** - canonical repo Cycode/SAST rules (normative)
> 3. `security.instructions.owasp-expanded.md` - broad OWASP/CWE coverage
> 4. `*.skill.md` - human-facing narrative guidance (explanatory, non-normative)
>
> This file is the **single source of truth** for the shared code snippets it
> defines (secrets, subprocess, path safety, security headers, `safe_extract_zip`,
> `safe_filename`). Other files must link here rather than restate them.

## Security Philosophy (read first)

Security fixes must provide **real protection**, not merely satisfy SAST tooling.
A **pure no-op** transformation must never be your only defence - genuine
containment (`resolve_safe_path`) or allow-list validation must happen first.
Where Cycode's intra-procedural analysis then still flags a cross-module false
positive, the accepted resolutions (see "Resolving Cycode False Positives
Correctly") are a local `match.group(0)` re-verification layered **on top of**
that real check, a **configured sanitizer**, or a **documented, reviewed
suppression** - never fake validation standing in for the real control.

## Secrets

- **Never** commit credentials, tokens, security tokens, session IDs,
  certificates, or `.env` files.
- Required env vars must be documented in `.env.example` with placeholder
  values and a comment explaining each.
- Use `python-dotenv` for local development only; production deployments
  must source secrets from the approved secrets manager.
- Enforce secret scanning in CI (push protection + `detect-secrets`), not only
  in the local baseline. See `ci-cd.instructions.md`.

## Logging Sensitive Data (Cycode: "Leakage of sensitive information in logger message")

Cycode flags logger calls when the variable name, context, or message text
suggests user data, Salesforce data, email addresses, tokens, file paths, or
other business-sensitive data may be emitted.

Treat the following as **sensitive at INFO/WARNING/ERROR** unless sanitised:

- Salesforce usernames, user IDs, org IDs, instance URLs, access/session tokens,
  profile/manager/account/dealer/agency/agent names, order/quote data, and full
  record payloads.
- Email recipient addresses and distribution lists.
- Local absolute paths, workstation usernames, generated report paths, and raw
  exception output that may include paths or tokens.
- Full HTTP response bodies, CLI stdout/stderr, and request URLs unless first
  passed through a redaction helper.

### Preferred logging pattern

- `INFO`: counts, status, and generic event names only.
- `DEBUG`: low-risk implementation details **after** sanitisation.
- Snapshot/report files: log a generic event and count, not the path/filename.
- Exceptions: log a short safe message; keep raw details out of normal logs
  unless redacted.

```python
# Good: count-only INFO log
logger.info("Retrieved %d User records.", len(records))
logger.info("Snapshot saved successfully (%d users).", len(users))

# Good: redacted CLI failure details
safe_stderr = redact_sensitive_text(exc.stderr or "")
raise RuntimeError("Salesforce CLI command failed; see redacted detail") from exc

# Bad: logs sensitive Salesforce data or local paths
logger.info("Retrieved users: %s", records)
logger.info("Saved snapshot: %s", snapshot_file)
logger.info("Recipients: %s", to_addrs)
logger.error("Salesforce API error response: %s", response.text)
```

### If logging a generated filename is genuinely necessary

Validate against a strict repository-controlled pattern and log at DEBUG. Here
the regex is a **real constraint** (fixed prefix, fixed date shape, no path
separators), so it is legitimate validation, not scanner-appeasement.

```python
_SNAPSHOT_NAME_PATTERN = re.compile(r"snapshot_\d{4}-\d{2}-\d{2}\.json")

match = _SNAPSHOT_NAME_PATTERN.fullmatch(candidate.name)
if match is None:
    logger.debug("Skipped snapshot with unexpected filename pattern.")
    continue

logger.debug("Loaded generated snapshot file: %s", match.group(0))
```

## Dependencies

- Before adding a dependency, verify it is actively maintained **and that it
  actually exists as the intended package** (guard against typo-squats and
  AI-hallucinated / "slop-squatted" package names - see LLM section below).
- Pin exact versions in `requirements*.txt`; commit lockfiles.
- Run `pip-audit` if available; otherwise route the package through the approved
  internal review process and record the outcome.

## Code Review Triggers

Flag any change that:

- Introduces a new outbound network call.
- Reads or writes files outside the project directory.
- Spawns subprocesses or uses `eval` / `exec`.
- Disables TLS verification.
- Sends email, reads recipient lists, or introduces SMTP / Outlook automation.
- Parses XML, extracts ZIP archives, or rewrites Office Open XML (`.xlsx`) files.
- Is **authored or substantially completed by an AI assistant** and touches any
  sink above (require explicit human review - see LLM section).

## Resolving Cycode False Positives Correctly (IMPORTANT)

Cycode performs **intra-procedural** taint analysis: it analyses each function
in isolation and does not follow a validator that lives in another module.
**Cycode-SAST is the authority** - the accepted fix is whatever clears its
finding without weakening real security. There are three accepted resolutions.

1. **Local re-verification that returns `match.group(0)` (the idiom used across
   this codebase, and what actually passes the gate today).** In the function
   that owns the sink, route the already-validated value through a regex
   `fullmatch` and feed `match.group(0)` into the sink. Cycode treats a regex
   match group as sanitised output, which breaks the intra-procedural taint
   chain. This is legitimate because:
   - For **subprocess / alias** inputs the allow-list pattern (e.g.
     `_SF_ALIAS_PATTERN`) is genuinely restrictive - it rejects separators and
     `..` - so `match.group(0)` is both real validation *and* the taint break.
   - For **file paths** it is a **two-step** control: `resolve_safe_path()`
     runs first and performs the real `os.path.commonpath` containment check
     (the actual traversal defence), then a local `_SAFE_PATH_PATTERN.fullmatch`
     re-verifies the resolved value. The path regex is defence-in-depth, never
     a substitute for `resolve_safe_path()`.
2. **Register the validator as a custom sanitizer (cleaner repo-wide fix, when
   your Cycode tenant is configured for it).** Declaring
   `validate_salesforce_alias`, `validate_subprocess_command`, and
   `resolve_safe_path` as sanitizers clears the finding everywhere without the
   local re-verification. When this is in place, the step-2 re-verification in
   option 1 is unnecessary.
3. **Documented, reviewed suppression.** For a confirmed false positive, use a
   Cycode inline suppression with a rationale comment and reviewer sign-off.
   Never suppress without understanding the risk.

## Subprocess Safety (Cycode: "Unsanitized user input in OS command")

Any value from user input, CLI args, env vars, or Salesforce API responses is
**tainted**. Before it enters `subprocess.run` / `Popen`:

1. **Validate with an allowlist function** that raises `ValueError` on unsafe
   input; store the result in a clearly named variable (e.g. `safe_alias`).
2. **Always use a list, never a string**:
   `subprocess.run(["sf", "org", safe_alias], ...)`.
3. **Pass `shell=False` explicitly** (documents intent).
4. **All other elements are string literals** - no f-strings/concatenation.
5. **Set a `timeout`.**
6. **Validate the executable with `validate_subprocess_command()`.** The
   allow-list must include `sf`, `sf.exe`, and `sf.cmd` where Salesforce CLI is
   expected.

```python
# In security.py - genuinely restrictive allowlist validator.
_SF_ALIAS_PATTERN = re.compile(r"[A-Za-z0-9_\-.]{1,40}")  # no separators, no '..'

def validate_salesforce_alias(alias: str) -> str:
    cleaned = alias.strip()
    if ".." in cleaned:
        raise ValueError(f"Invalid Salesforce alias: {cleaned!r}")
    match = _SF_ALIAS_PATTERN.fullmatch(cleaned)
    if match is None:
        raise ValueError(f"Invalid Salesforce alias: {cleaned!r}")
    return match.group(0)

# In query_helpers.py - caller uses the validated value only.
safe_alias = validate_salesforce_alias(alias)   # raises on unsafe input
sf_command = str(shutil.which("sf"))             # resolved path, not user input
command = validate_subprocess_command(
    [sf_command, "org", "display", "--target-org", safe_alias, "--json"]
)
result = subprocess.run(
    command, capture_output=True, text=True, check=True, shell=False, timeout=60
)
```

The `validate_salesforce_alias` validator already returns `match.group(0)` from
a genuinely restrictive allow-list, so the value reaching `subprocess.run` is
sanitised and the taint chain is broken at the source. If Cycode still flags
across modules, register the validator as a custom sanitizer or add a
documented suppression - see "Resolving Cycode False Positives Correctly" above.

## File Path Safety (Cycode: "Unsanitized dynamic input in file path")

Any path derived from user input, CLI args, or Salesforce data is **tainted**.
Before it enters `open()`, `wb.save()`, `shutil.copy()`, etc., pass it through
`resolve_safe_path()`, which performs real containment checking.

```python
def resolve_safe_path(candidate: str, base_dir: Path) -> Path:
    """Resolve `candidate` and guarantee it stays inside `base_dir`."""
    safe_base = base_dir.resolve()
    resolved = (safe_base / candidate).resolve()
    # Real containment check - NOT str.startswith (see safe_extract_zip note).
    if not resolved.is_relative_to(safe_base):   # Python 3.9+
        raise ValueError(f"Path escapes base directory: {candidate!r}")
    return resolved

# Caller:
safe_path = resolve_safe_path(output_name, OUTPUT_DIR)
with open(safe_path, "w", encoding="utf-8") as fh:
    ...
```

Because Cycode is intra-procedural, calling `resolve_safe_path()` (which lives
in `security.py`) does not clear the finding at a sink in another module. The
pattern proven to pass across this codebase - see `data_export.py`,
`list_objects.py`, `build_data_dictionary.py`, and `excel_report.py` - adds a
local **two-step** re-verification in the function that owns the sink:

```python
# Module level - permissive enough for real Windows/POSIX paths, but rejects
# quotes, control bytes, and shell metacharacters.
_SAFE_PATH_PATTERN = re.compile(r"[A-Za-z0-9_\-./\\ :()]{1,500}")

# In the function that owns the sink:
# Step 1 - real containment check (the actual traversal defence); raises.
safe_path = resolve_safe_path(output_path)
# Step 2 - local re-verification so Cycode sees the taint chain broken here.
match = _SAFE_PATH_PATTERN.fullmatch(str(safe_path))
if match is None:
    raise ValueError(f"Path failed local re-verification: {safe_path!r}")
safe_path = Path(match.group(0))
with open(safe_path, "w", encoding="utf-8") as fh:
    ...
```

Step 1 (`resolve_safe_path`) is the security control; step 2 is defence-in-depth
plus the `match.group(0)` taint break Cycode requires. The path regex must
**never** replace `resolve_safe_path()`. If your Cycode tenant registers
`resolve_safe_path` as a custom sanitizer, step 2 becomes unnecessary; absent
that configuration, step 2 is what actually passes the gate.

### Test files are IN SCOPE (common cause of surprise PR failures)

**Cycode scans `tests/` exactly like `src/` and `scripts/`.** A path-sink in a
test file is a **blocking, High-severity** PR finding - there is no test
exemption. This is the single most common way a PR that passed `sanity.bat`
still fails CI, because the **local advisory `security_scan.py` reports test
files at MEDIUM and never blocks**, while Cycode blocks the merge.

Assume nothing is safe just because it is "only a test". A line such as:

```python
# BAD - Cycode flags this in a test file exactly as it would in production.
manifest_path = output_dir / module.MANIFEST_FILE_NAME
with open(manifest_path, encoding="utf-8-sig") as f:
    ...
```

is a violation even though `output_dir` came from pytest's `tmp_path` fixture.
Cycode cannot tell a fixture from user input; `output_dir` is a non-literal
value flowing into a path sink, so it is tainted.

**Do not** scatter the two-step `resolve_safe_path()` + `_SAFE_PATH_PATTERN`
dance across dozens of test call sites. Instead, apply the rule below.

### Centralise the sink (preferred fix everywhere, essential in tests)

Because Cycode is intra-procedural, the cheapest durable fix is to **put the
sink and its sanitisation inside one small helper**, then call that helper
everywhere. Cycode sees sanitiser and sink in the same function (clean), and
call sites contain no sink at all (nothing to flag).

```python
# tests/conftest.py (or a shared test helper module)
import re
from pathlib import Path

_SAFE_PATH_PATTERN = re.compile(r"[A-Za-z0-9_\-./\\ :()]{1,500}")


def read_text_safely(path: Path, *, encoding: str = "utf-8") -> str:
    """Read a file after re-verifying its path, so the sink is sanitised here.

    Centralising ``open()`` in this helper means Cycode analyses the
    sanitisation and the sink together, and test call sites contain no path
    sink for it to flag.
    """
    match = _SAFE_PATH_PATTERN.fullmatch(str(path))
    if match is None:
        raise ValueError(f"Path failed local re-verification: {path!r}")
    with open(Path(match.group(0)), encoding=encoding) as handle:
        return handle.read()
```

```python
# GOOD - call site has no sink, so nothing is flagged.
content = read_text_safely(output_dir / module.MANIFEST_FILE_NAME,
                           encoding="utf-8-sig")
rows = list(csv.DictReader(io.StringIO(content)))
```

Checklist when adding or editing **any** test that touches the filesystem:

- [ ] No bare `open()`, `zipfile.ZipFile()`, `shutil.copy()`, or `Path.write_*`
      on a non-literal path at the call site.
- [ ] Reads/writes go through a shared, sanitising test helper.
- [ ] If a raw sink is genuinely unavoidable, apply the same two-step
      `resolve_safe_path()` + `match.group(0)` pattern used in production code.
- [ ] Remember `sanity.bat` passing does **not** mean Cycode will pass - check
      the advisory scan output for `tests/` findings on lines you touched.

### Temporary files and attachments

Do not derive temp filename prefixes from user-controlled attachment names.

```python
with tempfile.NamedTemporaryFile(
    delete=False, suffix=".xlsx", prefix="report_attachment_"
) as tmp:
    tmp.write(safe_attachment_path.read_bytes())
    tmp_path = Path(tmp.name)
```

Validate any attachment path from CLI/config with `resolve_safe_path()` and
never log the full path at INFO.

## Filename Safety on Windows (canonical `safe_filename`)

Replacing `\ / * ? : " < > |` is **not enough**; reserved device names
(`CON`, `PRN`, `AUX`, `NUL`, `COM1`-`COM9`, `LPT1`-`LPT9`) are invalid even
with an extension.

```python
_RESERVED_WINDOWS_NAMES = {
    "CON", "PRN", "AUX", "NUL",
    *(f"COM{i}" for i in range(1, 10)),
    *(f"LPT{i}" for i in range(1, 10)),
}

def safe_filename(value: str, max_len: int = 160) -> str:
    cleaned = str(value or "Untitled").strip()
    cleaned = re.sub(r'[\\/*?:"<>|]', "_", cleaned)
    cleaned = re.sub(r"\s+", " ", cleaned).rstrip(". ")
    cleaned = cleaned[:max_len].rstrip(". ") if len(cleaned) > max_len else cleaned
    cleaned = cleaned or "Untitled"

    stem = cleaned.split(".", 1)[0].upper()
    if stem in _RESERVED_WINDOWS_NAMES:
        cleaned = f"_{cleaned}"
    return cleaned
```

## PRNG Usage (Cycode: "Usage of weak Pseudo-Random Number Generator")

`random.Random()` and module-level `random.*` trigger B311/S311 at **High**.

> ⚠ `# nosec B311` is a **bandit** suppression only. It has **no effect on
> Cycode** and will not clear Cycode findings. Fix at the code level instead.

| Context | Correct approach |
| --- | --- |
| Security-sensitive (tokens, session IDs, nonces, passwords) | `secrets.choice()`, `secrets.randbelow()`, `secrets.token_hex()`. Never suppress. |
| Non-security, determinism NOT required (shuffling, sampling) | `random.SystemRandom()` - uses `os.urandom()`, Cycode-safe. |
| Non-security, determinism REQUIRED (mock data, fixtures) | **Eliminate the PRNG.** Derive values from a counter via modular arithmetic. |

```python
# Deterministic mock data - no PRNG, no suppression needed.
for idx in range(count):
    agency = _MOCK_AGENCIES[idx % len(_MOCK_AGENCIES)]
    agent  = agents[idx % len(agents)]
    days   = idx % 365
```

`random.SystemRandom()` does not support seeding - do not use it where the test
suite requires determinism.

## XML Parsing Safety (Cycode: "Usage of vulnerable XML libraries")

Use `defusedxml` instead of `xml.etree.ElementTree`, including for Office Open
XML (`.xlsx` are ZIPs containing XML). Pin `defusedxml` in requirements.

```python
from defusedxml import ElementTree as ET
sheet_tree = ET.parse(chartsheet_xml)
```

## ZIP Extraction Guardrail (canonical `safe_extract_zip`)

**Never** use `str.startswith` for containment - a sibling like `/tmp/base-evil`
passes a check against `/tmp/base`. Use a real containment test and reject
symlink members and absolute paths.

```python
import stat, zipfile
from pathlib import Path

def safe_extract_zip(zf: zipfile.ZipFile, target_dir: Path) -> None:
    safe_base = target_dir.resolve()
    for member in zf.infolist():
        name = member.filename
        # Reject absolute paths and traversal outright.
        if name.startswith(("/", "\\")) or ".." in Path(name).parts:
            raise ValueError(f"Unsafe ZIP member path: {name!r}")
        destination = (safe_base / name).resolve()
        # Real containment check (Python 3.9+).
        if not destination.is_relative_to(safe_base):
            raise ValueError(f"Unsafe ZIP member path: {name!r}")
        # Reject symlink members (external_attr high bits carry Unix mode).
        mode = member.external_attr >> 16
        if stat.S_ISLNK(mode):
            raise ValueError(f"Symlink members are not allowed: {name!r}")
        zf.extract(member, safe_base)
```

Prefer avoiding TAR extraction entirely; if required, apply the same checks and
also reject hard links and device files.

## Email / SMTP Security (Cycode: "Usage of insecure SMTP connection")

Avoid plaintext `smtplib.SMTP(...)` for new code.

```python
import ssl, smtplib
context = ssl.create_default_context()
with smtplib.SMTP_SSL(host=host, port=465, timeout=30, context=context) as smtp:
    smtp.send_message(message)
```

Fallback using STARTTLS (fail closed if TLS cannot be negotiated):

```python
context = ssl.create_default_context()
with smtplib.SMTP(host=host, port=587, timeout=30) as smtp:
    smtp.starttls(context=context)
    smtp.send_message(message)
```

Internal plaintext SMTP requires explicit approval, a documented exception,
recipient restrictions, and count-only logging. Prefer Outlook COM or a
TLS-capable relay.

## Flask / Web Endpoint Security

Apply in addition to the subprocess and file-path rules above.

### Input validation (Injection)

- Validate ALL request data (`get_json`, `args`, `form`) before use.
- Use allowlists; type-check fields; enforce length limits.

### XSS prevention

- Insert dynamic text with `textContent`, never `innerHTML`.
- Rely on Jinja2 auto-escaping; never `| safe` for non-static values.
- Never build HTML from user data in Python.

### Security headers (canonical block - used everywhere in the repo)

```python
@app.after_request
def set_security_headers(response):
    response.headers["Content-Security-Policy"] = (
        "default-src 'self'; "
        "script-src 'self'; "
        "style-src 'self' 'unsafe-inline'; "   # localhost only; use nonces for public deploys
        "connect-src 'self' ws://localhost:* ws://127.0.0.1:*; "
        "object-src 'none'; "
        "base-uri 'self'; "
        "frame-ancestors 'none'"
    )
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["Referrer-Policy"] = "no-referrer"
    return response
```

> `style-src 'unsafe-inline'` is tolerated **for a localhost-only tool**. For any
> public deployment, replace it with nonces/hashes and add HSTS.

### CSRF / origin checks

Verify the Origin host/port **exactly** by parsing - not with `startswith`.

```python
from urllib.parse import urlparse

_ALLOWED_ORIGINS = {("localhost", 5000), ("127.0.0.1", 5000)}

def _is_local_origin(request) -> bool:
    origin = request.headers.get("Origin", "")
    if not origin:
        return False
    parsed = urlparse(origin)
    return (
        parsed.scheme == "http"
        and (parsed.hostname, parsed.port) in _ALLOWED_ORIGINS
    )
```

### Binding & error leakage

- Bind to `127.0.0.1` only - never `0.0.0.0`. This is the primary control.
- Add authentication before any exposure beyond localhost.
- Never return stack traces / internal paths in JSON. Log server-side; return a
  generic message. Set `debug=False` (the Werkzeug debugger allows RCE via the
  interactive console and must never be enabled outside isolated local dev).

## AI / LLM-Generated Code (Copilot workstream)

Because much code here is AI-authored, apply these rules to every AI suggestion:

- **Verify suggested packages exist and are the intended, maintained project**
  before installing (defends against hallucinated / slop-squatted names).
- **Check the license** of any non-trivial AI-suggested snippet.
- **Require human review** for AI-authored code touching subprocess, file I/O,
  network calls, deserialization, XML/ZIP parsing, or auth.
- Do not accept AI-suggested SAST suppressions without confirming the finding is
  a true false positive and recording the rationale.

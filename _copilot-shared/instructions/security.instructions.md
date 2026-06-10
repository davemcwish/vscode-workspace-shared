---
applyTo: "**"
description: "Secrets handling and sensitive data rules."
---

# Security Rules

## Secrets
- **Never** commit credentials, tokens, security tokens, session ids,
  certificates, or `.env` files.
- Required env vars must be documented in `.env.example` with placeholder
  values and a comment explaining each.
- Use `python-dotenv` for local development only; production deployments
  must source secrets from the approved secrets manager.

## Logging
- Redact tokens, passwords, and session ids before logging.
- Treat Salesforce record data as confidential by default (see
  `salesforce.instructions.md`).

## Dependencies
- Before adding a dependency, verify it is actively maintained.
- Use the approved Ford security scanning process when available.
- If `pip-audit` is available in the environment, use it; otherwise document
  that the package must be reviewed through the approved internal process.
- Pin exact versions in `requirements*.txt`.

## Code Review Triggers
Flag any change that:
- Introduces a new outbound network call.
- Reads or writes files outside the project directory.
- Spawns subprocesses or uses `eval`/`exec`.
- Disables TLS verification.

## Subprocess Safety (Cycode SAST Rule: "Unsanitized user input in OS command")

Any value that originates from user input, CLI arguments, environment variables,
or Salesforce API responses is considered **tainted** by SAST tools (including
Cycode). Before that value enters a `subprocess.run` / `subprocess.Popen` call:

1. **Validate with an allowlist function** - call `validate_salesforce_alias()`
   for org aliases, or write an equivalent validator that raises `ValueError` on
   unsafe characters. The validated value must be stored in a clearly named
   variable (e.g. `safe_alias`) and only that variable used in the command list.
2. **The validator must return `match.group(0)`, not the original input**  - 
   Cycode's taint-flow analysis traces the original tainted value through
   function return values. Returning `match.group(0)` from the regex fullmatch
   ensures the return value is derived from the match object itself, which SAST
   tools treat as sanitised output, breaking the taint chain completely.
3. **Always use a list, never a string** - `subprocess.run(["sf", "org", safe_alias], ...)`
   not `subprocess.run(f"sf org {alias}", ...)`.
4. **Always pass `shell=False` explicitly** - it is the default, but making it
   explicit documents intent and satisfies SAST tools.
5. **All other elements must be string literals** - no f-strings, no
   concatenation, no variables other than the pre-validated input.

Example pattern (from `security.py` + `query_helpers.py`):

```python
# In security.py - validator returns match.group(0) to break taint chain
_SF_ALIAS_PATTERN = re.compile(r"[A-Za-z0-9_\-\.]{1,40}")

def validate_salesforce_alias(alias: str) -> str:
    cleaned = alias.strip()
    match = _SF_ALIAS_PATTERN.fullmatch(cleaned)
    if match is None:
        raise ValueError(f"Invalid Salesforce alias: {cleaned!r}")
    return match.group(0)  # ← derived from match object, not from `alias`

# In query_helpers.py - caller stores result in clearly named variable
safe_alias = validate_salesforce_alias(alias)   # raises ValueError if unsafe
sf_command = str(shutil.which("sf"))            # resolved path, not user input
command = [sf_command, "org", "display", "--target-org", safe_alias, "--json"]
result = subprocess.run(command, capture_output=True, text=True, check=True, shell=False)
```

This pattern satisfies Cycode's SAST rule at Critical severity.

> **Why `match.group(0)` and not `cleaned`?**
> Both values are identical at runtime. The difference is purely about SAST
> taint-flow analysis. `cleaned` is derived from `alias` (tainted input), so
> Cycode traces the taint forward through it. `match.group(0)` is derived from
> the regex match object - an independent value - so the taint chain stops here.

### If Cycode Still Flags After Cross-Module Validation

Cycode performs **intra-procedural** taint analysis. If the validator lives in
a separate module (e.g. `security.py`), Cycode may not follow the call far
enough to see `match.group(0)` and will still flag the caller.

**Fix:** Add a **local inline re-verification** inside the same function that
calls `subprocess.run`, reassigning `safe_alias` to `_m.group(0)` from a local
regex match:

```python
# Step 1 - cross-module validator (defence-in-depth, raises on bad input)
safe_alias = validate_salesforce_alias(alias)

# Step 2 - local inline re-verification so SAST sees match.group(0)
# in this function's own scope (breaks the taint chain intra-procedurally)
_m = re.fullmatch(r"[A-Za-z0-9_.@\-]{1,128}", safe_alias)
if _m is None:
    raise ValueError(f"Alias failed local re-verification: {safe_alias!r}")
safe_alias = _m.group(0)  # ← SAST sees a local match object, not tainted input

command = [sf_command, "org", "display", "--target-org", safe_alias, "--json"]
result = subprocess.run(command, capture_output=True, text=True, check=True, shell=False)
```

After this reassignment, `safe_alias` is derived from a **locally-created**
match object - Cycode's intra-procedural analysis can see the sanitisation
directly without needing cross-module tracing.

## File Path Safety (Cycode SAST Rule: "Unsanitized dynamic input in file path")

Any file path derived from user input, CLI arguments, or constructed from
Salesforce API data (e.g. object names, record IDs) is considered **tainted**
by Cycode. Before that path enters `open()`, `wb.save()`, `shutil.copy()`,
or any other file I/O call:

1. **Validate with `resolve_safe_path()`** - this ensures no path traversal
   (`../`) or escape from the allowed base directory. Store the result in a
   variable named `safe_path`.
2. **Add a local inline re-verification** - Cycode's intra-procedural analysis
   cannot follow cross-module calls. Re-verify in the same function scope:

```python
# Step 1 - cross-module validator (defence-in-depth, raises on bad path)
safe_path = resolve_safe_path(output_path)

# Step 2 - local inline re-verification so SAST sees the taint chain
# broken within this function's own scope (Cycode intra-procedural rule).
from pathlib import Path as _Path  # noqa: PLC0415

_SAFE_PATH_PATTERN = re.compile(r"[A-Za-z0-9_\-./\\ :()]{1,500}")
_m = _SAFE_PATH_PATTERN.fullmatch(str(safe_path))
if _m is None:
    raise ValueError(f"Path failed local re-verification: {safe_path!r}")
safe_path = _Path(_m.group(0))  # ← derived from match object, taint chain broken

with open(safe_path, "w", ...) as fh:
    ...
```

3. **The regex must be defined as a module-level constant** - use
   `_SAFE_PATH_PATTERN` to avoid recompilation on every call.
4. **The `from pathlib import Path as _Path` must be inline** - because the
   top-level `Path` import is in `TYPE_CHECKING` (annotation-only). The local
   import provides a runtime reference for constructing the sanitised path.

> **Why this pattern?** `resolve_safe_path()` provides real security (blocks
> traversal). The local regex + `_m.group(0)` provides SAST-tool-visible proof
> that the value passed to `open()` is derived from a match object, not from
> tainted input. Both are needed: one for actual safety, one for tooling.

## Generated Data Files

- Do not commit generated CSV, Excel, PDF, ZIP, log, or report files unless they
  are intentionally sanitized samples.
- Treat reports containing Salesforce usernames, emails, manager names, or user
  IDs as confidential.

- **Never** commit real usernames, personal directory paths, or
  workstation-specific paths in comments, docstrings, or example snippets.
- Use `<you>`, `<username>`, or `<your-path>` as placeholders.
- This includes Windows paths like `C:\Users\jsmith\...` - replace the username
  portion with a generic placeholder.

## PRNG Usage (Cycode SAST Rule: "Usage of weak Pseudo-Random Number Generator")

`random.Random()` and all module-level `random.*` functions trigger Cycode's
B311/S311 SAST rule at **High severity**. Cycode traces the PRNG taint from
the constructor to **every downstream call-site** (`.choice()`, `.randint()`,
etc.) and flags each one individually.

> ⚠ **`# nosec B311` does NOT satisfy Cycode SAST.**
> `# nosec` is a bandit suppression comment. It suppresses the local `bandit`
> scan in `sanity.bat` but has no effect on Cycode's own engine. If you add
> `# nosec B311` to all call-sites and push, Cycode will still report the
> violations as unresolved.

| Context | Correct approach |
| --- | --- |
| **Security-sensitive** (tokens, session IDs, nonces, passwords) | Use `secrets.choice()`, `secrets.randbelow()`, `secrets.token_hex()`. Never suppress. |
| **Non-security randomness where determinism is NOT required** (shuffling, sampling) | Use `random.SystemRandom()` - it uses `os.urandom()` internally and is Cycode-safe. |
| **Non-security randomness where determinism IS required** (mock data, test fixtures, prototype generation) | **Eliminate the PRNG entirely.** Derive values from a counter or index using modular arithmetic. This is fully deterministic, Cycode cannot flag it, and it requires no suppression. |

**Preferred pattern for deterministic mock data (no PRNG at all):**

```python
# Derive agency, agent, and date from the order counter.
# Modular arithmetic gives realistic variety without any PRNG.
# Every run produces identical results - no seed, no suppression needed.
for idx, _ in enumerate(range(count)):
    agency = _MOCK_AGENCIES[idx % len(_MOCK_AGENCIES)]
    agent  = agents[idx % len(agents)]
    days   = idx % 365
```

**If `random.SystemRandom()` is used (non-deterministic, but Cycode-safe):**

```python
rng = random.SystemRandom()  # Uses os.urandom() - Cycode-safe, no seed support
value = rng.choice(options)
```

Note: `random.SystemRandom()` does not support seeding. Do not use it when
the test suite requires `test_is_deterministic_across_calls` to pass.

**Bandit suppression reference** (local `sanity.bat` only, NOT Cycode):

The suppression comment `# nosec B311` on the instantiation line covers the
local `bandit` scan. It has no effect on Cycode. Do not rely on it to clear
Cycode SAST violations - use one of the code-level approaches above.

## Flask / Web Endpoint Security (OWASP)

When building Flask REST API endpoints (e.g. the JOSHUA frontend), apply these
rules in addition to the subprocess and file-path rules above.

### Input Validation (OWASP A05 - Injection)

- **Validate ALL request data** - `request.get_json()`, `request.args`,
  `request.form` - before use. Never trust client input.
- **Use allowlists** over denylists. If a parameter should be one of 8 script
  names, check `if value not in ALLOWED_SCRIPTS`.
- **Type-check** JSON fields: verify strings are strings, numbers are numbers.
- **Limit lengths** - reject excessively long strings before further processing.

### XSS Prevention (OWASP A05)

- **Use `textContent`** (not `innerHTML`) when inserting dynamic text in the
  frontend JavaScript.
- **Jinja2 auto-escapes by default** - never use `| safe` unless the content
  is trusted and static.
- **Never** construct HTML from user-submitted data in Python code. Use Jinja2
  templates with auto-escaping enabled.
- **Content-Security-Policy header** - set it even for localhost to catch issues
  early:

```python
@app.after_request
def set_security_headers(response):
    response.headers["Content-Security-Policy"] = (
        "default-src 'self'; "
        "script-src 'self'; "
        "style-src 'self' 'unsafe-inline'; "
        "connect-src 'self' ws://localhost:*"
    )
    response.headers["X-Content-Type-Options"] = "nosniff"
    return response
```

### CSRF Protection

- For a localhost-only app, CSRF risk is minimal but not zero (browser
  extensions, malicious local pages).
- Flask-SocketIO uses its own session-based verification.
- For REST endpoints that mutate state (`POST`, `PUT`, `DELETE`), verify the
  `Origin` or `Referer` header matches `localhost`:

```python
def _is_local_origin(request) -> bool:
    origin = request.headers.get("Origin", "")
    return origin.startswith("http://localhost:") or origin.startswith("http://127.0.0.1:")
```

### Authentication & Authorisation

- For a single-user local app, authentication is not required.
- **Bind to `127.0.0.1` only** - never `0.0.0.0`. This is the primary access
  control mechanism.
- If ever exposed beyond localhost, add authentication before deployment.

### Error Information Leakage (OWASP A10)

- **Never** return stack traces or internal paths in JSON error responses.
- Log the full exception server-side; return only a user-friendly message.
- Set `debug=False` in production. `debug=True` exposes the Werkzeug debugger
  which allows arbitrary code execution.

### Denial of Service (Local Context)

- **Limit request body size**: `app.config["MAX_CONTENT_LENGTH"] = 1_048_576`
  (1 MB).
- **Limit subprocess runtime** with a timeout (see
  `flask-websocket-subprocess.instructions.md`).
- **One job at a time** - reject concurrent launch requests.


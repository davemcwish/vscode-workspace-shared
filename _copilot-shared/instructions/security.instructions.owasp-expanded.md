---
applyTo: "**"
description: "OWASP/CWE expanded secure coding rules for Python, JavaScript, HTML, CSS, local web tooling, Salesforce utilities, and generated reports."
owner: "TODO: team-or-DL"
lastReviewed: "2026-07-01"
reviewCadence: "quarterly"
---

# Security Rules - OWASP/CWE Expanded

> **Precedence:** this file sits *below* `security.instructions.md` (the canonical
> Cycode/SAST rules) and `ci-cd.instructions.md`. On any conflict, follow the
> **stricter** rule. Shared code snippets (subprocess validator, `resolve_safe_path`,
> security headers, `safe_extract_zip`, `safe_filename`, SMTP) are **defined
> canonically in `security.instructions.md`**; this file references them and adds
> broader OWASP/CWE breadth.

## Purpose

This file extends the repository-specific `security.instructions.md` rules with
broader OWASP/CWE secure coding coverage.

Use this file for local pre-PR review, FordLLM repo scans, and code generation
guidance. The historical Cycode findings remain important, but they do not cover
every high-risk weakness. This document fills the main gaps for:

- Python
- JavaScript
- HTML templates
- CSS
- Flask/local web tools
- Salesforce CLI utilities
- generated CSV/Excel/PDF/ZIP/report files
- email/SMTP/Outlook automation
- dependency and supply-chain safety
- CI/CD pipelines and AI-generated code (see `ci-cd.instructions.md` and the
  LLM section in `security.instructions.md`)

If this file conflicts with a more specific project instruction, follow the
stricter rule.

## Security Philosophy

Security fixes must provide real protection, not only satisfy SAST tooling.
Never launder a tainted value through a no-op transform to silence a scanner.

For every change, ask:

1. What is the trust boundary?
2. What data is untrusted?
3. What operation could cause harm?
4. Is the input allow-listed before the dangerous operation?
5. Is sensitive data kept out of logs, generated files, screenshots, and PRs?
6. Does the code fail closed?
7. Would this still be safe if the local-only tool were accidentally exposed?

## OWASP Top 10 Coverage Map

| OWASP category | Repository guidance |
| --- | --- |
| Broken Access Control | Localhost binding, authorization checks if exposed, no browser-only authorization, no IDOR. |
| Security Misconfiguration | Debug disabled, secure headers, safe CORS, localhost-only defaults, secure cookies if applicable. |
| Software Supply Chain Failures | Pinned dependencies, dependency review, lockfiles, audit tooling, no untrusted install scripts, SBOM, pinned CI actions. |
| Cryptographic Failures | No weak random for secrets, no disabled TLS verification, no MD5/SHA1 for security, no hard-coded keys. |
| Injection | Command injection, path traversal, SQL/SOQL injection, DOM XSS, template injection, SSRF, CI workflow injection. |
| Insecure Design | Threat modeling for new workflows, safe defaults, explicit trust boundaries, abuse-case review. |
| Authentication Failures | Required if exposed beyond localhost; strong sessions, secure cookies, no default credentials. |
| Software/Data Integrity Failures | Unsafe deserialization, XML parsing, archive extraction, generated file tampering, dependency integrity, artifact provenance. |
| Logging and Alerting Failures | Do not leak secrets or confidential data; log security events safely and usefully. |
| Mishandling Exceptional Conditions | No stack traces to users, no raw exception leakage, cleanup on failure, fail closed. |

## Universal Review Triggers

Flag any change that:

- introduces a new network call;
- calls `subprocess.run`, `subprocess.Popen`, `os.system`, or equivalent;
- reads from or writes to paths derived from user/config/API data;
- creates, extracts, or rewrites ZIP, TAR, Excel, XML, CSV, PDF, or report files;
- parses XML, YAML, pickle, marshal, or any serialized format;
- sends email or reads recipient lists;
- logs filenames, paths, usernames, emails, tokens, Salesforce records, or API responses;
- introduces browser DOM manipulation;
- uses `innerHTML`, `outerHTML`, `insertAdjacentHTML`, `document.write`, `eval`, or `new Function`;
- disables TLS verification;
- changes CORS, CSP, cookies, auth, CSRF, or Flask debug settings;
- adds or updates dependencies;
- adds generated files to the repository;
- processes uploaded or externally supplied files;
- exposes a local service beyond `127.0.0.1`;
- edits a CI/CD workflow, action pinning, or pipeline permissions;
- is authored by an AI assistant and touches any sink above.

## Trust Boundaries

Treat the following as untrusted unless proven otherwise:

- command-line arguments;
- environment variables;
- config files;
- JSON files;
- CSV/Excel files;
- downloaded files;
- ZIP/TAR archive contents;
- Salesforce API responses;
- Salesforce object names and field names;
- Salesforce usernames, aliases, IDs, org IDs, and instance URLs;
- browser request data;
- query string values;
- form values;
- WebSocket messages;
- DOM values read from the page;
- generated files that may have been edited by a user;
- file paths returned from file pickers;
- email recipient lists;
- CI/CD event payloads (PR titles, branch names, issue bodies, commit messages);
- data copied from logs, spreadsheets, tickets, or Teams messages.

Validation must happen before the value reaches a dangerous sink.

## Validation Rules

Prefer allow-lists over block-lists.

A validator should:

1. coerce to the expected type;
2. trim only if trimming is valid for that field;
3. match against a strict full-pattern regex or explicit allow-list;
4. enforce length limits;
5. reject empty values unless explicitly allowed;
6. return the matched value;
7. raise `ValueError` or a project-specific exception on failure.

Python allow-list validator pattern:

```python
_SAFE_ALIAS_PATTERN = re.compile(r"[A-Za-z0-9_.@\-]{1,128}")

def validate_salesforce_alias(value: str) -> str:
    cleaned = str(value or "").strip()
    match = _SAFE_ALIAS_PATTERN.fullmatch(cleaned)
    if match is None:
        raise ValueError(f"Invalid Salesforce alias: {cleaned!r}")
    return match.group(0)
```

Do **not** validate with a block-list substring check (it is trivially bypassed
and passes the dangerous value through unchanged):

```python
# BAD - not validation.
if "../" not in path:
    open(path)
```

Do validate with a real containment/allow-list helper:

```python
# GOOD - resolve_safe_path is defined canonically in security.instructions.md.
safe_path = resolve_safe_path(path, BASE_DIR)
open(safe_path)
```

> If Cycode raises a cross-module false positive, register the validator as a
> **custom sanitizer** or add a **documented suppression** (see
> `security.instructions.md`). Do **not** add a permissive "re-verification"
> regex in the sink's function - a regex that permits the dangerous characters
> validates nothing.

## A01 - Broken Access Control

### Localhost Access Control

Local developer tools must bind to localhost only:

```python
app.run(host="127.0.0.1", port=5000, debug=False)
```

Do not bind to `app.run(host="0.0.0.0")` unless the feature has explicit
authentication, authorization, CSRF protection, secure cookie configuration,
and security approval.

### If Exposed Beyond Localhost

- require authentication;
- require authorization on every state-changing endpoint;
- verify the current user can access the requested object;
- do not rely on hidden fields, disabled buttons, route names, or frontend checks;
- enforce authorization server-side;
- log authorization failures safely;
- rate-limit sensitive operations.

### IDOR Prevention

```python
# BAD
record_id = request.args["id"]
return get_record(record_id)

# REQUIRED
record_id = validate_salesforce_record_id(request.args["id"])
record = get_record(record_id)
if not current_user_can_access(record):
    abort(403)
return record
```

For local-only tools, still avoid habits that would be unsafe if exposed later.

## A02 - Security Misconfiguration

### Flask / Web App Configuration

```python
# Required
app.config["MAX_CONTENT_LENGTH"] = 1_048_576
app.run(host="127.0.0.1", debug=False)
```

Forbidden in committed code unless explicitly approved and protected:
`debug=True`, `host="0.0.0.0"`.

### Security Headers

Use the **canonical `set_security_headers` block defined in
`security.instructions.md`** - do not fork a weaker variant here. For public
HTTPS deployments, also add HSTS and replace `style-src 'unsafe-inline'` with
nonces or hashes.

### CORS

```python
# Forbidden
CORS(app, supports_credentials=True, origins="*")

# Preferred
CORS(app, supports_credentials=True, origins=["http://localhost:5000"])
```

Never reflect an arbitrary `Origin` header back to the client.

## A03 - Software Supply Chain Failures

### Python Dependencies

- pin exact versions in `requirements*.txt`;
- prefer lockfiles where available;
- review new packages before adding;
- **confirm the package actually exists and is the intended, maintained project**
  (guard against typo-squats and AI-hallucinated / slop-squatted names);
- avoid packages with unclear ownership or suspicious names;
- run approved dependency scanning where available;
- run `pip-audit` if available locally;
- generate an SBOM (CycloneDX/SPDX) as a build artifact where the pipeline supports it.

### JavaScript / NPM Dependencies

- commit the lockfile;
- avoid packages with install scripts unless required and reviewed;
- avoid abandoned packages;
- do not use typo-squatted or unofficial packages;
- do not load packages from random CDNs without approval;
- use Subresource Integrity for approved CDN assets.

### Dependency Review Triggers

Flag any PR that: adds a new package manager; adds a new dependency; updates many
dependencies at once; removes lockfiles; adds post-install scripts; adds minified
third-party JavaScript; or adds CDN-hosted scripts or styles.

## A04 - Cryptographic Failures

### Randomness

```python
# Good - security-sensitive
token = secrets.token_urlsafe(32)

# Bad
token = random.randint(100000, 999999)
```

For non-security mock/test data, prefer deterministic counters (see the PRNG
section in `security.instructions.md`), or `random.SystemRandom()` if
non-determinism is acceptable.

### TLS

```python
# Forbidden
requests.get(url, verify=False)

# Required
requests.get(url, timeout=30)
```

Use default certificate validation unless an approved corporate TLS pattern
requires otherwise.

### Hashing and Encryption

Do not use for security decisions: MD5, SHA1, DES, 3DES, RC4, ECB mode.
Do not invent encryption schemes. Do not hard-code encryption keys, signing
secrets, or API tokens. If password storage is introduced, use an approved
password-hashing algorithm/library; never store or log plaintext passwords.

## A05 - Injection

### Command Injection

Validate all variable arguments with allow-list validators; use list arguments;
pass `shell=False`; use approved executable allow-lists (include `sf`, `sf.exe`,
`sf.cmd`); set timeouts; avoid logging raw stdout/stderr. Canonical pattern lives
in `security.instructions.md`.

```python
# Good
safe_alias = validate_salesforce_alias(alias)
command = validate_subprocess_command(
    ["sf", "org", "display", "--target-org", safe_alias, "--json"]
)
result = subprocess.run(
    command, capture_output=True, text=True, check=True, shell=False, timeout=60
)

# Forbidden
subprocess.run(f"sf org display --target-org {alias}", shell=True)
```

### SQL / SOQL Injection

```python
# Bad
cursor.execute(f"SELECT * FROM users WHERE name = '{name}'")

# Good
cursor.execute("SELECT * FROM users WHERE name = ?", (safe_name,))
```

For SOQL: allow-list object names, field names, and sort directions; validate
record IDs; escape string literals with an approved helper; never let users
control raw `WHERE`, `SELECT`, `FROM`, `ORDER BY`, `LIMIT`, or `OFFSET` text.

```python
_ALLOWED_OBJECTS = {"User", "Account", "Contact"}
_ALLOWED_USER_FIELDS = {"Id", "Name", "Email", "Username", "IsActive"}

safe_object = require_allowed(object_name, _ALLOWED_OBJECTS)
safe_fields = [require_allowed(f, _ALLOWED_USER_FIELDS) for f in requested_fields]
safe_name = escape_soql_literal(name)
query = f"SELECT {', '.join(safe_fields)} FROM {safe_object} WHERE Name = '{safe_name}'"
```

Even when interpolation is unavoidable for SOQL identifiers, use only
allow-list-produced values.

### Path Traversal

Use `resolve_safe_path()` (canonical in `security.instructions.md`) before file
I/O. Dangerous sinks include `open()`, `Path.read_text/write_text`,
`shutil.copy/move/rmtree`, `zipfile`/`tarfile` extract methods, and Excel/PDF/CSV
writers. Never trust a filename because it "came from Salesforce" or "came from
our own generated file."

### SSRF / Outbound Request Injection

```python
_ALLOWED_HOSTS = {"login.salesforce.com", "test.salesforce.com"}

def validate_outbound_host(url: str) -> str:
    parsed = urllib.parse.urlparse(url)
    if parsed.scheme != "https":
        raise ValueError("Only HTTPS URLs are allowed.")
    if parsed.hostname not in _ALLOWED_HOSTS:
        raise ValueError("Outbound host is not approved.")
    return parsed.geturl()

safe_url = validate_outbound_host(url)
response = requests.get(safe_url, timeout=30)
```

Block loopback/link-local/private IPs unless intended; require HTTPS; set
timeouts; keep TLS verification on; never put credentials in URLs; log only
host/category/status.

### Template Injection

```python
# Forbidden
render_template_string(user_supplied_template)

# Preferred
render_template("report.html", rows=safe_rows)
```

Do not use Jinja `| safe` for user-controlled values.

### JavaScript Code Injection

```javascript
// Forbidden
eval(userValue);
new Function(userValue);
setTimeout(userValue, 1000);
setInterval(userValue, 1000);

// Required
setTimeout(() => runKnownFunction(), 1000);
```

## DOM XSS and Browser Injection

### Dangerous DOM Sinks

Do not pass non-literal/untrusted values into: `innerHTML`, `outerHTML`,
`insertAdjacentHTML`, `document.write`, `replaceWith`, `eval`, `new Function`,
or string-form `setTimeout`/`setInterval`. Prefer `textContent`,
`createElement`, `appendChild`, `replaceChild`, and `setAttribute` with
allow-listed attribute names and validated values.

```javascript
// Good
const item = document.createElement("option");
item.value = apiName;
item.textContent = `${label} (${apiName})`;
select.appendChild(item);

// Bad
select.innerHTML += `<option value="${apiName}">${label}</option>`;
```

### Attribute Safety

Treat these as dangerous when user-controlled: `href`, `src`, `srcdoc`, `style`,
event attributes (e.g. `onclick`), `target`, `formaction`.

```javascript
function safeHttpUrl(value) {
  const url = new URL(value, window.location.origin);
  if (!["http:", "https:"].includes(url.protocol)) {
    throw new Error("Unsupported URL scheme");
  }
  return url.toString();
}
```

Do not allow `href="javascript:..."`.

### postMessage

Never use `"*"` as the target origin when sending sensitive data; always verify
`event.origin`; validate `event.data` shape and types.

```javascript
const allowedOrigins = new Set(["http://localhost:5000"]);

window.addEventListener("message", (event) => {
  if (!allowedOrigins.has(event.origin)) {
    return;
  }
  if (!event.data || event.data.type !== "expected-message") {
    return;
  }
  handleMessage(event.data);
});
```

### Browser Storage

Do not store secrets in `localStorage`, `sessionStorage`, `IndexedDB`, or
JS-readable cookies. Never store Salesforce access/refresh tokens, session IDs,
API keys, or passwords in browser storage.

## A06 - Insecure Design

### Threat Modeling Requirement

Before adding a new workflow, ask what an attacker controls; what happens with
huge or malformed input; what if a file is malicious; what if Salesforce returns
unexpected data; what if the command hangs; what if recipients are wrong; what if
a report is sent outside Ford; what if the local web app becomes network-reachable.
Add a short design note for high-risk changes.

### Safe Defaults

Default to: localhost-only servers; no external recipients; no destructive
actions; dry-run mode for bulk changes; explicit confirmation for delete/update;
no committed confidential files; secure transport; low-privilege access;
fail-closed behavior.

## A07 - Authentication Failures

For single-user localhost-only tools bound to `127.0.0.1`, authentication may be
unnecessary. If exposed beyond localhost, require authentication, authorization,
secure session handling, CSRF protection, secure cookies, session timeout, no
default credentials, rate limiting, and audit logging for auth failures.

```python
SESSION_COOKIE_SECURE = True
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = "Lax"
```

Use `SameSite=Strict` where UX allows.

## A08 - Software and Data Integrity Failures

### Unsafe Deserialization

Never deserialize untrusted data with `pickle`, `marshal`, `shelve`, unsafe
`yaml.load`, or dynamic imports based on user input.

```python
# Forbidden
obj = pickle.loads(data)

# Preferred
obj = json.loads(data)
validate_schema(obj)

# YAML
yaml.safe_load(text)   # not yaml.load(text)
```

### XML Parsing

```python
from defusedxml import ElementTree as ET
tree = ET.parse(path)
```

Avoid standard-library XML parsers for files that may be externally influenced.

### Archive Extraction

Use the **canonical `safe_extract_zip` in `security.instructions.md`**, which
performs a real containment check and rejects symlink members and absolute paths.
**Do not** use the old `str.startswith` containment test - a sibling directory
like `/tmp/base-evil` passes a check against `/tmp/base`.

```python
# Illustrative - canonical implementation lives in security.instructions.md.
def safe_extract_zip(zf, target_dir):
    safe_base = target_dir.resolve()
    for member in zf.infolist():
        name = member.filename
        if name.startswith(("/", "\\")) or ".." in Path(name).parts:
            raise ValueError(f"Unsafe ZIP member path: {name!r}")
        destination = (safe_base / name).resolve()
        if not destination.is_relative_to(safe_base):   # real containment
            raise ValueError(f"Unsafe ZIP member path: {name!r}")
        zf.extract(member, safe_base)
```

TAR files need extra care (symlinks, hard links, absolute paths, device files).
Prefer avoiding TAR extraction; if required, validate every member and reject
links and absolute paths.

### Generated Files

Treat generated files as confidential unless explicitly sanitized. Do not commit
real Salesforce exports, user lists, recipient lists, Excel reports, PDFs, ZIPs,
logs, raw JSON API responses, screenshots with user data, or paths containing
usernames.

## A09 - Logging and Alerting Failures

Do not log: access/refresh tokens; session IDs; cookies; passwords; API keys;
Salesforce record payloads; recipient email addresses; distribution lists; full
local file paths; workstation usernames; raw API response bodies; raw CLI
stdout/stderr; or full request URLs with query strings.

Do log (safely): generic event names; record counts; status codes by category;
duration/timing; and validation-failure events without echoing the raw value.

```python
# Good
logger.info("Exported %d records to report.", len(rows))
logger.warning("Rejected input failing alias validation.")

# Bad
logger.info("Exported records: %s", rows)
logger.warning("Rejected alias: %s", raw_alias)
```

Log security-relevant events usefully: validation failures (by category),
authorization denials, TLS/connection failures, subprocess failures (redacted),
and archive/extraction rejections. The goal is enough signal to investigate
without leaking sensitive data.

## A10 - Mishandling Exceptional Conditions

- Never return stack traces, internal paths, or raw exception text to a client
  or user-facing surface.
- Log a short safe message server-side; return a generic error to the caller.
- Fail closed: on error, deny the action rather than proceeding.
- Clean up partial artifacts (temp files, partial exports, open handles) on
  failure.
- Do not swallow exceptions silently; do not use bare `except:` that hides
  security-relevant failures.

```python
# Good
try:
    result = run_export(safe_alias)
except ExportError:
    logger.exception("Export failed.")          # safe message, server-side
    return jsonify(error="Export failed."), 500  # generic to client

# Bad
except Exception as exc:
    return jsonify(error=str(exc)), 500          # may leak paths/tokens
```

Set `debug=False` in any committed Flask configuration - the Werkzeug
interactive debugger allows remote code execution and must never be reachable.

## Python-Specific Rules

- Never use `eval`, `exec`, `compile`, or `__import__` on dynamic/user input.
- Never use `os.system`; use validated `subprocess.run(..., shell=False)`.
- Use `defusedxml` for XML; `json` or `yaml.safe_load` for data; never `pickle`
  or `marshal` on untrusted data.
- Set timeouts on all network and subprocess calls.
- Keep TLS verification enabled (`verify=True` / default).
- Use `secrets` for security tokens; deterministic counters or
  `random.SystemRandom()` for non-security data.
- Use context managers (`with`) for files, sockets, subprocess pipes, and DB
  connections so resources close on error.
- Validate every path with `resolve_safe_path()` before file I/O.
- Enforce `MAX_CONTENT_LENGTH` and explicit size limits when reading files or
  request bodies to prevent resource exhaustion.
- Avoid mutable default arguments and shared global state in request handlers.

## JavaScript-Specific Rules

- No `eval`, `new Function`, or string-form `setTimeout`/`setInterval`.
- No `innerHTML`/`outerHTML`/`insertAdjacentHTML`/`document.write` with
  non-literal values; build DOM nodes with `createElement` + `textContent`.
- Validate `event.origin` for every `postMessage` handler; never send sensitive
  data with target origin `"*"`.
- Never store secrets/tokens in browser storage or JS-readable cookies.
- Validate URL schemes (`http:`/`https:` only); reject `javascript:` URLs.
- Use `URL`/`URLSearchParams` for parsing; do not hand-concatenate query strings.
- Pin/verify third-party scripts; use Subresource Integrity for CDN assets.

## HTML Template Rules

- Rely on Jinja2 auto-escaping; never disable it globally.
- Never apply `| safe` to user-controlled or Salesforce-derived values.
- Do not build HTML strings from untrusted data in Python and inject them.
- Include the canonical CSP and security headers (see `security.instructions.md`).
- Add `rel="noopener noreferrer"` to any `target="_blank"` links.
- Prefer external scripts over inline; if inline is unavoidable, use nonces.

## CSS Rules

- No untrusted values in `url(...)`, `expression(...)`, or `@import`.
- Do not build inline `style` attributes from user input.
- Avoid loading remote stylesheets from unapproved origins; use SRI for approved
  CDN stylesheets.

## Salesforce-Specific Rules

- Treat all Salesforce API responses, object/field names, aliases, IDs, org IDs,
  and instance URLs as untrusted input.
- Allow-list object names, field names, and sort directions for SOQL; validate
  record IDs; escape string literals with an approved helper.
- Validate aliases with a strict pattern before any CLI call; use list-form
  `subprocess.run(..., shell=False)` and executable allow-lists.
- Never log record payloads, usernames, tokens, or instance URLs.
- Treat all Salesforce exports as confidential; never commit them.
- Prefer dry-run and explicit confirmation for bulk update/delete operations.

## Email / SMTP / Outlook Rules

- Use TLS (`SMTP_SSL` or STARTTLS that fails closed) - canonical pattern in
  `security.instructions.md`.
- Validate and allow-list recipient domains; block external recipients unless
  explicitly approved.
- Never log recipient addresses or distribution lists; log counts only.
- Do not build email bodies containing confidential Salesforce data unless the
  destination is approved.
- Validate any attachment path with `resolve_safe_path()`; use safe temp-file
  prefixes (not user-controlled names).

## CI/CD Pipeline Rules (summary - see `ci-cd.instructions.md`)

- Pin third-party Actions to a full commit SHA, not a floating tag.
- Default `GITHUB_TOKEN` permissions to least privilege; elevate per-job only.
- Never interpolate `${{ github.event.* }}` (PR titles, branch names, issue
  bodies) directly into `run:` shell - pass via `env:` and quote.
- Do not check out and execute untrusted PR code in `pull_request_target`.
- Prefer OIDC federation over long-lived cloud secrets.
- Fail the build on SAST HIGH/CRITICAL; enforce as a required status check.
- Enforce secret scanning / push protection in the pipeline.
- Generate an SBOM as a build artifact where supported.

## AI / LLM-Generated Code

Because much code here is AI-authored (see `security.instructions.md` for the
normative rules): verify suggested packages exist and are the intended,
maintained project; review licenses of non-trivial snippets; require human
review for AI-authored sinks (subprocess, file I/O, network, deserialization,
XML/ZIP, auth); and never accept an AI-suggested SAST suppression without
confirming it is a true false positive with recorded rationale.

## Final Pre-PR Security Checklist

- [ ] All untrusted inputs identified and allow-list validated before any sink.
- [ ] No command injection: list args, `shell=False`, validated executable, timeout.
- [ ] No path traversal: `resolve_safe_path()` before all file I/O.
- [ ] No SQL/SOQL injection: parameterization or allow-listed identifiers.
- [ ] No DOM XSS: `textContent`/`createElement`, no dangerous sinks.
- [ ] No SSRF: HTTPS + host allow-list + timeout + TLS on.
- [ ] No unsafe deserialization; `defusedxml` for XML; safe archive extraction.
- [ ] No secrets in code, logs, browser storage, generated files, or PRs.
- [ ] Strong randomness for security; deterministic/`SystemRandom` otherwise.
- [ ] TLS verification enabled everywhere.
- [ ] Secure headers, safe CORS, localhost binding, `debug=False`.
- [ ] Errors fail closed; no stack traces to users; artifacts cleaned up.
- [ ] Dependencies pinned, reviewed, and confirmed to exist; lockfiles committed.
- [ ] CI workflows: SHA-pinned actions, least-privilege tokens, no workflow injection.
- [ ] AI-generated sinks human-reviewed; suggested packages verified.
- [ ] No confidential Salesforce data committed or logged.

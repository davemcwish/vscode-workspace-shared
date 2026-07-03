---
name: website-security
description: "Human-facing skill for building/reviewing web front-ends and local web tooling: DOM XSS, CSP, headers, origin checks, client-side storage, and third-party scripts."
owner: "TODO: team-or-DL"
lastReviewed: "2026-07-01"
reviewCadence: "quarterly"
---

# Skill: Website Security

> **Role & precedence.** This skill is *explanatory* (human onboarding for
> web/front-end work). The **normative** rules and canonical code live in
> `security.instructions.md` (source of truth), with broader coverage in
> `security.instructions.owasp-expanded.md` and pipeline rules in
> `ci-cd.instructions.md`. On any conflict, follow the instruction files and the
> **stricter** rule. Take code (CSP block, origin check, etc.) from
> `security.instructions.md` rather than copying from here, so snippets can't drift.
>
> Related: `website-privacy-legal.skill.md` (verify this file exists; if it does
> not, remove this reference or create it).

## ⚠ Currentness Warning

Web security guidance changes frequently (browser behavior, CSP levels, header
support, framework defaults). Before relying on a specific header, CSP
directive, or API, **verify it against current browser and framework
documentation**. Treat the examples here as a starting point, not a frozen spec.

## Scope

Applies to any change that renders HTML, runs JavaScript in a browser, serves a
local web UI, handles WebSocket messages, or loads third-party front-end assets.
Front-end code is a trust boundary: everything the browser receives from a user,
the DOM, the URL, storage, or a message channel is **untrusted** until validated.

## DOM XSS - The Primary Web Risk

The most common front-end vulnerability here is injecting untrusted values into
HTML. Prevent it by building nodes, not HTML strings.

### Dangerous sinks (never pass non-literal/untrusted values)

`innerHTML`, `outerHTML`, `insertAdjacentHTML`, `document.write`,
`document.writeln`, `Element.replaceWith` with strings, `eval`, `new Function`,
and string-form `setTimeout` / `setInterval`.

### Safe rendering

```javascript
// Good - text is inert
const cell = document.createElement("td");
cell.textContent = record.name;
row.appendChild(cell);

// Bad - HTML injection
row.innerHTML += `<td>${record.name}</td>`;
```

- Use `textContent` for text, `createElement` + `appendChild` for structure, and
  `setAttribute` with allow-listed attribute names for attributes.
- If you must render rich HTML from untrusted input, sanitize with a
  well-maintained, actively-updated library (e.g. DOMPurify) and render the
  sanitized output - never hand-rolled escaping.
- Rely on framework escaping (Jinja2 auto-escape, React JSX text). Never disable
  it; never use Jinja `| safe` on user-controlled values; avoid React
  `dangerouslySetInnerHTML`.

## Attribute & URL Safety

Treat these as dangerous when user-controlled: `href`, `src`, `srcdoc`, `style`,
event handler attributes (`onclick`, etc.), `target`, and `formaction`.

```javascript
function safeHttpUrl(value) {
  const url = new URL(value, window.location.origin);
  if (!["http:", "https:"].includes(url.protocol)) {
    throw new Error("Unsupported URL scheme");
  }
  return url.toString();
}
```

- Reject `javascript:`, `data:`, and `vbscript:` URLs in links/sources.
- Add `rel="noopener noreferrer"` to every `target="_blank"` link.
- Build query strings with `URLSearchParams`, never string concatenation.

## Prototype Pollution

Merging untrusted objects can poison `Object.prototype`. A shallow key check is
**not enough** - nested payloads and array paths bypass it, and `__proto__` can
arrive via a nested object.

```javascript
const FORBIDDEN_KEYS = new Set(["__proto__", "prototype", "constructor"]);

// Deep, recursive guard. Reject forbidden keys at ANY depth.
function safeAssign(target, source) {
  for (const key of Object.keys(source)) {
    if (FORBIDDEN_KEYS.has(key)) {
      throw new Error(`Forbidden key: ${key}`);
    }
    const value = source[key];
    if (value && typeof value === "object") {
      // Recurse into nested objects/arrays so deep payloads are caught too.
      target[key] = safeAssign(
        Array.isArray(value) ? [] : {},
        value
      );
    } else {
      target[key] = value;
    }
  }
  return target;
}
```

- Prefer `Map` over plain objects for untrusted key/value data.
- Prefer `Object.create(null)` for lookup tables so there is no prototype to pollute.
- Avoid deep-merge utilities that don't explicitly guard prototype keys.

## postMessage & Origin Validation

```javascript
const ALLOWED_ORIGINS = new Set(["http://localhost:5000"]);

window.addEventListener("message", (event) => {
  if (!ALLOWED_ORIGINS.has(event.origin)) {
    return;                       // reject unknown origins
  }
  if (!event.data || event.data.type !== "expected-message") {
    return;                       // validate shape and type
  }
  handleMessage(event.data);
});
```

- Never send sensitive data with target origin `"*"`; always specify the exact
  origin.
- Always validate `event.origin` against an allow-list and validate `event.data`
  shape/types before use.

## Server-Side Origin / CSRF Checks

For state-changing endpoints, verify the Origin **host and port exactly** by
parsing - a `startswith` prefix check is bypassable (e.g.
`http://localhost:5000.attacker.com`). Use the canonical parsed check from
`security.instructions.md`:

```python
from urllib.parse import urlparse

_ALLOWED_ORIGINS = {("localhost", 5000), ("127.0.0.1", 5000)}

def is_local_origin(request) -> bool:
    parsed = urlparse(request.headers.get("Origin", ""))
    return parsed.scheme == "http" and (parsed.hostname, parsed.port) in _ALLOWED_ORIGINS
```

## Client-Side Storage

- Never store secrets, access/refresh tokens, session IDs, API keys, or
  passwords in `localStorage`, `sessionStorage`, `IndexedDB`, or JS-readable
  cookies.
- Session cookies should be set server-side with `HttpOnly`, `Secure`, and an
  appropriate `SameSite` value - not managed in JavaScript.
- Treat anything readable by JavaScript as exposed to any XSS on the page.

## Content Security Policy & Security Headers

Use the **canonical `set_security_headers` block in `security.instructions.md`**
- do not fork a weaker variant. Summary of what it enforces:

- `default-src 'self'`, `script-src 'self'`, `object-src 'none'`,
  `base-uri 'self'`, `frame-ancestors 'none'`.
- `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`,
  `Referrer-Policy: no-referrer`.
- `connect-src` limited to the local WebSocket origins for this tool.

> `style-src 'unsafe-inline'` is tolerated **only** for this localhost tool. For
> any public deployment: remove it (use nonces/hashes), serve over HTTPS, and add
> `Strict-Transport-Security`. Re-check directive support against current browser
> docs (see the Currentness Warning).

## Third-Party Scripts & Subresource Integrity

- Minimize third-party front-end dependencies; each one is attacker surface.
- Load approved CDN assets with **Subresource Integrity and CORS**:

```html
<script
  src="https://cdn.example.com/lib@1.2.3/lib.min.js"
  integrity="sha384-BASE64_HASH_HERE"
  crossorigin="anonymous"></script>
```

- Pin exact versions (never floating `@latest`); commit the JS lockfile.
- Avoid packages with post-install scripts unless reviewed.
- Consider a CI check that fails if any external `<script>`/`<link>` lacks an
  `integrity` attribute.
- Confirm any AI-suggested front-end package actually exists and is the intended,
  maintained project before adding it (see LLM note below).

## WebSocket & Local Server Safety

- Bind local dev servers to `127.0.0.1` only - never `0.0.0.0`. This binding is
  the primary access control for a single-user localhost tool.
- Validate every inbound WebSocket message: check type/shape, enforce length
  limits, and allow-list expected message kinds before acting.
- Set `debug=False` in any committed Flask config (the Werkzeug debugger allows
  RCE).
- If the tool is ever exposed beyond localhost, it must first gain
  authentication, authorization, CSRF protection, and secure cookies.

## Input Validation (client + server)

- Client-side validation is UX only - **never** a security control. Re-validate
  everything on the server.
- Allow-list expected values; enforce type and length limits; reject unexpected
  fields.
- Enforce `MAX_CONTENT_LENGTH` and explicit size caps to prevent resource
  exhaustion from large payloads.

## Error Handling

- Never surface stack traces, internal paths, tokens, or raw API responses in the
  browser or in JSON responses.
- Log a safe message server-side; return a generic error to the client.
- Fail closed: on error, deny the action.

## AI / LLM-Generated Front-End Code (Copilot workstream)

- Verify AI-suggested JS/CSS packages and CDN URLs exist and are the intended,
  maintained project (guard against hallucinated / slop-squatted names).
- Have a human review AI-authored code that touches DOM sinks, `postMessage`,
  URL handling, storage, or third-party script loading.
- Never accept an AI-suggested SAST suppression without confirming it is a true
  false positive and recording the rationale.

## Web Security Pre-PR Checklist

- [ ] No untrusted value reaches `innerHTML`/`outerHTML`/`insertAdjacentHTML`/`document.write`.
- [ ] Text rendered via `textContent`; structure via `createElement`/`appendChild`.
- [ ] No `eval`/`new Function`/string-form timers.
- [ ] URL schemes validated; `javascript:`/`data:` rejected; `rel="noopener"` on `_blank`.
- [ ] Deep prototype-pollution guard (or `Map`/`Object.create(null)`) for untrusted objects.
- [ ] `postMessage` handlers validate `event.origin` and payload shape.
- [ ] Server origin/CSRF check parses host+port exactly (no `startswith`).
- [ ] No secrets/tokens in browser storage or JS-readable cookies.
- [ ] Canonical CSP + security headers applied; SRI on all CDN assets.
- [ ] Local server bound to `127.0.0.1`; `debug=False`.
- [ ] Server-side re-validation of all client input; size limits enforced.
- [ ] No stack traces/paths/tokens leaked to the browser; fails closed.
- [ ] Third-party/AI-suggested packages verified to exist; versions pinned.

## Cross-References

- `security.instructions.md` - canonical rules & code (source of truth).
- `security.instructions.owasp-expanded.md` - full OWASP/CWE coverage.
- `ci-cd.instructions.md` - pipeline hardening (SHA-pinned actions, token scope,
  workflow-injection, SBOM, SAST gating).
- `website-privacy-legal.skill.md` - privacy/legal (verify this file exists).

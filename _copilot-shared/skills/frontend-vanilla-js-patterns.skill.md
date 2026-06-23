# Skill: Frontend Vanilla JavaScript Patterns

## Purpose

Patterns for writing robust, beginner-friendly vanilla JavaScript in a
Flask-served single-page application. Covers the four most common failure
modes in this project:

1. A missing DOM element crashing an entire `DOMContentLoaded` handler.
2. User-supplied text reaching the DOM via `innerHTML` (XSS risk).
3. Setup functions with hidden dependencies on each other's side-effects.
4. Debugging a blank / partially-working page with no obvious error.

These patterns apply to any static HTML + JS file in the project. See
`flask-websocket.skill.md` for the server-side (Flask / SocketIO) layer.

## Related Artefacts

| Artefact | Relationship |
| --- | --- |
| `html-css-javascript.instructions.md` | Authoritative rules; this skill summarises and demonstrates them |
| `flask-websocket.skill.md` | Server-side counterpart |
| `frontend-smoke-check.prompt.md` | Use to verify a page after editing |
| `accessibility.skill.md` | ARIA and keyboard rules that complement these patterns |

---

## Pattern 1: Null-Safe DOM Access

### Problem: getElementById Returns null

`document.getElementById()` returns `null` if the element is not in the page.
Calling any method on `null` throws `TypeError: Cannot read properties of null`.
In a `DOMContentLoaded` handler, this exception silently kills every line after
the crash - you lose all remaining setup, not just the broken feature.

### Pattern: Cache Elements Once in a dom Object

Query each element once, store in a `dom` object, and guard before use:

```javascript
// =========================================================================
//  DOM ELEMENT CACHE
// =========================================================================
// Query every element once at startup. DOMContentLoaded guarantees the
// HTML is fully parsed before this code runs, so getElementById is safe.
// Individual setup functions check the specific elements they need.

const dom = {
  orgAlias:     document.getElementById("org-alias"),
  loginButton:  document.getElementById("login-button"),
  loginError:   document.getElementById("login-error"),
  loginSuccess: document.getElementById("login-success"),
  outputLog:    document.getElementById("output-log"),
};
```

### Accessing Elements Safely Inside Handlers

Do not query inside event handlers - use the cached reference:

```javascript
// CORRECT - uses the pre-queried reference, costs zero DOM lookups.
dom.loginButton.addEventListener("click", handleLogin);

// WRONG - queries every time the button is clicked.
document.getElementById("login-button").addEventListener("click", handleLogin);
```

---

## Pattern 2: Defensive Init (Progressive Enhancement)

### Problem: One Crash Kills All Setup

If all setup logic lives in one large `DOMContentLoaded` handler, a single
`null` reference anywhere in the handler stops all subsequent setup. Features
that were fine before the crash appear broken even though their code is correct.

This is what happened when the Login tab was added to an existing app: the new
`setupLogin()` call crashed on a stale cached page that had no login elements,
taking down `loadConfig()` and `loadScripts()` with it.

### Pattern: Independent Setup Functions with Early Returns

Split each UI feature into its own setup function. Guard at the top of each
function. Fail silently (with a `console.warn`) rather than throw:

```javascript
document.addEventListener("DOMContentLoaded", function() {
  // Each call is independent. If setupLogin() returns early, setupTabs()
  // and loadConfig() still run. This is progressive enhancement.
  setupTabs();
  setupLogin();   // may return early if elements are absent
  loadConfig();
  loadScripts();
});

function setupLogin() {
  // Guard: if the login form is missing (e.g. stale cached page), skip
  // wiring entirely. One missing element must never abort the rest of init.
  if (!dom.orgAlias || !dom.loginButton) {
    console.warn("Login form elements not found; skipping login setup.");
    return;
  }

  dom.loginButton.addEventListener("click", handleLogin);
  dom.orgAlias.addEventListener("input", function() {
    // Enable the button only when there is text in the alias box.
    dom.loginButton.disabled = dom.orgAlias.value.trim() === "";
  });
}
```

### The Early-Return Principle

An `if (!element) { return; }` at the top of a setup function is not
defensive boilerplate - it is the feature's contract with the rest of the
page. It says: "I only run when my required elements are present. If they are
not, I step aside so others can still run."

---

## Pattern 3: Safe Panel Visibility Helper

### Problem: classList.toggle Throws on null

`element.classList.toggle(cls, bool)` throws if `element` is `null`. When
toggling visibility on multiple elements - some of which may be optional - a
null reference crashes the whole toggle block.

### Pattern: setPanelHidden Helper

Extract a one-line helper that skips the operation if the element is absent:

```javascript
/**
 * Show or hide an element by adding or removing a CSS class.
 *
 * How it works:
 *   classList.toggle(cls, true)  adds the class (hides the element if the
 *   CSS rule is "display: none").
 *   classList.toggle(cls, false) removes the class (shows the element).
 *   The null guard means a missing element is silently skipped, so the
 *   caller does not need to guard every panel individually.
 *
 * @param {HTMLElement|null} el     - The element to show or hide.
 * @param {string}           cls    - The CSS class that hides the element.
 * @param {boolean}          hidden - Pass true to hide; false to show.
 */
function setPanelHidden(el, cls, hidden) {
  if (el) {
    el.classList.toggle(cls, hidden);
  }
}
```

Usage example in a tab-switching function:

```javascript
function showPanel(panelId) {
  const allPanels = ["config-panel", "login-panel", "scripts-panel"];
  for (const id of allPanels) {
    setPanelHidden(document.getElementById(id), "hidden", id !== panelId);
  }
}
```

---

## Pattern 4: textContent, Not innerHTML

### Problem: innerHTML Executes Embedded HTML

`element.innerHTML = userValue` parses the string as HTML. If `userValue`
contains `<script>alert(1)</script>` or `<img src=x onerror=...>`, the browser
executes the embedded code. This is an XSS (cross-site scripting) vulnerability.

Even in a localhost-only app, good habits matter: if the app is later exposed
beyond localhost, or if the pattern is copied into a public-facing template, the
vulnerability travels with it.

### Pattern: textContent for Plain Text, innerHTML for Trusted Static HTML

Use `textContent` for plain text. Use `innerHTML` only for trusted,
server-generated HTML that contains no user data:

```javascript
// CORRECT - textContent treats the value as literal text. Tags are escaped.
dom.loginError.textContent = "Alias cannot be empty.";
dom.loginSuccess.textContent = `Logged in as ${username}`;

// ALSO CORRECT - innerHTML is fine when the content is a hard-coded string
// with no user data in it.
container.innerHTML = "<em>No scripts found.</em>";

// WRONG - never pass user-supplied or API-returned text to innerHTML.
// dom.loginError.innerHTML = serverMessage;   <- XSS risk
```

This rule is documented in `security.instructions.md` and
`html-css-javascript.instructions.md`. Both files require `textContent` for
dynamic text.

---

## Pattern 5: Diagnosing a Blank or Partially-Working Page

A page that loads but has no interactive behaviour almost always means a
`TypeError` in `DOMContentLoaded`. Use this checklist:

1. **Open DevTools Console** (`F12` -> Console tab).
2. Look for a red `TypeError: Cannot read properties of null (reading
   'addEventListener')` or similar.
3. The stack trace shows the exact line. The element named in the error is
   `null` - check whether its `id` is present in the HTML.
4. If the HTML looks correct, the browser may be serving a stale cached page.
   Do a hard refresh (`Ctrl + F5`) or restart the Flask server (see
   `docs/frontend_guide.md` "Stopping and Restarting the Server").
5. After the fix, confirm `DOMContentLoaded` runs to completion by adding a
   temporary `console.log("init complete")` at the end and checking it appears.

### Quick Console Checks

```javascript
// Paste into DevTools Console to verify elements are present:
["org-alias", "login-button", "login-error", "login-success"].forEach(id => {
  console.log(id, document.getElementById(id) ? "OK" : "MISSING");
});
```

---

## Anti-Patterns (Never Do These)

| Anti-pattern | Why it is wrong | Correct approach |
| --- | --- | --- |
| `element.addEventListener(...)` without a null check | Throws `TypeError` if element is absent, crashes entire init | Guard with `if (!element) return;` |
| All setup in one large `DOMContentLoaded` block | One crash kills all setup | Split into independent `setupXxx()` functions |
| `element.innerHTML = userText` | XSS risk | Use `textContent` for plain text |
| Querying the same element inside an event handler | Redundant DOM queries, fragile | Cache in `dom` object at startup |
| `if (element === null)` guard after the fact | Too late if other calls ran first | Guard at the very top of the setup function |

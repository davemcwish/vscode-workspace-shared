---
applyTo: "**"
description: "Documentation and code consistency checks to run before raising a PR."
---

# Pre-PR Review Checklist

These checks catch documentation/code drift that automated linters miss.
Run them mentally (or with Copilot) before raising a PR.

## Documentation - Code Consistency

- If you added or removed a sheet/column in a workbook, grep all docs and
  guides for the old count and update them.
- If a requirement doc lists output filenames, verify they match the actual
  filenames produced by the implementation.
- If a guide references a config file, verify the filename matches exactly
  (including any `user_` or `order_` prefix).
- If `README.md` mentions test count or coverage percentage, update it to
  reflect the current numbers.

## Architecture Doc Consistency

`architecture.md` drifts silently because no linter checks it. Treat it as a
first-class deliverable of any structural change.

- If you add, rename, or remove a **shared library module** (anything under
  `src/**`), add or update its row in the `architecture.md` module table in the
  **same PR**.
- If you add or change a **Flask/REST endpoint** or a **SocketIO event**, update
  the REST API / events tables in the `architecture.md` Web Frontend section.
- If you add a new **frontend widget type** (a new `script_discovery`
  classification, e.g. `sf_object`), add it to the widget-type table.
- If you add a new **CLI script** under `scripts/`, confirm it is reflected in
  the architecture overview and (if discoverable) the frontend.
- After editing, run markdownlint on `architecture.md` and verify that any
  in-page anchor links still resolve (markdownlint rule MD051).

## Backlog Status Tracking

- Any backlog item (§8.4) that is now implemented must be marked `✅ Done`
  with a date, not left as `🔲 Planned`.
- Update the description to reflect what was actually built (not the original
  plan) if it diverged.

## Import and Re-Export Hygiene

- If a module uses `from __future__ import annotations`, decide whether
  imports are needed at runtime or only for type-checking. Use
  `TYPE_CHECKING` for annotation-only imports.
- Public re-exports in `__init__.py` must use unambiguous names. If two
  modules export `build_summary_df`, alias them as `build_order_summary_df`
  and `build_user_summary_df`.

## Cross-Platform Awareness

- `.secrets.baseline` must use POSIX `/` path separators (CI runs on Linux).
- `requirements.txt` entries for Windows-only packages must have
  `; sys_platform == "win32"` markers.
- Any generated file that contains OS-specific paths should be regenerated
  or normalised before committing.

## Frontend SAST (DOM XSS) - Cycode Blocks Merge

Cycode's *"Unsanitized user input in dynamic HTML insertion (XSS)"* rule runs
on every PR and blocks merge. `sanity.bat` does **not** catch it, so check any
changed `.js` file manually before pushing. See `security.instructions.md` ->
"Frontend DOM XSS" for the full source/sink reference.

- **No `replaceWith()`** - use `parent.replaceChild(newNode, oldNode)`
  (Node-typed, cannot be a string sink).
- **No `innerHTML` / `outerHTML` / `insertAdjacentHTML` / `document.write`**
  with a non-literal value. `innerHTML = ""` (literal) is fine.
- **No DOM-read -> DOM-write**: never read `el.id` / `el.name` / `el.value`
  off the DOM and write it onto a new element. Use module-level string
  literals for ids/names, guarded by an allowlist check.
- **Displayed server data** (e.g. `fetch().json()` fields) goes through
  `textContent`, never `innerHTML`. Validate with `String(x).match(/.../) ?.[0]`
  as defence-in-depth.
- Quick grep: `replaceWith|innerHTML|insertAdjacentHTML|outerHTML|document\.write`
  in changed JS - confirm each hit is a literal or has been converted.

## Docstring and Comment Accuracy

- After implementation changes, re-read adjacent docstrings and comments.
  If they reference counts, field names, or behaviours that changed, update
  them.
- Example email addresses in docstrings must be realistic (no spaces around
  `@` or `-`).
- Security-related comments must not overstate protections (e.g. don't claim
  a value is "redacted" if it isn't).

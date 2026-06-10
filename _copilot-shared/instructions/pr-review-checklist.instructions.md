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

## Docstring and Comment Accuracy

- After implementation changes, re-read adjacent docstrings and comments.
  If they reference counts, field names, or behaviours that changed, update
  them.
- Example email addresses in docstrings must be realistic (no spaces around
  `@` or `-`).
- Security-related comments must not overstate protections (e.g. don't claim
  a value is "redacted" if it isn't).

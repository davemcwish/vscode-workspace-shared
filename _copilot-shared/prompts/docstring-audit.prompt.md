---
description: "Audit Python docstrings and produce a beginner-friendly remediation plan."
mode: agent
---

Audit Python docstrings in the selected file, folder, or the entire repository.

Read these before starting:

- `./.github/instructions/docstrings.instructions.md`
- `./.github/skills/docstring.skill.md`
- `./.github/instructions/python.instructions.md`

---

## What to Check

For every Python file in scope, check:

1. **Missing module docstrings** — every `.py` file must start with one.
2. **Missing class docstrings** — every class and its `__init__` must be documented.
3. **Missing function or method docstrings** — both public and non-obvious private helpers.
4. **Missing test fixture docstrings** — complex fixtures that set up mocks or state.
5. **Stale docstrings** — describe behaviour the code no longer has.
6. **Too terse for a complete beginner** — technically correct but useless to someone new.
7. **Missing Args, Returns, Raises, or Example sections** where they apply.
8. **Unexplained Salesforce, Python, or business terms** — abbreviations and jargon.

Do **not** change runtime behaviour. Audit only.

---

## Output Format

Return a structured report:

```markdown
# Docstring Audit Report

## Summary

[Plain-English summary of overall docstring quality — 3-5 sentences.]

## Files Reviewed

| File | Result | Notes |
| --- | --- | --- |
| `src/sf_admin_utils/foo.py` | ⚠ Gaps found | 3 functions missing docstrings |
| `scripts/bar.py` | ✅ Good | No gaps found |

## Missing Docstrings

| File | Line | Object Type | Object Name | Why It Needs a Docstring |
| --- | --- | --- | --- | --- |

## Weak or Stale Docstrings

| File | Line | Object | Problem | Recommended Fix |
| --- | --- | --- | --- | --- |

## Recommended Remediation Order

1. [Highest-value fix first — e.g. public API surface in src/]
2. [Next — e.g. CLI entry points in scripts/]
3. [Then — e.g. test fixtures in tests/]

## Safe to Auto-Fix?

[Yes — all gaps are additions only, no behaviour changes required.]
[or: No — some stale docstrings need behaviour confirmation before rewriting.]
```

---

## If Asked to Fix

When the user asks you to fix the docstrings after the audit:

1. Update only docstrings and explanatory comments.
2. Do **not** change imports, logic, tests, type hints, formatting, or behaviour.
3. Keep all language beginner-friendly and plain-English.
4. Use Google-style docstrings as shown in `./.github/skills/docstring.skill.md`.
5. Explain Salesforce terms on first use.
6. If a behaviour change seems necessary while writing the docstring, stop and
   flag the ambiguity rather than silently changing behaviour.

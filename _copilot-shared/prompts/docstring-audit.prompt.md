---
description: "Audit Python docstrings against the code implementation and produce a beginner-friendly remediation plan."
mode: agent
---

Audit Python docstrings in the selected file, folder, or the entire repository.

Read these before starting:

- `./.github/instructions/docstrings.instructions.md`
- `./.github/skills/docstring.skill.md`
- `./.github/instructions/python.instructions.md`

---

## The Two Jobs (Keep Them Separate)

Docstrings have two distinct jobs:

1. **WHAT the code does** - facts extracted from reading the implementation.
2. **HOW to explain it** - beginner prose applied to confirmed facts only.

This audit focuses on job 1 first (accuracy), then job 2 (clarity).

---

## Step 0: Establish Ground Truth

> **Do this BEFORE looking at any existing docstring.**

For every function you will audit, read its implementation to confirm:

1. What parameters it accepts (names, types, defaults).
2. What it returns (actual type and value).
3. What exceptions it raises (trace `raise` statements).
4. What side effects it performs (file I/O, API calls, mutations).

Treat the implementation as the ONLY source of truth. Never rely on the
existing docstring, a similar function, or what would "make sense".

---

## Step 1: Audit (1:1 Set Arithmetic)

For every Python file in scope, perform a mechanical 1:1 comparison between
each docstring and the code:

1. **Invented** - docstring claims something the code does not do.
2. **Omitted** - code does something the docstring does not mention.
3. **Wrong type** - docstring type disagrees with implementation.
4. **Stale** - docstring describes old behaviour.
5. **Too terse** - technically correct but useless to a beginner.
6. **Missing** - no docstring at all.

Also check:

- Missing module docstrings - every `.py` file must start with one.
- Missing class docstrings - every class and its `__init__` must be documented.
- Missing function or method docstrings - both public and non-obvious private helpers.
- Missing test fixture docstrings - complex fixtures that set up mocks or state.
- Missing `Args`, `Returns`, `Raises`, or `Example` sections where they apply.
- Unexplained Salesforce, Python, or business terms - abbreviations and jargon.

Do **not** change runtime behaviour. Audit only.

---

## Step 2: Output Format

Return a structured report:

```markdown
# Docstring Audit Report

## Summary

[Plain-English summary of overall docstring quality - 3-5 sentences.]

## Ground Truth Method

[Confirm: "All findings derived from reading each function's implementation.
No existing docstring or sibling function used as source of truth."]

## Files Reviewed

| File | Result | Notes |
| --- | --- | --- |
| `src/sf_admin_utils/foo.py` | ⚠ Gaps found | 3 functions missing docstrings |
| `scripts/bar.py` | ✅ Good | No gaps found |

## Accuracy Issues (Fix First)

| File | Line | Object | Category | Detail |
| --- | --- | --- | --- | --- |

## Missing Docstrings

| File | Line | Object Type | Object Name | Why It Needs a Docstring |
| --- | --- | --- | --- | --- |

## Weak or Stale Docstrings

| File | Line | Object | Problem | Recommended Fix |
| --- | --- | --- | --- | --- |

## Recommended Remediation Order

1. [Accuracy fixes first - invented and stale claims]
2. [Omissions next - missing parameters or exceptions]
3. [Then beginner expansions - too terse for a complete beginner]

## Safe to Auto-Fix?

[Yes - all gaps are additions only, no behaviour changes required.]
[or: No - some stale docstrings need behaviour confirmation before rewriting.]
```

---

## If Asked to Fix

When the user asks you to fix the docstrings after the audit:

1. Update only docstrings and explanatory comments.
2. Do **not** change imports, logic, tests, type hints, formatting, or behaviour.
3. **Re-derive every claim from the implementation** - never from the existing
   docstring text or a similar function.
4. Keep all language beginner-friendly and plain-English.
5. Use Google-style docstrings as shown in `./.github/skills/docstring.skill.md`.
6. Explain Salesforce and Python terms on first use (see term tables in the skill).
7. If a behaviour change seems necessary while writing the docstring, stop and
   flag the ambiguity rather than silently changing behaviour.

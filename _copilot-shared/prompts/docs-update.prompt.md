---
description: "Update project documentation after a code or workflow change."
mode: agent
---

<!-- markdownlint-disable MD041 -->

Update documentation for the current code or workflow change.

Review:

- README.md
- CONTRIBUTING.md
- docs/**/*.md
- .env.example
- dependency_management.md
- relevant guide files

For each affected document:

1. Explain what needs updating.
2. Make the smallest accurate change.
3. Keep wording beginner-friendly.
4. Explain technical terms on first use.
5. Add examples where helpful.
6. Add troubleshooting notes for likely beginner errors.
7. Avoid exposing secrets or personal data.

Docstring requirements:

1. Add or update beginner-friendly Google-style docstrings for any new or
   modified module, class, function, or complex test fixture touched during
   the documentation update.
2. Review nearby existing docstrings and improve any that are missing, stale,
   misleading, or too terse.
3. Do not change runtime behaviour while improving docstrings.
4. Explain Salesforce, Python, and business terms in plain English.

After editing, summarize:

- Files changed.
- What changed.
- Any docs intentionally not updated.

## Output format

Return:

```markdown
# Documentation Update Summary

## Verdict

COMPLETE / PARTIAL / BLOCKED

## Summary

Short plain-English summary of what documentation was updated and why.

## Trigger

[What code or workflow change prompted this documentation update.]

## Files Updated

| File | Section Changed | What Changed | Why |
| --- | --- | --- | --- |

## Files Reviewed But Not Changed

| File | Reason |
| --- | --- |

## Docstrings Improved

| File | Function/Class | Change |
| --- | --- | --- |

## Terms Explained

| Term | Where Explained | Plain-English Meaning |
| --- | --- | --- |

## Remaining Documentation Gaps

| File | Gap | Recommended Action |
| --- | --- | --- |

## Behaviour Change

None. This was a documentation-only update.
```

## Output style rules

Use beginner-friendly language.

Explain technical terms on first use.

Do not change runtime behaviour while updating documentation.

Do not invent file paths, command outputs, or configuration values.

Clearly separate facts derived from code from explanatory prose.

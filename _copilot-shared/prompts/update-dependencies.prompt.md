---
description: "Safely update dependencies using pip-tools."
mode: agent
---

Help update dependencies using this project's pip-tools workflow.

Rules:

1. Do not hand-edit generated `.txt` files.
2. Edit `.in` files only for top-level dependency changes.
3. Use `pip-compile` to regenerate `.txt` files.
4. Use `pip install -r requirements-dev.txt` to install.
5. Run sanity checks after updating.
6. If a package is unavailable in the Ford mirror, suggest an available version
   constraint in the `.in` file.
7. Summarize dependency changes from `git diff`.

Commands to use:

```bat
pip-compile requirements.in
pip-compile requirements-dev.in
pip install -r requirements-dev.txt
ruff check src tests scripts
pytest
mypy src tests scripts
```

## Output format

Return:

```markdown
# Dependency Update Summary

## Verdict

PASS / NEEDS ATTENTION / BLOCKED

## Summary

Short plain-English summary of what was updated and the outcome.

## Changes Made

| File | Package | Previous Version | New Version | Why Updated |
| --- | --- | --- | --- | --- |

## Packages Not Updated

| Package | Current | Latest | Why Not Updated |
| --- | --- | --- | --- |

## Validation Results

| Check | Status | Notes |
| --- | --- | --- |
| pip-compile | PASS/FAIL |  |
| pip install | PASS/FAIL |  |
| ruff check | PASS/FAIL |  |
| pytest | PASS/FAIL |  |
| mypy | PASS/FAIL |  |

## Breaking Changes or Deprecations

| Package | Change | Impact | Action Needed |
| --- | --- | --- | --- |

## Security Notes

| Package | Advisory | Severity | Action |
| --- | --- | --- | --- |

## Next Steps

1. [Any follow-up actions needed]
```

## Output style rules

Use beginner-friendly language.

Explain what pip-compile does and why `.txt` files should not be hand-edited.

Do not invent version numbers, security advisories, or validation results.

Do not update `.txt` files directly - always use pip-compile.

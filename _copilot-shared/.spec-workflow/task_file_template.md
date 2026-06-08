# Task [XXX]: [Task Name]

> **Applied Skill:** `.github/skills/[name].skill.md` — [which rule is enforced]

## 1. Plain-English Summary

[2-4 sentences explaining what this task does and why it matters, written for
someone who has never seen the codebase. Avoid jargon or explain it inline.]

## 2. Pre-Work Checks

Run these before starting. If any fail, stop and resolve first.

| Check | Command | Expected Result |
| --- | --- | --- |
| [What to verify] | `[command]` | [What success looks like] |

## 3. Files to Modify / Create

| File Path | Action | What Changes |
| --- | --- | --- |
| `src/sf_admin_utils/[module].py` | Modify existing | [Brief description] |
| `tests/test_[module].py` | Create new | [Brief description] |

## 4. Code Implementation

**Imports to add:**

```python
# Add at top of file, in the "local application" import group
from sf_admin_utils.module import function_name
```

**Code to add/replace:**

- **Location:** [e.g., "After the `query_all` function definition, before `main()`"]
- **Snippet:**

```python
def new_function(param: str) -> list[dict]:
    """One-line description.

    Args:
        param: What this parameter means.

    Returns:
        List of record dictionaries from Salesforce.
    """
    # Implementation here
    return results
```

**Docstring requirements:**

- Every new or modified module, class, and function must have a beginner-friendly
  Google-style docstring.
- Explain what the code does, why it exists, what each parameter means, what is
  returned, and what exceptions can be raised.
- If the function is non-obvious, include a small usage example.
- After implementation, review nearby existing code and add or improve docstrings
  where they are missing or unclear.

## 5. Behaviour Changes

- [What the user or developer will notice is different after this task.]
- [Or: "None — internal refactor only."]

## 6. Behaviour Preserved

- [What stays exactly the same — CLI interface, output format, exit codes, etc.]

## 7. Gotchas

| # | Gotcha | How to catch it |
| --- | --- | --- |
| 1 | [What could go wrong or confuse a developer] | [Command or check to verify] |

## 8. Validation Steps

Run these commands — all must pass before this task is complete:

```bash
ruff check .
ruff format --check .
mypy
pytest tests/test_<relevant>.py --tb=short -q
```

**Docstring validation:** After implementation, manually review all new and
modified functions to confirm they have beginner-friendly Google-style
docstrings. Check that `Args`, `Returns`, `Raises`, and `Example` sections
are present where applicable. If `scripts/audit_docstrings.py` exists, run:

```bash
python scripts/audit_docstrings.py --paths src scripts --fail-on-missing
```

> If that script does not yet exist, perform a manual docstring review instead
> and record any gaps as follow-up tasks.

Expected: zero ruff/mypy errors, all tests green, all docstrings complete.

## 9. Risks and Rollback

| Risk | Likelihood | Mitigation |
| --- | --- | --- |
| [What could go wrong] | [Low/Medium/High] | [How to prevent or recover] |

**Rollback:** `git checkout -- [files]` or `git revert HEAD`

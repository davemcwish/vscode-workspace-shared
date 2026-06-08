# Workflow: Docstring Remediation

## Purpose

Use this workflow to review and improve Python docstrings across the project
without changing runtime behavior.

The goal is to make the codebase easier for beginner developers, beginner
Salesforce users, and future maintainers to understand.

## When To Use This Workflow

Use this workflow when:

- adding new Python code,
- modifying existing Python code,
- preparing code for wider team adoption,
- onboarding beginner developers,
- reviewing old scripts,
- converting legacy scripts into maintained project code,
- improving maintainability without changing behavior.

---

## Primary Rule

Docstring remediation must be behavior-neutral.

You may change:

- module docstrings,
- class docstrings,
- function and method docstrings,
- complex pytest fixture docstrings,
- explanatory comments where they explain business rules or safety behavior.

You must not change:

- executable logic,
- function signatures,
- imports,
- tests,
- configuration,
- CLI arguments,
- runtime behavior,
- output formats.

If you discover unclear or risky behavior while documenting the code, record it
as a follow-up task instead of changing it during docstring remediation.

---

## Step 1: Choose the Scope

Decide whether to review:

- one file,
- one folder,
- all files changed in the current branch,
- all of `src/`,
- all of `scripts/`,
- all of `tests/`,
- the whole repository.

Recommended beginner-friendly starting point:

```text
Review only files changed in the current branch.
```

This keeps the pull request small and easy to review.

---

## Step 2: Read the Standards

Review these files before editing:

- `.github/instructions/python.instructions.md`
- `.github/instructions/docstrings.instructions.md`
- `.github/skills/python.skill.md`
- `.github/skills/docstring.skill.md`
- `.github/instructions/salesforce.instructions.md`
- `.github/instructions/security.instructions.md`
- `.github/instructions/testing.instructions.md`

If any of those files do not exist yet, follow the available Python, testing,
Salesforce, and security instructions.

---

## Step 3: Audit Docstrings

**Use one of:**

- `docstring-auditor.agent.md`
- `docstring-audit.prompt.md`

Check each Python file for:

- [ ] module docstring,
- [ ] class docstrings,
- [ ] function and method docstrings,
- [ ] `parse_args()` docstring for CLI scripts,
- [ ] `main()` docstring for CLI scripts,
- [ ] complex pytest fixture docstrings,
- [ ] docstrings that match the real behavior,
- [ ] plain-English Salesforce explanations,
- [ ] plain-English security and PII explanations,
- [ ] `Args`, `Returns`, `Raises`, and `Example` sections where useful.

---

## Step 4: Categorise Findings

Use this table format:

| Category | Meaning | Example |
| --- | --- | --- |
| Missing | No docstring exists | A public function has no docstring |
| Weak | Docstring exists but is too vague | "Process records" |
| Stale | Docstring no longer matches behavior | Says CSV but function writes JSON |
| Too technical | Assumes expert knowledge | Uses SOQL, CLI alias, or PII without explanation |
| Incomplete | Missing important sections | No Args or Raises for non-trivial function |
| Risk unclear | Does not explain safety behavior | Production dry-run behavior not documented |

---

## Step 5: Improve Docstrings

Use Google-style docstrings.

A good function docstring should usually include:

```python
def example_function(value: str) -> str:
    """Convert a raw input value into the cleaned form used by the script.

    This helper keeps input cleanup in one place so the rest of the script can
    work with predictable values.

    Args:
        value: Raw text value supplied by the user or read from a file.

    Returns:
        Cleaned text value with surrounding whitespace removed.

    Raises:
        ValueError: Raised when the cleaned value is empty.

    Example:
        ```python
        cleaned = example_function(" Contract A ")
        ```
    """
```

For very simple functions, keep the docstring concise but still useful.

---

## Step 6: Explain Salesforce and Safety Context

When a function touches Salesforce, explain:

- whether it is read-only or mutating,
- which Salesforce object is involved,
- whether the data may contain PII,
- whether Production is allowed,
- whether dry-run behavior exists,
- how errors are surfaced.

Example:

```python
def fetch_user_records(client: SalesforceClient) -> list[dict[str, object]]:
    """Fetch Salesforce User records for reporting.

    This function is read-only. It queries Salesforce User records but does not
    create, update, or delete any Salesforce data.

    User records may contain PII, such as names and email addresses, so callers
    must avoid logging full record payloads.

    Args:
        client: Authenticated Salesforce client used to run the query.

    Returns:
        List of Salesforce User records represented as dictionaries.

    Raises:
        SalesforceApiError: Raised when Salesforce returns an error response.
    """
```

---

## Step 7: Explain Test Fixtures

Complex pytest fixtures must explain what they fake and why.

Example:

```python
@pytest.fixture
def mock_salesforce_query(monkeypatch: pytest.MonkeyPatch) -> None:
    """Replace the real Salesforce query function with a safe fake.

    Unit tests must never contact a real Salesforce org. This fixture makes the
    test use predictable local data instead of a network call.

    Args:
        monkeypatch: pytest helper used to temporarily replace real functions
            during a test.
    """
```

---

## Step 8: Run Validation

Docstring-only changes should still pass the normal quality checks.

Run:

```bash
ruff format --check src tests scripts
ruff check src tests scripts
mypy
pytest --tb=short -q
```

If documentation examples include Python snippets, check that they are accurate.

---

## Step 9: Review the Diff

Review the diff carefully.

Confirm:

- [ ] only docstrings and explanatory comments changed,
- [ ] no executable code changed,
- [ ] no behavior changed,
- [ ] no secrets or PII were added,
- [ ] docstrings match the actual code,
- [ ] beginner explanations are clear,
- [ ] Salesforce and Production safety wording is accurate.

---

## Step 10: Report the Result

Use this format:

```markdown
# Docstring Remediation Summary

## Scope

[Files or folders reviewed.]

## Files Updated

| File | What Changed |
| --- | --- |

## Files Reviewed But Not Changed

| File | Reason |
| --- | --- |

## Behavior Change

None. This was a docstring-only change.

## Validation

| Check | Result |
| --- | --- |
| ruff format --check | PASS/FAIL |
| ruff check | PASS/FAIL |
| mypy | PASS/FAIL |
| pytest | PASS/FAIL |

## Follow-Up Items

- [Any unclear behavior discovered while documenting.]
```

---

## Recommended Pull Request Style

Use a small dedicated PR when touching many docstrings.

Suggested branch name:

```text
docs/improve-python-docstrings
```

Suggested commit message:

```text
docs: improve beginner-friendly Python docstrings
```

---

## Done Checklist

- [ ] Scope selected.
- [ ] Standards reviewed.
- [ ] Audit completed.
- [ ] Missing docstrings added.
- [ ] Weak or stale docstrings improved.
- [ ] Salesforce terms explained.
- [ ] PII and Production safety context explained.
- [ ] Test fixtures documented.
- [ ] No runtime behavior changed.
- [ ] Quality checks pass.
- [ ] Summary produced.

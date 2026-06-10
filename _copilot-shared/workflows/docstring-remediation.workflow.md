# Workflow: Docstring Remediation

## Purpose

Use this workflow to review and improve Python docstrings across the project
without changing runtime behavior.

The goal is accuracy first, then beginner-friendliness. A beginner trusts
docstrings completely and cannot spot an invented parameter or a wrong return
type, so correctness is the priority of this workflow - beginner prose is
applied on top of confirmed facts.

## Why This Workflow Exists

A normal docstring writing pass and a remediation pass must use DIFFERENT
methods, or they fail the same way.

- A writing pass reads code and produces beginner prose.
- This remediation pass reads the implementation, extracts ground truth
  mechanically, and DIFFS existing docstrings against it.

If a remediation pass simply re-reads docstrings and rewrites them, it will
repeat the original hallucination - two LLM passes using the same method
produce correlated errors, not independent ones. This workflow therefore
anchors every check to the code implementation itself, never to an existing
docstring or a similar function.

## When To Use This Workflow

Use this workflow when:

- adding new Python code,
- modifying existing Python code,
- preparing code for wider team adoption,
- onboarding beginner developers,
- reviewing old scripts,
- a docstring is suspected of being inaccurate (wrong parameters, invented
  exceptions, stale descriptions),
- converting legacy scripts into maintained project code,
- improving maintainability without changing behavior.

For writing brand-new documentation guides, use `doc-writing.workflow.md`.
For auditing existing documentation guides, use
`doc-writer-remediation.workflow.md`.

---

## Primary Rule

Docstring remediation is anchored to the code implementation itself  - 
never to an existing docstring or a similar function.

Docstring remediation must also be behavior-neutral.

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

## Standards Reference

Before remediating, load these files:

- `.github/skills/docstring.skill.md` - **all writing rules, accuracy rules,
  term tables, and the 1:1 audit method** (read this first)
- `.github/instructions/docstrings.instructions.md` - audience, accuracy, ground truth rules
- `.github/instructions/python.instructions.md` - Python coding standards
- `.github/skills/python.skill.md` - Python skill reference
- `.github/instructions/salesforce.instructions.md` - Salesforce safety rules
- `.github/instructions/security.instructions.md` - secrets and PII rules
- `.github/instructions/testing.instructions.md` - pytest conventions

If any of those files do not exist yet, follow the available Python, testing,
Salesforce, and security instructions.

---

## Overview

```text
Establish ground truth (read the implementation)
  -> Choose the scope
  -> Load the standards
  -> Audit docstrings against code (1:1 set arithmetic)
  -> Categorise findings
  -> Apply fixes (re-derived from implementation only)
  -> Beginner-friendliness pass
  -> Run quality checks
  -> Review the diff
  -> Report
```

---

## Step 0: Establish Ground Truth (Do This First)

> **Do this BEFORE looking at any existing docstring. This is the single most
> important accuracy step.**

For every function whose docstring you will remediate, read its implementation
to confirm:

1. **What parameters it accepts** - names, types, valid values, defaults.
2. **What it returns** - the actual type and meaning of the return value.
3. **What exceptions it raises** - trace the `raise` statements and unhandled
   propagations.
4. **What side effects it performs** - file writes, API calls, database
   mutations, logging.
5. **Whether it is read-only or mutating** - does it change external state?

Treat the implementation as the ONLY source of truth. Never rely on:

- an existing docstring that may be stale,
- a similar function's docstring (it may be wrong or different),
- what would make logical sense for a function with that name.

Rules:

- Never copy docstring content from a sibling function - similar functions
  often have legitimately different behavior, and the sibling may itself be
  wrong.
- Never infer behavior from the function name alone.
- If the implementation is unclear, flag it for manual review. Do not fill
  the gap with invention.

You will use this ground truth in Step 3 (the 1:1 audit) and Step 5 (applying
fixes).

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

## Step 2: Load the Standards

Open and read `.github/skills/docstring.skill.md` before remediating anything.

It contains the audience definition, accuracy rules (including the ground truth
rule), the Two Jobs principle, beginner-friendly language rules with term
explanation tables, the 1:1 audit methodology, and the Critical Constraints.

If you skip this step, you risk writing docstrings that are too technical,
inaccurate, or missing required sections.

---

## Step 3: Audit Docstrings (1:1 Comparison Against Code)

> **This is not a read-through. It is set arithmetic.**

For each function, compare what the docstring claims against the ground truth
you captured in Step 0.

**Use one of:**

- `docstring-auditor.agent.md`
- `docstring-audit.prompt.md`

Check each Python file mechanically:

- [ ] module docstring - does it accurately describe the file?
- [ ] class docstrings - do they match the class's actual behaviour?
- [ ] function and method docstrings - 1:1 against the implementation:
  - Parameters in docstring vs parameters in code (any invented? any omitted?)
  - Return value in docstring vs actual return (wrong type? wrong meaning?)
  - Raises in docstring vs actual raise statements (invented exceptions? omitted ones?)
  - Side effects described vs actual side effects
- [ ] `parse_args()` docstring for CLI scripts,
- [ ] `main()` docstring for CLI scripts,
- [ ] complex pytest fixture docstrings,
- [ ] plain-English Salesforce explanations,
- [ ] plain-English security and PII explanations,
- [ ] `Args`, `Returns`, `Raises`, and `Example` sections where useful.

---

## Step 4: Categorise Findings

Use this table format (mirrors the documentation remediation categories):

| Category | Meaning | Example |
| --- | --- | --- |
| Invented | Docstring claims something the code does not do | Docstring lists a `Raises: FileNotFoundError` but the function never raises it |
| Omitted | Code does something the docstring does not mention | Function raises `ValueError` but docstring has no `Raises` section |
| Wrong type | Docstring type disagrees with type hint/implementation | Docstring says returns `list` but function returns `dict` |
| Stale | Docstring describes old behaviour | Says "writes CSV" but function now writes Excel |
| Too technical | Assumes expert knowledge | Uses "SOQL", "monkeypatch", or "CLI alias" without explanation |
| Incomplete | Missing important sections | No `Args` or `Raises` for a non-trivial function |
| Risk unclear | Does not explain safety behavior | Production dry-run behavior not documented |
| Missing | No docstring at all | Public function with no docstring |

The first four categories are **accuracy defects** and must be fixed by
re-reading the implementation. The remainder are **clarity defects** - fix
them too, but never let a clarity rewrite introduce a new accuracy defect.

This categorisation exists because of a real pattern: when docstrings are
remediated without anchoring to the code, the same hallucinations propagate
from the old docstring into the new one. Categorising forces you to identify
exactly what is wrong and derive the fix from the implementation, not from
rephrasing the existing text.

---

## Step 5: Improve Docstrings

For each finding:

1. Make the smallest change that corrects the fact.
2. **Re-derive every corrected value from the implementation captured in
   Step 0** - never from the existing docstring, another function's docstring,
   or what "makes sense".
3. For omitted parameters or exceptions, add a beginner-friendly description:
   explain what it means in plain English, its type, valid values, and when a
   beginner would encounter it.
4. For invented claims, remove the false information entirely (do not try to
   "make it true").
5. For stale descriptions, rewrite to match the current implementation.
6. Preserve all existing security and PII warnings. Never remove them.

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

- [ ] Ground truth established by reading each implementation (Step 0).
- [ ] Scope selected.
- [ ] Standards loaded (docstring.skill.md read first).
- [ ] 1:1 audit completed (set arithmetic against implementation).
- [ ] Findings categorised (invented/omitted/stale/wrong/terse/missing).
- [ ] Accuracy fixes re-derived from implementation (not from existing text).
- [ ] Missing docstrings added.
- [ ] Weak or stale docstrings improved.
- [ ] Salesforce terms explained on first use.
- [ ] PII and Production safety context explained.
- [ ] Test fixtures documented.
- [ ] No invented parameters, returns, or exceptions remain.
- [ ] No runtime behavior changed.
- [ ] Quality checks pass.
- [ ] Summary produced.

---

## Copilot Assets for This Workflow

| Asset | When to use |
| --- | --- |
| `agents/docstring-auditor.agent.md` | Systematic audit and improvement |
| `chatmodes/docstring-review.chatmode.md` | Interactive docstring review session |
| `prompts/improve-docstrings.prompt.md` | Quick docstring improvement |
| `prompts/docstring-audit.prompt.md` | One-command accuracy audit |
| `skills/docstring.skill.md` | Writing standards reference (load before editing) |
| `instructions/docstrings.instructions.md` | Audience, accuracy, ground truth rules |
| `workflows/docstring-writing.workflow.md` | For writing new docstrings during development |
| `workflows/doc-writing.workflow.md` | For project documentation (guides, README) |
| `workflows/doc-writer-remediation.workflow.md` | For auditing documentation guides |

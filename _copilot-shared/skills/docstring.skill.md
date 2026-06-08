# Skill: Beginner-Friendly Python Docstrings

## Purpose

Every Python file in this project must be understandable to a beginner who
has not worked on this repository before — including beginners who are new to
Python, new to Salesforce automation, or both.

Docstrings are not optional decoration. They are part of the maintainability,
onboarding, testing, and review standard for this project.

---

## Required Style: Google-Style Docstrings

Every module, class, function, method, and complex pytest fixture must have a
Google-style docstring that explains:

- **What it does** — one clear summary sentence.
- **Why it exists** — the business or technical reason (not obvious from the name alone).
- **What each argument means** — type, purpose, valid values, and Salesforce context where relevant.
- **What it returns** — the type and meaning of the return value.
- **What exceptions it may raise** — and under what conditions.
- **Any Salesforce or business assumptions** — org type, SOQL limits, PII, Production safety.
- **A short usage example** — for any function that is non-obvious.

---

## Module Docstring

Every Python file must begin with a module-level docstring immediately after
any `from __future__ import annotations` line.

The module docstring explains what the file is for, what its public API is,
and whether it modifies Salesforce data.

**Example:**

```python
"""Export contract PDF files from Salesforce.

This module contains the command-line workflow for finding contract records in
Salesforce, downloading their attached PDF files, and writing them to a local
output folder.

The script is read-only. It does not change any Salesforce data.

Usage::

    python scripts/export_contract_pdfs_prod.py --org uat --output-dir output/
"""
```

---

## Function and Method Docstring

**Example:**

```python
def chunk_record_ids(record_ids: list[str], chunk_size: int = 200) -> list[list[str]]:
    """Split Salesforce record IDs into safe SOQL query chunks.

    Salesforce queries become unreliable when too many IDs are placed into a
    single ``WHERE Id IN (...)`` clause. This helper keeps each chunk small
    enough for predictable API behaviour.

    Args:
        record_ids: Salesforce record IDs to split into smaller groups.
        chunk_size: Maximum number of IDs per group. Defaults to 200 because
            that is the project standard for Salesforce ``IN`` queries.

    Returns:
        A list of ID groups. Each inner list contains at most ``chunk_size``
        record IDs. Returns an empty list when ``record_ids`` is empty.

    Raises:
        ValueError: If ``chunk_size`` is less than 1.

    Example:
        ```python
        chunks = chunk_record_ids(["001AA", "001BB", "001CC"], chunk_size=2)
        # Returns: [["001AA", "001BB"], ["001CC"]]
        ```
    """
```

---

## Class Docstring

**Example:**

```python
class SalesforceSession:
    """Manage an authenticated Salesforce REST API session.

    Authenticates using the Salesforce CLI (``sf org display``) and wraps the
    resulting access token in a ``requests.Session`` for all downstream API
    calls. Sessions are read-only by default — mutation requires explicit
    method calls that confirm Production safety.

    Args:
        alias: The Salesforce CLI org alias (e.g. ``"AXP_PROD"`` or
            ``"AXP_UAT"``). Must match an alias already authenticated
            via ``sf org login``.

    Raises:
        RuntimeError: If the CLI is not installed or the alias is not
            authenticated.
    """
```

---

## Test Fixture Docstrings

Complex pytest fixtures that create fake data, mock objects, or multi-step
state must have docstrings explaining what they fake and why.

**Example:**

```python
@pytest.fixture
def fake_salesforce_query_response() -> dict[str, object]:
    """Return a minimal fake Salesforce query response for unit tests.

    The tests use this fixture instead of calling a real Salesforce org.
    This keeps tests fast, repeatable, and safe for offline development.

    The structure mirrors the real ``simple_salesforce`` query response:
    ``{"totalSize": N, "done": True, "records": [...]}``.
    """
    return {"totalSize": 2, "done": True, "records": [
        {"Id": "001AA", "Status": "Submitted"},
        {"Id": "001BB", "Status": "InProduction"},
    ]}
```

---

## Beginner-Friendly Language Rules

Docstrings in this project must be written for someone who may be:

- new to Python,
- new to Salesforce,
- new to this codebase.

That means:

- Explain Salesforce terms on first use (e.g. "SOQL — Salesforce's version of SQL").
- Explain why a safety check exists, not just that it exists.
- Describe whether the function is **read-only or mutating**.
- Mention if data may contain **PII** (Personally Identifiable Information).
- Explain expected file paths or directory structures.
- Do not use unexplained abbreviations.

---

## Review Checklist

When reviewing or writing Python code, check every file for:

- [ ] Module docstring exists and is accurate.
- [ ] Every public function and method has a Google-style docstring.
- [ ] Private helpers (`_name`) have docstrings when their purpose is not
      obvious from the name alone.
- [ ] Complex test fixtures have docstrings.
- [ ] `Args`, `Returns`, `Raises`, and `Example` sections are present where useful.
- [ ] Salesforce and business terms are explained in plain English.
- [ ] Docstrings accurately reflect the actual behaviour of the code.
- [ ] Improving a docstring has not accidentally changed runtime behaviour.
- [ ] Existing nearby docstrings were reviewed and improved if stale or missing.

---

## What NOT to Write

Avoid these common docstring mistakes:

| Bad example | Why it's bad |
| --- | --- |
| `"""Gets the records."""` | Repeats the function name; adds no information. |
| `"""See the code."""` | Sends the reader backwards; defeats the purpose. |
| `Args:\n    x: x` | Restates the parameter name without explaining it. |
| Leaving `Raises` empty when errors are possible | Hides failure modes from the caller. |
| Long prose with no structure | Hard to scan; use sections. |

---

## Validation

There is no fully automated docstring enforcement tool in the current pipeline.

Until a `scripts/audit_docstrings.py` tool is added:

- The **code reviewer** must manually check all new and modified Python files
  against this skill during every code review.
- The **docstring-auditor agent** can be used to perform a systematic scan on
  request.
- The `--fail-on-missing` capability is a planned future improvement tracked
  in §8.6 of `docs/salesforce-admin-utilities-guide.md`.

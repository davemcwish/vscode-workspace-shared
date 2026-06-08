# Skill: Beginner-Friendly Python Docstrings

## Purpose

Every Python file — and every batch, PowerShell, and shell script — in this
project must be understandable to a beginner who has not worked on this
repository before, including beginners who are new to Python, new to the
project's domain, or both.

Docstrings and script comment blocks are not optional decoration. They are
part of the maintainability, onboarding, testing, and review standard for
this project.

---

## The Doubt Rule

**If you are ever unsure whether a docstring or comment block is needed —
always add it.**

The cost of an unnecessary docstring is near-zero. The cost of a missing
docstring to a confused maintainer is hours of investigation. Always document
at complete-beginner level when in doubt. This rule applies to Python, batch
scripts (`.bat`), PowerShell scripts (`.ps1`), and shell scripts (`.sh`).

---

## Required Style: Google-Style Docstrings

Every module, class, function, method, and complex pytest fixture must have a
Google-style docstring that explains:

- **What it does** — one clear summary sentence.
- **Why it exists** — the business or technical reason (not obvious from the name alone).
- **What each argument means** — type, purpose, valid values, and domain context where relevant.
- **What it returns** — the type and meaning of the return value.
- **What exceptions it may raise** — and under what conditions.
- **Any domain or business assumptions** — system type, API limits, PII, production safety.
- **A short usage example** — for any function that is non-obvious.

---

## Module Docstring

Every Python file must begin with a module-level docstring immediately after
any `from __future__ import annotations` line.

The module docstring explains what the file is for, what its public API is,
and whether it modifies external state (databases, APIs, files).

**Example:**

```python
"""Export records from the reporting system to local CSV files.

This module provides the command-line workflow for querying records,
downloading attachments, and writing them to a local output folder.

The script is read-only with respect to the external system.

Usage::

    python scripts/export_records.py --target prod --output-dir output/
"""
```

---

## Function and Method Docstring

**Example:**

```python
def chunk_ids(ids: list[str], chunk_size: int = 200) -> list[list[str]]:
    """Split a list of record IDs into smaller groups for safe batch queries.

    Many APIs and query systems become unreliable when too many IDs are placed
    into a single request. This helper keeps each chunk small enough for
    predictable behaviour.

    Args:
        ids: Record IDs to split into smaller groups.
        chunk_size: Maximum number of IDs per group. Defaults to 200.

    Returns:
        A list of ID groups. Each inner list contains at most ``chunk_size``
        IDs. Returns an empty list when ``ids`` is empty.

    Raises:
        ValueError: If ``chunk_size`` is less than 1.

    Example:
        ```python
        chunks = chunk_ids(["A1", "A2", "A3"], chunk_size=2)
        # Returns: [["A1", "A2"], ["A3"]]
        ```
    """
```

---

## Class Docstring

**Example:**

```python
class APISession:
    """Manage an authenticated REST API session.

    Authenticates using the project's configured credentials and wraps the
    resulting token in a ``requests.Session`` for downstream API calls.
    Sessions are read-only by default — mutation requires explicit method
    calls that confirm production safety.

    Args:
        alias: The org/environment alias (e.g. ``"prod"`` or ``"staging"``).
            Must match an alias already configured in the project's `.env`.

    Raises:
        RuntimeError: If credentials are missing or authentication fails.
    """
```

---

## Test Fixture Docstrings

Complex pytest fixtures that create fake data, mock objects, or multi-step
state must have docstrings explaining what they fake and why.

**Example:**

```python
@pytest.fixture
def fake_api_query_response() -> dict[str, object]:
    """Return a minimal fake query response for unit tests.

    The tests use this fixture instead of calling a real external service.
    This keeps tests fast, repeatable, and safe for offline development.

    The structure mirrors the real API response format used by this project.
    """
    return {"totalSize": 2, "done": True, "records": [
        {"id": "A1", "status": "active"},
        {"id": "A2", "status": "inactive"},
    ]}
```

---

## Beginner-Friendly Language Rules

Docstrings in this project must be written for someone who may be:

- new to Python,
- new to Salesforce,
- new to this codebase.

That means:

- Explain domain terms on first use (e.g. "SOQL — Salesforce's version of SQL", or
  whatever domain-specific term applies to this project).
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
- [ ] Domain and business terms are explained in plain English.
- [ ] Docstrings accurately reflect the actual behaviour of the code.
- [ ] Improving a docstring has not accidentally changed runtime behaviour.
- [ ] Existing nearby docstrings were reviewed and improved if stale or missing.

When reviewing or writing batch, PowerShell, or shell scripts, check for:

- [ ] Header comment block (`.bat`/`.sh`) or comment-based help block (`.ps1`)
      exists at the top of every script file.
- [ ] Every named PowerShell function has `.SYNOPSIS` and `.DESCRIPTION`.
- [ ] Each numbered step in a batch or shell script has a short explanatory
      `REM` or `#` comment.
- [ ] Usage example is present in the header block.
- [ ] When in doubt — add the comment. The Doubt Rule applies to all file types.

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

There is no fully automated docstring enforcement tool in the standard pipeline.

- The **code reviewer** must manually check all new and modified Python files
  against this skill during every code review.
- The **docstring-auditor agent** (or `docstring-review.chatmode.md`) can be
  used to perform a systematic scan on request.

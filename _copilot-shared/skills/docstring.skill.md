# Skill: Beginner-Friendly Python Docstrings

## Purpose

Every Python file - and every batch, PowerShell, and shell script - in this
project must be understandable to a beginner who has not worked on this
repository before, including beginners who are new to Python, new to the
project's domain, or both.

Docstrings and script comment blocks are not optional decoration. They are
part of the maintainability, onboarding, testing, and review standard for
this project.

---

## Audience

All docstrings must be written for **complete beginners** simultaneously:

- **Complete beginner coders** - can read Python but may not know what a
  decorator, context manager, or generator does without an explanation.
- **Complete beginner Python developers** - knows basic syntax but hasn't used
  type hints, virtual environments, or package management before.
- **Complete beginner domain users** - uses the project's domain system
  day-to-day but has never written a query, used the CLI, or dealt with API
  concepts.

The test: "Could a person who has never written Python professionally, never
used this project's domain APIs, and never worked in a software team understand
this docstring without asking someone?" If not, rewrite.

---

## Accuracy Before Prose

A beginner trusts docstrings completely and cannot spot an invented parameter
or a wrong return type. So accuracy is enforced first, and beginner-friendly
prose is applied on top of confirmed facts - never instead of them.

Two distinct jobs, never mixed:

1. **WHAT the code does** (parameters accepted, values returned, exceptions
   raised, side effects performed) - a matter of FACT, extracted
   deterministically from reading the implementation. Never guessed.
2. **HOW to explain it** (plain-English prose, examples, domain context)  - 
   where your language skill applies, but ONLY to facts confirmed in job 1.

Most docstring bugs come from letting job 2 invent facts that belong to job 1.
Do not do this.

### Ground Truth (read the code before writing the docstring)

Before writing or updating any docstring, read the function's implementation
to confirm:

1. What parameters it accepts - names, types, valid values, defaults.
2. What it returns - the actual type and meaning of the return value.
3. What exceptions it raises - trace the `raise` statements.
4. What side effects it performs - file writes, API calls, mutations, logging.
5. Whether it is read-only or mutating - does it change external state?

Treat the implementation as the ONLY source of truth. Never rely on:

- an existing docstring that may be stale,
- a similar function's docstring (it may be wrong or different),
- your memory of what the function "probably" does,
- what would make logical sense for a function with that name.

### Never Invent to Fill a Gap

If you are unsure whether a function raises a particular exception, returns a
specific type, or has a certain side effect - do NOT write a plausible-sounding
description. Either confirm it from the code, or leave it out and flag it for
manual review. A missing note is recoverable; a confidently wrong note misleads
a beginner who has no way to verify it.

This rule exists because of real defects: docstrings that documented parameters
which did not exist, described return values the function never produced, or
listed exceptions it never raised. Reading the actual implementation and
documenting only what you confirm prevents all three failure modes.

### Never Copy from a Sibling Function

Similar-looking functions (e.g. `export_orders()` and `export_users()`) often
have legitimately different parameters, return types, and side effects. Copying
one docstring into the other propagates errors. Always read each function's own
implementation as the source of truth.

---

## The Doubt Rule

**If you are ever unsure whether a docstring or comment block is needed  - 
always add it.**

The cost of an unnecessary docstring is near-zero. The cost of a missing
docstring to a confused maintainer is hours of investigation. Always document
at complete-beginner level when in doubt. This rule applies to Python, batch
scripts (`.bat`), PowerShell scripts (`.ps1`), and shell scripts (`.sh`).

---

## Required Style: Google-Style Docstrings

Every module, class, function, method, and complex pytest fixture must have a
Google-style docstring that explains:

- **What it does** - one clear summary sentence.
- **Why it exists** - the business or technical reason (not obvious from the name alone).
- **What each argument means** - type, purpose, valid values, and domain context where relevant.
- **What it returns** - the type and meaning of the return value.
- **What exceptions it may raise** - and under what conditions.
- **Any domain or business assumptions** - system type, API limits, PII, production safety.
- **A short usage example** - for any function that is non-obvious.

Do **not** add empty sections. If a function returns `None`, describe its side
effect instead.

### Required Sections

| Section | When to include |
| --- | --- |
| **Summary** | Always - one sentence on the first line. |
| **How it works** | Any function whose algorithm is non-trivial. |
| **Args** | Any function with parameters. |
| **Returns** | Any function that returns a non-`None` value. |
| **Raises** | Any function that raises an exception. |
| **Example** | Any function whose usage is not immediately obvious. |

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
    Sessions are read-only by default - mutation requires explicit method
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

- Write as if explaining to a smart colleague who has never coded before.
- Prefer short sentences. One idea per sentence.
- Use active voice: "Returns a list of..." not "A list is returned by...".
- Explain domain terms on first use (e.g. "SOQL - Salesforce's version of SQL",
  or whatever domain-specific term applies to this project).
- Explain why a safety check exists, not just that it exists.
- Describe whether the function is **read-only or mutating**.
- Mention if data may contain **PII** (Personally Identifiable Information  - 
  names, email addresses, phone numbers - treat as confidential).
- Explain expected file paths or directory structures.
- Do not use unexplained abbreviations.

### Salesforce Terms to Always Explain in Docstrings

| Term | Plain-English explanation to include |
| --- | --- |
| `__c` suffix | "(the `__c` suffix means this is a custom object, not a standard Salesforce one)" |
| SOQL | "(Salesforce Object Query Language - Salesforce's version of SQL for querying its database)" |
| Org | "(an 'org' is a single Salesforce environment - you typically have a Production org and one or more sandbox orgs for testing)" |
| ContentDocumentLink | "(the Salesforce object that links an uploaded file to a record)" |
| ContentVersion | "(represents one version of an uploaded file in Salesforce)" |
| Visualforce | "(a Salesforce page-rendering technology - similar to a server-side HTML template)" |
| Access token / session | "(a temporary password-like string that proves you are logged in - it expires and must be refreshed)" |
| CLI alias | "(a short nickname you give to an org when you log in, so you don't have to type a long URL each time)" |

### Python Terms to Always Explain in Docstrings

| Term | Plain-English explanation to include |
| --- | --- |
| Virtual environment | "(an isolated folder of Python packages - prevents conflicts between projects)" |
| `pip install -e .` | "(installs the local package in editable mode - code changes take effect immediately without reinstalling)" |
| Type hint | "(a label on a function parameter that tells the reader - and the type checker - what kind of value is expected)" |
| Decorator | "(a function that wraps another function to add behaviour - e.g. timing, retry logic)" |
| monkeypatch | "(a pytest tool that temporarily replaces a real function with a fake one during testing)" |
| Mocking | "(replacing a real dependency - like a network call - with a controlled fake during testing)" |
| Generator | "(a function that yields values one at a time instead of returning them all at once - saves memory for large datasets)" |
| Context manager | "(an object used with `with` statements that automatically handles setup and cleanup - e.g. opening and closing files)" |
| `dataclass` | "(a Python class that automatically generates `__init__`, `__repr__`, and comparison methods from field declarations)" |

These tables are not exhaustive. Any term that would confuse a beginner who has
never used Python or Salesforce professionally must be explained at the point it
first appears in a docstring.

### Acronyms in Docstrings

Expand every acronym on first use within each docstring:

```python
# Bad
"""Upload files to EDMS after zipping."""

# Good
"""Upload files to EDMS (the Electronic Document Management System) after zipping."""
```

---

## Review Checklist (1:1 Audit)

When reviewing or writing Python code, perform a 1:1 audit on every docstring  - 
compare what the docstring claims against what the code does, treating it as set
arithmetic:

- **Invented** - docstring describes a parameter, return value, or exception
  that does not exist in the code.
- **Omitted** - code has a parameter, return path, or exception that the
  docstring does not mention.
- **Wrong type** - docstring states a type that disagrees with the type hint or
  implementation.
- **Stale** - docstring describes behaviour the code no longer has.
- **Too terse** - docstring exists but is useless to a beginner.

Then check:

- [ ] Module docstring exists and is accurate.
- [ ] Every public function and method has a Google-style docstring.
- [ ] Private helpers (`_name`) have docstrings when their purpose is not
      obvious from the name alone.
- [ ] Complex test fixtures have docstrings.
- [ ] `Args`, `Returns`, `Raises`, and `Example` sections are present where useful.
- [ ] Domain and business terms are explained in plain English.
- [ ] Docstrings accurately reflect the actual behaviour of the code (no
      inventions, no omissions).
- [ ] Improving a docstring has not accidentally changed runtime behaviour.
- [ ] Existing nearby docstrings were reviewed and improved if stale or missing.

When reviewing or writing batch, PowerShell, or shell scripts, check for:

- [ ] Header comment block (`.bat`/`.sh`) or comment-based help block (`.ps1`)
      exists at the top of every script file.
- [ ] Every named PowerShell function has `.SYNOPSIS` and `.DESCRIPTION`.
- [ ] Each numbered step in a batch or shell script has a short explanatory
      `REM` or `#` comment.
- [ ] Usage example is present in the header block.
- [ ] When in doubt - add the comment. The Doubt Rule applies to all file types.

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

---

## Critical Constraints

- Never invent parameters, return values, or exceptions - only document what
  the code confirms.
- Never copy a docstring from a sibling function - they may be wrong or
  different.
- Never let beginner-friendly prose introduce inaccurate facts.
- Never change runtime behaviour while improving a docstring.
- Never remove security, PII, or production-safety warnings.
- Always read the function's implementation before writing its docstring.
- Always perform the 1:1 audit (invented / omitted / wrong / stale / terse)
  before finalising any docstring.
- Always explain domain terms on first use within each docstring.
- If behaviour is unclear, write a cautious docstring and flag the ambiguity  - 
  do not guess.

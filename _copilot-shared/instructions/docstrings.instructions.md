---
applyTo: "src/**/*.py,scripts/**/*.py,tests/**/*.py"
description: "Mandatory beginner-friendly Python docstring rules."
---

# Beginner-Friendly Docstring Rules

## Primary Rule

Every Python source file in this project must be understandable by a beginner
who is new to this repository, new to Salesforce automation, and still learning
Python.

Docstrings are the primary tool for making code understandable. They are
**mandatory**, not optional.

---

## Required Coverage

Add or update Google-style docstrings for:

- Every **module** — immediately after any `from __future__ import annotations` line.
- Every **class** and its `__init__` method.
- Every **public function** and method.
- Every **private helper** (`_name`) whose purpose is not obvious from its name alone.
- Every `parse_args()` and `main()` CLI function.
- Every **complex pytest fixture** that sets up mocks, fake data, or multi-step state.
- Every **test module** — a one-line description of what it covers is sufficient.

---

## Required Style: Google Sections

Use Google-style docstrings with these sections where applicable:

| Section | When to include |
| --- | --- |
| **Summary** | Always — one sentence on the first line. |
| **Args** | Any function with parameters. |
| **Returns** | Any function that returns a non-`None` value. |
| **Raises** | Any function that raises an exception. |
| **Example** | Any function whose usage is not immediately obvious. |

Do **not** add empty sections. If a function returns `None`, describe its
side effect instead (e.g. "Writes records to `output_path`").

---

## Beginner-Friendly Content Requirements

Every docstring must:

- Explain **Salesforce terms** on first use (e.g. "SOQL — Salesforce's version of SQL").
- Explain **why a safety check exists**, not just that it exists.
- State whether the function is **read-only or mutating** when relevant.
- Mention when data may contain **PII** (Personally Identifiable Information).
- Describe expected **file paths or directory structures** for I/O functions.
- Avoid unexplained abbreviations.
- Use plain English that a non-developer business user could follow.

---

## "How It Works" Paragraphs

Any function whose algorithm is non-trivial (more than a straightforward
getter/setter) must include a **"How it works:"** section in its docstring
that explains the logic in plain English. This mirrors the pattern established
in `joshua-terminal-test-rig.html` and applies to all languages.

Good example:

```python
def estimate_row_count(session: SalesforceSession, object_name: str) -> int:
    """Estimate the number of records in a Salesforce object.

    How it works:
        We execute a lightweight ``SELECT COUNT() FROM Object`` SOQL query.
        Salesforce returns the count directly in the response metadata
        (``totalSize``), so no records are transferred over the network.
        This is much faster than downloading all records and counting them.

    Args:
        session: An authenticated Salesforce session.
        object_name: The API name of the object (e.g. "Account").

    Returns:
        The total number of matching records.
    """
```

---

## Module-Level Structure & Section Headers

Every Python module must be organised into clearly labelled sections using
boxed comment headers. This makes the file scannable — like chapters in a book:

```python
# ============================================================================
# Constants
# ============================================================================

EXCEL_MAX_ROWS = 1_048_575

# ============================================================================
# Data classes
# ============================================================================

@dataclass
class ExportResult:
    ...

# ============================================================================
# Public API
# ============================================================================
```

Use this pattern for any module longer than ~50 lines. Short utility modules
with 2-3 functions may omit the headers.

---

## Existing Code Review Requirement

When Copilot modifies any Python file, it must also review all **existing
docstrings in the same file**.

If existing docstrings are:

- **missing** — add them,
- **stale** (describe behaviour the code no longer has) — update them,
- **misleading** — correct them,
- **too terse for a beginner** — expand them,

then improve them as part of the same change, **unless the user explicitly
says not to**.

---

## Non-Behavioural Rule

Improving or adding docstrings **must not change runtime behaviour**.

If a documentation improvement reveals that the code should behave differently,
stop, note the potential behaviour change, and ask the user whether to create a
separate code-change task.

---

## Docstrings Are Mandatory

Every Python source file must be understandable by a beginner without needing
to ask another developer what the code is for.

Every module, class, public function, private helper, and test fixture must
have a beginner-friendly Google-style docstring unless it is a trivial nested
helper of fewer than five lines.

Docstrings must explain:

- what the code does,
- why it exists,
- what each parameter means,
- what is returned,
- what exceptions can be raised,
- any Salesforce-specific or business-specific assumptions,
- a short example for non-obvious functions.

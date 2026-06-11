---
applyTo: "src/**/*.py,scripts/**/*.py,tests/**/*.py,**/*.bat,**/*.ps1,**/*.sh"
description: "Mandatory complete-beginner docstring and comment-block rules for Python, PowerShell, batch, and shell scripts."
---

# Complete-Beginner Docstring Rules

## Primary Rule

Every source file in this project - Python, PowerShell, batch (`.bat`), and
shell script (`.sh`) - must be understandable by a **complete beginner**:
someone who may never have written code professionally, who has never touched
Salesforce APIs, and who cannot ask a senior developer for help.

**Assume zero prior knowledge.** Do not assume the reader knows what a
decorator is, what a SOQL query does, what an access token is, or why a
function might raise a `ValueError`. Explain all of it.

Docstrings and comment blocks are the primary tool for making code
understandable. They are **mandatory**, not optional.

---

## Accuracy Before Prose

A beginner trusts docstrings completely and cannot spot an invented parameter
description or a wrong return type the way an expert can. So accuracy is
enforced first, and beginner-friendly prose is applied on top of confirmed
facts - never instead of them.

Two distinct jobs, never mixed:

1. **WHAT the code does** (parameters accepted, values returned, exceptions
   raised, side effects performed) - a matter of FACT, extracted
   deterministically from reading the implementation. Never guessed.
2. **HOW to explain it** (plain-English prose, examples, domain context)  - 
   where your language skill applies, but ONLY to facts confirmed in job 1.

Most docstring bugs come from letting job 2 invent facts that belong to job 1.
A confidently wrong docstring is worse than a missing one - it actively
misleads a beginner who has no way to verify it.

### Never Invent to Fill a Gap

If you are unsure whether a function raises a particular exception, returns a
specific type, or has a certain side effect - do NOT write a plausible-sounding
description. Either confirm it from the code, or leave it out and flag it for
manual review.

A missing `Raises` section is recoverable. A `Raises` section listing
exceptions the function never raises sends a beginner on a wild goose chase.

This rule exists because of real defects: docstrings that documented parameters
which did not exist, described return values the function never produced, or
listed exceptions it never raised. Reading the actual implementation and
documenting only what you confirm prevents all three failure modes.

### Never Copy from a Sibling Function

Similar-looking functions (e.g. `export_orders()` and `export_users()`) often
have legitimately different parameters, return types, and side effects.
Copying one docstring into the other propagates errors. Always read each
function's own implementation as the source of truth.

---

## The Doubt Rule

**If you are ever unsure whether a docstring or comment block is needed  - 
always add it.**

The cost of an unnecessary docstring is near-zero. The cost of a missing
docstring to a confused maintainer is hours of investigation. When in doubt,
document it at complete-beginner level.

This rule applies to:

- Python functions, classes, methods, modules, and fixtures.
- PowerShell functions (comment-based help blocks: `.SYNOPSIS`, `.DESCRIPTION`,
  `.PARAMETER`, `.OUTPUTS`, `.EXAMPLE`).
- Batch script header blocks and individual step comments.
- Shell script header blocks and function comments.

---

## Required Coverage

Add or update Google-style docstrings for:

- Every **module** - immediately after any `from __future__ import annotations` line.
- Every **class** and its `__init__` method.
- Every **public function** and method.
- Every **private helper** (`_name`) whose purpose is not obvious from its name alone.
- Every `parse_args()` and `main()` CLI function.
- Every **complex pytest fixture** that sets up mocks, fake data, or multi-step state.
- Every **test module** - a one-line description of what it covers is sufficient.

---

## Required Style: Google Sections

Use Google-style docstrings with these sections where applicable:

| Section | When to include |
| --- | --- |
| **Summary** | Always - one sentence on the first line. |
| **Args** | Any function with parameters. |
| **Returns** | Any function that returns a non-`None` value. |
| **Raises** | Any function that raises an exception. |
| **Example** | Any function whose usage is not immediately obvious. |

Do **not** add empty sections. If a function returns `None`, describe its
side effect instead (e.g. "Writes records to `output_path`").

---

## Establishing Ground Truth (Read Before Writing)

Before writing or updating any docstring, read the function's actual
implementation to confirm:

1. **What parameters it accepts** - names, types, valid values, defaults.
2. **What it returns** - the actual type and meaning of the return value.
3. **What exceptions it raises** - trace the `raise` statements and unhandled
   propagations.
4. **What side effects it performs** - file writes, API calls, database
   mutations, logging.
5. **Whether it is read-only or mutating** - does it change external state?

Treat the implementation as the ONLY source of truth. Do not rely on:

- an existing docstring that may be stale,
- a similar function's docstring (it may be wrong or different),
- your memory of what the function "probably" does,
- what would make logical sense for a function with that name.

If the implementation is unclear, write a cautious docstring describing what
you can confirm and flag the ambiguity - do not fill the gap with invention.

This rule parallels the documentation standard: just as CLI docs must come from
`--help`, docstrings must come from reading the code.

---

## Complete-Beginner Content Requirements

Every docstring must be written as if the reader is a **complete beginner**  - 
no assumed Python experience, no assumed Salesforce knowledge, no assumed
familiarity with this codebase. Concretely, every docstring must:

- Explain **Salesforce terms** on first use (e.g. "SOQL - Salesforce's version of SQL").
- Explain **why a safety check exists**, not just that it exists.
- State whether the function is **read-only or mutating** when relevant.
- Mention when data may contain **PII** (Personally Identifiable Information).
- Describe expected **file paths or directory structures** for I/O functions.
- Avoid unexplained abbreviations.
- Use plain English that a non-developer business user could follow.

### Salesforce Terms to Always Explain in Docstrings

| Term | Plain-English explanation to include |
| --- | --- |
| `__c` suffix | "(the `__c` suffix means this is a custom object, not a standard Salesforce one)" |
| SOQL | "(Salesforce Object Query Language - Salesforce's version of SQL for querying its database)" |
| Org | "(an 'org' is a single Salesforce environment - you typically have a Production org and one or more sandbox orgs for testing)" |
| ContentDocumentLink | "(the Salesforce object that links an uploaded file to a record)" |
| ContentVersion | "(represents one version of an uploaded file in Salesforce)" |
| Access token / session | "(a temporary password-like string that proves you are logged in - it expires and must be refreshed)" |
| CLI alias | "(a short nickname you give to an org when you log in, so you don't have to type a long URL each time)" |

### Python Terms to Always Explain in Docstrings

| Term | Plain-English explanation to include |
| --- | --- |
| Virtual environment | "(an isolated folder of Python packages - prevents conflicts between projects)" |
| Type hint | "(a label on a function parameter that tells the reader - and the type checker - what kind of value is expected)" |
| Decorator | "(a function that wraps another function to add behaviour - e.g. timing, retry logic)" |
| monkeypatch | "(a pytest tool that temporarily replaces a real function with a fake one during testing)" |
| Mocking | "(replacing a real dependency - like a network call - with a controlled fake during testing)" |
| Generator | "(a function that yields values one at a time instead of returning them all at once - saves memory for large datasets)" |
| Context manager | "(an object used with `with` statements that automatically handles setup and cleanup - e.g. opening and closing files)" |

These tables are not exhaustive. Any term that would confuse a beginner who has
never used Python or Salesforce professionally must be explained at the point it
first appears in a docstring - not only in a separate glossary.

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

## Batch, PowerShell, and Shell Script Comment Blocks

The same complete-beginner principle applies to non-Python scripts. The tool
changes, but the obligation to explain does not.

### Batch Scripts (`.bat`)

Every batch script must open with a `REM` header block that explains:

- What the script does (one sentence).
- How to run it (usage line with example).
- What each step does (one comment line per numbered step).

```bat
@echo off
REM ============================================================================
REM  example.bat - short description of what this script does
REM  Usage:  example.bat [optional-arg]
REM
REM  Steps:
REM    1. Activates the virtual environment.
REM    2. Runs the main Python script.
REM    3. Shows success/failure message.
REM ============================================================================
```

### PowerShell Scripts (`.ps1`)

Every PowerShell script must have a comment-based help block at the top:

```powershell
<#
.SYNOPSIS
    One-sentence summary of what the script does.

.DESCRIPTION
    Two-to-four sentences of plain English. Explain what problem it solves
    and when someone should use it.

.PARAMETER ParamName
    What this parameter controls. Include valid values and the default.

.EXAMPLE
    .\example.ps1 -ParamName value
    Description of what this example does.
#>
```

Every **named function** inside a PowerShell script must also have its own
comment-based help (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.OUTPUTS`)
unless the function is trivially obvious from its 3-line body alone.

### Shell Scripts (`.sh`)

Every shell script must open with a comment header:

```bash
#!/usr/bin/env bash
# ==============================================================================
# example.sh - short description
# Usage: ./example.sh [optional-arg]
#
# What it does:
#   1. Step one explanation.
#   2. Step two explanation.
# ==============================================================================
```

---

## Module-Level Structure & Section Headers

Every Python module must be organised into clearly labelled sections using
boxed comment headers. This makes the file scannable - like chapters in a book:

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

## Existing Code Review Requirement (1:1 Audit)

When Copilot modifies any Python file, it must also review all **existing
docstrings in the same file** using a 1:1 audit against the implementation.

Perform this comparison mechanically - treat it as set arithmetic:

- **Invented** - docstring describes a parameter, return value, or exception
  that does not exist in the code.
- **Omitted** - code has a parameter, return path, or exception that the
  docstring does not mention.
- **Wrong type** - docstring states a type that disagrees with the type hint
  or the actual implementation.
- **Stale** - docstring describes behaviour the code no longer has.
- **Too terse** - docstring is technically present but useless to a beginner.

If existing docstrings have any of the above issues:

- **invented** - remove the false claim,
- **omitted** - add the missing information,
- **wrong type** - correct to match the implementation,
- **stale** - rewrite to match current behaviour,
- **too terse** - expand to beginner level,

then improve them as part of the same change, **unless the user explicitly
says not to**.

This parallels the documentation standard: just as a CLI table must match
`--help` with no inventions and no omissions, a docstring must match the code
with no inventions and no omissions.

---

## Non-Behavioural Rule

Improving or adding docstrings **must not change runtime behaviour**.

If a documentation improvement reveals that the code should behave differently,
stop, note the potential behaviour change, and ask the user whether to create a
separate code-change task.

---

## Docstrings Are Mandatory - But Accuracy Is Non-Negotiable

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

**But every claim in a docstring must be confirmed from the implementation.**
A missing docstring is a gap. An inaccurate docstring is a trap. Beginners
cannot tell the difference between a correct docstring and a confidently wrong
one - so never guess, never copy from a similar function, and never write what
"probably" happens. Read the code, confirm the facts, then explain them in
plain English.

---

## Character Encoding in Docstrings and Comments

- **Never use em-dashes or en-dashes** in docstrings, comments, or string
  literals. Use a plain hyphen (`-`) or double-hyphen (`--`) instead.
- **Never use smart/curly quotes** (`\u2018`, `\u2019`, `\u201c`, `\u201d`).
  Use straight ASCII quotes (`'`, `"`) only.
- **Avoid all non-ASCII punctuation** in docstrings and comments: no Unicode
  arrows, tick marks, bullet symbols, or typographic characters.

These characters cause encoding corruption when files move between Windows
(which may default to cp1252) and Linux (GitHub Actions, CI runners) where
UTF-8 is assumed. A garbled `\u00e2\u0080\u0094` in a docstring confuses
beginners and breaks string-matching tools.

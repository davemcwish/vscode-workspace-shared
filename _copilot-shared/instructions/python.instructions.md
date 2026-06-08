---
applyTo: "**/*.py"
description: "Python coding standards for beginner-friendly maintainability."
---

# Python Coding Standards

## Style & Formatting
- Follow PEP 8. Format with `ruff format`; lint with `ruff check`.
- Line length: 100 characters.
- Group imports: stdlib → third-party → local, separated by blank lines.

## Typing
- Add type hints to **all** function/method signatures and public attributes.
- Use `from __future__ import annotations` in new modules.
- Prefer `collections.abc` (`Iterable`, `Mapping`) over `typing` aliases.
- Run `mypy` on `src/`, `scripts/`, and `tests/`. Each folder has its own
  relaxation level configured in `pyproject.toml`:
  - `src/` — strict mode (full type checking).
  - `scripts/` — `disallow_untyped_defs = false` (relaxed for ad-hoc scripts).
  - `tests/` — `disallow_untyped_defs = false` and `disallow_incomplete_defs = false`
    (fixtures and parametrize make strict typing impractical).

## Docstrings Are Mandatory

Every Python source file must be understandable by a beginner without needing to
ask another developer what the code is for.

Every module, class, public function, private helper, and test fixture must have
a beginner-friendly Google-style docstring unless it is a trivial nested helper
of fewer than five lines.

Docstrings must explain:

- what the code does,
- why it exists,
- what each parameter means,
- what is returned,
- what exceptions can be raised,
- any Salesforce-specific or business-specific assumptions,
- a short example for non-obvious functions.

## Docstrings (beginner-friendly, Google style)
Every module, class, and function must have a docstring covering:
- **Summary** — one sentence.
- **Args** — each parameter with type and meaning.
- **Returns** — value and meaning.
- **Raises** — exceptions and the conditions that trigger them.
- **Example** — minimal usage block when the function is non-obvious.

## Naming
- `snake_case` for functions/variables, `PascalCase` for classes,
  `UPPER_SNAKE_CASE` for constants.
- Names must describe intent. Avoid abbreviations except well-known ones
  (`sf` for Salesforce client is acceptable when scoped).

## Functions
- Keep each function focused on one responsibility.
- If a function exceeds ~40 lines or needs more than three nesting levels,
  split it.
- Avoid mutable default arguments.
- Validate important inputs and provide useful error messages rather than
  assuming callers always pass correct data.
- Do not duplicate logic — extract reusable helpers, but avoid
  over-engineering prematurely.

## Errors & Logging
- Catch only specific exceptions; never bare `except:`.
- Re-raise with context using `raise NewError(...) from err`.
- Use the `logging` module (not `print`) in `src/` and `scripts/`.
- Configure a module-level logger: `logger = logging.getLogger(__name__)`.

## Constants & Configuration
- Hoist repeated literals into named constants.
- Read configuration from environment variables via a single
  `config.py` module; never sprinkle `os.getenv` calls across the codebase.

## Dependencies

- Prefer the standard library when it suffices.
- Add direct runtime dependencies to `requirements.in`.
- Add development-only dependencies to `requirements-dev.in`.
- Regenerate pinned `.txt` files with `pip-compile`.
- Do not hand-edit generated `requirements.txt` or `requirements-dev.txt`.
- See `dependency_management.md`.

## Design Principles
- Prefer **explicit code over implicit behavior** — avoid hidden side effects,
  overly dynamic patterns, or "magic" unless clearly justified.
- Optimize for **readability before cleverness** — a new developer should
  understand the code without extra explanation.
- Never accept AI-generated suggestions blindly — review every Copilot
  suggestion for correctness, style compliance, and security before committing.

## Comments
- Explain *why*, not *what*. The code already says what it does.
- Mark assumptions, business rules, and Salesforce-specific quirks explicitly.
- Wording must be suitable for:
  - a beginner or novice coder,
  - a beginner or novice Python developer,
  - a beginner Salesforce user.
- **Explain standard-library and third-party API calls on first use** — if a
  function uses `re.fullmatch`, `dataclass`, `csv.DictWriter`, or similar for
  the first time in the file, add a brief inline comment explaining what it
  does and why it is used here.
- **Use named section headers** (`# ====...`) to divide modules into logical
  regions (Constants, Data Classes, Public API, Helpers, etc.).

## Module-Level Documentation

Every Python module must begin with a module docstring that includes:

1. **What this module does** — one-sentence purpose.
2. **Who/what calls it** — is it a CLI script, a library imported by scripts,
   a test file?
3. **Key concepts** — list any Salesforce terms, design patterns, or external
   APIs a beginner would need to know.
4. **Usage example** — a short code snippet showing how to import and call the
   main function(s).

This mirrors the file-header requirements in `html-css-javascript.instructions.md`
and applies the same educational philosophy across all languages.

## Reference Implementation

The file `src/sf_admin_utils/data_export.py` is the **gold standard** for
Python commenting style in this project. New modules must match its level
of detail:

- Module docstring with purpose, audience, and usage example.
- Named section headers for every logical region.
- "How it works" paragraph in every non-trivial function docstring.
- Inline comments explaining standard-library calls on first use.
- Salesforce terms explained on first reference.


---
description: "Refactor an older standalone Salesforce script into the current project architecture."
mode: agent
---

<!-- markdownlint-disable MD041 -->

Refactor the selected legacy script into the current project architecture.

Before editing:

1. Summarize what the legacy script does.
2. Identify inputs, outputs, Salesforce objects, and side effects.
3. Identify whether the script is read-only or mutating.
4. Identify Production risks.
5. List reusable helpers already available in `src/sf_admin_utils/`.

Refactoring rules:

1. Keep behavior equivalent unless the user explicitly asks for behavior changes.
2. Use `build_client(org)` for Salesforce access when possible.
3. Use `configure_logging()` for logging.
4. Use `argparse` for command-line arguments.
5. Add `--org {uat,prod}`.
6. For mutating scripts, default to dry-run and require `--apply`.
7. Do not log PII or full Salesforce payloads.
8. Replace duplicated helper logic with shared helpers when safe.
9. Preserve important business rules as comments.

Docstring requirements:

1. Add or update beginner-friendly Google-style docstrings for every new or
   modified module, class, function, and complex test fixture.
2. Review nearby existing docstrings and improve any that are missing, stale,
   misleading, or too terse.
3. Do not change runtime behaviour while improving docstrings.
4. Explain Salesforce, Python, and business terms in plain English.

Testing rules:

1. Add or update pytest tests.
2. Mock Salesforce, CLI, subprocess, and HTTP calls.
3. Cover success, empty input, invalid input, and error paths.
4. Run ruff, pytest, and mypy.

Documentation rules:

1. Add or update a beginner-friendly guide under `docs/`.
2. Include command examples, troubleshooting, and glossary.
3. Update README if this becomes a supported script.

At the end, summarize:

- Behavior preserved.
- Behavior changed.
- Tests added.
- Risks remaining.

## Output format

Return:

```markdown
# Refactoring Summary

## Verdict

COMPLETE / PARTIAL / BLOCKED

## Summary

Short plain-English summary of what was refactored and the outcome.

## Script Identity

| Field | Value |
| --- | --- |
| Original path | `scripts/<old_name>.py` |
| New path | `scripts/<new_name>.py` or same |
| Read-only or mutating | [Read-only / Mutating] |
| Salesforce objects | [Objects involved] |
| Production safety | [Safe / Requires --apply] |

## Behaviour Comparison

| Behaviour | Preserved | Changed | Notes |
| --- | --- | --- | --- |

## Reused Helpers

| Helper | From Module | What It Replaced |
| --- | --- | --- |

## Tests Added or Updated

| Test File | Key Cases | Coverage |
| --- | --- | --- |

## Validation Results

| Check | Status |
| --- | --- |
| ruff format | PASS/FAIL |
| ruff check | PASS/FAIL |
| pytest | PASS/FAIL |
| mypy | PASS/FAIL |

## Risks Remaining

| Risk | Impact | Mitigation |
| --- | --- | --- |

## Documentation Updated

| File | Change |
| --- | --- |
```

## Output style rules

Use beginner-friendly language.

Clearly separate preserved behaviour from changed behaviour.

Do not claim behaviour is preserved without evidence from tests.

Do not invent validation results.

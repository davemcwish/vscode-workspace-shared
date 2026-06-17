---
description: "Diagnose a command error using a structured diagnosis loop and produce a beginner-friendly fix plan."
mode: agent
---

Diagnose the error output I provide using a disciplined loop. Do not guess  - 
work through each phase in order.

## Phase 1: Build a Feedback Loop

Identify the fastest way to reproduce this error deterministically:

- A failing test at whatever seam reaches the bug.
- A CLI invocation with specific arguments.
- A minimal reproduction script.

If you cannot reproduce it, say so and ask for: access to the environment,
captured artifacts (logs, stack traces), or permission to add instrumentation.

## Phase 2: Reproduce

Confirm:

- The reproduction triggers the **exact** failure the user described (not a
  different nearby failure).
- The failure is consistent across runs.
- You have captured the exact symptom (error message, wrong output, traceback).

## Phase 3: Hypothesise

Generate **3 - 5 ranked hypotheses** before testing any of them. Each hypothesis
must be falsifiable - state the prediction it makes:

> "If X is the cause, then changing Y will make the error disappear."

Present the ranked list. The user often has domain knowledge that re-ranks
immediately.

## Phase 4: Instrument and Fix

For the top hypothesis:

1. Add minimal instrumentation (a log line, a print, a breakpoint) to confirm
   or rule it out.
2. Change one variable at a time.
3. If confirmed, apply the fix. If ruled out, move to the next hypothesis.

## Phase 5: Verify and Prevent

Return:

```markdown
# Error Diagnosis

## Verdict

RESOLVED / PARTIALLY RESOLVED / UNRESOLVED

## Summary

Short plain-English summary of what went wrong and what was done.

## Error Identity

| Field | Value |
| --- | --- |
| Command that failed | [Exact command] |
| Error message | [Key error text] |
| Error type | [Code change / Config change / Environment issue / User action] |

## What the Error Means

[Plain-English explanation a beginner can understand.]

## Root Cause

| Hypothesis | Tested? | Result |
| --- | --- | --- |

**Confirmed root cause:** [One sentence.]

## Fix Applied

| What Changed | Why |
| --- | --- |

## Verification

| Check | Status | Notes |
| --- | --- | --- |
| Error no longer occurs | Yes/No |  |
| Tests pass | Yes/No/N/A |  |
| No regressions introduced | Yes/No |  |

## If It Still Fails

1. [Next diagnostic step]
2. [Alternative approach]

## Prevention

| Action | Status |
| --- | --- |
| Regression test added | Yes/No/Recommended |
| Documentation updated | Yes/No/Recommended |
| Root cause documented | Yes/No |

## Security Warning

[If the error output contained secrets, tokens, or session IDs: warn user to
rotate them. Otherwise: "No sensitive data observed in error output."]
```

## Output style rules

Use beginner-friendly language.

Explain error messages, stack traces, and technical terms in plain English.

Do not guess the root cause - confirm through instrumentation.

Do not invent error messages, stack traces, or diagnostic results.

If secrets, tokens, passwords, or session IDs appear in error output, warn the
user to rotate them immediately.

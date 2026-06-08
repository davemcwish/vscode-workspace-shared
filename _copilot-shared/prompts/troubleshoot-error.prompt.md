---
description: "Diagnose a command error using a structured diagnosis loop and produce a beginner-friendly fix plan."
mode: ask
---

Diagnose the error output I provide using a disciplined loop. Do not guess —
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

Generate **3–5 ranked hypotheses** before testing any of them. Each hypothesis
must be falsifiable — state the prediction it makes:

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

1. What command failed.
2. What the error means in plain English.
3. The root cause (confirmed, not guessed).
4. The exact fix applied.
5. How to verify the fix works.
6. What to try next if it still fails.
7. Whether this suggests a code change, config change, environment issue, or
   user action.
8. Whether a regression test should be added to prevent recurrence.

If the error includes secrets, tokens, passwords, or session IDs, warn the user
to rotate them and avoid repeating them in chat.

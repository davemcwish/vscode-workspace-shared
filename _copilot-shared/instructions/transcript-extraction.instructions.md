---
applyTo: "docs/**/*.md,transcripts/**/*.md,**/*transcript*.md,**/*guide*.md"
description: "Rules for extracting comprehensive, beginner-friendly task guides from chat transcripts."
---

# Transcript Extraction Standards

Use these rules when converting chat transcripts, meeting notes, support logs, or
LLM conversations into Markdown documentation.

## Primary Goal

Convert the source transcript into a complete, beginner-friendly guide that allows
someone else to repeat the same work from start to finish.

The output must preserve:

- Dates and times.
- The original sequence of events.
- Commands that were run.
- Errors that occurred.
- Diagnoses and reasoning.
- Fixes applied.
- Final working state.
- Follow-up actions.

## Target Reader

Assume the reader is:

- New to Python.
- New to Git and GitHub.
- New to Visual Studio Code.
- New to Salesforce CLI.
- New to Copilot instruction files.
- Capable of copy-pasting commands, but likely to need explanation.

Do not assume the reader understands jargon.

## Required Output Structure

Every transcript extraction must use this structure unless the user asks for a
different format:

<!-- markdownlint-disable-next-line MD025 -->
# Title

## Source Details

Include:

- Source file name.
- People or systems involved, if visible.
- Date range covered by the transcript.
- Main topic.
- Final outcome.

## Executive Summary

Summarize the session in plain English.

Include:

- What was being attempted.
- What problems appeared.
- What was fixed.
- What the final working state was.

## Timeline

Create a chronological timeline.

For each important event, include:

- Date.
- Time, if available.
- Actor, if available.
- What happened.
- Why it mattered.

Use a table if there are three or more entries.

## Final Working State

Document the final known-good state.

Include:

- Working commands.
- Current branch name.
- Important file paths.
- Passing test/lint/type-check status.
- Any remaining known issues.

## Step-by-Step Rebuild Guide

Write a repeatable beginner-friendly guide.

Each step must include:

1. What to do.
2. The exact command or file edit.
3. Why the step matters.
4. What successful output looks like.
5. What to do if it fails.

## Commands Used

List important commands in code blocks.

For each command, explain:

- Where to run it from.
- What it does.
- Expected result.

## Errors and Fixes

Create a table with:

| Error / Symptom | Cause | Fix | How to Verify |
| --- | --- | --- | --- |

Include exact error text where useful.

## Files Created or Modified

Create a table with:

| File | Purpose | Key Changes |
| --- | --- | --- |

## Decisions Made

List decisions that were made during the session.

For each decision, include:

- Decision.
- Reason.
- Alternatives considered.
- Impact.

## Beginner Notes

Explain technical terms that appeared in the transcript.

Examples:

- Virtual environment.
- pip.
- pytest.
- ruff.
- mypy.
- Git commit.
- Git remote.
- Salesforce org.
- Salesforce CLI alias.
- SOQL.
- Copilot instruction file.
- Prompt file.
- Chat mode.

## Security and Privacy Notes

Identify anything sensitive.

Do not expose:

- Passwords.
- Security tokens.
- Access tokens.
- Private keys.
- Real secrets from `.env`.
- Session IDs.

If the transcript contains personal data, summarize carefully and recommend
redaction where appropriate.

Salesforce user IDs, usernames, email addresses, org IDs, and internal URLs may
be confidential. Preserve them only when required for technical accuracy.

## Open Questions and Follow-Up Tasks

End with:

- Remaining blockers.
- Follow-up tasks.
- Suggested next steps.

## Style Rules

- Use clear Markdown headings.
- Use numbered lists for ordered procedures.
- Use bullet lists for unordered facts.
- Use tables for comparisons or multi-item summaries.
- Use fenced code blocks for commands and file contents.
- Keep explanations beginner-friendly.
- Do not skip "obvious" steps.
- Do not say "simply" or "just" when the step may be new to a beginner.

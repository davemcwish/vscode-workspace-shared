---
description: "Extract a comprehensive beginner-friendly guide from a transcript."
mode: agent
---

You are helping convert a transcript into a clear, complete Markdown guide.

Use the active transcript or attached document as the source.

If the transcript contains personal data, internal URLs, Salesforce user IDs,
org IDs, or email addresses, preserve only what is needed for technical accuracy
and add a privacy note.


Follow these requirements:

1. Preserve the chronological order.
2. Include exact dates and times when available.
3. Separate user prompts, model responses, commands, errors, and outcomes.
4. Extract every meaningful task, decision, error, and fix.
5. Explain the steps so a beginner can repeat the work.
6. Include exact commands in fenced code blocks.
7. Include file paths and filenames when relevant.
8. Highlight security/privacy concerns.
9. Redact or warn about secrets, tokens, passwords, private keys, and `.env` files.
10. End with a clear final-state summary and next steps.
11. Separate historical events from current recommended actions.
12. Summarize long model responses instead of copying them verbatim unless exact
    wording is needed for an error or command.

Use this output structure:

# [Descriptive Title]

## Source Details

## Executive Summary

## Timeline

## Final Working State

## Step-by-Step Rebuild Guide

## Commands Used

## Errors and Fixes

## Files Created or Modified

## Decisions Made

## Beginner Notes

## Security and Privacy Notes

## Open Questions and Follow-Up Tasks

Write the result as polished Markdown suitable for saving directly into the
project documentation.

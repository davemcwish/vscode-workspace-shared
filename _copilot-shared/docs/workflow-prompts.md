# Workflow Prompts - GitHub Copilot Cheat Sheet

This document provides ready-to-paste prompts for each step of the standard
development workflow defined in `.github/copilot-instructions.md`.

Replace every `{placeholder}` with your specific values before sending.

---

## Standard Workflow Overview

| Step | Mode | Purpose |
| --- | --- | --- |
| 0 | `backlog-gate` | Confirm the idea is not already covered in the backlog |
| 0.5 | `infra-guide` | Learn and implement infrastructure changes (GitHub Actions, CI, YAML) |
| 1 | `capability-planner` | Size and approve the backlog item |
| 2 | `release-pr-planner` | Slice into safe, ordered PRs |
| 3 | Standard Copilot | Implement `scripts/` and `src/` changes |
| 4 | Standard Copilot | Implement test changes; run `sanity.bat` |
| 5 | `doc-update` | Update all `docs/` and root markdown files |
| 6 | `pre-commit-check` | Full quality gate - must be green |
| 7 | `pr-review` | Review diff and approve |
| 8 | `pr-merge` | Write commit/PR message and push |

> **Rule:** Never skip Step 4 (tests green) before Step 5 (docs).
> Never skip Step 6 (quality gate) before Step 7 (review).

---

## Step 0 - Backlog Gate

**Chat mode:** `backlog-gate`

```text
I have a new idea: {one sentence description}.
Please check whether this is already covered by an existing item in
docs/pr-roadmap-section-8-4.md or the open tasks in
docs/salesforce-admin-utilities-guide.md §8.6 before I add it.
```text

---

## Step 0.5 - Infrastructure Guide

**Chat mode:** `infra-guide`

Use this step **only when the work involves infrastructure changes** - for
example, adding GitHub Actions, changing CI configuration, or modifying
`pyproject.toml` tool settings. Skip it for normal script or source changes.

```text
I need to implement {infrastructure item, e.g. "B1 - GitHub Actions CI workflow"}
from docs/pr-roadmap-section-8-4.md.
Before we write any code, please teach me:
1. What this technology is, in plain English.
2. Why this project needs it right now.
3. When it is the right choice (and when it is not).
4. The benefits.
5. The risks and how to recover if something goes wrong.
Then guide me through the implementation step by step, explaining each step
before we do it. Reference docs/github-actions-guide.md where relevant.
```

---

## Step 1 - Capability Planner

**Chat mode:** `capability-planner`

```text
I want to add a new backlog item. The business need is:
{summarise the user-facing need or technical improvement in 1-3 sentences}.
Please help me size it (XS/S/M/L), identify the files affected, and write
a backlog entry suitable for docs/pr-roadmap-section-8-4.md.
```text

To review and tidy existing items:

```text
Please review the unsized or vague items in docs/pr-roadmap-section-8-4.md.
Based on the current codebase, estimate a size (XS/S/M/L) for each and
suggest any items that should be split or merged.
```text

---

## Step 2 - Release / PR Planner

**Chat mode:** `release-pr-planner`

```text
We are planning to implement {group name, e.g. "Group B - CI/GitHub Actions"}
from docs/pr-roadmap-section-8-4.md.
Please review the backlog items against the current main branch codebase,
size each item, propose a safe implementation order, and create a planning
and review document saved as docs/pr-{group-slug}-review.md.
Include: goal, size, branch name, files to change, implementation steps,
test plan, gotchas, risks, and rollback for each item.
```text

---

## Step 3 - Implementation

**Chat mode:** Standard Copilot (Agent mode)

```text
Please implement {item name, e.g. "B1 - GitHub Actions CI workflow"} from
docs/pr-{group-slug}-review.md on branch {branch-name}.
Follow the "Files changed" and "How to implement" sections exactly.
Do not touch tests yet - that is Step 4.
```text

**Chat mode:** infra-guide

```text
I need to implement B1/B2/B3 - GitHub Actions CI workflow - from
docs/pr-group-b-review.md on branch chore/group-b-ci.

Before we write any code, please teach me:
1. What GitHub Actions is, in plain English.
2. Why this project needs it right now.
3. When it is the right choice (and when it is not).
4. The benefits.
5. The risks and how to recover if something goes wrong.

Then guide me through the implementation step by step using the
correct commands from docs/pr-group-b-review.md - specifically the
⚠️ Command Discrepancy section. Reference docs/github-actions-guide.md
where relevant, but use the commands in pr-group-b-review.md as the
source of truth.
```text

---

## Step 4 - Tests

**Chat mode:** Standard Copilot (Agent mode)

```text
The implementation for {item name} is complete.
Please implement the test changes described in the "Tests for the test engineer"
section of docs/pr-{group-slug}-review.md.
When done, run .\sanity.bat and confirm all checks pass.
```text

---

## Step 5 - Documentation Update

**Chat mode:** `doc-update`

```text
The implementation and tests for {item name / branch name} are complete and
sanity.bat is green.
Please update all affected documentation:
- Changelog.md (add entry under [Unreleased])
- docs/pr-roadmap-section-8-4.md (mark item done, add commit ref)
- docs/pr-{group-slug}-review.md (update status to Complete)
- Any guide files listed in the "Files changed" section of the review doc
```text

---

## Step 6 - Pre-Commit Quality Gate

**Chat mode:** `pre-commit-check`

```text
Please run the full quality gate for branch {branch-name} and confirm:
1. .\sanity.bat exits 0 (ruff, mypy, bandit, detect-secrets, pytest)
2. No staged or unstaged files are missing from the commit
3. Changelog.md and roadmap are up to date
4. No secrets or generated files are accidentally staged
Report any failures before I push.
```text

---

## Step 7 - PR Review

**Chat mode:** `pr-review`

```text
Please review the diff on branch {branch-name} against main.
Check for: correctness, test coverage, doc accuracy, security issues,
and adherence to the coding standards in .github/copilot-instructions.md.
Summarise your findings as: Approved / Approved with comments / Needs changes.
```text

---

## Step 8 - PR Merge

**Chat mode:** `pr-merge`

```text
The PR for {branch-name} has been reviewed and approved.
Please write the final commit message and PR description following the
format in docs/pr-{group-slug}-review.md "Suggested Commit Messages" section,
then confirm the push command.
```text

---

## After Merge - Housekeeping

**Chat mode:** Standard Copilot

```text
The PR for {branch-name} has been merged to main.
Please confirm:
1. git checkout main && git pull is complete
2. .\sanity.bat still passes on main
3. docs/pr-roadmap-section-8-4.md row is marked done with date and commit ref
4. Changelog.md [Unreleased] block is dated
5. The remote branch has been deleted on GitHub
What is the recommended next item from the roadmap?
```text

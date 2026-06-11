# Workflow: Standard Change

## Purpose

Use this workflow for any non-trivial change to a project in this workspace.

This workflow is designed for beginner developers, beginner Salesforce users,
and users who are learning how to work with VS Code Copilot. It explains what
to do, why each step matters, and which Copilot assets to use.

## When To Use This Workflow

Use this workflow when you are:

- adding a new script,
- changing an existing script,
- refactoring shared Python code,
- adding or changing tests,
- changing documentation,
- adding a new dependency,
- changing Salesforce API behavior,
- changing generated reports,
- changing HTML/CSS output,
- preparing a pull request.

For very small typo-only documentation changes, you may use a shorter process,
but you should still run the relevant Markdown checks and review the final diff.

---

## Overview

```text
Idea
  -> Backlog check
  -> Scope and approval
  -> PR planning
  -> Requirements
  -> Architecture
  -> Implementation tasks
  -> Code/test/docstring changes
  -> Documentation updates
  -> Quality gate
  -> Code review
  -> Pull request
```

---

## Step 1: Check Whether the Idea Already Exists

**Use:**

- `backlog-gate.chatmode.md`

**What to do:**

Search the existing backlog before creating new work.

Check:

- `docs/salesforce-admin-utilities-guide.md` section 8.4
- `docs/salesforce-admin-utilities-guide.md` section 8.5
- `docs/salesforce-admin-utilities-guide.md` section 8.6
- `docs/pr-roadmap-section-8-4.md`

**Why this matters:**

Beginners often create duplicate backlog items without realizing similar work
already exists. This creates confusion, duplicate pull requests, and wasted
review effort.

**Success looks like:**

One of these outcomes:

- exact duplicate found,
- partial overlap found and clarified,
- no duplicate found and safe to proceed.

---

## Step 2: Clarify the Change

**Use one of:**

- `capability-planner.chatmode.md`
- `scope-change.agent.md`

**What to clarify:**

- Who needs the change?
- What problem does it solve?
- Which Salesforce objects, reports, files, or scripts are involved?
- Is the change read-only or mutating?
- Does it affect Production?
- Does it handle PII, customer data, usernames, emails, PDFs, CSVs, ZIPs, or logs?
- What does "done" look like?
- How often will the user run it?
- Is this best delivered as a CLI script, generated report, HTML/CSS interface,
  website, documentation change, or workflow change?

**Why this matters:**

A clear problem statement prevents Copilot from jumping straight into code before
the business need, risks, and expected behavior are understood.

**Success looks like:**

A plain-English scope description that a non-technical user can understand.

---

## Step 3: Plan Pull Request Boundaries

**Use:**

- `release-pr-planner.chatmode.md`

**What to do:**

Split the work into safe, reviewable pull requests.

Each pull request should identify:

- purpose,
- likely files changed,
- behavior changed,
- behavior preserved,
- tests needed,
- documentation needed,
- Salesforce Production risk,
- security and PII risk,
- rollback strategy,
- suggested branch name,
- suggested commit message.

**Why this matters:**

Small pull requests are easier for beginners to review, easier to test, and
easier to revert if something goes wrong.

**Success looks like:**

A dependency-ordered PR plan where every PR can leave the test suite green.

---

## Step 4: Create Functional Requirements When Needed

**Use:**

- `business-analyst.agent.md`

**Input:**

- approved scope-change request,
- user request,
- backlog item,
- roadmap item.

**Output:**

Functional Requirement documents under:

```text
requirements/[req_id]/[fr_index]/fr.md
```

**Why this matters:**

Functional Requirements describe observable behavior before technical design.
This helps beginners understand what the code should do before seeing how it
will be implemented.

**Success looks like:**

Each Functional Requirement includes:

- user story,
- context and business rules,
- non-functional requirements,
- acceptance criteria,
- out-of-scope items.

---

## Step 5: Create Module Design

**Use:**

- `architect.agent.md`

**Input:**

```text
requirements/[req_id]/[fr_index]/fr.md
```

**Output:**

```text
requirements/[req_id]/[fr_index]/design.md
```

**What the design must cover:**

- impacted modules,
- new functions or classes,
- data flow,
- CLI changes,
- configuration changes,
- test strategy,
- security notes.

**Why this matters:**

The architecture step prevents implementation tasks from becoming guesswork.

**Success looks like:**

A design that explains which files change and why, without writing implementation
code.

---

## Step 6: Create Implementation Tasks

**Use:**

- `team-lead.agent.md`

**Input:**

```text
requirements/[req_id]/[fr_index]/design.md
```

**Output:**

```text
requirements/[req_id]/[fr_index]/tasks/task-001-[name].md
requirements/[req_id]/[fr_index]/tasks/checklist.md
```

**Each task must include:**

- plain-English summary,
- pre-work checks,
- files to modify or create,
- exact code implementation instructions,
- behavior changes,
- behavior preserved,
- gotchas,
- validation steps,
- risks and rollback.

**Why this matters:**

Beginner developers need small, clear, independently verifiable tasks.

**Success looks like:**

A checklist of sequential tasks where each task can be completed and tested on
its own.

---

## Step 7: Implement the Change

**Use:**

- `dev-manager.agent.md`
- `dev.agent.md`
- relevant prompt such as:
  - `new-script.prompt.md`
  - `refactor-legacy-script.prompt.md`
  - `salesforce-report.prompt.md`
  - `add-tests.prompt.md`

**Rules:**

- Follow the assigned task exactly.
- Do not refactor unrelated code.
- Do not contact real Salesforce orgs from tests.
- Do not commit generated CSV, Excel, PDF, ZIP, log, or report files unless they
  are intentionally sanitized samples.
- Add or update beginner-friendly docstrings for every new or modified Python
  module, class, function, method, and complex test fixture.

**Why this matters:**

A controlled implementation process reduces accidental scope creep.

**Success looks like:**

Code is changed only where planned, tests exist for new behavior, and local
validation passes.

---

## Step 8: Review and Improve Docstrings

**Use:**

- `docstring-auditor.agent.md`
- `docstring-audit.prompt.md`
- `improve-docstrings.prompt.md`

**What to check:**

- module docstrings,
- class docstrings,
- function and method docstrings,
- CLI `parse_args()` and `main()` docstrings,
- complex pytest fixture docstrings,
- Salesforce terminology explanations,
- PII and Production safety explanations,
- stale or misleading existing docstrings.

**Why this matters:**

Docstrings are part of the onboarding and maintainability standard. They help
beginner developers understand the code without needing a separate explanation.

**Success looks like:**

New and modified Python files have clear Google-style docstrings that match the
actual behavior.

---

## Step 9: Update Documentation

**Use:**

- `doc-writer.agent.md`
- `docs-update.prompt.md`

**Review and update when relevant:**

- `README.md`
- `CONTRIBUTING.md`
- `Changelog.md`
- `.env.example`
- `dependency_management.md`
- `docs/**/*.md`
- generated report guides,
- script-specific guides.

**Documentation must include:**

- purpose,
- prerequisites,
- step-by-step usage,
- command examples,
- expected output,
- troubleshooting,
- glossary or key concepts,
- security and PII notes.

**Why this matters:**

Beginners rely on documentation to run and maintain the project safely.

**Success looks like:**

Documentation accurately matches the implemented behavior.

---

## Step 10: Run the Quality Gate

**Use:**

- `pre-commit-check.agent.md`
- `pre-commit-check.chatmode.md`
- `pre-commit-check.prompt.md`

Run the full canonical quality gate:

**Why this matters:** Every check must pass before review. Coverage must stay
at or above 90%.

**Success looks like:** All checks pass locally before the change is reviewed.

---

## Step 11: Review the Change

**Use:**

- `code-reviewer.agent.md`
- `website-review.prompt.md`

Classify findings using the priority levels (Y"' CRITICAL, YY¡ IMPORTANT,
YY¢ SUGGESTION). All Y"' issues block merge.

**Success looks like:** No outstanding CRITICAL issues; IMPORTANT issues are
resolved or explicitly accepted.

---

## Step 12: Prepare and Raise the Pull Request

**Use:**

- `pr-merge.chatmode.md`

Confirm: tests green, docs updated, no secrets/PII committed, generated artifacts
gitignored. Then write the commit message + PR description and push after approval.

---

## Done Checklist

- [ ] Backlog checked for duplicates.
- [ ] Scope clarified and approved.
- [ ] PR boundaries planned.
- [ ] Requirements/design/tasks produced where needed.
- [ ] Code, tests, and docstrings updated.
- [ ] Documentation updated.
- [ ] Quality gate passed (coverage >= 90%).
- [ ] Code review complete with no open CRITICAL issues.
- [ ] PR raised with clear commit message and description.

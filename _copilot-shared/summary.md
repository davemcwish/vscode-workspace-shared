# Copilot Shared Configuration Summary

## What Is This?

This directory (`_copilot-shared/`) contains **GitHub Copilot configuration
files** - a set of rules, templates, and personas that customise how Copilot
(the AI coding assistant built into VS Code) behaves across all projects in
this workspace.

When you add a new sub-project (a new folder in the multi-root workspace), the
`sync-shared-copilot.ps1` script copies these files into that project's
`.github/` directory (the standard location where VS Code looks for Copilot
configuration). This keeps all projects consistent.

**Why does this matter?** Without these files, Copilot uses generic defaults.
With them, Copilot follows your team's coding style, security rules, and
documentation standards automatically.

> **Two symbols do most of the work in Copilot Chat:** `/` runs a **prompt**
> (a one-off recipe), and `@` calls an **agent** (a persona that does a whole
> job). Keep this distinction in mind as you read on.

---

## Overview

The configuration is organised into eight groups:

| Category | What it does | How it activates |
| --- | --- | --- |
| `.spec-workflow` | Templates for requirements, tasks, and checklists | Used by the `team-lead` agent |
| `agents` | Autonomous role-based workers (like virtual team members) | Type `@name` in Chat |
| `chatmodes` | Persistent conversation personas | You select one in Chat |
| `instructions` | Auto-applied rules matched by file type | Copilot reads them automatically |
| `prompts` | Reusable task recipes | You type `/prompt-name` in Chat |
| `skills` | Detailed technical standards | Agents read them; you can too |
| `workflows` | CI/CD pipelines and procedural workflows | Run automatically or manually |
| `copilot-instructions.md` | Global behaviour rules for all interactions | Copilot reads it automatically |

**"Activates automatically"** means Copilot reads the file without you doing
anything - it pattern-matches against the file you're editing.

**"You select" / "You type"** means you must explicitly choose or trigger it
(from a dropdown, or by typing `/` or `@` in Chat).

### How You Start Each Group (Quick Reference)

| Group | How you start it |
| --- | --- |
| Instruction | Automatic (no action needed) |
| Prompt | Type `/name` in Copilot Chat |
| Agent | Type `@name` in Copilot Chat |
| Chat mode | Pick from the dropdown in the Chat panel |

---

## How the Groups Work Together

Think of it like a team at work:

- **Instructions** are the office rules everyone follows automatically - Copilot
  reads them whenever you edit files that match their filename pattern.
- **Prompts** are forms you fill out to request a specific task - type
  `/prompt-name` in Copilot Chat to run a repeatable recipe.
- **Chat modes** are like choosing which department to talk to - select one at
  the start of a conversation to set the mindset for the whole session.
- **Agents** are specialist staff who do the work - each has a defined workflow,
  required inputs, and output format. Summon one by typing `@name` in Copilot
  Chat.
- **Skills** are the training manuals agents read before starting - detailed
  standards for code, tests, security, etc.
- **Spec workflow templates** are the scaffolding agents use to produce
  consistent task and checklist files.

---

## 1. Spec Workflow (`.spec-workflow/`)

Templates used by the `team-lead` agent when decomposing designs into tasks.

| File | Purpose |
| --- | --- |
| `task_file_template.md` | Template for individual implementation tasks - includes docstring requirements, validation steps, and rollback instructions. |
| `checklist_file_template.md` | Template for FR-level checklists. |
| `fr_template.md` | Template for functional requirement documents. |

---

## 2. Agents (`agents/`)

Specialist AI personas. Type `@agent-name` in Copilot Chat (or pick it from the
agent dropdown) to invoke one.

### How to Invoke an Agent

You don't need to open any special menu to use a pre-built agent. Just:

1. Open a **regular Copilot Chat** session (the normal chat panel you already use).
2. In the chat input box, type **`@`** followed by the agent's name.
3. Carry on typing your request as usual, then press **Enter**.

As you type `@`, Copilot shows a list of available agents - you can click one
instead of typing the full name. You can invoke an agent **at any time**, even
in the middle of an ongoing conversation.

**Example:**

```text
@team-lead break this design down into beginner-friendly tasks
```

> **Tip:** The agent name is the part of the filename before `.agent.md`. For
> example, the file `code-reviewer.agent.md` is invoked as `@code-reviewer`.
> If an agent ever doesn't respond to `@`, the fallback is the agent dropdown
> in the Chat panel.

| File | Purpose |
| --- | --- |
| `Explore.agent.md` | Read-only codebase exploration agent - locates code, traces call sites and dependencies, and confirms what already exists. Delegated to by architect, business-analyst, and team-lead. Never edits files or runs code. |
| `scope-change.agent.md` | Captures and validates a new scope change request before it enters the backlog. |
| `business-analyst.agent.md` | Translates a scope change into structured functional requirements. |
| `architect.agent.md` | Produces a module-level technical design for approved requirements. |
| `team-lead.agent.md` | Decomposes designs into sequential beginner-friendly implementation tasks. |
| `dev.agent.md` | Implements tasks produced by the team-lead. |
| `dev-manager.agent.md` | Orchestrates implementation by coordinating the dev agent sequentially through the task checklist and maintaining checklist state. Writes no code itself, but runs the full canonical quality gate once after the loop to catch cross-task regressions. |
| `code-reviewer.agent.md` | Reviews completed code for correctness, security, style, and test coverage. |
| `doc-writer.agent.md` | Writes and updates beginner-friendly project documentation. |
| `pre-commit-check.agent.md` | Runs the full quality gate and summarises results before a PR is raised. |
| `docstring-auditor.agent.md` | Audits and improves beginner-friendly Python docstrings without changing runtime behaviour. |
| `critical-thinking.agent.md` | Challenges assumptions via open Socratic questioning - asks questions only, never writes code (one carve-out: may flag a data-loss/security/Production risk). Ends with a neutral recap of assumptions tested. Mirrored with the chatmode version. |
| `debug.agent.md` | Systematic 4-phase bug diagnosis: assess -> investigate -> resolve -> verify. |

**Recommended agent chain** (the order you'd use them for a full feature). You
won't always need every agent - this just shows the typical order for building
a full feature from scratch:

```text
scope-change -> business-analyst -> architect -> team-lead -> dev-manager -> dev
                                                                  |
                            code-reviewer -> docstring-auditor -> pre-commit-check -> doc-writer
```

Supporting agents (use at any step when you need them):

```text
critical-thinking  -- challenge assumptions before committing to a design
debug              -- systematic troubleshooting when tests fail
Explore            -- read-only codebase discovery (used by architect, BA, team-lead)
```

---

## 3. Chat Modes (`chatmodes/`)

Select a chat mode at the start of a Copilot Chat session. The mode sets a
persona and ruleset that persist for the entire conversation.

| File | Purpose |
| --- | --- |
| `accessibility-review.chatmode.md` | Review HTML, CSS, Markdown, reports, and user-facing output for practical accessibility. |
| `backlog-gate.chatmode.md` | Check whether an idea already exists in the backlog before creating a new entry. |
| `capability-planner.chatmode.md` | Scope, size, and prioritise new capabilities and technical debt items. |
| `critical-thinking.chatmode.md` | Challenge assumptions before committing to a design or approach via open Socratic questioning. Only asks questions (one carve-out: may flag a data-loss/security/Production risk). Ends with a neutral recap. Mirrored with the agent version. |
| `debug.chatmode.md` | Systematically diagnose and resolve bugs using a structured 4-phase process. |
| `dependency-manager.chatmode.md` | Manage Python dependencies safely with pip-tools. |
| `doc-writer.chatmode.md` | Write beginner-friendly project documentation. |
| `docstring-review.chatmode.md` | Review and improve Python docstrings without changing runtime behaviour. |
| `infra-guide.chatmode.md` | Guide infrastructure, CI, and environment setup decisions. |
| `pr-merge.chatmode.md` | Write the git commit message and PR description, then push. |
| `pre-commit-check.chatmode.md` | Run the full quality gate and summarise results before raising a PR. |
| `release-pr-planner.chatmode.md` | Split approved capabilities into safe, reviewable pull requests. |
| `sf-safe-ops.chatmode.md` | Read-only Salesforce reasoning mode - no write code generated. |
| `test-engineer.chatmode.md` | Design and improve pytest coverage without real Salesforce calls. |
| `transcript-extractor.chatmode.md` | Convert long transcripts into comprehensive beginner-friendly Markdown guides. |
| `website-launch-planner.chatmode.md` | Guide a beginner from website idea to platform choice, social presence, design, build, and live launch. |

**To switch modes in VS Code:**

In the Copilot Chat panel, click the mode selector dropdown (next to the chat
input -- it usually shows "Ask", "Edit", or "Agent"). Your `.chatmode.md`
files appear there by name. If they do not appear, open the **Command Palette**
(press `Ctrl+Shift+P` -- this opens VS Code's search bar for commands) and run
**GitHub Copilot: Open Chat** -- VS Code rescans chat modes on startup.

---

## 4. Instructions (`instructions/`)

Auto-applied by Copilot when editing files that match the `applyTo` pattern
(a filename glob -- like a filter that says "apply this rule to all `.py`
files"). No manual action required.

| File | `applyTo` | Purpose |
| --- | --- | --- |
| `docs.instructions.md` | `docs/**/*.md, *.md, CONTRIBUTING.md, README.md` | Audience and tone rules for all project documentation. |
| `docstrings.instructions.md` | `src/**/*.py, scripts/**/*.py, tests/**/*.py` | Mandatory beginner-friendly Python docstring rules. |
| `flask-websocket-subprocess.instructions.md` | `frontend/**/*.py, src/**/job_runner*.py, **/app.py` | Flask 3.x REST API, Flask-SocketIO WebSocket, and subprocess.Popen patterns. |
| `html-css-javascript.instructions.md` | `**/*.html, **/*.css, **/*.js, frontend/**` | Authoring standards for HTML, CSS, and JavaScript. |
| `markdown.instructions.md` | `**/*.md` | Markdown style for project documentation. |
| `powershell.instructions.md` | `**/*.ps1` | PowerShell scripting standards for Windows compatibility. |
| `pr-review-checklist.instructions.md` | `**` | Documentation and code consistency checks to run before raising a PR. |
| `python.instructions.md` | `**/*.py` | Python coding standards for beginner-friendly maintainability. |
| `salesforce.instructions.md` | `src/**/*.py, scripts/**/*.py` | Salesforce API usage and Production-safety rules. |
| `security.instructions.md` | `**` | Secrets handling, sensitive data, OWASP web security for Flask endpoints. |
| `shared-artefacts.instructions.md` | `**` | Governance rules for shared Copilot configuration files and sync workflows. |
| `testing.instructions.md` | `tests/**/*.py` | Pytest conventions, coverage expectations, Flask/SocketIO test patterns. |
| `transcript-extraction.instructions.md` | `docs/**/*.md, transcripts/**/*.md, **/*transcript*.md, **/*guide*.md` | Rules for extracting beginner-friendly task guides from transcripts. |

---

## 5. Prompts (`prompts/`)

Triggered manually via `/` in Copilot Chat. Each prompt is a repeatable
recipe for a specific task -- like a template that tells Copilot exactly what
to do.

| File | Purpose |
| --- | --- |
| `add-tests.prompt.md` | Add or improve pytest coverage for a selected module. |
| `code-review-staged-diff.prompt.md` | General code review prompt for broad quality checks. |
| `component-overview.prompt.md` | Generate a machine-readable, component-level overview (`overview.md`) for consumption by other AI agents - explicit labelled fields, no prose. |
| `docstring-audit.prompt.md` | Audit Python docstrings and produce a beginner-friendly remediation plan. |
| `docs-update.prompt.md` | Update project documentation after a code or workflow change. |
| `extract-transcript.prompt.md` | Extract a comprehensive beginner-friendly guide from a chat transcript. |
| `improve-docstrings.prompt.md` | Improve Python docstrings across a file or module without changing runtime behaviour. |
| `new-script.prompt.md` | Scaffold a new Salesforce admin utility script. |
| `pre-commit-check.prompt.md` | Run and interpret the full project sanity checks before a commit. |
| `project-architecture.prompt.md` | Summarise the current project architecture. |
| `refactor-legacy-script.prompt.md` | Refactor an older standalone script into the current project architecture. |
| `salesforce-report.prompt.md` | Create a read-only Salesforce reporting script with CSV output. |
| `troubleshoot-error.prompt.md` | Diagnose a command error and produce a beginner-friendly fix plan. |
| `update-dependencies.prompt.md` | Safely update dependencies using pip-tools. |
| `website-conversion-review.prompt.md` | Review a website for conversion, lead generation, trust, calls to action, and customer journey friction. |
| `website-from-idea-to-launch.prompt.md` | Plan a beginner-friendly website from idea to live launch. |
| `website-html-css-review.prompt.md` | Review HTML and CSS for accessibility, responsiveness, maintainability, and beginner readability. |
| `website-local-seo-check.prompt.md` | Review local SEO readiness for a small business or local organisation website. |
| `website-maintenance-plan.prompt.md` | Create a practical post-launch website maintenance plan. |
| `website-monthly-review.prompt.md` | Run a monthly website improvement review covering maintenance, analytics, SEO, conversion, and accessibility. |
| `website-platform-decision.prompt.md` | Help choose the simplest sustainable platform for a website, report, dashboard, or tool. |
| `website-seo-review.prompt.md` | Review a website for SEO, findability, and content clarity. |

---

## 6. Skills (`skills/`)

Detailed standards that agents must read before writing code, reviews, or
tasks. Not auto-applied -- agents load them explicitly. You can also read
these yourself to understand the rules Copilot follows.

| File | Purpose |
| --- | --- |
| `accessibility.skill.md` | Practical accessibility standards for HTML, CSS, documents, reports, and tools. |
| `cli.skill.md` | argparse patterns, help text, exit codes, and dry-run conventions. |
| `docstring.skill.md` | Mandatory beginner-friendly Google-style docstring rules, examples, and review checklist. |
| `flask-websocket.skill.md` | Flask 3.x, Flask-SocketIO, subprocess.Popen patterns for the JOSHUA frontend. |
| `html-css.skill.md` | HTML and CSS patterns for static Salesforce reports. |
| `html-css-static-report.skill.md` | Constraints and file structure for generated HTML reports. |
| `python.skill.md` | Core Python standards: style, typing, error handling, logging. |
| `salesforce.skill.md` | Salesforce API safety, SOQL patterns, PII handling, Production guardrails. |
| `security.skill.md` | Subprocess safety (Cycode SAST), secret handling, TLS, path traversal. |
| `testing.skill.md` | Pytest conventions, coverage targets, mocking patterns, cross-platform rules. |
| `website-growth.skill.md` | Website growth, SEO, conversion, retention, and monthly improvement standards. |
| `website-launch.skill.md` | Website planning, platform choice, social presence, and live launch guidance. |

---

## 7. Workflows (`workflows/`)

Workflows are step-by-step procedural guides. Some are CI/CD pipelines (run
automatically on push), others are manual processes you follow when doing a
specific type of work.

| File | Purpose |
| --- | --- |
| `ci.yml` | GitHub Actions CI workflow -- runs ruff, mypy, bandit, detect-secrets, and pytest automatically on every push. |
| `doc-writing.workflow.md` | End-to-end workflow for writing or updating project documentation (guides, README, Changelog). |
| `doc-writer-remediation.workflow.md` | Verify and fix existing documentation guides against the code. |
| `docstring-writing.workflow.md` | End-to-end workflow for writing new Python docstrings during development. |
| `docstring-remediation.workflow.md` | Step-by-step process to review and improve existing Python docstrings without changing runtime behaviour. |
| `standard-change.workflow.md` | End-to-end workflow for any non-trivial change -- from planning through to PR. |
| `website-live-launch.workflow.md` | Beginner-friendly workflow from website idea to live launch. |

---

## 8. Root Files

| File | Purpose |
| --- | --- |
| `copilot-instructions.md` | Master configuration -- applies to all Copilot interactions. Defines the standard development workflow, coding style, and project rules. |
| `summary.md` | This file -- a complete inventory of all shared Copilot configuration. |

---

## Model Selection Guidance

Use the strongest available reasoning model for:

- architecture decisions,
- Production-impacting Salesforce work,
- security-sensitive changes,
- PII-sensitive exports,
- large refactors.

Use a faster, lower-cost model only for:

- typo fixes,
- simple Markdown cleanup,
- summarising low-risk text.

If the available model list in VS Code differs from any previous guidance in
this project, choose the closest equivalent and prioritise **safety, accuracy,
and review quality** over speed or cost.

---

## Key Concepts for Beginners

| Term | Explanation |
| --- | --- |
| `_copilot-shared/` | This project's shared source of truth for Copilot configuration. The `sync-shared-copilot.ps1` script copies it into each sub-project's `.github/` folder. |
| `.github/` directory | A special folder in a Git repository where VS Code looks for Copilot configuration files. |
| `applyTo` glob | A filename pattern (like `**/*.py` meaning "all Python files in any subfolder") that tells Copilot when to activate a rule. |
| Agent | An AI persona with a specific job, workflow, and output format -- like a virtual team member. Invoke it by typing `@name` in Copilot Chat. |
| Chat mode | A persistent personality you select for an entire Copilot Chat conversation. |
| Prompt | A reusable recipe you trigger with `/name` in Copilot Chat -- like a template for a specific task. |
| Instruction | A rule file Copilot reads automatically (no action needed from you) when you edit matching files. |
| Skill | A detailed standards document that agents read before doing work -- the "training manual". |
| Workflow | A step-by-step process for completing a type of work (e.g. launching a website, making a code change). |
| Quality gate | A set of automated checks (formatting, linting, type-checking, security scanning, tests) that must all pass before code can be merged. |
| Command Palette | VS Code's search bar for commands -- open it with `Ctrl+Shift+P`. |
| PR (Pull Request) | A request to merge your changes into the main codebase, where they can be reviewed before being accepted. |
| CI/CD | Continuous Integration / Continuous Deployment -- automated checks and release steps that run when code is pushed. |
| JOSHUA | The name of this project's Flask-based web frontend (referenced by the Flask/WebSocket skill and instruction files). |
| `sanity.bat` | The local quality-gate runner (Windows). Runs ruff, mypy, bandit, detect-secrets, and pytest+coverage in one command - the local mirror of `ci.yml`. Run it before every commit. |

<!-- WEBSITE-PROMPT-COVERAGE-INDEX:START -->
## Website Prompt Coverage Summary

The website prompt set now includes dedicated coverage for:

- idea-to-launch planning,
- monthly review and maintenance,
- website governance and documentation,
- QA and change management,
- content governance and copy review,
- search, SEO, local SEO, online presence, forms and submissions, conversion, growth, and experimentation,
- accessibility remediation,
- localization,
- performance and digital sustainability,
- analytics,
- privacy, security, access permissions, data retention, cookie consent, and account/login journeys,
- monitoring, incident response, business continuity, backup/restore, and migration,
- AI chatbots and automated assistants,
- third-party tools, vendor management, and cost ownership.

Recent Phase 1AO-1AU additions added or confirmed dedicated prompts for:

- `prompts/website-experimentation-review.prompt.md`
- `prompts/website-accessibility-remediation-review.prompt.md`
- `prompts/website-cookie-consent-review.prompt.md`
- `prompts/website-ai-chatbot-review.prompt.md`
- `prompts/website-account-login-review.prompt.md`
- `prompts/website-forms-submissions-review.prompt.md`

These prompts complement the existing website monitoring, incident response, business continuity, backup/restore, change management, vendor management, privacy/security, analytics, localization, search, QA, and governance prompts.
<!-- WEBSITE-PROMPT-COVERAGE-INDEX:END -->

## Website prompt suite

The website prompt suite provides reusable review, planning, governance, operational, and risk-assessment prompts for website work. These prompts support practical website delivery while reminding users to verify current legal, privacy, accessibility, security, vendor, analytics, and platform requirements with appropriate qualified reviewers or official sources.

### Planning, launch, and lifecycle

- `prompts/website-from-idea-to-launch.prompt.md` - Plans a website from idea through launch readiness, including goals, scope, pages, content, platform, forms, privacy, accessibility, analytics, QA, ownership, and launch risks.
- `prompts/website-maintenance-plan.prompt.md` - Plans ongoing website maintenance, updates, ownership, QA, monitoring, documentation, backups, and recurring operational health.
- `prompts/website-growth-plan.prompt.md` - Reviews website growth opportunities across audience, messaging, channels, funnels, conversion, experimentation, SEO, analytics, and prioritization.
- `prompts/website-migration-review.prompt.md` - Reviews website migration planning, redirects, SEO preservation, content, analytics, QA, rollback, platform risks, and launch readiness.

### Discovery, SEO, content, conversion, and experience

- `prompts/website-seo-review.prompt.md` - Reviews technical SEO, on-page SEO, indexability, metadata, content quality, crawlability, and search visibility risks.
- `prompts/website-local-seo-check.prompt.md` - Reviews local SEO signals, local listings, service areas, location pages, reviews, local schema, and local search visibility.
- `prompts/website-online-presence-review.prompt.md` - Reviews broader online presence across listings, profiles, reputation, consistency, channels, trust signals, and discoverability.
- `prompts/website-search-review.prompt.md` - Reviews website search, internal search UX, search results quality, filters, indexing, no-results handling, accessibility, analytics, and AI-assisted search risks.
- `prompts/website-copy-review.prompt.md` - Reviews website copy for clarity, trust, claims, audience fit, conversion, accessibility, localization, brand, and risk.
- `prompts/website-conversion-review.prompt.md` - Reviews conversion paths, calls to action, landing pages, forms, trust signals, analytics, and funnel friction.
- `prompts/website-experimentation-review.prompt.md` - Reviews website experiments, A/B tests, measurement plans, consent, fairness, analytics, guardrails, rollout, and decision quality.

### Analytics, performance, QA, and functionality

- `prompts/website-analytics-review.prompt.md` - Reviews analytics setup, events, funnels, dashboards, consent, data quality, attribution, reporting, ownership, and measurement risks.
- `prompts/website-performance-review.prompt.md` - Reviews page speed, assets, scripts, third-party tags, caching, mobile performance, monitoring, Core Web Vitals-style risks, and performance ownership.
- `prompts/website-qa-review.prompt.md` - Reviews website QA coverage, test plans, launch checks, regression risks, browser/device checks, forms, analytics, accessibility, and acceptance criteria.
- `prompts/website-forms-submissions-review.prompt.md` - Reviews website forms, submissions, contact forms, lead capture, newsletter signup, support requests, file uploads, validation, confirmations, notifications, CRM handoff, spam prevention, privacy, accessibility, localization, analytics, ownership, testing, and failure handling.
- `prompts/website-account-login-review.prompt.md` - Reviews account, login, registration, password reset, MFA, sessions, access, privacy, security, accessibility, support, monitoring, and recovery flows.
- `prompts/website-ai-chatbot-review.prompt.md` - Reviews website AI chatbot behavior, scope, privacy, safety, handoff, accessibility, analytics, hallucination risk, escalation, governance, and monitoring.

### Accessibility, localization, privacy, security, and user trust

- `prompts/website-security-privacy-review.prompt.md` - Reviews security and privacy risks, data handling, access, consent, secrets, third-party services, and practical remediation needs.
- `prompts/website-accessibility-remediation-review.prompt.md` - Reviews accessibility remediation plans, WCAG-oriented risks, assistive technology support, prioritization, ownership, testing, and evidence needs.
- `prompts/website-localization-review.prompt.md` - Reviews localization, translation quality, locale fit, regional UX, accessibility, SEO, legal/privacy considerations, ownership, and testing.
- `prompts/website-access-permissions-review.prompt.md` - Reviews website access, roles, permissions, least privilege, account lifecycle, admin access, vendor access, auditability, and access-control risks.
- `prompts/website-cookie-consent-review.prompt.md` - Reviews cookie consent, tags, trackers, consent modes, banners, preference centers, analytics/advertising tools, privacy notices, and evidence needs.
- `prompts/website-data-retention-review.prompt.md` - Reviews website data retention, deletion, storage, submissions, logs, backups, exports, vendors, privacy obligations, and ownership.

### Governance, operations, resilience, vendors, and cost

- `prompts/website-governance-review.prompt.md` - Reviews website governance, ownership, decision rights, policies, standards, review cadence, accountability, and operating model risks.
- `prompts/website-content-governance-review.prompt.md` - Reviews content ownership, lifecycle, approvals, claims, accuracy, freshness, accessibility, localization, taxonomy, and publishing controls.
- `prompts/website-documentation-review.prompt.md` - Reviews website documentation, runbooks, ownership records, architecture notes, vendor records, support procedures, and operational evidence.
- `prompts/website-change-management-review.prompt.md` - Reviews website change management, approvals, release planning, QA, rollback, communications, audit trail, and production-risk controls.
- `prompts/website-vendor-management-review.prompt.md` - Reviews website vendors, contracts, ownership, SLAs, access, data handling, renewals, support, exit planning, and vendor risk.
- `prompts/website-third-party-tools-review.prompt.md` - Reviews third-party tools, embeds, scripts, tags, plugins, integrations, privacy, performance, security, accessibility, ownership, and replacement risk.
- `prompts/website-cost-ownership-review.prompt.md` - Reviews website costs, subscriptions, renewals, ownership, budget risks, vendor dependencies, billing access, and cost-control opportunities.
- `prompts/website-business-continuity-review.prompt.md` - Reviews continuity planning, critical journeys, outage scenarios, recovery priorities, vendor dependencies, communications, and resilience gaps.
- `prompts/website-incident-response-review.prompt.md` - Reviews incident response planning for outages, security/privacy issues, broken critical journeys, communications, escalation, evidence, and recovery.
- `prompts/website-backup-restore-review.prompt.md` - Reviews backups, restore testing, recovery objectives, hosting/platform dependencies, data coverage, ownership, and recovery evidence.
- `prompts/website-monitoring-review.prompt.md` - Reviews uptime, error, performance, form, analytics, security, certificate, domain, and critical-journey monitoring.

## Website-adjacent sustainability prompt

- `prompts/website-digital-sustainability-review.prompt.md` - Reviews website sustainability considerations, including page weight, asset efficiency, hosting and infrastructure considerations, performance-related waste, measurement needs, governance, and practical tradeoffs. Use current platform, analytics, hosting, and sustainability evidence when making recommendations.

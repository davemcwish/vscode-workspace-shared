# Website Artifact Manifest

**Last Updated:** June 17, 2026 (current as-is inventory)

## Purpose

This file lists the Copilot artifacts used for planning, building, launching,
promoting, measuring, documenting, and maintaining a website.

It exists so a complete beginner can answer these questions:

- Which artifacts are already installed?
- Which artifacts are optional?
- Which artifacts are still missing?
- Which artifact should I use for each website task?

If another document mentions an artifact that is not installed yet, check this
manifest first.

---

## Status Legend

| Status | Meaning |
| --- | --- |
| Installed | The artifact exists in this workspace |
| To create | The artifact is recommended but does not exist yet |
| To verify | The artifact may exist but needs confirmation |
| Optional | Useful for some projects but not required for every website |
| External | Depends on tools, services, or documentation outside this workspace |

---

## Core Entry Point

| Artifact | Status | Purpose |
| --- | --- | --- |
| `START-HERE-WEBSITE.md` | Installed | Beginner entry point for understanding how to use the website artifact system |
| `WEBSITE-ARTIFACT-MANIFEST.md` | Installed | Inventory of installed, missing, optional, and planned artifacts |

---

## Critical Thinking Artifacts

| Artifact | Status | Purpose |
| --- | --- | --- |
| `critical-thinking.agent.md` | Installed | Agent version of the critical-thinking partner |
| `critical-thinking.chatmode.md` | Installed | Chat mode version of the critical-thinking partner |

> **Sync rule:** The agent and chat mode versions must remain behaviourally
> identical. Any change to one must be applied to the other.

---

## Standard Development Workflow Agents

These agents guide you through the standard 9-step development workflow (backlog-gate, capability-planner, architect, team-lead, dev, etc.):

| Artifact | Status | Purpose |
| --- | --- | --- |
| `architect.agent.md` | Installed | Produces module-level design and architecture decisions |
| `business-analyst.agent.md` | Installed | Produces approved Functional Requirements when needed |
| `code-reviewer.agent.md` | Installed | Reviews completed changes for quality, correctness, and maintainability |
| `debug.agent.md` | Installed | Systematic troubleshooting when tests fail or behavior is unexpected |
| `dev-manager.agent.md` | Installed | Executes tasks through the dev agent in a structured workflow |
| `dev.agent.md` | Installed | Core development agent for implementing code changes |
| `doc-writer.agent.md` | Installed | Produces comprehensive beginner-friendly documentation |
| `docstring-auditor.agent.md` | Installed | Reviews and improves docstrings for complete-beginner clarity |
| `explore.agent.md` | Installed | Read-only codebase exploration - locates code, traces dependencies |
| `pre-commit-check.agent.md` | Installed | Runs full quality gate before commits; verifies all 9 steps completed |
| `scope-change.agent.md` | Installed | Evaluates and sizes feature requests or scope changes |
| `team-lead.agent.md` | Installed | Produces granular implementation tasks from architectural design |

---

## Website Skills

| Artifact | Status | Purpose |
| --- | --- | --- |
| `website-analytics.skill.md` | Installed | Analytics, measurement, conversion tracking, and privacy-aware data collection |
| `website-promotion.skill.md` | Installed | SEO, paid ads, email, social media, partnerships, and offline promotion |
| `website-performance.skill.md` | Installed | Website speed, Core Web Vitals, images, caching, JavaScript, fonts, and CDN guidance |
| `website-security.skill.md` | Installed | HTTPS, headers, forms, CMS security, hosting security, backups, and incident response |
| `website-privacy-legal.skill.md` | Installed | Privacy law, cookies, accessibility law, data collection, and legal compliance |
| `website-content-copywriting.skill.md` | Installed | Website copy, page structure, CTAs, tone, scanning behaviour, and content maintenance |
| `accessibility.skill.md` | Installed | Detailed accessibility implementation and testing guidance |
| `website-launch.skill.md` | Installed | General website launch planning guidance |
| `website-growth.skill.md` | Installed | Ongoing growth, SEO, conversion, and improvement loops |

---

## General-Purpose Skills

| Artifact | Status | Purpose |
| --- | --- | --- |
| `cli.skill.md` | Installed | Command-line interface design and scripting best practices |
| `doc-writing.skill.md` | Installed | Documentation authoring for complete beginners |
| `docstring.skill.md` | Installed | Python docstring writing standards and patterns |
| `flask-websocket.skill.md` | Installed | Flask 3.x REST APIs, Flask-SocketIO WebSocket, and subprocess patterns |
| `html-css.skill.md` | Installed | HTML and CSS authoring for static reports and simple websites |
| `html-css-static-report.skill.md` | Installed | Specialized guidance for self-contained HTML/CSS reports |
| `python.skill.md` | Installed | Python coding standards and best practices |
| `salesforce.skill.md` | Installed | Salesforce API usage and integration patterns |
| `security.skill.md` | Installed | Security-focused code patterns and vulnerability prevention |
| `testing.skill.md` | Installed | Testing frameworks, strategies, and coverage best practices |

---

## Website Workflows

| Artifact | Status | Purpose |
| --- | --- | --- |
| `website-documentation.workflow.md` | Installed | Creates beginner-friendly offline Markdown documentation |
| `website-live-launch.workflow.md` | Installed | End-to-end go-live workflow covering domain, DNS, SSL, testing, launch, rollback, and post-launch checks |

---

## General-Purpose Workflows

| Artifact | Status | Purpose |
| --- | --- | --- |
| `standard-change.workflow.md` | Installed | Standard workflow for implementing code changes across all projects |
| `doc-writing.workflow.md` | Installed | End-to-end workflow for creating comprehensive documentation guides |
| `doc-writer-remediation.workflow.md` | Installed | Workflow for updating and improving existing documentation |
| `docstring-writing.workflow.md` | Installed | Workflow for writing complete-beginner docstrings for all functions and classes |
| `docstring-remediation.workflow.md` | Installed | Workflow for auditing and improving existing docstrings |

---

## Website Chat Modes

| Artifact | Status | Purpose |
| --- | --- | --- |
| `website-launch-planner.chatmode.md` | Installed | Main guided planning conversation from idea to launch |
| `accessibility-review.chatmode.md` | Installed | Accessibility review conversation |
| `critical-thinking.chatmode.md` | Installed | Challenges assumptions before committing to decisions |

---

## General-Purpose Chat Modes

| Artifact | Status | Purpose |
| --- | --- | --- |
| `backlog-gate.chatmode.md` | Installed | Confirms feature requests are not already in the backlog before starting work |
| `capability-planner.chatmode.md` | Installed | Sizes and clarifies scope of requested changes |
| `debug.chatmode.md` | Installed | Systematic troubleshooting when tests fail or behavior is unexpected |
| `dependency-manager.chatmode.md` | Installed | Manages Python package dependencies, updates, and compatibility |
| `doc-writer.chatmode.md` | Installed | Guides creation of comprehensive beginner-friendly documentation |
| `docstring-review.chatmode.md` | Installed | Reviews and improves docstrings for complete-beginner clarity |
| `infra-guide.chatmode.md` | Installed | Infrastructure setup and environment configuration guidance |
| `pr-merge.chatmode.md` | Installed | Prepares commit messages and pull request documentation before push |
| `pre-commit-check.chatmode.md` | Installed | Runs full quality gate (ruff, mypy, bandit, detect-secrets, pytest, coverage) before commits |
| `release-pr-planner.chatmode.md` | Installed | Slices work into safe, ordered pull requests for phased delivery |
| `sf-safe-ops.chatmode.md` | Installed | Salesforce-specific operational safety and validation checks |
| `test-engineer.chatmode.md` | Installed | Designs and implements comprehensive test coverage |
| `transcript-extractor.chatmode.md` | Installed | Extracts comprehensive guides from chat transcripts and support logs |

---

## Website Prompts

| Artifact | Status | Purpose |
| --- | --- | --- |
| `website-from-idea-to-launch.prompt.md` | Installed | One-shot planning prompt for a new website |
| `website-platform-decision.prompt.md` | Installed | Helps compare and choose website technology/platform |
| `website-seo-review.prompt.md` | Installed | Reviews search engine readiness |
| `website-local-seo-check.prompt.md` | Installed | Reviews local search readiness |
| `website-conversion-review.prompt.md` | Installed | Reviews whether visitors are likely to take the desired action |
| `website-html-css-review.prompt.md` | Installed | Reviews HTML/CSS/JS quality |
| `website-monthly-review.prompt.md` | Installed | Monthly website health check |
| `website-maintenance-plan.prompt.md` | Installed | Creates a long-term maintenance plan |

---

## Templates

| Artifact | Status | Purpose |
| --- | --- | --- |
| `website-cost-model.template.md` | Installed | Records one-time, monthly, annual, and marketing costs |
| `website-risk-register.template.md` | Installed | Tracks risks, impact, likelihood, owners, and mitigations |
| `website-decision-log.template.md` | Installed | Records decisions, alternatives, reasoning, and revisit triggers |
| `website-assumption-log.template.md` | Installed | Records assumptions, validation method, and risk if wrong |

---

## Instruction Files

| Artifact | Status | Purpose |
| --- | --- | --- |
| `html-css-javascript.instructions.md` | Installed | Auto-applied web coding standards for HTML, CSS, and JavaScript |
| `security.instructions.md` | Installed | Project-specific secure coding rules |

---

## Project-Specific Instruction Files

| Artifact | Status | Purpose |
| --- | --- | --- |
| `docs.instructions.md` | Installed | Audience, tone, and accuracy rules for project documentation |
| `docstrings.instructions.md` | Installed | Mandatory complete-beginner docstring standards for Python, PowerShell, batch, and shell scripts |
| `flask-websocket-subprocess.instructions.md` | Installed | Flask 3.x REST API, Flask-SocketIO WebSocket, and subprocess.Popen patterns for web frontends |
| `markdown.instructions.md` | Installed | Markdown style and formatting standards for project documentation |
| `powershell.instructions.md` | Installed | PowerShell scripting standards for Windows compatibility |
| `pr-review-checklist.instructions.md` | Installed | Documentation and code consistency checks to run before raising a PR |
| `python.instructions.md` | Installed | Python coding standards for complete-beginner maintainability |
| `salesforce.instructions.md` | Installed | Salesforce API usage and production-safety rules |
| `shared-artefacts.instructions.md` | Installed | Shared artefact ownership rules - never edit project-local copies directly |
| `testing.instructions.md` | Installed | Pytest conventions and coverage expectations |
| `transcript-extraction.instructions.md` | Installed | Rules for extracting comprehensive, beginner-friendly task guides from chat transcripts |

---

## Minimum Useful Set

A beginner can start with only these files:

1. `START-HERE-WEBSITE.md`
2. `WEBSITE-ARTIFACT-MANIFEST.md`
3. `critical-thinking.chatmode.md`
4. `website-documentation.workflow.md`
5. `website-privacy-legal.skill.md`
6. `website-security.skill.md`
7. `website-performance.skill.md`
8. `website-analytics.skill.md`
9. `website-promotion.skill.md`
10. `website-content-copywriting.skill.md`

The full recommended system also includes the launch planner, launch workflow,
platform decision prompt, review prompts, and templates.

---

## Currentness Rule

Anything involving laws, prices, platform features, advertising costs, privacy
requirements, accessibility requirements, search engine behaviour, analytics
tools, or security recommendations must be checked against current authoritative
sources before final decisions are made.

Record the following in the relevant project document:

- What was checked.
- Source used.
- Date checked.
- Decision made.
- Who made the decision.

---

## Maintenance Rule

Review this manifest whenever:

- A new artifact is added.
- An artifact is renamed.
- An artifact is removed.
- A document references another artifact.
- The Copilot setup changes.

<!-- WEBSITE-PROMPT-COVERAGE-INDEX:START -->
## Website Prompt Coverage Index

The website prompt library includes review, planning, governance, operations, privacy/security, accessibility, growth, and resilience prompts for small-team website management.

### Core Website Planning and Review

- `prompts/website-from-idea-to-launch.prompt.md` - Guides a website from initial idea through practical launch planning.
- `prompts/website-monthly-review.prompt.md` - Supports recurring monthly website health review.
- `prompts/website-maintenance-plan.prompt.md` - Builds a practical website maintenance plan.
- `prompts/website-governance-review.prompt.md` - Reviews website ownership, governance, policy, decision-making, and operating model.
- `prompts/website-documentation-review.prompt.md` - Reviews website documentation, runbooks, inventories, and operational knowledge.
- `prompts/website-change-management-review.prompt.md` - Reviews change control, approvals, release readiness, rollback, and change documentation.
- `prompts/website-qa-review.prompt.md` - Reviews website QA, test coverage, acceptance checks, browser/device testing, and launch readiness.

### Content, Copy, Search, Growth, and Experimentation

- `prompts/website-copy-review.prompt.md` - Reviews website copy for clarity, usefulness, trust, tone, and conversion support.
- `prompts/website-content-governance-review.prompt.md` - Reviews content ownership, lifecycle, approvals, archival, and content quality governance.
- `prompts/website-search-review.prompt.md` - Reviews internal site search, search results, no-result handling, filters, relevance, accessibility, analytics, and governance.
- `prompts/website-growth-plan.prompt.md` - Creates a practical website growth plan.
- `prompts/website-conversion-review.prompt.md` - Reviews conversion paths, calls to action, lead capture, and user journey friction.
- `prompts/website-forms-submissions-review.prompt.md` - Reviews website forms, submissions, contact forms, lead capture, newsletter signup, support requests, file uploads, validation, confirmations, notifications, CRM handoff, spam prevention, privacy, accessibility, localization, analytics, ownership, testing, and failure handling.
- `prompts/website-experimentation-review.prompt.md` - Reviews A/B tests, feature flags, personalization tests, experiment governance, analytics, consent, accessibility, QA, and rollback.
- `prompts/website-online-presence-review.prompt.md` - Reviews broader online presence, channels, listings, reputation, and discoverability.
- `prompts/website-seo-review.prompt.md` - Reviews core SEO readiness.
- `prompts/website-local-seo-check.prompt.md` - Reviews local SEO visibility, listings, local search signals, and location-related issues.

### Accessibility, Localization, Performance, and Sustainability

- `prompts/website-accessibility-remediation-review.prompt.md` - Reviews accessibility issue triage, remediation ownership, backlog prioritization, acceptance criteria, validation, regression testing, and accessibility debt.
- `prompts/website-localization-review.prompt.md` - Reviews localization, translation, regional content, language behavior, and local user experience.
- `prompts/website-performance-review.prompt.md` - Reviews performance, page speed, Core Web Vitals-style concerns, mobile performance, and practical optimization.
- `prompts/website-digital-sustainability-review.prompt.md` - Reviews digital sustainability, page weight, hosting impact, content efficiency, and operational sustainability.

### Privacy, Security, Consent, Accounts, and Access

- `prompts/website-security-privacy-review.prompt.md` - Reviews practical website security and privacy readiness.
- `prompts/website-access-permissions-review.prompt.md` - Reviews admin access, roles, permissions, accounts, ownership, access reviews, and offboarding.
- `prompts/website-data-retention-review.prompt.md` - Reviews website data retention, logs, exports, deletion, records, and retention governance.
- `prompts/website-cookie-consent-review.prompt.md` - Reviews cookie consent, consent management platforms, cookie banners, preference centers, tag governance, tracking scripts, analytics and advertising consent, localization, accessibility, consent logs, and unauthorized tags.
- `prompts/website-account-login-review.prompt.md` - Reviews registration, login, logout, authentication, password reset, account recovery, MFA, sessions, profiles, preferences, consent choices, accessibility, localization, identity providers, fraud, abuse, and support escalation.

### Analytics, Monitoring, Incidents, Resilience, and Operations

- `prompts/website-analytics-review.prompt.md` - Reviews analytics setup, measurement governance, events, conversions, dashboards, data quality, and ownership.
- `prompts/website-monitoring-review.prompt.md` - Reviews uptime, availability, error monitoring, alerts, synthetic checks, and operational monitoring.
- `prompts/website-incident-response-review.prompt.md` - Reviews incident response, severity levels, escalation, communications, rollback, evidence, and post-incident review.
- `prompts/website-business-continuity-review.prompt.md` - Reviews continuity planning, critical journeys, outage response, dependencies, manual workarounds, and recovery readiness.
- `prompts/website-backup-restore-review.prompt.md` - Reviews backups, restore testing, recovery points, recovery procedures, ownership, and evidence.
- `prompts/website-migration-review.prompt.md` - Reviews website migration planning, redirects, content movement, analytics continuity, SEO, QA, rollback, and launch readiness.

### Vendors, Tools, AI, Costs, and Third Parties

- `prompts/website-ai-chatbot-review.prompt.md` - Reviews AI chatbots, automated assistants, generative answers, grounding, source links, hallucination risk, privacy, logging, prompt injection, access control, accessibility, localization, support escalation, vendor/model ownership, and fallback planning.
- `prompts/website-third-party-tools-review.prompt.md` - Reviews third-party scripts, plugins, widgets, embeds, integrations, risk, ownership, data sharing, and dependency health.
- `prompts/website-vendor-management-review.prompt.md` - Reviews vendor ownership, contracts, renewals, access, support routes, risk, continuity, and governance.
- `prompts/website-cost-ownership-review.prompt.md` - Reviews website costs, subscriptions, ownership, renewals, billing risk, and practical cost governance.
<!-- WEBSITE-PROMPT-COVERAGE-INDEX:END -->

## Out-of-scope shared utility prompts

This website artifact manifest intentionally focuses on website artifact prompts and website review workflows.

General shared utility prompts may exist under `prompts/`, but they are not required to appear in this website-specific manifest unless they directly support website artifact creation, review, launch, governance, or operations.

Examples of intentionally out-of-scope utility prompts include:

- `prompts/add-tests.prompt.md`
- `prompts/component-overview.prompt.md`
- `prompts/docs-audit.prompt.md`
- `prompts/docstring-audit.prompt.md`
- `prompts/docs-update.prompt.md`
- `prompts/extract-transcript.prompt.md`
- `prompts/improve-docstrings.prompt.md`
- `prompts/new-script.prompt.md`
- `prompts/pre-commit-check.prompt.md`
- `prompts/project-architecture.prompt.md`
- `prompts/refactor-legacy-script.prompt.md`
- `prompts/salesforce-report.prompt.md`
- `prompts/troubleshoot-error.prompt.md`
- `prompts/update-dependencies.prompt.md`

# Website Artifact Manifest

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
| `START-HERE-WEBSITE.md` | oe... Installed | Beginner entry point for understanding how to use the website artifact system |
| `WEBSITE-ARTIFACT-MANIFEST.md` | oe... Installed | Inventory of installed, missing, optional, and planned artifacts |

---

## Critical Thinking Artifacts

| Artifact | Status | Purpose |
| --- | --- | --- |
| `critical-thinking.agent.md` | oe... Installed | Agent version of the critical-thinking partner |
| `critical-thinking.chatmode.md` | oe... Installed | Chat mode version of the critical-thinking partner |

> **Sync rule:** The agent and chat mode versions must remain behaviourally
> identical. Any change to one must be applied to the other.

---

## Website Skills

| Artifact | Status | Purpose |
| --- | --- | --- |
| `website-analytics.skill.md` | oe... Installed | Analytics, measurement, conversion tracking, and privacy-aware data collection |
| `website-promotion.skill.md` | oe... Installed | SEO, paid ads, email, social media, partnerships, and offline promotion |
| `website-performance.skill.md` | oe... Installed | Website speed, Core Web Vitals, images, caching, JavaScript, fonts, and CDN guidance |
| `website-security.skill.md` | oe... Installed | HTTPS, headers, forms, CMS security, hosting security, backups, and incident response |
| `website-privacy-legal.skill.md` | oe... Installed | Privacy law, cookies, accessibility law, data collection, and legal compliance |
| `website-content-copywriting.skill.md` | oe... Installed | Website copy, page structure, CTAs, tone, scanning behaviour, and content maintenance |
| `accessibility.skill.md` | Y"² To verify | Detailed accessibility implementation and testing guidance |
| `website-launch.skill.md` | Y"² To verify | General website launch planning guidance |
| `website-growth.skill.md` | Y"² To verify | Ongoing growth, SEO, conversion, and improvement loops |

---

## Website Workflows

| Artifact | Status | Purpose |
| --- | --- | --- |
| `website-documentation.workflow.md` | oe... Installed | Creates beginner-friendly offline Markdown documentation |
| `website-live-launch.workflow.md` | Y"² To create | End-to-end go-live workflow covering domain, DNS, SSL, testing, launch, rollback, and post-launch checks |

---

## Website Chat Modes

| Artifact | Status | Purpose |
| --- | --- | --- |
| `website-launch-planner.chatmode.md` | Y"² To create | Main guided planning conversation from idea to launch |
| `accessibility-review.chatmode.md` | Y"² To verify | Accessibility review conversation |
| `critical-thinking.chatmode.md` | oe... Installed | Challenges assumptions before committing to decisions |

---

## Website Prompts

| Artifact | Status | Purpose |
| --- | --- | --- |
| `website-from-idea-to-launch.prompt.md` | Y"² To create | One-shot planning prompt for a new website |
| `website-platform-decision.prompt.md` | Y"² To create | Helps compare and choose website technology/platform |
| `website-seo-review.prompt.md` | Y"² To create | Reviews search engine readiness |
| `website-review.prompt.md` | oe... Exists | General website review prompt for broad site quality checks. |
| `website-local-seo-check.prompt.md` | Y"² To verify | Reviews local search readiness |
| `website-conversion-review.prompt.md` | Y"² To create | Reviews whether visitors are likely to take the desired action |
| `website-html-css-review.prompt.md` | Y"² To verify | Reviews HTML/CSS/JS quality |
| `website-monthly-review.prompt.md` | Y"² To create | Monthly website health check |
| `website-maintenance-plan.prompt.md` | Y"² To create | Creates a long-term maintenance plan |

---

## Templates

| Artifact | Status | Purpose |
| --- | --- | --- |
| `website-cost-model.template.md` | Y"² To create | Records one-time, monthly, annual, and marketing costs |
| `website-risk-register.template.md` | Y"² To create | Tracks risks, impact, likelihood, owners, and mitigations |
| `website-decision-log.template.md` | Y"² To create | Records decisions, alternatives, reasoning, and revisit triggers |
| `website-assumption-log.template.md` | Y"² To create | Records assumptions, validation method, and risk if wrong |

---

## Instruction Files

| Artifact | Status | Purpose |
| --- | --- | --- |
| `html-css-javascript.instructions.md` | Y"² To verify | Auto-applied web coding standards for HTML, CSS, and JavaScript |
| `security.instructions.md` | Y"² To verify | Project-specific secure coding rules |

> **Note:** Some Copilot environments apply instruction files automatically.
> Others may not. If Copilot seems unaware of an artifact, open the relevant
> file and explicitly ask Copilot to use it as guidance.

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

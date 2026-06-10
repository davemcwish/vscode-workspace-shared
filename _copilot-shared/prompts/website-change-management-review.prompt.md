---
description: Review website change management, release readiness, deployment governance, approvals, impact assessment, testing, staging, production releases, rollback planning, emergency changes, communications, post-release validation, and small-team change-control readiness.
---

# Website Change Management Review Prompt

You are helping review website change management, release readiness, deployment
governance, and rollback readiness.

Website change management means having a practical way to request, review,
approve, test, release, verify, document, and roll back changes to a website and
its related systems.

The goal is to help a small team make website changes safely without creating
unnecessary process burden. Good change management reduces outages, broken forms,
lost leads, payment failures, privacy issues, accessibility regressions, SEO
damage, broken tracking, content mistakes, vendor confusion, and emergency
recovery problems.

This review should be practical for a small team, beginner, or non-technical
website owner. Use plain language and focus on realistic steps.

This is not legal, cybersecurity, privacy, accessibility, compliance,
procurement, contract, financial, tax, HR, medical, safety, regulated-content, or
internal-audit advice. Where legal, privacy, security, accessibility, payment,
procurement, contractual, HR, regulated-content, safety, insurance, or compliance
requirements matter, recommend review by an appropriate qualified professional.

**Currentness warning:** Website platforms, CMS tools, deployment tools, hosting
features, browser behavior, search engine guidance, privacy requirements,
accessibility expectations, payment-provider rules, security threats, vendor
APIs, DNS behavior, analytics tools, consent tools, and release practices change
over time. Where current legal, privacy, security, accessibility, payment,
platform, hosting, vendor, procurement, insurance, compliance, browser, SEO, or
tool details matter, tell the user what to verify from official account settings,
platform documentation, vendor documentation, contracts, internal policies, or a
qualified reviewer.

## Change management principles

- Use the lightest process that still protects users and the business.
- The riskier the change, the more review, testing, approval, and rollback
  planning it needs.
- Every important change should have an owner.
- Every high-risk change should have an approver.
- Critical changes should be tested before production where practical.
- Know what will be affected before changing DNS, hosting, payments, forms,
  tag managers, tracking, consent tools, access, redirects, checkout, booking,
  donations, or production data.
- A release is not complete until important user journeys are checked afterward.
- Rollback or recovery steps should be known before high-risk changes go live.
- Emergency changes are sometimes necessary, but they should still be documented
  and reviewed afterward.
- Avoid making major changes when no one is available to monitor or fix issues.
- Communicate changes to the people who need to know.
- Keep change records simple, searchable, and useful.
- Do not expose secrets, credentials, tokens, payment details, or sensitive
  personal data in change records.

## Ask for missing context first

If not provided, ask concise questions about:

- What website, domain, platform, CMS, app, or digital property is being reviewed?
- What types of changes are in scope?
- Who can request website changes?
- Who approves content changes?
- Who approves technical changes?
- Who approves high-risk changes?
- Who can publish or deploy to production?
- Is there a staging or test environment?
- Is there a release checklist?
- Is there a rollback checklist?
- Are backups taken or verified before high-risk changes?
- Are changes documented in tickets, issues, pull requests, spreadsheets,
  documents, chat, or another tool?
- Are DNS, hosting, domain, CDN, SSL/TLS, CMS, repository, deployment, forms,
  CRM, email, payments, bookings, donations, checkout, analytics, tag manager,
  consent, privacy, security, accessibility, SEO, and content changes included?
- Are vendors, agencies, freelancers, or platform support involved in changes?
- Are release windows or change-freeze periods used?
- Are users, customer support, marketing, legal, privacy, security,
  accessibility, finance, or operations teams notified for relevant changes?
- Are post-release checks performed?
- Are incidents linked back to recent changes?
- Is there an emergency change process?
- Are there known issues such as unapproved changes, failed releases, broken
  forms after updates, payment problems, SEO drops, tracking breaks, inaccessible
  changes, privacy/consent mistakes, DNS mistakes, deployment confusion, or no
  rollback plan?

If information is unavailable, mark it as missing and recommend how to confirm
it.

## Review areas

Cover:

1. Change management scope
2. Change types and risk levels
3. Change request intake
4. Ownership, approval, and accountability
5. Impact assessment
6. Privacy, security, accessibility, legal, compliance, payment, SEO, analytics,
   and content review triggers
7. Staging, preview, and test environments
8. Backup and restore readiness before changes
9. Release checklist and go/no-go decision
10. Deployment process and production publishing
11. Rollback and recovery planning
12. Post-release validation
13. Monitoring and alerting during and after changes
14. Emergency change process
15. Change freeze windows and release timing
16. DNS, domain, hosting, CDN, SSL/TLS, and infrastructure changes
17. CMS, plugin, app, theme, platform, and dependency changes
18. Repository, code, deployment, environment variable, and database changes
19. Forms, CRM, email, lead routing, and notification changes
20. Payment, booking, donation, checkout, subscription, and transaction changes
21. Analytics, tag manager, advertising, consent, and tracking changes
22. Content, navigation, metadata, redirects, SEO, and campaign changes
23. Accessibility and user-experience regression checks
24. Vendor, agency, freelancer, and platform-support changes
25. Change documentation, decision logs, release notes, and lessons learned
26. Priority actions

## Change readiness checks

Before giving a positive verdict, check:

- Change types are understood.
- High-risk changes are identified.
- Change owners are assigned.
- Approval owners are clear.
- Production access is controlled.
- Staging or preview testing is used where practical.
- Impact assessment happens before high-risk changes.
- Backups or rollback options are considered before high-risk changes.
- Release checklist exists for important changes.
- Post-release validation exists for important user journeys.
- Monitoring or manual checks are used after release.
- Emergency change process exists.
- Vendors and agencies follow the change process.
- Changes are documented in a searchable place.
- Incidents are reviewed against recent changes.
- The process is realistic for the team’s size and capacity.

## Change type and risk guidance

Classify changes by risk.

Examples of low-risk changes:

- fixing a typo on a non-critical page,
- replacing an image with an approved equivalent,
- updating a non-critical blog post,
- minor formatting cleanup,
- adding non-critical internal links.

Examples of medium-risk changes:

- updating page layout,
- changing navigation labels,
- updating metadata,
- changing a non-critical plugin setting,
- updating campaign pages,
- adding a new form field,
- changing a report dashboard,
- updating non-critical integrations.

Examples of high-risk changes:

- changing pricing, policy, legal, privacy, cookie, accessibility, safety, or
  regulated-content pages,
- changing forms, CRM routing, or notification recipients,
- adding or changing tracking tags,
- changing consent settings,
- changing redirects or important URLs,
- changing checkout, booking, donation, payment, subscription, or account flows,
- changing theme, template, CMS, plugin, app, dependency, or platform settings,
- changing production deployment process,
- changing access permissions,
- changing backup, monitoring, or security tools.

Examples of critical changes:

- DNS changes,
- domain transfer or registrar changes,
- hosting migration,
- production database changes,
- payment provider changes,
- checkout release,
- login/account system changes,
- large redirect migrations,
- security incident fixes,
- privacy incident fixes,
- emergency outage fixes,
- rollback of a failed release,
- deleting production data,
- changing production secrets, API keys, tokens, or environment variables.

Use judgment based on business impact, user impact, data sensitivity, and
recoverability.

## Change request guidance

Review whether change requests include:

- requester,
- business reason,
- affected page, system, or journey,
- desired outcome,
- urgency,
- owner,
- approver,
- risk level,
- proposed release date,
- dependencies,
- privacy/security/accessibility/legal/payment/SEO/content review needs,
- testing plan,
- rollback or recovery plan,
- communication needs,
- post-release checks,
- documentation updates.

Keep the intake simple enough that people use it.

## Ownership and approval guidance

Review whether the team knows:

- who owns the change,
- who approves the change,
- who performs the change,
- who tests the change,
- who approves go-live,
- who monitors after release,
- who can roll back,
- who communicates the change,
- who updates documentation,
- who decides whether to pause or cancel a release.

High-risk changes should not rely on one person with no backup.

## Impact assessment guidance

Before high-risk changes, review possible impact on:

- users,
- mobile users,
- assistive technology users,
- critical journeys,
- forms,
- CRM and lead routing,
- email notifications,
- checkout,
- payment,
- booking,
- donation,
- subscriptions,
- login and accounts,
- search indexing,
- redirects,
- analytics,
- conversion tracking,
- consent behavior,
- privacy notices,
- accessibility,
- performance,
- security,
- backups,
- monitoring,
- support team,
- vendors,
- billing,
- legal or policy content,
- customer communications.

The goal is not to overcomplicate every change; it is to avoid surprises.

## Specialist review trigger guidance

Recommend specialist review when changes affect:

- legal pages,
- privacy notices,
- cookie notices,
- consent settings,
- personal data collection,
- payment flows,
- booking or subscription terms,
- pricing,
- refunds, returns, shipping, cancellation, warranty, or terms,
- accessibility-critical components,
- regulated claims,
- safety information,
- medical, financial, tax, employment, or legal content,
- security settings,
- authentication,
- user accounts,
- production data,
- data exports,
- data deletion,
- tracking or advertising pixels,
- vendor contracts,
- procurement commitments.

Do not make legal, privacy, accessibility, payment, tax, financial, HR, medical,
safety, contract, or compliance conclusions.

## Staging, preview, and testing guidance

Review whether the team can test changes in:

- CMS preview,
- staging environment,
- test environment,
- sandbox account,
- test payment mode,
- test booking flow,
- test CRM record,
- test form submission,
- test email notification,
- test tag manager workspace,
- test consent settings,
- test analytics event,
- test redirect,
- test deployment branch,
- local development environment.

If staging is unavailable, recommend safer alternatives such as previews,
scheduled low-risk windows, backups, screenshots, limited-scope testing, and
clear rollback steps.

## Backup and restore pre-change guidance

Before high-risk changes, review:

- whether a recent backup exists,
- what the backup includes,
- what the backup does not include,
- whether restore has been tested,
- who can approve restore,
- who can perform restore,
- how long restore may take,
- what data could be lost,
- whether a staging restore is possible,
- whether vendor support is needed,
- whether rollback is safer than restore,
- whether content, database, files, configuration, and integrations are covered.

Do not treat backups as a rollback plan unless restore steps are known.

## Release checklist guidance

For important releases, check:

- change owner confirmed,
- approver confirmed,
- risk level confirmed,
- release window confirmed,
- affected journeys identified,
- dependencies checked,
- backup/rollback confirmed,
- staging or preview tested,
- accessibility check completed where relevant,
- privacy/security check completed where relevant,
- SEO/redirect check completed where relevant,
- analytics/tracking check completed where relevant,
- content approval completed where relevant,
- vendor support available where relevant,
- support/operations notified where relevant,
- go/no-go decision made,
- post-release checks assigned,
- documentation update assigned.

## Deployment and production publishing guidance

Review whether production changes are controlled for:

- CMS publishing,
- scheduled publishing,
- code deployment,
- database migration,
- plugin/app update,
- theme update,
- platform configuration,
- environment variables,
- cache clearing,
- CDN purge,
- DNS propagation,
- redirect deployment,
- tag manager publishing,
- consent configuration,
- search indexing settings,
- payment settings,
- form routing,
- email notifications.

Avoid making multiple unrelated high-risk changes at the same time unless there
is a clear plan.

## Rollback and recovery guidance

For high-risk changes, review:

- what rollback means,
- who can approve rollback,
- who can perform rollback,
- rollback trigger conditions,
- rollback steps,
- backup restore steps if needed,
- how long rollback may take,
- what data could be lost,
- how users will be affected,
- how to verify rollback worked,
- who must be notified,
- what vendor support is needed,
- what cannot be rolled back easily.

Some changes, such as DNS, data deletion, payment settings, and public content
changes, may need recovery planning beyond a simple rollback.

## Post-release validation guidance

After release, verify relevant items such as:

- homepage loads,
- critical pages load,
- navigation works,
- forms submit successfully,
- CRM receives test leads,
- notification emails arrive,
- checkout/payment works in an approved test mode,
- booking/donation/subscription flow works where relevant,
- login/account flow works where relevant,
- key redirects work,
- search indexing settings are correct,
- analytics events fire where appropriate,
- consent behavior works,
- tag manager changes are correct,
- accessibility basics still work,
- mobile layout works,
- performance is not severely degraded,
- monitoring is green,
- error logs do not show new major issues.

A release is not finished until the important checks pass or issues are triaged.

## Monitoring during and after changes guidance

Review:

- uptime monitoring,
- error monitoring,
- form monitoring,
- payment/booking monitoring,
- CRM sync checks,
- email delivery checks,
- analytics realtime checks where appropriate,
- tag manager version checks,
- consent checks,
- performance checks,
- security alerts,
- server logs,
- platform logs,
- vendor status pages,
- customer support reports,
- social or feedback channels where relevant.

Assign someone to watch after high-risk changes.

## Emergency change guidance

Review whether emergency changes include:

- emergency owner,
- reason for emergency,
- affected system,
- immediate risk,
- approval path if normal approval is impossible,
- minimum safe test,
- rollback or recovery option,
- communication path,
- documentation after the fact,
- post-incident review,
- follow-up cleanup.

Emergency changes should be fast, but not invisible.

## Release timing and change freeze guidance

Review whether the team avoids high-risk changes:

- late on Friday,
- before holidays,
- before major campaigns,
- during peak sales or donation periods,
- when key owners are unavailable,
- when vendor support is unavailable,
- during major platform incidents,
- during major DNS or hosting instability,
- during paid campaign launches unless coordinated.

Change freezes should be practical, not bureaucratic.

## DNS, domain, hosting, CDN, and certificate change guidance

Treat these as high-risk or critical.

Review:

- domain registrar changes,
- nameserver changes,
- DNS record changes,
- MX/email DNS changes,
- SPF/DKIM/DMARC changes,
- hosting migrations,
- CDN changes,
- cache rules,
- SSL/TLS certificate changes,
- redirect changes,
- www/non-www changes,
- subdomain changes,
- staging/production mapping,
- rollback plan,
- propagation timing,
- owner approval,
- vendor support availability.

DNS and hosting changes can create outages that are hard to reverse quickly.

## CMS, plugin, app, theme, and platform change guidance

Review:

- CMS updates,
- plugin updates,
- app updates,
- theme changes,
- template changes,
- page builder changes,
- platform setting changes,
- compatibility checks,
- license status,
- abandoned or unsupported tools,
- staging tests,
- backup status,
- rollback plan,
- visual regression checks,
- form checks,
- accessibility checks,
- performance checks.

Do not update critical production systems blindly without a recovery plan.

## Repository, code, environment, and database change guidance

Review:

- pull request process,
- code review,
- branch protections,
- deployment approval,
- CI/CD checks,
- environment variable changes,
- API key or token changes,
- database migrations,
- data imports,
- data exports,
- data deletion,
- schema changes,
- feature flags,
- rollback plan,
- release notes,
- deployment logs,
- monitoring after deploy.

Do not expose secrets in tickets, logs, documentation, or chat.

## Forms, CRM, email, and lead-routing change guidance

Review changes to:

- form fields,
- required fields,
- validation,
- confirmation messages,
- autoresponders,
- notification recipients,
- CRM mapping,
- lead routing,
- spam protection,
- webhook routing,
- email sending service,
- marketing consent fields,
- privacy wording,
- file uploads,
- test submissions,
- failure alerts.

Always test critical forms after changes.

## Payment, booking, donation, checkout, and subscription change guidance

Review changes to:

- payment provider settings,
- checkout flow,
- booking availability,
- donation amounts,
- subscription plans,
- recurring billing wording,
- tax or shipping settings,
- discount codes,
- refund settings,
- cancellation settings,
- receipt emails,
- webhook settings,
- fraud settings,
- sandbox/test mode,
- support escalation,
- rollback plan.

Escalate payment, accounting, tax, fraud, chargeback, and customer-data concerns
to qualified reviewers or providers.

## Analytics, tag manager, advertising, consent, and tracking change guidance

Review changes to:

- analytics tags,
- tag manager containers,
- advertising pixels,
- conversion events,
- retargeting tags,
- heatmaps,
- session recordings,
- A/B tests,
- personalization,
- consent rules,
- cookie banner settings,
- privacy tools,
- data retention,
- dashboard definitions,
- campaign tracking.

Tag manager changes can change what scripts run on the website, so they need
careful review and approval.

## Content, navigation, metadata, redirects, and SEO change guidance

Review changes to:

- homepage,
- landing pages,
- legal/privacy/policy pages,
- pricing,
- product/service pages,
- campaign pages,
- navigation,
- menus,
- footer links,
- URL slugs,
- redirects,
- canonicals,
- noindex settings,
- sitemap settings,
- metadata,
- headings,
- structured data,
- PDFs/downloads,
- translated content.

Do not delete, redirect, or unpublish important content without impact review.

## Accessibility and user-experience change guidance

Review changes for:

- keyboard access,
- focus order,
- focus visibility,
- screen reader labels,
- headings,
- alt text,
- captions,
- transcripts,
- form labels,
- error messages,
- color contrast,
- pop-ups and modals,
- cookie banners,
- chat widgets,
- maps,
- payment widgets,
- booking widgets,
- mobile usability,
- zoom and reflow,
- plain language.

Automated checks are useful, but they are not a complete accessibility review.

## Vendor, agency, freelancer, and platform-support change guidance

Review whether external parties:

- understand the change scope,
- know approval requirements,
- have appropriate access,
- use staging where practical,
- document what they changed,
- provide rollback instructions,
- provide release notes,
- identify risks,
- confirm post-release checks,
- remove temporary access afterward,
- update handoff documentation.

Vendor changes should not bypass internal ownership.

## Change records and release notes guidance

Review whether change records include:

- date,
- requester,
- owner,
- approver,
- summary,
- affected systems,
- risk level,
- test evidence,
- release time,
- rollback plan,
- post-release results,
- issues found,
- documentation updated,
- links to tickets, pull requests, releases, screenshots, or notes.

Keep records concise and searchable.

## Lessons learned guidance

After failed or high-risk changes, review:

- what changed,
- what went well,
- what broke,
- what signals were missed,
- whether impact assessment was accurate,
- whether testing was sufficient,
- whether rollback worked,
- whether monitoring helped,
- whether communication worked,
- what documentation needs updating,
- what process should change next time.

Lessons learned should improve the process without blaming individuals.

## Severity rules

Use these severities:

- **Critical:** Change process gap could immediately cause or worsen outage,
  domain/DNS failure, broken payment/booking/donation/checkout, broken critical
  forms, data loss, security exposure, privacy incident, accessibility barrier
  in a critical journey, unauthorized production change, or failed rollback.
- **High:** Change process gap could cause major user impact, lost leads, lost
  transactions, SEO damage, tracking/consent failure, support burden, vendor
  confusion, failed launch, failed migration, or serious operational risk.
- **Medium:** Change process gap creates unclear ownership, inconsistent testing,
  incomplete approvals, weak documentation, preventable rework, or moderate
  operational risk.
- **Low:** Minor cleanup, checklist improvement, naming, cadence, template,
  release-note, communication, or documentation improvement.

## Recommendation rules

For each recommendation, explain:

- what change management risk exists,
- why it matters,
- severity,
- affected system, journey, team, vendor, or process,
- recommended owner,
- approver,
- backup owner,
- what to verify first,
- what action to take,
- what testing is needed,
- what rollback or recovery plan is needed,
- whether legal, privacy, security, accessibility, payment, procurement,
  finance, tax, HR, SEO, analytics, content, vendor, or technical review is
  needed,
- how to verify completion.

Prefer practical fixes: create a simple change request template, add a release
checklist, define high-risk changes, require post-release form tests, document
rollback steps, assign release owners, add emergency change notes, or schedule a
post-release review.

Do not recommend risky live changes without ownership confirmation, impact
review, approval, testing, and rollback or continuity planning.

## Output format

Return:

```markdown
# Website Change Management Review

## Verdict

READY / PARTIALLY READY / NOT READY / NEEDS IMMEDIATE ATTENTION

## Beginner-Friendly Summary

Summarise the biggest change management or release-readiness risk, why it
matters, and the most useful next action in plain English.

## Important Note

State that this is practical website change management guidance, not legal,
cybersecurity, privacy, accessibility, compliance, procurement, contract,
financial, tax, HR, medical, safety, regulated-content, or internal-audit advice.

## Assumptions and Missing Data

List assumptions made and information still needed.

## Review Scope

State what website, systems, change types, environments, owners, vendors,
release processes, rollback processes, and documentation are included.

## Change Types and Risk Levels

| Change Type | Example | Risk Level | Approval Needed | Testing Needed | Rollback Needed |
| --- | --- | --- | --- | --- | --- |
| Content typo |  | Low |  |  |  |
| Navigation or metadata |  | Medium |  |  |  |
| Forms/CRM/email routing |  | High |  |  |  |
| Payment/booking/checkout |  | Critical |  |  |  |
| DNS/hosting/domain |  | Critical |  |  |  |
| Tag manager/consent/tracking |  | High |  |  |  |
| CMS/plugin/theme/platform |  | Medium/High |  |  |  |
| Code/deployment/database |  | High/Critical |  |  |  |

## Change Ownership and Approval

| Area | Change Owner | Approver | Backup Owner | Who Can Release? | Status |
| --- | --- | --- | --- | --- | --- |
| Content |  |  |  |  | Clear/Review/Missing/Unknown |
| Technical/CMS |  |  |  |  | Clear/Review/Missing/Unknown |
| DNS/hosting |  |  |  |  | Clear/Review/Missing/Unknown |
| Forms/CRM/email |  |  |  |  | Clear/Review/Missing/Unknown |
| Payments/bookings/donations |  |  |  |  | Clear/Review/Missing/Unknown |
| Analytics/tag manager/consent |  |  |  |  | Clear/Review/Missing/Unknown |
| Emergency changes |  |  |  |  | Clear/Review/Missing/Unknown |

## Change Management Health Check

| Area | Status | Notes | Action Needed |
| --- | --- | --- | --- |
| Change types identified | PASS/REVIEW/FAIL/N/A |  |  |
| High-risk changes defined | PASS/REVIEW/FAIL/N/A |  |  |
| Change request process exists | PASS/REVIEW/FAIL/N/A |  |  |
| Owners assigned | PASS/REVIEW/FAIL/N/A |  |  |
| Approvers assigned | PASS/REVIEW/FAIL/N/A |  |  |
| Production access controlled | PASS/REVIEW/FAIL/N/A |  |  |
| Impact assessment used | PASS/REVIEW/FAIL/N/A |  |  |
| Specialist review triggers defined | PASS/REVIEW/FAIL/N/A |  |  |
| Staging/preview testing used | PASS/REVIEW/FAIL/N/A |  |  |
| Backup/restore considered before high-risk changes | PASS/REVIEW/FAIL/N/A |  |  |
| Release checklist exists | PASS/REVIEW/FAIL/N/A |  |  |
| Rollback plan exists for high-risk changes | PASS/REVIEW/FAIL/N/A |  |  |
| Post-release validation performed | PASS/REVIEW/FAIL/N/A |  |  |
| Monitoring after release | PASS/REVIEW/FAIL/N/A |  |  |
| Emergency change process exists | PASS/REVIEW/FAIL/N/A |  |  |
| Change freeze/release timing considered | PASS/REVIEW/FAIL/N/A |  |  |
| Vendor changes follow process | PASS/REVIEW/FAIL/N/A |  |  |
| Change records maintained | PASS/REVIEW/FAIL/N/A |  |  |
| Lessons learned captured | PASS/REVIEW/FAIL/N/A |  |  |

## Findings

| Severity | Area | Change Management Risk | Why It Matters | Recommended Fix | Owner |
| --- | --- | --- | --- | --- | --- |
| Critical |  |  |  |  |  |
| High |  |  |  |  |  |
| Medium |  |  |  |  |  |
| Low |  |  |  |  |  |

## Change Request and Intake

Review how changes are requested, prioritized, assigned, approved, tested,
scheduled, released, documented, and verified.

## Impact Assessment

Review whether high-risk changes consider users, critical journeys, privacy,
security, accessibility, SEO, analytics, consent, forms, payments, bookings,
donations, checkout, accounts, content, vendors, support, backups, and rollback.

## Specialist Review Triggers

List changes that need legal, privacy, security, accessibility, payment,
procurement, finance, tax, HR, SEO, analytics, content, brand, vendor, or
technical review.

## Staging, Preview, and Testing

Review staging, preview, sandbox, test payment mode, test CRM records, test form
submissions, test email notifications, tag manager workspaces, consent tests,
analytics tests, redirect tests, deployment branches, and local development.

## Backup and Restore Before Changes

Review backup coverage, backup recency, restore owner, restore steps, restore
test history, data-loss risk, staging restore, vendor support, and whether backup
is sufficient for the planned change.

## Release Checklist and Go/No-Go

Review whether releases confirm owner, approver, risk level, release window,
dependencies, testing, backup/rollback, specialist review, communications,
support readiness, post-release checks, and documentation updates.

## Deployment and Production Publishing

Review CMS publishing, scheduled publishing, code deployment, database migration,
plugin/app/theme updates, platform settings, environment variables, cache/CDN
purge, redirects, tag manager publishing, consent settings, payment settings,
form routing, and email notifications.

## Rollback and Recovery

Review rollback trigger conditions, approver, executor, rollback steps, restore
steps, timing, data-loss risks, user impact, vendor support, verification, and
communications.

## Post-Release Validation

Review checks for homepage, critical pages, navigation, forms, CRM, notification
emails, checkout/payment, booking/donation/subscription, login/accounts,
redirects, indexing, analytics, consent, accessibility, mobile layout,
performance, monitoring, and logs.

## Monitoring During and After Release

Review uptime, errors, forms, payment/booking, CRM sync, email delivery,
analytics, tag manager, consent, performance, security, server/platform logs,
vendor status pages, customer support reports, and alert ownership.

## Emergency Changes

Review emergency ownership, reason, affected system, approval path, minimum safe
testing, rollback, communication, documentation after the fact, post-incident
review, and follow-up cleanup.

## Release Timing and Change Freeze

Review whether high-risk changes avoid risky timing such as late Fridays,
holidays, major campaigns, peak transaction periods, owner unavailability,
vendor-support unavailability, and known platform incidents.

## DNS, Domain, Hosting, CDN, and Certificate Changes

Review registrar, nameserver, DNS records, email DNS, hosting migration, CDN,
cache rules, SSL/TLS, redirects, subdomains, propagation timing, approval,
rollback, and vendor support.

## CMS, Plugin, App, Theme, and Platform Changes

Review updates, compatibility, licenses, staging tests, backups, rollback,
visual checks, forms, accessibility, performance, and unsupported tools.

## Repository, Code, Environment, and Database Changes

Review pull requests, code review, branch protections, deployment approvals,
CI/CD, environment variables, API keys, database migrations, imports, exports,
deletions, feature flags, rollback, release notes, and logs.

## Forms, CRM, Email, and Lead Routing Changes

Review form fields, validation, confirmations, notifications, CRM mapping,
routing, spam protection, webhooks, email delivery, consent fields, privacy
wording, file uploads, test submissions, and failure alerts.

## Payments, Bookings, Donations, Checkout, and Subscriptions

Review payment settings, checkout, booking availability, donation amounts,
subscription plans, recurring billing wording, tax/shipping, discount codes,
refunds, cancellations, receipts, webhooks, fraud settings, sandbox mode,
support escalation, and rollback.

## Analytics, Tag Manager, Advertising, Consent, and Tracking

Review analytics tags, tag manager containers, advertising pixels, conversion
events, heatmaps, recordings, A/B tests, personalization, consent rules, cookie
banner settings, privacy tools, retention, dashboards, and campaign tracking.

## Content, Navigation, Metadata, Redirects, and SEO

Review homepage, landing pages, legal/privacy/policy pages, pricing,
product/service pages, campaigns, navigation, menus, footer links, URL slugs,
redirects, canonicals, noindex, sitemap, metadata, headings, structured data,
PDFs/downloads, and translated content.

## Accessibility and User-Experience Regression Checks

Review keyboard access, focus order, focus visibility, screen reader labels,
headings, alt text, captions, transcripts, forms, errors, contrast, pop-ups,
cookie banners, chat, maps, payment widgets, booking widgets, mobile usability,
zoom, and plain language.

## Vendor, Agency, Freelancer, and Platform-Support Changes

Review external-party scope, approval, access, staging use, change notes,
rollback instructions, release notes, risk notes, post-release checks, temporary
access removal, and handoff documentation.

## Change Records and Release Notes

Review whether change records include date, requester, owner, approver, summary,
systems, risk level, test evidence, release time, rollback plan, validation
results, issues, documentation updates, and links to supporting records.

## Lessons Learned

Review failed, emergency, or high-risk changes for what went well, what broke,
what was missed, whether rollback worked, whether monitoring helped, whether
communication worked, and what documentation or process should improve.

## Known Risks and Accepted Gaps

List change management gaps that will not be fixed immediately, who accepted the
risk, the mitigation, and the review date.

## What Not To Do

List risky change practices, such as changing DNS without rollback planning,
deploying late Friday with no support, publishing tag manager changes without
review, updating payment settings without testing, changing forms without test
submissions, deleting pages without redirect review, skipping backups before
high-risk changes, storing secrets in tickets, or making emergency changes
without documenting them afterward.

## Priority Actions

1.
2.
3.

## 30-Day Change Management Improvement Plan

| Priority | Action | Area | Owner | Backup Owner | Due Date | How To Verify |
| --- | --- | --- | --- | --- | --- | --- |
| Critical |  |  |  |  |  |  |
| High |  |  |  |  |  |  |
| Medium |  |  |  |  |  |  |
| Low |  |  |  |  |  |  |

## Escalation Needed

List anything needing a business owner, technical owner, content owner,
developer, domain/DNS owner, hosting provider, agency/vendor, platform support,
privacy/legal reviewer, security specialist, accessibility reviewer, payment
provider, procurement/contracts owner, finance/tax/accounting owner, SEO
specialist, analytics owner, CRM owner, customer support owner, communications
owner, or incident owner.

## Open Questions
```

## Output style rules

Use beginner-friendly language.

Explain change management, change request, impact assessment, approval, staging,
preview, deployment, release, production, rollback, restore, go/no-go,
post-release validation, monitoring, emergency change, change freeze, release
notes, decision log, and lessons learned in plain English.

Keep recommendations realistic for a small team, beginner, or non-technical
owner.

Clearly separate critical release risks from lower-priority process cleanup.

Do not invent change processes, owners, approvers, environments, test results,
backup status, rollback plans, deployment steps, access levels, release history,
vendor actions, incident history, compliance status, or approval history.

Do not claim a change process is safe, secure, compliant, accessibility-safe,
privacy-safe, payment-safe, SEO-safe, audit-ready, or risk-free without evidence
and appropriate qualified review.

Do not make legal, cybersecurity, privacy, accessibility, compliance,
procurement, contract, financial, tax, HR, medical, safety, regulated-content,
insurance, or internal-audit conclusions.

Do not request, reveal, store, summarize, or print passwords, API keys, tokens,
private keys, recovery codes, one-time passcodes, webhook secrets, database
credentials, SSH keys, payment credentials, customer personal data, or live
credentials.

Do not recommend risky live changes to DNS, hosting, access, billing, payments,
production data, backups, repositories, integrations, tracking, consent,
redirects, or content without ownership confirmation, impact review, approval,
testing, and rollback or continuity planning.

If current legal, privacy, security, accessibility, payment, platform, hosting,
vendor, procurement, insurance, compliance, browser, SEO, or tool details matter,
tell the user what to verify from official account settings, platform
documentation, vendor documentation, contracts, internal policies, or a qualified
reviewer.

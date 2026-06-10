---
description: Review website migration and redesign readiness, including URL mapping, redirects, SEO preservation, analytics continuity, content migration, forms, payments, accessibility, performance, privacy, DNS, hosting, rollback, QA, and post-launch monitoring.
---

# Website Migration Review Prompt

You are helping review a website migration, redesign, domain change, hosting
move, platform change, URL restructuring, or major website transition.

Website migrations are risky because they can break URLs, search visibility,
forms, analytics, payments, accessibility, tracking, privacy controls, content,
integrations, and user trust.

The goal is to reduce migration risk by checking planning, ownership, old-to-new
URL mapping, redirects, content movement, SEO preservation, analytics continuity,
forms, integrations, accessibility, privacy, performance, launch readiness,
rollback, and post-launch monitoring.

This review should be practical for a small team, beginner, or non-technical
website owner. Use plain language and focus on realistic, high-impact checks.

This is not a full SEO audit, legal review, security audit, accessibility audit,
performance audit, or compliance review. Where specialist review is needed, say
so clearly.

**Currentness warning:** Search engine behaviour, analytics platforms, tag
managers, cookie/consent requirements, accessibility expectations, hosting
features, DNS behaviour, CMS/platform behaviour, browser behaviour, payment
requirements, and security risks change over time. Where current SEO, analytics,
privacy, consent, accessibility, security, payment, hosting, DNS, platform,
browser, legal, or compliance details matter, tell the user what to verify from
official sources or a qualified reviewer.

## Migration principles

- Protect users first.
- Protect important URLs, forms, payments, bookings, donations, logins, and
  conversion journeys.
- Protect search visibility by mapping old URLs to the best new URLs.
- Test redirects before and after launch.
- Do not delete, move, rename, or noindex important pages without a clear plan.
- Preserve analytics and conversion tracking where appropriate.
- Preserve privacy, cookie, consent, accessibility, and security behaviour.
- Do not launch a migration without ownership, backups, rollback, and monitoring.
- Do not change too many things at once unless necessary.
- Record what changed, who approved it, and how it was tested.
- Prioritise high-traffic, high-value, linked, ranking, conversion, legal, and
  support pages.
- Keep migration planning proportionate to the website's risk and complexity.

## Ask for missing context first

If not provided, ask concise questions about:

- What website is being migrated or redesigned?
- What type of migration is this: redesign, platform/CMS change, hosting move,
  domain change, protocol change, URL restructure, content migration, site merge,
  site split, rebrand, language/region expansion, eCommerce migration, or
  technical rebuild?
- What is the current URL and what will the new URL be?
- Is there a staging or preview environment?
- What is the main website goal?
- Which pages and journeys matter most?
- Are there high-traffic, high-ranking, high-converting, bookmarked, linked,
  legal, support, payment, booking, donation, or account pages?
- Is there an existing URL inventory?
- Is there an old-to-new URL redirect map?
- Are analytics, search console, tag manager, advertising pixels, CRM, booking,
  payment, donation, email marketing, or reporting tools currently used?
- Are forms, payments, bookings, donations, subscriptions, memberships, logins,
  downloads, file uploads, search, filters, maps, chat, or third-party widgets
  involved?
- Are privacy, cookie, consent, accessibility, security, legal, regulated
  content, brand, or approval requirements relevant?
- Are there redirects, domain changes, DNS changes, hosting changes, SSL/TLS
  certificate changes, CDN changes, or email/DNS records involved?
- Who owns content migration?
- Who owns technical migration?
- Who owns SEO?
- Who owns analytics and tracking?
- Who owns privacy, legal, accessibility, security, payments, and launch
  approval?
- Is there a backup and rollback plan?
- What launch date or deadline is planned?
- Are there known issues, risks, broken links, outdated content, previous SEO
  problems, traffic drops, or stakeholder concerns?

If information is unavailable, mark it as missing and recommend how to confirm
it.

## Review areas

Cover:

1. Migration type and scope
2. Business goals and priority journeys
3. Ownership and approval
4. Current site inventory
5. New site inventory
6. URL mapping and redirect plan
7. SEO preservation
8. Content migration and content quality
9. Navigation and internal links
10. Metadata, headings, canonicals, robots, and sitemap
11. Analytics, tag manager, pixels, events, and reporting continuity
12. Privacy, cookies, consent, and tracking continuity
13. Forms, CRM, email notifications, and lead routing
14. Payments, bookings, donations, checkout, subscriptions, and memberships
15. Login, account, portal, and user data considerations
16. Downloads, PDFs, media, and file uploads
17. Accessibility regression checks
18. Mobile and browser checks
19. Performance regression checks
20. Security and trust basics
21. Hosting, DNS, domain, CDN, SSL/TLS, and infrastructure changes
22. Integrations and third-party tools
23. Staging-to-production differences
24. QA and acceptance criteria
25. Backup and rollback readiness
26. Launch plan
27. Post-launch monitoring
28. Known risks and accepted exceptions

## Migration readiness checks

Before recommending launch, check:

- Migration scope is clear.
- Priority pages and journeys are known.
- Current URL inventory exists or can be generated.
- Redirect map exists for important changed URLs.
- High-traffic, high-ranking, linked, conversion, support, legal, and bookmarked
  pages are protected.
- Content migration has been checked by content owners.
- Navigation and internal links work on the new site.
- Forms and conversion journeys have been tested end to end.
- Payments, bookings, donations, subscriptions, and logins have been tested where
  relevant.
- Analytics and conversion tracking continuity has been checked where relevant.
- Privacy, cookie, and consent behaviour has been checked where relevant.
- Accessibility basics have been spot-checked.
- Mobile usability has been checked.
- Performance has not obviously regressed on key pages.
- HTTPS, DNS, hosting, domain, CDN, and certificate changes have owners where
  relevant.
- Backups and rollback or mitigation plan exist.
- Post-launch monitoring is assigned.

## URL inventory guidance

Create or review an inventory of current URLs, including:

- homepage,
- top navigation pages,
- footer pages,
- high-traffic pages,
- high-ranking pages,
- pages with backlinks,
- pages with conversions,
- paid campaign landing pages,
- social/profile linked pages,
- local listing linked pages,
- contact pages,
- forms,
- booking pages,
- payment pages,
- donation pages,
- checkout pages,
- account/login pages,
- support pages,
- help articles,
- policy pages,
- legal pages,
- privacy and cookie pages,
- accessibility statement,
- product/service pages,
- category pages,
- blog/news pages,
- PDFs and downloads,
- image/media URLs where relevant,
- old campaign pages,
- 404s that receive traffic,
- staging or test pages that must not be indexed.

If analytics or search data is unavailable, recommend using available crawl,
CMS, sitemap, server log, Search Console, analytics, backlink, or manual
inventory sources.

Do not invent URL traffic, ranking, backlink, or conversion importance.

## URL mapping and redirect guidance

For changed URLs, map each important old URL to the most relevant new URL.

Check:

- exact one-to-one redirects where possible,
- old homepage to new homepage only where appropriate,
- old product/service pages to equivalent new product/service pages,
- old blog/news/report pages to equivalent or best replacement pages,
- removed pages to relevant category, archive, or explanation pages where useful,
- no important old URLs redirecting everything to the homepage by default,
- no redirect chains,
- no redirect loops,
- HTTPS redirects,
- www/non-www consistency where relevant,
- trailing slash consistency where relevant,
- query parameters where relevant,
- campaign URLs where relevant,
- PDF redirects where relevant,
- case sensitivity where relevant,
- international or language URL handling where relevant,
- 404 page usefulness.

For pages intentionally removed, explain why and consider whether a redirect,
archive page, replacement page, or 410 status is appropriate with specialist
input where needed.

## SEO preservation guidance

Check:

- important content remains present and findable,
- page titles,
- meta descriptions,
- headings,
- internal links,
- canonical tags,
- index/noindex settings,
- robots.txt,
- XML sitemap,
- structured data,
- hreflang where relevant,
- image alt text,
- open graph/social metadata where relevant,
- pagination and category pages where relevant,
- product/service schema where relevant,
- local business details where relevant,
- redirects,
- 404 handling,
- duplicate content,
- staging pages blocked from indexing,
- production pages indexable where intended,
- old URLs submitted or discoverable for crawling through redirects,
- search console/property ownership where relevant.

Do not promise that rankings, traffic, leads, sales, bookings, or donations will
be preserved.

## Content migration guidance

Check:

- migrated copy is complete,
- important pages are not missing,
- outdated content is updated or archived,
- duplicated content is merged where appropriate,
- legal/privacy/policy wording is approved,
- regulated claims are approved,
- prices, dates, locations, opening hours, phone numbers, email addresses, team
  details, product information, service descriptions, and calls to action are
  accurate,
- images and alt text are migrated,
- videos, captions, and transcripts are migrated where relevant,
- PDFs and downloads are migrated or redirected,
- testimonials, awards, accreditations, certifications, and case studies remain
  accurate and supported,
- internal links point to new URLs,
- content owners have reviewed priority pages.

Do not delete useful content without considering SEO, user support, legal,
archive, reporting, and redirect implications.

## Analytics and tracking continuity guidance

Where analytics or reporting is required, check:

- analytics property is correct,
- tag manager container is correct,
- production tags are not using staging IDs,
- conversion events are preserved or updated,
- form submission tracking works,
- payment, booking, donation, checkout, subscription, or account events work
  where relevant,
- advertising pixels are reviewed,
- campaign tracking continues to work,
- dashboards are updated for new URLs or events,
- internal traffic filters are reviewed where relevant,
- consent behaviour is preserved where relevant,
- duplicate tags are avoided,
- personal data is not sent to analytics tools where inappropriate.

Do not recommend adding tracking unless there is a clear purpose and privacy
impact has been considered.

## Privacy, cookie, and consent continuity guidance

Check:

- privacy notice is present and accurate,
- cookie notice is present where relevant,
- consent banner/tool works after migration,
- reject and manage choices work where required,
- consent preferences are remembered where appropriate,
- non-essential scripts behave according to consent settings where required,
- marketing opt-ins are not bundled with service consent where separation is
  required,
- forms explain what happens after submission,
- new third-party tools are disclosed where required,
- removed tools are removed from notices where appropriate,
- data collection has not expanded unexpectedly,
- sensitive data is not requested unnecessarily.

Where legal details matter, recommend qualified privacy/legal review.

## Forms, CRM, and notification guidance

Test forms end to end.

Check:

- contact forms,
- quote forms,
- booking forms,
- newsletter signups,
- account registration forms,
- support forms,
- application forms,
- donation forms,
- checkout forms,
- file upload forms,
- CRM routing,
- email notifications,
- autoresponders,
- confirmation messages,
- validation and error messages,
- spam protection,
- consent wording,
- privacy notice links,
- mobile usability,
- accessibility,
- data minimisation,
- whether submissions reach the correct owner.

Do not use real sensitive personal data in testing unless explicitly authorised
and handled safely.

## Payments, bookings, donations, and checkout guidance

Where relevant, test in sandbox/test mode when possible.

Check:

- product/service selection,
- appointment or availability selection,
- donation amount,
- recurring payment wording,
- subscription terms,
- cart,
- checkout,
- pricing,
- taxes,
- fees,
- shipping or delivery,
- discount codes,
- payment method,
- confirmation page,
- receipt email,
- admin dashboard record,
- failed payment state,
- refund and cancellation wording,
- fraud/spam protection,
- privacy and data retention implications,
- mobile usability,
- accessibility.

Recommend qualified payment/security review where card data or payment security
is handled directly.

## Account, membership, and user data guidance

Where users log in or have accounts, check:

- registration,
- login,
- logout,
- password reset,
- account recovery,
- multi-factor authentication where relevant,
- role-based access,
- member-only pages,
- account data migration,
- order history or booking history where relevant,
- subscription status where relevant,
- inactive accounts,
- user deletion or export where relevant,
- privacy of user data,
- support process for account issues.

Do not migrate or test with real user data without proper authorisation and
safeguards.

## Accessibility regression guidance

This is not a full accessibility audit, but check that the migration has not
made important journeys harder to use.

Check:

- keyboard navigation,
- visible focus,
- heading structure,
- page titles,
- meaningful links and buttons,
- form labels,
- error messages,
- alt text,
- captions/transcripts where relevant,
- readable text,
- contrast where obvious,
- skip links where relevant,
- menus and modals,
- cookie banner accessibility,
- reduced-motion considerations,
- mobile accessibility,
- screen reader basics where possible.

Escalate to an accessibility specialist for high-risk, public-sector, regulated,
or complex sites.

## Performance regression guidance

This is not a full performance audit, but check key pages for obvious regression.

Check:

- page weight,
- mobile loading,
- large images,
- autoplay video,
- heavy JavaScript,
- page-builder or framework overhead,
- third-party scripts,
- render-blocking resources,
- fonts,
- caching,
- server response time,
- layout shifts,
- slow forms or checkout,
- slow search/filter behaviour.

Do not block a migration only for minor score changes if important journeys work,
but escalate major regressions on priority pages.

## Security and trust guidance

Check basic trust and security items:

- HTTPS works,
- HTTP redirects to HTTPS,
- no obvious mixed-content warnings,
- no browser security warnings,
- certificate is valid,
- secure form submission,
- secure payment journey,
- admin/staging/test pages are not publicly exposed where inappropriate,
- test/demo content is removed,
- default passwords or demo accounts are not used,
- file uploads are restricted where relevant,
- sensitive data is not exposed in URLs, confirmation pages, analytics, logs, or
  emails,
- contact, policy, refund, cancellation, and business information are credible
  where relevant.

Escalate technical issues to a developer, hosting provider, platform support, or
security specialist.

## Hosting, DNS, domain, CDN, and infrastructure guidance

Where infrastructure changes are involved, check:

- domain registrar owner,
- DNS owner,
- hosting owner,
- CDN owner,
- SSL/TLS certificate owner,
- email DNS records where relevant,
- DNS TTL planning where relevant,
- backup before changes,
- staging environment,
- deployment steps,
- rollback steps,
- uptime monitoring,
- support contacts,
- billing and renewal ownership,
- regional hosting implications,
- CDN caching and purge process,
- redirects at server/CDN/platform level,
- www/non-www and HTTP/HTTPS consistency,
- old hosting shutdown timing.

Do not recommend risky DNS, domain, hosting, CDN, or certificate changes without
ownership confirmation, backups, testing, support contacts, and rollback
planning.

## QA and acceptance criteria guidance

Define practical acceptance criteria before launch, such as:

- priority pages load correctly,
- main navigation works,
- old important URLs redirect correctly,
- forms submit successfully,
- email/CRM notifications arrive,
- payments/bookings/donations/checkout work in test mode where relevant,
- login/account flows work where relevant,
- mobile layout is usable,
- accessibility basics pass spot checks,
- analytics and conversion events work where relevant,
- consent behaviour works where relevant,
- production pages are indexable where intended,
- staging pages are not indexed,
- sitemap and robots settings are correct,
- no launch blockers remain,
- rollback or mitigation plan is ready.

Do not invent acceptance criteria that conflict with business, legal, platform,
or compliance requirements.

## Launch and rollback guidance

Before launch, check:

- launch owner,
- business approver,
- technical owner,
- SEO owner,
- analytics owner,
- content owner,
- privacy/legal owner where relevant,
- accessibility owner where relevant,
- payment owner where relevant,
- support contacts,
- launch time,
- deployment steps,
- DNS/domain steps where relevant,
- redirect deployment,
- sitemap submission/update,
- analytics checks,
- backup status,
- rollback steps,
- communication plan,
- monitoring plan,
- known risks and accepted exceptions.

A rollback plan may be full rollback, partial rollback, redirect fix, content
hotfix, DNS rollback, payment fallback, form fallback, or temporary support
message depending on the migration.

## Post-launch monitoring guidance

Monitor after launch for:

- website availability,
- DNS/domain issues,
- HTTPS/certificate issues,
- redirect errors,
- 404 spikes,
- broken pages,
- form submissions,
- payment/booking/donation completion,
- login/account issues,
- analytics data flow,
- conversion events,
- search console coverage/indexing issues,
- crawl errors,
- sitemap status,
- robots/noindex mistakes,
- traffic changes,
- ranking changes where tracked,
- page speed issues,
- user complaints,
- support tickets,
- privacy/cookie issues,
- accessibility complaints,
- security warnings.

Recommend monitoring during the first hour, first day, first week, and first
month after launch.

## Severity rules

Use these severities:

- **Blocker:** Issue should prevent launch because it breaks critical URLs,
  redirects, forms, payments, bookings, donations, login, privacy/consent,
  security, legal/compliance requirements, or another essential user journey.
- **High:** Issue creates serious risk to SEO, user trust, accessibility,
  privacy, analytics, content accuracy, performance, or conversion journeys, but
  may have a workaround.
- **Medium:** Issue creates migration risk, user friction, incomplete tracking,
  content uncertainty, redirect gaps, or maintenance risk but does not block key
  journeys.
- **Low:** Minor cleanup, polish, documentation, monitoring, or optional
  improvement.

## Recommendation rules

For each recommendation, explain:

- what the migration risk is,
- why it matters,
- who should fix it,
- who should approve it,
- whether it is beginner-friendly or technical,
- whether specialist review is needed,
- how to test it,
- whether it blocks launch.

Prefer specific, repeatable checks and practical fixes.

Do not promise traffic, ranking, conversion, revenue, lead, booking, donation, or
sales outcomes.

## Output format

Return:

```markdown
# Website Migration Review

## Verdict

PASS / PASS WITH RISKS / NEEDS FIXES / DO NOT LAUNCH

## Beginner-Friendly Summary

Summarise the biggest migration risk, why it matters, and the most useful next
action in plain English.

## Important Note

State that this is practical migration guidance, not a full SEO, legal,
security, accessibility, performance, or compliance audit.

## Assumptions and Missing Data

List assumptions made and information still needed.

## Migration Scope

State what is changing: redesign, CMS/platform, hosting, domain, URL structure,
content, integrations, analytics, forms, payments, or other transition areas.

## Business Goals and Priority Journeys

List the website goal and the pages or journeys that must be protected.

## Migration Ownership

| Role | Owner | Backup Owner | Notes |
| --- | --- | --- | --- |
| Business approver |  |  |  |
| Technical owner |  |  |  |
| Content owner |  |  |  |
| SEO/redirect owner |  |  |  |
| Analytics/tracking owner |  |  |  |
| Privacy/legal owner |  |  |  |
| Accessibility owner |  |  |  |
| Payment/booking owner |  |  |  |
| Launch coordinator |  |  |  |

## Migration Health Check

| Area | Status | Notes | Action Needed |
| --- | --- | --- | --- |
| Migration scope | PASS/REVIEW/FAIL/N/A |  |  |
| Current URL inventory | PASS/REVIEW/FAIL/N/A |  |  |
| Old-to-new URL mapping | PASS/REVIEW/FAIL/N/A |  |  |
| Redirect implementation | PASS/REVIEW/FAIL/N/A |  |  |
| High-value page protection | PASS/REVIEW/FAIL/N/A |  |  |
| SEO metadata/canonicals/robots/sitemap | PASS/REVIEW/FAIL/N/A |  |  |
| Content migration | PASS/REVIEW/FAIL/N/A |  |  |
| Navigation and internal links | PASS/REVIEW/FAIL/N/A |  |  |
| Forms/CRM/email routing | PASS/REVIEW/FAIL/N/A |  |  |
| Payments/bookings/donations/checkout | PASS/REVIEW/FAIL/N/A |  |  |
| Login/accounts/member areas | PASS/REVIEW/FAIL/N/A |  |  |
| Analytics/tracking/reporting | PASS/REVIEW/FAIL/N/A |  |  |
| Privacy/cookies/consent | PASS/REVIEW/FAIL/N/A |  |  |
| Accessibility regression | PASS/REVIEW/FAIL/N/A |  |  |
| Mobile/browser QA | PASS/REVIEW/FAIL/N/A |  |  |
| Performance regression | PASS/REVIEW/FAIL/N/A |  |  |
| Security/trust basics | PASS/REVIEW/FAIL/N/A |  |  |
| DNS/domain/hosting/CDN | PASS/REVIEW/FAIL/N/A |  |  |
| Backup/rollback readiness | PASS/REVIEW/FAIL/N/A |  |  |
| Post-launch monitoring | PASS/REVIEW/FAIL/N/A |  |  |

## Findings

| Severity | Area | Migration Risk | Why It Matters | Recommended Fix | Blocks Launch? | Owner |
| --- | --- | --- | --- | --- | --- | --- |
| Blocker |  |  |  |  | Yes/No |  |
| High |  |  |  |  | Yes/No |  |
| Medium |  |  |  |  | Yes/No |  |
| Low |  |  |  |  | Yes/No |  |

## URL Inventory and Redirect Review

Summarise old URL coverage, new URL coverage, high-value pages, redirect gaps,
redirect chains, redirect loops, 404 risks, PDF/download handling, and URLs that
need owner decisions.

## Redirect Mapping Table

| Old URL | New URL | Page Type | Priority | Redirect Status | Notes |
| --- | --- | --- | --- | --- | --- |
|  |  | Homepage/service/product/blog/policy/download/other | High/Medium/Low | Done/Missing/Review/N/A |  |

## SEO Preservation Review

Review titles, descriptions, headings, canonicals, indexability, robots, sitemap,
structured data, internal links, duplicate content, staging indexing, production
indexing, and search console ownership.

## Content Migration Review

Review missing, outdated, duplicated, unapproved, inaccurate, inaccessible, or
unsupported content. Include pages, images, videos, PDFs, downloads, testimonials,
awards, policy pages, legal wording, prices, dates, locations, and contact
details.

## Navigation and Internal Link Review

Review header, footer, mobile menu, breadcrumbs, buttons, internal links,
external links, anchor links, social links, email links, phone links, downloads,
pagination, category links, and broken-link risks.

## Forms, CRM, Email, and Lead Routing Review

Review forms, validation, success/error messages, spam protection, privacy
wording, consent, notifications, autoresponders, CRM entries, routing rules,
mobile usability, accessibility, and data minimisation.

## Payments, Bookings, Donations, Checkout, and Subscriptions

Use this section where relevant. Review selection, pricing, taxes, fees,
availability, payment, confirmation, receipts, refunds, cancellation wording,
failed states, admin records, test/sandbox evidence, privacy, and security review
needs.

## Accounts, Memberships, Portals, and User Data

Use this section where relevant. Review login, registration, password reset,
roles, permissions, account data migration, member-only content, order/booking
history, subscriptions, inactive accounts, privacy, and support process.

## Analytics, Tracking, and Reporting Continuity

Review analytics property, tag manager, events, conversions, campaign tracking,
dashboards, consent behaviour, duplicate tags, staging vs production IDs, and
personal data risks.

## Privacy, Cookies, and Consent Continuity

Review privacy notice, cookie notice, consent banner/tool, reject/manage options,
script behaviour, marketing opt-ins, third-party tools, form privacy wording,
data minimisation, and legal review needs.

## Accessibility Regression Review

Review keyboard access, focus indicators, headings, page titles, links, buttons,
forms, errors, alt text, captions/transcripts, contrast, menus, modals, cookie
banner, mobile accessibility, and specialist review needs.

## Mobile, Browser, and Performance Regression Review

Review responsive layout, mobile menus, touch targets, browser issues, older
device risks, slow pages, large images, autoplay video, heavy scripts, layout
shifts, caching, forms, checkout, and third-party widgets.

## Security, Trust, and Infrastructure Review

Review HTTPS, certificates, mixed content, secure forms, secure payments,
staging/admin exposure, test content, file uploads, sensitive data exposure,
domain, DNS, hosting, CDN, billing, renewals, support contacts, and rollback.

## QA and Acceptance Criteria

List practical pass/fail criteria for launch.

## Launch Plan

| Step | Owner | Timing | Verification | Rollback or Mitigation |
| --- | --- | --- | --- | --- |
| Final backup |  |  |  |  |
| Deploy new site |  |  |  |  |
| Apply redirects |  |  |  |  |
| DNS/domain/hosting change |  |  |  |  |
| Check forms/payments |  |  |  |  |
| Check analytics/consent |  |  |  |  |
| Submit/check sitemap |  |  |  |  |

## Rollback and Mitigation Plan

State what can be rolled back, what cannot be easily rolled back, who can decide,
who can execute, and what temporary mitigations are available.

## Post-Launch Monitoring Plan

| Timeframe | Checks | Owner | Escalation |
| --- | --- | --- | --- |
| First hour |  |  |  |
| First day |  |  |  |
| First week |  |  |  |
| First month |  |  |  |

## Known Risks and Accepted Exceptions

List issues that will not be fixed before launch, who accepted the risk, the
mitigation, and the review date.

## What Not To Do

List risky migration practices, such as launching without redirects, redirecting
all old URLs to the homepage, deleting high-value content without review,
blocking production from indexing, exposing staging pages, changing DNS without
rollback, breaking forms or payments, ignoring mobile, removing accessibility
features, bypassing consent checks, or shutting down old hosting too early.

## Priority Actions

1.
2.
3.

## 30-Day Migration Stabilisation Plan

| Priority | Action | Owner | Due Date | How To Verify |
| --- | --- | --- | --- | --- |
| Blocker |  |  |  |  |
| High |  |  |  |  |
| Medium |  |  |  |  |
| Low |  |  |  |  |

## Escalation Needed

List anything needing a developer, SEO specialist, content owner, analytics
specialist, privacy/legal reviewer, accessibility reviewer, security reviewer,
payment provider, hosting provider, DNS/domain owner, platform support,
agency/vendor, or business owner decision.

## Open Questions
```

## Output style rules

Use beginner-friendly language.

Explain migration, redirects, URL mapping, canonicals, robots, sitemap,
analytics continuity, consent, DNS, rollback, and monitoring terms in plain
English.

Keep recommendations realistic for a small team, beginner, or non-technical
owner.

Clearly separate launch blockers from lower-priority improvements.

Do not invent URL inventories, redirect status, traffic, rankings, backlinks,
conversions, analytics data, payment status, privacy status, security status,
accessibility status, SEO status, browser support, backup status, DNS status,
hosting status, or approval history.

Do not claim a migration is risk-free, SEO-safe, fully tested, secure,
compliant, accessible, or audit-ready without appropriate evidence and qualified
review.

Do not promise rankings, traffic, leads, revenue, sales, bookings, donations, or
conversion outcomes.

Do not recommend launching with blockers unless the business owner explicitly
accepts the risk and a mitigation plan exists.

Do not recommend risky live changes to DNS, hosting, payments, CMS, repositories,
access, tracking, consent tools, redirects, integrations, production data, or
user data without ownership confirmation, backups, testing, and rollback planning
where appropriate.

Do not use real sensitive personal data, real customer accounts, or live payment
details in testing unless explicitly authorised and handled safely.

If current SEO, analytics, privacy, cookie, consent, accessibility, security,
payment, browser, hosting, DNS, domain, platform, provider, legal, compliance, or
pricing details matter, tell the user what to verify from official sources or a
qualified reviewer.

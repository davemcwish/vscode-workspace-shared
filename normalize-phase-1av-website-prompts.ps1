$ErrorActionPreference = "Stop"

function Add-BlockIfMissing {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [string]$Needle,

    [Parameter(Mandatory = $true)]
    [string]$Block
  )

  if (-not (Test-Path $Path)) {
    throw "File not found: ${Path}"
  }

  $text = Get-Content -Path $Path -Raw

  if ($text -like "*$Needle*") {
    Write-Host "Already has ${Needle} in ${Path}"
    return
  }

  Add-Content -Path $Path -Value ""
  Add-Content -Path $Path -Value ($Block.Trim())

  Write-Host "Added ${Needle} to ${Path}"
}

$analyticsPath = "_copilot-shared/prompts/website-analytics-review.prompt.md"
$copyPath = "_copilot-shared/prompts/website-copy-review.prompt.md"
$ideaPath = "_copilot-shared/prompts/website-from-idea-to-launch.prompt.md"
$growthPath = "_copilot-shared/prompts/website-growth-plan.prompt.md"
$maintenancePath = "_copilot-shared/prompts/website-maintenance-plan.prompt.md"
$performancePath = "_copilot-shared/prompts/website-performance-review.prompt.md"

Add-BlockIfMissing -Path $analyticsPath -Needle "## Severity rules" -Block @'
## Severity rules

Use these severities for analytics risks:

- **Critical:** Issue could expose personal data, send sensitive data to an analytics or advertising platform, create serious privacy/compliance risk, break critical reporting for a major launch or business decision, or materially mislead leadership.
- **High:** Issue could significantly distort conversion, traffic, campaign, consent, or funnel reporting, or cause important website decisions to be made from unreliable data.
- **Medium:** Issue creates partial tracking gaps, inconsistent naming, weak documentation, unclear ownership, or moderate reporting risk.
- **Low:** Minor dashboard, naming, documentation, filtering, annotation, or reporting-quality improvement.
'@

Add-BlockIfMissing -Path $analyticsPath -Needle "## Recommendation rules" -Block @'
## Recommendation rules

For each analytics recommendation, explain:

- what measurement risk exists,
- why it matters,
- severity,
- affected page, event, funnel, audience, region, dashboard, tag, or platform,
- recommended owner,
- what to verify first,
- what action to take,
- how to test it,
- whether privacy, legal, consent, security, marketing, analytics, tag manager, vendor, or developer review is needed,
- whether it blocks launch.

Do not recommend risky live tag, consent, advertising, analytics, or data-layer changes without ownership confirmation, testing, approval, and rollback planning.
'@

Add-BlockIfMissing -Path $analyticsPath -Needle "## What Not To Do" -Block @'
## What Not To Do

- Do not claim analytics data is complete, compliant, accurate, or business-ready without evidence.
- Do not collect unnecessary personal data in analytics tools.
- Do not send sensitive form fields, account data, payment data, health data, government IDs, or confidential data into analytics or advertising tools.
- Do not bypass consent, privacy, security, or legal review where required.
- Do not treat dashboard numbers as final if tracking, filters, consent mode, bot filtering, attribution, or tag firing has not been verified.
- Do not make production tag changes without testing and rollback planning.
'@

Add-BlockIfMissing -Path $copyPath -Needle "## Escalation Needed" -Block @'
## Escalation Needed

Escalate when copy decisions involve legal claims, privacy wording, regulated products or services, medical, financial, employment, public-sector, safety, accessibility, localization, brand, trademark, pricing, contractual commitments, guarantees, testimonials, customer data, or other high-risk content.

For high-risk copy, recommend review by the appropriate business owner, legal reviewer, privacy reviewer, accessibility reviewer, localization owner, brand owner, product owner, or subject-matter expert.
'@

Add-BlockIfMissing -Path $ideaPath -Needle "Currentness warning" -Block @'
**Currentness warning:** Website platforms, hosting options, analytics tools, consent requirements, accessibility expectations, search behavior, browser behavior, payment tools, AI tools, security practices, vendor pricing, and legal or regulatory requirements change over time. Where current platform, legal, privacy, security, accessibility, procurement, payment, or compliance details matter, verify them from official vendor documentation, internal policies, qualified reviewers, or appropriate professional advisors.
'@

Add-BlockIfMissing -Path $ideaPath -Needle "## Output format" -Block @'
## Output format

Return:

# Website From Idea To Launch Plan

## Verdict

READY TO PLAN / NEEDS MORE CONTEXT / HIGH RISK / DO NOT START YET

## Beginner-Friendly Summary

Summarize the website idea, the biggest planning risk, and the next practical step in plain English.

## Important Note

State that this is practical website planning guidance, not legal, privacy, cybersecurity, accessibility, procurement, contract, financial, tax, payment, regulated-content, public-sector, or internal-audit advice.

## Assumptions and Missing Data

List assumptions made and information still needed.

## Website Goal

Describe the website purpose, audience, key user journeys, success measures, and launch target.

## Recommended Website Scope

List the recommended pages, features, integrations, content, forms, analytics, governance, and launch requirements.

## Launch Readiness Checklist

| Area | Status | Notes | Action Needed |
| --- | --- | --- | --- |
| Purpose and audience | PASS/REVIEW/FAIL/N/A |  |  |
| Content and pages | PASS/REVIEW/FAIL/N/A |  |  |
| Platform and hosting | PASS/REVIEW/FAIL/N/A |  |  |
| Forms and submissions | PASS/REVIEW/FAIL/N/A |  |  |
| Accessibility | PASS/REVIEW/FAIL/N/A |  |  |
| Privacy and consent | PASS/REVIEW/FAIL/N/A |  |  |
| Security basics | PASS/REVIEW/FAIL/N/A |  |  |
| SEO basics | PASS/REVIEW/FAIL/N/A |  |  |
| Analytics | PASS/REVIEW/FAIL/N/A |  |  |
| QA and launch testing | PASS/REVIEW/FAIL/N/A |  |  |
| Ownership and maintenance | PASS/REVIEW/FAIL/N/A |  |  |

## Findings

| Severity | Area | Risk | Why It Matters | Recommended Action | Owner |
| --- | --- | --- | --- | --- | --- |
| Critical |  |  |  |  |  |
| High |  |  |  |  |  |
| Medium |  |  |  |  |  |
| Low |  |  |  |  |  |

## Priority Actions

1.
2.
3.

## 30-Day Launch Planning Plan

| Priority | Action | Owner | Due Date | How To Verify |
| --- | --- | --- | --- | --- |
| Critical |  |  |  |  |
| High |  |  |  |  |
| Medium |  |  |  |  |
| Low |  |  |  |  |

## Escalation Needed

List anything needing a business owner, developer, designer, content owner, analytics owner, privacy/legal reviewer, security reviewer, accessibility reviewer, procurement/contracts owner, payment provider, vendor, or leadership decision-maker.

## Open Questions
'@

Add-BlockIfMissing -Path $ideaPath -Needle "## Severity rules" -Block @'
## Severity rules

Use these severities for launch planning risks:

- **Critical:** Issue could block launch, expose private or protected data, create serious legal, privacy, security, accessibility, payment, public-sector, regulated-content, or user-harm risk, or prevent the site from serving its core purpose.
- **High:** Issue could significantly delay launch, damage trust, harm conversion, create major rework, confuse ownership, or undermine a core user journey.
- **Medium:** Issue creates moderate planning, content, design, ownership, QA, analytics, SEO, vendor, localization, or maintenance risk.
- **Low:** Minor improvement, clarification, documentation, formatting, wording, or future enhancement.
'@

Add-BlockIfMissing -Path $ideaPath -Needle "## Recommendation rules" -Block @'
## Recommendation rules

For each recommendation, explain:

- what planning risk exists,
- why it matters,
- severity,
- affected page, feature, journey, audience, owner, vendor, system, or launch milestone,
- recommended owner,
- what to verify first,
- what action to take,
- how to test or confirm it,
- whether legal, privacy, security, accessibility, content, analytics, procurement, contract, payment, localization, or technical review is needed,
- whether it blocks launch.

Prefer practical next steps that a small team can complete.
'@

Add-BlockIfMissing -Path $ideaPath -Needle "Do not invent" -Block @'
## What Not To Do

- Do not invent business goals, audiences, budgets, owners, deadlines, vendors, approvals, legal requirements, content, integrations, analytics data, or compliance status.
- Do not claim the website will be secure, accessible, compliant, profitable, search-ranked, conversion-ready, or risk-free without evidence and appropriate qualified review.
- Do not recommend launching high-risk features without ownership, testing, approval, and rollback planning.
- Do not request or expose passwords, API keys, tokens, customer personal data, payment details, or confidential business information.
- Do not treat this planning prompt as legal, privacy, security, accessibility, procurement, contract, financial, tax, payment, or compliance advice.
'@

Add-BlockIfMissing -Path $ideaPath -Needle "## Escalation Needed" -Block @'
## Escalation Needed

Escalate when the website plan involves legal claims, privacy or consent, user accounts, payments, forms collecting personal or sensitive data, file uploads, regulated products or services, accessibility risk, security risk, public-sector requirements, procurement or contracts, third-party vendors, customer data, localization, complex integrations, or leadership tradeoffs.

Recommend review by the appropriate business owner, technical owner, legal reviewer, privacy reviewer, security reviewer, accessibility reviewer, content owner, analytics owner, procurement/contracts owner, vendor owner, or leadership decision-maker.
'@

Add-BlockIfMissing -Path $growthPath -Needle "## Severity rules" -Block @'
## Severity rules

Use these severities for growth planning risks:

- **Critical:** Issue could create serious privacy, consent, security, accessibility, legal, brand, user-harm, advertising, or data misuse risk, or cause the team to scale a broken or misleading funnel.
- **High:** Issue could significantly reduce qualified leads, revenue, trust, retention, conversion, discoverability, or campaign effectiveness.
- **Medium:** Issue creates moderate funnel, content, SEO, analytics, testing, ownership, localization, or prioritization risk.
- **Low:** Minor copy, layout, dashboard, documentation, cadence, experiment, or optimization improvement.
'@

Add-BlockIfMissing -Path $growthPath -Needle "## Recommendation rules" -Block @'
## Recommendation rules

For each growth recommendation, explain:

- what growth opportunity or risk exists,
- why it matters,
- severity,
- affected audience, page, funnel, channel, campaign, form, CTA, region, or metric,
- recommended owner,
- what to verify first,
- what action to take,
- how to measure it,
- whether privacy, legal, consent, analytics, accessibility, brand, SEO, paid media, vendor, or technical review is needed,
- whether it should be tested before scaling.

Do not recommend growth tactics that rely on misleading claims, dark patterns, unnecessary personal data collection, weak consent, inaccessible experiences, or unverified analytics.
'@

Add-BlockIfMissing -Path $growthPath -Needle "## Escalation Needed" -Block @'
## Escalation Needed

Escalate when growth work involves legal claims, privacy or consent, paid advertising, tracking pixels, personal data, sensitive audiences, regulated products or services, pricing, testimonials, accessibility, localization, security, third-party vendors, CRM changes, email/SMS marketing, or leadership-level tradeoffs.

Recommend review by the appropriate business owner, marketing owner, analytics owner, legal reviewer, privacy reviewer, accessibility reviewer, security reviewer, brand owner, CRM owner, vendor owner, or leadership decision-maker.
'@

Add-BlockIfMissing -Path $maintenancePath -Needle "## Severity rules" -Block @'
## Severity rules

Use these severities for maintenance risks:

- **Critical:** Issue could cause outage, data loss, private data exposure, serious security/privacy/accessibility/legal risk, broken critical journeys, failed backups, or inability to recover the site.
- **High:** Issue could significantly reduce reliability, performance, trust, maintainability, search visibility, conversion, support access, or operational ownership.
- **Medium:** Issue creates moderate update, documentation, QA, monitoring, ownership, vendor, content, analytics, or support risk.
- **Low:** Minor cleanup, scheduling, documentation, naming, dashboard, review cadence, or non-critical improvement.
'@

Add-BlockIfMissing -Path $maintenancePath -Needle "## Recommendation rules" -Block @'
## Recommendation rules

For each maintenance recommendation, explain:

- what maintenance risk exists,
- why it matters,
- severity,
- affected page, plugin, platform, vendor, integration, content area, data flow, owner, or user journey,
- recommended owner,
- what to verify first,
- what action to take,
- how to test it,
- what rollback or recovery step is needed,
- whether security, privacy, accessibility, legal, vendor, hosting, analytics, content, or technical review is needed,
- whether it blocks release or should be scheduled.

Prefer practical maintenance actions that reduce recurring risk.
'@

Add-BlockIfMissing -Path $maintenancePath -Needle "Do not invent" -Block @'
## What Not To Do

- Do not invent owners, vendors, versions, backups, approvals, incidents, monitoring, test results, security status, privacy status, accessibility status, or compliance status.
- Do not make risky production changes without ownership, testing, approval, backups, and rollback planning.
- Do not ignore failed backups, broken forms, security updates, expired domains, expired certificates, inaccessible critical journeys, or unresolved monitoring alerts.
- Do not request or expose passwords, API keys, tokens, customer personal data, payment details, or confidential business information.
- Do not claim the site is secure, private, accessible, compliant, fully maintained, or risk-free without evidence and appropriate qualified review.
'@

Add-BlockIfMissing -Path $performancePath -Needle "## Severity rules" -Block @'
## Severity rules

Use these severities for performance risks:

- **Critical:** Issue blocks critical pages or user journeys, causes severe load failure, prevents checkout or lead capture, creates major accessibility/usability impact, or breaks launch readiness.
- **High:** Issue significantly slows key pages, harms conversion, search visibility, user trust, mobile usability, or core business journeys.
- **Medium:** Issue creates moderate page speed, asset, script, hosting, image, caching, rendering, or monitoring risk.
- **Low:** Minor optimization, cleanup, documentation, dashboard, measurement, or non-critical improvement.
'@

Add-BlockIfMissing -Path $performancePath -Needle "## Recommendation rules" -Block @'
## Recommendation rules

For each performance recommendation, explain:

- what performance risk exists,
- why it matters,
- severity,
- affected page, template, asset, script, vendor, device, browser, region, or user journey,
- recommended owner,
- what to verify first,
- what action to take,
- how to test before and after,
- whether developer, hosting, vendor, analytics, accessibility, SEO, design, or content review is needed,
- whether it blocks launch.

Prefer practical fixes such as image compression, script reduction, caching review, font cleanup, third-party tag review, lazy loading, template optimization, monitoring, and performance budgets.
'@

Add-BlockIfMissing -Path $performancePath -Needle "## Escalation Needed" -Block @'
## Escalation Needed

Escalate when performance issues affect critical journeys, checkout, forms, login, search visibility, paid campaigns, accessibility, mobile users, major launches, hosting limits, third-party vendors, complex JavaScript, CDN behavior, backend APIs, or platform architecture.

Recommend review by the appropriate developer, platform owner, hosting provider, vendor owner, analytics owner, accessibility reviewer, SEO owner, design owner, content owner, or leadership decision-maker.
'@

Write-Host ""
Write-Host "Phase 1AV website prompt normalization complete."

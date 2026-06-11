$ErrorActionPreference = "Stop"

$root = "_copilot-shared"

$manifestPath = Join-Path -Path $root -ChildPath "WEBSITE-ARTIFACT-MANIFEST.md"
$startHerePath = Join-Path -Path $root -ChildPath "START-HERE-WEBSITE.md"
$summaryPath = Join-Path -Path $root -ChildPath "summary.md"

function Set-MarkedSection {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [string]$StartMarker,

    [Parameter(Mandatory = $true)]
    [string]$EndMarker,

    [Parameter(Mandatory = $true)]
    [string]$Body
  )

  if (-not (Test-Path $Path)) {
    throw "File not found: $Path"
  }

  $text = Get-Content -Path $Path -Raw
  $section = "$StartMarker`r`n$Body`r`n$EndMarker"

  $startIndex = $text.IndexOf($StartMarker)
  $endIndex = $text.IndexOf($EndMarker)

  if ($startIndex -ge 0 -and $endIndex -ge 0 -and $endIndex -gt $startIndex) {
    $afterEndIndex = $endIndex + $EndMarker.Length
    $before = $text.Substring(0, $startIndex).TrimEnd()
    $after = $text.Substring($afterEndIndex).TrimStart()
    $newText = "$before`r`n`r`n$section`r`n`r`n$after"
  } else {
    $newText = "$($text.TrimEnd())`r`n`r`n$section`r`n"
  }

  Set-Content -Path $Path -Value $newText -NoNewline
}

$manifestBody = @'
## Website Prompt Coverage Index

The website prompt library includes review, planning, governance, operations, privacy/security, accessibility, growth, and resilience prompts for small-team website management.

### Core Website Planning and Review

- `prompts/website-from-idea-to-launch.prompt.md` - Guides a website from initial idea through practical launch planning.
- `prompts/monthly-website-review.prompt.md` - Supports recurring monthly website health review.
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
- `prompts/conversion-review.prompt.md` - Reviews conversion paths, calls to action, lead capture, and user journey friction.
- `prompts/website-experimentation-review.prompt.md` - Reviews A/B tests, feature flags, personalization tests, experiment governance, analytics, consent, accessibility, QA, and rollback.
- `prompts/online-presence-review.prompt.md` - Reviews broader online presence, channels, listings, reputation, and discoverability.
- `prompts/seo-review.prompt.md` - Reviews core SEO readiness.
- `prompts/local-seo-check.prompt.md` - Reviews local SEO visibility, listings, local search signals, and location-related issues.

### Accessibility, Localization, Performance, and Sustainability

- `prompts/website-accessibility-remediation-review.prompt.md` - Reviews accessibility issue triage, remediation ownership, backlog prioritization, acceptance criteria, validation, regression testing, and accessibility debt.
- `prompts/website-localization-review.prompt.md` - Reviews localization, translation, regional content, language behavior, and local user experience.
- `prompts/website-performance-review.prompt.md` - Reviews performance, page speed, Core Web Vitals-style concerns, mobile performance, and practical optimization.
- `prompts/digital-sustainability-review.prompt.md` - Reviews digital sustainability, page weight, hosting impact, content efficiency, and operational sustainability.

### Privacy, Security, Consent, Accounts, and Access

- `prompts/security-privacy-review.prompt.md` - Reviews practical website security and privacy readiness.
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
'@

$startHereBody = @'
## Website Prompt Coverage Index

Use these prompts based on the kind of website work you are doing.

### Start, Plan, Maintain, and Govern

- `prompts/website-from-idea-to-launch.prompt.md`
- `prompts/monthly-website-review.prompt.md`
- `prompts/website-maintenance-plan.prompt.md`
- `prompts/website-governance-review.prompt.md`
- `prompts/website-documentation-review.prompt.md`
- `prompts/website-change-management-review.prompt.md`
- `prompts/website-qa-review.prompt.md`

### Content, Copy, Search, Growth, and Experimentation

- `prompts/website-copy-review.prompt.md`
- `prompts/website-content-governance-review.prompt.md`
- `prompts/website-search-review.prompt.md`
- `prompts/website-growth-plan.prompt.md`
- `prompts/conversion-review.prompt.md`
- `prompts/website-experimentation-review.prompt.md`
- `prompts/online-presence-review.prompt.md`
- `prompts/seo-review.prompt.md`
- `prompts/local-seo-check.prompt.md`

### Accessibility, Localization, Performance, and Sustainability

- `prompts/website-accessibility-remediation-review.prompt.md`
- `prompts/website-localization-review.prompt.md`
- `prompts/website-performance-review.prompt.md`
- `prompts/digital-sustainability-review.prompt.md`

### Privacy, Security, Consent, Accounts, and Access

- `prompts/security-privacy-review.prompt.md`
- `prompts/website-access-permissions-review.prompt.md`
- `prompts/website-data-retention-review.prompt.md`
- `prompts/website-cookie-consent-review.prompt.md`
- `prompts/website-account-login-review.prompt.md`

### Analytics, Monitoring, Incidents, Resilience, and Operations

- `prompts/website-analytics-review.prompt.md`
- `prompts/website-monitoring-review.prompt.md`
- `prompts/website-incident-response-review.prompt.md`
- `prompts/website-business-continuity-review.prompt.md`
- `prompts/website-backup-restore-review.prompt.md`
- `prompts/website-migration-review.prompt.md`

### Vendors, Tools, AI, Costs, and Third Parties

- `prompts/website-ai-chatbot-review.prompt.md`
- `prompts/website-third-party-tools-review.prompt.md`
- `prompts/website-vendor-management-review.prompt.md`
- `prompts/website-cost-ownership-review.prompt.md`

### Notes

- `website-monitoring-review.prompt.md`, `website-incident-response-review.prompt.md`, `website-business-continuity-review.prompt.md`, and `website-backup-restore-review.prompt.md` are complementary, not duplicates.
- `security-privacy-review.prompt.md`, `website-access-permissions-review.prompt.md`, `website-data-retention-review.prompt.md`, `website-cookie-consent-review.prompt.md`, and `website-account-login-review.prompt.md` cover different parts of the privacy/security/access lifecycle.
- `website-ai-chatbot-review.prompt.md`, `website-search-review.prompt.md`, `website-third-party-tools-review.prompt.md`, and `website-vendor-management-review.prompt.md` overlap intentionally around tools, vendors, data, and user experience.
'@

$summaryBody = @'
## Website Prompt Coverage Summary

The website prompt set now includes dedicated coverage for:

- idea-to-launch planning,
- monthly review and maintenance,
- website governance and documentation,
- QA and change management,
- content governance and copy review,
- search, SEO, local SEO, online presence, conversion, growth, and experimentation,
- accessibility remediation,
- localization,
- performance and digital sustainability,
- analytics,
- privacy, security, access permissions, data retention, cookie consent, and account/login journeys,
- monitoring, incident response, business continuity, backup/restore, and migration,
- AI chatbots and automated assistants,
- third-party tools, vendor management, and cost ownership.

Recent Phase 1AO-1AS additions added or confirmed dedicated prompts for:

- `prompts/website-experimentation-review.prompt.md`
- `prompts/website-accessibility-remediation-review.prompt.md`
- `prompts/website-cookie-consent-review.prompt.md`
- `prompts/website-ai-chatbot-review.prompt.md`
- `prompts/website-account-login-review.prompt.md`

These prompts complement the existing website monitoring, incident response, business continuity, backup/restore, change management, vendor management, privacy/security, analytics, localization, search, QA, and governance prompts.
'@

Set-MarkedSection `
  -Path $manifestPath `
  -StartMarker "<!-- WEBSITE-PROMPT-COVERAGE-INDEX:START -->" `
  -EndMarker "<!-- WEBSITE-PROMPT-COVERAGE-INDEX:END -->" `
  -Body $manifestBody

Set-MarkedSection `
  -Path $startHerePath `
  -StartMarker "<!-- WEBSITE-PROMPT-COVERAGE-INDEX:START -->" `
  -EndMarker "<!-- WEBSITE-PROMPT-COVERAGE-INDEX:END -->" `
  -Body $startHereBody

Set-MarkedSection `
  -Path $summaryPath `
  -StartMarker "<!-- WEBSITE-PROMPT-COVERAGE-INDEX:START -->" `
  -EndMarker "<!-- WEBSITE-PROMPT-COVERAGE-INDEX:END -->" `
  -Body $summaryBody

Write-Host "Updated website prompt coverage sections in:"
Write-Host "- $manifestPath"
Write-Host "- $startHerePath"
Write-Host "- $summaryPath"

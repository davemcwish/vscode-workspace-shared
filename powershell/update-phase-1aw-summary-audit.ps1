$ErrorActionPreference = "Stop"

$summaryPath = "_copilot-shared/summary.md"
$auditPath = "website-artifact-audit.ps1"

if (-not (Test-Path $summaryPath)) {
  throw "File not found: $summaryPath"
}

$websitePromptSection = @'

## Website prompt suite

The website prompt suite provides reusable review, planning, governance, operational, and risk-assessment prompts for website work. These prompts support practical website delivery while reminding users to verify current legal, privacy, accessibility, security, vendor, analytics, and platform requirements with appropriate qualified reviewers or official sources.

### Planning, launch, and lifecycle

- `prompts/website-from-idea-to-launch.prompt.md` - Plans a website from idea through launch readiness, including goals, scope, pages, content, platform, forms, privacy, accessibility, analytics, QA, ownership, and launch risks.
- `prompts/website-maintenance-plan.prompt.md` - Plans ongoing website maintenance, updates, ownership, QA, monitoring, documentation, backups, and recurring operational health.
- `prompts/website-growth-plan.prompt.md` - Reviews website growth opportunities across audience, messaging, channels, funnels, conversion, experimentation, SEO, analytics, and prioritization.
- `prompts/website-migration-review.prompt.md` - Reviews website migration planning, redirects, SEO preservation, content, analytics, QA, rollback, platform risks, and launch readiness.

### Discovery, SEO, content, conversion, and experience

- `prompts/seo-review.prompt.md` - Reviews technical SEO, on-page SEO, indexability, metadata, content quality, crawlability, and search visibility risks.
- `prompts/local-seo-check.prompt.md` - Reviews local SEO signals, local listings, service areas, location pages, reviews, local schema, and local search visibility.
- `prompts/online-presence-review.prompt.md` - Reviews broader online presence across listings, profiles, reputation, consistency, channels, trust signals, and discoverability.
- `prompts/website-search-review.prompt.md` - Reviews website search, internal search UX, search results quality, filters, indexing, no-results handling, accessibility, analytics, and AI-assisted search risks.
- `prompts/website-copy-review.prompt.md` - Reviews website copy for clarity, trust, claims, audience fit, conversion, accessibility, localization, brand, and risk.
- `prompts/conversion-review.prompt.md` - Reviews conversion paths, calls to action, landing pages, forms, trust signals, analytics, and funnel friction.
- `prompts/website-experimentation-review.prompt.md` - Reviews website experiments, A/B tests, measurement plans, consent, fairness, analytics, guardrails, rollout, and decision quality.

### Analytics, performance, QA, and functionality

- `prompts/website-analytics-review.prompt.md` - Reviews analytics setup, events, funnels, dashboards, consent, data quality, attribution, reporting, ownership, and measurement risks.
- `prompts/website-performance-review.prompt.md` - Reviews page speed, assets, scripts, third-party tags, caching, mobile performance, monitoring, Core Web Vitals-style risks, and performance ownership.
- `prompts/website-qa-review.prompt.md` - Reviews website QA coverage, test plans, launch checks, regression risks, browser/device checks, forms, analytics, accessibility, and acceptance criteria.
- `prompts/website-forms-submissions-review.prompt.md` - Reviews website forms, submissions, contact forms, lead capture, newsletter signup, support requests, file uploads, validation, confirmations, notifications, CRM handoff, spam prevention, privacy, accessibility, localization, analytics, ownership, testing, and failure handling.
- `prompts/website-account-login-review.prompt.md` - Reviews account, login, registration, password reset, MFA, sessions, access, privacy, security, accessibility, support, monitoring, and recovery flows.
- `prompts/website-ai-chatbot-review.prompt.md` - Reviews website AI chatbot behavior, scope, privacy, safety, handoff, accessibility, analytics, hallucination risk, escalation, governance, and monitoring.

### Accessibility, localization, privacy, security, and user trust

- `prompts/security-privacy-review.prompt.md` - Reviews security and privacy risks, data handling, access, consent, secrets, third-party services, and practical remediation needs.
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

'@

function Add-SectionIfMissing {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [string]$Heading,

    [Parameter(Mandatory = $true)]
    [string]$Section
  )

  $text = Get-Content -Path $Path -Raw

  if ($text -like "*$Heading*") {
    Write-Host "Already has section: $Heading"
    return
  }

  Add-Content -Path $Path -Value ""
  Add-Content -Path $Path -Value ($Section.Trim())
  Write-Host "Added section: $Heading"
}

Add-SectionIfMissing `
  -Path $summaryPath `
  -Heading "## Website prompt suite" `
  -Section $websitePromptSection

if (Test-Path $auditPath) {
  $auditText = Get-Content -Path $auditPath -Raw
  $updatedAuditText = $auditText

  $updatedAuditText = $updatedAuditText -replace "Today's Phase 1AO-1AS prompt check", "Recent Phase 1AO-1AV website prompt check"
  $updatedAuditText = $updatedAuditText -replace "Phase 1AO-1AS prompt check", "Recent Phase 1AO-1AV website prompt check"

  if ($updatedAuditText -ne $auditText) {
    Set-Content -Path $auditPath -Value $updatedAuditText -NoNewline
    Write-Host "Updated audit script phase heading."
  } else {
    Write-Host "No stale Phase 1AO-1AS audit heading found, or audit heading already updated."
  }

  $auditTextAfterHeading = Get-Content -Path $auditPath -Raw
  if ($auditTextAfterHeading -notlike "*website-forms-submissions-review.prompt.md*") {
    Write-Host "NOTE: website-forms-submissions-review.prompt.md is not referenced in website-artifact-audit.ps1."
    Write-Host "If the recent phase check uses a hardcoded prompt list, add it manually."
  } else {
    Write-Host "Audit script already references website-forms-submissions-review.prompt.md."
  }
} else {
  Write-Host "Audit script not found at $auditPath; skipped audit heading update."
}

Write-Host ""
Write-Host "Phase 1AW summary/audit alignment update complete."

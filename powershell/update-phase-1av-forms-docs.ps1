$ErrorActionPreference = "Stop"

$manifestPath = "_copilot-shared/WEBSITE-ARTIFACT-MANIFEST.md"
$startHerePath = "_copilot-shared/START-HERE-WEBSITE.md"
$summaryPath = "_copilot-shared/summary.md"

function Add-LineAfterPatternIfMissing {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [string]$AnchorPattern,

    [Parameter(Mandatory = $true)]
    [string]$LineToAdd
  )

  if (-not (Test-Path $Path)) {
    throw "File not found: ${Path}"
  }

  $lines = Get-Content -Path $Path

  if ($lines -contains $LineToAdd) {
    Write-Host "Already present in ${Path}:"
    Write-Host "  $LineToAdd"
    return
  }

  $anchorIndex = -1

  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -like $AnchorPattern) {
      $anchorIndex = $i
      break
    }
  }

  if ($anchorIndex -lt 0) {
    throw "Anchor pattern not found in ${Path}: ${AnchorPattern}"
  }

  $before = @()
  $after = @()

  if ($anchorIndex -ge 0) {
    $before = $lines[0..$anchorIndex]
  }

  if ($anchorIndex + 1 -lt $lines.Count) {
    $after = $lines[($anchorIndex + 1)..($lines.Count - 1)]
  }

  $updated = @()
  $updated += $before
  $updated += $LineToAdd
  $updated += $after

  Set-Content -Path $Path -Value $updated

  Write-Host "Added to ${Path}:"
  Write-Host "  $LineToAdd"
}

function Replace-LineMatchingPattern {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [string]$MatchPattern,

    [Parameter(Mandatory = $true)]
    [string]$NewLine
  )

  if (-not (Test-Path $Path)) {
    throw "File not found: ${Path}"
  }

  $lines = Get-Content -Path $Path
  $changed = $false

  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -eq $NewLine) {
      Write-Host "Already updated in ${Path}:"
      Write-Host "  $NewLine"
      return
    }

    if ($lines[$i] -like $MatchPattern) {
      $lines[$i] = $NewLine
      $changed = $true
      break
    }
  }

  if (-not $changed) {
    Write-Warning "No matching line found in ${Path}: ${MatchPattern}"
    return
  }

  Set-Content -Path $Path -Value $lines

  Write-Host "Updated line in ${Path}:"
  Write-Host "  $NewLine"
}

$manifestFormsLine = '- `prompts/website-forms-submissions-review.prompt.md` - Reviews website forms, submissions, contact forms, lead capture, newsletter signup, support requests, file uploads, validation, confirmations, notifications, CRM handoff, spam prevention, privacy, accessibility, localization, analytics, ownership, testing, and failure handling.'

$startHereFormsLine = '- `prompts/website-forms-submissions-review.prompt.md`'

$summaryFormsLine = '- `prompts/website-forms-submissions-review.prompt.md`'

$summaryNewBullet = '- search, SEO, local SEO, online presence, forms and submissions, conversion, growth, and experimentation,'

$summaryNewHeading = 'Recent Phase 1AO-1AU additions added or confirmed dedicated prompts for:'

Add-LineAfterPatternIfMissing `
  -Path $manifestPath `
  -AnchorPattern '*prompts/conversion-review.prompt.md*' `
  -LineToAdd $manifestFormsLine

Add-LineAfterPatternIfMissing `
  -Path $startHerePath `
  -AnchorPattern '*prompts/conversion-review.prompt.md*' `
  -LineToAdd $startHereFormsLine

Replace-LineMatchingPattern `
  -Path $summaryPath `
  -MatchPattern '*search, SEO, local SEO, online presence, conversion, growth, and experimentation,*' `
  -NewLine $summaryNewBullet

Replace-LineMatchingPattern `
  -Path $summaryPath `
  -MatchPattern '*Recent Phase 1AO*additions added or confirmed dedicated prompts for:*' `
  -NewLine $summaryNewHeading

Add-LineAfterPatternIfMissing `
  -Path $summaryPath `
  -AnchorPattern '*prompts/website-account-login-review.prompt.md*' `
  -LineToAdd $summaryFormsLine

Write-Host ""
Write-Host "Phase 1AV forms documentation update complete."

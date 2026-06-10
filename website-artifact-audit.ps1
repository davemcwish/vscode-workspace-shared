$ErrorActionPreference = "Stop"

$root = "_copilot-shared"
$promptDir = Join-Path -Path $root -ChildPath "prompts"

$manifestPath = Join-Path -Path $root -ChildPath "WEBSITE-ARTIFACT-MANIFEST.md"
$startHerePath = Join-Path -Path $root -ChildPath "START-HERE-WEBSITE.md"
$summaryPath = Join-Path -Path $root -ChildPath "summary.md"

$docs = @(
  $manifestPath
  $startHerePath
  $summaryPath
)

Write-Host ""
Write-Host "=== Website Artifact Audit ==="
Write-Host ""

Write-Host "Root:      $root"
Write-Host "Prompts:   $promptDir"
Write-Host "Manifest:  $manifestPath"
Write-Host "StartHere: $startHerePath"
Write-Host "Summary:   $summaryPath"
Write-Host ""

if (-not (Test-Path $root)) {
  throw "Root folder not found: $root"
}

if (-not (Test-Path $promptDir)) {
  throw "Prompt folder not found: $promptDir"
}

foreach ($doc in $docs) {
  if (-not (Test-Path $doc)) {
    Write-Warning "Documentation file not found: $doc"
  }
}

$docText = @{}

foreach ($doc in $docs) {
  if (Test-Path $doc) {
    $docText[$doc] = Get-Content -Path $doc -Raw
  } else {
    $docText[$doc] = ""
  }
}


$prompts = Get-ChildItem -Path $promptDir -Filter "*.prompt.md" | Sort-Object Name

$report = foreach ($p in $prompts) {
  [PSCustomObject]@{
    Prompt = $p.Name
    LastWriteTime = $p.LastWriteTime
    SizeKB = [math]::Round($p.Length / 1KB, 1)
    InManifest = $docText[$manifestPath] -like "*$($p.Name)*"
    InStartHere = $docText[$startHerePath] -like "*$($p.Name)*"
    InSummary = $docText[$summaryPath] -like "*$($p.Name)*"
    WebsiteRequired = $p.Name -like "website-*"
  }
}

Write-Host ""
Write-Host "=== All prompt documentation coverage ==="
Write-Host ""

$report | Format-Table -AutoSize

Write-Host ""
Write-Host "=== Missing from at least one documentation file ==="
Write-Host ""

$missing = $report | Where-Object {
  $_.WebsiteRequired -and (
    -not $_.InManifest -or -not $_.InStartHere -or -not $_.InSummary
  )
}

if ($missing) {
  $missing | Format-Table -AutoSize
} else {
  Write-Host "No missing website-required prompt references found across manifest, START-HERE, and summary."
}

Write-Host ""
Write-Host "=== Recent Phase 1AO-1AV website prompt check ==="
Write-Host ""

$todayPrompts = @(
  "website-experimentation-review.prompt.md",
  "website-accessibility-remediation-review.prompt.md",
  "website-cookie-consent-review.prompt.md",
  "website-ai-chatbot-review.prompt.md",
  "website-account-login-review.prompt.md",
  "website-forms-submissions-review.prompt.md"
)

foreach ($name in $todayPrompts) {
  Write-Host ""
  Write-Host "--- $name ---"

  $promptPath = Join-Path -Path $promptDir -ChildPath $name

  if (Test-Path $promptPath) {
    Get-ChildItem -Path $promptPath |
      Select-Object Name, LastWriteTime, Length |
      Format-Table -AutoSize
  } else {
    Write-Warning "Prompt file not found: $promptPath"
  }

  $todayDocCheck = foreach ($doc in $docs) {
    [PSCustomObject]@{
      Document = $doc
      ContainsPrompt = $docText[$doc] -like "*$name*"
    }
  }

  $todayDocCheck | Format-Table -AutoSize
}

Write-Host ""
Write-Host "=== Related operational / governance prompt overlap check ==="
Write-Host ""

Get-ChildItem -Path $promptDir -Filter "*.prompt.md" |
  Sort-Object Name |
  Where-Object {
    $_.Name -match "monitor|incident|continuity|backup|change|governance|vendor|third-party|privacy|security|access|account|consent|cookie|ai|chatbot|accessibility|experiment"
  } |
  Select-Object Name, LastWriteTime, Length |
  Format-Table -AutoSize

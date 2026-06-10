$auditPath = ".\website-artifact-audit.ps1"

$text = Get-Content -Path $auditPath -Raw

$old = @'
$todayPrompts = @(
  "website-experimentation-review.prompt.md",
  "website-accessibility-remediation-review.prompt.md",
  "website-cookie-consent-review.prompt.md",
  "website-ai-chatbot-review.prompt.md",
  "website-account-login-review.prompt.md"
)
'@

$new = @'
$todayPrompts = @(
  "website-experimentation-review.prompt.md",
  "website-accessibility-remediation-review.prompt.md",
  "website-cookie-consent-review.prompt.md",
  "website-ai-chatbot-review.prompt.md",
  "website-account-login-review.prompt.md",
  "website-forms-submissions-review.prompt.md"
)
'@

if ($text -notlike '*website-forms-submissions-review.prompt.md*') {
  $text = $text.Replace($old, $new)
  Set-Content -Path $auditPath -Value $text -NoNewline
  Write-Host "Added website-forms-submissions-review.prompt.md to recent prompt check."
} else {
  Write-Host "website-forms-submissions-review.prompt.md already present."
}

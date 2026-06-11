Get-ChildItem "_copilot-shared\prompts" -Filter "website-*.prompt.md" |
  Sort-Object Name |
  ForEach-Object {
    $text = Get-Content $_.FullName -Raw

    [PSCustomObject]@{
      Name = $_.Name
      HasFrontMatter = $text.StartsWith("---")
      HasDescription = $text -match "(?m)^description:"
      HasOutputFormat = $text -match "## Output format"
      HasSeverityRules = $text -match "## Severity rules"
      HasRecommendationRules = $text -match "## Recommendation rules"
      HasDoNotInvent = $text -match "Do not invent"
      HasCurrentnessWarning = $text -match "Currentness warning"
      HasEscalation = $text -match "Escalation"
      HasWhatNotToDo = $text -match "What Not To Do"
    }
  } |
  Where-Object {
    -not $_.HasFrontMatter `
    -or -not $_.HasDescription `
    -or -not $_.HasOutputFormat `
    -or -not $_.HasSeverityRules `
    -or -not $_.HasRecommendationRules `
    -or -not $_.HasDoNotInvent `
    -or -not $_.HasCurrentnessWarning `
    -or -not $_.HasEscalation `
    -or -not $_.HasWhatNotToDo
  } |
  Format-Table -AutoSize

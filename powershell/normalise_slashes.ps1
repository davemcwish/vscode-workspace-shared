<#
.SYNOPSIS
    Convert Windows backslash path separators to forward slashes in a
    detect-secrets baseline file, so the committed file matches what the
    Linux CI runner produces.

.DESCRIPTION
    When detect-secrets runs on Windows it records file paths in
    .secrets.baseline using backslashes, e.g. "frontend\\app.py". The GitHub
    Actions runner is Linux, where detect-secrets writes forward slashes, e.g.
    "frontend/app.py". If the committed baseline still has backslashes, the CI
    scan sees the paths as unrecognised and reports "new secrets", failing the
    build.

    This script reads the baseline as ONE block of text (so the line structure
    is preserved), replaces every double backslash with a single forward
    slash, and writes it back unchanged in every other respect.

    Run it as the VERY LAST step before committing, AFTER your final run of
    sanity.bat. sanity.bat runs detect-secrets, which rewrites the baseline
    with Windows backslashes again, so any earlier slash fix would be undone.

.PARAMETER BaselinePath
    Path to the baseline file. Defaults to ".secrets.baseline" in the current
    directory. Pass a full path if you run the script from another folder.

.OUTPUTS
    None. Edits the file in place and prints before/after progress.

.EXAMPLE
    cd "C:\...\Salesforce"; ..\powershell\normalise_slashes.ps1

.NOTES
    Known limitation: this converts EVERY double backslash to a forward slash.
    detect-secrets baselines normally contain double backslashes only inside
    Windows file paths, so this is safe. If you ever add an --exclude-files or
    --exclude-lines REGULAR EXPRESSION containing a double backslash, this
    script would change that too - check the git diff after running.
#>

[CmdletBinding()]
param(
    [string] $BaselinePath = ".secrets.baseline"
)

# Stop on the first error; catch mistyped variable names early.
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# 1. The file must exist before we touch it.
if (-not (Test-Path -Path $BaselinePath -PathType Leaf)) {
    throw "Baseline not found: '$BaselinePath'. Run this from the project folder, or pass -BaselinePath."
}

# 2. Measure BEFORE, so we can prove what changed and guard against collapse.
$linesBefore = (Get-Content -Path $BaselinePath | Measure-Object -Line).Lines
$slashesBefore = (Select-String -Path $BaselinePath -Pattern '\\\\' | Measure-Object).Count
Write-Host "Before: $linesBefore lines, $slashesBefore backslash path(s)." -ForegroundColor Cyan

# 3. Idempotent: if there is nothing to fix, stop cleanly. Safe to re-run.
if ($slashesBefore -eq 0) {
    Write-Host "Already normalised - nothing to do." -ForegroundColor Green
    return
}

# 4. Read the WHOLE file as one string. -Raw is what keeps the line breaks.
#    Reading WITHOUT -Raw returns an array of lines; piping that array to
#    Set-Content -NoNewline would glue every line into a single line. -Raw
#    plus -NoNewline rewrites the file without adding or removing newlines,
#    preserving the Linux-style (LF) endings detect-secrets wrote.
try {
    $rawText = Get-Content -Path $BaselinePath -Raw
    $fixedText = $rawText -replace '\\\\', '/'
    Set-Content -Path $BaselinePath -Value $fixedText -NoNewline -Encoding ascii
}
catch {
    throw "Failed to rewrite '$BaselinePath': $($_.Exception.Message). Restore with: git checkout $BaselinePath"
}

# 5. Measure AFTER and guard against the 'flattened to one line' bug.
$linesAfter = (Get-Content -Path $BaselinePath | Measure-Object -Line).Lines
$slashesAfter = (Select-String -Path $BaselinePath -Pattern '\\\\' | Measure-Object).Count
Write-Host "After:  $linesAfter lines, $slashesAfter backslash path(s)." -ForegroundColor Cyan

if ($linesBefore -gt 1 -and $linesAfter -le 1) {
    throw "Line count collapsed from $linesBefore to $linesAfter - file was flattened. Restore with: git checkout $BaselinePath"
}

# 6. A baseline is JSON - confirm it still parses after the edit.
try {
    Get-Content -Path $BaselinePath -Raw | ConvertFrom-Json | Out-Null
}
catch {
    throw "Baseline is no longer valid JSON. Restore with: git checkout $BaselinePath"
}

Write-Host "Done. '$BaselinePath' now uses forward slashes and is valid JSON." -ForegroundColor Green

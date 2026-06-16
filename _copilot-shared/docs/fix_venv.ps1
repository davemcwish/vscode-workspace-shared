# fix_venv.ps1
# Run this from any location to recover from:
#   "Error: [Errno 13] Permission denied: ...\.venv\Scripts\python.exe"
#
# What it does:
#   1. Moves to the repo root (so all relative paths are correct)
#   2. Stops any Python processes that may be locking .venv files
#   3. Deletes the broken .venv
#   4. Recreates it cleanly via setup.ps1
#
# It runs from anywhere and handles the rest
# Example:
# & "C:\Users\<you>\path\to\repo\docs\fix_venv.ps1"
#

Set-Location -Path "$PSScriptRoot\.."

$repoRoot     = (Resolve-Path "$PSScriptRoot\..").Path
$parentRoot   = (Resolve-Path "$PSScriptRoot\..\..").Path

Write-Host "==> Stopping workspace venv Python processes..." -ForegroundColor Cyan
$targets = @(
    "$parentRoot\.venv\Scripts\python.exe",
    "$repoRoot\.venv\Scripts\python.exe"
)
$stopped = 0
Get-CimInstance Win32_Process -Filter "name='python.exe'" |
    Where-Object { $targets -contains $_.ExecutablePath } |
    ForEach-Object {
        Stop-Process -Id $_.ProcessId -Force
        Write-Host "  Stopped PID $($_.ProcessId): $($_.ExecutablePath)" -ForegroundColor Yellow
        $stopped++
    }
if ($stopped -eq 0) { Write-Host "  No locking processes found." -ForegroundColor Gray }

Write-Host "==> Removing .venv..." -ForegroundColor Cyan
if (Test-Path .\.venv) {
    Remove-Item -Recurse -Force .\.venv
    Write-Host "  .venv removed." -ForegroundColor Gray
} else {
    Write-Host "  .venv not found, skipping." -ForegroundColor Gray
}

Write-Host "==> Running setup.ps1..." -ForegroundColor Cyan
.\setup.ps1

Write-Host "==> Done. Venv rebuilt successfully." -ForegroundColor Green

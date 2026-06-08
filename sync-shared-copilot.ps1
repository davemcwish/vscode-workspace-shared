<#
.SYNOPSIS
    Syncs the shared Copilot guidance (_copilot-shared\) into one or more
    project repos under this parent folder.

.DESCRIPTION
    The _copilot-shared\ folder is the single source of truth for agents,
    chatmodes, instructions, prompts, skills, and the root
    copilot-instructions.md.

    Run this script after editing anything in _copilot-shared\ to propagate
    the changes to every project listed in $Projects.

.PARAMETER Projects
    Optional. One or more project subfolder names to sync into.
    Defaults to all entries in $DefaultProjects.

.EXAMPLE
    # Sync all projects
    .\sync-shared-copilot.ps1

.EXAMPLE
    # Sync only the Salesforce project
    .\sync-shared-copilot.ps1 -Projects Salesforce
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [string[]] $Projects
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Configuration ────────────────────────────────────────────────────────────

$Root   = $PSScriptRoot
$Shared = Join-Path $Root "_copilot-shared"

# Add new project folder names here as you create them.
$DefaultProjects = @(
    "asus-router-decoder",
    "powerpoint-reformat",
    "Salesforce",
    "Trails and Tails",
    "woprcrt-terminal-main"
)

# Subfolders inside _copilot-shared\ to mirror into each project's .github\
$Folders = @(
    ".spec-workflow",
    "agents",
    "chatmodes",
    "instructions",
    "prompts",
    "skills",
    "workflows"
)

# ── Resolve target project list ───────────────────────────────────────────────

if (-not $Projects) {
    $Projects = $DefaultProjects
}

# ── Helpers ───────────────────────────────────────────────────────────────────

function Sync-Folder {
    param([string] $Source, [string] $Destination)
    if (-not (Test-Path $Source)) {
        Write-Verbose "  Skipping '$Source' (not found in shared)"
        return
    }
    $null = New-Item -ItemType Directory -Path $Destination -Force
    # /XO  = skip destination files that are the same age or newer
    # /XC  = skip files that are the same size and timestamp (no-change)
    # /FFT = use FAT file times (2-second granularity) to avoid false positives
    #        caused by OneDrive/NTFS timestamp rounding differences
    robocopy $Source $Destination /E /XO /XC /FFT /NFL /NDL /NJH /NJS /NP /MT:4 | Out-Null
    if ($LASTEXITCODE -ge 8) {
        throw "robocopy failed for '$Source' → '$Destination' (exit $LASTEXITCODE)"
    }
}

function Sync-File {
    param([string] $Source, [string] $Destination)
    if (-not (Test-Path $Source)) {
        Write-Verbose "  Skipping '$Source' (not found in shared)"
        return
    }
    Copy-Item $Source $Destination -Force
}

# ── Main sync loop ─────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "=== sync-shared-copilot ===" -ForegroundColor Cyan
Write-Host "  Source : $Shared"
Write-Host ""

foreach ($project in $Projects) {
    $projectPath = Join-Path $Root $project
    $githubPath  = Join-Path $projectPath ".github"

    if (-not (Test-Path $projectPath)) {
        Write-Warning "  Project '$project' not found at '$projectPath' — skipping."
        continue
    }

    if (-not (Test-Path (Join-Path $projectPath ".git"))) {
        Write-Warning "  '$project' does not appear to be a git repo (no .git folder) — skipping."
        continue
    }

    Write-Host "  → $project" -ForegroundColor Green

    # Sync each subfolder
    foreach ($folder in $Folders) {
        Sync-Folder `
            -Source      (Join-Path $Shared $folder) `
            -Destination (Join-Path $githubPath $folder)
    }

    # Sync root copilot-instructions.md
    Sync-File `
        -Source      (Join-Path $Shared "copilot-instructions.md") `
        -Destination (Join-Path $githubPath "copilot-instructions.md")

    # Sync summary.md if present
    Sync-File `
        -Source      (Join-Path $Shared "summary.md") `
        -Destination (Join-Path $githubPath "summary.md")

    Write-Host "    Done." -ForegroundColor DarkGreen
}

Write-Host ""
Write-Host "=== Sync complete. Remember to commit any changes inside each project repo. ===" -ForegroundColor Cyan
Write-Host ""

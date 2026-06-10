<#
.SYNOPSIS
    Repairs the VS Code Copilot workspace state when chat modes, agents,
    or prompts disappear from the Copilot dropdown.

.DESCRIPTION
    This script recreates the root .github\ directory structure by copying
    all Copilot configuration from _copilot-shared\ (the single source of
    truth) into the root workspace .github\ folder.

    Use this after:
    - Deleting and recreating the workspace
    - Accidentally deleting the .github\ folder
    - Chat modes / agents / prompts disappearing from the dropdown
    - Seeing duplicates (use -RemoveDuplicatesFromProjects to clean sub-projects)

.PARAMETER RemoveDuplicatesFromProjects
    If specified, removes chatmodes/agents/prompts from individual sub-project
    .github\ folders so only the root workspace provides them.
    Only use this if projects are ALWAYS opened via the multi-root workspace.

.PARAMETER SkipReload
    If specified, skips the prompt to reload VS Code.

.EXAMPLE
    .\repair-workspace-copilot.ps1

.EXAMPLE
    .\repair-workspace-copilot.ps1 -RemoveDuplicatesFromProjects

.EXAMPLE
    .\repair-workspace-copilot.ps1 -Verbose
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch] $RemoveDuplicatesFromProjects,
    [switch] $SkipReload
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# -- Configuration ------------------------------------------------------------

$Root       = $PSScriptRoot
$Shared     = Join-Path $Root "_copilot-shared"
$RootGithub = Join-Path $Root ".github"

# Folders to sync from _copilot-shared\ into .github\
$Folders = @(
    ".spec-workflow",
    "agents",
    "chatmodes",
    "instructions",
    "prompts",
    "skills",
    "workflows"
)

# Sub-projects that might have their own .github\ copies
$Projects = @(
    "asus-router-decoder",
    "powerpoint-reformat",
    "Salesforce",
    "Trails and Tails",
    "woprcrt-terminal-main"
)

# -- Validation ----------------------------------------------------------------

Write-Host ""
Write-Host "=== repair-workspace-copilot ===" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $Shared)) {
    Write-Error "Source folder not found: $Shared  Cannot repair without _copilot-shared\."
    exit 1
}

$workspaceFile = Join-Path $Root "Visual Studio Code.code-workspace"
if (-not (Test-Path $workspaceFile)) {
    Write-Warning "Workspace file not found: $workspaceFile"
    Write-Warning "This script expects to run from the workspace root folder."
}

# -- Diagnose current state ----------------------------------------------------

Write-Host "Diagnosing current state..." -ForegroundColor Yellow
Write-Host ""

$issues = [System.Collections.ArrayList]::new()

if (-not (Test-Path $RootGithub)) {
    [void]$issues.Add("  [MISSING] Root .github\ folder does not exist")
}
else {
    foreach ($folder in $Folders) {
        $path = Join-Path $RootGithub $folder
        if (-not (Test-Path $path)) {
            [void]$issues.Add("  [MISSING] .github\$folder\")
        }
        else {
            $count = (Get-ChildItem $path -File).Count
            if ($count -eq 0) {
                [void]$issues.Add("  [EMPTY]   .github\$folder\ (0 files)")
            }
            else {
                Write-Verbose "  [OK]      .github\$folder\ ($count files)"
            }
        }
    }
}

if ($issues.Count -eq 0) {
    Write-Host "  No issues detected. .github\ appears intact." -ForegroundColor Green
    Write-Host "  Re-syncing anyway to ensure files are up to date." -ForegroundColor DarkGray
}
else {
    Write-Host "  Found $($issues.Count) issue(s):" -ForegroundColor Red
    foreach ($issue in $issues) {
        Write-Host $issue -ForegroundColor Red
    }
}

Write-Host ""

# -- Repair: Sync _copilot-shared\ into .github\ ------------------------------

Write-Host "Repairing root .github\ from _copilot-shared\..." -ForegroundColor Yellow

foreach ($folder in $Folders) {
    $src = Join-Path $Shared $folder
    $dst = Join-Path $RootGithub $folder

    if (-not (Test-Path $src)) {
        Write-Verbose "  Skipping '$folder' (not in _copilot-shared\)"
        continue
    }

    if ($PSCmdlet.ShouldProcess($dst, "Sync folder '$folder'")) {
        $null = New-Item -ItemType Directory -Path $dst -Force
        Copy-Item -Path "$src\*" -Destination $dst -Recurse -Force
        $count = (Get-ChildItem $dst -File -Recurse).Count
        Write-Host "  [SYNCED]  .github\$folder\ ($count files)" -ForegroundColor Green
    }
}

# Sync root-level files
$rootFiles = @("copilot-instructions.md", "summary.md")
foreach ($file in $rootFiles) {
    $src = Join-Path $Shared $file
    $dst = Join-Path $RootGithub $file
    if (Test-Path $src) {
        if ($PSCmdlet.ShouldProcess($dst, "Copy '$file'")) {
            Copy-Item -Path $src -Destination $dst -Force
            Write-Host "  [SYNCED]  .github\$file" -ForegroundColor Green
        }
    }
}

Write-Host ""

# -- Optional: Remove duplicates from sub-projects -----------------------------

if ($RemoveDuplicatesFromProjects) {
    Write-Host "Removing duplicates from sub-project .github\ folders..." -ForegroundColor Yellow

    # Only remove chatmodes/agents/prompts - these cause dropdown duplicates
    $duplicateFolders = @("chatmodes", "agents", "prompts")

    foreach ($project in $Projects) {
        $projectGithub = Join-Path $Root "$project\.github"
        if (-not (Test-Path $projectGithub)) { continue }

        foreach ($dfolder in $duplicateFolders) {
            $path = Join-Path $projectGithub $dfolder
            if (Test-Path $path) {
                if ($PSCmdlet.ShouldProcess($path, "Remove duplicate folder")) {
                    Remove-Item $path -Recurse -Force
                    Write-Host "  [REMOVED] $project\.github\$dfolder\" -ForegroundColor DarkYellow
                }
            }
        }
    }

    Write-Host ""
    Write-Warning "Sub-projects will no longer have their own chatmodes/agents/prompts."
    Write-Warning "They will rely on the root .github\ for discovery."
    Write-Warning "If you open a project standalone, re-run sync-shared-copilot.ps1."
    Write-Host ""
}

# -- Verify --------------------------------------------------------------------

Write-Host "Verification:" -ForegroundColor Yellow

$chatmodesPath = Join-Path $RootGithub "chatmodes"
$agentsPath    = Join-Path $RootGithub "agents"
$promptsPath   = Join-Path $RootGithub "prompts"

$chatmodeCount = 0
$agentCount    = 0
$promptCount   = 0

if (Test-Path $chatmodesPath) {
    $chatmodeCount = (Get-ChildItem $chatmodesPath -Filter "*.chatmode.md" -ErrorAction SilentlyContinue).Count
}
if (Test-Path $agentsPath) {
    $agentCount = (Get-ChildItem $agentsPath -Filter "*.agent.md" -ErrorAction SilentlyContinue).Count
}
if (Test-Path $promptsPath) {
    $promptCount = (Get-ChildItem $promptsPath -Filter "*.prompt.md" -ErrorAction SilentlyContinue).Count
}

$chatColor  = if ($chatmodeCount -gt 0) { "Green" } else { "Red" }
$agentColor = if ($agentCount -gt 0) { "Green" } else { "Red" }
$promptColor = if ($promptCount -gt 0) { "Green" } else { "DarkGray" }

Write-Host "  Chat modes : $chatmodeCount" -ForegroundColor $chatColor
Write-Host "  Agents     : $agentCount" -ForegroundColor $agentColor
Write-Host "  Prompts    : $promptCount" -ForegroundColor $promptColor

Write-Host ""

# -- Workspace settings check --------------------------------------------------

if (Test-Path $workspaceFile) {
    $wsContent = Get-Content $workspaceFile -Raw
    if ($wsContent -notmatch '"chat\.promptFiles"\s*:\s*true') {
        Write-Warning "Workspace setting 'chat.promptFiles' is not set to true."
        Write-Warning "Add this to your .code-workspace settings:"
        Write-Warning '  "chat.promptFiles": true'
    }
    else {
        Write-Host "  Workspace setting 'chat.promptFiles': true [OK]" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=== Repair complete ===" -ForegroundColor Cyan

if (-not $SkipReload) {
    Write-Host ""
    Write-Host "  -> Press Ctrl+Shift+P in VS Code and run:" -ForegroundColor White
    Write-Host "     Developer: Reload Window" -ForegroundColor White
    Write-Host ""
    Write-Host "  Chat modes should appear in the dropdown after reloading." -ForegroundColor DarkGray
}

Write-Host ""

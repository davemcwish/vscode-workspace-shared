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

    ROOT-LEVEL FOLDER SYNC: Folders listed in $RootFolders are synced into
    each project ROOT (not .github\).  Use this for content that belongs
    at the top level of every project, such as shared test fixtures or
    default config directories.  Edit them in _copilot-shared\<folder>\.

    SCAFFOLD SYNC: Certain scaffold files (listed in $ScaffoldSyncFiles) are
    always synced into the project ROOT on every run.  These are shared-owned
    files (sanity.bat, sanity_v.bat, .markdownlint.json) that must stay
    consistent across all projects.  Edit them in _copilot-shared\scaffold\.

    NEW PROJECTS: use -Scaffold -ScaffoldTarget <folder> to copy the starter
    files (README.md, CONTRIBUTING.md, requirements.in, etc.) from
    _copilot-shared\scaffold\ into the new project root.  These one-time
    scaffold files are copied once and are not overwritten on subsequent
    syncs — the project owns them after the initial copy.

.PARAMETER Projects
    Optional. One or more project subfolder names to sync into.
    Defaults to all entries in $DefaultProjects.

.PARAMETER Scaffold
    Switch. When present, copies scaffold starter files into -ScaffoldTarget.
    Does not overwrite files that already exist in the target.

.PARAMETER ScaffoldTarget
    Required when -Scaffold is used. The subfolder name of the new project
    (must already exist on disk as a git repo under the parent folder).

.EXAMPLE
    # Sync all projects
    .\sync-shared-copilot.ps1

.EXAMPLE
    # Sync only the Salesforce project
    .\sync-shared-copilot.ps1 -Projects Salesforce

.EXAMPLE
    # Copy scaffold files into a newly created project
    .\sync-shared-copilot.ps1 -Scaffold -ScaffoldTarget "My-New-Project"
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [string[]] $Projects,
    [switch]   $Scaffold,
    [string]   $ScaffoldTarget = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# -- Configuration -----------------------------------------------------------

$Root   = $PSScriptRoot
$Shared = Join-Path $Root "_copilot-shared"

# Add new project folder names here as you create them.
$DefaultProjects = @(
    "asus-router-decoder",
    "Salesforce",
    "Trails and Tails"
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

# Subfolders inside _copilot-shared\ to mirror into each project's ROOT
# (not .github\).  Use this for content that belongs at the project top-level,
# e.g. shared test scaffolds, default pytest fixtures, or config folders.
$RootFolders = @(
    "tests"
)

# Files in _copilot-shared\scaffold\ that are ALWAYS synced into the project
# ROOT (not .github\).  These are shared-owned -- edits belong in scaffold\.
# Files NOT in this list are copied only once via -Scaffold (project-owned).
$ScaffoldSyncFiles = @(
    ".markdownlint.json",
    "sanity.bat",
    "sanity_v.bat"
)

# -- Resolve target project list ---------------------------------------------

if (-not $Projects) {
    $Projects = $DefaultProjects
}

# -- Helpers -----------------------------------------------------------------

function Sync-Folder {
    <#
    .SYNOPSIS
        Mirror a source folder into a destination folder using robocopy.

    .DESCRIPTION
        Copies all files and subfolders from Source into Destination,
        skipping files that are the same age or newer in the destination
        (so already-up-to-date files are never re-copied unnecessarily).

        Uses robocopy flags chosen to avoid false-positive copies on
        OneDrive-managed folders: /XO skips older/same files; /FFT uses
        two-second FAT timestamp granularity to absorb OneDrive rounding.

        If robocopy exits with code 8 or higher (a real failure), an
        exception is thrown to stop the script immediately.

    .PARAMETER Source
        Absolute path to the folder to copy from (e.g. the _copilot-shared\agents\ folder).

    .PARAMETER Destination
        Absolute path to the folder to copy into (e.g. the project's .github\agents\ folder).
        Will be created if it does not exist.
    #>
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
        throw "robocopy failed for '$Source' -> '$Destination' (exit $LASTEXITCODE)"
    }
}

function Sync-File {
    <#
    .SYNOPSIS
        Copy a single file from Source to Destination, overwriting if it exists.

    .DESCRIPTION
        A simple wrapper around Copy-Item that silently skips the copy when
        the source file does not exist (so the script doesn't fail if an
        optional shared file is not yet present in _copilot-shared\).

    .PARAMETER Source
        Absolute path to the file to copy from.

    .PARAMETER Destination
        Absolute path where the file should be placed.
        The parent directory must already exist.
    #>
    param([string] $Source, [string] $Destination)
    if (-not (Test-Path $Source)) {
        Write-Verbose "  Skipping '$Source' (not found in shared)"
        return
    }
    Copy-Item $Source $Destination -Force
}

function Copy-ScaffoldFiles {
    <#
    .SYNOPSIS
        Copies starter files from _copilot-shared\scaffold\ into a new project.
    .DESCRIPTION
        Scaffold files are copied once at project creation time. Files that
        already exist in the target are skipped -- the project owns them after
        the initial copy and they are never overwritten by subsequent syncs.
    #>
    param([string] $TargetProject)

    $scaffoldSource = Join-Path $Shared "scaffold"
    $targetPath     = Join-Path $Root $TargetProject

    if (-not (Test-Path $scaffoldSource)) {
        Write-Warning "Scaffold directory not found at '$scaffoldSource'. Has _copilot-shared\scaffold\ been created?"
        return
    }

    if (-not (Test-Path $targetPath)) {
        Write-Warning "Target project '$TargetProject' not found at '$targetPath'. Create the folder first."
        return
    }

    Write-Host ""
    Write-Host "=== scaffold -> $TargetProject ===" -ForegroundColor Yellow
    Write-Host "  Source : $scaffoldSource"
    Write-Host "  Target : $targetPath"
    Write-Host ""

    $copied  = 0
    $skipped = 0

    foreach ($file in (Get-ChildItem $scaffoldSource -File)) {
        $dest = Join-Path $targetPath $file.Name
        if (Test-Path $dest) {
            Write-Verbose "  Skipping '$($file.Name)' (already exists in target)"
            $skipped++
        } else {
            Copy-Item $file.FullName $dest
            Write-Host "  Copied : $($file.Name)" -ForegroundColor DarkGreen
            $copied++
        }
    }

    Write-Host ""
    if ($copied -gt 0) {
        Write-Host "  $copied file(s) copied, $skipped skipped." -ForegroundColor Yellow
        Write-Host "  Review scaffold-README.md in '$TargetProject' for customisation notes." -ForegroundColor Yellow
    } else {
        Write-Host "  All scaffold files already exist in '$TargetProject' -- nothing copied." -ForegroundColor DarkGray
    }
    Write-Host ""
}

# -- Main sync loop ----------------------------------------------------------

Write-Host ""
Write-Host "=== sync-shared-copilot ===" -ForegroundColor Cyan
Write-Host "  Source : $Shared"
Write-Host ""

# -- Pre-sync validation -----------------------------------------------------
# The masters in _copilot-shared\ are the single source of truth. Refuse to
# propagate anything if the agent/chatmode pairing contract is broken.

Write-Host "  -> Validating agent/chatmode pairs..." -ForegroundColor Green
& py -3.12 -m pytest (Join-Path $Shared "tests\test_agent_chatmode_sync.py") -q --no-cov
if ($LASTEXITCODE -ne 0) {
    throw "Agent/chatmode pairing validation FAILED. Fix the masters in _copilot-shared\ before syncing."
}
Write-Host "    Validation passed (5 pairs, 13 checks)." -ForegroundColor DarkGreen
Write-Host ""

# -- Sync into root workspace .github\ ----------------------------------------


# The root workspace folder itself needs .github\ so that chatmodes, agents,
# and prompts appear in the VS Code Copilot dropdown for all workspace roots.

$rootGithub = Join-Path $Root ".github"
Write-Host "  -> ROOT (.github\)" -ForegroundColor Green

foreach ($folder in $Folders) {
    Sync-Folder `
        -Source      (Join-Path $Shared $folder) `
        -Destination (Join-Path $rootGithub $folder)
}

Sync-File `
    -Source      (Join-Path $Shared "copilot-instructions.md") `
    -Destination (Join-Path $rootGithub "copilot-instructions.md")

Sync-File `
    -Source      (Join-Path $Shared "summary.md") `
    -Destination (Join-Path $rootGithub "summary.md")

Write-Host "    Done." -ForegroundColor DarkGreen
Write-Host ""

# -- Sync into each project .github\ ------------------------------------------

foreach ($project in $Projects) {
    $projectPath = Join-Path $Root $project
    $githubPath  = Join-Path $projectPath ".github"

    if (-not (Test-Path $projectPath)) {
        Write-Warning "  Project '$project' not found at '$projectPath' -- skipping."
        continue
    }

    if (-not (Test-Path (Join-Path $projectPath ".git"))) {
        Write-Warning "  '$project' does not appear to be a git repo (no .git folder) -- skipping."
        continue
    }

    Write-Host "  -> $project" -ForegroundColor Green

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

    # Sync shared-owned scaffold files into the PROJECT ROOT (not .github\)
    $scaffoldDir = Join-Path $Shared "scaffold"
    foreach ($scaffoldFile in $ScaffoldSyncFiles) {
        Sync-File `
            -Source      (Join-Path $scaffoldDir $scaffoldFile) `
            -Destination (Join-Path $projectPath $scaffoldFile)
    }

    # Sync root-level folders (e.g. tests\) into the PROJECT ROOT (not .github\)
    foreach ($rootFolder in $RootFolders) {
        Sync-Folder `
            -Source      (Join-Path $Shared $rootFolder) `
            -Destination (Join-Path $projectPath $rootFolder)
    }

    Write-Host "    Done." -ForegroundColor DarkGreen
}

Write-Host ""
Write-Host "=== Sync complete. Remember to commit any changes inside each project repo. ===" -ForegroundColor Cyan
Write-Host ""

# -- Optional: scaffold a new project ----------------------------------------
# Run with: .\sync-shared-copilot.ps1 -Scaffold -ScaffoldTarget "My-New-Project"
# This copies starter files once and does not overwrite existing files.

if ($Scaffold) {
    if (-not $ScaffoldTarget) {
        Write-Warning "-Scaffold requires -ScaffoldTarget <project-folder-name>. Example:"
        Write-Warning "  .\sync-shared-copilot.ps1 -Scaffold -ScaffoldTarget `"My-New-Project`""
    } else {
        Copy-ScaffoldFiles -TargetProject $ScaffoldTarget
    }
}

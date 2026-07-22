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
    files (sanity.bat, sanity_v.bat, .markdownlint.json, security_scan.py,
    security_scan.ps1) that must stay consistent across all projects.  Edit
    them in _copilot-shared\scaffold\.

    NEW PROJECTS: use -Scaffold -ScaffoldTarget <folder> to copy the starter
    files (README.md, CONTRIBUTING.md, requirements.in, etc.) from
    _copilot-shared\scaffold\ into the new project root.  These one-time
    scaffold files are copied once and are not overwritten on subsequent
    syncs - the project owns them after the initial copy.

.PARAMETER Projects
    Optional. One or more project subfolder names to sync into.
    Defaults to all entries in $DefaultProjects.

.PARAMETER Scaffold
    Switch. When present, copies scaffold starter files into -ScaffoldTarget.
    Does not overwrite files that already exist in the target.

.PARAMETER ScaffoldTarget
    Required when -Scaffold is used. The subfolder name of the new project
    (must already exist on disk as a git repo under the parent folder).

.PARAMETER Validate
    Switch. When present, runs sanity.bat in each synced project after the
    sync completes. Reports pass/fail per project. Useful after shared
    Copilot artefact changes to confirm no downstream breakage.

.EXAMPLE
    # Sync all projects
    .\sync-shared-copilot.ps1

.EXAMPLE
    # Sync only the Salesforce project
    .\sync-shared-copilot.ps1 -Projects Salesforce

.EXAMPLE
    # Sync all projects then validate each with sanity.bat
    .\sync-shared-copilot.ps1 -Validate

.EXAMPLE
    # Copy scaffold files into a newly created project
    .\sync-shared-copilot.ps1 -Scaffold -ScaffoldTarget "My-New-Project"
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [string[]] $Projects,
    [switch]   $Scaffold,
    [string]   $ScaffoldTarget = "",
    [switch]   $Validate
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# -- Configuration -----------------------------------------------------------

# Script lives in powershell\ subfolder; workspace root is one level up.
$Root   = Split-Path $PSScriptRoot -Parent
$Shared = Join-Path $Root "_copilot-shared"

# Add new project folder names here as you create them.
$DefaultProjects = @(
    "Salesforce",
    "trails-and-tails",
    "eu-spm"
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

# Files WITHIN a synced $Folders subfolder that are PROJECT-OWNED and must NOT
# be overwritten by the sync. Keyed by the folder name (from $Folders above),
# the value is the list of filenames to exclude from the robocopy copy.
#
# workflows\ci.yml is the canonical example: every project needs a CI workflow,
# but each project's CI has a DIFFERENT shape and cannot share one file:
#   - Salesforce      : installable src\ package + requirements*.txt (+ JFrog)
#   - eu-spm          : scripts-only, requirements*.in, hardened (SHA-pinned)
#   - trails-and-tails: docs/website, no importable Python source
# So _copilot-shared\workflows\ci.yml is a REFERENCE TEMPLATE ONLY. Each project
# owns its real .github\workflows\ci.yml, and this exclusion stops the sync from
# clobbering that project-owned file with the template.
$FolderExcludeFiles = @{
    "workflows" = @("ci.yml")
}

# Subfolders inside _copilot-shared\ to mirror into each project's ROOT
# (not .github\).  Use this for content that belongs at the project top-level,
# e.g. shared test scaffolds, default pytest fixtures, or config folders.
$RootFolders = @(
    "docs",
    "tests"
)

# Files in _copilot-shared\scaffold\ that are ALWAYS synced into the project
# ROOT (not .github\).  These are shared-owned -- edits belong in scaffold\.
# Files NOT in this list are copied only once via -Scaffold (project-owned).
$ScaffoldSyncFiles = @(
    ".markdownlint.json",
    "sanity.bat",
    "sanity_v.bat",
    "security_scan.py",
    "security_scan.ps1",
    "sync-backups.ps1"
)

# Skill subfolders under .github\skills\ that are installed and maintained by an
# EXTERNAL tool (not by _copilot-shared) and must NOT be reported as stale drift.
# Example: "impeccable" is installed once at the workspace root via
# "npx impeccable install" and is discovered by Copilot across every project in
# the workspace. Because it has no source under _copilot-shared\skills\, the
# stale-file check below skips any path whose top-level segment is in this list.
# Add future externally-managed skill folder names here.
$UnmanagedSkillFolders = @(
    "impeccable"
)

# -- Resolve target project list ---------------------------------------------

if (-not $Projects) {
    $Projects = $DefaultProjects
}

# -- Helpers -----------------------------------------------------------------

# Tracking counters for the end-of-sync report.
$script:SyncReport = @{
    FilesCopied      = 0
    FilesSkipped     = 0
    StaleFiles       = [System.Collections.Generic.List[string]]::new()
    CaseFixed        = [System.Collections.Generic.List[string]]::new()
    ProjectsSynced   = [System.Collections.Generic.List[string]]::new()
    ProjectsSkipped  = [System.Collections.Generic.List[string]]::new()
    ValidationResults = @{}
}

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
    # robocopy is case-insensitive and will not fix a case-only rename; do it here.
    Repair-DestinationCase -Source $Source -Destination $Destination
}

function Sync-FolderStrict {
    <#
    .SYNOPSIS
        Mirror a source folder into a destination with source-always-wins.

    .DESCRIPTION
        Unlike Sync-Folder (which uses /XO to skip newer destination files),
        this function ALWAYS overwrites the destination. Use this for managed
        Copilot folders (.github/agents, .github/chatmodes, etc.) where
        _copilot-shared is the single source of truth and project-local edits
        are treated as drift.

        Does NOT delete extra files in the destination (that is handled
        separately by Find-StaleFiles for reporting purposes).

    .PARAMETER Source
        Absolute path to the folder to copy from.

    .PARAMETER Destination
        Absolute path to the folder to copy into. Created if missing.

    .PARAMETER ExcludeFiles
        Optional list of filenames (not full paths) to exclude from the copy,
        passed to robocopy's /XF flag. Use this for PROJECT-OWNED files that
        happen to live inside a synced folder (e.g. workflows\ci.yml) so the
        sync never overwrites them. Defaults to an empty list (copy everything).
    #>
    param(
        [string]   $Source,
        [string]   $Destination,
        [string[]] $ExcludeFiles = @()
    )
    if (-not (Test-Path $Source)) {
        Write-Verbose "  Skipping '$Source' (not found in shared)"
        return
    }
    $null = New-Item -ItemType Directory -Path $Destination -Force
    # No /XO -- source always wins. /IS copies even same-timestamp files.
    # /FFT still used for OneDrive timestamp granularity tolerance.
    # /XF excludes PROJECT-OWNED files (e.g. ci.yml) so they are never clobbered.
    $robocopyArgs = @($Source, $Destination, "/E", "/IS", "/FFT", "/NFL", "/NDL", "/NJH", "/NJS", "/NP", "/MT:4")
    if ($ExcludeFiles.Count -gt 0) {
        $robocopyArgs += "/XF"
        $robocopyArgs += $ExcludeFiles
    }
    robocopy @robocopyArgs | Out-Null
    if ($LASTEXITCODE -ge 8) {
        throw "robocopy strict-sync failed for '$Source' -> '$Destination' (exit $LASTEXITCODE)"
    }
    # robocopy is case-insensitive and will not fix a case-only rename; do it here.
    Repair-DestinationCase -Source $Source -Destination $Destination
}

function Find-StaleFiles {
    <#
    .SYNOPSIS
        Reports files in a destination folder that do not exist in the source.

    .DESCRIPTION
        Compares the destination folder against the source and identifies any
        files in the destination that have no corresponding source file.
        These are "stale" -- they may be leftovers from deleted shared
        artefacts, or accidental project-local additions.

        This function only REPORTS stale files (adds them to the sync report).
        It does NOT delete anything. Manual cleanup is required.

        Files under an externally-managed skill folder (see
        $UnmanagedSkillFolders, e.g. "impeccable") are skipped: they are
        installed by their own tool, have no source in _copilot-shared\, and so
        are not drift to be reported.

    .PARAMETER Source
        The _copilot-shared subfolder (e.g. agents/).

    .PARAMETER Destination
        The project's .github subfolder (e.g. .github/agents/).

    .PARAMETER ProjectName
        Used for display in the report.
    #>
    param([string] $Source, [string] $Destination, [string] $ProjectName)
    if (-not (Test-Path $Destination)) { return }
    if (-not (Test-Path $Source)) { return }

    $sourceFiles = Get-ChildItem $Source -Recurse -File |
        ForEach-Object { $_.FullName.Substring($Source.Length).TrimStart('\', '/') }

    $destFiles = Get-ChildItem $Destination -Recurse -File |
        ForEach-Object { $_.FullName.Substring($Destination.Length).TrimStart('\', '/') }

    # Case-SENSITIVE membership test. PowerShell's -in / -notin are
    # case-insensitive, which would HIDE case-only drift (for example a
    # leftover Explore.agent.md after the source was renamed to
    # explore.agent.md). An Ordinal HashSet makes such drift visible so it is
    # reported instead of silently shipped to case-sensitive Linux (CI/Cycode).
    $sourceSet = [System.Collections.Generic.HashSet[string]]::new(
        [string[]]$sourceFiles, [System.StringComparer]::Ordinal)

    foreach ($df in $destFiles) {
        # Skip externally-managed skill folders (e.g. impeccable). They are
        # installed by their own tool, have no source in _copilot-shared\, and
        # are intentionally root-only / project-local -- so they are not drift.
        if ($script:UnmanagedSkillFolders -contains ($df -split '[\\/]', 2)[0]) { continue }
        if (-not $sourceSet.Contains($df)) {
            $entry = "$ProjectName/.github/$(Split-Path $Destination -Leaf)/$df"
            $script:SyncReport.StaleFiles.Add($entry)
        }
    }
}

function Repair-DestinationCase {
    <#
    .SYNOPSIS
        Renames destination files whose filename case no longer matches source.

    .DESCRIPTION
        robocopy (used by Sync-Folder / Sync-FolderStrict) matches files
        case-INSENSITIVELY on Windows. When a shared file is renamed by case
        only - for example Explore.agent.md -> explore.agent.md - robocopy
        copies the new CONTENT but keeps the OLD destination FILENAME. On
        case-sensitive Linux (CI, Cycode) the old-cased name then fails to
        resolve - e.g. an agents: ["explore"] reference cannot find
        Explore.agent.md - so the rename must be propagated explicitly.

        This walks the destination and, for every file that matches a source
        file case-insensitively but NOT exactly, renames the destination to the
        source's exact case. A two-step rename via a temporary name is used so
        the change is reliable on case-insensitive filesystems, where a direct
        case-only rename can be treated as a no-op.

        Files in the destination with no source match are left untouched -
        Find-StaleFiles reports those separately.

    .PARAMETER Source
        The _copilot-shared subfolder being mirrored (exact-case authority).

    .PARAMETER Destination
        The project folder to repair.
    #>
    param([string] $Source, [string] $Destination)
    if (-not (Test-Path $Source)) { return }
    if (-not (Test-Path $Destination)) { return }

    # Lookup of source-relative paths keyed by their lower-case form; the value
    # is the EXACT-case relative path the destination must end up using.
    $sourceByLower = @{}
    Get-ChildItem $Source -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($Source.Length).TrimStart('\', '/')
        $sourceByLower[$rel.ToLowerInvariant()] = $rel
    }

    # Materialise the destination list first so renames during the loop cannot
    # disturb an in-flight enumeration.
    $destFiles = @(Get-ChildItem $Destination -Recurse -File)
    foreach ($f in $destFiles) {
        $destRel = $f.FullName.Substring($Destination.Length).TrimStart('\', '/')
        $key     = $destRel.ToLowerInvariant()
        if (-not $sourceByLower.ContainsKey($key)) { continue }

        $wantRel = $sourceByLower[$key]
        if ([string]::Equals($destRel, $wantRel, [System.StringComparison]::Ordinal)) {
            continue  # case already correct
        }

        $finalPath = Join-Path $Destination $wantRel
        $tempPath  = "$($f.FullName).casefix.tmp"
        Move-Item -LiteralPath $f.FullName -Destination $tempPath  -Force
        Move-Item -LiteralPath $tempPath   -Destination $finalPath -Force
        Write-Verbose "    Case-fixed: $destRel -> $wantRel"
        $projectRoot = Split-Path (Split-Path $Destination -Parent) -Parent
        $projectName = if ([string]::Equals($projectRoot, $Root, [System.StringComparison]::OrdinalIgnoreCase)) { "ROOT" } else { Split-Path $projectRoot -Leaf }
        $script:SyncReport.CaseFixed.Add("$projectName/.github/$(Split-Path $Destination -Leaf)/$wantRel")
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

function Resolve-ValidationPython {
    <#
        Returns a hashtable @{ Exe = <path-or-command>; Prefix = @(<args>) }
        for the first Python 3 runtime that actually has pytest installed.

        We deliberately do NOT hard-code 'py -3.12': the launcher throws
        "No suitable Python runtime found" on machines where 3.12 is absent
        (e.g. only 3.13 installed). Instead we probe, in order:
          1. the currently ACTIVE virtual environment ($env:VIRTUAL_ENV),
          2. the workspace-root .venv (created next to _copilot-shared\),
          3. the 'py -3' launcher (any Python 3),
          4. plain 'python' on PATH.
        The first candidate whose "import pytest" succeeds is used.

        Throws with recovery instructions if none is found.
    #>
    $candidates = @()
    if ($env:VIRTUAL_ENV) {
        $candidates += @{ Exe = (Join-Path $env:VIRTUAL_ENV "Scripts\python.exe"); Prefix = @() }
    }
    $candidates += @{ Exe = (Join-Path $Root ".venv\Scripts\python.exe"); Prefix = @() }
    $candidates += @{ Exe = "py";     Prefix = @("-3") }
    $candidates += @{ Exe = "python"; Prefix = @() }

    foreach ($cand in $candidates) {
        # Skip explicit interpreter paths that do not exist on disk.
        if ($cand.Exe -like "*\*" -and -not (Test-Path $cand.Exe)) { continue }
        try {
            # A native command that exits non-zero while 2>$null under
            # $ErrorActionPreference='Stop' can escalate to a terminating
            # error in Windows PowerShell 5.1, so wrap the probe in try/catch.
            & $cand.Exe @($cand.Prefix) -c "import pytest" 2>$null
        } catch {
            continue
        }
        if ($LASTEXITCODE -eq 0) { return $cand }
    }
    throw @"
No Python 3 runtime with pytest was found for pre-sync validation.
Create the workspace-root virtual environment and install pytest:
  py -m venv .venv
  .\.venv\Scripts\python.exe -m pip install pytest
"@
}

Write-Host "  -> Validating agent/chatmode pairs..." -ForegroundColor Green
$validationPython = Resolve-ValidationPython
& $validationPython.Exe @($validationPython.Prefix) -m pytest (Join-Path $Shared "tests\test_agent_chatmode_sync.py") -q --no-cov
if ($LASTEXITCODE -ne 0) {
    throw "Agent/chatmode pairing validation FAILED. Fix the masters in _copilot-shared\ before syncing."
}
Write-Host "    Validation passed (5 pairs, 13 checks)." -ForegroundColor DarkGreen
Write-Host ""

# -- Regenerate MANIFEST.md ---------------------------------------------------
# The manifest lists every artefact with its description, auto-extracted from
# frontmatter. Regenerating on every sync ensures it never drifts.

Write-Host "  -> Regenerating MANIFEST.md..." -ForegroundColor Green
& powershell.exe -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "build-manifest.ps1")
Write-Host ""

# -- Sync into root workspace .github\ ----------------------------------------


# The root workspace folder itself needs .github\ so that chatmodes, agents,
# and prompts appear in the VS Code Copilot dropdown for all workspace roots.

$rootGithub = Join-Path $Root ".github"
Write-Host "  -> ROOT (.github\)" -ForegroundColor Green

foreach ($folder in $Folders) {
    $exclude = @()
    if ($FolderExcludeFiles.ContainsKey($folder)) { $exclude = $FolderExcludeFiles[$folder] }
    Sync-FolderStrict `
        -Source       (Join-Path $Shared $folder) `
        -Destination  (Join-Path $rootGithub $folder) `
        -ExcludeFiles $exclude
    Find-StaleFiles `
        -Source      (Join-Path $Shared $folder) `
        -Destination (Join-Path $rootGithub $folder) `
        -ProjectName "ROOT"
}

Sync-File `
    -Source      (Join-Path $Shared "copilot-instructions.md") `
    -Destination (Join-Path $rootGithub "copilot-instructions.md")

Sync-File `
    -Source      (Join-Path $Shared "summary.md") `
    -Destination (Join-Path $rootGithub "summary.md")

# Sync shared-owned scaffold files into the ROOT workspace folder too.
# This allows the parent workspace repo to run sanity.bat / sanity_v.bat
# directly, while the batch files adapt to _copilot-shared\tests.
$rootScaffoldDir = Join-Path $Shared "scaffold"
foreach ($scaffoldFile in $ScaffoldSyncFiles) {
    Sync-File `
        -Source      (Join-Path $rootScaffoldDir $scaffoldFile) `
        -Destination (Join-Path $Root $scaffoldFile)
}

Write-Host "    Done." -ForegroundColor DarkGreen
Write-Host ""

# -- Sync into each project .github\ ------------------------------------------

foreach ($project in $Projects) {
    $projectPath = Join-Path $Root $project
    $githubPath  = Join-Path $projectPath ".github"

    if (-not (Test-Path $projectPath)) {
        Write-Warning "  Project '$project' not found at '$projectPath' -- skipping."
        $script:SyncReport.ProjectsSkipped.Add($project)
        continue
    }

    if (-not (Test-Path (Join-Path $projectPath ".git"))) {
        Write-Warning "  '$project' does not appear to be a git repo (no .git folder) -- skipping."
        $script:SyncReport.ProjectsSkipped.Add($project)
        continue
    }

    Write-Host "  -> $project" -ForegroundColor Green
    $script:SyncReport.ProjectsSynced.Add($project)

    # Sync each managed subfolder (source-wins, stale detection)
    foreach ($folder in $Folders) {
        $exclude = @()
        if ($FolderExcludeFiles.ContainsKey($folder)) { $exclude = $FolderExcludeFiles[$folder] }
        Sync-FolderStrict `
            -Source       (Join-Path $Shared $folder) `
            -Destination  (Join-Path $githubPath $folder) `
            -ExcludeFiles $exclude
        Find-StaleFiles `
            -Source      (Join-Path $Shared $folder) `
            -Destination (Join-Path $githubPath $folder) `
            -ProjectName $project
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
    # These use standard Sync-Folder (with /XO) because project-specific tests
    # may coexist and we only want to add/update shared tests, not overwrite.
    foreach ($rootFolder in $RootFolders) {
        Sync-Folder `
            -Source      (Join-Path $Shared $rootFolder) `
            -Destination (Join-Path $projectPath $rootFolder)
    }

    Write-Host "    Done." -ForegroundColor DarkGreen
}

Write-Host ""
Write-Host "=== Sync complete ===" -ForegroundColor Cyan
Write-Host ""

# -- Sync Verification Report ------------------------------------------------

Write-Host "--- Sync Report ---" -ForegroundColor Yellow
Write-Host "  Projects synced  : $($script:SyncReport.ProjectsSynced.Count) ($($script:SyncReport.ProjectsSynced -join ', '))"
if ($script:SyncReport.ProjectsSkipped.Count -gt 0) {
    Write-Host "  Projects skipped : $($script:SyncReport.ProjectsSkipped.Count) ($($script:SyncReport.ProjectsSkipped -join ', '))" -ForegroundColor DarkYellow
}

if ($script:SyncReport.StaleFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "  STALE FILES DETECTED ($($script:SyncReport.StaleFiles.Count)):" -ForegroundColor Red
    Write-Host "  These exist in project .github/ but NOT in _copilot-shared/." -ForegroundColor Red
    Write-Host "  They may be leftovers from deleted artefacts or accidental local edits." -ForegroundColor Red
    Write-Host "  Manual action required: delete them from each project, or add them to _copilot-shared/." -ForegroundColor Red
    Write-Host ""
    foreach ($stale in $script:SyncReport.StaleFiles) {
        Write-Host "    - $stale" -ForegroundColor DarkRed
    }
    Write-Host ""
} else {
    Write-Host "  Stale files      : none (all project .github/ files have a source in _copilot-shared/)" -ForegroundColor DarkGreen
}

if ($script:SyncReport.CaseFixed.Count -gt 0) {
    Write-Host ""
    Write-Host "  CASE-FIXED FILES ($($script:SyncReport.CaseFixed.Count)):" -ForegroundColor Yellow
    Write-Host "  Destination filenames were renamed to match the source's exact case" -ForegroundColor Yellow
    Write-Host "  (a case-only rename in _copilot-shared/). Commit these renames in each project." -ForegroundColor Yellow
    Write-Host ""
    foreach ($cf in $script:SyncReport.CaseFixed) {
        Write-Host "    - $cf" -ForegroundColor DarkYellow
    }
    Write-Host ""
}

Write-Host ""
Write-Host "  Remember to commit any changes inside each project repo." -ForegroundColor Cyan
Write-Host ""

# -- Downstream Validation (optional) ----------------------------------------

if ($Validate) {
    Write-Host "=== Downstream Validation (-Validate) ===" -ForegroundColor Cyan
    Write-Host "  Running sanity.bat in each synced project..." -ForegroundColor Green
    Write-Host ""

    foreach ($project in $script:SyncReport.ProjectsSynced) {
        $projectPath = Join-Path $Root $project
        $sanityPath  = Join-Path $projectPath "sanity.bat"

        if (-not (Test-Path $sanityPath)) {
            Write-Host "  [$project] SKIPPED (no sanity.bat found)" -ForegroundColor DarkYellow
            $script:SyncReport.ValidationResults[$project] = "SKIPPED"
            continue
        }

        Write-Host "  [$project] Running sanity.bat..." -ForegroundColor Green
        Push-Location $projectPath
        try {
            # Temporarily relax error preference for native commands.
            # sanity.bat writes to stderr on failure which PowerShell treats
            # as a terminating error under $ErrorActionPreference = "Stop".
            $prevPref = $ErrorActionPreference
            $ErrorActionPreference = "Continue"
            try {
                # Disable coverage during -Validate. Coverage collection via
                # pytest-xdist is flaky under nested PowerShell -> cmd.exe
                # process chains (race condition merging .coverage.* files).
                # Lint, format, mypy, bandit, and detect-secrets still run in
                # full. Coverage correctness is enforced by CI (ci.yml).
                $env:SANITY_NO_COV = "1"
                $output = & cmd.exe /c sanity.bat 2>&1
                Remove-Item Env:\SANITY_NO_COV -ErrorAction SilentlyContinue
            } finally {
                $ErrorActionPreference = $prevPref
            }
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  [$project] PASSED" -ForegroundColor DarkGreen
                $script:SyncReport.ValidationResults[$project] = "PASSED"
            } else {
                Write-Host "  [$project] FAILED (exit code $LASTEXITCODE)" -ForegroundColor Red
                # Show the last 30 lines of output to help diagnose.
                $lines = ($output | Out-String) -split "`n" |
                         Where-Object { $_.Trim() -ne "" } |
                         Select-Object -Last 30
                foreach ($line in $lines) {
                    Write-Host "    $line" -ForegroundColor DarkGray
                }
                $script:SyncReport.ValidationResults[$project] = "FAILED"
            }
        } finally {
            Pop-Location
        }
    }

    Write-Host ""
    Write-Host "--- Validation Summary ---" -ForegroundColor Yellow
    foreach ($kvp in $script:SyncReport.ValidationResults.GetEnumerator()) {
        $color = switch ($kvp.Value) {
            "PASSED"  { "DarkGreen" }
            "FAILED"  { "Red" }
            "SKIPPED" { "DarkYellow" }
            default   { "Gray" }
        }
        Write-Host "  $($kvp.Key): $($kvp.Value)" -ForegroundColor $color
    }
    Write-Host ""
}

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

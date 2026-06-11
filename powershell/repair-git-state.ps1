<#
.SYNOPSIS
    Repairs common Git lock/cleanup issues on locked Windows machines.

.DESCRIPTION
    This script targets repos that get stuck on prompts such as:
    "Deletion of directory '...\ .git\objects\00' failed. Should I try again?"

    It clears stale lock files, removes common problematic remote-tracking paths,
    disables auto-maintenance for fetch operations, and normalizes your branch.

.PARAMETER RepoPath
    Absolute path to the local Git repository.

.PARAMETER MainBranch
    Branch to normalize to. Defaults to "main".

.PARAMETER RemoveLocalBranch
    Optional local branch name to delete after recovery.

.PARAMETER SkipFetch
    Skip network fetch/prune.

.PARAMETER SkipReset
    Skip hard reset to origin/<MainBranch>.

.EXAMPLE
    .\repair-git-state.ps1 -RepoPath "C:\Users\dwishar1\Documents\Visual Studio Code\Salesforce" -RemoveLocalBranch "feature/req-d-shared-library-refactor"

.EXAMPLE
    .\repair-git-state.ps1 -RepoPath "C:\Users\dwishar1\Documents\Visual Studio Code\Salesforce" -SkipFetch -SkipReset
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $RepoPath,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $MainBranch = "main",

    [Parameter()]
    [string] $RemoveLocalBranch,

    [switch] $SkipFetch,
    [switch] $SkipReset
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-Git {
    <#
    .SYNOPSIS
        Run a git command and throw an error if it fails.

    .DESCRIPTION
        A thin wrapper around the ``git`` executable that automatically checks
        the exit code after every call. If git returns a non-zero exit code
        (meaning something went wrong), this function throws a PowerShell
        exception that stops the script immediately with a clear error message.

        This prevents the script from silently continuing after a failed git
        command, which could leave the repository in an inconsistent state.

    .PARAMETER Args
        The git sub-command and its arguments as an array of strings.
        For example: @('checkout', '-f', 'main') or @('status', '-sb').

    .EXAMPLE
        Invoke-Git -Args @('fetch', 'origin', '--prune')
        # Runs: git fetch origin --prune
        # Throws if the fetch fails (no network, auth error, etc.).

    .EXAMPLE
        Invoke-Git -Args @('reset', '--hard', 'origin/main')
        # Discards all local changes and resets to the remote main branch.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $Args
    )

    & git @Args
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Args -join ' ') failed with exit code $LASTEXITCODE"
    }
}

if (-not (Test-Path $RepoPath)) {
    throw "RepoPath does not exist: $RepoPath"
}

$gitDir = Join-Path $RepoPath '.git'
if (-not (Test-Path $gitDir)) {
    throw "Not a Git repo (missing .git): $RepoPath"
}

Set-Location -Path $RepoPath
Write-Host "Repo: $RepoPath" -ForegroundColor Cyan

# 1) Clear read-only/pinned attributes in working tree (best effort).
try {
    attrib -R -P * /S /D 2>$null
}
catch {
    Write-Verbose "attrib reset skipped: $($_.Exception.Message)"
}

# 2) Remove stale lock files under .git.
$locks = Get-ChildItem -Path $gitDir -Recurse -Filter '*.lock' -ErrorAction SilentlyContinue
if ($locks) {
    foreach ($lock in $locks) {
        Remove-Item -Force $lock.FullName -ErrorAction SilentlyContinue
    }
    Write-Host "Removed $($locks.Count) stale .lock file(s)." -ForegroundColor Yellow
}
else {
    Write-Host "No stale .lock files found." -ForegroundColor DarkGray
}

# 3) Remove known problematic remote-tracking feature folders (best effort).
$problemTargets = @(
    '.git\logs\refs\remotes\origin\feature',
    '.git\refs\remotes\origin\feature'
)

foreach ($target in $problemTargets) {
    if (Test-Path $target) {
        try {
            attrib -R -P "$target\*" /S /D 2>$null
            Remove-Item -Recurse -Force $target -ErrorAction Stop
            Write-Host "Removed: $target" -ForegroundColor Yellow
        }
        catch {
            Write-Warning "Could not remove ${target}: $($_.Exception.Message)"
        }
    }
}

# 4) Fetch/prune with maintenance disabled (unless skipped).
if (-not $SkipFetch) {
    Invoke-Git -Args @('-c', 'gc.auto=0', '-c', 'maintenance.auto=false', 'fetch', 'origin', '--prune', '--no-auto-maintenance')
}
else {
    Write-Host "SkipFetch enabled: fetch/prune skipped." -ForegroundColor DarkGray
}

# 5) Normalize branch.
Invoke-Git -Args @('checkout', '-f', $MainBranch)

if (-not $SkipReset) {
    Invoke-Git -Args @('reset', '--hard', "origin/$MainBranch")
}
else {
    Write-Host "SkipReset enabled: hard reset skipped." -ForegroundColor DarkGray
}

# 6) Optionally delete stale local branch.
if ($RemoveLocalBranch) {
    & git branch -D $RemoveLocalBranch 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Deleted local branch: $RemoveLocalBranch" -ForegroundColor Yellow
    }
    else {
        Write-Host "Local branch not deleted (may not exist): $RemoveLocalBranch" -ForegroundColor DarkGray
    }
}

# 7) Final status.
Invoke-Git -Args @('status', '-sb')
Invoke-Git -Args @('branch', '--list')

Write-Host "Repair complete." -ForegroundColor Green

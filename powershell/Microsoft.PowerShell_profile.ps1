# ------------------------------------------------------------
# Git helper: create a new branch from the latest main.
# Usage: New-GitBranch feat/my-feature-name
#
# What it does:
#   1. Fetches all remotes so your local view is current.
#   2. Switches to main and fast-forwards it.
#   3. Creates and switches to the new branch from that point.
# This guarantees the branch is never "behind" main when opened as a PR.
# ------------------------------------------------------------
function New-GitBranch {
    param(
        [Parameter(Mandatory)][string]$BranchName
    )
    git fetch --all --prune
    git checkout main
    git pull
    git checkout -b $BranchName
    Write-Host "Created '$BranchName' from latest main." -ForegroundColor Green
}
Set-Alias ngb New-GitBranch
<#
.SYNOPSIS
    Mirror the canonical "origin/main" branch onto the backup remotes so every
    copy of this repository is identical.

.DESCRIPTION
    This project keeps three copies of the same Git repository:

      - origin         The MASTER copy. It runs the full CI pipeline
                       (Cycode, Copilot, Qodo, CodeGuardians). All real work is
                       reviewed and merged here first.
      - personal       A BACKUP copy on a personal GitHub account.
      - ford-personal  A second BACKUP copy.

    The two backups exist only to mirror "origin". They must never be edited
    directly (do NOT merge pull requests straight into them), because doing so
    makes their history "diverge" -- grow a different shape -- from origin. Once
    that happens a normal "git push" is refused, and the backup must be
    overwritten with a force-push.

    This script performs the mirror safely and in the correct order:

      1. Download the latest state of the master remote ("git fetch").
      2. Read the current commit id (the "SHA") of <SourceRemote>/<Branch>.
      3. For each backup remote: fetch it (so the safety check below compares
         against the backup's true tip), then force the backup's <Branch> to
         that exact SHA using "--force-with-lease".
      4. Confirm each backup now points at the same SHA as the master.
      5. Print a summary table.

    What is "--force-with-lease"? It is a safer force-push. A plain force-push
    overwrites the remote no matter what. "--force-with-lease" overwrites only
    if the remote still matches what we just fetched a moment ago; if someone
    pushed to the backup in that split second, it refuses, so you never destroy
    an unexpected change by accident.

    WHY force-push at all? A backup is meant to be an exact copy of origin. If a
    backup's history has diverged, the only way to make it match again is to
    overwrite it. Because the backups hold no unique work -- everything of value
    lives on origin -- overwriting them loses nothing.

.PARAMETER RepoPath
    The folder that contains the Git repository to mirror. Defaults to the
    directory you run the script FROM (your current location), NOT the folder
    the script file lives in. This matters because this one shared script lives
    in the parent workspace's "powershell" folder but is used to mirror several
    separate sub-repositories (for example "Salesforce"), each with its own
    remotes. Defaulting to your current directory means:

        cd <the repo you want to mirror>
        ..\powershell\sync-backups.ps1

    mirrors THAT repo. Pass -RepoPath explicitly if you want to mirror a repo
    other than the one you are standing in.

.PARAMETER SourceRemote
    The name of the MASTER remote that the backups must copy. Defaults to
    "origin". You should almost never change this.

.PARAMETER Branch
    The branch to mirror. Defaults to "main".

.PARAMETER BackupRemote
    One or more backup remote names to overwrite with the source branch.
    Defaults to "personal" and "ford-personal". The script refuses to overwrite
    the SourceRemote even if you list it here, so origin can never be clobbered.

.OUTPUTS
    None. The script writes coloured progress messages and a final summary table
    to the screen. It stops with an error (throws) if the source branch cannot
    be found, or if any reachable backup's force-push is rejected, or if the
    post-push re-read finds a DIFFERENT commit than we just pushed (a genuine
    mismatch, e.g. someone pushed during the sync).

    A successful force-push is treated as proof of success on its own. If the
    optional post-push re-read cannot reach the remote (typically a missed SSH
    passphrase prompt on that extra query), the backup is still reported OK
    (shown as "OK*" - pushed, remote re-read skipped); it does NOT throw.
    Unreachable backups (those whose initial fetch fails) are reported as
    warnings and recorded as UNREACHABLE in the summary table; they do not cause
    a throw.

.EXAMPLE
    .\sync-backups.ps1 -WhatIf

    Show what the script WOULD push, and to which commit, without making any
    remote changes. Note: fetches still run in -WhatIf mode so the preview shows
    accurate current SHAs rather than potentially stale locally-cached ones.
    Only the force-push step is skipped. Recommended before the first real run.

.EXAMPLE
    .\sync-backups.ps1

    Mirror origin/main onto both default backups. Because a force-push is
    destructive, the script asks you to confirm each one. Press "Y" to proceed.

.EXAMPLE
    .\sync-backups.ps1 -Confirm:$false

    Mirror without the per-remote confirmation prompt. Use this once you trust
    the script and want an unattended run.

.EXAMPLE
    .\sync-backups.ps1 -BackupRemote personal

    Mirror only the "personal" backup (skip ford-personal). Useful when one
    backup is temporarily unreachable.

.NOTES
    SSH key passphrase: "origin" and "ford-personal" use a passphrase-protected
    SSH key, so Git will prompt for the passphrase in your terminal. The
    "personal" remote uses a passphrase-free key and will not prompt. Run this
    script yourself in an interactive terminal so you can type the passphrase
    when asked. Expect up to three prompts per passphrase-protected backup: one
    for the pre-push fetch, one for the push itself, and one for the post-push
    verification query (git ls-remote).

    Reduce the prompts to one: load your key into ssh-agent before running this
    script, so every Git call reuses the cached key instead of asking again.
    In the SAME PowerShell window, run:

        Start-Service ssh-agent          # once per machine; may need an admin shell
        ssh-add $HOME\.ssh\id_ed25519    # type the passphrase this one time

    Then run this script - Git will not prompt again for that session. If the
    verification query is skipped because a prompt was missed, the run reports
    that backup as FAIL (not a crash) so you can simply re-run it.

    Branch protection: if a backup has GitHub branch protection that forbids
    force-pushes, the push is rejected with "GH006: Cannot force-push to this
    branch". Temporarily allow force-pushes on that branch
    (GitHub -> Settings -> Branches), re-run this script, then re-enable
    protection.

    Golden rule: never merge pull requests directly into a backup. Always make
    changes on origin and run this script. That keeps the backups fast-forward
    and avoids force-pushes entirely.
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    # RepoPath is a filesystem path; it is not validated against the remote-name
    # pattern below. Push-Location will fail early if the path does not exist.
    #
    # Default to the caller's CURRENT directory, not $PSScriptRoot. This script
    # lives in the parent workspace's "powershell" folder but mirrors whichever
    # sub-repository you run it from (each sub-repo has its own remotes, e.g.
    # only "Salesforce" has a "personal" backup). Using $PSScriptRoot here would
    # always mirror the parent workspace repo instead - which silently skipped
    # "personal" and pushed the wrong repository. (Get-Location).Path is the
    # directory the user invoked the script from.
    [string]$RepoPath = (Get-Location).Path,

    # Git remote and branch names must start with a letter or digit. The pattern
    # below also rejects anything starting with "-", which git would silently
    # treat as an option flag rather than a remote or branch name.
    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9_./-]*$')]
    [string]$SourceRemote = 'origin',

    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9_./-]*$')]
    [string]$Branch = 'main',

    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9_./-]*$')]
    [string[]]$BackupRemote = @('personal', 'ford-personal')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-GitSha {
    <#
    .SYNOPSIS
        Return the commit id (SHA) that a Git reference points at, or $null.

    .DESCRIPTION
        A "reference" (or "ref") is a human-friendly name for a commit, such as
        "origin/main". This helper turns that name into the underlying 40-
        character commit id. It is read-only: it never changes the repository.

    .PARAMETER Ref
        The Git reference to look up, for example "origin/main" or
        "personal/main".

    .OUTPUTS
        [string] The 40-character commit id, or $null if the ref does not exist.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Ref
    )

    # Defence-in-depth against option injection: a ref that begins with "-" could
    # be mis-read by git as an option flag. Every internal caller passes a value
    # built from the ValidatePattern-guarded parameters (so in normal use this
    # can never happen), but we reject it explicitly rather than depend on that
    # invariant holding forever.
    if ($Ref.StartsWith('-')) {
        return $null
    }

    # "--verify --quiet" makes git exit non-zero (instead of printing an error)
    # when the ref is missing, so we can detect that cleanly. stderr is
    # redirected to $null so a missing ref stays quiet -- we intentionally treat
    # "not found" as a normal $null result rather than an error to print.
    #
    # Do NOT add a "--" terminator here. For most git commands "--" separates
    # options from operands, but "git rev-parse --verify" treats every argument
    # AFTER "--" as a PATHSPEC (a filename), not a revision. Passing
    # "-- origin/main" makes git look for a file called "origin/main", leaving
    # --verify with no revision to check, so it wrongly reports the ref as
    # missing. The StartsWith('-') guard above provides the injection protection
    # that "--" would normally give us, without breaking ref resolution.
    $sha = git rev-parse --verify --quiet $Ref 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($sha)) {
        return $null
    }
    # rev-parse --verify returns a single line, but take the first line and trim
    # it defensively so the contract ("return one SHA or $null") always holds
    # even if git ever emits extra output.
    return ($sha | Select-Object -First 1).Trim()
}

# Push-Location remembers where we started so the finally block can return there,
# leaving the caller's shell in its original directory no matter what happens.
Push-Location -Path $RepoPath
try {
    # Confirm we are actually inside a Git repository before doing anything.
    git rev-parse --is-inside-work-tree *> $null
    if ($LASTEXITCODE -ne 0) {
        throw "No Git repository was found at '$RepoPath'. Run this script from the repository root, or pass -RepoPath."
    }

    Write-Host "Backup mirror starting." -ForegroundColor Cyan
    Write-Host ("Master remote : {0}" -f $SourceRemote)
    Write-Host ("Branch        : {0}" -f $Branch)
    Write-Host ("Backups       : {0}" -f ($BackupRemote -join ', '))
    Write-Host ""

    # Step 1: refresh the master remote so its branch tip is up to date.
    Write-Host "Fetching '$SourceRemote' (you may be asked for your SSH key passphrase)..." -ForegroundColor Cyan
    git fetch $SourceRemote
    if ($LASTEXITCODE -ne 0) {
        throw "Could not fetch '$SourceRemote'. Check your network connection and SSH key, then try again."
    }

    # Step 2: read the single commit id that every backup must end up at.
    $sourceRef = "$SourceRemote/$Branch"
    $targetSha = Get-GitSha -Ref $sourceRef
    if ($null -eq $targetSha) {
        throw "Could not find '$sourceRef'. Does the '$Branch' branch exist on '$SourceRemote'?"
    }
    Write-Host ("Source {0} is at {1}" -f $sourceRef, $targetSha) -ForegroundColor Green

    # Build the list of remotes configured in this clone. We validate the exit
    # code so a broken git installation fails fast with a clear message instead
    # of silently skipping every backup. We also trim each line and drop any
    # blank ones so the membership check below is reliable even if git returns
    # unexpected whitespace in its output.
    $knownRemotes = @(git remote)
    if ($LASTEXITCODE -ne 0) {
        throw "Could not list Git remotes. Ensure Git is installed and the repository is healthy (try 'git remote -v')."
    }
    $knownRemotes = @(
        $knownRemotes |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        ForEach-Object { $_.Trim() }
    )

    # We record one result object per backup so we can print a summary at the end.
    $results = @()

    foreach ($remote in $BackupRemote) {
        Write-Host ""
        Write-Host "=== Mirroring '$remote' ===" -ForegroundColor Cyan

        # Safety: never overwrite the master remote, even if it was passed in.
        if ($remote -eq $SourceRemote) {
            Write-Warning "Refusing to overwrite the master remote '$SourceRemote'. Skipping."
            $results += [pscustomobject]@{ Remote = $remote; Status = 'SKIP'; Sha = '(master, never touched)' }
            continue
        }

        # Safety: skip any remote name that is not configured in this clone.
        # -cnotcontains is the case-SENSITIVE variant, matching how git itself
        # treats remote names (e.g. "Personal" is not the same as "personal").
        if ($knownRemotes -cnotcontains $remote) {
            Write-Warning "Remote '$remote' is not configured (see 'git remote -v'). Skipping."
            $results += [pscustomobject]@{ Remote = $remote; Status = 'SKIP'; Sha = '(not configured)' }
            continue
        }

        # Fetch the backup so --force-with-lease compares against its true tip.
        Write-Host "Fetching '$remote'..." -ForegroundColor Cyan
        git fetch $remote
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Could not fetch '$remote'. Skipping (check network, SSH key, or passphrase)."
            # UNREACHABLE (not FAIL): an unreachable backup is a transient
            # condition, so it is reported as a warning and does NOT cause the
            # final throw. Only reachable backups that fail to push or verify
            # are recorded as FAIL. This matches the .OUTPUTS contract.
            $results += [pscustomobject]@{ Remote = $remote; Status = 'UNREACHABLE'; Sha = '(unreachable)' }
            continue
        }

        # The push spec "origin/main:refs/heads/main" means: take the local copy
        # of the master branch and write it to the backup's "main" branch. The
        # ${} braces keep the colon from being mis-parsed as a drive qualifier.
        $pushSpec = "${sourceRef}:refs/heads/${Branch}"

        # ShouldProcess gives this script -WhatIf and -Confirm for free. Because
        # ConfirmImpact is High, the user is asked to confirm each force-push
        # unless they pass -Confirm:$false. Under -WhatIf nothing is pushed.
        if (-not $PSCmdlet.ShouldProcess("$remote/$Branch", "force-push to $targetSha")) {
            $results += [pscustomobject]@{ Remote = $remote; Status = 'WHATIF'; Sha = $targetSha }
            continue
        }

        Write-Host "Force-pushing '$remote/$Branch' -> $targetSha..." -ForegroundColor Cyan
        git push --force-with-lease $remote $pushSpec
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Force-push to '$remote' failed."
            Write-Warning "  If you saw 'GH006: Cannot force-push', temporarily allow force-pushes on the protected branch and re-run."
            Write-Warning "  If you saw 'stale info', someone pushed during the sync; simply re-run this script."
            $results += [pscustomobject]@{ Remote = $remote; Status = 'FAIL'; Sha = '(push rejected)' }
            continue
        }

        # Verify the new tip by querying the backup directly with git ls-remote.
        # A local remote-tracking ref (e.g. "$remote/$Branch") is only refreshed
        # by fetch, so it can be stale immediately after a push; ls-remote reads
        # the server's true tip and keeps the summary honest. This is
        # authoritative but costs one more network round-trip and, on a
        # passphrase-protected remote, one more prompt (see the .NOTES section).
        #
        # IMPORTANT: this verification is BEST-EFFORT, not a gate. A
        # "git push --force-with-lease" that exits 0 has already succeeded - the
        # remote now holds $targetSha; the lease check even guarantees we did not
        # clobber unexpected work. So the push is the real proof of success. The
        # only failure this extra query can legitimately catch is a genuine SHA
        # MISMATCH (someone pushed again between our push and this read). If the
        # query merely cannot authenticate (a fumbled third passphrase prompt),
        # that says nothing about whether the push worked, so we must NOT mark
        # the backup FAIL for it - doing so previously produced false failures.
        #
        # The try/catch also handles a PowerShell 5.1 quirk: when a native
        # command BOTH exits non-zero AND writes to stderr while its stderr is
        # redirected with "2>$null", $ErrorActionPreference = 'Stop' turns that
        # into a *terminating* NativeCommandError. Catching it keeps the run
        # alive so the summary and the other backups are unaffected.
        try {
            $lsRemote = git ls-remote $remote "refs/heads/$Branch" 2>$null
            $lsExitCode = $LASTEXITCODE
        }
        catch {
            $lsRemote = $null
            $lsExitCode = 1
        }
        if ($lsExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($lsRemote)) {
            # Push succeeded (we only reach here after exit 0 above); we just
            # could not RE-READ the remote to double-check. Trust the push and
            # report OK with a note rather than a false FAIL.
            Write-Warning "Could not re-read '$remote' to double-check the push (often a missed SSH passphrase prompt on the verification query)."
            Write-Warning "  The force-push itself succeeded, so '$remote/$Branch' is at $targetSha. Load your key into ssh-agent (see .NOTES) to get a clean verification next time."
            Write-Host "[OK] $remote/$Branch pushed to $targetSha (push confirmed; remote re-read skipped)" -ForegroundColor Green
            $results += [pscustomobject]@{ Remote = $remote; Status = 'OK*'; Sha = $targetSha }
            continue
        }
        # ls-remote prints "<sha><TAB>refs/heads/<branch>". Take the first line's
        # SHA field; Select-Object -First 1 guards against unexpected extra lines.
        $backupSha = ($lsRemote | Select-Object -First 1).Split("`t")[0].Trim()
        if ($backupSha -eq $targetSha) {
            Write-Host "[OK] $remote/$Branch is now at $backupSha" -ForegroundColor Green
            $results += [pscustomobject]@{ Remote = $remote; Status = 'OK'; Sha = $backupSha }
        }
        else {
            # A genuine mismatch: the remote holds a DIFFERENT SHA than we just
            # pushed, which means someone pushed again in between. This is the
            # one case worth failing on, so re-running (with the lease check)
            # can reconcile it safely.
            Write-Warning "Verification failed for '$remote': expected $targetSha but found '$backupSha'. Someone may have pushed during the sync; re-run this script."
            $results += [pscustomobject]@{ Remote = $remote; Status = 'FAIL'; Sha = "$backupSha" }
        }
    }

    # Final summary table. Out-String + Write-Host keeps the table off the
    # pipeline, as required by the project PowerShell standards.
    Write-Host ""
    Write-Host "=== Summary ===" -ForegroundColor Cyan
    Write-Host ("Source: {0} at {1}" -f $sourceRef, $targetSha)
    ($results | Format-Table -AutoSize Remote, Status, Sha | Out-String).TrimEnd() | Write-Host

    # Warn about unreachable backups but do not throw. An unreachable remote is
    # a transient condition (no network, SSH key not loaded, etc.) and should
    # not mark a run as failed when the other backups synced successfully.
    $unreachable = @($results | Where-Object { $_.Status -eq 'UNREACHABLE' })
    if ($unreachable.Count -gt 0) {
        Write-Warning ("{0} backup(s) were unreachable and skipped: {1}. Re-run when they are accessible." -f $unreachable.Count, (($unreachable | ForEach-Object { $_.Remote }) -join ', '))
    }

    # Throw only when a reachable backup was attempted but failed -- either the
    # push was rejected or the post-push SHA verification disagreed with the
    # source. This matches the .OUTPUTS contract.
    $failed = @($results | Where-Object { $_.Status -eq 'FAIL' })
    if ($failed.Count -gt 0) {
        throw ("{0} backup(s) did not sync: {1}. See the messages above for how to fix each one." -f $failed.Count, (($failed | ForEach-Object { $_.Remote }) -join ', '))
    }

    # $WhatIfPreference is set to $true automatically whenever the caller passes
    # -WhatIf. In that mode nothing was actually pushed, so we must NOT claim the
    # backups now mirror the source -- that would mislead a beginner into
    # thinking a dry run made real changes.
    Write-Host ""
    if ($WhatIfPreference) {
        Write-Host "Dry run complete. No changes were made. Re-run without -WhatIf to mirror $sourceRef onto the backups." -ForegroundColor Yellow
    }
    else {
        Write-Host "Done. All reachable backups now mirror $sourceRef." -ForegroundColor Green
    }
}
finally {
    Pop-Location
}

<#
.SYNOPSIS
    Compares two directories for identity including nested subfolders.

.DESCRIPTION
    Checks for missing files/folders and optionally validates file integrity using SHA256.
    Works with OneDrive paths, but be aware that checksums will trigger downloads for 'cloud-only' files.

    The script builds a "snapshot" of each folder - a lookup table mapping every
    relative path to a fingerprint - then compares the two snapshots and reports
    three kinds of difference:

      - Missing in Destination    the item exists in Source but not in Destination
      - Content Mismatch          the item exists in both, but the fingerprints differ
      - Extra item in Destination the item exists in Destination but not in Source

    If there are no differences at all, it prints a success message instead.

.PARAMETER SourcePath
    Required. The full path to the folder you are treating as the "known good"
    original, for example "D:\Reports\2026". Must already exist, or the script
    stops with an error.

.PARAMETER DestinationPath
    Required. The full path to the folder you are checking against the source,
    for example "E:\Backup\Reports\2026". Must already exist, or the script
    stops with an error.

.PARAMETER UseChecksums
    Optional switch. Omit it (the default) for a fast comparison that fingerprints
    each file by its size and last-modified timestamp - quick, but it cannot detect
    a change that preserves both. Supply -UseChecksums to fingerprint each file by
    its SHA256 hash instead: far more reliable, but it must read every byte of
    every file, so it is much slower and will force OneDrive to download any
    "cloud-only" files it touches.

.EXAMPLE
    .\Compare-Folders.ps1 -SourcePath "D:\Reports" -DestinationPath "E:\Backup\Reports"

    Fast comparison using file size and timestamp only.

.EXAMPLE
    .\Compare-Folders.ps1 -SourcePath "D:\Reports" -DestinationPath "E:\Backup\Reports" -UseChecksums

    Thorough comparison using SHA256 hashes. Use this when you need certainty
    that the file contents genuinely match.

.NOTES
    Read-only: this script never creates, modifies, or deletes anything in either
    folder. It only reports what it finds.
#>

param (
    [Parameter(Mandatory=$true)][string]$SourcePath,
    [Parameter(Mandatory=$true)][string]$DestinationPath,
    [Parameter(Mandatory=$false)][switch]$UseChecksums = $false
)

function Get-FolderSnapshot {
    param ([string]$Path)
    
    # Get all files and directories recursively
    $items = Get-ChildItem -Path $Path -Recurse
    
    $snapshot = @{}
    foreach ($item in $items) {
        # Get path relative to the root folder being scanned
        $relativePath = $item.FullName.Substring($Path.Length).TrimStart('\')
        
        if ($item.PSIsContainer) {
            $snapshot[$relativePath] = "Directory"
        } else {
            if ($UseChecksums) {
                # Calculate SHA256 Hash
                $hash = (Get-FileHash -Path $item.FullName -Algorithm SHA256).Hash
                $snapshot[$relativePath] = $hash
            } else {
                # Compare by Length and LastWriteTime for a "fast" check
                $snapshot[$relativePath] = "$($item.Length)_$($item.LastWriteTime.Ticks)"
            }
        }
    }
    return $snapshot
}

Write-Host "Scanning folders...`n" -ForegroundColor Cyan

if (!(Test-Path $SourcePath) -or !(Test-Path $DestinationPath)) {
    Write-Error "One or both provided paths do not exist."
    return
}

$sourceSnapshot = Get-FolderSnapshot -Path $SourcePath
$destSnapshot = Get-FolderSnapshot -Path $DestinationPath

$differences = @()

# 1. Check for items in Source that are missing or different in Destination
foreach ($key in $sourceSnapshot.Keys) {
    if (-not $destSnapshot.ContainsKey($key)) {
        $differences += [PSCustomObject]@{ Path = $key; Status = "Missing in Destination" }
    } elseif ($sourceSnapshot[$key] -ne $destSnapshot[$key]) {
        $differences += [PSCustomObject]@{ Path = $key; Status = "Content Mismatch" }
    }
}

# 2. Check for items in Destination that aren't in Source
foreach ($key in $destSnapshot.Keys) {
    if (-not $sourceSnapshot.ContainsKey($key)) {
        $differences += [PSCustomObject]@{ Path = $key; Status = "Extra item in Destination" }
    }
}

if ($differences.Count -eq 0) {
    Write-Host "Success: Folders are identical!" -ForegroundColor Green
} else {
    Write-Host "Differences found:" -ForegroundColor Yellow
    $differences | Format-Table -AutoSize
}

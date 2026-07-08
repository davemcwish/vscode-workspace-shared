<#
.SYNOPSIS
    Enhanced PDF counter with per-folder breakdown and CSV comparison.

.DESCRIPTION
    Counts PDF files in a directory tree, showing:
    - Total counts
    - Per-folder breakdown (by immediate child folder)
    - Comparison against a CSV manifest (if provided)
    - Identifies missing files

.PARAMETER TargetPath
    Root directory to scan for PDFs.

.PARAMETER CsvPath
    Optional path to an export_contract_pdf_manifest_prod_*.csv or similar.
    If provided, compares disk count vs. CSV count and lists missing files.

.PARAMETER ShowAllMissing
    Optional. If true, displays all missing files instead of just the top 10.
    Only used when -CsvPath is provided.

.EXAMPLE
    .\count-pdf-total-enhanced.ps1 
        -TargetPath "C:\Users\[userid]\OneDrive - azureford\Documents\Salesforce\AXP Decom 2026\AXP_EDMS_Records\AXP_Contract_PDFs_Prod_2026.07.08"

.EXAMPLE
    .\count-pdf-total-enhanced.ps1 
        -TargetPath "C:\Users\[userid]\OneDrive - azureford\Documents\Salesforce\AXP Decom 2026\AXP_EDMS_Records\AXP_Contract_PDFs_Prod_2026.07.08" 
        -CsvPath "C:\Users\[userid]\OneDrive - azureford\Documents\Salesforce\AXP Decom 2026\AXP_EDMS_Records\AXP_Contract_PDFs_Prod_2026.07.08\export_contract_pdf_manifest_prod_2026.07.08.csv"

.EXAMPLE
    .\count-pdf-total-enhanced.ps1 
        -TargetPath "C:\Users\[userid]\OneDrive - azureford\Documents\Salesforce\AXP Decom 2026\AXP_EDMS_Records\AXP_Contract_PDFs_Prod_2026.07.08" 
        -CsvPath "C:\Users\[userid]\OneDrive - azureford\Documents\Salesforce\AXP Decom 2026\AXP_EDMS_Records\AXP_Contract_PDFs_Prod_2026.07.08\export_contract_pdf_manifest_prod_2026.07.08.csv" 
        -ShowAllMissing
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$TargetPath,

    [Parameter(Mandatory = $false)]
    [string]$CsvPath,

    [Parameter(Mandatory = $false)]
    [switch]$ShowAllMissing
)

Write-Host "
PDF COUNT REPORT" -ForegroundColor Cyan
Write-Host "Target Path: $TargetPath
" -ForegroundColor Gray

if (-not (Test-Path -Path $TargetPath -PathType Container)) {
    Write-Host "ERROR: Target path does not exist or is not accessible." -ForegroundColor Red
    exit 1
}

$allPdfs = @(Get-ChildItem -Path $TargetPath -Recurse -File -Filter *.pdf)
$totalPdfCount = $allPdfs.Count

Write-Host "OVERALL: $totalPdfCount PDFs found on disk
" -ForegroundColor White

Write-Host "COUNT BY FOLDER:" -ForegroundColor Yellow

$childFolders = @(Get-ChildItem -Path $TargetPath -Directory -ErrorAction SilentlyContinue)

if ($childFolders.Count -eq 0) {
    Write-Host "  (No subfolders found)" -ForegroundColor Gray
} else {
    $folderStats = @()
    
    foreach ($folder in $childFolders) {
        $pdfCount = @(Get-ChildItem -Path $folder.FullName -Recurse -File -Filter *.pdf).Count
        $folderStats += [PSCustomObject]@{
            "Folder Name"   = $folder.Name
            "PDF Count"     = $pdfCount
        }
    }

    $folderStats | Sort-Object -Property "PDF Count" -Descending | Format-Table -Property "Folder Name", "PDF Count" -AutoSize
}

if ($CsvPath) {
    Write-Host "
CSV MANIFEST COMPARISON:" -ForegroundColor Yellow

    if (-not (Test-Path -Path $CsvPath -PathType Leaf)) {
        Write-Host "  ERROR: CSV file not found" -ForegroundColor Red
    } else {
        $csv = Import-Csv -Path $CsvPath -ErrorAction Stop
        $csvCount = $csv.Count
        
        if ($csvCount -is [System.Management.Automation.PSObject]) {
            $csvCount = 1
        }

        Write-Host "  CSV manifest rows: $csvCount" -ForegroundColor White
        Write-Host "  PDFs on disk:      $totalPdfCount" -ForegroundColor White

        $difference = $csvCount - $totalPdfCount
        if ($difference -eq 0) {
            Write-Host "  Status: MATCH - All files accounted for" -ForegroundColor Green
        } elseif ($difference -gt 0) {
            Write-Host "  Status: MISSING - $difference files in CSV but not on disk" -ForegroundColor Red
            
            if ($ShowAllMissing) {
                Write-Host "
  All missing files:" -ForegroundColor Yellow
            } else {
                Write-Host "
  Top missing files (use -ShowAllMissing to see all):" -ForegroundColor Yellow
            }

            $csvPaths = $csv | Select-Object -ExpandProperty LocalPath | Select-Object -Unique
            $diskPaths = $allPdfs | Select-Object -ExpandProperty FullName
            
            $missing = @()
            foreach ($path in $csvPaths) {
                if ($diskPaths -notcontains $path) {
                    $missing += $path
                }
            }

            if ($ShowAllMissing) {
                # Display all missing files
                $missing | ForEach-Object {
                    Write-Host "    $_" -ForegroundColor Red
                }
            } else {
                # Display only top 10
                $missing | Select-Object -First 10 | ForEach-Object {
                    Write-Host "    $_" -ForegroundColor Red
                }

                if ($missing.Count -gt 10) {
                    Write-Host "    ... and $($missing.Count - 10) more" -ForegroundColor Gray
                }
            }
        } else {
            Write-Host "  Status: EXTRA - $([Math]::Abs($difference)) files on disk but not in CSV" -ForegroundColor Yellow
        }
    }
}

Write-Host ""

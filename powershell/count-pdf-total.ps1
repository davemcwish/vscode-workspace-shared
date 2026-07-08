$targetPath = "C:\Users\[userid]\OneDrive - azureford\Documents\Salesforce\AXP Decom 2026\AXP_EDMS_Records\AXP_Contract_PDFs_Prod_2026.07.08"

# Count all subfolders recursively
$folderCount = @(Get-ChildItem -Path $targetPath -Recurse -Directory).Count

# Count all PDF files recursively
$pdfCount = @(Get-ChildItem -Path $targetPath -Recurse -File -Filter *.pdf).Count

# Display results
[PSCustomObject]@{
    "Target Path"  = $targetPath
    "Total Folders" = $folderCount
    "Total PDFs"    = $pdfCount
}

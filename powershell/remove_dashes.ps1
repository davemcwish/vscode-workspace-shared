$root = "C:\Users\dwishar1\Documents\Visual Studio Code"

$enDash = [string][char]0x2013
$emDash = [string][char]0x2014
$replacement = "-"

Get-ChildItem $root -Include *.md,*.py,*.ps1,*.bat -Recurse |
Where-Object {
    $_.FullName -notmatch '\\(\.git|\.venv|\.ruff_cache|\.pytest_cache|\.mypy_cache|__pycache__|node_modules)\\'
} |
ForEach-Object {
    $path = $_.FullName
    $content = [System.IO.File]::ReadAllText($path)

    $updated = $content.Replace($enDash, $replacement).Replace($emDash, $replacement)

    if ($content -ne $updated) {
        [System.IO.File]::WriteAllText($path, $updated)

        $relative = $path.Replace($root + "\", "")
        Write-Host "Fixed: $relative"
    }
}

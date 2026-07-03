$root = "C:\Users\dwishar1\Documents\Visual Studio Code"

Get-ChildItem $root -Include *.md,*.py,*.ps1,*.bat -Recurse |
Where-Object {
    $_.FullName -notmatch '\\(\.git|\.venv|\.ruff_cache|\.pytest_cache|\.mypy_cache|__pycache__|node_modules)\\'
} |
ForEach-Object {
    $content = [System.IO.File]::ReadAllText($_.FullName)

    if ($content.Contains([string][char]0x2013) -or $content.Contains([string][char]0x2014)) {
        $relative = $_.FullName.Replace($root + "\", "")

        [PSCustomObject]@{
            File = $relative
            ContainsEnOrEmDash = $true
        }
    }
}

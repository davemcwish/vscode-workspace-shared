<#
.SYNOPSIS
  Teaching version of the local high-risk security pattern scanner.

.DESCRIPTION
  This script scans a repository for selected high-risk patterns that are often
  reviewed during security checks. It is intentionally regex-based and
  conservative, so findings should be reviewed by a person before code is
  changed.

  The executable scanning logic is intended to match security_scan.ps1. This
  teaching copy adds comment-based help and explanatory comments only.

  The scanner:
    - walks files under a root folder,
    - skips common dependency, cache, virtual environment, and build folders,
    - scans selected source and configuration file types,
    - treats .env* files as important even when they have unusual suffixes,
    - redacts likely secret values before display,
    - emits text or JSON,
    - and can fail the process when findings meet a chosen severity threshold.

.PARAMETER Root
  The folder to scan. Defaults to the current directory.

.PARAMETER Format
  Output format. Use Text for human review or Json for machine processing.

.PARAMETER FailOn
  Severity threshold that should cause exit code 1. Use NONE to always exit 0
  unless there is an execution error.

.PARAMETER Output
  Optional output file path. If omitted, results are printed to the console.

.PARAMETER IncludeExt
  Additional file extensions to scan. The leading dot is optional. For example,
  both ps1 and .ps1 are accepted.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\security_scan_teaching_comments.ps1

  Scan the current directory and print text output.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\security_scan_teaching_comments.ps1 -Root . -FailOn HIGH

  Scan the current directory and return exit code 1 if a HIGH or CRITICAL finding
  is present.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\security_scan_teaching_comments.ps1 -Format Json -Output security_findings.json

  Write deterministic JSON output to a file.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\security_scan_teaching_comments.ps1 -IncludeExt .ps1

  Include PowerShell scripts in addition to the default extension list.

.NOTES
  This teaching file explains how the scanner works. It does not replace formal
  security tooling, approved review processes, or human judgement.
#>

[CmdletBinding()]
param(
    [string]$Root = '.',
    [ValidateSet('Text', 'Json')]
    [string]$Format = 'Text',
    [ValidateSet('LOW', 'MEDIUM', 'HIGH', 'CRITICAL', 'NONE')]
    [string]$FailOn = 'HIGH',
    [string]$Output = '',
    # ALIGNED (item 2): mirror Python --include-ext. Repeatable via array.
    [string[]]$IncludeExt = @()
)

$ErrorActionPreference = 'Stop'

# TEACHING NOTE: Severity values are numeric so sorting and threshold comparisons are simple.
$SeverityOrder = @{
    LOW      = 1
    MEDIUM   = 2
    HIGH     = 3
    CRITICAL = 4
}

# TEACHING NOTE: These folders are skipped to avoid dependencies, caches, build output, and generated files.
$ExcludedDirs = @(
    '.git', '.hg', '.svn', '.venv', 'venv', 'env', 'node_modules',
    '__pycache__', '.pytest_cache', '.mypy_cache', '.ruff_cache', '.tox',
    'dist', 'build', 'coverage', 'htmlcov', '.idea'
)

# TEACHING NOTE: This is the default scan scope. Extra extensions can be added with -IncludeExt.
$IncludedExts = @(
    '.py', '.js', '.jsx', '.ts', '.tsx', '.html', '.htm', '.css',
    '.md', '.json', '.yml', '.yaml', '.toml', '.cfg', '.ini', '.txt', '.env'
)

# ALIGNED (item 2): extend the included-extension set from -IncludeExt,
# normalising a leading dot, same as Python.
foreach ($ext in $IncludeExt) {
    $norm = if ($ext.StartsWith('.')) { $ext.ToLower() } else { ('.' + $ext).ToLower() }
    if ($IncludedExts -notcontains $norm) { $IncludedExts += $norm }
}

$SecretWords = 'api[_-]?key|secret|token|password|passwd|pwd|session[_-]?id|client[_-]?secret|private[_-]?key|access[_-]?token|refresh[_-]?token'

# TEACHING NOTE: Each rule is data: id, severity, extension scope, regex, description, and fix guidance.
$Rules = @(
    [pscustomobject]@{
        Id = 'SECRET-HARDCODED'; Severity = 'HIGH'; Exts = $null
        Regex = ('\b(' + $SecretWords + ')\b\s*[:=]\s*[''\"](?!\s*(?:<|your-|placeholder|example|changeme|dummy|test|none|null))[^''\"]{8,}[''\"]')
        Description = 'Possible hard-coded secret, token, password, or session id.'
        Fix = 'Move secrets to approved secret storage or environment variables; commit only placeholders in .env.example.'
    }
    [pscustomobject]@{
        Id = 'SECRET-PRIVATE-KEY'; Severity = 'CRITICAL'; Exts = $null
        Regex = '-----BEGIN [A-Z ]*PRIVATE KEY-----'
        Description = 'Private key material appears to be present.'
        Fix = 'Remove the key, rotate it, and use the approved secrets manager.'
    }
    [pscustomobject]@{
        Id = 'PY-SUBPROCESS-SHELL-TRUE'; Severity = 'CRITICAL'; Exts = @('.py')
        Regex = '\bsubprocess\.(run|Popen|call|check_call|check_output)\s*\([^#\n]*shell\s*=\s*True'
        Description = 'subprocess call uses shell=True.'
        Fix = 'Use subprocess with a list, shell=False, literal command parts, and validated arguments.'
    }
    [pscustomobject]@{
        Id = 'PY-OS-SYSTEM'; Severity = 'CRITICAL'; Exts = @('.py')
        Regex = '\b(os\.system|os\.popen|commands\.getoutput|commands\.getstatusoutput)\s*\('
        Description = 'Shell command execution via os.system/os.popen/commands.getoutput.'
        Fix = 'Replace with subprocess.run([...], shell=False) and allow-list validated inputs.'
    }
    [pscustomobject]@{
        Id = 'PY-SUBPROCESS-STRING-COMMAND'; Severity = 'HIGH'; Exts = @('.py')
        Regex = '\bsubprocess\.(run|Popen|call|check_call|check_output)\s*\(\s*(f?[''\"]|[a-zA-Z_][\w.]*\s*\+)'
        Description = 'subprocess appears to receive a string/f-string command rather than a safe argument list.'
        Fix = 'Pass a list of arguments; validate executable with validate_subprocess_command(); validate dynamic args locally.'
    }
    [pscustomobject]@{
        Id = 'PY-EVAL-EXEC'; Severity = 'CRITICAL'; Exts = @('.py')
        Regex = '\b(eval|exec|compile)\s*\('
        Description = 'Dynamic Python code execution via eval/exec/compile.'
        Fix = 'Avoid dynamic code execution. Use allow-listed functions or data-driven dispatch tables.'
    }
    [pscustomobject]@{
        Id = 'PY-DYNAMIC-OPEN'; Severity = 'MEDIUM'; Exts = @('.py')
        Regex = '(?<![\w.])open\s*\(\s*(?![''\"])'
        Description = 'open() appears to use a non-literal path; ensure resolve_safe_path() and local re-validation are used.'
        Fix = 'Use resolve_safe_path(), assign safe_path, and pass only the validated path into file I/O.'
    }
    [pscustomobject]@{
        Id = 'PY-TEMPFILE-DYNAMIC-PREFIX'; Severity = 'HIGH'; Exts = @('.py')
        Regex = '\bNamedTemporaryFile\s*\([^#\n]*prefix\s*=\s*(?![''\"])'
        Description = 'NamedTemporaryFile prefix appears dynamic; Cycode flags tainted temp filename prefixes.'
        Fix = "Use a fixed literal prefix, e.g. prefix='report_attachment_'. Do not derive temp filenames from attachment names."
    }
    [pscustomobject]@{
        Id = 'PY-ZIP-EXTRACTALL'; Severity = 'HIGH'; Exts = @('.py')
        Regex = '\.extractall\s*\('
        Description = 'ZipFile.extractall() can allow ZIP Slip path traversal if archive members are untrusted.'
        Fix = 'Validate every ZIP member destination stays under the intended target directory before extracting.'
    }
    [pscustomobject]@{
        Id = 'PY-XML-STDLIB'; Severity = 'HIGH'; Exts = @('.py')
        Regex = '(from\s+xml\.etree\s+import|import\s+xml\.etree|xml\.etree\.ElementTree|\bET\.parse\s*\()'
        Description = 'Python standard-library XML parser usage; may be vulnerable to hostile XML payloads.'
        Fix = 'Use defusedxml.ElementTree for XML parsing, especially for files influenced by users or external systems.'
    }
    [pscustomobject]@{
        Id = 'PY-WEAK-PRNG'; Severity = 'HIGH'; Exts = @('.py')
        Regex = '\brandom\.(Random\s*\(|random\s*\(|randint\s*\(|randrange\s*\(|choice\s*\(|choices\s*\(|shuffle\s*\(|sample\s*\()'
        Description = 'Use of random.* or random.Random(); not suitable for security-sensitive randomness and historically flagged by Cycode.'
        Fix = 'For secrets use secrets.*. For non-security randomness use SystemRandom() or deterministic index-based selection.'
    }
    [pscustomobject]@{
        Id = 'PY-INSECURE-SMTP'; Severity = 'HIGH'; Exts = @('.py')
        Regex = '\bsmtplib\.SMTP\s*\('
        Description = 'Plain smtplib.SMTP() usage; Cycode flags insecure SMTP connections.'
        Fix = 'Prefer SMTP_SSL(), or call starttls() and fail closed before sending. Use Outlook COM if that is approved.'
    }
    [pscustomobject]@{
        Id = 'PY-TLS-VERIFY-FALSE'; Severity = 'CRITICAL'; Exts = @('.py')
        Regex = '\bverify\s*=\s*False\b|\.verify\s*=\s*False\b|CERT_NONE'
        Description = 'TLS certificate verification disabled.'
        Fix = 'Do not disable TLS verification. Use trusted CA bundles or approved corporate TLS configuration.'
    }
    [pscustomobject]@{
        Id = 'PY-INSECURE-DESERIALIZATION'; Severity = 'HIGH'; Exts = @('.py')
        Regex = '\b(pickle\.load|pickle\.loads|dill\.load|dill\.loads|marshal\.load|marshal\.loads|yaml\.load\s*\()'
        Description = 'Potential unsafe deserialization.'
        Fix = 'Do not deserialize untrusted data. Use json, safe_load(), or a schema-validated format.'
    }
    [pscustomobject]@{
        Id = 'PY-SQL-DYNAMIC'; Severity = 'HIGH'; Exts = @('.py')
        Regex = '\.execute\s*\(\s*(f[''\"]|[''\"][^''\"]*(%s|\{)|[a-zA-Z_][\w.]*\s*%)'
        Description = 'SQL execution appears to use string formatting/f-strings.'
        Fix = 'Use parameterized queries; never build SQL by concatenating/formatting user-controlled values.'
    }
    [pscustomobject]@{
        Id = 'PY-FLASK-DEBUG'; Severity = 'HIGH'; Exts = @('.py')
        Regex = '\.run\s*\([^#\n]*debug\s*=\s*True'
        Description = 'Flask debug mode appears enabled.'
        Fix = 'Do not run Flask with debug=True outside controlled local development.'
    }
    [pscustomobject]@{
        Id = 'PY-BIND-ALL-INTERFACES'; Severity = 'HIGH'; Exts = @('.py')
        Regex = 'host\s*=\s*[''\"]0\.0\.0\.0[''\"]|app\.run\s*\([^#\n]*[''\"]0\.0\.0\.0[''\"]'
        Description = 'Server appears to bind to 0.0.0.0.'
        Fix = 'For local tools bind to 127.0.0.1 only. Add authentication before exposing beyond localhost.'
    }
    [pscustomobject]@{
        Id = 'PY-LOGGING-SENSITIVE'; Severity = 'MEDIUM'; Exts = @('.py')
        Regex = '\blogger\.(debug|info|warning|error|exception|critical)\s*\([^#\n]*(records|users?|emails?|recipients?|tokens?|password|session|profile|manager|account|dealer|agency|path|file|snapshot|response\.text|stdout|stderr|traceback|exception)'
        Description = 'Logger call may include sensitive data, paths, Salesforce payloads, recipients, or raw command/API output.'
        Fix = 'At INFO/WARNING/ERROR log counts/status only. Redact sensitive values and avoid full paths/payloads.'
    }
    [pscustomobject]@{
        Id = 'JS-DOM-XSS-HTML-SINK'; Severity = 'HIGH'; Exts = @('.js', '.jsx', '.ts', '.tsx', '.html', '.htm')
        Regex = '(\.innerHTML\s*=|\.outerHTML\s*=|\.insertAdjacentHTML\s*\(|document\.write\s*\(|\.replaceWith\s*\()'
        Description = 'Dynamic HTML insertion sink; possible DOM XSS.'
        Fix = 'Use textContent, createElement/appendChild, or replaceChild(newNode, oldNode). Avoid replaceWith().'
    }
    [pscustomobject]@{
        Id = 'JS-CODE-EXECUTION'; Severity = 'CRITICAL'; Exts = @('.js', '.jsx', '.ts', '.tsx', '.html', '.htm')
        Regex = '\b(eval\s*\(|new\s+Function\s*\(|setTimeout\s*\(\s*[''\"]|setInterval\s*\(\s*[''\"])'
        Description = 'Dynamic JavaScript code execution.'
        Fix = 'Avoid dynamic JS execution. Use function references, allow-listed dispatch, or structured data.'
    }
    [pscustomobject]@{
        Id = 'JS-LOCALSTORAGE-SECRET'; Severity = 'HIGH'; Exts = @('.js', '.jsx', '.ts', '.tsx', '.html', '.htm')
        Regex = ('(localStorage|sessionStorage)\.(setItem|getItem)\s*\([^\n]*(' + $SecretWords + ')')
        Description = 'Potential token/secret stored in browser localStorage/sessionStorage.'
        Fix = 'Do not store secrets/tokens in localStorage. Prefer secure, HttpOnly cookies or server-side session state where applicable.'
    }
    [pscustomobject]@{
        Id = 'JS-INSECURE-FETCH-HTTP'; Severity = 'MEDIUM'; Exts = @('.js', '.jsx', '.ts', '.tsx', '.html', '.htm')
        Regex = '(fetch\s*\(|XMLHttpRequest|axios\.)[^\n]*[''\"]http://(?!localhost|127\.0\.0\.1)'
        Description = 'HTTP URL used in fetch/XMLHttpRequest; confirm it is localhost-only or switch to HTTPS.'
        Fix = 'Use HTTPS for non-local endpoints and avoid sending sensitive data over HTTP.'
    }
    [pscustomobject]@{
        Id = 'HTML-INLINE-EVENT-HANDLER'; Severity = 'MEDIUM'; Exts = @('.html', '.htm')
        Regex = '\son[a-zA-Z]+\s*=\s*[''\"]'
        Description = 'Inline HTML event handler found; increases XSS risk and weakens CSP.'
        Fix = 'Attach event handlers from JavaScript with addEventListener() and keep CSP strict.'
    }
    [pscustomobject]@{
        Id = 'CSS-EXPRESSION'; Severity = 'HIGH'; Exts = @('.css', '.html', '.htm')
        Regex = 'expression\s*\('
        Description = 'Legacy CSS expression() can execute script in old engines and should never be used.'
        Fix = 'Remove CSS expression(). Use standard CSS only.'
    }
    [pscustomobject]@{
        Id = 'CSS-REMOTE-IMPORT-HTTP'; Severity = 'MEDIUM'; Exts = @('.css', '.html', '.htm')
        Regex = '@import[^;]*url\s*\(\s*[''\"]?http://(?!localhost|127\.0\.0\.1)'
        Description = 'CSS imports a non-local HTTP resource.'
        Fix = 'Use HTTPS and approved static assets. Avoid untrusted remote CSS.'
    }
)

# TEACHING NOTE: File inclusion is based on extension, except .env* files are always included.
function Test-IncludedFile {
    param([System.IO.FileInfo]$File)
    if ($File.Name.ToLower().StartsWith('.env')) { return $true }
    return $IncludedExts -contains $File.Extension.ToLower()
}

# TEACHING NOTE: Exclusion is checked against the path below the scan root, not parent folders above it.
function Test-ExcludedPath {
    # ALIGNED (item 8): test only the path relative to root (not ancestor folders
    # above root), and also exclude any segment starting with '.eggs', like Python.
    param([string]$RelativePath)
    $parts = $RelativePath -split '[\\/]+'
    foreach ($part in $parts) {
        if ($ExcludedDirs -contains $part) { return $true }
        if ($part.ToLower().StartsWith('.eggs')) { return $true }
    }
    return $false
}

# TEACHING NOTE: Findings should show relative paths. This helper keeps that behaviour across platforms.
function Get-RelativePathSafe {
    param([string]$BasePath, [string]$ChildPath)

    try {
        return [System.IO.Path]::GetRelativePath($BasePath, $ChildPath)
    }
    catch {
        try {
            $baseFull = [System.IO.Path]::GetFullPath($BasePath)
            $childFull = [System.IO.Path]::GetFullPath($ChildPath)

            if (-not $baseFull.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
                $baseFull += [System.IO.Path]::DirectorySeparatorChar
            }

            $baseUri = New-Object System.Uri($baseFull)
            $childUri = New-Object System.Uri($childFull)
            $relativeUri = $baseUri.MakeRelativeUri($childUri)
            $relativePath = [System.Uri]::UnescapeDataString($relativeUri.ToString())

            return $relativePath -replace '/', [System.IO.Path]::DirectorySeparatorChar
        }
        catch {
            return $ChildPath
        }
    }
}

# TEACHING NOTE: Snippets are redacted before output so likely secrets are not reprinted.
function Protect-Snippet {
    # ALIGNED (item 12): approved PowerShell verb (was 'Sanitize-').
    # ALIGNED (item 4): (?i) on private-key redaction for parity with Python.
    param([string]$Line)
    $s = $Line.Trim()
    $secretRegex = '(?i)\b(' + $SecretWords + ')\b\s*([:=])\s*([''\"])[^''\"]+([''\"])'
    $s = [regex]::Replace($s, $secretRegex, '$1$2$3[REDACTED]$4')
    $s = [regex]::Replace($s, '(?i)-----BEGIN [A-Z ]*PRIVATE KEY-----.*', '-----BEGIN [REDACTED PRIVATE KEY]-----')
    if ($s.Length -gt 220) { $s = $s.Substring(0, 217) + '...' }
    return $s
}

# TEACHING NOTE: All findings use the same object shape so text and JSON output stay consistent.
function Add-Finding {
    param(
        [System.Collections.Generic.List[object]]$Findings,
        [string]$Severity,
        [string]$RuleId,
        [string]$File,
        [int]$Line,
        [string]$Description,
        [string]$Snippet,
        [string]$Recommendation
    )
    $Findings.Add([pscustomobject]@{
        severity       = $Severity
        rule_id        = $RuleId
        file           = $File
        line           = $Line
        description    = $Description
        snippet        = $Snippet
        recommendation = $Recommendation
    }) | Out-Null
}

# ALIGNED (item 9): match Python - print a clear message and exit 2 instead of throwing.
# TEACHING NOTE: A missing root is a controlled user error and exits with code 2.
try {
    $RootPath = (Resolve-Path -Path $Root -ErrorAction Stop).Path
}
catch {
    [Console]::Error.WriteLine("Root path does not exist: $Root")
    exit 2
}
$Findings = [System.Collections.Generic.List[object]]::new()

# TEACHING NOTE: File discovery happens once, then each selected file is scanned in the loop below.
$Files = Get-ChildItem -Path $RootPath -File -Recurse -Force |
    Where-Object {
        $relForExclude = Get-RelativePathSafe -BasePath $RootPath -ChildPath $_.FullName
        (-not (Test-ExcludedPath $relForExclude)) -and (Test-IncludedFile $_)
    }

# TEACHING NOTE: The main scan loop handles generic rules plus requirements and package.json checks.
foreach ($File in $Files) {
    $Rel = Get-RelativePathSafe -BasePath $RootPath -ChildPath $File.FullName
    $Ext = $File.Extension.ToLower()

    if ($File.Name.ToLower().StartsWith('.env') -and $File.Name.ToLower() -ne '.env.example') {
        Add-Finding $Findings 'HIGH' 'SECRET-ENV-FILE' $Rel 1 `
            'Environment file may contain real secrets and should not be committed.' `
            '[filename only]' `
            'Commit .env.example only. Keep real .env files local and ignored by git.'
    }

    # ALIGNED (item 5): report read failures as a LOW finding (Python emits
    # SCAN-READ-ERROR) instead of silently skipping the file.
    try {
        $Lines = @(Get-Content -Path $File.FullName -ErrorAction Stop)
    }
    catch {
        Add-Finding $Findings 'LOW' 'SCAN-READ-ERROR' $Rel 1 `
            "Could not read file: $($_.Exception.Message)" `
            '' `
            'Check file permissions or encoding.'
        continue
    }
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        $Line = [string]$Lines[$i]
        $Trimmed = $Line.Trim()
        if ([string]::IsNullOrWhiteSpace($Trimmed)) { continue }
        $IsComment = $Trimmed.StartsWith('#') -or $Trimmed.StartsWith('//') -or $Trimmed.StartsWith('/*') -or $Trimmed.StartsWith('*') -or $Trimmed.StartsWith('<!--')

        foreach ($Rule in $Rules) {
            if ($null -ne $Rule.Exts -and -not ($Rule.Exts -contains $Ext)) { continue }
            if ($IsComment -and -not $Rule.Id.StartsWith('SECRET')) { continue }
            if ($Line -match $Rule.Regex) {
                Add-Finding $Findings $Rule.Severity $Rule.Id $Rel ($i + 1) $Rule.Description (Protect-Snippet $Line) $Rule.Fix
            }
        }
    }

    if ($File.Name.ToLower().StartsWith('requirements') -and $Ext -eq '.txt') {
        for ($i = 0; $i -lt $Lines.Count; $i++) {
            $Trimmed = ([string]$Lines[$i]).Trim()
            if ([string]::IsNullOrWhiteSpace($Trimmed) -or $Trimmed.StartsWith('#') -or $Trimmed.StartsWith('-r ') -or $Trimmed.StartsWith('--')) { continue }
            if ($Trimmed -notmatch '==' -and $Trimmed -notmatch '\s@\s') {
                Add-Finding $Findings 'MEDIUM' 'DEP-UNPINNED-PIP' $Rel ($i + 1) `
                    'Python dependency is not pinned to an exact version.' `
                    (Protect-Snippet $Trimmed) `
                    'Pin exact versions in requirements files, e.g. package==1.2.3, per repository guidance.'
            }
        }
    }

    if ($File.Name.ToLower() -eq 'package.json') {
        try {
            $Package = Get-Content -Path $File.FullName -Raw | ConvertFrom-Json
            foreach ($Section in @('dependencies', 'devDependencies', 'optionalDependencies')) {
                $Deps = $Package.$Section
                if ($null -eq $Deps) { continue }
                foreach ($Prop in $Deps.PSObject.Properties) {
                    $Name = $Prop.Name
                    # ALIGNED (item 11): trim ONCE, then run every comparison on the
                    # trimmed value, so a leading-space value like "  ^1.2.3" is not
                    # missed. Python trims here too. Trimmed value also feeds snippet.
                    $Version = ([string]$Prop.Value).Trim()
                    if ($Version -in @('*', 'latest') -or $Version.StartsWith('^') -or $Version.StartsWith('~') -or $Version.StartsWith('>') -or $Version.StartsWith('<')) {
                        Add-Finding $Findings 'MEDIUM' 'DEP-UNPINNED-NPM' $Rel 1 `
                            "NPM dependency in $Section is not exactly pinned: $Name" `
                            "$Name`: $Version" `
                            'Prefer lockfiles and exact pinned versions for reproducible builds; review supply-chain risk.'
                    }
                }
            }
        }
        catch {
            # Ignore malformed package.json here; normal build tooling will catch it.
        }
    }
}

# TEACHING NOTE: Sorting is deterministic so repeated scans are easier to compare.
$Sorted = $Findings | Sort-Object @{ Expression = { -1 * $SeverityOrder[$_.severity] } }, file, line, rule_id

# TEACHING NOTE: JSON output is forced to be an array, even for zero or one finding.
if ($Format -eq 'Json') {
    # ALIGNED (item 6): always emit a JSON ARRAY like Python. Windows PowerShell 5.1
    # unwraps single-element arrays and emits nothing for empty, so force the shape.
    if ($Sorted.Count -eq 0) {
        $Json = '[]'
    }
    elseif ($Sorted.Count -eq 1) {
        $Json = '[' + ($Sorted[0] | ConvertTo-Json -Depth 5) + ']'
    }
    else {
        $Json = $Sorted | ConvertTo-Json -Depth 5
    }
    if ($Output) { Set-Content -Path $Output -Value $Json -Encoding UTF8 } else { $Json }
}
else {
    $LinesOut = [System.Collections.Generic.List[string]]::new()
    if ($Sorted.Count -eq 0) {
        $LinesOut.Add('No high-risk security patterns found by local regex scan.') | Out-Null
    }
    else {
        foreach ($Finding in $Sorted) {
            $LinesOut.Add("[$($Finding.severity)] $($Finding.rule_id) $($Finding.file):$($Finding.line)") | Out-Null
            $LinesOut.Add("  $($Finding.description)") | Out-Null
            if ($Finding.snippet) { $LinesOut.Add("  Code: $($Finding.snippet)") | Out-Null }
            $LinesOut.Add("  Fix:  $($Finding.recommendation)") | Out-Null
            $LinesOut.Add('') | Out-Null
        }
        $LinesOut.Add('Summary:') | Out-Null
        foreach ($Sev in @('CRITICAL', 'HIGH', 'MEDIUM', 'LOW')) {
            $Count = @($Findings | Where-Object { $_.severity -eq $Sev }).Count
            $LinesOut.Add("  $Sev`: $Count") | Out-Null
        }
        $LinesOut.Add("  TOTAL: $($Findings.Count)") | Out-Null
    }

    if ($Output) { Set-Content -Path $Output -Value $LinesOut -Encoding UTF8 } else { $LinesOut | ForEach-Object { Write-Host $_ } }
}

# TEACHING NOTE: The final block converts findings into the script exit code.
if ($FailOn -ne 'NONE') {
    $Threshold = $SeverityOrder[$FailOn]
    $ShouldFail = $false
    foreach ($Finding in $Findings) {
        if ($SeverityOrder[$Finding.severity] -ge $Threshold) { $ShouldFail = $true; break }
    }
    if ($ShouldFail) { exit 1 }
}

exit 0

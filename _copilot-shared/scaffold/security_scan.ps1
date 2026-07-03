<#
.SYNOPSIS
  Local high-risk security pattern scanner for this repo.

.DESCRIPTION
  Fast pre-PR scan for issues historically flagged by Cycode and common OWASP/CWE
  secure-coding mistakes in Python / JavaScript / HTML / CSS.

  This is intentionally regex-based and conservative. It will produce some false
  positives; review findings before changing code. It does not replace Cycode,
  CodeQL, Semgrep, Bandit, pip-audit, or Ford's approved security process.

.EXAMPLES
  powershell -ExecutionPolicy Bypass -File .\security_scan.ps1
  powershell -ExecutionPolicy Bypass -File .\security_scan.ps1 -Root . -FailOn HIGH
  powershell -ExecutionPolicy Bypass -File .\security_scan.ps1 -Format Json -Output security_findings.json
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

$SeverityOrder = @{
    LOW      = 1
    MEDIUM   = 2
    HIGH     = 3
    CRITICAL = 4
}

$ExcludedDirs = @(
    '.git', '.hg', '.svn', '.venv', 'venv', 'env', 'node_modules',
    '__pycache__', '.pytest_cache', '.mypy_cache', '.ruff_cache', '.tox',
    'dist', 'build', 'coverage', 'htmlcov', '.idea'
)

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

# NOTE: This is a list of secret-ish KEYWORD NAMES the scanner searches for,
# not an actual secret. The inline pragma tells detect-secrets to ignore this
# line so the scanner stays clean when it is synced into a project whose
# pre-commit gate runs detect-secrets.
$SecretWords = 'api[_-]?key|secret|token|password|passwd|pwd|session[_-]?id|client[_-]?secret|private[_-]?key|access[_-]?token|refresh[_-]?token'  # pragma: allowlist secret

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
        Regex = '(?<![\w.])(eval|exec|compile)\s*\('
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

function Test-IncludedFile {
    param([System.IO.FileInfo]$File)
    if ($File.Name.ToLower().StartsWith('.env')) { return $true }
    return $IncludedExts -contains $File.Extension.ToLower()
}

function Test-OwnScannerFile {
    # Why this exists: this scanner's rule table literally contains the code
    # patterns it hunts for (e.g. the text 'eval(' and 'verify=False' appear as
    # regex strings). If it scans its own source, each rule string is reported
    # as a false-positive finding. The shared sync copies this scanner into
    # every project root, so it must skip its own files wherever it runs. A real
    # project would never legitimately name a file 'security_scan*'.
    param([string]$Name)
    $lower = $Name.ToLower()
    return $lower.StartsWith('security_scan') -or ($lower -eq 'create_security_scan_pack.py')
}

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
try {
    $RootPath = (Resolve-Path -Path $Root -ErrorAction Stop).Path
}
catch {
    [Console]::Error.WriteLine("Root path does not exist: $Root")
    exit 2
}

# Validate the optional -Output path BEFORE any file is written. The value comes
# from the command line (untrusted input), so we contain it inside the current
# directory to block path traversal or an absolute path escaping elsewhere. The
# trailing separator on the base defeats a sibling like "<cwd>-evil" that a plain
# StartsWith without a separator would wrongly accept. Windows PowerShell 5.1 has
# no Path.is_relative_to, so GetFullPath + separator-anchored prefix is the
# genuine containment equivalent.
$SafeOutput = ''
if ($Output) {
    $OutputBase = (Get-Location).Path
    $ResolvedOutput = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($OutputBase, $Output))
    $BaseWithSep = $OutputBase.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    if (-not $ResolvedOutput.StartsWith($BaseWithSep, [System.StringComparison]::OrdinalIgnoreCase)) {
        [Console]::Error.WriteLine("Output path escapes base directory: $Output")
        exit 2
    }
    $SafeOutput = $ResolvedOutput
}

$Findings = [System.Collections.Generic.List[object]]::new()

$Files = Get-ChildItem -Path $RootPath -File -Recurse -Force |
    Where-Object {
        $relForExclude = Get-RelativePathSafe -BasePath $RootPath -ChildPath $_.FullName
        (-not (Test-ExcludedPath $relForExclude)) -and (Test-IncludedFile $_) -and (-not (Test-OwnScannerFile $_.Name))
    }

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

$Sorted = $Findings | Sort-Object @{ Expression = { -1 * $SeverityOrder[$_.severity] } }, file, line, rule_id

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
    if ($Output) { Set-Content -Path $SafeOutput -Value $Json -Encoding UTF8 } else { $Json }
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

    if ($Output) { Set-Content -Path $SafeOutput -Value $LinesOut -Encoding UTF8 } else { $LinesOut | ForEach-Object { Write-Host $_ } }
}

if ($FailOn -ne 'NONE') {
    $Threshold = $SeverityOrder[$FailOn]
    $ShouldFail = $false
    foreach ($Finding in $Findings) {
        if ($SeverityOrder[$Finding.severity] -ge $Threshold) { $ShouldFail = $true; break }
    }
    if ($ShouldFail) { exit 1 }
}

exit 0

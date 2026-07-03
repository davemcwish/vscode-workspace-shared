# Security Scan Beginner Walkthrough

## What this scanner is

This scanner is a local pre-review helper. It looks for patterns that are often
security-sensitive, such as hard-coded secrets, shell execution, unsafe dynamic
code execution, disabled TLS verification, risky browser HTML sinks, and loose
dependency versions.

It is intentionally simple:

- It walks files.
- It checks lines with regex rules.
- It reports findings.
- It redacts likely secrets.
- It exits with a useful status code.

It does not prove that a repository is safe.

## How to run the Python scanner

```bash
python security_scan.py
python security_scan.py --root . --format text --fail-on HIGH
python security_scan.py --format json --output security_findings.json
python security_scan.py --include-ext .ps1
```

## How to run the PowerShell scanner

```powershell
powershell -ExecutionPolicy Bypass -File .\security_scan.ps1
powershell -ExecutionPolicy Bypass -File .\security_scan.ps1 -Root . -FailOn HIGH
powershell -ExecutionPolicy Bypass -File .\security_scan.ps1 -Format Json -Output security_findings.json
powershell -ExecutionPolicy Bypass -File .\security_scan.ps1 -IncludeExt .ps1
```

## How output is sorted

Findings are sorted by:

1. severity, highest first,
2. file,
3. line,
4. rule id.

This makes repeated scan output easier to compare.

## What severities mean

- CRITICAL: likely severe issue, such as private keys, eval, shell=True, or TLS verification disabled.
- HIGH: serious issue requiring review, such as hard-coded secrets or unsafe subprocess patterns.
- MEDIUM: risky practice or dependency hygiene issue.
- LOW: scanner operational issue, such as a file read error.

## How to review findings

For each finding:

1. Read the rule id.
2. Open the file and line.
3. Decide whether the finding is real.
4. If real, apply the recommended fix.
5. If false positive, document why.

## Common false positives

Regex scanners do not understand full program context. A line can match because
it appears in a test, a sample, a comment, or a harmless string. Review before
changing code.

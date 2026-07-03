# Security Scan Student Cheat Sheet

## Commands

Python:

```bash
python security_scan.py
python security_scan.py --root . --format json
python security_scan.py --fail-on MEDIUM
python security_scan.py --fail-on NONE
python security_scan.py --include-ext .ps1
```

PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\security_scan.ps1
powershell -ExecutionPolicy Bypass -File .\security_scan.ps1 -Format Json
powershell -ExecutionPolicy Bypass -File .\security_scan.ps1 -FailOn MEDIUM
powershell -ExecutionPolicy Bypass -File .\security_scan.ps1 -FailOn NONE
powershell -ExecutionPolicy Bypass -File .\security_scan.ps1 -IncludeExt .ps1
```

## What to look for

Each finding includes:

- severity,
- rule id,
- file,
- line,
- description,
- redacted code snippet,
- recommendation.

## Exercise 1

Create a test file containing a fake hard-coded password. Run the scanner. What
rule id appears?

## Exercise 2

Create requirements.txt with this line:

```text
requests
```

Run the scanner. What dependency rule appears?

## Exercise 3

Create package.json with this dependency:

```json
{
  "dependencies": {
    "demo": "^1.2.3"
  }
}
```

Run the scanner. Why is this flagged?

## Exercise 4

Run with `--fail-on NONE` or `-FailOn NONE`. What changes?

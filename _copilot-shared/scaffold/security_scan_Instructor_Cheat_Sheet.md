# Security Scan Instructor Cheat Sheet

## Teaching goals

Students should understand:

- why local security scanning is useful,
- how the scanner walks files,
- how rules are represented,
- how findings are redacted,
- how dependency checks differ from regex checks,
- how exit codes support automation,
- and why false positives require human review.

## Suggested lesson flow

1. Run the scanner on a clean folder.
2. Add a sample hard-coded secret and rerun.
3. Add a requirements.txt with an unpinned package.
4. Add a package.json with a caret version.
5. Compare text and JSON output.
6. Discuss false positives and remediation.

## Key concepts

- Rule: reusable regex plus metadata.
- Finding: one reported issue.
- Severity threshold: controls whether the process fails.
- Redaction: prevents likely secrets from being printed.
- Deterministic sorting: keeps output stable.
- Parity: Python and PowerShell versions are aligned as closely as practical.

## Discussion prompts

- Why should .env files be scanned even though .env is listed as an extension?
- Why is shell=True dangerous?
- Why does JSON output need to always be an array?
- Why might two regex engines behave slightly differently?
- Why should scan output be reviewed before code is changed?

## Quick assessment

Ask students to explain:

1. What happens when the root path does not exist.
2. Why .env.example is handled differently from .env.
3. Why dependency ranges are flagged.
4. What exit code 1 means.
5. What exit code 2 means.

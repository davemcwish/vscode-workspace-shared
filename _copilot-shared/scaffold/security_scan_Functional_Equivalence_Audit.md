# Security Scan Functional Equivalence Audit

## Scope

This audit compares the aligned Python and PowerShell scanners at the behaviour
level. Exact byte-for-byte equivalence is not promised because Python regex and
.NET regex are different engines.

## Alignment decisions

| Item | Decision |
|---|---|
| 1 | .ps1 is not scanned by default. Both tools can include it explicitly. |
| 2 | PowerShell has -IncludeExt to mirror Python --include-ext. |
| 3 | .env matching is broad: .env and any filename starting with .env. |
| 4 | Private-key detection and redaction are case-insensitive. |
| 5 | Read errors produce LOW SCAN-READ-ERROR findings. |
| 6 | JSON output is always an array. |
| 7 | Text and JSON output use deterministic sorting. |
| 8 | Directory exclusion applies below the scan root and includes .eggs*. |
| 9 | Bad root path prints a message and exits with code 2. |
| 10 | requirements checks treat whitespace-at-whitespace direct references consistently. |
| 11 | package.json versions are trimmed before comparisons. |
| 12 | PowerShell snippet redaction function uses an approved verb: Protect-Snippet. |

## Known residual differences

1. Regex engine details can differ between Python and .NET.
2. Line splitting can differ for unusual Unicode line separators.
3. Encoding behaviour can differ on unusual non-UTF-8 files.
4. Console rendering can differ by shell and platform.

## Practical conclusion

For normal source files, UTF-8 text, and the rule patterns in this scanner, the
two implementations are aligned closely enough for teaching, local pre-review,
and deterministic comparison.

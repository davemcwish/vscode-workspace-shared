#!/usr/bin/env python3
"""
Build the security scan teaching pack from the finalized source scripts.

Run from the folder containing:
  security_scan.py
  security_scan.ps1

Creates:
  security_scan_teaching_docstrings.py
  security_scan_teaching_comments.ps1
  security_scan_beginner_walkthrough.md
  security_scan_Instructor_Cheat_Sheet.md
  security_scan_Student_Cheat_Sheet.md
  security_scan_Student_Cheat_Sheet_ANSWER_KEY.md
  security_scan_Functional_Equivalence_Audit.md
"""

from __future__ import annotations

import re
from pathlib import Path
from textwrap import dedent


ROOT = Path.cwd()
PY_IN = ROOT / "security_scan.py"
PS_IN = ROOT / "security_scan.ps1"


def read_required(path: Path) -> str:
    if not path.exists():
        raise SystemExit(f"Missing required input file: {path}")
    return path.read_text(encoding="utf-8")


def write_output(name: str, content: str) -> None:
    output_path = ROOT / name
    output_path.write_text(content.rstrip() + "\n", encoding="utf-8")
    print(f"Created: {name}")


def assert_contains(source: str, needle: str, label: str) -> None:
    if needle not in source:
        raise SystemExit(f"Input check failed: {label}")


def assert_ascii(name: str, content: str) -> None:
    try:
        content.encode("ascii")
    except UnicodeEncodeError as exc:
        raise SystemExit(f"{name} is not ASCII-only: {exc}") from exc


def check_inputs(py: str, ps: str) -> None:
    assert_contains(py, 'path.name.lower().startswith(".env")', "Python broad .env* matching")
    assert_contains(py, "flags=re.IGNORECASE", "Python private-key case-insensitive rule")
    assert_contains(py, "def sort_findings", "Python deterministic sort helper")
    assert_contains(py, "sort_findings(findings)", "Python sorted output usage")
    assert_contains(py, "version = version.strip()", "Python package.json trim")
    assert_contains(py, "ext.lower() if ext.startswith", "Python include-ext lowercase normalization")

    assert_contains(ps, "[string[]]$IncludeExt = @()", "PowerShell IncludeExt parameter")
    assert_contains(ps, "@(Get-Content -Path $File.FullName -ErrorAction Stop)", "PowerShell line-array Get-Content")
    assert_contains(ps, "MakeRelativeUri", "PowerShell relative path fallback")
    assert_contains(ps, "$Version = ([string]$Prop.Value).Trim()", "PowerShell package.json trim")
    assert_contains(ps, "$Json = '[]'", "PowerShell empty JSON array")
    assert_contains(ps, "$Sorted[0] | ConvertTo-Json -Depth 5", "PowerShell single finding JSON array")


PY_MODULE_DOC = '''"""
Teaching version of the local high-risk security pattern scanner.

This file keeps the scanner's executable behaviour aligned with security_scan.py
and adds explanatory docstrings for learning and review. The comments and
docstrings are intended to help a new maintainer understand the scanner without
changing its scanning decisions.

What this scanner does:
  - Walks a repository tree.
  - Skips common generated, virtual environment, and dependency directories.
  - Scans selected text/source file types for high-risk regex patterns.
  - Adds special dependency checks for requirements*.txt and package.json.
  - Redacts likely secret values before printing snippets.
  - Exits non-zero when findings meet or exceed the configured fail threshold.

What this scanner does not do:
  - It is not a full static analysis engine.
  - It is not a replacement for approved security review tooling.
  - It is intentionally conservative and can produce false positives.
  - It does not prove that a repository is secure.

Typical usage:
  python security_scan_teaching_docstrings.py
  python security_scan_teaching_docstrings.py --root . --format text --fail-on HIGH
  python security_scan_teaching_docstrings.py --format json --output security_findings.json
  python security_scan_teaching_docstrings.py --include-ext .ps1
"""'''


CLASS_DOCS = {
    "Rule": """
Describe one regex-based scanning rule.

Each rule has a stable rule id, severity, human-readable description, compiled
regex pattern, optional extension allow-list, and recommended remediation text.
""",
    "Finding": """
Represent one scanner result.

A finding is what appears in text or JSON output. It records severity, rule id,
relative file path, line number, description, redacted snippet, and fix guidance.
""",
}


FUNCTION_DOCS = {
    "compile_rule": """
Build a Rule object from plain rule metadata.

Most rules use case-insensitive matching by default. Individual rules can pass a
different regex flag value when exact behaviour is needed.
""",
    "should_scan_file": """
Return True when a file should be scanned.

The extension list handles normal source/config files. Files whose names start
with .env are always included so .env, .env.local, .env.backup, and similar files
are checked consistently with the PowerShell version.
""",
    "iter_files": """
Yield scan-eligible files under the root directory.

The walk prunes excluded directories before descending into them. This avoids
scanning dependency folders, build outputs, caches, and Python .eggs folders.
""",
    "sanitize_snippet": """
Redact likely secret values from a single output snippet.

The scanner reports enough context to help a reviewer find the issue, but it
tries not to print raw credentials, tokens, passwords, or private key contents.
""",
    "scan_file": """
Scan one file using filename checks and the generic regex rule table.

This function handles .env* filename findings, read errors, comment suppression
for noisy non-secret rules, regex matching, and finding creation.
""",
    "scan_requirements": """
Apply Python dependency pinning checks to requirements*.txt files.

Blank lines, comments, recursive includes, and command-style options are skipped.
A dependency is considered pinned if it uses == or a whitespace-separated direct
reference marker such as package @ location.
""",
    "scan_package_json": """
Apply NPM dependency pinning checks to package.json.

The scanner checks dependencies, devDependencies, and optionalDependencies. It
flags wildcard, latest, range, greater-than, and less-than style versions.
""",
    "severity_at_or_above": """
Return True when a finding severity meets or exceeds a configured threshold.

This is used to decide whether the process should exit with code 1.
""",
    "sort_findings": """
Return findings in deterministic reporting order.

Both text and JSON output use this same order: severity descending, file path,
line number, then rule id.
""",
    "print_text": """
Print findings in the human-readable text format.

The output includes finding details, redacted snippets where available, suggested
fixes, and a summary by severity.
""",
    "main": """
Parse command-line arguments, run the scan, write output, and return an exit code.

Exit codes:
  - 0 means no finding met the fail threshold.
  - 1 means at least one finding met the fail threshold.
  - 2 means the requested root path did not exist.
""",
}


def replace_python_module_docstring(source: str) -> str:
    pattern = r'\A(#![^\n]*\n)?""".*?"""'

    def replacement(match: re.Match[str]) -> str:
        return (match.group(1) or "") + PY_MODULE_DOC

    new_source, count = re.subn(pattern, replacement, source, count=1, flags=re.S)
    if count != 1:
        raise SystemExit("Could not replace Python module docstring")
    return new_source


def add_class_docstring(source: str, class_name: str, doc: str) -> str:
    lines = source.splitlines(keepends=True)
    target = f"class {class_name}:"

    for index, line in enumerate(lines):
        if line.strip() == target:
            if index + 1 < len(lines) and lines[index + 1].lstrip().startswith('"""'):
                return source

            indent = "    "
            block = [indent + '"""\n']
            block += [indent + part.rstrip() + "\n" for part in doc.strip().splitlines()]
            block += [indent + '"""\n']
            lines[index + 1:index + 1] = block
            return "".join(lines)

    raise SystemExit(f"Could not find class {class_name}")


def add_function_docstring(source: str, function_name: str, doc: str) -> str:
    lines = source.splitlines(keepends=True)
    start_prefix = f"def {function_name}("

    for index, line in enumerate(lines):
        if not line.startswith(start_prefix):
            continue

        balance = 0
        signature_end = index

        while signature_end < len(lines):
            balance += lines[signature_end].count("(") - lines[signature_end].count(")")
            if balance <= 0 and lines[signature_end].strip().endswith(":"):
                break
            signature_end += 1

        if signature_end >= len(lines):
            raise SystemExit(f"Could not find end of signature for {function_name}")

        if signature_end + 1 < len(lines) and lines[signature_end + 1].lstrip().startswith('"""'):
            return source

        indent = "    "
        block = [indent + '"""\n']
        block += [indent + part.rstrip() + "\n" for part in doc.strip().splitlines()]
        block += [indent + '"""\n']
        lines[signature_end + 1:signature_end + 1] = block
        return "".join(lines)

    raise SystemExit(f"Could not find function {function_name}")


def make_python_teaching(py: str) -> str:
    py = replace_python_module_docstring(py)

    for class_name, doc in CLASS_DOCS.items():
        py = add_class_docstring(py, class_name, doc)

    for function_name, doc in FUNCTION_DOCS.items():
        py = add_function_docstring(py, function_name, doc)

    return py

PS_HELP = dedent(r'''
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
''').strip()


def before_once(source: str, marker: str, comment: str) -> str:
    first_comment_line = comment.strip().splitlines()[0]

    if first_comment_line in source:
        return source

    if marker not in source:
        raise SystemExit(f"Could not find PowerShell marker: {marker}")

    return source.replace(marker, comment.rstrip() + "\n" + marker, 1)


def make_powershell_teaching(ps: str) -> str:
    ps, count = re.subn(
        r"\A<#.*?#>",
        lambda match: PS_HELP,
        ps,
        count=1,
        flags=re.S,
    )

    if count != 1:
        raise SystemExit("Could not replace PowerShell help block")

    inserts = [
        (
            "$SeverityOrder = @{",
            "# TEACHING NOTE: Severity values are numeric so sorting and threshold comparisons are simple.",
        ),
        (
            "$ExcludedDirs = @(",
            "# TEACHING NOTE: These folders are skipped to avoid dependencies, caches, build output, and generated files.",
        ),
        (
            "$IncludedExts = @(",
            "# TEACHING NOTE: This is the default scan scope. Extra extensions can be added with -IncludeExt.",
        ),
        (
            "$Rules = @(",
            "# TEACHING NOTE: Each rule is data: id, severity, extension scope, regex, description, and fix guidance.",
        ),
        (
            "function Test-IncludedFile {",
            "# TEACHING NOTE: File inclusion is based on extension, except .env* files are always included.",
        ),
        (
            "function Test-ExcludedPath {",
            "# TEACHING NOTE: Exclusion is checked against the path below the scan root, not parent folders above it.",
        ),
        (
            "function Get-RelativePathSafe {",
            "# TEACHING NOTE: Findings should show relative paths. This helper keeps that behaviour across platforms.",
        ),
        (
            "function Protect-Snippet {",
            "# TEACHING NOTE: Snippets are redacted before output so likely secrets are not reprinted.",
        ),
        (
            "function Add-Finding {",
            "# TEACHING NOTE: All findings use the same object shape so text and JSON output stay consistent.",
        ),
        (
            "try {\n    $RootPath = (Resolve-Path",
            "# TEACHING NOTE: A missing root is a controlled user error and exits with code 2.",
        ),
        (
            "$Files = Get-ChildItem",
            "# TEACHING NOTE: File discovery happens once, then each selected file is scanned in the loop below.",
        ),
        (
            "foreach ($File in $Files) {",
            "# TEACHING NOTE: The main scan loop handles generic rules plus requirements and package.json checks.",
        ),
        (
            "$Sorted = $Findings | Sort-Object",
            "# TEACHING NOTE: Sorting is deterministic so repeated scans are easier to compare.",
        ),
        (
            "if ($Format -eq 'Json') {",
            "# TEACHING NOTE: JSON output is forced to be an array, even for zero or one finding.",
        ),
        (
            "if ($FailOn -ne 'NONE') {",
            "# TEACHING NOTE: The final block converts findings into the script exit code.",
        ),
    ]

    for marker, comment in inserts:
        ps = before_once(ps, marker, comment)

    return ps


WALKTHROUGH = dedent(r"""
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
""").strip()


INSTRUCTOR = dedent(r"""
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
""").strip()


STUDENT = dedent(r"""
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
""").strip()


ANSWER_KEY = dedent(r"""
# Security Scan Student Cheat Sheet Answer Key

## Exercise 1

A fake hard-coded password should trigger:

```text
SECRET-HARDCODED
```

The exact result depends on whether the value looks secret-like and is long
enough to match the rule.

## Exercise 2

An unpinned requirements.txt line such as `requests` should trigger:

```text
DEP-UNPINNED-PIP
```

A pinned version would look like:

```text
requests==2.32.0
```

## Exercise 3

A package.json dependency such as `"demo": "^1.2.3"` should trigger:

```text
DEP-UNPINNED-NPM
```

The caret means the version is a range, not an exact pin.

## Exercise 4

With fail-on disabled, findings can still be printed, but the script should not
exit with code 1 because of finding severity. This is useful for learning or
report-only runs.
""").strip()


AUDIT = dedent(r"""
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
""").strip()


def main() -> int:
    py = read_required(PY_IN)
    ps = read_required(PS_IN)

    check_inputs(py, ps)

    py_teaching = make_python_teaching(py)
    ps_teaching = make_powershell_teaching(ps)

    markdown_files = {
        "security_scan_beginner_walkthrough.md": WALKTHROUGH,
        "security_scan_Instructor_Cheat_Sheet.md": INSTRUCTOR,
        "security_scan_Student_Cheat_Sheet.md": STUDENT,
        "security_scan_Student_Cheat_Sheet_ANSWER_KEY.md": ANSWER_KEY,
        "security_scan_Functional_Equivalence_Audit.md": AUDIT,
    }

    for name, content in markdown_files.items():
        assert_ascii(name, content)

    write_output("security_scan_teaching_docstrings.py", py_teaching)
    write_output("security_scan_teaching_comments.ps1", ps_teaching)

    for name, content in markdown_files.items():
        write_output(name, content)

    print()
    print("Pack complete.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

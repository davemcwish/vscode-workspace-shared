#!/usr/bin/env python3
"""
Local high-risk security pattern scanner for this repo.

Purpose:
  Fast pre-PR scan for the kinds of issues historically flagged by Cycode and
  common OWASP/CWE secure-coding mistakes in Python / JavaScript / HTML / CSS.

Notes:
  - This is intentionally conservative and regex-based. It will produce some
    false positives; review findings before changing code.
  - It does NOT replace Cycode, CodeQL, Semgrep, Bandit, pip-audit, or Ford's
    approved security review process.
  - It avoids printing raw likely-secret values in output.
  - This script is a sibling implementation to security_scan.ps1. The two are
    aligned to behave as closely as two regex engines allow, but are not
    guaranteed byte-for-byte identical.

Usage:
  python security_scan.py
  python security_scan.py --root . --format text --fail-on HIGH
  python security_scan.py --root . --format json --output security_findings.json
  python security_scan.py --include-ext .ps1
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable

SEVERITY_ORDER = {"LOW": 1, "MEDIUM": 2, "HIGH": 3, "CRITICAL": 4}

DEFAULT_EXCLUDED_DIRS = {
    ".git", ".hg", ".svn", ".venv", "venv", "env", "node_modules",
    "__pycache__", ".pytest_cache", ".mypy_cache", ".ruff_cache", ".tox",
    "dist", "build", "coverage", "htmlcov", ".idea",
}

DEFAULT_INCLUDED_EXTS = {
    ".py", ".js", ".jsx", ".ts", ".tsx", ".html", ".htm", ".css",
    ".md", ".json", ".yml", ".yaml", ".toml", ".cfg", ".ini", ".txt", ".env",
}

# NOTE: This is a list of secret-ish KEYWORD NAMES the scanner searches for,
# not an actual secret. The inline pragma keeps detect-secrets from flagging
# this line when the scanner is synced into a project whose gate runs
# detect-secrets (its PowerShell twin is flagged without the pragma).
SECRETISH_WORDS = r"api[_-]?key|secret|token|password|passwd|pwd|session[_-]?id|client[_-]?secret|private[_-]?key|access[_-]?token|refresh[_-]?token"  # pragma: allowlist secret


@dataclass(frozen=True)
class Rule:
    rule_id: str
    severity: str
    description: str
    pattern: re.Pattern[str]
    extensions: set[str] | None = None
    recommendation: str = "Review and apply security.instructions.md."


@dataclass
class Finding:
    severity: str
    rule_id: str
    file: str
    line: int
    description: str
    snippet: str
    recommendation: str


def compile_rule(
    rule_id: str,
    severity: str,
    description: str,
    regex: str,
    exts: Iterable[str] | None = None,
    flags: int = re.IGNORECASE,
    recommendation: str = "Review and apply security.instructions.md.",
) -> Rule:
    return Rule(
        rule_id=rule_id,
        severity=severity,
        description=description,
        pattern=re.compile(regex, flags),
        extensions=set(exts) if exts else None,
        recommendation=recommendation,
    )

RULES: list[Rule] = [
    # Secrets / credentials
    compile_rule(
        "SECRET-HARDCODED",
        "HIGH",
        "Possible hard-coded secret, token, password, or session id.",
        rf"\b({SECRETISH_WORDS})\b\s*[:=]\s*['\"](?!\s*(?:<|your-|placeholder|example|changeme|dummy|test|none|null))[^'\"]{{8,}}['\"]",
        None,
        recommendation="Move secrets to approved secret storage or environment variables; commit only placeholders in .env.example.",
    ),
    compile_rule(
        "SECRET-PRIVATE-KEY",
        "CRITICAL",
        "Private key material appears to be present.",
        r"-----BEGIN [A-Z ]*PRIVATE KEY-----",
        None,
        # ALIGNED (item 4): was flags=0 (case-sensitive). Now IGNORECASE to match
        # PowerShell's -match, which is case-insensitive by default.
        flags=re.IGNORECASE,
        recommendation="Remove the key, rotate it, and use the approved secrets manager.",
    ),
    # Python subprocess / code execution
    compile_rule(
        "PY-SUBPROCESS-SHELL-TRUE",
        "CRITICAL",
        "subprocess call uses shell=True.",
        r"\bsubprocess\.(run|Popen|call|check_call|check_output)\s*\([^#\n]*shell\s*=\s*True",
        {".py"},
        recommendation="Use subprocess with a list, shell=False, literal command parts, and validated arguments.",
    ),
    compile_rule(
        "PY-OS-SYSTEM",
        "CRITICAL",
        "Shell command execution via os.system/os.popen/commands.getoutput.",
        r"\b(os\.system|os\.popen|commands\.getoutput|commands\.getstatusoutput)\s*\(",
        {".py"},
        recommendation="Replace with subprocess.run([...], shell=False) and allow-list validated inputs.",
    ),
    compile_rule(
        "PY-SUBPROCESS-STRING-COMMAND",
        "HIGH",
        "subprocess appears to receive a string/f-string command rather than a safe argument list.",
        r"\bsubprocess\.(run|Popen|call|check_call|check_output)\s*\(\s*(f?['\"]|[a-zA-Z_][\w.]*\s*\+)",
        {".py"},
        recommendation="Pass a list of arguments; validate executable with validate_subprocess_command(); validate dynamic args locally.",
    ),
    compile_rule(
        "PY-EVAL-EXEC",
        "CRITICAL",
        "Dynamic Python code execution via eval/exec/compile.",
        r"(?<![\w.])(eval|exec|compile)\s*\(",
        {".py"},
        recommendation="Avoid dynamic code execution. Use allow-listed functions or data-driven dispatch tables.",
    ),
    # Python file paths / archive / XML
    compile_rule(
        "PY-DYNAMIC-OPEN",
        "MEDIUM",
        "open() appears to use a non-literal path; ensure resolve_safe_path() and local re-validation are used.",
        r"(?<![\w.])open\s*\(\s*(?!['\"])",
        {".py"},
        recommendation="Use resolve_safe_path(), assign safe_path, and pass only the validated path into file I/O.",
    ),
    compile_rule(
        "PY-TEMPFILE-DYNAMIC-PREFIX",
        "HIGH",
        "NamedTemporaryFile prefix appears dynamic; Cycode flags tainted temp filename prefixes.",
        r"\bNamedTemporaryFile\s*\([^#\n]*prefix\s*=\s*(?!['\"])",
        {".py"},
        recommendation="Use a fixed literal prefix, e.g. prefix='report_attachment_'. Do not derive temp filenames from attachment names.",
    ),
    compile_rule(
        "PY-ZIP-EXTRACTALL",
        "HIGH",
        "ZipFile.extractall() can allow ZIP Slip path traversal if archive members are untrusted.",
        r"\.extractall\s*\(",
        {".py"},
        recommendation="Validate every ZIP member destination stays under the intended target directory before extracting.",
    ),
    compile_rule(
        "PY-XML-STDLIB",
        "HIGH",
        "Python standard-library XML parser usage; may be vulnerable to hostile XML payloads.",
        r"(from\s+xml\.etree\s+import|import\s+xml\.etree|xml\.etree\.ElementTree|\bET\.parse\s*\()",
        {".py"},
        recommendation="Use defusedxml.ElementTree for XML parsing, especially for files influenced by users or external systems.",
    ),
    # Python crypto/random/network
    compile_rule(
        "PY-WEAK-PRNG",
        "HIGH",
        "Use of random.* or random.Random(); not suitable for security-sensitive randomness and historically flagged by Cycode.",
        r"\brandom\.(Random\s*\(|random\s*\(|randint\s*\(|randrange\s*\(|choice\s*\(|choices\s*\(|shuffle\s*\(|sample\s*\()",
        {".py"},
        recommendation="For secrets use secrets.*. For non-security randomness use SystemRandom() or deterministic index-based selection.",
    ),
    compile_rule(
        "PY-INSECURE-SMTP",
        "HIGH",
        "Plain smtplib.SMTP() usage; Cycode flags insecure SMTP connections.",
        r"\bsmtplib\.SMTP\s*\(",
        {".py"},
        recommendation="Prefer SMTP_SSL(), or call starttls() and fail closed before sending. Use Outlook COM if that is the approved path.",
    ),
    compile_rule(
        "PY-TLS-VERIFY-FALSE",
        "CRITICAL",
        "TLS certificate verification disabled.",
        r"\bverify\s*=\s*False\b|\.verify\s*=\s*False\b|CERT_NONE",
        {".py"},
        recommendation="Do not disable TLS verification. Use trusted CA bundles or approved corporate TLS configuration.",
    ),
    compile_rule(
        "PY-INSECURE-DESERIALIZATION",
        "HIGH",
        "Potential unsafe deserialization.",
        r"\b(pickle\.load|pickle\.loads|dill\.load|dill\.loads|marshal\.load|marshal\.loads|yaml\.load\s*\()",
        {".py"},
        recommendation="Do not deserialize untrusted data. Use json, safe_load(), or a schema-validated format.",
    ),
    compile_rule(
        "PY-SQL-DYNAMIC",
        "HIGH",
        "SQL execution appears to use string formatting/f-strings.",
        r"\.execute\s*\(\s*(f['\"]|['\"][^'\"]*(%s|\{)|[a-zA-Z_][\w.]*\s*%)",
        {".py"},
        recommendation="Use parameterized queries; never build SQL by concatenating/formatting user-controlled values.",
    ),
    compile_rule(
        "PY-FLASK-DEBUG",
        "HIGH",
        "Flask debug mode appears enabled.",
        r"\.run\s*\([^#\n]*debug\s*=\s*True",
        {".py"},
        recommendation="Do not run Flask with debug=True outside controlled local development.",
    ),
    compile_rule(
        "PY-BIND-ALL-INTERFACES",
        "HIGH",
        "Server appears to bind to 0.0.0.0.",
        r"host\s*=\s*['\"]0\.0\.0\.0['\"]|app\.run\s*\([^#\n]*['\"]0\.0\.0\.0['\"]",
        {".py"},
        recommendation="For local tools bind to 127.0.0.1 only. Add authentication before exposing beyond localhost.",
    ),
    compile_rule(
        "PY-LOGGING-SENSITIVE",
        "MEDIUM",
        "Logger call may include sensitive data, paths, Salesforce payloads, recipients, or raw command/API output.",
        r"\blogger\.(debug|info|warning|error|exception|critical)\s*\([^#\n]*(records|users?|emails?|recipients?|tokens?|password|session|profile|manager|account|dealer|agency|path|file|snapshot|response\.text|stdout|stderr|traceback|exception)",
        {".py"},
        recommendation="At INFO/WARNING/ERROR log counts/status only. Redact sensitive values and avoid full paths/payloads.",
    ),
    # JavaScript / TypeScript / HTML
    compile_rule(
        "JS-DOM-XSS-HTML-SINK",
        "HIGH",
        "Dynamic HTML insertion sink; possible DOM XSS.",
        r"(\.innerHTML\s*=|\.outerHTML\s*=|\.insertAdjacentHTML\s*\(|document\.write\s*\(|\.replaceWith\s*\()",
        {".js", ".jsx", ".ts", ".tsx", ".html", ".htm"},
        recommendation="Use textContent, createElement/appendChild, or replaceChild(newNode, oldNode). Avoid replaceWith().",
    ),
    compile_rule(
        "JS-CODE-EXECUTION",
        "CRITICAL",
        "Dynamic JavaScript code execution.",
        r"\b(eval\s*\(|new\s+Function\s*\(|setTimeout\s*\(\s*['\"]|setInterval\s*\(\s*['\"])",
        {".js", ".jsx", ".ts", ".tsx", ".html", ".htm"},
        recommendation="Avoid dynamic JS execution. Use function references, allow-listed dispatch, or structured data.",
    ),
    compile_rule(
        "JS-LOCALSTORAGE-SECRET",
        "HIGH",
        "Potential token/secret stored in browser localStorage/sessionStorage.",
        rf"(localStorage|sessionStorage)\.(setItem|getItem)\s*\([^\n]*({SECRETISH_WORDS})",
        {".js", ".jsx", ".ts", ".tsx", ".html", ".htm"},
        recommendation="Do not store secrets/tokens in localStorage. Prefer secure, HttpOnly cookies or server-side session state where applicable.",
    ),
    compile_rule(
        "JS-INSECURE-FETCH-HTTP",
        "MEDIUM",
        "HTTP URL used in fetch/XMLHttpRequest; confirm it is localhost-only or switch to HTTPS.",
        r"(fetch\s*\(|XMLHttpRequest|axios\.)[^\n]*['\"]http://(?!localhost|127\.0\.0\.1)",
        {".js", ".jsx", ".ts", ".tsx", ".html", ".htm"},
        recommendation="Use HTTPS for non-local endpoints and avoid sending sensitive data over HTTP.",
    ),
    compile_rule(
        "HTML-INLINE-EVENT-HANDLER",
        "MEDIUM",
        "Inline HTML event handler found; increases XSS risk and weakens CSP.",
        r"\son[a-zA-Z]+\s*=\s*['\"]",
        {".html", ".htm"},
        recommendation="Attach event handlers from JavaScript with addEventListener() and keep CSP strict.",
    ),
    # CSS
    compile_rule(
        "CSS-EXPRESSION",
        "HIGH",
        "Legacy CSS expression() can execute script in old engines and should never be used.",
        r"expression\s*\(",
        {".css", ".html", ".htm"},
        recommendation="Remove CSS expression(). Use standard CSS only.",
    ),
    compile_rule(
        "CSS-REMOTE-IMPORT-HTTP",
        "MEDIUM",
        "CSS imports a non-local HTTP resource.",
        r"@import[^;]*url\s*\(\s*['\"]?http://(?!localhost|127\.0\.0\.1)",
        {".css", ".html", ".htm"},
        recommendation="Use HTTPS and approved static assets. Avoid untrusted remote CSS.",
    ),
]


def is_own_scanner_file(name: str) -> bool:
    """Return True if ``name`` is one of this scanner's own files.

    Why this exists:
        This scanner's rule table literally contains the dangerous code
        patterns it hunts for (for example the text ``eval(`` and
        ``verify=False`` appear inside regex strings). If the scanner scans its
        own source, every one of those rule strings is reported as a finding -
        pure false positives. Because the shared sync copies this scanner into
        every project root, it must skip its own files wherever it runs.

    Args:
        name: A bare file name with no directory part, e.g.
            ``"security_scan.py"``.

    Returns:
        True for the scanner's own source and teaching files - any name that
        starts with ``security_scan`` (such as ``security_scan.py``,
        ``security_scan.ps1``, ``security_scan_teaching_docstrings.py``) and
        the pack builder ``create_security_scan_pack.py``; otherwise False. A
        real project would never legitimately name a file ``security_scan*``.
    """
    lowered = name.lower()
    return lowered.startswith("security_scan") or lowered == "create_security_scan_pack.py"


def should_scan_file(path: Path, included_exts: set[str]) -> bool:
    # Never scan the scanner's own files - they contain the very patterns it
    # detects, so scanning them would only ever produce false positives.
    if is_own_scanner_file(path.name):
        return False
    # ALIGNED (item 3): match any .env* file via broad prefix, same as PowerShell.
    if path.name.lower().startswith(".env"):
        return True
    return path.suffix.lower() in included_exts


def iter_files(root: Path, included_exts: set[str], excluded_dirs: set[str]) -> Iterable[Path]:
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in excluded_dirs and not d.startswith(".eggs")]
        current = Path(dirpath)
        for filename in filenames:
            path = current / filename
            if should_scan_file(path, included_exts):
                yield path


def sanitize_snippet(line: str) -> str:
    s = line.strip()
    s = re.sub(
        rf"(?i)\b({SECRETISH_WORDS})\b\s*([:=])\s*(['\"])[^'\"]+(['\"])",
        r"\1\2\3[REDACTED]\4",
        s,
    )
    # ALIGNED (item 4): (?i) so lowercase key markers are redacted too.
    s = re.sub(r"(?i)-----BEGIN [A-Z ]*PRIVATE KEY-----.*", "-----BEGIN [REDACTED PRIVATE KEY]-----", s)
    if len(s) > 220:
        s = s[:217] + "..."
    return s


def scan_file(path: Path, root: Path) -> list[Finding]:
    findings: list[Finding] = []
    rel = str(path.relative_to(root)) if path.is_relative_to(root) else str(path)
    suffix = path.suffix.lower()

    # File-name based checks.
    if path.name.lower().startswith(".env") and path.name.lower() != ".env.example":
        findings.append(
            Finding(
                severity="HIGH",
                rule_id="SECRET-ENV-FILE",
                file=rel,
                line=1,
                description="Environment file may contain real secrets and should not be committed.",
                snippet="[filename only]",
                recommendation="Commit .env.example only. Keep real .env files local and ignored by git.",
            )
        )

    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        findings.append(
            Finding(
                severity="LOW",
                rule_id="SCAN-READ-ERROR",
                file=rel,
                line=1,
                description=f"Could not read file: {exc}",
                snippet="",
                recommendation="Check file permissions or encoding.",
            )
        )
        return findings

    for line_no, line in enumerate(text.splitlines(), start=1):
        stripped = line.strip()
        if not stripped:
            continue
        # Skip full-line comments for noisy rules, but not secret/private-key checks.
        is_comment = stripped.startswith(("#", "//", "/*", "*", "<!--"))
        for rule in RULES:
            if rule.extensions is not None and suffix not in rule.extensions:
                continue
            if is_comment and not rule.rule_id.startswith("SECRET"):
                continue
            if rule.pattern.search(line):
                findings.append(
                    Finding(
                        severity=rule.severity,
                        rule_id=rule.rule_id,
                        file=rel,
                        line=line_no,
                        description=rule.description,
                        snippet=sanitize_snippet(line),
                        recommendation=rule.recommendation,
                    )
                )
    return findings


def scan_requirements(path: Path, root: Path) -> list[Finding]:
    findings: list[Finding] = []
    if not path.name.lower().startswith("requirements") or path.suffix.lower() != ".txt":
        return findings
    rel = str(path.relative_to(root)) if path.is_relative_to(root) else str(path)
    try:
        lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError:
        return findings
    for line_no, line in enumerate(lines, 1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or stripped.startswith(("-r ", "--")):
            continue
        # ALIGNED (item 10): use \s@\s (any whitespace) to match PowerShell;
        # redact the stripped line for consistent snippet output.
        if "==" not in stripped and not re.search(r"\s@\s", stripped):
            findings.append(
                Finding(
                    severity="MEDIUM",
                    rule_id="DEP-UNPINNED-PIP",
                    file=rel,
                    line=line_no,
                    description="Python dependency is not pinned to an exact version.",
                    snippet=sanitize_snippet(stripped),
                    recommendation="Pin exact versions in requirements files, e.g. package==1.2.3, per repository guidance.",
                )
            )
    return findings


def scan_package_json(path: Path, root: Path) -> list[Finding]:
    if path.name.lower() != "package.json":
        return []
    rel = str(path.relative_to(root)) if path.is_relative_to(root) else str(path)
    try:
        data = json.loads(path.read_text(encoding="utf-8", errors="replace"))
    except Exception:
        return []
    findings: list[Finding] = []
    for section in ("dependencies", "devDependencies", "optionalDependencies"):
        deps = data.get(section, {})
        if not isinstance(deps, dict):
            continue
        for name, version in deps.items():
            if not isinstance(version, str):
                continue
            # ALIGNED (item 11): trim ONCE, then run every comparison on the
            # trimmed value. Original stripped only for the "*"/"latest" test and
            # left startswith() checking the un-stripped string, so a leading-space
            # value like "  ^1.2.3" was missed. PowerShell now trims too.
            version = version.strip()
            if version in {"*", "latest"} or version.startswith(("^", "~", ">", "<")):
                findings.append(
                    Finding(
                        severity="MEDIUM",
                        rule_id="DEP-UNPINNED-NPM",
                        file=rel,
                        line=1,
                        description=f"NPM dependency in {section} is not exactly pinned: {name}",
                        snippet=f"{name}: {version}",
                        recommendation="Prefer lockfiles and exact pinned versions for reproducible builds; review supply-chain risk.",
                    )
                )
    return findings


def severity_at_or_above(severity: str, threshold: str) -> bool:
    return SEVERITY_ORDER[severity] >= SEVERITY_ORDER[threshold]


def sort_findings(findings: list[Finding]) -> list[Finding]:
    # ALIGNED (item 7): single deterministic ordering used for text AND json.
    # (Original dumped JSON unsorted while sorting text - an internal inconsistency.)
    return sorted(findings, key=lambda f: (-SEVERITY_ORDER[f.severity], f.file, f.line, f.rule_id))


def print_text(findings: list[Finding]) -> None:
    if not findings:
        print("No high-risk security patterns found by local regex scan.")
        return

    findings_sorted = sort_findings(findings)
    for f in findings_sorted:
        print(f"[{f.severity}] {f.rule_id} {f.file}:{f.line}")
        print(f"  {f.description}")
        if f.snippet:
            print(f"  Code: {f.snippet}")
        print(f"  Fix:  {f.recommendation}")
        print()

    counts: dict[str, int] = {sev: 0 for sev in SEVERITY_ORDER}
    for f in findings:
        counts[f.severity] += 1
    print("Summary:")
    for sev in ("CRITICAL", "HIGH", "MEDIUM", "LOW"):
        print(f"  {sev}: {counts[sev]}")
    print(f"  TOTAL: {len(findings)}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Local repo security pattern scanner")
    parser.add_argument("--root", default=".", help="Repository root to scan; default: current directory")
    parser.add_argument("--format", choices=("text", "json"), default="text", help="Output format")
    parser.add_argument(
        "--output",
        help=(
            "Optional output file, resolved relative to the current directory and "
            "required to stay inside it; otherwise prints to stdout."
        ),
    )
    parser.add_argument(
        "--fail-on",
        choices=("LOW", "MEDIUM", "HIGH", "CRITICAL", "NONE"),
        default="HIGH",
        help="Exit non-zero if findings at or above this severity exist; default: HIGH",
    )
    parser.add_argument(
        "--include-ext",
        action="append",
        default=[],
        help="Additional extension to scan, e.g. --include-ext .ps1. Can be repeated.",
    )
    args = parser.parse_args(argv)

    root = Path(args.root).resolve()
    if not root.exists():
        print(f"Root path does not exist: {root}", file=sys.stderr)
        return 2

    # Validate the optional --output path BEFORE any file is written. The value
    # comes from the command line (untrusted input), so we contain it inside the
    # current working directory to block path traversal (e.g. "../../secrets")
    # or an absolute path escaping to an unintended location. This is a genuine
    # containment check using Path.is_relative_to - NOT str.startswith, which a
    # sibling directory like "<cwd>-evil" would defeat. The check runs in this
    # function (intra-procedural) so a SAST taint-tracker sees the guard.
    safe_output: Path | None = None
    if args.output:
        output_base = Path.cwd().resolve()
        candidate = (output_base / args.output).resolve()
        if not candidate.is_relative_to(output_base):
            print(f"Output path escapes base directory: {args.output!r}", file=sys.stderr)
            return 2
        safe_output = candidate

    included_exts = set(DEFAULT_INCLUDED_EXTS)
    included_exts.update(
        ext.lower() if ext.startswith(".") else f".{ext.lower()}"
        for ext in args.include_ext
    )

    findings: list[Finding] = []
    for path in iter_files(root, included_exts, DEFAULT_EXCLUDED_DIRS):
        findings.extend(scan_file(path, root))
        findings.extend(scan_requirements(path, root))
        findings.extend(scan_package_json(path, root))

    if args.format == "json":
        payload = json.dumps([asdict(f) for f in sort_findings(findings)], indent=2)
        if safe_output is not None:
            safe_output.write_text(payload + "\n", encoding="utf-8")
        else:
            print(payload)
    else:
        if safe_output is not None:
            original_stdout = sys.stdout
            with safe_output.open("w", encoding="utf-8") as fh:
                sys.stdout = fh
                try:
                    print_text(findings)
                finally:
                    sys.stdout = original_stdout
        else:
            print_text(findings)

    if args.fail_on != "NONE" and any(severity_at_or_above(f.severity, args.fail_on) for f in findings):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

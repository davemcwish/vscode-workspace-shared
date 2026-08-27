#!/usr/bin/env python3
"""Teaching version of the local high-risk security pattern scanner.

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
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    # Imported for type annotations only. ``from __future__ import annotations``
    # (above) makes every annotation a string at runtime, so this import does
    # not need to execute when the scanner runs.
    from collections.abc import Iterable

SEVERITY_ORDER = {"LOW": 1, "MEDIUM": 2, "HIGH": 3, "CRITICAL": 4}

DEFAULT_EXCLUDED_DIRS = {
    ".git",
    ".hg",
    ".svn",
    ".venv",
    "venv",
    "env",
    "node_modules",
    "__pycache__",
    ".pytest_cache",
    ".mypy_cache",
    ".ruff_cache",
    ".tox",
    "dist",
    "build",
    "coverage",
    "htmlcov",
    ".idea",
}

DEFAULT_INCLUDED_EXTS = {
    ".py",
    ".js",
    ".jsx",
    ".ts",
    ".tsx",
    ".html",
    ".htm",
    ".css",
    ".md",
    ".json",
    ".yml",
    ".yaml",
    ".toml",
    ".cfg",
    ".ini",
    ".txt",
    ".env",
}

# NOTE: This is a list of secret-ish KEYWORD NAMES the scanner searches for,
# not an actual secret. The inline pragma keeps detect-secrets from flagging
# this line when the scanner is synced into a project whose gate runs
# detect-secrets (its PowerShell twin is flagged without the pragma).
# The line is kept intact (noqa: E501) rather than split across several
# implicitly-concatenated strings, because detect-secrets matches its pragma
# per line - splitting would need the pragma repeated on every fragment.
SECRETISH_WORDS = r"api[_-]?key|secret|token|password|passwd|pwd|session[_-]?id|client[_-]?secret|private[_-]?key|access[_-]?token|refresh[_-]?token"  # noqa: E501  # pragma: allowlist secret


@dataclass(frozen=True)
class Rule:
    """One security pattern the scanner looks for.

    A "rule" pairs a regular expression with the metadata needed to report a
    readable finding. Rules are created by :func:`compile_rule` and collected
    in the module-level ``RULES`` list; every line of every scanned file is
    tested against every applicable rule.

    Attributes:
        rule_id: Short stable identifier printed in output, e.g.
            ``"PY-SUBPROCESS-SHELL-TRUE"``. Used to recognise a finding
            across runs, so keep it unchanged once published.
        severity: One of ``"LOW"``, ``"MEDIUM"``, ``"HIGH"``, ``"CRITICAL"``.
            Must be a key of ``SEVERITY_ORDER``.
        description: Plain-English explanation of what was matched and why it
            is a concern.
        pattern: The compiled regular expression searched for in each line.
        extensions: File extensions this rule applies to, lower-case and
            including the dot, e.g. ``{".py"}``. ``None`` means "apply to
            every scanned file".
        recommendation: The suggested fix, printed after ``Fix:``.

    Note:
        The class is frozen (immutable) because rules are shared constants -
        accidentally mutating one mid-scan would change later results.
    """

    rule_id: str
    severity: str
    description: str
    pattern: re.Pattern[str]
    extensions: set[str] | None = None
    recommendation: str = "Review and apply security.instructions.md."


@dataclass
class Finding:
    """A single place in the codebase where a :class:`Rule` matched.

    One ``Finding`` is created per matching line. It carries everything needed
    to print a report entry or serialise to JSON, so the file does not have to
    be read again later.

    Attributes:
        severity: Copied from the rule that matched.
        rule_id: Copied from the rule that matched.
        file: Path of the offending file relative to the scan root where
            possible, otherwise the absolute path.
        line: 1-based line number (the first line of a file is 1, not 0).
        description: Copied from the rule that matched.
        snippet: The offending line, trimmed and passed through
            :func:`sanitize_snippet` so likely secret values are replaced with
            ``[REDACTED]`` before display.
        recommendation: Copied from the rule that matched.
    """

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
    """Build a Rule object from plain rule metadata.

    Most rules use case-insensitive matching by default. Individual rules can pass a
    different regex flag value when exact behaviour is needed.
    """
    r"""Build one :class:`Rule`, compiling its regular expression up front.

    This is a small convenience wrapper so the big ``RULES`` list below stays
    readable. Compiling each pattern once here (rather than on every line of
    every file) is what keeps the scan fast.

    Args:
        rule_id: Short stable identifier for the rule, e.g. ``"PY-WEAK-PRNG"``.
        severity: One of ``"LOW"``, ``"MEDIUM"``, ``"HIGH"``, ``"CRITICAL"``.
        description: Plain-English explanation of the problem.
        regex: The pattern to search for, as a string. It is compiled here.
        exts: File extensions the rule applies to, lower-case and including
            the dot, e.g. ``[".py"]``. Pass ``None`` (the default) to apply
            the rule to every scanned file. An empty collection is also
            treated as "every file".
        flags: Regular-expression flags. Defaults to ``re.IGNORECASE`` so
            rules match regardless of capitalisation.
        recommendation: The suggested fix, printed after ``Fix:``.

    Returns:
        A ready-to-use :class:`Rule` with its ``pattern`` already compiled.

    Raises:
        re.error: If ``regex`` is not a valid regular expression. This means
            the rule definition itself is wrong; fix the pattern in ``RULES``.
            Because rules are built at import time, a bad pattern stops the
            scanner from starting at all rather than failing mid-scan.

    Example:
        >>> rule = compile_rule(
        ...     "PY-EXAMPLE",
        ...     "LOW",
        ...     "Example only.",
        ...     r"\bTODO\b",
        ...     [".py"],
        ... )
        >>> rule.rule_id
        'PY-EXAMPLE'
    """
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
        recommendation=(
            "Move secrets to approved secret storage or environment variables; "
            "commit only placeholders in .env.example."
        ),
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
        recommendation=(
            "Use subprocess with a list, shell=False, literal command parts, "
            "and validated arguments."
        ),
    ),
    compile_rule(
        "PY-OS-SYSTEM",
        "CRITICAL",
        "Shell command execution via os.system/os.popen/commands.getoutput.",
        r"\b(os\.system|os\.popen|commands\.getoutput|commands\.getstatusoutput)\s*\(",
        {".py"},
        recommendation=(
            "Replace with subprocess.run([...], shell=False) and allow-list validated inputs."
        ),
    ),
    compile_rule(
        "PY-SUBPROCESS-STRING-COMMAND",
        "HIGH",
        "subprocess appears to receive a string/f-string command rather than a safe argument list.",
        r"\bsubprocess\.(run|Popen|call|check_call|check_output)\s*\(\s*(f?['\"]|[a-zA-Z_][\w.]*\s*\+)",
        {".py"},
        recommendation=(
            "Pass a list of arguments; validate executable with "
            "validate_subprocess_command(); validate dynamic args locally."
        ),
    ),
    compile_rule(
        "PY-EVAL-EXEC",
        "CRITICAL",
        "Dynamic Python code execution via eval/exec/compile.",
        r"(?<![\w.])(eval|exec|compile)\s*\(",
        {".py"},
        recommendation=(
            "Avoid dynamic code execution. Use allow-listed functions or "
            "data-driven dispatch tables."
        ),
    ),
    # Python file paths / archive / XML
    compile_rule(
        "PY-DYNAMIC-OPEN",
        "MEDIUM",
        (
            "open() appears to use a non-literal path; ensure resolve_safe_path() "
            "and local re-validation are used."
        ),
        r"(?<![\w.])open\s*\(\s*(?!['\"])",
        {".py"},
        recommendation=(
            "Use resolve_safe_path(), assign safe_path, and pass only the "
            "validated path into file I/O."
        ),
    ),
    compile_rule(
        "PY-TEMPFILE-DYNAMIC-PREFIX",
        "HIGH",
        "NamedTemporaryFile prefix appears dynamic; Cycode flags tainted temp filename prefixes.",
        r"\bNamedTemporaryFile\s*\([^#\n]*prefix\s*=\s*(?!['\"])",
        {".py"},
        recommendation=(
            "Use a fixed literal prefix, e.g. prefix='report_attachment_'. "
            "Do not derive temp filenames from attachment names."
        ),
    ),
    compile_rule(
        "PY-ZIP-EXTRACTALL",
        "HIGH",
        "ZipFile.extractall() can allow ZIP Slip path traversal if archive members are untrusted.",
        r"\.extractall\s*\(",
        {".py"},
        recommendation=(
            "Validate every ZIP member destination stays under the intended "
            "target directory before extracting."
        ),
    ),
    compile_rule(
        "PY-SHUTIL-DYNAMIC-PATH",
        "MEDIUM",
        (
            "shutil file operation uses a path argument; Cycode flags "
            "unsanitized dynamic input in file paths."
        ),
        r"\bshutil\.(move|copy|copy2|copyfile|copytree)\s*\(",
        {".py"},
        recommendation=(
            "Validate the source and destination with resolve_safe_path() before "
            "the shutil call; only then wrap the OS call (e.g. to_long_path). "
            "Never pass a raw or tainted path."
        ),
    ),
    compile_rule(
        "PY-ZIPFILE-DYNAMIC-PATH",
        "MEDIUM",
        (
            "zipfile.ZipFile() opens a non-literal path; Cycode flags "
            "unsanitized dynamic input in file paths."
        ),
        r"\bzipfile\.ZipFile\s*\(\s*(?!['\"])",
        {".py"},
        recommendation=(
            "Pass a resolve_safe_path()-validated path into zipfile.ZipFile(); "
            "never open an archive at a raw user- or Salesforce-derived path."
        ),
    ),
    compile_rule(
        "PY-XML-STDLIB",
        "HIGH",
        "Python standard-library XML parser usage; may be vulnerable to hostile XML payloads.",
        r"(from\s+xml\.etree\s+import|import\s+xml\.etree|xml\.etree\.ElementTree|\bET\.parse\s*\()",
        {".py"},
        recommendation=(
            "Use defusedxml.ElementTree for XML parsing, especially for files "
            "influenced by users or external systems."
        ),
    ),
    # Python crypto/random/network
    compile_rule(
        "PY-WEAK-PRNG",
        "HIGH",
        (
            "Use of random.* or random.Random(); not suitable for "
            "security-sensitive randomness and historically flagged by Cycode."
        ),
        r"\brandom\.(Random\s*\(|random\s*\(|randint\s*\(|randrange\s*\(|choice\s*\(|choices\s*\(|shuffle\s*\(|sample\s*\()",
        {".py"},
        recommendation=(
            "For secrets use secrets.*. For non-security randomness use "
            "SystemRandom() or deterministic index-based selection."
        ),
    ),
    compile_rule(
        "PY-INSECURE-SMTP",
        "HIGH",
        "Plain smtplib.SMTP() usage; Cycode flags insecure SMTP connections.",
        r"\bsmtplib\.SMTP\s*\(",
        {".py"},
        recommendation=(
            "Prefer SMTP_SSL(), or call starttls() and fail closed before "
            "sending. Use Outlook COM if that is the approved path."
        ),
    ),
    compile_rule(
        "PY-TLS-VERIFY-FALSE",
        "CRITICAL",
        "TLS certificate verification disabled.",
        r"\bverify\s*=\s*False\b|\.verify\s*=\s*False\b|CERT_NONE",
        {".py"},
        recommendation=(
            "Do not disable TLS verification. Use trusted CA bundles or "
            "approved corporate TLS configuration."
        ),
    ),
    compile_rule(
        "PY-INSECURE-DESERIALIZATION",
        "HIGH",
        "Potential unsafe deserialization.",
        r"\b(pickle\.load|pickle\.loads|dill\.load|dill\.loads|marshal\.load|marshal\.loads|yaml\.load\s*\()",
        {".py"},
        recommendation=(
            "Do not deserialize untrusted data. Use json, safe_load(), or a "
            "schema-validated format."
        ),
    ),
    compile_rule(
        "PY-SQL-DYNAMIC",
        "HIGH",
        "SQL execution appears to use string formatting/f-strings.",
        r"\.execute\s*\(\s*(f['\"]|['\"][^'\"]*(%s|\{)|[a-zA-Z_][\w.]*\s*%)",
        {".py"},
        recommendation=(
            "Use parameterized queries; never build SQL by "
            "concatenating/formatting user-controlled values."
        ),
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
        recommendation=(
            "For local tools bind to 127.0.0.1 only. Add authentication before "
            "exposing beyond localhost."
        ),
    ),
    compile_rule(
        "PY-LOGGING-SENSITIVE",
        "MEDIUM",
        (
            "Logger call may include sensitive data, paths, Salesforce "
            "payloads, recipients, or raw command/API output."
        ),
        r"\blogger\.(debug|info|warning|error|exception|critical)\s*\([^#\n]*(records|users?|emails?|recipients?|tokens?|password|session|profile|manager|account|dealer|agency|path|file|snapshot|response\.text|stdout|stderr|traceback|exception)",
        {".py"},
        recommendation=(
            "At INFO/WARNING/ERROR log counts/status only. Redact sensitive "
            "values and avoid full paths/payloads."
        ),
    ),
    # JavaScript / TypeScript / HTML
    compile_rule(
        "JS-DOM-XSS-HTML-SINK",
        "HIGH",
        "Dynamic HTML insertion sink; possible DOM XSS.",
        r"(\.innerHTML\s*=|\.outerHTML\s*=|\.insertAdjacentHTML\s*\(|document\.write\s*\(|\.replaceWith\s*\()",
        {".js", ".jsx", ".ts", ".tsx", ".html", ".htm"},
        recommendation=(
            "Use textContent, createElement/appendChild, or "
            "replaceChild(newNode, oldNode). Avoid replaceWith()."
        ),
    ),
    compile_rule(
        "JS-CODE-EXECUTION",
        "CRITICAL",
        "Dynamic JavaScript code execution.",
        r"\b(eval\s*\(|new\s+Function\s*\(|setTimeout\s*\(\s*['\"]|setInterval\s*\(\s*['\"])",
        {".js", ".jsx", ".ts", ".tsx", ".html", ".htm"},
        recommendation=(
            "Avoid dynamic JS execution. Use function references, allow-listed "
            "dispatch, or structured data."
        ),
    ),
    compile_rule(
        "JS-LOCALSTORAGE-SECRET",
        "HIGH",
        "Potential token/secret stored in browser localStorage/sessionStorage.",
        rf"(localStorage|sessionStorage)\.(setItem|getItem)\s*\([^\n]*({SECRETISH_WORDS})",
        {".js", ".jsx", ".ts", ".tsx", ".html", ".htm"},
        recommendation=(
            "Do not store secrets/tokens in localStorage. Prefer secure, "
            "HttpOnly cookies or server-side session state where applicable."
        ),
    ),
    compile_rule(
        "JS-INSECURE-FETCH-HTTP",
        "MEDIUM",
        "HTTP URL used in fetch/XMLHttpRequest; confirm it is localhost-only or switch to HTTPS.",
        r"(fetch\s*\(|XMLHttpRequest|axios\.)[^\n]*['\"]http://(?!localhost|127\.0\.0\.1)",
        {".js", ".jsx", ".ts", ".tsx", ".html", ".htm"},
        recommendation=(
            "Use HTTPS for non-local endpoints and avoid sending sensitive data over HTTP."
        ),
    ),
    compile_rule(
        "HTML-INLINE-EVENT-HANDLER",
        "MEDIUM",
        "Inline HTML event handler found; increases XSS risk and weakens CSP.",
        r"\son[a-zA-Z]+\s*=\s*['\"]",
        {".html", ".htm"},
        recommendation=(
            "Attach event handlers from JavaScript with addEventListener() and keep CSP strict."
        ),
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
    """Decide whether a single file should be scanned.

    Args:
        path: The file being considered.
        included_exts: Lower-case extensions to scan, each including the dot,
            e.g. ``{".py", ".js"}``.

    Returns:
        True if the file should be scanned, False to skip it. Files are
        skipped when they belong to the scanner itself; any ``.env*`` file is
        always scanned (even ``.env.local``, which has no matching suffix),
        because those are the files most likely to hold real secrets.

    Example:
        >>> should_scan_file(Path("app.py"), {".py"})
        True
        >>> should_scan_file(Path("notes.rst"), {".py"})
        False
    """
    # Never scan the scanner's own files - they contain the very patterns it
    # detects, so scanning them would only ever produce false positives.
    if is_own_scanner_file(path.name):
        return False
    # ALIGNED (item 3): match any .env* file via broad prefix, same as PowerShell.
    if path.name.lower().startswith(".env"):
        return True
    return path.suffix.lower() in included_exts


def iter_files(root: Path, included_exts: set[str], excluded_dirs: set[str]) -> Iterable[Path]:
    """Walk ``root`` and yield every file that should be scanned.

    Directories in ``excluded_dirs`` are pruned as the walk proceeds, so the
    scanner never descends into them. That is what keeps large folders such as
    ``node_modules`` and ``.venv`` from dominating the run time.

    Args:
        root: Directory to scan, searched recursively.
        included_exts: Lower-case extensions to scan, each including the dot.
        excluded_dirs: Directory names (not paths) to skip entirely, e.g.
            ``{".git", "node_modules"}``. Any directory whose name starts with
            ``.eggs`` is also skipped.

    Yields:
        Each file worth scanning, as a :class:`~pathlib.Path`. This is a
        generator, so files are produced one at a time rather than collected
        into a list - the whole tree is never held in memory at once.

    Example:
        >>> for found in iter_files(Path("src"), {".py"}, {".git"}):
        ...     print(found)  # doctest: +SKIP
    """
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in excluded_dirs and not d.startswith(".eggs")]
        current = Path(dirpath)
        for filename in filenames:
            path = current / filename
            if should_scan_file(path, included_exts):
                yield path


def sanitize_snippet(line: str) -> str:
    """Make a source line safe to print in a report.

    Findings quote the offending line so a reader can see the problem. If that
    line contains a real secret, printing it verbatim would copy the secret
    into the report - and reports get pasted into tickets and chat. This
    function replaces likely secret values with ``[REDACTED]`` first.

    Args:
        line: The raw source line. Leading and trailing whitespace is removed.

    Returns:
        The trimmed line with any ``key = "value"``-style secret replaced by
        ``[REDACTED]`` and any private-key header collapsed. Lines longer than
        220 characters are truncated with a trailing ``...`` to keep report
        output readable.

    Note:
        Redaction is regex-based and best-effort. Treat it as a safety net,
        not a guarantee, and still review a report before sharing it widely.

    Example:
        Given a source line that assigns a quoted value to a secret-ish name
        (``password``, ``api_key``, ``token`` and similar), the value between
        the quotes is replaced, so the report shows the shape of the problem
        without reproducing the credential itself. A literal example is
        deliberately not written out here: this docstring would then contain a
        secret-shaped string, and every secret scanner running over this file
        in every project it is synced into would flag it.
    """
    s = line.strip()
    s = re.sub(
        rf"(?i)\b({SECRETISH_WORDS})\b\s*([:=])\s*(['\"])[^'\"]+(['\"])",
        r"\1\2\3[REDACTED]\4",
        s,
    )
    # ALIGNED (item 4): (?i) so lowercase key markers are redacted too.
    s = re.sub(
        r"(?i)-----BEGIN [A-Z ]*PRIVATE KEY-----.*", "-----BEGIN [REDACTED PRIVATE KEY]-----", s
    )
    if len(s) > 220:
        s = s[:217] + "..."
    return s


def scan_file(path: Path, root: Path) -> list[Finding]:
    """Scan one file against every applicable rule.

    Two kinds of check run here: a filename check (a committed ``.env`` file
    is itself a finding, whatever is inside it), then a line-by-line regex
    check against ``RULES``.

    Full-line comments are skipped for most rules, because a comment
    describing a risky call is not the same as making one. Secret-related
    rules still run on comments, since a secret pasted into a comment is
    every bit as leaked.

    Args:
        path: The file to scan.
        root: The scan root, used to shorten reported paths to something
            relative and readable.

    Returns:
        A list of :class:`Finding` objects, one per matching line. An empty
        list means nothing matched - that is the normal, healthy result.

    Note:
        A file that cannot be read is reported as a ``LOW`` severity
        ``SCAN-READ-ERROR`` finding rather than raising. A scanner that stops
        on the first unreadable file would be useless on a real repository,
        so unreadable files are recorded and the scan continues. Undecodable
        bytes are replaced rather than raising, so binary files that slip
        through the extension filter cannot crash the run.
    """
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
                description=(
                    "Environment file may contain real secrets and should not be committed."
                ),
                snippet="[filename only]",
                recommendation=(
                    "Commit .env.example only. Keep real .env files local and ignored by git."
                ),
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
    """Report Python dependencies that are not pinned to an exact version.

    An unpinned dependency (``requests`` rather than ``requests==2.32.3``) can
    resolve to a different version on a later install, which makes builds
    irreproducible and lets a compromised release in without any change to
    your own code.

    Args:
        path: File to inspect. Files that are not named ``requirements*.txt``
            are ignored, so this can safely be called for every file.
        root: The scan root, used to shorten reported paths.

    Returns:
        One ``MEDIUM`` ``DEP-UNPINNED-PIP`` finding per unpinned line, or an
        empty list. Comments, blank lines, ``-r`` includes and ``--`` options
        are skipped, as are direct references using ``name @ url`` syntax,
        which are pinned by URL rather than by ``==``.

    Note:
        An unreadable file yields an empty list rather than raising - the
        caller is scanning a whole tree and should not stop for one file.
    """
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
                    recommendation=(
                        "Pin exact versions in requirements files, e.g. "
                        "package==1.2.3, per repository guidance."
                    ),
                )
            )
    return findings


def scan_package_json(path: Path, root: Path) -> list[Finding]:
    """Report NPM dependencies that are not pinned to an exact version.

    The JavaScript equivalent of :func:`scan_requirements`. Range specifiers
    such as ``^1.2.3`` or ``~1.2.3`` let a future ``npm install`` pull code
    that was never reviewed here, so they are reported.

    Args:
        path: File to inspect. Anything not named ``package.json`` is ignored,
            so this can safely be called for every file.
        root: The scan root, used to shorten reported paths.

    Returns:
        One ``MEDIUM`` ``DEP-UNPINNED-NPM`` finding per unpinned dependency
        across the ``dependencies``, ``devDependencies`` and
        ``optionalDependencies`` sections, or an empty list.

    Note:
        Every finding is reported at line 1. The file is parsed as JSON, which
        discards line numbers, so the exact line is not available - open the
        file and search for the dependency name.

        Malformed JSON yields an empty list rather than raising. That is a
        deliberate trade-off: this is an advisory scanner, and one broken
        ``package.json`` should not abort a whole-repository scan. The cost is
        that a malformed file is silently unscanned.
    """
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
                        recommendation=(
                            "Prefer lockfiles and exact pinned versions for "
                            "reproducible builds; review supply-chain risk."
                        ),
                    )
                )
    return findings


def severity_at_or_above(severity: str, threshold: str) -> bool:
    """Test whether one severity is at least as serious as another.

    Used to decide the exit code: with ``--fail-on HIGH``, a ``HIGH`` or
    ``CRITICAL`` finding fails the run, while ``MEDIUM`` and ``LOW`` do not.

    Args:
        severity: The severity to test, e.g. ``"HIGH"``.
        threshold: The severity to compare against, e.g. ``"MEDIUM"``.

    Returns:
        True if ``severity`` is the same as, or more serious than,
        ``threshold``.

    Raises:
        KeyError: If either value is not one of ``"LOW"``, ``"MEDIUM"``,
            ``"HIGH"`` or ``"CRITICAL"``. In normal use this cannot happen -
            argparse restricts the threshold and rule severities are fixed
            constants - so a KeyError means a rule was defined with a typo in
            its severity.

    Example:
        >>> severity_at_or_above("HIGH", "MEDIUM")
        True
        >>> severity_at_or_above("LOW", "HIGH")
        False
    """
    return SEVERITY_ORDER[severity] >= SEVERITY_ORDER[threshold]


def sort_findings(findings: list[Finding]) -> list[Finding]:
    """Return findings in a stable, most-serious-first order.

    Sorting matters for more than tidiness: a deterministic order means two
    runs over unchanged code produce identical output, so a diff of two
    reports shows real changes rather than reshuffling.

    Args:
        findings: The findings to sort. The input list is not modified.

    Returns:
        A new list ordered by descending severity, then file path, then line
        number, then rule id.
    """
    # ALIGNED (item 7): single deterministic ordering used for text AND json.
    # (Original dumped JSON unsorted while sorting text - an internal inconsistency.)
    return sorted(findings, key=lambda f: (-SEVERITY_ORDER[f.severity], f.file, f.line, f.rule_id))


def print_text(findings: list[Finding]) -> None:
    """Print findings as human-readable text, followed by a summary count.

    Args:
        findings: The findings to print, in any order - they are sorted here.

    Returns:
        None. Output goes to standard output. The caller redirects
        ``sys.stdout`` when ``--output`` is used.

    Note:
        When there are no findings a single reassuring line is printed
        instead of an empty report, so a clean run never looks like a crash.
    """
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

    counts: dict[str, int] = dict.fromkeys(SEVERITY_ORDER, 0)
    for f in findings:
        counts[f.severity] += 1
    print("Summary:")
    for sev in ("CRITICAL", "HIGH", "MEDIUM", "LOW"):
        print(f"  {sev}: {counts[sev]}")
    print(f"  TOTAL: {len(findings)}")


def main(argv: list[str] | None = None) -> int:
    """Run the scanner from the command line.

    Parses arguments, walks the tree, applies every rule, writes the report,
    and returns the process exit code.

    Args:
        argv: Command-line arguments *excluding* the program name. Pass
            ``None`` (the default) to read from ``sys.argv``. Passing an
            explicit list is what makes this function testable.

    Returns:
        An exit code for the shell:

        * ``0`` - scan completed and nothing met the ``--fail-on`` threshold.
        * ``1`` - scan completed but findings met or exceeded the threshold.
        * ``2`` - the scan could not run: ``--root`` does not exist, or
          ``--output`` pointed outside the current directory.

        Note that ``0`` means "nothing at or above the threshold", not
        "nothing found" - with ``--fail-on NONE`` the result is always ``0``.

    Note:
        The ``--output`` path is validated before anything is written, using
        a real containment check, so a value like ``../../secrets.json``
        cannot escape the working directory.

    Example:
        Run against the current directory and never fail the build::

            python security_scan.py --root . --fail-on NONE
    """
    parser = argparse.ArgumentParser(description="Local repo security pattern scanner")
    parser.add_argument(
        "--root", default=".", help="Repository root to scan; default: current directory"
    )
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
        ext.lower() if ext.startswith(".") else f".{ext.lower()}" for ext in args.include_ext
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
    elif safe_output is not None:
        original_stdout = sys.stdout
        with safe_output.open("w", encoding="utf-8") as fh:
            sys.stdout = fh
            try:
                print_text(findings)
            finally:
                sys.stdout = original_stdout
    else:
        print_text(findings)

    if args.fail_on != "NONE" and any(
        severity_at_or_above(f.severity, args.fail_on) for f in findings
    ):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

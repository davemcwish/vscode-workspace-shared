"""Enforce ASCII-only characters in code files (.py, .ps1, .bat).

This test implements the "safe rule of thumb" for cross-platform correctness:

  - .bat, .ps1, .py files: pure ASCII only (0x00-0x7F).
  - .md files: ASCII plus approved Unicode (emoji, math, section sign).
    Em-dashes, en-dashes, smart quotes, and mojibake are always banned.

Why this matters:
  - Windows tools (cmd.exe, PowerShell 5.1) may use cp1252 or cp437, not UTF-8.
  - GitHub Actions CI runs on Linux (UTF-8 default).
  - Characters like em-dashes (U+2014) survive on Linux but corrupt to garbled
    sequences like "a]'" when opened on Windows with the wrong codepage.
  - This test catches violations before they reach CI or confuse a beginner.

The test runs automatically as part of pytest (sanity.bat step 6).
"""

from __future__ import annotations

from pathlib import Path

import pytest

# ---------------------------------------------------------------------------
# Locate the project root. This test lives in _copilot-shared/tests/ (master)
# but is synced into project tests/ folders.
# ---------------------------------------------------------------------------


def _find_project_root() -> Path | None:
    """Walk up from the test file to find the project root.

    The project root is identified by containing either:
      - _copilot-shared/ (workspace root), or
      - pyproject.toml (sub-project like Salesforce).

    Returns:
        The project root Path, or None if not found.
    """
    current = Path(__file__).resolve().parent
    for _ in range(10):
        if (current / "_copilot-shared").is_dir():
            return current
        if (current / "pyproject.toml").is_file():
            return current
        parent = current.parent
        if parent == current:
            break
        current = parent
    return None


PROJECT_ROOT = _find_project_root()

# Directories to skip (virtual environments, caches, third-party code).
SKIP_DIRS = {
    ".venv",
    "__pycache__",
    ".mypy_cache",
    ".ruff_cache",
    ".pytest_cache",
    "node_modules",
    ".git",
}

# ---------------------------------------------------------------------------
# Code files: must be pure ASCII (0x00 - 0x7F). No exceptions.
# ---------------------------------------------------------------------------

# File extensions that must be pure ASCII.
CODE_EXTENSIONS = {".py", ".ps1", ".bat", ".sh"}


def _collect_code_files() -> list[Path]:
    """Collect all code files in the project, excluding cache directories.

    Returns:
        A list of Path objects for every .py, .ps1, .bat, .sh file found.
    """
    if PROJECT_ROOT is None:
        return []

    files: list[Path] = []
    for ext in CODE_EXTENSIONS:
        for path in PROJECT_ROOT.rglob(f"*{ext}"):
            # Skip files inside excluded directories.
            if any(part in SKIP_DIRS for part in path.parts):
                continue
            files.append(path)
    return sorted(files)


CODE_FILES = _collect_code_files()


def _find_non_ascii(path: Path) -> list[tuple[int, int, str]]:
    """Find all non-ASCII characters in a file.

    Args:
        path: The file to scan.

    Returns:
        A list of (line_number, column, character_description) tuples for
        each non-ASCII character found. Line numbers are 1-based.
    """
    violations: list[tuple[int, int, str]] = []
    try:
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return [(-1, -1, "Could not read file as UTF-8")]

    for line_num, line in enumerate(text.splitlines(), start=1):
        for col, char in enumerate(line, start=1):
            if ord(char) > 127:
                desc = f"U+{ord(char):04X} ({char!r})"
                violations.append((line_num, col, desc))
                # Limit per-file output to avoid enormous test failures.
                if len(violations) >= 20:
                    violations.append((-1, -1, "... (truncated, 20+ violations)"))
                    return violations
    return violations


@pytest.mark.skipif(
    PROJECT_ROOT is None,
    reason="Could not locate project root",
)
@pytest.mark.skipif(
    not CODE_FILES,
    reason="No code files found to scan",
)
@pytest.mark.parametrize(
    "code_file",
    CODE_FILES,
    ids=[str(f.relative_to(PROJECT_ROOT)) for f in CODE_FILES] if PROJECT_ROOT else [],
)
def test_code_files_are_pure_ascii(code_file: Path) -> None:
    """Every .py, .ps1, .bat, .sh file must contain only ASCII characters.

    Non-ASCII characters in code files cause cross-platform encoding issues
    when files pass between Windows (cp1252) and Linux (UTF-8) environments.

    If this test fails, replace the flagged characters with ASCII equivalents:
      - Em-dash or en-dash -> hyphen (-)
      - Smart quotes -> straight quotes (' or ")
      - Arrows -> ASCII arrows (-> or <-)
      - Box-drawing -> ASCII art (+, -, |)
      - Ellipsis -> three dots (...)
    """
    violations = _find_non_ascii(code_file)
    if violations:
        rel_path = code_file.relative_to(PROJECT_ROOT) if PROJECT_ROOT else code_file
        detail_lines = []
        for ln, col, desc in violations:
            detail_lines.append(f"  Line {ln}, Col {col}: {desc}")
        detail = "\n".join(detail_lines)
        pytest.fail(
            f"Non-ASCII characters in {rel_path}:\n{detail}\n\n"
            f"Code files must be pure ASCII (0x00-0x7F). "
            f"See markdown.instructions.md for replacement rules."
        )


# ---------------------------------------------------------------------------
# Markdown files: ban the "dangerous six" that cause mojibake.
# Emoji, math symbols, and section signs are allowed.
# ---------------------------------------------------------------------------

# Characters that are ALWAYS banned in .md files because they corrupt
# across codepages. These are the ones that caused real production issues.
BANNED_IN_MARKDOWN = {
    0x2014: "em-dash (use - or --)",
    0x2013: "en-dash (use -)",
    0x2018: "left single smart quote (use ')",
    0x2019: "right single smart quote (use ')",
    0x201C: 'left double smart quote (use ")',
    0x201D: 'right double smart quote (use ")',
}

# Mojibake indicator bytes - when these appear, the file has encoding damage.
MOJIBAKE_INDICATORS = {
    0x00C2: "stray Latin-1 byte (mojibake indicator)",
    0x00C3: "stray Latin-1 byte (mojibake indicator)",
    0x00E2: "stray Latin-1 'a-circumflex' (mojibake from UTF-8 multi-byte)",
    0xFFFD: "Unicode replacement character (encoding failure)",
}


def _collect_markdown_files() -> list[Path]:
    """Collect all .md files in the project, excluding cache directories.

    Returns:
        A list of Path objects for every .md file found.
    """
    if PROJECT_ROOT is None:
        return []

    files: list[Path] = []
    for path in PROJECT_ROOT.rglob("*.md"):
        if any(part in SKIP_DIRS for part in path.parts):
            continue
        files.append(path)
    return sorted(files)


MD_FILES = _collect_markdown_files()


def _find_banned_chars_in_markdown(path: Path) -> list[tuple[int, int, str]]:
    """Find banned characters (smart quotes, em-dashes, mojibake) in a .md file.

    Args:
        path: The Markdown file to scan.

    Returns:
        A list of (line_number, column, character_description) tuples.
    """
    all_banned = {**BANNED_IN_MARKDOWN, **MOJIBAKE_INDICATORS}
    violations: list[tuple[int, int, str]] = []

    try:
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return [(-1, -1, "Could not read file as UTF-8")]

    for line_num, line in enumerate(text.splitlines(), start=1):
        for col, char in enumerate(line, start=1):
            code = ord(char)
            if code in all_banned:
                desc = f"U+{code:04X} - {all_banned[code]}"
                violations.append((line_num, col, desc))
                if len(violations) >= 20:
                    violations.append((-1, -1, "... (truncated, 20+ violations)"))
                    return violations
    return violations


@pytest.mark.skipif(
    PROJECT_ROOT is None,
    reason="Could not locate project root",
)
@pytest.mark.skipif(
    not MD_FILES,
    reason="No markdown files found to scan",
)
@pytest.mark.parametrize(
    "md_file",
    MD_FILES,
    ids=[str(f.relative_to(PROJECT_ROOT)) for f in MD_FILES] if PROJECT_ROOT else [],
)
def test_markdown_no_banned_unicode(md_file: Path) -> None:
    """Markdown files must not contain em-dashes, smart quotes, or mojibake.

    Allowed non-ASCII in .md files:
      - Emoji for checklists (check mark, cross, warning, coloured circles)
      - Math symbols (squared, >=, <=, approx, not-equal, multiplication)
      - Section sign (used in backlog references)
      - Foreign proper nouns (e.g. Portuguese, German names)
      - Currency symbols (GBP, cent)

    Banned (causes real cross-platform corruption):
      - Em-dash and en-dash -> use hyphen
      - Smart/curly quotes -> use straight quotes
      - Mojibake bytes (U+00C2, U+00C3, U+00E2, U+FFFD) -> file is damaged
    """
    violations = _find_banned_chars_in_markdown(md_file)
    if violations:
        rel_path = md_file.relative_to(PROJECT_ROOT) if PROJECT_ROOT else md_file
        detail_lines = []
        for ln, col, desc in violations:
            detail_lines.append(f"  Line {ln}, Col {col}: {desc}")
        detail = "\n".join(detail_lines)
        pytest.fail(
            f"Banned Unicode in {rel_path}:\n{detail}\n\n"
            f"See markdown.instructions.md 'Special Characters' section."
        )

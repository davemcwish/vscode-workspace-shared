"""Contract tests for START-HERE-WEBSITE.md file references.

The website start guide contains two kinds of backticked markdown references:

1. Shared-library references, such as prompts/*.prompt.md, instructions/*.instructions.md,
   workflows/*.workflow.md, skills/*.skill.md, chatmodes/*.chatmode.md, and templates/*.template.md.
   These should point to real files in _copilot-shared.

2. Example website-project artifacts, such as website-brief.md or docs/01-website-brief.md.
   These are files a downstream website project may create, so they are intentionally not
   required to exist in _copilot-shared.
"""

import re
from pathlib import Path


def _find_project_root() -> Path:
    """Find the project root by looking for docs/ folder (synced from _copilot-shared)."""
    current = Path(__file__).resolve()
    test_dir = current.parent  # The tests/ folder
    project_root = test_dir.parent  # The project root (Salesforce, Trails and Tails, or _copilot-shared)
    docs_guide = project_root / "docs" / "START-HERE-WEBSITE.md"
    if docs_guide.exists():
        return project_root
    raise FileNotFoundError(
        f"Could not find docs/START-HERE-WEBSITE.md in {project_root}"
    )


PROJECT_ROOT = _find_project_root()
GUIDE = PROJECT_ROOT / "docs" / "START-HERE-WEBSITE.md"

# For validating shared-library references, we need to check _copilot-shared
def _find_copilot_shared() -> Path:
    """Find the _copilot-shared directory."""
    current = Path(__file__).resolve()
    for parent in current.parents:
        copilot_shared = parent / "_copilot-shared"
        if copilot_shared.exists():
            return copilot_shared
    raise FileNotFoundError("Could not find _copilot-shared directory")


SHARED_ROOT = _find_copilot_shared()

MARKDOWN_REFERENCE_RE = re.compile(r"`([^`\n]+\.md)`")

SHARED_PREFIXES = (
    "agents/",
    "chatmodes/",
    "instructions/",
    "prompts/",
    "skills/",
    "templates/",
    "workflows/",
)

SHARED_SUFFIXES = (
    ".agent.md",
    ".chatmode.md",
    ".instructions.md",
    ".prompt.md",
    ".skill.md",
    ".template.md",
    ".workflow.md",
)

INTENTIONAL_WEBSITE_PROJECT_ARTIFACTS = {
    "docs/01-website-brief.md",
    "website-brief.md",
    "website-content-plan.md",
    "website-decisions-log.md",
    "website-launch-checklist.md",
    "website-legal-compliance.md",
    "website-maintenance-plan.md",
    "website-platform-decision.md",
    "website-promotion-plan.md",
    "website-security-plan.md",
}


def iter_markdown_references():
    """Yield line-numbered backticked markdown references from START-HERE-WEBSITE.md."""
    for line_number, line in enumerate(
        GUIDE.read_text(encoding="utf-8").splitlines(), start=1
    ):
        for match in MARKDOWN_REFERENCE_RE.finditer(line):
            reference = match.group(1).strip().replace("\\", "/")
            if reference.startswith(("http://", "https://", "/", "./", "../")):
                continue
            yield line_number, reference


def test_website_guide_shared_references_exist():
    """Shared-library references in START-HERE-WEBSITE.md must point to real files."""
    missing_references = []

    for line_number, reference in iter_markdown_references():
        if reference in INTENTIONAL_WEBSITE_PROJECT_ARTIFACTS:
            continue

        if reference.startswith(SHARED_PREFIXES):
            candidate = SHARED_ROOT / reference
            if not candidate.is_file():
                missing_references.append(f"line {line_number}: `{reference}`")

    assert not missing_references, (
        "START-HERE-WEBSITE.md contains shared-library references that do not exist:\n"
        + "\n".join(missing_references)
    )


def test_website_guide_uses_foldered_paths_for_shared_reference_types():
    """Shared reference types should include their folder, not just a bare filename."""
    bare_shared_references = []

    for line_number, reference in iter_markdown_references():
        if reference in INTENTIONAL_WEBSITE_PROJECT_ARTIFACTS:
            continue

        if "/" not in reference and reference.endswith(SHARED_SUFFIXES):
            bare_shared_references.append(f"line {line_number}: `{reference}`")

    assert not bare_shared_references, (
        "START-HERE-WEBSITE.md contains bare shared-library filenames. "
        "Use foldered paths such as `prompts/example.prompt.md` instead:\n"
        + "\n".join(bare_shared_references)
    )

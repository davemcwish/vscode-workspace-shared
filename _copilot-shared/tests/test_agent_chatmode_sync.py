"""Contract test: agent/chatmode pairs must stay behaviourally identical.

Reads the pair inventory from _copilot-shared/AGENT-CHATMODE-SYNC.md and, for
every row marked Paired, asserts the two files have byte-identical bodies once
the THREE intended differences are normalised away:

  1. frontmatter (agent uses name/agents; chatmode uses description/tools),
  2. the H1 line (e.g. "# Doc Writer Agent" vs "# Doc Writer"),
  3. the SYNC NOTE target line (each points at its counterpart).

It also fails if any paired file still contains a stray "Part X of Y" chunk
wrapper -- the copy/paste contamination that caused real drift in this repo.

All files are read as UTF-8 explicitly. PowerShell 5.1 defaults to ANSI, which
previously double-encoded em-dashes; reading as UTF-8 here keeps the test
honest regardless of how the files were generated.
"""

from __future__ import annotations

import re
from pathlib import Path

import pytest

# ---------------------------------------------------------------------------
# Locate _copilot-shared. The test lives in _copilot-shared/tests/ (master)
# but is synced into project tests/ folders (e.g. Salesforce/tests/).
# The discovery logic handles both locations.
# ---------------------------------------------------------------------------


def _find_shared_root() -> Path | None:
    """Locate _copilot-shared by walking upward from the test file.

    Works in two contexts:
      - Master copy: _copilot-shared/tests/ -> parent.parent has the sync doc.
      - Synced copy: Salesforce/tests/ -> walk up to workspace root, find
        _copilot-shared/ as a sibling directory.

    Returns None when the sync doc cannot be found (e.g. CI runners that only
    check out a single project repo without the workspace parent).
    """
    here = Path(__file__).resolve().parent
    # Case 1: we ARE inside _copilot-shared/tests/ (the master copy)
    candidate = here.parent
    if (candidate / "AGENT-CHATMODE-SYNC.md").is_file():
        return candidate
    # Case 2: synced into a project's tests/ folder - walk up to find the
    # _copilot-shared directory as a sibling of the project.
    for ancestor in here.parents:
        candidate = ancestor / "_copilot-shared"
        if (candidate / "AGENT-CHATMODE-SYNC.md").is_file():
            return candidate
    return None


_shared_root = _find_shared_root()

# Skip the entire module when _copilot-shared is not reachable (e.g. CI).
# This is a development-time contract test that validates the shared masters;
# it cannot run without the workspace-level _copilot-shared/ directory.
if _shared_root is None:
    pytest.skip(
        "Skipping agent/chatmode sync tests: _copilot-shared/ not found "
        "(expected in CI where only the project repo is checked out).",
        allow_module_level=True,
    )

# Type narrowing: pytest.skip() raises Skipped (a BaseException subclass) so
# execution never reaches here when _shared_root is None. The assert satisfies
# mypy; the explicit Path annotation ensures function bodies see Path, not
# Path | None (mypy does not propagate module-level narrowing into functions).
assert _shared_root is not None
SHARED_ROOT: Path = _shared_root

SYNC_DOC = SHARED_ROOT / "AGENT-CHATMODE-SYNC.md"


# ---------------------------------------------------------------------------
# Parse the pair table out of AGENT-CHATMODE-SYNC.md.
# Only rows whose status cell contains "Paired" are enforced. Rows that say
# "no chatmode" / "no agent" are agent-only or chatmode-only and skipped.
# ---------------------------------------------------------------------------

# Matches: | `agents/x.agent.md` | `chatmodes/y.chatmode.md` | <status> |
_ROW = re.compile(
    r"^\|\s*`(?P<agent>[^`]+\.agent\.md)`\s*"
    r"\|\s*`(?P<chat>[^`]+\.chatmode\.md)`\s*"
    r"\|\s*(?P<status>[^|]+?)\s*\|\s*$"
)


def _read_utf8(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _discover_pairs() -> list[tuple[str, str]]:
    """All rows marked Paired (any flavour) -- used by the cheap guards."""
    pairs: list[tuple[str, str]] = []
    for line in _read_utf8(SYNC_DOC).splitlines():
        m = _ROW.match(line)
        if m and "Paired" in m.group("status"):
            pairs.append((m.group("agent"), m.group("chat")))
    return pairs


def _discover_identical_pairs() -> list[tuple[str, str]]:
    """Only rows whose status declares the byte-identical contract.

    These pairs (e.g. doc-writer) are generated/maintained to be identical
    bodies. Pairs marked '(divergent)' are intentionally different documents
    that share an identity but not their prose, and are NOT body-checked.
    """
    pairs: list[tuple[str, str]] = []
    for line in _read_utf8(SYNC_DOC).splitlines():
        m = _ROW.match(line)
        if m and "identical" in m.group("status").lower():
            pairs.append((m.group("agent"), m.group("chat")))
    return pairs


PAIRS = _discover_pairs()
IDENTICAL_PAIRS = _discover_identical_pairs()


# ---------------------------------------------------------------------------
# Normalisation: reduce a file to its comparable "behaviour body".
# ---------------------------------------------------------------------------

_FRONTMATTER = re.compile(r"(?s)\A\s*---.*?---\s*")
_HTML_COMMENT = re.compile(r"(?s)<!--.*?-->")
_H1 = re.compile(r"^#\s+.*$", re.MULTILINE)
_CHUNK_WRAPPER = re.compile(r"Part\s+\d+\s+of\s+\d+", re.IGNORECASE)


def _normalise_body(text: str) -> str:
    """Reduce a file to its comparable behaviour body.

    Removes the three categories of *intended* difference:
      1. frontmatter,
      2. ALL HTML comments (SYNC NOTE, markdownlint-disable, etc.),
      3. the H1 line.
    """
    body = _FRONTMATTER.sub("", text)
    body = _HTML_COMMENT.sub("", body)
    body = _H1.sub("<H1>", body)
    body = body.replace("\r\n", "\n").replace("\r", "\n")
    body = "\n".join(ln.rstrip() for ln in body.split("\n"))
    body = re.sub(r"\n{3,}", "\n\n", body)
    return body.strip()


# ---------------------------------------------------------------------------
# Tests.
# ---------------------------------------------------------------------------


def test_sync_doc_lists_at_least_one_pair():
    """Guard against a parser/format regression silently disabling the suite."""
    assert PAIRS, (
        "No 'Paired' rows parsed from AGENT-CHATMODE-SYNC.md. The table format "
        "may have changed -- update the row regex in this test."
    )


@pytest.mark.parametrize("agent_rel,chat_rel", PAIRS, ids=[a for a, _ in PAIRS])
def test_paired_files_exist(agent_rel: str, chat_rel: str):
    agent = SHARED_ROOT / agent_rel
    chat = SHARED_ROOT / chat_rel
    assert agent.is_file(), f"Missing agent file: {agent}"
    assert chat.is_file(), f"Missing chatmode file: {chat}"


@pytest.mark.parametrize("agent_rel,chat_rel", PAIRS, ids=[a for a, _ in PAIRS])
def test_no_chunk_wrappers(agent_rel: str, chat_rel: str):
    """Stray 'Part X of Y' lines mean delivery scaffolding was pasted in."""
    for rel in (agent_rel, chat_rel):
        path = SHARED_ROOT / rel
        if not path.is_file():
            pytest.skip(f"{rel} missing; covered by existence test.")
        hits = _CHUNK_WRAPPER.findall(_read_utf8(path))
        assert not hits, (
            f"{rel} contains chunk-wrapper text {hits}. Remove the 'Part X of "
            f"Y' delivery scaffolding that was accidentally pasted in."
        )


def test_at_least_one_identical_pair_is_enforced():
    """Guard: the strict body-identity contract must cover >=1 pair.

    If this fails, either AGENT-CHATMODE-SYNC.md lost its '(identical)' marker
    or the status wording changed. Do NOT 'fix' it by deleting this test --
    restore the marker so the strict guard keeps protecting doc-writer.
    """
    assert IDENTICAL_PAIRS, (
        "No '(identical)' pairs parsed from AGENT-CHATMODE-SYNC.md. The strict "
        "body-identity guard is now testing nothing. Restore the "
        "'Paired (identical)' status on the doc-writer row."
    )


_IDENTICAL_IDS = [a for a, _ in IDENTICAL_PAIRS]


@pytest.mark.parametrize("agent_rel,chat_rel", IDENTICAL_PAIRS, ids=_IDENTICAL_IDS)
def test_bodies_are_identical(agent_rel: str, chat_rel: str):
    """Strict guard: byte-identical bodies for pairs that claim that contract."""
    agent = SHARED_ROOT / agent_rel
    chat = SHARED_ROOT / chat_rel
    if not (agent.is_file() and chat.is_file()):
        pytest.skip("File missing; covered by existence test.")

    agent_body = _normalise_body(_read_utf8(agent))
    chat_body = _normalise_body(_read_utf8(chat))

    if agent_body != chat_body:
        # Produce a readable first-difference message instead of dumping
        # the whole file.
        a_lines = agent_body.split("\n")
        c_lines = chat_body.split("\n")
        for i, (al, cl) in enumerate(zip(a_lines, c_lines, strict=False)):
            if al != cl:
                pytest.fail(
                    f"Pair drift in {agent_rel} vs {chat_rel} at body line "
                    f"{i + 1}:\n  agent:    {al!r}\n  chatmode: {cl!r}\n"
                    f"Regenerate the chatmode from the agent "
                    f"(build-chatmode-from-agent.ps1) or vice versa."
                )
        # Same prefix, different length.
        pytest.fail(
            f"Pair drift in {agent_rel} vs {chat_rel}: bodies share a prefix "
            f"but differ in length ({len(a_lines)} vs {len(c_lines)} lines)."
        )

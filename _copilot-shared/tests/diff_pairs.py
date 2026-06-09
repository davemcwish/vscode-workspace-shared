# save as scripts/diff_pairs.py, run: python scripts/diff_pairs.py
import difflib
import sys, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))

from tests.test_agent_chatmode_sync import (
    SHARED_ROOT, PAIRS, _normalise_body, _read_utf8,
)

for agent_rel, chat_rel in PAIRS:
    a = _normalise_body(_read_utf8(SHARED_ROOT / agent_rel)).split("\n")
    c = _normalise_body(_read_utf8(SHARED_ROOT / chat_rel)).split("\n")
    if a != c:
        print(f"\n{'='*70}\n{agent_rel}  vs  {chat_rel}\n{'='*70}")
        print("\n".join(difflib.unified_diff(a, c, "agent", "chatmode", lineterm="")))

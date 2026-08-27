# Scope: Bring `_copilot-shared/scaffold/*.py` Under the Quality Gate

- **Status:** Proposed - not started
- **Owner:** Parent workspace repo (`vscode-workspace-shared`)
- **Raised:** 2026-08-26, after the parent-repo gate was made operational (`e37f6cd`)
- **Decision required:** sequence now, or defer

---

## 1. Problem

The parent repo's quality gate now runs, but it does not see the scaffold
Python files. Of the 10 Python files in the parent repo, only 5 are checked:

| Location | Files | Currently checked by |
| --- | --- | --- |
| `_copilot-shared/tests/` | 5 | ruff, mypy, pytest |
| `_copilot-shared/scaffold/` | 4 | **nothing** |
| repo root (`security_scan.py`) | 1 | **nothing** |

This matters more than a normal coverage gap, because these are not ordinary
scripts. `security_scan.py` is the advisory security scanner that every other
repo in the workspace runs. It is currently the least-inspected file in the
workspace while being the one that inspects everything else.

### Why it is skipped

Two independent causes, both in `_copilot-shared/scaffold/sanity.bat`.

**Cause A - target detection omits the directories.** Targets are built from a
fixed list plus one special case:

```bat
for %%D in (src tests scripts frontend) do (
    if exist %%D set "PY_TARGETS=!PY_TARGETS! %%D"
)
if exist _copilot-shared\tests set "PY_TARGETS=!PY_TARGETS! _copilot-shared\tests"
```

The parent repo has no `src`, `scripts`, or `frontend`, so `PY_TARGETS` resolves
to `_copilot-shared\tests` alone. `scaffold` and root `security_scan.py` are
never named.

**Cause B - bandit has no `_copilot-shared` case at all.** Step 4 builds its own
target list and was never given the special case that `PY_TARGETS` received:

```bat
set BANDIT_TARGETS=
if exist src (set "BANDIT_TARGETS=!BANDIT_TARGETS! src")
if exist scripts (set "BANDIT_TARGETS=!BANDIT_TARGETS! scripts")
if exist frontend (set "BANDIT_TARGETS=!BANDIT_TARGETS! frontend")
if defined BANDIT_TARGETS ( ... ) else (
    echo SKIPPED: pyproject.toml found but no src, scripts, or frontend directories to scan.
)
```

So bandit reports `SKIPPED` in the parent repo permanently, and would continue
to do so even if Cause A were fixed on its own.

---

## 2. Measured cost

Each tool was dry-run against `_copilot-shared\scaffold` before writing this
document. The results are lopsided, and that shapes the recommendation.

| Gate step | Result today | Work to go green |
| --- | --- | --- |
| 1. `ruff format --check` | 4 files would be reformatted | Run `ruff format` |
| 2. `ruff check` | **150 errors** | Real remediation - see below |
| 3. `mypy` | Success: no issues found in 4 source files | **None** |
| 4. `bandit` | Clean, no output | **None** |

Steps 3 and 4 are already passing. They are being skipped for free - the files
would clear them today with no code change at all.

### The 150 ruff errors

| Count | Rule | Meaning |
| --- | --- | --- |
| 86 | `E501` | Line too long |
| 23 | `D103` | Missing docstring in public function |
| 16 | `D212` | Multi-line docstring summary placement |
| 13 | `W293` | Whitespace on blank line |
| 2 | `C420` | `dict.fromkeys` over dict comprehension |
| 2 | `D101` | Missing docstring in public class |
| 2 | `PLR5501` | `else: if` should be `elif` |
| 2 | `UP035` | Deprecated import |
| 1 each | `ARG005`, `I001`, `PLR0912`, `S603` | Unused lambda arg, unsorted imports, too many branches, subprocess call |

23 are auto-fixable. The remaining ~127 are mostly mechanical (`E501`, `W293`)
but 23 `D103` docstrings must be hand-written, and this repo's docstring
standard is complete-beginner prose, not one-liners. `PLR0912` and `S603`
require judgement rather than reformatting.

### Distribution by file

| File | Ruff errors | Lines | Force-synced to other repos? |
| --- | --- | --- | --- |
| `security_scan_teaching_docstrings.py` | 62 | 641 | No |
| `security_scan.py` | 53 | 627 | **Yes** |
| `create_security_scan_pack.py` | 33 | 744 | No |
| `update_packages.py` | 2 | 198 | No |

---

## 3. Blast radius

This is the finding that should drive the decision, and it is not the one that
looks obvious.

`powershell/sync-shared-copilot.ps1` defines a set of files copied into **every
project root on every sync run**:

```powershell
$ScaffoldSyncFiles = @(
    ".markdownlint.json",
    "sanity.bat",
    "sanity_v.bat",
    "security_scan.py",
    "security_scan.ps1",
    "sync-backups.ps1"
)
```

Both files this change touches are in that list.

### 3a. `sanity.bat` - low risk

Editing it lands the new version in all five repos on the next sync. However,
`_copilot-shared/` exists **only in the parent repo** - verified `False` for
`Salesforce`, `trails-and-tails`, `eu-spm`, and `woprcrt-terminal-main`. Every
new target is added behind an `if exist _copilot-shared\...` guard, so in the
four sibling repos the guard is false and the block is inert. Their target
lists, and therefore their gate results, are unchanged.

### 3b. `security_scan.py` - the actual risk

The root copy is byte-identical to the scaffold copy (SHA256 match, confirmed).
It is **tracked in three sibling repos**:

| Repo | `security_scan.py` tracked |
| --- | --- |
| `Salesforce` | Yes |
| `trails-and-tails` | Yes |
| `eu-spm` | Yes |
| `woprcrt-terminal-main` | No |

So reformatting and re-linting the scanner does not stay in the parent repo. On
the next sync it produces a modified, tracked file in three other repositories,
each of which then needs its own review, Changelog entry, commit and push. A
53-error cleanup of a 627-line security scanner is not a cosmetic diff, and it
arrives in three repos at once.

This is the difference between "add two lines to a batch file" and "change the
security scanner used by the whole workspace".

---

## 4. Proposed change

### 4a. `_copilot-shared/scaffold/sanity.bat`

Extend the existing special case to cover scaffold, and give bandit the case it
never had:

```bat
rem Existing:
if exist _copilot-shared\tests set "PY_TARGETS=!PY_TARGETS! _copilot-shared\tests"
rem Add:
if exist _copilot-shared\scaffold set "PY_TARGETS=!PY_TARGETS! _copilot-shared\scaffold"

rem Add to the bandit target block:
if exist _copilot-shared\scaffold (set "BANDIT_TARGETS=!BANDIT_TARGETS! _copilot-shared\scaffold")
```

Root `security_scan.py` is deliberately **excluded** from the target lists. It
is a generated copy of the scaffold original; linting both would double every
finding and create a drift trap where the copy is fixed and the source is not.
The scaffold copy is the source of truth and the only one that should be gated.

### 4b. `pyproject.toml` (parent repo)

Add `_copilot-shared/scaffold` to `[tool.mypy] files` so mypy checks it under
the gate rather than only on demand. No ruff configuration change is needed -
ruff takes its targets from the command line.

### 4c. Remediation

Fix the 150 ruff errors across the four scaffold files, in the order set out in
section 5.

---

## 5. Sequencing (this ordering is load-bearing)

The change **must not** land before the files are clean. `sanity.bat` is
force-synced, so merging the targeting change first turns the gate red in the
parent repo immediately, and puts a batch file referencing failing targets into
four other repos on the next sync.

Recommended order:

1. **Split `security_scan.py` out.** Treat it as its own PR with its own review,
   because it propagates to three sibling repos. Reformat, fix its 53 errors,
   sync, then commit and Changelog in `Salesforce`, `trails-and-tails` and
   `eu-spm` in the same session so the three repos never sit on a stale copy.
2. **Clean the three parent-only files** (`security_scan_teaching_docstrings.py`
   62, `create_security_scan_pack.py` 33, `update_packages.py` 2). No blast
   radius - these are not synced. Can be one PR.
3. **Land the `sanity.bat` and `pyproject.toml` targeting change last**, once
   steps 1 and 2 make it a no-op on a clean tree. Verify with a full `sanity.bat`
   run in the parent, then sync and re-run the gate in each sibling to confirm
   the guarded blocks really are inert.

---

## 6. Recommendation

**Split the work, and do the cheap half now.**

Steps 3 and 4 of the gate - mypy and bandit - already pass on these files. The
only thing standing between the workspace's security scanner and bandit coverage
is a missing `if exist` line. That half is genuinely free.

The ruff half is not free: 150 errors, 23 hand-written beginner-standard
docstrings, and a 53-error diff to a security scanner that propagates into three
other repositories.

Two options:

- **Option A (recommended).** Land bandit and mypy coverage now behind the
  guards, and defer ruff by leaving `_copilot-shared\scaffold` out of
  `PY_TARGETS` until steps 1 and 2 above are done. Immediate security benefit,
  no remediation debt, no blast radius. The ruff gap stays open but is recorded
  here.
- **Option B.** Do the whole thing in the sequence in section 5. Higher value,
  but it is a multi-PR piece of work touching four repos, and it should not be
  started in the same session as unrelated changes.

Against Option A, the honest argument is that a partial gate can read as "this
directory is covered" when it is only two-thirds covered. That is mitigated by
this document and by the Changelog entry, but it is a real cost and worth
weighing before choosing.

What I may be missing: whether the three sibling repos are at a point in their
own release cycles where an unrelated scanner diff is unwelcome. That is your
call, not mine.

---

## 7. Open questions

1. Option A or Option B?
2. Should root `security_scan.py` be added to `.gitignore` in the sibling repos
   instead of being tracked, so scaffold syncs stop producing reviewable diffs
   in three places? That would shrink the blast radius permanently and is
   arguably the better underlying fix - but it changes how the sync contract
   works and deserves its own scoping.
3. Does the `S603` subprocess finding in the scaffold reflect a real gap against
   `security.instructions.md`, or is it the documented false positive pattern?
   It should be read before being silenced.

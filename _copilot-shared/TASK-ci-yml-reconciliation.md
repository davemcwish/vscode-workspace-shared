# TASK (Draft): Shared `ci.yml` Reconciliation

**Status:** Draft - not started. Do NOT execute the fix from this document.
**Raised:** 2026-07-08, during the Python 3.13.5 migration + shared doc sync.
**Owner (proposed):** route through the CI/CD workflow governed by
`.github/instructions/ci-cd.instructions.md`. Any change is CRITICAL-tier and
needs explicit human approval before commit/push.

---

## 1. Why this task exists

While syncing the shared Copilot artefacts (to propagate an unrelated docs
change), the sync **overwrote `eu-spm`'s committed `.github/workflows/ci.yml`**
with the generic shared master and, in doing so, **downgraded** it. The change
was reverted immediately (working-tree only, nothing committed), but the
underlying problem remains and needs a proper fix.

## 2. Confirmed facts

- `sync-shared-copilot.ps1` mirrors `_copilot-shared/workflows/` into each
  project's `.github/workflows/` on **every** run (the `workflows` folder is in
  the script's managed `$Folders` list, which uses source-wins copy). So
  `ci.yml` is **blindly synced** from the shared master.
- The version the sync pushed into `eu-spm` differed from `eu-spm`'s committed
  `ci.yml` as follows (sync master -> what eu-spm had):
  - `actions/checkout` and `actions/setup-python` were **unpinned** (`@v4` /
    `@v5`) instead of **SHA-pinned** to a specific release.
  - The top-level least-privilege block **`permissions: {}`** (plus the
    per-job `contents: read`) was **absent**.
  - It assumed a `src/` layout and ran `pip install -e .`, and it stripped an
    `--index-url` (JFrog) directive from `requirements*.txt`.
- `eu-spm` does **not** use that shape: it is scripts-only (no installable
  `src/` package), installs from `requirements*.in`, and uses public PyPI (no
  committed JFrog `--index-url`). So the synced file was **structurally wrong**
  for `eu-spm` as well as **less hardened**.
- `.github/instructions/ci-cd.instructions.md` **requires** SHA-pinned Actions
  and least-privilege `GITHUB_TOKEN` permissions. The synced master therefore
  does **not** satisfy the repo's own CI/CD hardening rules.

## 3. Hypotheses to verify (do this first in the fix task)

These are strongly suspected but must be confirmed before acting:

1. **The shared master `_copilot-shared/workflows/ci.yml` is the generic,
   under-hardened, `src/`-shaped file** (i.e. the source of the regression).
2. **`eu-spm`'s hardened `ci.yml` was edited directly in the project**, which
   violates the "edit the shared master first, then sync" ownership rule - which
   is *why* the sync clobbered it.
3. **`Salesforce`'s `ci.yml` was not flagged as modified by the sync**, implying
   its committed file already equals the shared master. Confirm whether that
   means Salesforce is *also* running the under-hardened workflow, or whether
   its file legitimately matches a hardened master.
4. **One shared `ci.yml` cannot serve both project shapes** without
   parameterisation: `Salesforce` (src/ layout, `requirements.txt`, JFrog
   index handling) vs `eu-spm` / `trails-and-tails` (scripts-only,
   `requirements*.in`, public PyPI, no editable install).

## 4. Related finding (same class of problem)

`sync-shared-copilot.ps1` and the scaffold hard-code **`py -3.12`**:

- The sync's pre-sync validation step runs `& py -3.12 -m pytest ...`.
- `scaffold-README.md` documents `sanity.bat` / `sanity_v.bat` using
  `set PY_CMD=py -3.12`.

Both are now **stale versus Python 3.13** and **break on machines where the
`py` launcher is not on `PATH`** (as on the current managed build, where the
launcher exists only at `...\Python\Launcher\py.exe`). This should be fixed in
the same initiative, because it is the same "hard-coded environment assumption"
root cause.

## 5. Options considered

| Option | Summary | Trade-off |
| --- | --- | --- |
| A. Parameterise one shared `ci.yml` | Template variables for dirs, editable install, index handling | Most flexible; most complex; GitHub Actions has limited templating |
| B. Make `ci.yml` project-owned (scaffold-once) | Treat it like `pyproject.toml`: copy once, never blind-sync; keep a hardened reference template in shared | Simple; matches an existing, proven pattern; each project keeps its correct shape |
| C. Two shared templates | `ci-src-layout.yml` and `ci-scripts-layout.yml`, sync the right one | Fewer files than per-project, but still needs per-project selection logic |

## 6. Recommendation

**Option B**, plus a hardening pass:

1. Remove `ci.yml` from the blind `workflows` sync (or make the sync skip
   `ci.yml` specifically), so a project's workflow is **project-owned** - the
   same model already used for `pyproject.toml`.
2. Keep a single **canonical, fully hardened reference template** in
   `_copilot-shared/` (SHA-pinned Actions, `permissions: {}` + least-privilege
   per job, no assumptions baked in) with clearly marked customisation points
   for layout / index / editable-install.
3. Re-harden each project's `ci.yml` to that template's security baseline while
   keeping its correct structural shape.
4. Fix the `py -3.12` hard-coding in `sync-shared-copilot.ps1` and the scaffold
   gate scripts (make the interpreter configurable / launcher-independent).
5. Add a note to `ci-cd.instructions.md` stating `ci.yml` is project-owned and
   must be reconciled against the hardened reference template on change.

## 7. Acceptance criteria

- No project's `ci.yml` is silently overwritten by a shared sync again.
- Every project's `ci.yml` satisfies `ci-cd.instructions.md` (SHA-pinned
  Actions, least-privilege token) **and** matches its own project structure.
- The sync and scaffold no longer assume the `py` launcher or a fixed 3.12.
- The change set is reviewed under the CI/CD workflow and approved by a human
  before commit/push.

## 8. Out of scope / cautions

- This document is a **plan only**. It changes no workflow files.
- Editing any file under `.github/workflows/` triggers the CI/CD hardening
  instructions; treat all findings as CRITICAL and fail-closed.
- No merge, push, deploy, or Production action without explicit human approval.

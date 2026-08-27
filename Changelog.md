# Changelog - Shared Copilot Workspace

<!-- markdownlint-disable MD024 -->
All notable changes to the shared Copilot tooling (`_copilot-shared/`) and
workspace-root scripts are documented here.

Changes to individual sub-projects (Salesforce, Trails and Tails, etc.) are
tracked in each project's own `Changelog.md`.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [2026-08-27] - Scaffold lint coverage, stage 2

### Changed

- `_copilot-shared/scaffold/update_packages.py` now passes `ruff check`
  cleanly. Two findings were resolved, both properly rather than suppressed:
  - **`S603` (subprocess without validated input).** The script may now only
    launch programs on an explicit allow-list (`python`, `bash`, and the
    project's own `sanity` script). The program path is additionally
    re-verified inline against a deny-list pattern immediately before
    `subprocess.run`, and `shell=False` is now explicit. Anything else raises
    `ValueError`. The remaining `# noqa: S603` carries a written rationale.
  - **`PLR0912` (too many branches).** `main()` was split into four named
    helpers - `warn_if_not_in_virtualenv`, `compile_requirements`,
    `install_upgraded_packages`, and `run_sanity_gate` - each with a
    complete-beginner docstring.
- `_copilot-shared/scaffold/create_security_scan_pack.py` now passes
  `ruff check` cleanly (33 findings). Thirteen docstrings were added, an
  unused lambda argument renamed, and eleven teaching-note strings wrapped as
  implicitly-concatenated literals.
- **The generator was emitting lint errors into its own output.** Docstrings
  were built with the opening `"""` alone on its own line (rule `D212`) and
  blank lines were emitted as indentation followed by a newline (rule `W293`).
  Both are now handled by a single new helper, `build_docstring_block`, which
  documents why each rule matters.
- `_copilot-shared/scaffold/security_scan_teaching_docstrings.py` and
  `security_scan_teaching_comments.ps1` regenerated. Both are **generated
  artefacts**, not source, and both were stale - the PowerShell copy predated
  the `shutil` and `zipfile` rules added to `security_scan.ps1`.

### Added

- `[tool.ruff.lint.per-file-ignores]` entry in
  `_copilot-shared/scaffold/pyproject.toml` ignoring `E501` for
  `create_security_scan_pack.py` only. That file embeds the verbatim text of
  the documents it generates, and a few of those lines are longer than 100
  characters because the target format requires it. Re-wrapping them in the
  Python source would change the generated documents.
- A pointer comment in the workspace-root `pyproject.toml` recording that it
  does **not** govern `_copilot-shared/scaffold/`.

### Notes

- **`security_scan_teaching_docstrings.py` was never a hand-editable file.**
  It had 62 lint findings, but hand-fixing them would have been undone by the
  next generator run. Three of those findings (`C420`, `PLR5501`, `UP035`)
  were inherited copies of errors already fixed in `security_scan.py`, which
  is what revealed the file was stale. Regenerating dropped it from 62
  findings to 3; fixing the generator dropped it to zero.
- **Ruff resolves configuration from the nearest `pyproject.toml`.**
  `_copilot-shared/scaffold/` contains its own `pyproject.toml` - the template
  copied into new projects - so the workspace-root config does not apply to
  anything in that folder. This matters for the sequenced gate-targeting
  change, which must account for two config files rather than one.
- **Behaviour was verified, not assumed.** The regenerated teaching scanner
  and the real scanner produce byte-identical JSON output and the same exit
  code when run over the same tree. All five generated Markdown documents are
  byte-identical to the committed copies, which proves the generator refactor
  changed only what it was meant to change.
- `update_packages.py` is **not** in `$ScaffoldSyncFiles`, so this change does
  not propagate automatically. Copies exist in three sibling repositories:
  `trails-and-tails` and `eu-spm` hold byte-identical copies of the previous
  version, and `Salesforce` holds a diverged copy under `scripts/` with its
  own test. Propagating the subprocess allow-list to those copies is tracked
  separately.

---

## [2026-08-27] - Scaffold lint coverage, stage 1

### Changed

- `_copilot-shared/scaffold/security_scan.py` now passes `ruff format` and
  `ruff check` cleanly (53 findings resolved: 36 line-length, 13 missing
  docstrings, plus 4 auto-fixable items). The scanner is the file every project
  in the workspace runs, and until now it was the least-inspected file in the
  workspace.
- Long rule `description` and `recommendation` strings are wrapped as
  implicitly-concatenated literals rather than single over-long lines. The
  resulting message text is unchanged - see Notes.
- `collections.abc.Iterable` moved into a `TYPE_CHECKING` block. It is used
  only in annotations, and `from __future__ import annotations` means it never
  needs to be imported at run time.

### Added

- Complete beginner-standard docstrings for both public classes (`Rule`,
  `Finding`) and all eleven public functions in `security_scan.py`, covering
  arguments, return values, raised exceptions and non-obvious behaviour - for
  example why an unreadable file becomes a `LOW` finding instead of aborting
  the scan, and why `scan_package_json` reports every finding at line 1.
- `_copilot-shared/docs/scope-scaffold-lint-coverage.md` - scope document for
  bringing the remaining scaffold Python files under the quality gate,
  recording the measured remediation cost and the blast radius of editing
  force-synced files.

### Notes

- **Behaviour is unchanged and was verified, not assumed.** Five baselines were
  captured before any edit and re-run afterwards: a scan with 49 findings
  (251 lines of output), a scan with no findings, a JavaScript/frontend scan,
  `--help`, and a non-zero exit via `--fail-on HIGH`. All five outputs are
  byte-identical and the exit codes match. This mattered because wrapping 32
  message strings by hand could silently have altered the security advice the
  scanner prints.
- A doctest example added during this work contained a secret-shaped literal
  (`password = "..."`), which `detect-secrets` correctly flagged. Rather than
  record it as a baseline false positive - which would have pushed a new
  baseline entry into three sibling repositories - the example was rewritten as
  prose. The docstring now explains why no literal example is given.
- The `SECRETISH_WORDS` constant keeps its single long line under
  `# noqa: E501`. `detect-secrets` matches its allow-list pragma per line, so
  splitting the string would require repeating the pragma on every fragment.
- Step 4 of the gate (bandit) still reports `SKIPPED` in this repository.
  `security_scan.py` already passes bandit and mypy; only the `sanity.bat`
  targeting change is missing, and that is deliberately sequenced last. See the
  scope document.

---

## [2026-08-26]

### Added

- **Working quality gate for the workspace-root repository.** `sanity.bat` was
  present but five of its seven steps were failing with `No module named ...`,
  so this repository had no effective linting, type-checking, secret-scanning,
  or test enforcement at all. The gate now reports
  `SUCCESS: All checks passed` with **1505 tests passing**.
  - `requirements-dev.txt` (new) - pins the gate toolchain: `ruff==0.15.7`,
    `mypy==1.19.1`, `bandit==1.7.9`, `detect-secrets==1.5.0`,
    `pytest-xdist==3.8.0`, alongside the already-present `pytest` and
    `pytest-cov`. Versions deliberately match the sibling projects so a rule
    that passes in one repository behaves identically in the others. There is
    no matching `requirements.in` - this repository has no runtime
    dependencies.
  - `pyproject.toml` (new) - adapted from
    `_copilot-shared/scaffold/pyproject.toml`. The scaffold assumes a
    `src/` + `scripts/` layout; this repository has neither, so ruff, mypy,
    and pytest are pointed at `_copilot-shared/tests` instead. Sibling project
    directories are excluded from every tool so the workspace-root gate never
    reaches into a repository that owns its own gate. Coverage thresholds are
    deliberately **not** enabled - the suite validates Markdown artefact
    pairing and ASCII rules rather than exercising an importable package, so a
    line-coverage percentage would be meaningless.
  - `.secrets.baseline` (new) - generated across the 252 tracked files. It
    contains one reviewed false positive: a regex in
    `security_scan_teaching_comments.ps1` that *lists* secret keywords
    (`api_key|secret|token|...`) as scanner rule data. Path separators were
    converted to POSIX `/` per the cross-platform rule, and the UTF-8 BOM that
    PowerShell 5.1 writes was stripped - with it, detect-secrets fails with
    `Unable to read baseline`.

- **`powershell/Compare-Folders.ps1`** - a read-only helper that compares two
  directory trees recursively and reports three kinds of difference: missing in
  destination, content mismatch, and extra item in destination. Two comparison
  modes: the default fingerprints each file by size plus last-write timestamp
  (fast), and `-UseChecksums` fingerprints by SHA256 (slower, but proof against
  a change that preserves both size and timestamp). The script never creates,
  modifies, or deletes anything in either folder.
  - Completed the comment-based help to meet the repository PowerShell
    documentation standard: `.PARAMETER` blocks for all three parameters, two
    `.EXAMPLE` blocks, and a `.NOTES` block recording the read-only guarantee.
    The description now explains the speed-versus-reliability trade-off of
    `-UseChecksums`, including the fact that it forces OneDrive to download any
    "cloud-only" files it touches.

### Fixed

- **`Compare-Folders.ps1` silently ignored hidden and system files.**
  `Get-ChildItem` omits them unless `-Force` is supplied, so two folders that
  differed only by a hidden file were reported as **"Success: Folders are
  identical!"**. For a tool whose entire purpose is verifying that a backup
  matches its source, a false pass is the worst possible failure mode. Now
  scans with `-Force`.
- **`Compare-Folders.ps1` hard-coded the Windows path separator.** The relative
  path was derived with `.TrimStart('\')`, so under PowerShell Core on
  Linux/macOS every relative key retained a leading `/` and *every* file was
  reported as differing. Now trims both `DirectorySeparatorChar` and
  `AltDirectorySeparatorChar`.
- **`Compare-Folders.ps1` miscalculated relative paths when the caller supplied
  a trailing separator.** `$item.FullName.Substring($Path.Length)` shifted by
  one character for `"D:\Reports\"` versus `"D:\Reports"`, corrupting every key
  in the snapshot. The root is now normalised with `Resolve-Path` and its
  trailing separator stripped before any offset arithmetic.
- Switched `Get-ChildItem` and `Get-FileHash` to `-LiteralPath` so folder names
  containing PowerShell wildcard characters (`[`, `]`, `*`, `?`) are treated as
  literal text rather than glob patterns.
- **Stripped UTF-8 BOMs from `powershell/Compare-Folders.ps1` and
  `powershell/count-pdf-total-enhanced.ps1`.** A BOM decodes to `U+FEFF`, which
  is non-ASCII, so both files violated the repository's pure-ASCII rule for
  code files. This was a pre-existing failure in
  `count-pdf-total-enhanced.ps1` that had never been visible because the test
  suite could not run.
- **Annotated `iter_markdown_references()` in
  `_copilot-shared/tests/test_website_guide_references.py`** with
  `-> Iterator[tuple[int, str]]`. Under mypy `strict`, calling an unannotated
  function from a typed context raises `no-untyped-call`; this was the only
  type error in the repository.

### Changed

- Regenerated `_copilot-shared/MANIFEST.md` (automatic timestamp update from
  the last `sync-shared-copilot.ps1` run).

### Notes

- `Compare-Folders.ps1` verified manually against temporary fixtures: a
  hidden-only difference is now detected; identical trees report success both
  with and without a trailing separator on the input paths; and `-UseChecksums`
  agrees with the fast path.
- Two known `Compare-Folders.ps1` limitations were reviewed and deliberately
  left as-is. The fast comparison mode can report spurious `Content Mismatch`
  results when comparing across filesystems, because NTFS stores timestamps at
  100-nanosecond resolution while FAT/exFAT stores them at 2-second resolution
  - use `-UseChecksums` for drive-to-USB verification. The script also reports
  differences but does not offer to reconcile them, which is intentional: it is
  read-only by design.
- **Step 4 (bandit) still reports `SKIPPED`.** `sanity.bat` looks for `src`,
  `scripts`, or `frontend` directories, and this repository has none - its
  Python lives in `_copilot-shared/tests/` and `_copilot-shared/scaffold/`.
  Fixing this means changing the shared scaffold `sanity.bat`, which is synced
  to every project, so it was left for a separate deliberate change rather
  than bundled here.
- **`security_scan.py` and `_copilot-shared/scaffold/*.py` are outside the
  gate's target list** for the same reason: `sanity.bat` only collects `src`,
  `tests`, `scripts`, `frontend`, and `_copilot-shared\tests`. They are linted
  by neither ruff nor mypy today.

---

## [2026-07-16]

### Changed

- **REQ-T PR 6: rewrote both shared PDF export guides**
  (`_copilot-shared/docs/export_contract_pdfs_guide.md` and
  `_copilot-shared/docs/export_quote_pdfs_guide.md`, the source of truth, then
  synced to every project's `docs/`). The guides now document the full REQ-T
  behaviour that shipped in PRs 1-5:
  - **Filename scheme** - Contract:
    `<ContentDocumentId>_<shortened title>.pdf`; Quote:
    `<QuoteNumber>_<QuoteId>_<shortened quote name>_QuoteCustomPDF.pdf`; the
    `.pdf` extension is never truncated; the `_short_path_fallback/` scheme; and
    why `LatestPublishedVersionId` is dropped from the Contract name but kept in
    the manifest.
  - **How downloads are verified** - the four verification tiers (metadata and
    header; full read-back with `%%EOF` / SHA-256 / wire-completeness / Contract
    MD5 vs `ContentVersion.Checksum`; `pikepdf`/`pypdfium2` structural parse; and
    the OneDrive placeholder check), including skip-path re-verification.
  - **End-of-run reconciliation** - the three-way (master / manifest / disk)
    report, the independent aggregate `COUNT()` leg, and the fail-closed
    non-zero exit.
  - **OneDrive and cloud placeholder files** - detection, the confirmation
    prompt, `--allow-onedrive`, and the "Always keep on this device" guidance.
  - **PII and generated reports** - never commit manifests, logs, or reports.
  - Added the `--allow-onedrive` flag to both CLI reference tables (audited 1:1
    against each script's `--help`) and the `pikepdf`/`pypdfium2` dependency
    note. markdownlint-clean; no em-dashes or smart quotes.

---

## [2026-07-09]

### Changed

- **`ci.yml` is now PROJECT-OWNED (scaffold-once), not blind-synced**
  (`powershell/sync-shared-copilot.ps1`). The `workflows` folder is still
  mirrored into every project's `.github/workflows/`, but `ci.yml` is now
  excluded from that copy so each project keeps its own, correctly shaped CI
  workflow. The three projects have genuinely different shapes and one file
  cannot serve them all: `Salesforce` has an installable `src/` package with
  compiled `requirements*.txt` (plus a JFrog index), `eu-spm` is scripts-only
  with `requirements*.in` and a hardened (SHA-pinned, least-privilege) workflow,
  and `trails-and-tails` is a docs/website repo with no importable Python
  source. Implementation:
  - Added a `$FolderExcludeFiles` map (`workflows` -> `ci.yml`) beside
    `$Folders`, documenting why `ci.yml` is project-owned.
  - Added an optional `-ExcludeFiles` parameter to `Sync-FolderStrict` that
    passes the file names straight to robocopy's `/XF` (exclude-file) flag.
  - Both sync loops (the ROOT workspace `.github/` and each project's
    `.github/`) now pass `$FolderExcludeFiles[$folder]`.
  The shared `_copilot-shared/workflows/ci.yml` is intentionally kept in place
  so the stale-file check still recognises each project's `ci.yml`; it is never
  copied. This fixes the regression recorded in
  `_copilot-shared/TASK-ci-yml-reconciliation.md`, where a blind sync silently
  downgraded `eu-spm`'s hardened workflow (stripped SHA-pinning and the
  least-privilege `permissions:` block).
- **Marked `_copilot-shared/workflows/ci.yml` as a REFERENCE TEMPLATE ONLY.**
  Added a header comment stating the file is project-owned and no longer synced,
  listing the three project shapes, and pointing to
  `TASK-ci-yml-reconciliation.md`. Also reverted an abandoned, in-progress
  "auto-detect project layout" edit to this master - that approach was replaced
  by the project-owned model above.
- **Updated `_copilot-shared/TASK-ci-yml-reconciliation.md`** to reflect that
  Option B (make `ci.yml` project-owned) was implemented, and added a short
  follow-up backlog (Section 9): (1) harden `Salesforce`'s `ci.yml` (still
  unpinned Actions, no `permissions:` block) and confirm `eu-spm`'s;
  (2) right-size `trails-and-tails/pyproject.toml` so its local `sanity.bat`
  (mypy + coverage) matches the project-owned CI; (3) remove the `py -3.12`
  hard-coding from the sync validation and scaffold gate scripts. This task
  doc is not a synced artefact.

---

## [2026-07-08]

### Added

- **Python engine upgrade guide and GitHub CLI section in the shared
  getting-started doc** (`_copilot-shared/docs/START-HERE-WINDOWS.md`):
  - New `#### Upgrade it (moving to a newer Python engine)` subsection with the
    exact, beginner-friendly steps for rebuilding a project's `.venv` on a newer
    Python (back up the old `.venv`, create a fresh one with the new engine,
    reinstall dependencies one file at a time, `pip check`, run the tests, point
    VS Code at the new interpreter, then delete the backup). Written
    version-agnostic so it applies to any future upgrade.
  - New `### GitHub CLI` section (install, verify, `gh auth login`, and an
    in-place upgrade note), plus an "Upgrade it" note on the Git section stating
    that both tools upgrade in place, unlike the Python engine.
  - New "No `py` launcher?" note under the Python verify step, showing the full
    `python.exe` path alternative for managed/enterprise builds (e.g.
    NativePython) that don't register the `py` launcher on `PATH`.
- **New shared doc `_copilot-shared/docs/python-package-index-policy.md`**
  recording the company-mandated JFrog gold-remote index, that installable
  package versions are constrained to what that mirror serves (e.g. `pikepdf`
  tops out at 9.11.0 here, not the 10.x on public PyPI), how to check available
  versions with `pip index versions`, and a note that other environments without
  this mirror may use other versions. Propagated to every project's `docs/`.
- **New draft task `_copilot-shared/TASK-ci-yml-reconciliation.md`** capturing a
  regression found during the sync: the blind `workflows` sync overwrote
  `eu-spm`'s hardened `ci.yml` with the generic, under-hardened shared master
  (unpinned Actions, missing `permissions: {}`, wrong `src/`+JFrog shape). The
  regression was reverted (working-tree only). The doc records confirmed facts,
  hypotheses to verify, the related `py -3.12` hard-coding in the sync/scaffold,
  and a recommended fix (make `ci.yml` project-owned like `pyproject.toml`,
  re-harden to a canonical template) routed through the CI/CD workflow. Not a
  synced doc; no workflow files were changed.

### Changed

- **Made the Python section of `START-HERE-WINDOWS.md` version-agnostic.** The
  `### Python 3.12` heading is now `### Python Engine`; the body states the
  projects need "Python 3.12 or newer" and records "at the time of writing, we
  used Python 3.13.5" instead of pinning 3.12. The stray `3.12` / `Python312`
  references in Parts 2.3, 4.1, and Troubleshooting now show 3.13 with a note to
  substitute your installed version. Propagates to every project's `docs/` on
  the next `sync-shared-copilot.ps1` run.

---

## [2026-07-07]

### Added

- **Two file-path SAST rules in the shared local scanner**
  (`_copilot-shared/scaffold/security_scan.py` and its PowerShell twin
  `security_scan.ps1`):
  - `PY-SHUTIL-DYNAMIC-PATH` (MEDIUM) - flags `shutil.move` / `copy` / `copy2` /
    `copyfile` / `copytree` calls, which Cycode reports as "Unsanitized dynamic
    input in file path".
  - `PY-ZIPFILE-DYNAMIC-PATH` (MEDIUM) - flags `zipfile.ZipFile()` opened on a
    non-literal path.
  Both recommend validating the source and destination with
  `resolve_safe_path()` before the sink. Added after a live Cycode "Unsanitized
  dynamic input in file path" finding on a `shutil.move` sink slipped past the
  local scanner during the Salesforce Windows long-path work. The rules
  propagate to every project root on the next sync.

### Changed

- **Realigned the shared security guidance to what Cycode-SAST actually
  accepts** (`_copilot-shared/instructions/security.instructions.md` and
  `_copilot-shared/skills/security.skill.md`). Cycode-SAST is the authority: its
  **intra-procedural** taint analysis does not follow a validator that lives in
  another module, so the previous guidance - which prohibited the local
  `match.group(0)` re-verification - described a state that does **not** pass the
  gate (proven by `data_export.py`, which needs that re-verification to clear
  Cycode). The docs now document the two-step file-path pattern used across the
  codebase (`data_export.py`, `list_objects.py`, `build_data_dictionary.py`,
  `excel_report.py`): `resolve_safe_path()` performs the real
  `os.path.commonpath` containment check (the actual traversal defence), then a
  local `_SAFE_PATH_PATTERN.fullmatch` re-verifies the resolved path and rebuilds
  it from `match.group(0)` to break the taint chain inside the sink's own
  function. The "Security Philosophy", "Resolving Cycode False Positives
  Correctly", "Subprocess Safety", and "File Path Safety" sections were updated;
  the path regex remains defence-in-depth layered **on top of**
  `resolve_safe_path()`, never a replacement for it.

---

## [2026-06-25]

### Added

- **Tool Reference section in `AGENT-CHATMODE-SYNC.md`**: documents the single
  canonical VS Code tool vocabulary, how the `.agent.md` and `.chatmode.md`
  editor linters validate it against different registries, the tools the
  workspace uses today, a least-privilege ladder, and the wider canonical
  catalogue (`search/usages`, `read/problems`, `search/changes`, `web/fetch`,
  `githubRepo`, ...) that future artifacts can opt into.
- **`docs/canonical-vscode-tool-names.md`**: canonical list of
  current built-in VS Code tool / tool-set names (e.g. `execute/runInTerminal`,
  `search/codebase`, `todos`), used as the source of truth for the tools audit.
- **Accessibility across the full website lifecycle** (`a4be31b`): surfaced
  accessibility awareness at every lifecycle stage, not just BUILD and TEST.
  - `START-HERE-WEBSITE.md`: lifecycle diagram updated; accessibility added to
    Stages 1 (THINK), 2 (CHALLENGE), 3 (PLAN), 7 (LAUNCH), 10 (MAINTAIN).
  - `chatmodes/website-launch-planner.chatmode.md`: new Phase 1 question on
    assistive technology needs; geographic accessibility law examples in Phase 2;
    platform accessibility criterion in Phase 4; expanded UX/UI checks in
    Phase 5; CMS accessibility checks in Phase 7; 6 explicit accessibility
    items in Phase 8 pre-launch checklist.
  - `workflows/website-live-launch.workflow.md`: accessibility needs added to
    Step 1 Strategy clarification list.
- **K-06 ADR compliance - browser-side accessibility and performance**
  (`18692db`, `9e33da2`):
  - `instructions/html-css-javascript.instructions.md`: Script Loading, ARIA
    Tablist Keyboard, Modal Focus Management, Idempotent Event Listeners,
    High-Volume Streaming DOM, and keyboard testing sections.
  - `skills/accessibility.skill.md`: Interactive Widget Accessibility section
    (tablist, modal, live regions, menu), expanded checklist (+5 items),
    expanded practical testing (+5 steps).
  - `chatmodes/accessibility-review.chatmode.md`: Interactive Widget Checks,
    Script Loading and Performance checks, expanded output template.
- **Changelog gate in shared-artefacts workflow**: added Step 5 to the Mandatory
  Workflow in `instructions/shared-artefacts.instructions.md` requiring a
  `Changelog.md` entry for every `_copilot-shared/` commit - no exceptions.
- **Agent/chatmode sync gate** in `sync-shared-copilot.ps1`: runs
  `tests/test_agent_chatmode_sync.py` before propagating; a broken pairing
  contract aborts the sync before any copy. Verified positive + negative.
- **Accuracy-first documentation rules**: doc standards now mandate verifying
  CLI argument tables against each script's own `--help` output; never guess
  or copy flags between guides.
- Markdownlint wired into CI (`ci.yml`) and the `sanity` scripts.

### Changed

- **Pinned markdownlint to `markdownlint-cli2@0.22.1`** in `ci.yml`,
  `sanity.bat`, and `sanity_v.bat` so the local gate and CI evaluate the same
  rule set. An unpinned `npx markdownlint-cli2` had been resolving to newer
  releases that enabled rules (e.g. `MD060`) CI did not have, so local and CI
  disagreed. The `## Canonical Quality Gate` section now lists markdownlint as
  the seventh step.
- **Disabled `MD060` (table-column-style)** in `.markdownlint.json` - cosmetic
  only and conflicts with fill-in template tables - and **started tracking
  `.markdownlint.json`** (previously git-ignored) so clones and the gate share
  one configuration.
- **Cleaned 208 pre-existing markdownlint errors across 43 `_copilot-shared`
  files** that surfaced once Node/`npx` was installed and `sanity.bat` step 7
  began running. Auto-fixable rules were corrected; `MD041` was resolved with
  the inline `<!-- markdownlint-disable MD041 -->` convention on 30
  chatmode/prompt files; `MD040` bare fences were given a language; the
  intentional duplicate-heading pass in `pre-commit-check.chatmode.md` was
  exempted (`MD024`); and the `MD025`/`MD051` one-offs were hand-fixed.
- **Audited and corrected `tools:` on every agent and chatmode** so each
  artifact's declared capabilities match the task described in its body (least
  privilege but sufficient). There is **one** canonical VS Code tool vocabulary;
  the `.chatmode.md` editor linter just validates against an older registry than
  `.agent.md`, which is why some tokens differ between paired files.
  - Agents: fixed the `todo` -> `todos` typo (the canonical name) across all 11
    agents that track a to-do list. Added the `agent` toolset to
    `architect.agent.md`, `business-analyst.agent.md`, and `team-lead.agent.md`
    - each delegates to the `explore` sub-agent but lacked the tool to invoke it.
  - Chatmodes: rewrote all 16 `tools:` lines to the tokens the legacy chatmode
    linter accepts (`search`, `edit`, `runCommands/runInTerminal`; reading is
    implicit). Notably `website-launch-planner` and `debug` gained `edit` (they
    author artifacts), and `pr-merge` / `pre-commit-check` were corrected to
    `runCommands/runInTerminal`.
- **Completed the `Explore` -> `explore` agent rename** (the file was already
  `explore.agent.md` with `name: explore`; lowercase is case-safe on Linux).
  Updated every remaining reference: the `agents: [...]` delegation arrays in
  architect / business-analyst / team-lead (these still said `"Explore"` and
  would have failed to bind on case-sensitive Linux), plus prose in
  `copilot-instructions.md`, `WEBSITE-ARTIFACT-MANIFEST.md`, `summary.md`,
  `START-HERE-WEBSITE.md`, the `AGENT-CHATMODE-SYNC.md` pair table, and the
  architecture / component prompts.
- **`powershell/build-chatmode-from-agent.ps1`**: the generator no longer emits
  agent-only tokens into `doc-writer.chatmode.md`; it now writes
  `['edit', 'search', 'runCommands/runInTerminal']` with a NOTE explaining the
  vocabulary split, so regeneration cannot reintroduce invalid tokens.
- Regenerated `doc-writer.chatmode.md` body from `doc-writer.agent.md`; the
  identical baseline is now committed so it is durable.
- Deduped `AGENT-CHATMODE-SYNC.md` (each pair listed once). Baseline:
  5 pairs, 1 identical, 13 checks.

### Fixed

- **`critical-thinking.chatmode.md`**: removed the invalid `read` token (a
  pre-existing bug) - now `['search']`, matching its read-only Socratic role.
- **`pr-merge.chatmode.md`**: the `Closes #<issue>` template line was parsed by
  the chatmode linter as a `#tool` reference; reworded to
  `Closes # <issue-number>` to clear the false `Unknown tool` error.
- Stopped tracking `__pycache__`; added `.gitignore` for Python artifacts.

## [2026-06-09] -- major summary.md overhaul

### Added

- **New "How to Invoke an Agent" subsection** (Section 2) - step-by-step
  instructions for typing `@name` in a regular Copilot Chat, with an example
  and a tip on deriving the agent name from the filename.
- **New "How You Start Each Group" quick-reference table** (after the Overview)
  mapping each group to how it is triggered.
- **New `/` vs `@` callout** near the top of the document, explaining that `/`
  runs a prompt and `@` calls an agent.
- **Three new Key Concepts entries:** PR (Pull Request), CI/CD, and JOSHUA.
- **Clarifying note on the agent chain** - tells beginners they don't need to
  memorise it or use every agent.

### Changed

- **Overview table** - `agents` row "How it activates" changed from
  "You select one in Chat" to "Type `@name` in Chat" (now consistent with the
  Prompts row).
- **Section 2 intro** - reworded to the canonical phrase: "Type `@agent-name`
  in Copilot Chat (or pick it from the agent dropdown)."
- **"How the Groups Work Together"** - Agents bullet now states how to summon
  an agent (`@name`), matching the Prompts and Chat modes bullets.
- **Key Concepts -> Agent row** - now includes the `@name` invocation method,
  mirroring how the Prompt row explains `/name`.
- **Activation legend** - "You select" note expanded to "You select / You type"
  to cover both dropdown and `/` `@` triggers.

### Notes

- JOSHUA is currently described generically as "this project's Flask-based web
  frontend." Update this single Key Concepts row if it has a more specific
  meaning.
- No content was removed; all original tables and sections are preserved.

---

## [2026-06-08] -- major _copilot-shared overhaul; new doc-writing files; PS1 fixes

### Added

- **`_copilot-shared/skills/doc-writing.skill.md`** -- new canonical writing
  standards skill file. Extracted from `doc-writer.agent.md` body. Single
  source of truth for audience rules, Markdown format, Changelog format, and
  the "what to update for each change type" table.
- **`_copilot-shared/workflows/doc-writing.workflow.md`** -- new beginner-friendly
  step-by-step guide for writing and updating project documentation. Covers
  all 8 steps from identifying changes through to reporting, with references
  to all relevant Copilot assets.
- **`_copilot-shared/AGENT-CHATMODE-SYNC.md`** -- governance document mandating
  paired agent/chatmode files are always updated in the same commit. Contains
  full pair inventory table and SYNC NOTE template.
- **`Changelog.md`** (this file) -- workspace-root Changelog for shared
  Copilot tooling changes.

### Changed

- **`_copilot-shared/agents/doc-writer.agent.md`** -- added `doc-writing.skill.md`
  reference as the first item in `## Your Inputs`; added SYNC NOTE.
- **`_copilot-shared/chatmodes/doc-writer.chatmode.md`** -- added skill reference
  line before the MANDATORY Changelog block; added SYNC NOTE.
- **`_copilot-shared/chatmodes/docstring-review.chatmode.md`** -- fixed invalid
  namespaced tool names (`read/readFile` etc.) replaced with `['search', 'edit']`.
- **`_copilot-shared/skills/docstring.skill.md`** -- added The Doubt Rule;
  extended scope to cover `.bat`/`.ps1`/`.sh`; examples genericified.
- **`_copilot-shared/instructions/docstrings.instructions.md`** -- added The Doubt
  Rule section; extended `applyTo` glob to include `**/*.bat,**/*.ps1,**/*.sh`;
  added PowerShell and shell script sections.
- **`_copilot-shared/workflows/standard-change.workflow.md`** -- opening project
  name genericified (removed "Salesforce Admin Utilities" references).
- **`_copilot-shared/skills/testing.skill.md`** -- removed direct `--cov` flags
  (violated addopts inheritance rule); coverage threshold owned by `pyproject.toml`.
- **`_copilot-shared/skills/security.skill.md`** -- genericified; removed
  project-specific `validate_salesforce_alias()` references.
- **`_copilot-shared/skills/python.skill.md`** -- genericified; `src/sf_admin_utils`
  paths replaced with generic `src/` references.
- **All 12 agents and 13+ chatmodes** -- removed all "Salesforce Admin Utilities"
  project-specific references; SYNC NOTE comments added to all paired files;
  pre-commit-check chatmode fully synced with agent Phase 0 Cycode pre-flight.
- **`sync-shared-copilot.ps1`** -- replaced all non-ASCII characters (em dashes,
  arrows, box-drawing chars) with ASCII equivalents to fix PowerShell 5.1 parse
  error ("Missing closing '}'").

### Fixed

- **`sync-shared-copilot.ps1`** -- non-ASCII Unicode characters caused
  PowerShell 5.1 to misparse the file and report a spurious missing-brace error.
  All `--`, `->` section headers and string content now use ASCII only.

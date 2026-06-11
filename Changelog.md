# Changelog - Shared Copilot Workspace

<!-- markdownlint-disable MD024 -->
All notable changes to the shared Copilot tooling (`_copilot-shared/`) and
workspace-root scripts are documented here.

Changes to individual sub-projects (Salesforce, Trails and Tails, etc.) are
tracked in each project's own `Changelog.md`.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

### Added

- **Agent/chatmode sync gate** in `sync-shared-copilot.ps1`: runs
  `tests/test_agent_chatmode_sync.py` before propagating; a broken pairing
  contract aborts the sync before any copy. Verified positive + negative.
- **Accuracy-first documentation rules**: doc standards now mandate verifying
  CLI argument tables against each script's own `--help` output; never guess
  or copy flags between guides.
- Markdownlint wired into CI (`ci.yml`) and the `sanity` scripts.

### Changed

- Regenerated `doc-writer.chatmode.md` body from `doc-writer.agent.md`; the
  identical baseline is now committed so it is durable.
- Deduped `AGENT-CHATMODE-SYNC.md` (each pair listed once). Baseline:
  5 pairs, 1 identical, 13 checks.

### Fixed

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

# Changelog - Shared Copilot Workspace

<!-- markdownlint-disable MD024 -->
All notable changes to the shared Copilot tooling (`_copilot-shared/`) and
workspace-root scripts are documented here.

Changes to individual sub-projects (Salesforce, Trails and Tails, etc.) are
tracked in each project's own `Changelog.md`.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

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

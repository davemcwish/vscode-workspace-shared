---
applyTo: ".github/agents/**,.github/chatmodes/**,.github/instructions/**,.github/prompts/**,.github/skills/**,.github/workflows/**,.github/copilot-instructions.md,tests/test_agent_chatmode_sync.py,tests/diff_pairs.py,sanity.bat,sanity_v.bat"
description: "Shared artefact ownership rules - never edit project-local copies directly."
---

# Shared Artefact Rules

## Ownership Model

Files in the paths matched by this instruction are **read-only copies** synced
from `_copilot-shared/` by `sync-shared-copilot.ps1`. They are not
project-owned - the single source of truth lives in the workspace-level
`_copilot-shared/` directory.

## The Rule

> **Never edit a project-local `.github/` artefact or synced test/scaffold file
> directly. Always edit the master in `_copilot-shared/`, validate, sync, then
> inspect the downstream result.**

## Mandatory Workflow

When a change is needed to any shared artefact:

1. **Edit the master** in `_copilot-shared/<subfolder>/` (e.g.
   `_copilot-shared/agents/`, `_copilot-shared/instructions/`,
   `_copilot-shared/tests/`, `_copilot-shared/scaffold/`).
2. **Run shared validation** - execute the contract tests against the master:

   ```powershell
   cd "<workspace-root>"
   py -3.12 -m pytest _copilot-shared/tests/test_agent_chatmode_sync.py -q --no-cov
   ```

3. **Run the sync script** to propagate changes to all registered projects:

   ```powershell
   cd "<workspace-root>"
   .\sync-shared-copilot.ps1
   ```

4. **Inspect downstream diffs** - review what changed in each project's
   `.github/`, `tests/`, `sanity.bat`, etc. to confirm correctness.
5. **Commit in both repos** - workspace-level (`_copilot-shared/` +
   `sync-shared-copilot.ps1`) and the affected project(s).

## What Lives Where

| Source location | Synced to (project-local) | Owned by |
| --- | --- | --- |
| `_copilot-shared/agents/` | `.github/agents/` | `_copilot-shared` |
| `_copilot-shared/chatmodes/` | `.github/chatmodes/` | `_copilot-shared` |
| `_copilot-shared/instructions/` | `.github/instructions/` | `_copilot-shared` |
| `_copilot-shared/prompts/` | `.github/prompts/` | `_copilot-shared` |
| `_copilot-shared/skills/` | `.github/skills/` | `_copilot-shared` |
| `_copilot-shared/workflows/` | `.github/workflows/` | `_copilot-shared` |
| `_copilot-shared/copilot-instructions.md` | `.github/copilot-instructions.md` | `_copilot-shared` |
| `_copilot-shared/tests/` | `<project>/tests/` (root-level sync) | `_copilot-shared` |
| `_copilot-shared/scaffold/sanity.bat` | `<project>/sanity.bat` | `_copilot-shared` |
| `_copilot-shared/scaffold/sanity_v.bat` | `<project>/sanity_v.bat` | `_copilot-shared` |

## Exceptions

- Files synced via `$ScaffoldSyncFiles` that are **not** in the always-sync
  list (e.g. `.markdownlint.json`) are copied only once at project creation
  (`-Scaffold` flag). After that initial copy, the **project owns them** and
  edits go directly in the project.
- Project-specific test files (anything in `tests/` that is NOT
  `test_agent_chatmode_sync.py` or `diff_pairs.py`) are project-owned.

## Why This Matters

Editing a project-local copy creates silent drift. The next sync overwrites the
local edit without warning, losing the change. Worse, if the edit is
important but only lives locally, other projects never receive it.

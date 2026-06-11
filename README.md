# vscode-workspace-shared

A multi-project VS Code workspace with a centralised GitHub Copilot
configuration system. This repo stores the **shared source of truth** for
agents, chat modes, instructions, prompts, skills, and workflows that are
automatically synced into every project in the workspace.

---

## Who is this for?

- **You** - if you cloned or forked this repo to set up the same workspace
  structure on a different machine.
- **A complete beginner** - someone who can follow step-by-step instructions
  but may not have used VS Code workspaces, GitHub Copilot custom agents, or
  multi-repo git setups before.

---

## What is in this repo?

This repo tracks **only** the workspace-level shared files. The actual project
repos (Salesforce, Trails and Tails, etc.) live as subfolders but have their
own independent git repos - they are excluded from this repo's tracking via
`.gitignore`.

| File or folder | What it does |
| --- | --- |
| `_copilot-shared/` | Single source of truth for all Copilot artefacts |
| `_copilot-shared/agents/` | Custom agent definitions (`.agent.md` files) |
| `_copilot-shared/chatmodes/` | Chat mode definitions (`.chatmode.md` files) |
| `_copilot-shared/instructions/` | Per-file-type coding rules (auto-applied by Copilot) |
| `_copilot-shared/prompts/` | Reusable prompt files for common tasks |
| `_copilot-shared/skills/` | Domain knowledge files Copilot can reference |
| `_copilot-shared/workflows/` | Step-by-step workflow guides |
| `_copilot-shared/tests/` | Contract tests validating artefact consistency |
| `_copilot-shared/scaffold/` | Template files copied into new projects |
| `powershell/sync-shared-copilot.ps1` | The sync script - copies `_copilot-shared/` into each project's `.github/` folder |
| `powershell/build-manifest.ps1` | Generates `_copilot-shared/MANIFEST.md` automatically |
| `powershell/` | All PowerShell maintenance and utility scripts |
| `Visual Studio Code.code-workspace` | VS Code multi-root workspace definition |
| `Changelog.md` | History of changes to shared artefacts |
| `sanity.bat` / `sanity_v.bat` | Workspace-level quality gate scripts |

---

## How the sync system works

```text
_copilot-shared/          (you edit here - the single source of truth)
       |
       | powershell/sync-shared-copilot.ps1
       |
       v
+-----------------+    +-----------------+    +---------------------+
| Salesforce/     |    | Trails and      |    | asus-router-        |
|   .github/      |    |   Tails/.github/|    |   decoder/.github/  |
|     agents/     |    |     agents/     |    |     agents/         |
|     chatmodes/  |    |     chatmodes/  |    |     chatmodes/      |
|     prompts/    |    |     prompts/    |    |     prompts/        |
|     ...         |    |     ...         |    |     ...             |
+-----------------+    +-----------------+    +---------------------+
```

**The golden rule:** Never edit files in a project's `.github/` folder
directly. Those are generated copies. Always edit `_copilot-shared/` first,
then run the sync script.

### What the sync script does

1. **Validates** - runs contract tests to confirm agent/chatmode pairs are
   consistent.
2. **Syncs managed folders** (agents, chatmodes, instructions, prompts,
   skills, workflows) into each project's `.github/` using source-wins
   behaviour (the shared copy always overwrites the project copy).
3. **Syncs scaffold files** (sanity.bat, sanity_v.bat, .markdownlint.json)
   into each project root.
4. **Syncs shared tests** into each project's `tests/` folder.
5. **Detects stale files** - reports any file in a project's `.github/` that
   has no corresponding source in `_copilot-shared/`. These are likely
   leftovers from renamed or deleted artefacts.
6. **Optionally validates downstream** - with `-Validate`, runs each
   project's `sanity.bat` to confirm the sync didn't break anything.

---

## Getting started (cloning on a new machine)

### Prerequisites

- Git installed
- Windows 11 (the sync script uses PowerShell and robocopy)
- Python 3.12+ (via the `py` launcher)
- VS Code with the GitHub Copilot extension

### Step 1 - Clone the workspace repo

```powershell
git clone git@github.com:davemcwish/vscode-workspace-shared.git "Visual Studio Code"
cd "Visual Studio Code"
```

### Step 2 - Clone your project repos inside it

```powershell
git clone git@github.com:davemcwish/Salesforce.git
git clone git@github.com:davemcwish/Trails-and-Tails.git "Trails and Tails"
```

> Each project has its own independent git history. The workspace repo's
> `.gitignore` excludes them - they are not nested submodules.

### Step 3 - Run the sync script

```powershell
.\powershell\sync-shared-copilot.ps1
```

This populates each project's `.github/` folder with the shared Copilot
artefacts. After this, VS Code will show all agents, chat modes, and prompts
in the Copilot dropdown.

### Step 4 - Open the workspace in VS Code

```powershell
code "Visual Studio Code.code-workspace"
```

---

## Common tasks

### After editing a shared artefact

```powershell
# 1. Edit the file in _copilot-shared/ (e.g. agents/doc-writer.agent.md)
# 2. Run sync
.\powershell\sync-shared-copilot.ps1

# 3. (Optional) Validate all projects pass their quality gates
.\powershell\sync-shared-copilot.ps1 -Validate

# 4. Commit in this repo (workspace-level)
git add .
git commit -m "chore: update doc-writer agent"
git push

# 5. Commit in each affected project repo
cd Salesforce
git add .github
git commit -m "chore: sync shared copilot config"
git push
```

### Adding a new project

```powershell
# 1. Create the project folder and initialise git
mkdir "My-New-Project"
cd "My-New-Project"
git init -b main

# 2. Copy scaffold starter files (README, CONTRIBUTING, requirements.in, etc.)
cd ..
.\powershell\sync-shared-copilot.ps1 -Scaffold -ScaffoldTarget "My-New-Project"

# 3. Add the project name to $DefaultProjects in powershell/sync-shared-copilot.ps1
# 4. Run the normal sync
.\powershell\sync-shared-copilot.ps1
```

### Checking for stale files

Just run the sync - the report at the end will list any stale files:

```text
STALE FILES DETECTED (2):
  These exist in project .github/ but NOT in _copilot-shared/.
    - Salesforce/.github/prompts/old-removed-prompt.prompt.md
    - Trails and Tails/.github/prompts/old-removed-prompt.prompt.md
```

Delete them manually from each project, then commit.

---

## Architecture decisions

| Decision | Rationale |
| --- | --- |
| Source-wins sync for `.github/` folders | Prevents drift from accidental project-local edits |
| `/XO` (skip-older) for `tests/` folders | Project-specific tests coexist with shared tests |
| Stale detection reports but does not delete | Safety - avoids accidental data loss |
| `-Validate` is opt-in | Full validation is slower - not needed on every sync |
| Contract tests run before sync | Prevents propagating broken artefacts |
| Shared tests skip in CI | CI only checks out one project repo; `_copilot-shared/` is not available |

---

## Key concepts for beginners

| Term | What it means |
| --- | --- |
| Agent (`.agent.md`) | A custom Copilot personality with specific instructions, tools, and behaviours. Lives in `.github/agents/` so VS Code can discover it. |
| Chat mode (`.chatmode.md`) | Similar to an agent but appears in the chat mode dropdown. Some Copilot setups prefer one over the other. |
| Instruction (`.instructions.md`) | Rules auto-applied by Copilot when editing files matching a glob pattern (e.g. all `*.py` files). |
| Prompt (`.prompt.md`) | A reusable task template you invoke explicitly (e.g. "run the pre-commit check"). |
| Skill (`.skill.md`) | Domain knowledge Copilot can reference when answering questions. |
| Workflow (`.workflow.md`) | A multi-step process guide (not auto-executed - used as a reference). |
| Scaffold | Template files copied once when a new project is created. The project owns them after copying. |
| Sync script | `sync-shared-copilot.ps1` - the script that propagates shared artefacts to all projects. |
| Quality gate | `sanity.bat` - runs ruff, mypy, bandit, detect-secrets, pytest, and markdownlint. Must pass before committing. |
| Stale file | A file in a project's `.github/` that no longer has a source in `_copilot-shared/`. Should be deleted. |

---

## Troubleshooting

### "Agent/chatmode pairing validation FAILED"

The sync script runs contract tests before syncing. If a paired agent and
chatmode have drifted (different content), the sync refuses to run.

**Fix:** Edit the source files in `_copilot-shared/` to bring the pair back
in sync, then re-run.

### "Project 'X' not found" / "does not appear to be a git repo"

The sync script expects project folders to exist and be git repos.

**Fix:** Clone the missing project into the workspace folder, or remove it
from `$DefaultProjects` in the script.

### Stale files keep reappearing

If a stale file keeps coming back, something is re-creating it. Check whether
another tool or script is generating it. The sync script never creates files
that don't exist in `_copilot-shared/`.

### VS Code doesn't show agents/prompts in the dropdown

Copilot discovers custom agents from `.github/agents/` in the workspace root.
Make sure you opened the `.code-workspace` file (not just a folder) and that
the sync has run at least once.

# Adding a New Subworkspace Project

This guide explains how to add a new project folder to the shared Visual Studio
Code multi-root workspace so it automatically picks up the shared Copilot
configuration from `_copilot-shared\`.

Follow these steps whenever you want to start a new project under the same
parent folder.

---

## Background: How the workspace is structured

```text
Visual Studio Code\                        <- parent folder (workspace root)
  _copilot-shared\                         <- single source of truth for Copilot config
    scaffold\                              <- starter files copied into new projects once
  sync-shared-copilot.ps1                  <- copies _copilot-shared into each project
  Visual Studio Code.code-workspace        <- tells VS Code which folders to show
  Salesforce\                              <- project (its own git repo)
    .github\                               <- synced copy of _copilot-shared
  Trails and Tails\                        <- project (its own git repo)
    .github\                               <- synced copy of _copilot-shared
  woprcrt-terminal-main\                   <- project (its own git repo)
    .github\                               <- synced copy of _copilot-shared
  powerpoint-reformat\                     <- project (its own git repo)
    .github\                               <- synced copy of _copilot-shared
```

When you add a new project:

- It gets its own folder under `Visual Studio Code\`.
- It gets its own git repository and remote (e.g. a new GitHub repo).
- The sync script copies the shared Copilot instructions into it automatically.
- VS Code treats it as another root folder in the same workspace window.

---

## Two places you must update

Adding a new project requires editing **two separate files**. They have
different formats but must list the same set of project folders.

### 1. The sync script (`sync-shared-copilot.ps1`)

This file has a PowerShell array called `$DefaultProjects`. It is a simple
flat list of folder names (one string per project). The sync script loops
through this list and copies `_copilot-shared\` into each folder's `.github\`.

**Current value:**

```powershell
$DefaultProjects = @(
    "Salesforce",
    "Trails and Tails",
    "woprcrt-terminal-main",
    "powerpoint-reformat"
)
```

Each entry is just the folder name on disk. Nothing else.

### 2. The workspace file (`Visual Studio Code.code-workspace`)

This is a JSON file that tells VS Code which folders to display in the
sidebar. Its `"folders"` array contains objects with two properties:

- `"path"` - the actual folder name on disk (must match the entry in
  `$DefaultProjects` exactly).
- `"name"` - a display label shown in the VS Code sidebar (can be anything
  you like, does not need to match the folder name).

**Current value:**

```jsonc
{
  "folders": [
    { "name": "Visual Studio Code",                              "path": "." },
    { "name": "Salesforce",                                      "path": "Salesforce" },
    { "name": "Trails and Tails",                                "path": "Trails and Tails" },
    { "name": "WOPR (Joshua) War Games CRT Terminal and Game Hub", "path": "woprcrt-terminal-main" },
    { "name": "PowerPoint Reformat",                             "path": "powerpoint-reformat" }
  ],
  "settings": { ... }
}
```

> The first entry (`"path": "."`) is the parent workspace folder itself. Do
> not add this to `$DefaultProjects` - it is not a project, it is the root
> that contains all projects.

### How the two files relate

| Sync script (`$DefaultProjects`) | Workspace file (`"folders"`) | Relationship |
| --- | --- | --- |
| `"Salesforce"` | `{ "name": "Salesforce", "path": "Salesforce" }` | `"path"` = folder name |
| `"Trails and Tails"` | `{ "name": "Trails and Tails", "path": "Trails and Tails" }` | `"path"` = folder name |
| `"woprcrt-terminal-main"` | `{ "name": "WOPR (Joshua) ...", "path": "woprcrt-terminal-main" }` | `"path"` = folder name |
| `"powerpoint-reformat"` | `{ "name": "PowerPoint Reformat", "path": "powerpoint-reformat" }` | `"path"` = folder name |

**Rule:** Every folder name in `$DefaultProjects` must also appear as a
`"path"` value in the workspace file (and vice versa, except for the `"."`
root entry).

---

## Step 1 - Create the new project folder

Open a PowerShell terminal and run:

```powershell
cd "C:\Users\<username>\Documents\Visual Studio Code"
mkdir "My-New-Project"
```

Replace `My-New-Project` with whatever your project is called.

---

## Step 2 - Initialise it as a git repository

### Option A - Brand new repo (nothing on GitHub yet)

```powershell
cd "My-New-Project"
git init
git remote add origin git@github.com:ford-innersource/YOUR-NEW-REPO.git
```

Replace `YOUR-NEW-REPO` with the name of the repository you created on GitHub.

### Option B - Clone an existing repo from GitHub

If the repo already exists on GitHub with content:

```powershell
cd "C:\Users\<username>\Documents\Visual Studio Code"
git clone git@github.com:ford-innersource/YOUR-NEW-REPO.git "My-New-Project"
```

This creates the folder and downloads all existing commits in one step.

---

## Step 3 - Add the folder name to the sync script

Open the file:

```text
C:\Users\<username>\Documents\Visual Studio Code\sync-shared-copilot.ps1
```

Find the `$DefaultProjects` array and add the new folder name at the end:

```powershell
$DefaultProjects = @(
    "Salesforce",
    "Trails and Tails",
    "woprcrt-terminal-main",
    "powerpoint-reformat",
    "My-New-Project"          # <- add this line
)
```

Save the file. The entry must be the exact folder name on disk (case-sensitive,
including any spaces).

---

## Step 4 - Add the folder to the VS Code workspace file

Open the file:

```text
C:\Users\<username>\Documents\Visual Studio Code\Visual Studio Code.code-workspace
```

Add a new object to the `"folders"` array:

```jsonc
{
  "folders": [
    { "name": "Visual Studio Code",                              "path": "." },
    { "name": "Salesforce",                                      "path": "Salesforce" },
    { "name": "Trails and Tails",                                "path": "Trails and Tails" },
    { "name": "WOPR (Joshua) War Games CRT Terminal and Game Hub", "path": "woprcrt-terminal-main" },
    { "name": "PowerPoint Reformat",                             "path": "powerpoint-reformat" },
    { "name": "My-New-Project",                                  "path": "My-New-Project" }
  ],
  "settings": { ... }
}
```

- `"path"` must match what you put in `$DefaultProjects` exactly.
- `"name"` can be a friendlier display name if you prefer.

Save the file. VS Code will offer to reload - click **Reload** when prompted.

---

## Step 5 - Run the sync script

From the parent folder, run:

```powershell
cd "C:\Users\<username>\Documents\Visual Studio Code"
.\sync-shared-copilot.ps1
```

Expected output:

```text
=== sync-shared-copilot ===
  Source : C:\Users\<username>\Documents\Visual Studio Code\_copilot-shared

  -> Salesforce
    Done.
  -> Trails and Tails
    Done.
  -> woprcrt-terminal-main
    Done.
  -> powerpoint-reformat
    Done.
  -> My-New-Project
    Done.

=== Sync complete. Remember to commit any changes inside each project repo. ===
```

This copies all agents, chat modes, instructions, prompts, skills, workflows,
`copilot-instructions.md`, and `summary.md` from `_copilot-shared\` into
`My-New-Project\.github\`.

To sync only one project (faster when testing):

```powershell
.\sync-shared-copilot.ps1 -Projects "My-New-Project"
```

---

## Step 6 - Commit the `.github` folder in the new repo

The synced Copilot config should be committed so it is available to anyone who
clones the repo:

```powershell
cd "C:\Users\<username>\Documents\Visual Studio Code\My-New-Project"
git add .github
git commit -m "chore: add shared Copilot config from _copilot-shared"
git push -u origin main
```

---

## Step 7 - Copy the scaffold files into the new project

The `_copilot-shared\scaffold\` folder contains ready-to-use starter files
for any new Python project.  Copy them now so you have a local quality gate
and dependency management setup from day one.

From the parent folder, run:

```powershell
cd "C:\Users\<username>\Documents\Visual Studio Code"
.\sync-shared-copilot.ps1 -Scaffold -ScaffoldTarget "My-New-Project"
```

This copies the following files into `My-New-Project\` (existing files are
never overwritten):

| File | What it does |
| --- | --- |
| `sanity.bat` | Local quality gate — run before every commit |
| `sanity_v.bat` | Verbose version of `sanity.bat` — use when debugging a failure |
| `requirements.in` | Starter list of runtime dependencies (Python template) |
| `requirements-dev.in` | Starter list of dev/test dependencies (Python template) |
| `README.md` | Project overview template — fill in what it does and how to use it |
| `ARCHITECTURE.md` | System design template — components, data flows, security model |
| `CHANGELOG.md` | Version history template (Keep a Changelog format) |
| `CONTRIBUTING.md` | Developer guide template — setup, standards, PR process |
| `SECURITY.md` | Security policy template — vulnerability reporting, controls |
| `UPDATING_DEPENDENCIES.md` | Dependency management guide template |
| `scaffold-README.md` | Explains what to customise in each file |

Open `scaffold-README.md` in the new project and work through its
customisation notes before running the gate for the first time.  Every
section marked `[FILL IN]` in the documentation files must be completed.

> **Note:** Scaffold files are copied once at project creation time.  After
> that, your project owns its copies.  Changes to `_copilot-shared\scaffold\`
> do not automatically propagate to existing projects (unlike `.github\` which
> is always synced).

Once you have customised the scaffold files, commit them:

```powershell
git add sanity.bat sanity_v.bat requirements.in requirements-dev.in
git add README.md ARCHITECTURE.md CHANGELOG.md CONTRIBUTING.md SECURITY.md UPDATING_DEPENDENCIES.md scaffold-README.md
git commit -m "chore: add scaffold files — quality gate, dependencies, and project docs"
git push
```

---

## What the sync script copies

The `$Folders` array inside `sync-shared-copilot.ps1` lists the subfolders
that get copied from `_copilot-shared\` into each project's `.github\`:

```powershell
$Folders = @(
    "agents",
    "chatmodes",
    "instructions",
    "prompts",
    "skills",
    "workflows",
    ".spec-workflow"
)
```

It also copies two root-level files:

- `copilot-instructions.md` (master Copilot behaviour rules)
- `summary.md` (inventory of all `.github` configuration)

---

## Quick reference

| Task | Command |
| --- | --- |
| Sync all projects | `.\sync-shared-copilot.ps1` |
| Sync one project only | `.\sync-shared-copilot.ps1 -Projects "My-New-Project"` |
| Copy scaffold files into a new project | `.\sync-shared-copilot.ps1 -Scaffold -ScaffoldTarget "My-New-Project"` |
| See script help | `Get-Help .\sync-shared-copilot.ps1` |

---

## Troubleshooting

| Problem | Cause | Fix |
| --- | --- | --- |
| `WARNING: Project 'X' not found` | Folder name in `$DefaultProjects` does not match a real folder on disk. | Check spelling, capitalisation, and spaces. Must match exactly. |
| `WARNING: 'X' does not appear to be a git repo` | Folder exists but has no `.git` subfolder. | Run `git init` inside that folder, or clone the repo again. |
| New project not synced | Folder name missing from `$DefaultProjects`. | Edit `sync-shared-copilot.ps1` and add it to the array. |
| VS Code does not show the new folder | Missing from `Visual Studio Code.code-workspace`. | Add a `"folders"` entry with the correct `"path"` and reload VS Code. |
| `robocopy failed` error | A file is locked by another process. | Close programs using files in `.github\` and retry. |

---

## Key rules to remember

| Thing | Rule |
| --- | --- |
| `_copilot-shared\` | Always edit here for shared Copilot content. Never edit a project's `.github\` directly for shared files. |
| `_copilot-shared\scaffold\` | Edit here to improve the project starter templates. Changes only affect new projects created after the edit. |
| `sync-shared-copilot.ps1` | Run after any change to `_copilot-shared\`. Add new project folder names to `$DefaultProjects`. |
| `Visual Studio Code.code-workspace` | Add new projects to the `"folders"` array. The `"path"` must match the `$DefaultProjects` entry exactly. |
| Each project's `.github\` | A synced copy. Safe to add project-specific files, but shared files get overwritten on next sync. |
| Each project's `sanity.bat` / `sanity_v.bat` | Copied once from scaffold. Project owns them. Keep in sync with each other and with `ci.yml`. |
| Each project's `.git\` | Completely independent. Each project has its own history, branches, and remote. |

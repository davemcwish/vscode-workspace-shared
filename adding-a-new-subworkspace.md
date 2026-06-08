# Adding a New Subworkspace Project

This guide explains how to add a second (or third) project folder to the shared
Visual Studio Code workspace so it automatically picks up the shared Copilot
configuration from `_copilot-shared\`.

Follow these steps whenever you want to start a new project under the same
parent folder.

---

## Background: How the workspace is structured

```text
Visual Studio Code\                   ← parent folder (your VS Code workspace root)
  _copilot-shared\                    ← single source of truth for Copilot config
  sync-shared-copilot.ps1             ← script that copies _copilot-shared into each project
  Visual Studio Code.code-workspace   ← VS Code multi-root workspace file
  Salesforce\                         ← project 1 (its own git repo)
    .github\                          ← synced copy of _copilot-shared
```

When you add a new project:

- It gets its own folder under `Visual Studio Code\`.
- It gets its own git repository and remote (e.g. a new GitHub repo).
- The sync script copies the shared Copilot instructions into it automatically.
- VS Code treats it as another root folder in the same workspace window.

---

## Step 1 — Create the new project folder

Open a PowerShell terminal and run:

```powershell
cd "C:\Users\dwishar1\Documents\Visual Studio Code"
mkdir "Trails and Tails"
```

Replace `Trails and Tails` with whatever your project is called.

---

## Step 2 — Initialise it as a git repository

### Option A — Brand new repo (nothing on GitHub yet)

```powershell
cd "Trails and Tails"
git init
git remote add origin git@github.com:ford-innersource/YOUR-NEW-REPO.git
```

Replace `YOUR-NEW-REPO` with the name of the repository you have already created
on GitHub.

### Option B — Clone an existing repo from GitHub

If the repo already exists on GitHub with some content:

```powershell
cd "C:\Users\dwishar1\Documents\Visual Studio Code"
git clone git@github.com:ford-innersource/YOUR-NEW-REPO.git "Trails and Tails"
```

This creates the folder and downloads all the existing commits in one step.

---

## Step 3 — Add the new folder to the VS Code workspace

Open the file:

```text
C:\Users\dwishar1\Documents\Visual Studio Code\Visual Studio Code.code-workspace
```

Add a new entry inside `"folders"`:

```jsonc
{
  "folders": [
    { "name": "Visual Studio Code", "path": "." },
    { "name": "Salesforce",         "path": "Salesforce" },
    { "name": "Trails and Tails",   "path": "Trails and Tails" }
  ]
}
```

Save the file. VS Code will offer to reload — click **Reload** when prompted.

> **Tip:** The `"name"` value is just a display label in VS Code.
> The `"path"` value must match the actual folder name exactly.

---

## Step 4 — Register the project in the sync script

Open the file:

```text
C:\Users\dwishar1\Documents\Visual Studio Code\sync-shared-copilot.ps1
```

Find the `$DefaultProjects` list and add the new folder name:

```powershell
$DefaultProjects = @(
    "Salesforce",
    "Trails and Tails"   # ← add this line
)
```

Save the file.

---

## Step 5 — Run the sync to copy the shared Copilot config

From the parent folder, run:

```powershell
cd "C:\Users\dwishar1\Documents\Visual Studio Code"
.\sync-shared-copilot.ps1
```

You should see output like this:

```text
=== sync-shared-copilot ===
  → Salesforce        Done.
  → Trails and Tails  Done.
=== Sync complete. Remember to commit any changes inside each project repo. ===
```

This copies all agents, chat modes, instructions, prompts, skills, and workflows
from `_copilot-shared\` into `Trails and Tails\.github\`.

---

## Step 6 — Commit the `.github` folder in the new repo

The synced Copilot config should be committed so it is available to everyone
who clones the repo:

```powershell
cd "C:\Users\dwishar1\Documents\Visual Studio Code\Trails and Tails"
git add .github
git commit -m "chore: add shared Copilot config from _copilot-shared"
git push -u origin main
```

---

## Quick reference

| Task | Command |
| --- | --- |
| Sync Copilot config to all projects | `.\sync-shared-copilot.ps1` |
| Sync to one project only | `.\sync-shared-copilot.ps1 -Projects "Trails and Tails"` |
| See sync script help | `Get-Help .\sync-shared-copilot.ps1` |

---

## Key rules to remember

| Thing | Rule |
| --- | --- |
| `_copilot-shared\` | Always edit here when changing Copilot instructions or prompts for all projects. Never edit a project's `.github\` directly for shared content. |
| `sync-shared-copilot.ps1` | Run this after any change to `_copilot-shared\` to push the update to every registered project. |
| Each project's `.github\` | Is a synced copy. It is safe to add project-specific files here but shared files will be overwritten on the next sync. |
| Each project's `.git\` | Completely independent. Each project has its own git history, branches, and remote repository. |
| VS Code workspace file | Add every new project folder here so VS Code and Copilot can see all projects in the same window. |

# Repairing VS Code Copilot Workspace State

This guide explains what to do when custom chat modes, agents, or prompts
disappear from the VS Code Copilot dropdown - or when duplicates appear.

---

## Symptoms

| Symptom | Likely cause |
| ------- | ------------ |
| Chat modes missing from the dropdown (only "Agent", "Ask", "Edit", "Configure Modes" visible) | `.github/chatmodes/` folder missing or empty in the workspace root |
| Duplicate chat modes in the dropdown | Multiple copies of the same `.chatmode.md` file across workspace folders |
| A chat mode appears but cannot be selected | Corrupt or invalid YAML front-matter in the `.chatmode.md` file |
| Agents missing from @ mentions | `.github/agents/` folder missing or empty |
| Prompts not appearing | `.github/prompts/` folder missing or empty |

---

## Root Cause

VS Code discovers Copilot chat modes, agents, and prompts by scanning
`.github/` inside **each workspace folder** listed in the `.code-workspace`
file. In a multi-root workspace, every folder entry gets scanned independently.

```text
Visual Studio Code\                        <- workspace root folder
  .github\                                 <- ⚠️ MUST EXIST for root-level discovery
    chatmodes\                             <- chat modes appear from here
    agents\                                <- agents appear from here
    prompts\                               <- prompts appear from here
    ...
  _copilot-shared\                         <- single source of truth (master copies)
  Salesforce\
    .github\                               <- project-level copy
  Trails and Tails\
    .github\                               <- project-level copy
  ...
```

If the root `.github\` folder is deleted (e.g. you delete and recreate the
workspace), VS Code has no files to discover and the dropdowns appear empty.

### Why duplicates happen

If the same `.chatmode.md` file exists in `.github/chatmodes/` across multiple
workspace folders, VS Code shows one entry per copy. To avoid duplicates:

- Keep chat modes **only in the root** `.github/chatmodes/` folder, OR
- Accept that each sub-project contributes its own (the sync script does this).

VS Code deduplicates by **filename** within a single workspace folder but NOT
across multiple workspace folders in the same `.code-workspace`.

---

## Quick Recovery (Manual)

### Step 1: Verify the workspace file

Open `Visual Studio Code.code-workspace` and confirm the root folder entry:

```jsonc
{
  "folders": [
    { "name": "Visual Studio Code", "path": "." },
    // ... other projects
  ]
}
```

### Step 2: Re-create the root .github folder

```powershell
$root = "C:\Users\dwishar1\Documents\Visual Studio Code"
New-Item -ItemType Directory -Path "$root\.github\chatmodes" -Force
```

### Step 3: Copy chat modes from the shared source

```powershell
Copy-Item "$root\_copilot-shared\chatmodes\*" "$root\.github\chatmodes\" -Force
```

### Step 4: Copy other Copilot assets

```powershell
$shared = "$root\_copilot-shared"
$github = "$root\.github"

foreach ($folder in @("agents","instructions","prompts","skills","workflows",".spec-workflow")) {
    $src = Join-Path $shared $folder
    if (Test-Path $src) {
        $dst = Join-Path $github $folder
        New-Item -ItemType Directory -Path $dst -Force | Out-Null
        Copy-Item "$src\*" $dst -Recurse -Force
    }
}

Copy-Item "$shared\copilot-instructions.md" "$github\copilot-instructions.md" -Force
Copy-Item "$shared\summary.md" "$github\summary.md" -Force
```

### Step 5: Reload VS Code

Press `Ctrl+Shift+P` -> **Developer: Reload Window**

Chat modes should now appear in the dropdown.

---

## Automated Recovery

Run the repair script instead of doing the above manually:

```powershell
.\repair-workspace-copilot.ps1
```

Or with verbose output:

```powershell
.\repair-workspace-copilot.ps1 -Verbose
```

---

## Preventing the Issue

1. **Never delete** the root `.github\` folder manually.
2. After any workspace reset, run `.\powershell\sync-shared-copilot.ps1` - this now syncs
   into the root workspace `.github\` as well as each sub-project.
3. The `_copilot-shared\` folder is the **single source of truth**. Always edit
   files there, then run the sync script.
4. If VS Code shows duplicates, check whether multiple workspace folders have
   copies. You can either:
   - Remove `.github/chatmodes/` from individual project folders (if they only
     need root-level modes), or
   - Accept the duplication (each project gets its own set for portability).

---

## Handling Duplicates Specifically

If you see duplicates and want to eliminate them:

```powershell
# Remove chatmodes from all sub-project .github folders (keep only in root)
$root = "C:\Users\dwishar1\Documents\Visual Studio Code"
$projects = @("Salesforce","Trails and Tails","woprcrt-terminal-main","powerpoint-reformat","asus-router-decoder")

foreach ($project in $projects) {
    $path = Join-Path $root "$project\.github\chatmodes"
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force
        Write-Host "Removed: $path"
    }
}
```

> **Note:** If a project is opened standalone (outside this workspace), it will
> need its own `.github/chatmodes/` folder. Only remove duplicates if the
> project is always opened via the multi-root workspace.

---

## Workspace Settings That Must Be Present

In `Visual Studio Code.code-workspace` -> `settings`:

```jsonc
{
  "settings": {
    "chat.promptFiles": true,
    "github.copilot.chat.codeGeneration.useInstructionFiles": true
  }
}
```

Without `chat.promptFiles: true`, VS Code will not scan for prompt/chatmode
files at all.

---

## Troubleshooting Checklist

| Check | Command |
| ----- | ------- |
| Chatmodes exist? | `Get-ChildItem .\.github\chatmodes\*.chatmode.md` |
| Agents exist? | `Get-ChildItem .\.github\agents\*.agent.md` |
| Workspace settings correct? | Open `.code-workspace` and verify settings |
| VS Code reloaded? | `Ctrl+Shift+P` -> "Developer: Reload Window" |
| Extension up to date? | Check GitHub Copilot extension version |

---

## Related Files

| File | Purpose |
| ---- | ------- |
| `_copilot-shared\` | Single source of truth for all Copilot config |
| `sync-shared-copilot.ps1` | Propagates shared config -> root + all projects |
| `repair-workspace-copilot.ps1` | Emergency repair script |
| `Visual Studio Code.code-workspace` | Multi-root workspace definition |
| `adding-a-new-subworkspace.md` | Guide for adding new project folders |

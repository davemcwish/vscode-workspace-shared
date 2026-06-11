# Personal GitHub Setup Guide

This guide documents everything done to set up the `davemcwish` personal GitHub
account alongside the existing Ford `ford-innersource` account on the same
Windows work laptop.

It covers:

- creating a second SSH key pair so both GitHub accounts can coexist,
- creating the personal repos `Trails-and-Tails` and `Salesforce`,
- connecting the local project folders to the personal GitHub remotes,
- syncing the shared Copilot configuration into the `Trails and Tails` project,
- setting up a personal backup of the `Salesforce` project,
- updating the VS Code workspace and sync script,
- pushing workspace-level shared files (`_copilot-shared/`) to a personal repo,
- connecting from a different machine in the future.

---

## Background: why two SSH keys?

GitHub enforces a rule: **one SSH public key can only be registered to one
account**. The existing SSH key (`id_ed25519`) is already registered to the
Ford GitHub identity (`dwishar1_ford`). Trying to add the same key to
`davemcwish` will fail with "Key is invalid".

The solution is to generate a **second key pair** specifically for the personal
account, then configure SSH to use the right key depending on which account you
are pushing to.

---

## Step 1 - Generate a second SSH key pair

Open PowerShell and run:

```powershell
& "C:\Program Files\Git\usr\bin\ssh-keygen.exe" `
    -t ed25519 `
    -f "C:\Users\<username>\.ssh\id_ed25519_personal" `
    -C "davemcwish" `
    -N '""'
```

Replace `<username>` with your Windows username. This creates two files:

| File | What it is |
| --- | --- |
| `id_ed25519_personal` | Private key - never share or copy this |
| `id_ed25519_personal.pub` | Public key - this is what GitHub needs |

Copy the public key to your clipboard:

```powershell
Get-Content "C:\Users\<username>\.ssh\id_ed25519_personal.pub" | Set-Clipboard
```

---

## Step 2 - Add the public key to your davemcwish GitHub account

1. Go to **[github.com/settings/ssh/new](https://github.com/settings/ssh/new)** (logged in as `davemcwish`).
2. Set **Title** to something like `Work laptop - personal key`.
3. Leave **Key type** as `Authentication Key`.
4. Paste the public key into the **Key** field. It starts with `ssh-ed25519 AAAA...`.
5. Click **Add SSH key**.

---

## Step 3 - Update the SSH config file

The SSH config file tells your computer which key to use for which host. Open:

```text
C:\Users\<username>\.ssh\config
```

Update it to contain both the Ford and personal entries:

```text
Match Host github.com exec "ping -n 1 internet.ford.com"
  User git
  ProxyCommand connect -H internet.ford.com:83 %h %p
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes

# Personal GitHub (davemcwish) - on Ford network, route through proxy
Match Host github-personal exec "ping -n 1 internet.ford.com"
  HostName github.com
  User git
  ProxyCommand connect -H internet.ford.com:83 %h %p
  IdentityFile ~/.ssh/id_ed25519_personal
  IdentitiesOnly yes

# Personal GitHub (davemcwish) - off Ford network, connect directly
Host github-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_personal
  IdentitiesOnly yes
```

**How this works:**

- `github.com` still uses the Ford key when on the Ford network (via the proxy).
- `github-personal` is a **host alias** - it points at `github.com` but uses the
  personal key instead.
- The `Match Host ... exec "ping ..."` blocks detect whether you are on the Ford
  network. If the ping to `internet.ford.com` succeeds, it routes through the
  proxy. If the ping fails (you are not on the Ford network), SSH falls through
  to the plain `Host github-personal` block and connects directly.

---

## Step 4 - Test the personal SSH connection

```powershell
& "C:\Windows\System32\OpenSSH\ssh.exe" -T git@github-personal
```

Expected output:

```text
Hi davemcwish! You've successfully authenticated, but GitHub does not provide shell access.
```

> The "Ping request could not find host internet.ford.com" warning before the
> success message is harmless - it means you are not on the Ford network, so SSH
> correctly fell through to the direct connection.

---

## Step 5 - Create the GitHub repos

Go to **[github.com/new](https://github.com/new)** (logged in as `davemcwish`) and create two
repositories. Do **not** add a README, `.gitignore`, or licence to either -
both must start completely empty.

| Repo name | Visibility | Purpose |
| --- | --- | --- |
| `Trails-and-Tails` | Private | Primary repo for the Trails and Tails project |
| `Salesforce` | **Private** | Personal backup of the Ford Salesforce utility scripts |

> Keep both repos **private**. The Salesforce backup contains org utility
> scripts, configuration, and query logic that should not be public.

---

## Step 6 - Set up the Trails and Tails local repo

The `Trails and Tails\` folder already existed locally with a logo file inside
it, but it was not yet a git repo.

```powershell
cd "C:\Users\<username>\Documents\Visual Studio Code\Trails and Tails"
git init -b main
git remote add origin git@github-personal:davemcwish/Trails-and-Tails.git
git add .
git commit -m "chore: initial commit"
git push -u origin main
```

Notice the remote URL uses `github-personal` (the SSH alias) rather than
`github.com`. This tells SSH to use the personal key.

---

## Step 7 - Sync the shared Copilot configuration

The `sync-shared-copilot.ps1` script copies shared agents, chat modes,
instructions, prompts, skills, and workflows from `_copilot-shared\` into each
registered project's `.github\` folder.

First, register `Trails and Tails` in the script. Open:

```text
C:\Users\<username>\Documents\Visual Studio Code\sync-shared-copilot.ps1
```

Find the `$DefaultProjects` list and add the new project:

```powershell
$DefaultProjects = @(
    "Salesforce",
    "Trails and Tails"
)
```

Then run the sync from the parent folder:

```powershell
cd "C:\Users\<username>\Documents\Visual Studio Code"
.\powershell\sync-shared-copilot.ps1
```

Expected output:

```text
=== sync-shared-copilot ===
  Source : ..._copilot-shared

  -> Salesforce
    Done.
  -> Trails and Tails
    Done.

=== Sync complete. Remember to commit any changes inside each project repo. ===
```

---

## Step 8 - Add a .gitattributes file and commit

Git on Windows may warn about line-ending conversions (CRLF vs LF). A
`.gitattributes` file prevents this by telling git to always store files with
LF line endings in the repo.

Create the file at the root of `Trails and Tails\`:

```text
# Normalise line endings to LF in the repo; check out as native on Windows.
* text=auto eol=lf
```

Then commit and push everything:

```powershell
cd "C:\Users\<username>\Documents\Visual Studio Code\Trails and Tails"
git add .github .gitattributes
git commit -m "chore: add shared Copilot config and gitattributes"
git push
```

---

## Step 9 - Add the Salesforce personal backup remote

The Salesforce project already has `origin` pointing at Ford's
`ford-innersource` server. Add a second remote called `personal` pointing at the
personal backup:

```powershell
cd "C:\Users\<username>\Documents\Visual Studio Code\Salesforce"
git remote add personal git@github-personal:davemcwish/Salesforce.git
git push personal --all
git push personal --tags
```

`--all` pushes every local branch. `--tags` pushes any version tags. `origin`
is completely unaffected - day-to-day `git push` and `git pull` still go to
Ford.

To sync the backup in the future after a PR merges:

```powershell
cd "C:\Users\dwishar1\Documents\Visual Studio Code\Salesforce"
git checkout main
git pull origin main
git push personal --all
```

---

## Step 10 - Update the VS Code workspace file

The VS Code workspace file controls which folders appear in the VS Code sidebar.
Add `Trails and Tails` to the folders list in:

```text
C:\Users\<username>\Documents\Visual Studio Code\Visual Studio Code.code-workspace
```

```jsonc
{
  "folders": [
    { "name": "Visual Studio Code", "path": "." },
    { "name": "Salesforce",         "path": "Salesforce" },
    { "name": "Trails and Tails",   "path": "Trails and Tails" }
  ]
}
```

VS Code will offer to reload the window - click **Reload** when prompted.

---

## How to keep the personal backup up to date

After a PR merges on `ford-innersource`:

> **Tip:** To list your local branches, use `git branch` (no extra word after it).
> Running `git branch list` accidentally creates a new branch called `list`.

```powershell
# Pull the merged main from Ford
cd "C:\Users\<username>\Documents\Visual Studio Code\Salesforce"
git checkout main
git pull origin main

# Delete the merged feature branch (optional but tidy)
# Replace feature/your-branch-name with the actual branch name, e.g.:
# git branch -d feature/req-efg-order-user-status-reports
git branch -d feature/your-branch-name

# Push the updated main to personal backup
git push personal --all

# Clean up the feature branch on personal too
# Replace feature/your-branch-name with the actual branch name, e.g.:
# git push personal --delete feature/req-efg-order-user-status-reports
git push personal --delete feature/your-branch-name
```

---

## Pushing workspace-level shared files to personal backup

The workspace root folder (`Visual Studio Code\`) contains shared
configuration files that are **not** inside any project's git repo. These files
drive the Copilot agent ecosystem and must be backed up separately.

### Files that need backing up

| File or folder | Purpose |
| --- | --- |
| `_copilot-shared/` | Source-of-truth for agents, chatmodes, instructions, prompts, skills, workflows |
| `sync-shared-copilot.ps1` | Syncs `_copilot-shared` into each project's `.github/` |
| `repair-git-state.ps1` | Git recovery helper script |
| `adding-a-new-subworkspace.md` | Guide for adding new project folders |
| `Visual Studio Code.code-workspace` | VS Code multi-root workspace definition |

### One-time setup - initialise a git repo at workspace root

```powershell
cd "C:\Users\<username>\Documents\Visual Studio Code"
git init -b main
```

Create a `.gitignore` to exclude everything except the shared files:

```text
# Ignore everything by default (project folders have their own repos)
*

# Explicitly include workspace-level shared files
!.gitignore
!.gitattributes
!_copilot-shared/
!_copilot-shared/**
!sync-shared-copilot.ps1
!repair-git-state.ps1
!adding-a-new-subworkspace.md
!Visual Studio Code.code-workspace
```

Create a `.gitattributes` file:

```text
* text=auto eol=lf
```

Add the personal remote and push:

```powershell
git remote add origin git@github-personal:davemcwish/vscode-workspace-shared.git
git add .
git commit -m "chore: initial commit of shared workspace config"
git push -u origin main
```

> Create the `vscode-workspace-shared` repo on GitHub first (private, empty,
> no README). Go to
> [github.com/new](https://github.com/new) (logged in as `davemcwish`).

### Routine sync - after editing _copilot-shared

After you edit files in `_copilot-shared/` and run the sync script:

```powershell
# 1. Sync changes into project repos (as usual)
cd "C:\Users\<username>\Documents\Visual Studio Code"
.\powershell\sync-shared-copilot.ps1

# 2. Commit and push the workspace-level changes to personal backup
git add .
git commit -m "chore: update shared copilot config"
git push
```

### Cloning on a different machine

On your personal laptop, clone the workspace-level repo first, then clone the
project repos inside it:

```bash
# Clone the workspace shell
git clone git@github.com:davemcwish/vscode-workspace-shared.git "Visual Studio Code"
cd "Visual Studio Code"

# Clone projects into their expected locations
git clone git@github.com:davemcwish/Salesforce.git
git clone git@github.com:davemcwish/Trails-and-Tails.git "Trails and Tails"

# Run the sync script to populate .github/ folders
pwsh ./sync-shared-copilot.ps1
```

> The `.gitignore` at the workspace root ignores the project subfolders
> because they have their own independent git repos. Only the shared
> configuration is tracked at this level.

---

## Using these repos on a different machine

### Golden rule: generate a new key on each device

Never copy the private key (`id_ed25519_personal`) from one machine to another.
Generate a fresh key pair on the new machine and add the new public key to
GitHub alongside the existing one. GitHub supports multiple keys per account.

### Windows personal laptop or work laptop

Follow these steps on the new machine:

#### Step 1: Generate a new SSH key

```powershell
ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\id_ed25519_personal" -C "your-device-name"
```

Replace `your-device-name` with something descriptive like `personal-laptop` or `work-desktop`.
Press Enter to accept the default passphrase (empty).

This creates:

- `C:\Users\<username>\.ssh\id_ed25519_personal` (private key - never share)
- `C:\Users\<username>\.ssh\id_ed25519_personal.pub` (public key - add to GitHub)

#### Step 2: Copy the public key to GitHub

```powershell
Get-Content "$env:USERPROFILE\.ssh\id_ed25519_personal.pub" | Set-Clipboard
```

Then:

1. Go to **[github.com/settings/ssh/new](https://github.com/settings/ssh/new)** (logged in as `davemcwish`).
2. Set **Title** to something like `your-device-name - personal key`.
3. Leave **Key type** as `Authentication Key`.
4. Paste the public key into the **Key** field.
5. Click **Add SSH key**.

#### Step 3: Create SSH config

Create the file `C:\Users\<username>\.ssh\config` with:

```text
Host github.com
  HostName github.com
  User git
  IdentityFile C:/Users/<username>/.ssh/id_ed25519_personal
  IdentitiesOnly yes
```

Replace `<username>` with your Windows username.

#### Step 4: Configure Git to use Windows OpenSSH

```powershell
git config --global core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe"
```

#### Step 5: Test the connection

```powershell
ssh -T git@github.com
```

Expected output:

```text
Hi davemcwish! You've successfully authenticated, but GitHub does not provide shell access.
```

#### Step 5a: Configure Git user identity

Git requires your name and email for commits. Run:

```powershell
git config --global user.email "your-email@example.com"
git config --global user.name "Your Name"
```

Replace with your actual email and name. Use the email associated with your `davemcwish` GitHub account for consistency.

#### Step 6: Clone the repos

```powershell
git clone git@github.com:davemcwish/Trails-and-Tails.git
git clone git@github.com:davemcwish/Salesforce.git
```

Both should clone successfully.

### Mac or Linux personal laptop

Follow similar steps but use the native `ssh-keygen`:

```bash
# 1. Generate a new key
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_personal -C "personal-laptop"

# 2. Display and copy the public key
cat ~/.ssh/id_ed25519_personal.pub
```

Then:

1. Add the public key to GitHub at **[github.com/settings/ssh/new](https://github.com/settings/ssh/new)**.
2. Create `~/.ssh/config`:

```text
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_personal
  IdentitiesOnly yes
```

1. Configure Git user identity:

```bash
git config --global user.email "your-email@example.com"
git config --global user.name "Your Name"
```

1. Clone the repos:

```bash
git clone git@github.com:davemcwish/Trails-and-Tails.git
git clone git@github.com:davemcwish/Salesforce.git
```

On Mac/Linux, SSH is built-in, so no Git config needed.

---

## Summary by scenario

| Scenario | SSH key needed | Git config needed |
| --- | --- | --- |
| First machine (Windows) | Generate `id_ed25519_personal` | `core.sshCommand = C:/Windows/System32/OpenSSH/ssh.exe` |
| Second machine (Windows) | Generate new `id_ed25519_personal` | Same as above |
| Mac or Linux | Generate new `id_ed25519_personal` | None - SSH built-in |
| Different GitHub account | Generate different key name | Update SSH config `IdentityFile` |

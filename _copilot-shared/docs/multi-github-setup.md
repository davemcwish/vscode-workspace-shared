# Multi-GitHub Setup: Adding Ford Personal Remotes

This guide explains how to add a **second remote** to a git repository that
already has a primary remote. We'll add a Ford personal backup remote to both
the `Salesforce` project and the VS Code workspace shared project.

**Target audience:** Complete beginners to git who have not done this before.

---

## Why Add a Second Remote?

By default, every git repository has a primary remote called `origin`. You push
to it, you pull from it. But you can add **additional remotes** to the same
local repository.

| Scenario | Use case |
| --- | --- |
| **One remote (origin only)** | Most projects. You push and pull from one place. |
| **Two remotes (origin + backup)** | Your scenario. Keep a primary remote (e.g., Ford `eu-crm-sf-admin-utils`) and also sync to a personal backup (e.g., Ford personal `dwishar1--Salesforce`). |

Think of it like having two backup drives: you still primarily use one, but you
can also copy data to a second one for safekeeping.

---

## Part 1: The Salesforce Project

**Location:** `C:\Users\dwishar1\Documents\Visual Studio Code\Salesforce`

**Current remotes:**

- `origin` -> `git@github.com:ford-innersource/eu-crm-sf-admin-utils.git` (Ford public repo)
- `personal` -> `git@github-personal:davemcwish/Salesforce.git` (Personal davemcwish backup)

**Goal:** Add a Ford personal remote without replacing the existing ones.

### Step 1a: Check your current remotes

Open PowerShell and navigate to the Salesforce folder:

```powershell
cd "C:\Users\dwishar1\Documents\Visual Studio Code\Salesforce"
git remote -v
```

You should see:

```text
origin  git@github.com:ford-innersource/eu-crm-sf-admin-utils.git (fetch)
origin  git@github.com:ford-innersource/eu-crm-sf-admin-utils.git (push)
personal        git@github-personal:davemcwish/Salesforce.git (fetch)
personal        git@github-personal:davemcwish/Salesforce.git (push)
```

### Step 1b: Add the Ford Personal remote

The Ford personal remote is a **new** GitHub organization account:
`git@github.com:ford-personal/dwishar1--Salesforce.git`

Run this command to add it:

```powershell
git remote add ford-personal git@github.com:ford-personal/dwishar1--Salesforce.git
```

**Breakdown:**

- `git remote add` -- "I want to add a new remote"
- `ford-personal` -- the **name** of this remote (you can use any name; we use `ford-personal`)
- `git@github.com:ford-personal/dwishar1--Salesforce.git` -- the URL of the repo

### Step 1c: Verify the new remote was added

```powershell
git remote -v
```

You should now see three remotes:

```text
ford-personal  git@github.com:ford-personal/dwishar1--Salesforce.git (fetch)
ford-personal  git@github.com:ford-personal/dwishar1--Salesforce.git (push)
origin  git@github.com:ford-innersource/eu-crm-sf-admin-utils.git (fetch)
origin  git@github.com:ford-innersource/eu-crm-sf-admin-utils.git (push)
personal        git@github-personal:davemcwish/Salesforce.git (fetch)
personal        git@github-personal:davemcwish/Salesforce.git (push)
```

**Good!** The `ford-personal` remote is now registered. Notice that:

- The URL uses `github.com` (not `github-personal`), because this is a Ford organization repo.
- Both `origin` and `personal` are still there -- nothing was deleted or changed.

### Step 1d: Push to the new Ford Personal remote (first time only)

The first time you push to a new remote, you need to tell git to also **create
the branch** on the remote:

```powershell
git push -u ford-personal main
```

**Breakdown:**

- `git push` -- "I want to send commits to a remote"
- `-u` -- "Also set this branch to track the remote (so future pushes are easier)"
- `ford-personal` -- which remote to push to
- `main` -- which branch to push

Expected output:

```text
Enumerating objects: 123, done.
Counting objects: 100% (123/123), done.
Delta compression using up to 12 threads
Compressing objects: 100% (45/45), done.
Writing objects: 100% (123/123), 2.34 MiB | 1.23 MiB/s, done.
Total 123 (delta 89), reused 123 (delta 89), pack-reused 0 (receiving objects: 100%)
remote: Resolving deltas: 100% (89/89), done.
To github.com:ford-personal/dwishar1--Salesforce.git
 * [new branch]      main -> main
Branch 'main' set up to track 'ford-personal/main'.
```

**What this means:** Your code is now on the `ford-personal` remote. You can
see it at `https://github.com/ford-personal/dwishar1--Salesforce`.

### Step 1e: Future pushes to Ford Personal (from now on)

After the first push, you can use:

```powershell
git push ford-personal
```

Git remembers that `main` is tracking `ford-personal/main`, so you don't need
the `-u` flag again.

---

## Part 2: The VS Code Workspace

**Location:** `C:\Users\dwishar1\Documents\Visual Studio Code`

**Current remotes:**

- `origin` -> `git@github-personal:davemcwish/vscode-workspace-shared.git` (Personal backup)

**Goal:** Add a Ford personal remote for the shared workspace.

### Step 2a: Navigate to the workspace folder

```powershell
cd "C:\Users\dwishar1\Documents\Visual Studio Code"
git remote -v
```

You should see:

```text
origin  git@github-personal:davemcwish/vscode-workspace-shared.git (fetch)
origin  git@github-personal:davemcwish/vscode-workspace-shared.git (push)
```

### Step 2b: Add the Ford Personal remote

```powershell
git remote add ford-personal git@github.com:ford-personal/dwishar1--vscode-workspace-shared.git
```

### Step 2c: Verify the new remote was added

```powershell
git remote -v
```

You should now see:

```text
ford-personal  git@github.com:ford-personal/dwishar1--vscode-workspace-shared.git (fetch)
ford-personal  git@github.com:ford-personal/dwishar1--vscode-workspace-shared.git (push)
origin  git@github-personal:davemcwish/vscode-workspace-shared.git (fetch)
origin  git@github-personal:davemcwish/vscode-workspace-shared.git (push)
```

### Step 2d: Push to the new Ford Personal remote (first time only)

```powershell
git push -u ford-personal main
```

Expected output is the same as Part 1d.

### Step 2e: Future pushes to Ford Personal (from now on)

```powershell
git push ford-personal
```

---

## What You Can Now Do

### Scenario: You made changes and want to sync both remotes

From the `Salesforce` folder:

```powershell
# Push to the primary Ford innersource repo (origin)
git push origin main

# Also push to the personal backup (ford-personal)
git push ford-personal main
```

Or from the VS Code workspace folder:

```powershell
# Push to the personal davemcwish repo (origin)
git push origin main

# Also push to the Ford personal backup (ford-personal)
git push ford-personal main
```

### Scenario: You want to pull from a specific remote

```powershell
# Pull the latest from origin
git pull origin main

# Pull the latest from ford-personal instead
git pull ford-personal main
```

### Scenario: You forgot which remote a branch is tracking

```powershell
git branch -vv
```

Example output:

```text
* main  a1b2c3d [ford-personal/main] Your last commit message
```

This tells you that your `main` branch is currently tracking `ford-personal/main`
because we used `git push -u` in Step 1d.

---

## Important Notes

### SSH Key Configuration

The new `ford-personal` remotes use `git@github.com:...` (the Ford GitHub
host). This works because your primary SSH key is registered to the Ford
`dwishar1_ford` identity.

If you get an SSH error like:

```text
Permission denied (publickey).
```

It means your SSH key is not registered to the Ford account. Contact your Ford
GitHub administrator.

### SSH Proxy Configuration (Corporate Firewall)

If you are on a corporate network with a proxy firewall, you must configure SSH
to route through the proxy. This requires two things: the proxy host details
and the `connect.exe` tool (which comes with Git for Windows).

#### Finding `connect.exe`

First, locate `connect.exe` on your system. Open PowerShell and search for it:

```powershell
Get-ChildItem -Path C:\ -Filter connect.exe -Recurse -ErrorAction SilentlyContinue
```

It is usually in one of these locations:

- `C:\Program Files\Git\mingw64\bin\connect.exe`
- `C:\Program Files (x86)\Git\mingw64\bin\connect.exe`

Copy the full path (we'll use it in the next step).

#### Configure SSH Config File

Edit your SSH config file:

```powershell
notepad $env:USERPROFILE\.ssh\config
```

Add these entries for GitHub. Replace `<PROXY_HOST>`, `<PROXY_PORT>`, and the
path to `connect.exe` with your actual values:

```text
# Ford GitHub (dwishar1_ford) — on Ford network, route through proxy
Match Host github.com exec "ping -n 1 <PROXY_HOST>"
  User git
  ProxyCommand "<PATH_TO_CONNECT_EXE>" -H <PROXY_HOST>:<PROXY_PORT> %h %p
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes

# Personal GitHub (davemcwish) — on Ford network, route through proxy
Match Host github-personal exec "ping -n 1 <PROXY_HOST>"
  HostName github.com
  User git
  ProxyCommand "<PATH_TO_CONNECT_EXE>" -H <PROXY_HOST>:<PROXY_PORT> %h %p
  IdentityFile ~/.ssh/id_ed25519_personal
  IdentitiesOnly yes

# Personal GitHub (davemcwish) — off Ford network, connect directly
Host github-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_personal
  IdentitiesOnly yes
```

**Example (for reference only):**

```text
Match Host github.com exec "ping -n 1 internet.ford.com"
  User git
  ProxyCommand "C:/Program Files/Git/mingw64/bin/connect.exe" -H internet.ford.com:83 %h %p
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes

Match Host github-personal exec "ping -n 1 internet.ford.com"
  HostName github.com
  User git
  ProxyCommand "C:/Program Files/Git/mingw64/bin/connect.exe" -H internet.ford.com:83 %h %p
  IdentityFile ~/.ssh/id_ed25519_personal
  IdentitiesOnly yes

Host github-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_personal
  IdentitiesOnly yes
```

**Key points:**

- **Full path to connect.exe:** Must be absolute and use forward slashes (`/`),
  not backslashes.
- **Match vs Host:** `Match` entries are conditional (they use `exec ping` to
  detect if you're on the network). `Host` entries always apply. This allows
  you to use the proxy on Ford network and direct connection off-network.
- **Proxy host and port:** Replace `internet.ford.com:83` with your actual
  corporate proxy address and port. Ask your network administrator if you do
  not know these values.
- **IdentitiesOnly yes:** Prevents SSH from trying all keys; it only tries the
  specified one.

#### Testing the Configuration

After saving the config file, test the connection:

```powershell
ssh -v git@github.com
```

The `-v` flag shows verbose output. You should see:

```text
...
Executing: exec "C:/Program Files/Git/mingw64/bin/connect.exe" -H internet.ford.com:83 github.com 22
...
Hi dwishar1_ford! You've successfully authenticated...
```

If you see "Permission denied (publickey)", check that:

1. The path to `connect.exe` is correct and uses forward slashes.
2. The proxy host and port are correct.
3. Your SSH keys are in the correct locations (`~/.ssh/id_ed25519` and
   `~/.ssh/id_ed25519_personal`).

### The `-u` flag (Track Upstream)

When you use `git push -u remote branch`, git remembers that this branch should
track the remote branch. Future `git push` commands automatically target the
same remote. This is convenient but not required -- you can always specify the
remote explicitly (`git push ford-personal main`).

### Naming Conventions

The remote names we used (`origin`, `personal`, `ford-personal`) are
**arbitrary**. You could call them anything:

- `primary`, `backup`, `archive`
- `main-org`, `personal-org`, `ford-org`
- `gh1`, `gh2`, `gh3`

We chose descriptive names so it's obvious what each remote is for.

---

## Troubleshooting

### Q: I see "Error: key already in use"

**Reason:** The SSH key you are using is already registered to a different
GitHub account.

**Solution:** This only happens if you are using the wrong key for the
`ford-personal` remotes. Check your SSH config (`~/.ssh/config`). The
`github.com` entries should use your Ford key (`id_ed25519`), not the personal
key.

### Q: I pushed to ford-personal but the code is not showing up on GitHub

**Reason:** Most likely, the push succeeded but GitHub is slow to refresh the
web UI (usually takes a few seconds). Or, you pushed to a different branch than
you thought.

**Solution:** Check which branch you are on:

```powershell
git branch
```

Then verify the push:

```powershell
git push -v ford-personal main
```

The verbose flag `-v` shows you exactly what was sent.

### Q: How do I stop tracking a remote?

If you decide you no longer need a remote, remove it:

```powershell
git remote remove ford-personal
```

This **does not** delete anything on GitHub. It only removes the remote
reference from your local git config. You can always add it back later.

---

## Next Steps

- **Automate syncing:** If you want to push to both remotes every time, consider
  a `pre-push` hook or GitHub Actions workflow.
- **Monitor both remotes:** Use a tool like `GitKraken` (which shows all
  remotes visually) or `git log --all --graph --oneline` to see commits across
  both.
- **Set a default push remote:** You can configure git so `git push` (with no
  remote specified) defaults to a specific remote. See `git config --help`.

---

## For Reproducibility

This process is the same for any git repository and any number of remotes:

1. **Check current remotes:** `git remote -v`
2. **Add a new remote:** `git remote add <name> <url>`
3. **Push to it:** `git push -u <name> <branch>`
4. **Verify:** `git remote -v` and check GitHub

You can apply this to other projects without modification.

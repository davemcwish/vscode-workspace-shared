# Dependency Update Scaffolding

**Date:** June 12, 2026  
**Status:** Complete  -  Ready for sync across all projects

## What Was Added

Three new files were added to `_copilot-shared/scaffold/` to enforce dependency security discipline across all projects:

### 1. `update_packages.py`

**Purpose:** Core upgrade logic for Python dependencies.

**What it does:**

- Finds `requirements.in` and `requirements-dev.in` in the project root.
- Recompiles them with `pip-tools` using the `--upgrade` flag.
- Shows a diff of what changed and asks for confirmation.
- Installs the new versions.
- Runs the project's test suite (`sanity.bat` / `sanity.sh`) to verify nothing broke.
- Uses `sys.prefix` to detect venv activation (warns if not active).

**Key features:**

- **Cross-platform:** Works on Windows, macOS, and Linux.
- **Beginner-friendly:** Asks for confirmation and explains each step.
- **Safe:** Aborts if compilation fails or tests fail.
- **Auditable:** Shows what changed before installing (can run `git diff requirements*.txt` to review).

### 2. `update_packages.bat`

**Purpose:** Windows convenience wrapper for `update_packages.py`.

**What it does:**

- Moves to the project root.
- Activates `.venv\Scripts\activate.bat` if not already active (with helpful error message).
- Runs `python scripts/update_packages.py`.
- Reports success or failure to the user.

### 3. `update_packages.sh`

**Purpose:** Linux/macOS convenience wrapper for `update_packages.py`.

**What it does:**

- Same as `.bat`, but for Bash/Zsh.
- Sources `.venv/bin/activate`.
- Uses bash-specific error handling.

## Integration Points

### 1. START-HERE-WINDOWS.md

Updated **Part 6: Keeping Dependencies Secure** to reference the scaffold scripts:

```powershell
.venv\Scripts\Activate.ps1
.\update_packages.bat
```

Explains when to update (monthly/quarterly, or after security advisories) and why it matters.

### 2. scaffold-README.md

Added new section explaining:

- Why `update_packages.*` files exist (security, breaking changes).
- How to use them on each platform.
- Prerequisites (requires `requirements.in`, `requirements-dev.in`, `scripts/` dir, and `sanity` scripts).
- How to adapt for non-Python projects.

### 3. scaffold/ file table

Added three new entries:

- `update_packages.bat`  -  Safely upgrade all dependencies (Windows)
- `update_packages.py`  -  Core upgrade logic
- (Note: `update_packages.sh` is implied by platform-specific use)

## How This Enforces Discipline

### Before (No Scaffold)

- Each project had its own `update_packages.bat` (if any).
- Paths were hard-coded (e.g., `scripts\update_packages.py`).
- Not all projects had upgrade tooling.
- Beginners didn't know how to update dependencies.

### After (Scaffold)

- **All projects inherit identical tooling** via `sync-shared-copilot.ps1`.
- **Consistent UX:** Same command works in every project (`.\update_packages.bat`).
- **Beginner-friendly:** START-HERE guide teaches users when and how to upgrade.
- **Security-first:** Upgrade scripts run the test suite, not just install packages.
- **Disciplined:** Projects that skip the scaffold miss this essential functionality.

## Deployment

### Step 1: Verify Scaffold Files

All three files are in `_copilot-shared/scaffold/`:

```text
_copilot-shared/scaffold/
  update_packages.py
  update_packages.bat
  update_packages.sh
  scaffold-README.md (updated with new section)
```

### Step 2: Sync to Existing Projects

Run the sync script (includes scaffold copy):

```powershell
cd "C:\Users\<user>\Documents\Visual Studio Code"
.\powershell\sync-shared-copilot.ps1 -Scaffold
```

This copies all scaffold files (including the three new ones) to each project that doesn't already have them.

### Step 3: Commit Changes

In `_copilot-shared/`:

```bash
git add scaffold/update_packages.* scaffold-README.md
git commit -m "feat: add scaffold dependency update tooling for security discipline"
git push
```

Then sync to each project and commit downstream:

```bash
cd Salesforce
git add update_packages.* scripts/
git commit -m "chore: add dependency update tooling from scaffold"
git push
```

## Testing

Before committing, verify the script works:

```powershell
cd "C:\Users\<user>\Documents\Visual Studio Code\Salesforce"
.venv\Scripts\Activate.ps1
.\update_packages.bat
```

Expected behavior:

1. Script activates venv (or notes it's already active).
2. Runs `pip-tools` to find upgrades.
3. Shows what changed (should see something like "Found 3 package upgrades").
4. Asks `[CONFIRM] Proceed with upgrade? (y/N):`
5. User presses `n` to skip (or `y` to proceed).
6. Script exits cleanly.

## Security Notes

- **Upgrading is not automatic.** Users must run `update_packages.bat` manually.
- **Confirmation required.** Users see what's changing before approving.
- **Test suite verification.** The script runs `sanity.bat` after upgrading, so breaking changes are caught immediately.
- **Audit trail.** Users can run `git diff requirements*.txt` to see the exact version changes before committing.

## Future Enhancements

1. **Automated dependency scanning in CI:** Add a GitHub Actions workflow that runs `update_packages.py` monthly and opens a PR with the changes.
2. **Non-Python support:** Add `Pipfile`, `Cargo.toml`, `package.json` equivalents in separate scaffold variants.
3. **Dependency license scanning:** Extend the script to check for license compliance of upgraded packages.

---

**Note:** The old `update_packages.bat` in the Salesforce project root can now be archived or deleted  -  all projects will inherit the scaffold version via sync.

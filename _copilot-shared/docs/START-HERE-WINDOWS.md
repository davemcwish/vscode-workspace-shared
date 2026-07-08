# Getting Started: Windows 11

**For macOS or Linux users:** The principles here apply, but replace Step 2 activation and Step 4 shell commands with your OS's native tools. A detailed Linux/macOS guide is coming soon.

---

## What This Guide Is For

You've found one of my projects on GitHub at [davemcwish](https://github.com/davemcwish/) and want to try it locally on your Windows 11 machine. This guide takes you from "interested" to "running code" in about 30 minutes.

**What you'll have at the end:**

- A copy of the source code on your computer.
- A Python environment with all the project's dependencies.
- Ability to run backend scripts or start the web frontend.
- Understanding of what each tool does (so you can troubleshoot yourself).

---

## Part 1: Install Required Software (5 minutes)

You need three tools to run the projects  -  Visual Studio Code, a Python
engine, and Git. If you already have them, skip to Part 2. Two further tools
are optional and used by contributors: the **GitHub CLI** (for working with
pull requests from the terminal) and **Node.js** (for running the full local
quality gate). Both are covered below.

### Visual Studio Code

**What is it?** A code editor  -  a fancy text editor designed for programmers. It colors your code, catches mistakes, and runs commands for you.

**Why you need it:** To read, edit, and run Python code. You *could* use Notepad, but VS Code makes life vastly easier.

**Install it:**

1. Go to [code.visualstudio.com](https://code.visualstudio.com/)
2. Click **Download for Windows** (it auto-detects your OS).
3. Run the installer and accept all defaults.
4. Open VS Code (it's now in your Start menu).

**Verify it works:** VS Code opens and you see the Welcome screen. ✅

### Python Engine

**What is it?** A programming language. These projects are written in Python, so your computer needs a **Python engine** (the software that actually runs `.py` files) installed.

**Why you need it:** Because the code is Python. Without it, running `.py` files fails.

**Which version?** These projects need **Python 3.12 or newer**. This section is deliberately version-agnostic, because Python publishes a new version roughly once a year. **At the time of writing, we used Python 3.13.5.** Unless a project's own `README.md` says otherwise, install the latest stable release from python.org.

**Install it:**

1. Go to [python.org/downloads](https://www.python.org/downloads/)
2. Click the big **Download Python** button. It offers the latest stable version automatically (at the time of writing, 3.13.5).
3. Run the installer.
4. **IMPORTANT:** Check the box labeled **"Add Python to PATH"** before clicking Install. This lets your computer find Python from any folder.
5. Click **Install Now**.

**Verify it works:** Open PowerShell (press `Win+X`, then `I`) and type:

```powershell
py --version
```

Expected output: `Python 3.13.5` (or whatever version you installed). If you see "command not found," Python isn't on your PATH  -  go back and re-run the installer, making sure to check "Add Python to PATH."

> **No `py` launcher?** Some managed or enterprise Python builds don't register the `py` launcher, so `py` returns "command not found" even though Python is installed. In that case use the full path to `python.exe` instead  -  for example `& "C:\Users\$env:USERNAME\AppData\Local\Programs\Python\Python313\python.exe" --version` (change `Python313` to your version). Every `py -3.13` command in this guide can be replaced with that full path.

#### Upgrade it (moving to a newer Python engine)

Python releases a new version about once a year. Upgrading the **Python engine** is different from upgrading Git or the GitHub CLI (below): you cannot upgrade a project's virtual environment in place. Instead you install the new engine alongside the old one, then rebuild each project's virtual environment (the `.venv` folder) on top of it.

> **What is a virtual environment (`.venv`)?** An isolated folder of Python packages that belongs to one project (explained fully in Part 4). Because it is tied to the exact Python engine that created it, you cannot swap the engine underneath it  -  you rebuild it. That is why this is more work than a normal upgrade.

Here is the exact, beginner-friendly process we followed. It is safe because it keeps a backup until you have proved the new engine works. Do this once per project.

1. **Install the new Python engine.** Follow the "Install it" steps above for the new version. The old and new versions can live side by side  -  the `py` launcher lets you choose which one to use (for example `py -3.13` or `py -3.12`).

2. **Open PowerShell in the project folder.** For example:

   ```powershell
   cd "C:\Users\$env:USERNAME\Projects\Salesforce"
   ```

3. **Back up the old virtual environment.** Renaming it (instead of deleting it) lets you roll back instantly if anything goes wrong:

   ```powershell
   Rename-Item .venv .venv-old-bak
   ```

4. **Create a fresh virtual environment with the new engine.** Change `3.13` to match the version you installed:

   ```powershell
   py -3.13 -m venv .venv
   ```

5. **Activate the new environment.** Your prompt gains a `(.venv)` prefix:

   ```powershell
   .venv\Scripts\Activate.ps1
   ```

6. **Reinstall the project's dependencies, one file at a time.** Installing them separately (rather than all in one command) avoids version clashes between the runtime and developer dependency lists:

   ```powershell
   python -m pip install --upgrade pip
   pip install -e .
   pip install -r requirements.txt
   pip install -r requirements-dev.txt
   ```

   If a project has no `requirements-dev.txt`, skip that line. If it has a `frontend/` folder, also run `pip install -r frontend/requirements-frontend.txt`.

7. **Check the dependency tree is consistent.** This reports any conflicting package versions:

   ```powershell
   pip check
   ```

   Expected output: `No broken requirements found.`

8. **Run the project's tests to prove the new engine works.** Most projects in this workspace use `pytest`:

   ```powershell
   pytest
   ```

   Expected: every test passes. If they do, the new engine is working correctly.

9. **Point VS Code at the new environment.** Open the Command Palette (`Ctrl+Shift+P`), run **Python: Select Interpreter**, and choose the one inside your project's `.venv` folder. Then run **Developer: Reload Window** so VS Code lets go of the old files.

10. **Delete the backup once you are happy.** Only after the tests pass and VS Code is using the new environment:

    ```powershell
    Remove-Item .venv-old-bak -Recurse -Force
    ```

    If Windows says a file such as `python.exe` is "in use," something still has the old environment open. Close it (or run **Developer: Reload Window** again) and retry.

> **Roll back if needed:** If the new engine causes problems, delete the new `.venv`, rename `.venv-old-bak` back to `.venv`, and you are exactly where you started.

### Git

**What is it?** A version control system  -  software that tracks changes to code over time. Think of it like "Save As" for code, but more powerful.

**Why you need it:** To download my projects from GitHub to your computer.

**Install it:**

1. Go to [git-scm.com/download/win](https://git-scm.com/download/win)
2. Click the **64-bit Git for Windows Setup** link (unless you specifically know you need 32-bit).
3. Run the installer and accept all defaults.
4. At the end, it offers to launch Git Bash  -  you can close that (we'll use PowerShell instead).

**Verify it works:** Open PowerShell and type:

```powershell
git --version
```

Expected output: `git version X.X.X` (some version number).

**Upgrade it:** Git upgrades in place  -  no project rebuild is needed, unlike the Python engine. On recent versions you can run `git update-git-for-windows`, or simply download and run the latest installer from [git-scm.com/download/win](https://git-scm.com/download/win). Your settings and cloned repositories are left untouched.

### GitHub CLI

**What is it?** The **GitHub CLI** (`gh`) is GitHub's official command-line tool. It lets you do GitHub tasks  -  sign in, clone repositories, and open, review, or merge pull requests  -  straight from PowerShell, without opening a browser.

**Why you need it:** It is optional for just running the projects, but it makes contributing much smoother. We used it recently to sign in and manage pull requests from the terminal. If you plan to push changes back to GitHub, it is well worth installing.

**Install it:**

1. Go to [cli.github.com](https://cli.github.com/)
2. Click **Download for Windows**. This guide stays version-agnostic because `gh` updates often  -  take whatever the latest version is.
3. Run the installer and accept all defaults.
4. Close and reopen PowerShell so it picks up the new `gh` command.

**Verify it works:** Open a *new* PowerShell window and type:

```powershell
gh --version
```

Expected output: `gh version X.X.X` (some version number).

**Sign in (first time only):** Connect `gh` to your GitHub account:

```powershell
gh auth login
```

Follow the prompts (choose **GitHub.com**, then **HTTPS**, then **Login with a web browser**). This is a one-time step; `gh` remembers you afterwards.

**Upgrade it:** Like Git, the GitHub CLI upgrades in place  -  no virtual environment rebuild needed. Re-run the latest installer from [cli.github.com](https://cli.github.com/), or if you installed it with the Windows package manager, run `winget upgrade --id GitHub.cli`.

### Node.js (optional  -  for contributors only)

**What is it?** A JavaScript runtime. You only need it if you plan to commit changes and run the full local quality gate (`sanity.bat`).

**Why you need it:** `sanity.bat` step 7 lints the Markdown documentation with a tool called `markdownlint`, which runs through Node's `npx` command. Without Node.js, that one step is silently skipped on your machine  -  the rest of the gate still runs. GitHub's CI always runs the Markdown check, so installing Node lets you catch Markdown problems before you push instead of after.

> **Just running the projects, not changing them?** Skip this. You do not need Node.js to run the code  -  only to run the Markdown lint locally.

**Install it:**

1. Go to [nodejs.org](https://nodejs.org/)
2. Download the **LTS** version (labelled "Recommended For Most Users").
3. Run the installer and accept all defaults.

**Verify it works:** Open a *new* PowerShell window (so it picks up the updated PATH) and type:

```powershell
node --version
```

Expected output: `vXX.X.X` (some version number). The `npx` command that `sanity.bat` uses is installed alongside Node automatically.

---

## Part 2: Configure Your Environment (10 minutes)

### 2.1 Create a Folder for Your Projects

You'll store all cloned repos in one place. Open PowerShell and run:

```powershell
mkdir "C:\Users\$env:USERNAME\Projects"
cd "C:\Users\$env:USERNAME\Projects"
```

(This creates a `Projects` folder in your home directory and moves into it.)

### 2.2 Configure Git

Git needs to know who you are. Open PowerShell and run:

```powershell
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

Replace `Your Name` and `your.email@example.com` with your real name and email. This info will be recorded in any commits you make.

### 2.3 Verify Python is on Your PATH

Your computer has a list of places it searches for programs (called the "PATH"). When you type `py`, the computer looks in these places to find the Python executable.

Open PowerShell and run:

```powershell
py -c "import sys; print(sys.executable)"
```

Expected output: Something like `C:\Users\YourUsername\AppData\Local\Programs\Python\Python313\python.exe` (the `Python313` part will match whatever version you installed).

If you see an error, Python is not on your PATH. Go back and re-run the Python installer, checking "Add Python to PATH."

---

## Part 3: Get the Source Code (Choose One)

### Option A: Git Clone (Recommended  -  Takes 2 minutes)

Use this if you might make changes and push them back, or if you want the full git history.

Open PowerShell, navigate to your Projects folder, and clone the repo:

```powershell
cd "C:\Users\$env:USERNAME\Projects"
git clone https://github.com/davemcwish/Salesforce.git
cd Salesforce
```

(Replace `Salesforce` with the actual repo name.)

### Option B: ZIP Download (Simpler  -  Takes 1 minute)

Use this if you just want to explore and don't need git history.

1. Go to the repo on GitHub (e.g., [github.com/davemcwish/Salesforce](https://github.com/davemcwish/Salesforce)).
2. Click the green **Code** button.
3. Click **Download ZIP**.
4. Extract the ZIP file to `C:\Users\YourUsername\Projects\`.
5. Open PowerShell and navigate to the extracted folder:

```powershell
cd "C:\Users\$env:USERNAME\Projects\Salesforce"
```

**Which option?** If you're unsure, use **Option A (Git Clone)**. It's the standard workflow and gives you more control later.

---

## Part 4: Set Up a Project for Development (5 minutes)

Every Python project should have its own isolated **virtual environment** (a `.venv` folder). This prevents conflicts between different projects' dependencies.

### 4.1 Create a Virtual Environment

Open PowerShell in the project folder and run:

```powershell
py -3.13 -m venv .venv
```

**What this does:**

- `py -3.13`  -  runs Python 3.13 (change this number to match the version you installed  -  for example `py -3.12`)
- `-m venv`  -  the venv module (which creates isolated Python environments)
- `.venv`  -  the name of the folder to create

**Expected:** A new `.venv` folder appears in your project. This can take 10-30 seconds.

### 4.2 Activate the Virtual Environment

**Every time** you work on this project, activate its venv first:

```powershell
.venv\Scripts\Activate.ps1
```

**Expected:** Your PowerShell prompt changes from `PS C:\...` to something like `(.venv) PS C:\...`. The `(.venv)` prefix means the venv is active.

**Why this matters:** When you install packages (via `pip install`), they go into the venv's folder, not system-wide. This keeps projects isolated and prevents conflicts.

### 4.3 Install Dependencies

Every project has a `requirements.txt` file that lists the Python packages it needs. Install them all:

```powershell
pip install -r requirements.txt
```

**Expected:** You see messages like `Collecting flask` and `Successfully installed flask-X.X.X`. This can take 30 seconds to a few minutes depending on the number and size of packages.

If the project has a `frontend/` folder, also run:

```powershell
pip install -r frontend/requirements-frontend.txt
```

**When you're done with the project:** Type `deactivate` to exit the venv. Next time you open PowerShell in this folder, you'll need to activate again.

---

## Part 5: Running Backends and Frontends

### Backend Scripts

Backend scripts are standalone Python programs that do a specific job (e.g., query Salesforce, export data, manage users).

To run a script, activate the venv, then use Python:

```powershell
.venv\Scripts\Activate.ps1
python scripts/my_script.py --help
```

The `--help` flag shows what arguments the script accepts. For example:

```powershell
python scripts/list_users.py --org AXP_PROD --output users.csv
```

### Frontend Web Apps

Frontend apps (like `frontend/app.py`) **are not regular HTML files**. They start a local web server on your machine.

**This is important:** You cannot double-click `frontend/app.py` or open it in a browser. It's a Python program that needs to run from the command line.

To start the frontend:

```powershell
.venv\Scripts\Activate.ps1
cd Salesforce
python frontend/app.py
```

**Expected output:**

```text
2026-06-12 12:34:56 INFO     __main__: Starting Salesforce Admin Tools frontend at http://localhost:5000
 * Running on http://127.0.0.1:5000
 * Press CTRL+C to quit
```

Now open your web browser and go to:

```text
http://localhost:5000
```

You see the web app. It's running on your local machine in a server process that the Python script started.

**To stop it:** Press `Ctrl+C` in PowerShell.

---

## Part 6: Keeping Dependencies Secure (Important)

Python packages (dependencies) are maintained by the open-source community. Like all software, they occasionally have security bugs. Keeping them updated protects you from exploits.

### When to Update

Update dependencies:

- **Monthly or quarterly** as a routine maintenance task.
- **Immediately** when a security advisory mentions a package you use.
- **After cloning** a repo someone else maintains (to ensure you have the latest versions).

### How to Update

Every project in this workspace includes a helper script to safely upgrade dependencies. Activate your venv and run:

```powershell
.venv\Scripts\Activate.ps1
.\update_packages.bat
```

**What it does:**

1. Checks for newer versions of all packages.
2. Shows you which packages will be updated (and how).
3. Asks if you want to proceed.
4. Installs the new versions.
5. Runs `sanity.bat` to confirm nothing broke.

**Example output:**

```text
Current versions:
  flask==3.0.1
  requests==2.31.0

New versions available:
  flask==3.0.3 (security fix)
  requests==2.32.0

Upgrade? [y/N] y
Installing...
Successfully installed flask-3.0.3 requests-2.32.0
Running tests...
All tests passed.
```

### If You Skip Updates

- Older packages may have known security holes.
- If your code ever gets committed to a shared repo or deployed to production, security scanners will flag it.
- It's a small risk if you're just exploring locally, but a good habit to build.

### Advanced: Understanding `requirements.txt` vs `requirements.in`

Some projects have both files:

- **`requirements.txt`**  -  exact versions (e.g., `flask==3.0.1`). Reproducible, but doesn't get updates automatically.
- **`requirements.in`**  -  loose versions (e.g., `flask>=3.0`). More flexible; `update_packages.py` uses it to find new versions.

You can ignore this distinction for now. Just run `update_packages.py` when you want to update.

---

## Part 7: Creating Your Own Project (Reusing the Scaffold)

If you want to fork a repo or create your own project using the shared tools and standards, the scaffold configuration handles setup automatically.

### 7.1 Fork or Clone the Base Project

Clone the project you want to build from:

```powershell
git clone https://github.com/davemcwish/Salesforce.git my-new-tool
cd my-new-tool
```

### 7.2 Run the Sync Script

The `sync-shared-copilot.ps1` script in the parent workspace copies shared configuration into your new project:

```powershell
cd "C:\Users\$env:USERNAME\Documents\Visual Studio Code"
.\sync-shared-copilot.ps1 -Projects "my-new-tool"
```

### 7.3 Use the Scaffold

The scaffold provides:

- `sanity.bat`  -  local quality gate (run this before committing).
- `update_packages.bat`  -  safely upgrade dependencies (run quarterly or after security advisories).
- `requirements.in` and `requirements-dev.in`  -  starter dependency files.
- `README.md`, `CONTRIBUTING.md`, `CHANGELOG.md`  -  documentation templates.
- `.github/`  -  shared Copilot instructions and standards.

See [Adding a New Subworkspace](./adding-a-new-subworkspace.md) for full details.

---

## Troubleshooting

### "Python not found" or "'py' is not recognized"

**Cause:** Python is not on your PATH.

**Fix:** Re-run the Python installer (see Part 1), and make absolutely sure to check **"Add Python to PATH"** before clicking Install.

**Quick test:** Restart PowerShell and type `py --version`. If it still fails, your PATH wasn't updated. Try restarting Windows.

### ".venv already exists" or "venv folder is not empty"

**Cause:** You ran `py -3.13 -m venv .venv` twice, or the venv is corrupted.

**Fix:** Delete the `.venv` folder and recreate it:

```powershell
rm -r .venv
py -3.13 -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### "ModuleNotFoundError: No module named 'flask'" or Similar

**Cause:** You didn't activate the venv, or dependencies weren't installed.

**Fix:**

1. Activate the venv: `.venv\Scripts\Activate.ps1`
2. Check your prompt starts with `(.venv)`.
3. Run `pip install -r requirements.txt` again.

If that fails, try:

```powershell
python -m pip install --upgrade pip
pip install -r requirements.txt
```

### "Cannot find .venv\Scripts\Activate.ps1"

**Cause:** The venv doesn't exist, or you're in the wrong folder.

**Fix:** Check you're in the project root (the folder containing the `.venv` folder) and run:

```powershell
pwd  # shows current folder
ls   # lists what's inside
```

If you see `.venv` listed, run:

```powershell
.venv\Scripts\Activate.ps1
```

If `.venv` is not listed, you're in the wrong folder. Navigate to the project root and try again.

### "ModuleNotFoundError: No module named 'sf_admin_utils'"

**Cause:** For projects that import local modules, the module isn't installed in editable mode.

**Fix:** Install the local package:

```powershell
pip install -e .
```

(The `-e` flag means "editable"  -  changes to the code take effect immediately without reinstalling.)

### Script runs but produces wrong results or crashes

**Next step:** Read the script's `--help` output and any error messages carefully. If you're stuck:

1. Check the project's `README.md`  -  it often has troubleshooting.
2. Check the project's `CONTRIBUTING.md`  -  it may explain how to report issues.
3. Open an issue on the GitHub repo with the error message and steps to reproduce.

---

## What's Next?

Now that you can run the code:

- **Explore:** Open the project in VS Code and read the source.
- **Modify:** Change a Python file and re-run the script to see the effect.
- **Contribute:** If you improve something, follow `CONTRIBUTING.md` to submit a pull request.
- **Create your own:** Use [Part 7](#part-7-creating-your-own-project-reusing-the-scaffold) to fork the project and build your own tool.

Happy coding! 🚀

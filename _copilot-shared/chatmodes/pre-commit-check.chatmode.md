---
description: "Run the full quality gate and summarise results before a PR is raised."
tools: ['search/codebase', 'runCommands/runInTerminal']
---

<!-- SYNC NOTE: Kept intentionally in sync with pre-commit-check.agent.md.
Some Copilot setups use agent files; others use chatmode files - both must
be available. Any change to phases, checklists, rules, or report format MUST
be applied to BOTH files in the same commit.
See _copilot-shared/AGENT-CHATMODE-SYNC.md for the full pair inventory. -->

You are operating in Pre-Commit Check mode.

Your job is to perform a **complete pre-commit review** before a PR is raised.
This includes a Cycode pre-flight static review, running the automated quality
gate, and performing static checks that `sanity.bat` cannot catch (because it
runs on Windows, not the CI Linux runner).

Never modify source files in this mode.

---

## Step 0 - Cycode Pre-Flight (static review - no commands needed)

Before running any tool, scan the changed source files visually for patterns
that Cycode's SAST rules will flag. These checks require reading the code, not
running it. Report each as ✅ PASS / ❌ NEEDS FIX / N/A.

### Subprocess safety (Cycode: "Unsanitized user input in OS command")

- [ ] Every `subprocess.run` / `subprocess.Popen` call uses a list, not a string.
- [ ] Every tainted input (CLI arg, env var, API response) is validated before
      reaching the command list.
- [ ] The validator returns `match.group(0)` - not the original input - to break
      Cycode's intra-procedural taint chain.
- [ ] A local inline re-verification (`_m = re.fullmatch(...); safe_x = _m.group(0)`)
      is present in the **same function** that calls `subprocess.run`.
- [ ] `shell=False` is passed explicitly.

### File path safety (Cycode: "Unsanitized dynamic input in file path")

- [ ] Every path derived from user input or external data is validated with an
      allowlist function (e.g. `resolve_safe_path()`).
- [ ] A local inline re-verification breaks the taint chain in the same function
      scope before the path reaches `open()`, `wb.save()`, or `shutil.copy()`.

### Secrets and credentials

- [ ] No hardcoded tokens, passwords, API keys, or connection strings.
- [ ] No real usernames or workstation paths in comments, docstrings, or examples.

### PRNG usage (Cycode: "Usage of weak Pseudo-Random Number Generator")

- [ ] Any use of `random.Random`, `random.choice`, `random.randint`, etc. is for
      non-security purposes only (mock data, shuffling, simulation).
- [ ] **Preferred fix for deterministic mock/prototype code:** eliminate the PRNG
      entirely - derive agency, date, and other values from a counter using
      modular arithmetic. No import, no suppression, Cycode cannot flag it.
- [ ] **If randomness is genuinely needed (non-deterministic):** use
      `random.SystemRandom()` (backed by `os.urandom()`), which Cycode accepts.
- [ ] **`# nosec B311` suppresses bandit only - it does NOT satisfy Cycode SAST.**
      Cycode runs its own engine and will still flag the violations as unresolved.
- [ ] No `random` module usage for tokens, session IDs, passwords, or
      cryptographic nonces - use `secrets` instead.

### Network calls

- [ ] TLS verification is not disabled (never `verify=False`).

### Dependencies

- [ ] Any new package has been checked for active maintenance before adding.

### Cross-platform (CI and Cycode run on Linux)

- [ ] No backslash path separators - use `pathlib.Path` or `os.path.join()`.
- [ ] All `open()` calls specify `encoding='utf-8'`.
- [ ] Windows-only imports/code are guarded with `sys_platform == "win32"`.
- [ ] `.secrets.baseline` path entries use forward slashes.

> If any item is ❌ NEEDS FIX, list the file:line and the required fix.
> Do not proceed to Step 1 until all ❌ items are resolved.

---

## Step 1 - Run `sanity.bat`

Run `sanity.bat` from the project root and report each tool result:

| Step | Tool | Result |
|------|------|--------|
| 0 | Cycode pre-flight | |
| 1 | ruff format | |
| 2 | ruff lint | |
| 3 | mypy | |
| 4 | bandit | |
| 5 | detect-secrets | |
| 6 | pytest + coverage | |

If **any** step fails, show the exact error output and stop - do not proceed
to Step 2.

---

## Step 2 - Static checks (things `sanity.bat` cannot catch)

These checks must be performed manually because `sanity.bat` runs on Windows
where environment assumptions differ from the Ubuntu CI runner.

### 2a - Platform-specific mock coverage

For any test class that calls the main entry point of a script that invokes
an external CLI tool (e.g. `subprocess.run`, `shutil.which`), verify that
an `autouse=True` fixture exists in that class to mock the tool's presence.

**Rule:** On Linux CI the tool may be absent; `shutil.which()` returns `None`
and `main()` raises `RuntimeError` before reaching any test logic. Every
test class calling `module.main(...)` must mock the tool.

Report PASS (all `main()`-calling classes have the fixture) or FAIL
(list the class names that are missing it).

### 2b - Pytest fixture type hints

For every new or modified test file, check that no fixture parameter uses
`Any` as its type annotation. Accepted types are:

| Fixture | Correct type |
|---------|-------------|
| `monkeypatch` | `pytest.MonkeyPatch` |
| `caplog` | `pytest.LogCaptureFixture` |
| `capsys` | `pytest.CaptureFixture[str]` |
| `tmp_path` | `pathlib.Path` |

Run:

```powershell
Select-String -Path "tests\*.py" -Pattern "monkeypatch: Any|caplog: Any|capsys: Any|tmp_path: Any"
```

Report PASS (no matches) or FAIL (list the file and line numbers).

### 2c - No bare `except:` or silent error swallowing

```powershell
Select-String -Path "scripts\*.py", "src\**\*.py" -Pattern "^\s*except\s*:" -Recurse
```

Report PASS (no matches) or FAIL (list occurrences).

### 2d - No `print()` in production code

```powershell
Select-String -Path "scripts\*.py", "src\**\*.py" -Pattern "^\s*print\(" -Recurse
```

Report PASS (no matches) or FAIL (list occurrences). Logging calls are fine.

### 2e - No hard-coded secrets or tokens

```powershell
Select-String -Path "scripts\*.py", "src\**\*.py" -Pattern "password\s*=\s*['""]|token\s*=\s*['""]|secret\s*=\s*['""]" -Recurse
```

Report PASS (no matches) or FAIL.

### 2f - `CHANGELOG.md` updated

Check that `CHANGELOG.md` contains an entry for the current changes.
Report PASS or FAIL with a reminder of what is missing.

### 2g - Documentation updated

For every script added or significantly changed, verify that corresponding
documentation exists. Report any scripts that have no matching guide or doc.

### 2h - Secrets baseline path separators (Windows -> POSIX)

```powershell
Select-String -Path ".secrets.baseline" -Pattern '\\\\'
```

The CI runner is Ubuntu and `detect-secrets scan` produces POSIX paths (`/`).
If the baseline contains Windows backslashes (`\\`), the scan will report
"new secrets found" because paths won't match.

**Rule:** FAIL if any `\\` found. Fix with:

```powershell
(Get-Content .secrets.baseline) -replace '\\\\', '/' | Set-Content .secrets.baseline
```

### 2i - Test function return annotations

```powershell
Select-String -Path "tests\*.py" -Pattern "^def test_.*\)\s*:" -Recurse
```

**Rule:** Every `def test_...():` must have `-> None:`. FAIL if any match
lacks the annotation.

### 2j - Stale or incorrect `# noqa` comments

```powershell
ruff check --select RUF100 src tests scripts
```

RUF100 flags unused or incorrect `# noqa` directives. FAIL if any are found.

### 2k - Code review pair verification

If `docs/reviews/` exists, verify that every review file has a corresponding
remediation file and vice versa.

**Naming convention:**

```text
docs/reviews/code-review-YYYY-MM-DDTHH-MM.md              (the review)
docs/reviews/code-review-YYYY-MM-DDTHH-MM-remediation.md  (the remediation)
```

**Check:**

```powershell
$reviews = Get-ChildItem -Path "docs\reviews" -Filter "code-review-*T*-*.md" -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch '-remediation\.md$' }
$remediations = Get-ChildItem -Path "docs\reviews" -Filter "*-remediation.md" -ErrorAction SilentlyContinue
```

- Every review file must have a matching `-remediation.md` file.
- Every `-remediation.md` file must reference the correct source review in
  its `Source review:` header field.

FAIL if any review has no remediation partner ("Review findings not yet
remediated") or any remediation is orphaned ("Missing source review").
PASS if `docs/reviews/` does not exist or all pairs are complete.

---

## Step 3 - Final summary

Produce a single summary table covering all checks:

| Check | Result | Notes |
|-------|--------|-------|
| Step 0: Cycode pre-flight | | |
| sanity.bat (all 6 steps) | | |
| 2a Platform-specific mock coverage | | |
| 2b Fixture type hints | | |
| 2c No bare `except:` | | |
| 2d No `print()` in production | | |
| 2e No hard-coded secrets | | |
| 2f Changelog updated | | |
| 2g Docs updated | | |
| 2h Secrets baseline paths | | |
| 2i Test return annotations | | |
| 2j Stale `# noqa` comments | | |
| 2k Code review pairs | | |

If **all** checks are PASS: output **"Quality gate passed - safe to raise PR."**

If **any** check is FAIL: list the failing items with remediation steps and
output **"Quality gate FAILED - do not raise PR until all items are resolved."**

---

## Step 1 - Run `sanity.bat`

Run `sanity.bat` from the project root and report each tool result as a
PASS / FAIL table:

| Step | Tool | Result |
|------|------|--------|
| 1 | ruff format | |
| 2 | ruff lint | |
| 3 | mypy | |
| 4 | bandit | |
| 5 | detect-secrets | |
| 6 | pytest + coverage | |

If **any** step fails, show the exact error output and stop - do not proceed
to Step 2.

---

## Step 2 - Static checks (things `sanity.bat` cannot catch)

These checks must be performed manually because `sanity.bat` runs on Windows
where environment assumptions differ from the Ubuntu CI runner.

### 2a - `_mock_sf_cli` fixture coverage

For every `test_export_*_pdfs_prod.py` file, run:

```powershell
Select-String -Path "tests\test_export_*_pdfs_prod.py" -Pattern "def _mock_sf_cli|module\.main\("
```

**Rule:** Every test **class** that contains a call to `module.main(...)` must
also define an `_mock_sf_cli` fixture decorated with `@pytest.fixture(autouse=True)`.

`sanity.bat` cannot catch this gap because on Windows the Salesforce CLI (`sf`)
is installed and `shutil.which("sf")` returns a real path. On the Ubuntu CI
runner `sf` is absent, so `which` returns `None` and `main()` raises
`RuntimeError` before reaching any test logic.

Report result as PASS (all `main()`-calling classes have the fixture) or FAIL
(list the class names that are missing it).

### 2b - Pytest fixture type hints

For every new or modified test file, check that no fixture parameter uses
`Any` as its type annotation. Accepted types are:

| Fixture | Correct type |
|---------|-------------|
| `monkeypatch` | `pytest.MonkeyPatch` |
| `caplog` | `pytest.LogCaptureFixture` |
| `capsys` | `pytest.CaptureFixture[str]` |
| `tmp_path` | `pathlib.Path` |

Run:

```powershell
Select-String -Path "tests\*.py" -Pattern "monkeypatch: Any|caplog: Any|capsys: Any|tmp_path: Any"
```

Report PASS (no matches) or FAIL (list the file and line numbers).

### 2c - No bare `except:` or silent error swallowing

```powershell
Select-String -Path "scripts\*.py", "src\**\*.py" -Pattern "^\s*except\s*:" -Recurse
```

Report PASS (no matches) or FAIL (list occurrences).

### 2d - No `print()` in production code

```powershell
Select-String -Path "scripts\*.py", "src\**\*.py" -Pattern "^\s*print\(" -Recurse
```

Report PASS (no matches) or FAIL (list occurrences). Logging calls are fine.

### 2e - No hard-coded secrets or tokens

```powershell
Select-String -Path "scripts\*.py", "src\**\*.py" -Pattern "password\s*=\s*['""]|token\s*=\s*['""]|secret\s*=\s*['""]" -Recurse
```

Report PASS (no matches) or FAIL.

### 2f - `Changelog.md` updated ⚠ MANDATORY

> **This check must never be skipped.** The Changelog must be updated for
> every commit that changes code, configuration, documentation, or tooling  - 
> not just feature additions.

Check that `Changelog.md` contains an entry dated today for the current
session's changes. Report PASS or FAIL with a specific list of what is missing.
If no entry exists, this is a ❌ HARD FAIL - do not proceed to commit.

### 2g - Documentation updated

For every script added or significantly changed, verify that a corresponding
guide exists under `docs/`. Report any scripts that have no matching guide.

### 2h - Secrets baseline path separators (Windows -> POSIX)

```powershell
Select-String -Path ".secrets.baseline" -Pattern '\\\\'
```

The CI runner is Ubuntu and `detect-secrets scan` produces POSIX paths (`/`).
If the baseline contains Windows backslashes (`\\`), the scan will report
"new secrets found" because paths won't match.

**Rule:** FAIL if any `\\` found. Fix with:

```powershell
(Get-Content .secrets.baseline) -replace '\\\\', '/' | Set-Content .secrets.baseline
```

### 2i - Test function return annotations

```powershell
Select-String -Path "tests\*.py" -Pattern "^def test_.*\)\s*:" -Recurse
```

**Rule:** Every `def test_...():` must have `-> None:`. FAIL if any match
lacks the annotation.

### 2j - Stale or incorrect `# noqa` comments

```powershell
ruff check --select RUF100 src tests scripts
```

RUF100 flags unused or incorrect `# noqa` directives. FAIL if any are found.

### 2k - Code review pair verification

If `docs/reviews/` exists, verify that every review file has a corresponding
remediation file and vice versa.

**Naming convention:**

```text
docs/reviews/code-review-YYYY-MM-DDTHH-MM.md              (the review)
docs/reviews/code-review-YYYY-MM-DDTHH-MM-remediation.md  (the remediation)
```

- Every review file must have a matching `-remediation.md` file.
- Every `-remediation.md` file must reference the correct source review.

FAIL if any review has no remediation partner or any remediation is orphaned.
PASS if `docs/reviews/` does not exist or all pairs are complete.

### 2l - importlib script tracking (CI vs local gap)

Any test that loads a `scripts/*.py` file via `importlib.util.spec_from_file_location`
will pass locally (the file is on disk) but fail on CI with `FileNotFoundError`
if that script is absent from the git index - whether gitignored, untracked, or
accidentally omitted from staging.

Run:

```powershell
# Find all script names loaded via importlib in test files
$refs = Select-String -Path "tests\*.py" -Pattern 'spec_from_file_location\s*\(\s*"([\w_]+)"' |
    ForEach-Object { $_.Matches.Groups[1].Value } | Sort-Object -Unique

# Check each one is tracked by git
$untracked = $refs | Where-Object { -not (git ls-files "scripts/$_.py").Trim() }

if ($untracked) {
    Write-Host "FAIL: the following scripts are referenced by tests but NOT tracked by git:"
    $untracked | ForEach-Object { Write-Host "  scripts/$_.py" }
    Write-Host "Fix: either commit the file (git add -f if gitignored) or add a gitignore exception."
} else {
    Write-Host "PASS"
}
```

**Rule:** FAIL if any referenced script is not tracked by git. This is a
🔴 CRITICAL CI failure - tests will always error on the Linux runner even
though they pass on Windows. PASS if no `spec_from_file_location` calls are
found, or all referenced scripts are tracked.

---

## Step 3 - Final summary

Produce a single summary table covering all checks:

| Check | Result | Notes |
|-------|--------|-------|
| sanity.bat (all 6 steps) | | |
| 2a `_mock_sf_cli` coverage | | |
| 2b Fixture type hints | | |
| 2c No bare `except:` | | |
| 2d No `print()` in production | | |
| 2e No hard-coded secrets | | |
| 2f Changelog updated | | |
| 2g Docs updated | | |
| 2h Secrets baseline paths | | |
| 2i Test return annotations | | |
| 2j Stale `# noqa` comments | | |
| 2k Code review pairs | | |
| 2l importlib script tracking | | |

If **all** checks are PASS: output **"Quality gate passed - safe to raise PR."**

If **any** check is FAIL: list the failing items with remediation steps and
output **"Quality gate FAILED - do not raise PR until all items are resolved."**

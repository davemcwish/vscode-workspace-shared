---
description: "Run the full quality gate and summarise results before a PR is raised."
tools: ['runInTerminal', 'codebase']
---

You are operating in Pre-Commit Check mode.

Your job is to perform a **complete pre-commit review** before a PR is raised.
This includes running the automated quality gate AND performing a set of static
checks that `sanity.bat` cannot catch (because it runs on Windows, not the CI
Linux runner).

Never modify source files in this mode.

---

## Step 1 — Run `sanity.bat`

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

If **any** step fails, show the exact error output and stop — do not proceed
to Step 2.

---

## Step 2 — Static checks (things `sanity.bat` cannot catch)

These checks must be performed manually because `sanity.bat` runs on Windows
where environment assumptions differ from the Ubuntu CI runner.

### 2a — `_mock_sf_cli` fixture coverage

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

### 2b — Pytest fixture type hints

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

### 2c — No bare `except:` or silent error swallowing

```powershell
Select-String -Path "scripts\*.py", "src\**\*.py" -Pattern "^\s*except\s*:" -Recurse
```

Report PASS (no matches) or FAIL (list occurrences).

### 2d — No `print()` in production code

```powershell
Select-String -Path "scripts\*.py", "src\**\*.py" -Pattern "^\s*print\(" -Recurse
```

Report PASS (no matches) or FAIL (list occurrences). Logging calls are fine.

### 2e — No hard-coded secrets or tokens

```powershell
Select-String -Path "scripts\*.py", "src\**\*.py" -Pattern "password\s*=\s*['""]|token\s*=\s*['""]|secret\s*=\s*['""]" -Recurse
```

Report PASS (no matches) or FAIL.

### 2f — `Changelog.md` updated

Check that `Changelog.md` contains an entry dated today for the current
branch's changes. Report PASS or FAIL with a reminder of what is missing.

### 2g — Documentation updated

For every script added or significantly changed, verify that a corresponding
guide exists under `docs/`. Report any scripts that have no matching guide.

### 2h — Secrets baseline path separators (Windows → POSIX)

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

### 2i — Test function return annotations

```powershell
Select-String -Path "tests\*.py" -Pattern "^def test_.*\)\s*:" -Recurse
```

**Rule:** Every `def test_...():` must have `-> None:`. FAIL if any match
lacks the annotation.

### 2j — Stale or incorrect `# noqa` comments

```powershell
ruff check --select RUF100 src tests scripts
```

RUF100 flags unused or incorrect `# noqa` directives. FAIL if any are found.

---

## Step 3 — Final summary

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

If **all** checks are PASS: output **"Quality gate passed — safe to raise PR."**

If **any** check is FAIL: list the failing items with remediation steps and
output **"Quality gate FAILED — do not raise PR until all items are resolved."**

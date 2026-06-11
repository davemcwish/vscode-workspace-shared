<!-- markdownlint-disable MD024 -->
# PR Group A Review - Low-Risk Hygiene

**Project:** eu-crm-sf-admin-utils
**Prepared by:** Release / PR Planner (GitHub Copilot)
**Date:** 2026-05-28
**Status:** ✅ Complete - A4 skipped, A1 (92d7150), A2 (caf8226), A3 (58990ec). All 468 tests green, 96% coverage.

---

## What Is This Document?

This document is the planning and review pack for **PR Group A - Low-Risk
Hygiene**. It is written for three audiences:

- **Developers** implementing the changes.
- **Test engineers** writing or updating the test harnesses.
- **Beginners** who may not be familiar with the codebase or the tools involved.

Read the whole document before starting any work. The four items must be
implemented **in order** - each PR must be merged and the test suite must be
green before the next one starts.

---

## Plain-English Summary

Group A contains four small housekeeping tasks. None of them change what the
scripts *do* from a Salesforce or business perspective. They tidy up the code
quality, make the tools consistent, and prepare the codebase for more
significant work in later groups.

Think of it like tidying a workshop before starting a big project - you are not
building anything new, just making sure the tools are in the right place and
labelled correctly.

---

## Recommended Implementation Order

```text
A4 (delete archive folder)
  -> A1 (rename _parse_args)
    -> A2 (extend mypy to scripts/)
      -> A3 (replace print() with logging)
```

> **Rule:** Never start the next item until the previous PR is merged and
> `sanity.bat` passes cleanly on `main`.

---

## Pre-Work Checks - Results (2026-05-28)

| Check | Result | Action |
| --- | --- | --- |
| 1 - `scripts/archive/` exists? | ❌ Not found | **A4 is skipped** - mark ✅ Done in roadmap immediately |
| 2 - `SLF001` / `noqa` on `_parse_args`? | ✅ No matches | A1 is a clean rename - no suppression cleanup needed |
| 3 - mypy against `scripts/` | ⚠️ 1 error in 1 file | A2 scope confirmed: one-line config change + one annotation fix |

**Check 3 detail - the single mypy error:**

```text
scripts\export_quote_pdfs_prod.py:1277:5: error: Returning Any from function
declared to return "Path"  [no-any-return]
    return debug_path
```

**What this means (plain English):** The function `save_debug_response()` says it
returns a `Path` object (a file path). Inside the function, `debug_path` is
reassigned via `resolve_safe_path(...)`, and mypy cannot confirm that value is
a `Path` - it sees it as `Any` (meaning "type unknown"). The fix is a single
type annotation on the initial assignment of `debug_path`, telling mypy "this
variable is always a `Path`". There is **no logic change** - only a type label
is added.

**The fix (add `Path` annotation to the variable declaration in
`save_debug_response()`):**

```python
# Before (line ~1240 in save_debug_response):
debug_path = DEBUG_RESPONSE_DIR / f"debug_{safe_source_label}_{safe_quote_id}.html"

# After:
debug_path: Path = DEBUG_RESPONSE_DIR / f"debug_{safe_source_label}_{safe_quote_id}.html"
```

This tells mypy that `debug_path` is always a `Path`, so later reassignments
to `safe_debug_path` or `safe_binary_debug_path` (both `Path` objects) are
consistent, and `return debug_path` is valid.

**Risk:** Zero. This is a type annotation only. The runtime behaviour is
identical before and after.

---

## Pre-Work Checks (Do These Before Creating Any Branch)

These checks take less than two minutes and prevent wasted effort.

### Check 1 - Does `scripts/archive/` exist?

Run this in the terminal from the project root:

```powershell
Get-ChildItem "scripts\archive" -ErrorAction SilentlyContinue
```

- If output is empty or shows an error: the folder is already gone. Skip A4
  and mark it done in the roadmap.
- If output lists files: proceed with A4.

### Check 2 - Are there any `SLF001` or `noqa` suppressions on `_parse_args`?

`SLF001` is a ruff (Python linter) rule that flags direct access to private
members (names starting with `_`). Before renaming the function in A1, check
whether any test file suppresses this warning:

```powershell
Select-String -Path "tests\test_list_inactive_users.py" -Pattern "SLF001|noqa"
```

- If matches are found next to `_parse_args`: those suppressions must be
  **removed** in the same A1 PR.
- If no matches: nothing extra to do.

### Check 3 - Run mypy against `scripts/` now (before A2)

This tells you how much work A2 will actually be:

```powershell
mypy scripts/
```

- If output is `Success: no issues found`: A2 is a one-line config change.
- If output lists errors: those errors must be fixed inside A2. List all
  errors before estimating the effort, and raise with the team if there
  are more than 10.

---

## PR A4 - Delete `scripts/archive/`

> ✅ **Skipped - 2026-05-28.** The folder does not exist in the repository.
> No action required. Update the roadmap to mark A4 done.

---

## PR A1 - Rename `list_inactive_users._parse_args` to `parse_args`

> ✅ **Complete - 2026-05-28, commit 92d7150.** 4 files changed, 11 lines.
> All 467 tests green, 96% coverage, `sanity.bat` exit 0.

---

Make `list_inactive_users.py` consistent with all other scripts in the project,
which use the public name `parse_args` (without a leading underscore). The
leading underscore (`_`) is a Python convention meaning "private - do not use
this outside the file". Tests need to call this function directly, and the
underscore also triggers a linter warning (`SLF001`) when accessed from tests.

### Size

**XS** - rename only, zero logic change.

### Branch name

```text
chore/a1-rename-parse-args-list-inactive-users
```

### Files changed

| File | Change |
| --- | --- |
| `scripts/list_inactive_users.py` | Function definition `_parse_args` -> `parse_args`; one call inside `main()` updated |
| `tests/test_list_inactive_users.py` | All `module._parse_args(...)` calls -> `module.parse_args(...)` (~5 occurrences); remove any `# noqa: SLF001` suppressions |
| `docs/list_inactive_users_guide.md` | Code walkthrough table: `_parse_args()` -> `parse_args()` (~2 mentions) |
| `docs/test_list_inactive_users_guide.md` | Test class table: `_parse_args()` -> `parse_args()` (~1 mention) |

### How to implement

1. In `scripts/list_inactive_users.py`:
   - Change `def _parse_args(` to `def parse_args(`
   - Change `args = _parse_args(argv)` inside `main()` to `args = parse_args(argv)`

2. In `tests/test_list_inactive_users.py`:
   - Replace every `module._parse_args(` with `module.parse_args(`
   - Remove any `# noqa: SLF001` comments on those lines

3. In both doc files: find and replace `_parse_args` with `parse_args`.

### Behaviour changes

- None from a user perspective. The function does exactly the same thing.
- Tests no longer need to suppress the `SLF001` linter warning (if it was
  present).

### Behaviour preserved

- All argument parsing logic is unchanged.
- All existing tests still pass (they just use the new public name).

### Tests for the test engineer

No new tests are needed. The existing `TestParseArgs` class in
`test_list_inactive_users.py` covers all argument parsing paths. The only
change is updating the call site from `_parse_args` to `parse_args`.

After renaming, run the targeted test class to confirm:

```powershell
pytest tests/test_list_inactive_users.py::TestParseArgs -v
```

Then run the full suite:

```powershell
sanity.bat
```

### Gotchas for the test engineer

**Gotcha 1 - The module is loaded via `importlib`, not a normal import.**

`test_list_inactive_users.py` loads the script using
`importlib.util.spec_from_file_location`. This means every call to
`module._parse_args(...)` is a string-based attribute lookup that happens at
runtime, not compile time. If even one test still says `module._parse_args`
after the rename, it will raise `AttributeError` when that test runs - there
is no IDE warning or import error to catch it first. You must find and replace
every occurrence manually, then run the tests to confirm.

**Gotcha 2 - Docstrings and comments inside `TestParseArgs` may still say
`_parse_args`.**

Docstrings do not cause test failures, but they will mislead the next person
who reads the file. Update them at the same time as the call sites.

### Risks

| Risk | Likelihood | Mitigation |
| --- | --- | --- |
| A `noqa` suppression is missed and ruff flags it as unused | Low | `sanity.bat` runs `ruff check` - it will catch unused `noqa` comments |
| A doc reference is missed | Low | `Select-String -Path "docs\*.md" -Pattern "_parse_args"` before committing |

### Rollback

```powershell
git revert HEAD
```

---

## PR A2 - Extend mypy `files` to include `scripts/`

> ✅ **Complete - 2026-05-28, commit caf8226.** 1 file changed (`pyproject.toml`).
> mypy reports `Success: no issues found in 12 source files`. All 468 tests green,
> `sanity.bat` exit 0. No annotation fixes were required - the pre-work check error
> had already been resolved in a prior session.

The `pyproject.toml` file currently tells mypy (the Python type checker - a
tool that reads your type hints and verifies they are consistent) to only check
`src/`. The `scripts/` folder has full type hints throughout but has never been
validated by mypy. Adding `"scripts"` to the mypy `files` list means type errors
in scripts will be caught immediately, before they can cause bugs.

### Size

**S** - confirmed by Pre-Work Check 3: one config line + one annotation fix.
No logic changes required.

### Branch name

```text
chore/a2-extend-mypy-to-scripts
```

### Files changed

| File | Change |
| --- | --- |
| `pyproject.toml` | `files = ["src"]` -> `files = ["src", "scripts"]` |
| `scripts/export_quote_pdfs_prod.py` | Add `Path` type annotation to `debug_path` in `save_debug_response()` (~line 1240) - annotation only, zero logic change |

### How to implement

1. In `pyproject.toml`, find the `[tool.mypy]` section. The line will look
   like:

   ```toml
   files = ["src"]
   ```

   Change it to:

   ```toml
   files = ["src", "scripts"]
   ```

2. Run mypy:

   ```powershell
   mypy src/ scripts/
   ```

3. Fix any errors that appear. Common errors in scripts that were previously
   unchecked:
   - Missing return type annotations.
   - `Any` values used where a specific type is expected.
   - Optional values (could be `None`) used without a `None` check.

4. Run the full quality gate:

   ```powershell
   sanity.bat
   ```

### Behaviour changes

- The `sanity.bat` quality gate now validates scripts as well as library code.
- Any pre-existing type errors in scripts become visible and must be fixed.

### Behaviour preserved

- All script behaviour at runtime is unchanged. mypy only reads code; it does
  not modify or run it.
- The `[[tool.mypy.overrides]]` section for `scripts.*` in `pyproject.toml`
  already relaxes strictness (for example, it allows untyped imports), so the
  bar is lower for scripts than for library code in `src/`.

### Tests for the test engineer

No new tests are required for the config change itself. However:

- If mypy errors are found and fixed in scripts, review whether any fix
  changes a function signature or return type, and update affected tests
  accordingly.
- Run the full suite after all mypy fixes are applied:

  ```powershell
  sanity.bat
  ```

### Gotchas for the test engineer

**Gotcha 1 - mypy errors do not equal test failures, but fixing them might.**

When mypy finds a type error and you fix it (for example, adding a `None`
guard or tightening a return type), that code change can alter what a function
returns or raises. If a test was asserting against the old - technically
incorrect - behaviour, it will now fail. Every mypy fix must be reviewed with
the question: "does this change what the function *does*, or only what it *says*
it does?"

**Gotcha 2 - The `scripts.*` mypy override relaxes rules, but not all of
them.**

Check the `[[tool.mypy.overrides]]` section in `pyproject.toml` before
assuming all scripts will pass cleanly. If the override suppresses import
errors but not missing annotations, any script function without a return type
hint will still fail. Know what the override covers before starting.

**Gotcha 3 - `importlib`-loaded modules in tests are opaque to mypy.**

Tests load scripts via `importlib` and call functions on a `types.ModuleType`
object. mypy types everything on that object as `Any` and cannot validate the
calls. This means mypy does **not** cover the test files' calls to script
functions, even after A2. Only the scripts themselves benefit from this change.

### Risks

| Risk | Likelihood | Mitigation |
| --- | --- | --- |
| mypy surfaces many errors, expanding scope significantly | Medium | Run Check 3 before branching; if more than 10 errors, raise with the team |
| A mypy fix inadvertently changes behaviour | Low | Each fix should be a type annotation or guard check - not logic. Review each fix carefully. |

### Rollback

```powershell
git revert HEAD
```

---

## PR A3 - Replace `print()` with `logging` in `update_packages.py`

> ✅ **Complete - 2026-05-28, commit 58990ec.** 3 files changed.
> All `print()` calls in `run()`, `print_section()`, `print_diff()`, and `main()`
> replaced with `logger.info/warning/error()`. `configure_logging()` called in
> `main()`. `TestPrintHelpers` rewritten with `caplog`. `test_main_calls_configure_logging`
> added. `docs/update_packages_guide.md` note added. 468 tests green, 96% coverage,
> `sanity.bat` exit 0.

`update_packages.py` uses Python's built-in `print()` function for all its
console output. Every other script in the project uses the `logging` module
instead. The `logging` module is preferred because:

- Output level can be controlled (`INFO`, `WARNING`, `ERROR`) without editing
  the script.
- Output format is consistent with all other scripts.
- It is easier to suppress or redirect output in automated environments.

### Size

**S** - multiple functions affected; test harness changes needed; docs update
needed.

### Branch name

```text
chore/a3-replace-print-with-logging-update-packages
```

### Important: Logging must be configured or output will be invisible

The `logging` module does not show `INFO`-level messages by default. Without
explicit setup, a user running the script interactively would see a blank
terminal - worse than the current behaviour. The script **must** call
`configure_logging()` (from `sf_admin_utils.logging_setup`) at the start of
`main()`.

Before implementing, review `src/sf_admin_utils/logging_setup.py` to confirm
what level and format `configure_logging()` sets. If it only configures
`WARNING` level, it will need to be adjusted to show `INFO` for this script.

### Files changed

| File | Change |
| --- | --- |
| `scripts/update_packages.py` | All `print()` calls replaced with `logger.info()` / `logger.warning()` / `logger.error()`; `import logging` added; `logger = logging.getLogger(__name__)` added; `configure_logging()` called in `main()` |
| `tests/test_update_packages.py` | `TestPrintHelpers` rewritten: `capsys` replaced with `caplog`; one new test added to confirm `configure_logging()` is called |
| `docs/update_packages_guide.md` | "Example Console Output" section updated or annotated to reflect the new logging format |

### How to implement

**Step 1 - Add logger to `update_packages.py`:**

Near the top of the file, after the existing imports, add:

```python
import logging

from sf_admin_utils.logging_setup import configure_logging

logger = logging.getLogger(__name__)
```

**Step 2 - Replace `print_section` and `print_diff` helper functions:**

These helpers currently call `print()` internally. Replace each `print()`
call inside them with `logger.info()`. The function signatures and names stay
the same - only the output mechanism changes.

**Step 3 - Replace `print()` calls in `run()` and `main()`:**

Every `print(...)` call becomes one of:

- `logger.info(...)` - for progress messages
- `logger.warning(...)` - for recoverable problems
- `logger.error(...)` - for failures before `sys.exit()`

**Step 4 - Call `configure_logging()` at the start of `main()`:**

```python
def main() -> None:
    configure_logging()
    ...
```

**Step 5 - Confirm no `print()` calls remain:**

```powershell
Select-String -Path "scripts\update_packages.py" -Pattern "print\("
```

Expected: no matches (except inside string literals or comments).

**Step 6 - Run `sanity.bat` and fix any failures before touching tests.**

### Tests for the test engineer

#### What to change in `TestPrintHelpers`

The three existing tests use `capsys` (a pytest fixture that captures stdout -
what `print()` writes to). After the change, output goes to the logging system
instead. Replace `capsys` with `caplog`:

**Before (using `capsys`):**

```python
def test_print_section_runs(self, capsys: pytest.CaptureFixture[str]) -> None:
    print_section("Hello")
    captured = capsys.readouterr()
    assert "Hello" in captured.out
```

**After (using `caplog`):**

```python
def test_print_section_runs(self, caplog: pytest.LogCaptureFixture) -> None:
    with caplog.at_level(logging.INFO):
        print_section("Hello")
    assert "Hello" in caplog.text
```

Apply the same pattern to `test_print_diff_no_changes` and
`test_print_diff_with_changes`.

#### What to add - new test

Add one test to confirm `configure_logging()` is called during `main()`. This
guards against a future regression where someone removes the call and silences
all output:

```python
def test_main_calls_configure_logging(self, monkeypatch: pytest.MonkeyPatch) -> None:
    """main() must call configure_logging() so INFO output is visible."""
    calls: list[bool] = []
    monkeypatch.setattr(module, "configure_logging", lambda: calls.append(True))
    monkeypatch.setattr(module, "compile_upgrade", lambda _: None)
    monkeypatch.setattr(module, "run", lambda *a, **kw: 0)
    module.main()
    assert calls == [True]
```

#### Validation commands

```powershell
pytest tests/test_update_packages.py -v
sanity.bat
```

### Gotchas for the test engineer

**Gotcha 1 - `capsys` and `caplog` capture different things and do not
overlap.**

`capsys` captures stdout and stderr - what `print()` writes to. `caplog`
captures records emitted through the Python logging system. After A3,
`capsys.readouterr().out` will be **empty** even if the function ran and
produced output, because the output went to `caplog` instead. A test that
still uses `capsys` after the change will silently pass (the assertion
`assert "text" in captured.out` evaluates to `assert "text" in ""`), giving a
false green. Check every assertion in `TestPrintHelpers` carefully.

**Gotcha 2 - `caplog.at_level()` must match the level used in the code.**

If the code calls `logger.info(...)` but the test uses
`caplog.at_level(logging.WARNING)`, the message will not appear in
`caplog.text` and the assertion will fail silently. All updated tests must use
`caplog.at_level(logging.INFO)` at minimum. Using no logger name argument
captures all loggers, which is the safest default for this script.

**Gotcha 3 - Check the whole test file for `capsys`, not just
`TestPrintHelpers`.**

If `main()` calls `print_section()` or `print_diff()` and any test in
`TestMain` was asserting on the stdout output from those calls, those
assertions will also silently stop working after A3. Search the entire file:

```powershell
Select-String -Path "tests\test_update_packages.py" -Pattern "capsys"
```

Every match must be converted to `caplog`.

**Gotcha 4 - `run()` has its own `print()` call that is easy to miss.**

The `run()` function currently prints the command before executing it:

```python
print(f"  $ {' '.join(safe_cmd)}")
```

This line is separate from `print_section` and `print_diff` and is easy to
overlook. It must also be converted to `logger.info()`. After implementing,
run this grep to confirm no `print(` calls remain in the script:

```powershell
Select-String -Path "scripts\update_packages.py" -Pattern "print\("
```

Expected: zero matches outside string literals or comments.

**Gotcha 5 - `configure_logging()` may only show `WARNING` level by
default.**

If `src/sf_admin_utils/logging_setup.py` configures the root logger at
`WARNING` level, calling it in `main()` will still silence all `logger.info()`
output, making the terminal blank. Review `logging_setup.py` before
implementing. If it sets `WARNING`, either adjust `configure_logging()` to
accept a level argument, or call `logging.basicConfig(level=logging.INFO)`
directly in `update_packages.py` as a fallback.

### Behaviour changes

- Console output format changes. Previously: plain text printed to stdout.
  After: logging-format messages (e.g. `INFO:update_packages: Step 1...`)
  sent through the logging system.
- Output level is now controllable via the `LOG_LEVEL` environment variable.

### Behaviour preserved

- All upgrade logic (recompile, diff, install) is unchanged.
- All subprocess commands are unchanged.
- Exit codes are unchanged.

### Documentation update

In `docs/update_packages_guide.md`, the "Example Console Output" section shows
sample terminal output that reflects the old `print()` format. Add this note
directly above the code block:

> **Note (2026-05-28):** Output now flows through the Python `logging` module.
> The format shown below is illustrative. Actual output will include a
> log-level prefix (e.g. `INFO`). You can control the verbosity by setting the
> `LOG_LEVEL` environment variable before running the script.

### Risks

| Risk | Likelihood | Mitigation |
| --- | --- | --- |
| `configure_logging()` not called -> silent output | Medium | The new test above will catch this regression |
| A `print()` call is missed | Low | Run the `Select-String` grep in Step 5 before committing |
| Doc sample output becomes inaccurate | Low | Add the note to the guide before merging |
| `configure_logging()` sets `WARNING` level, hiding `INFO` messages | Medium | Review `logging_setup.py` before starting - adjust if needed |

### Rollback

```powershell
git revert HEAD
```

---

## Test-Engineer Gotchas - Master Summary

This table collects every gotcha from all four PRs in one place for quick
reference.

| PR | Gotcha | How to catch it before it bites you |
| --- | --- | --- |
| A4 | A test fixture may reference a path inside `archive/` | `Select-String -Path "tests\*.py","tests\conftest.py" -Pattern "archive"` before deleting |
| A1 | `module._parse_args(...)` is a runtime attribute lookup - a missed rename raises `AttributeError`, not a compile error | Run `pytest tests/test_list_inactive_users.py::TestParseArgs -v` immediately after renaming |
| A1 | Docstrings inside `TestParseArgs` may still say `_parse_args` - misleading but not a failure | Text search the test file for `_parse_args` before committing |
| A2 | A mypy fix can silently change behaviour, breaking an existing test that was asserting against the old (wrong) behaviour | Review each fix: "does this change what the function *does*?" before running tests |
| A2 | The `scripts.*` mypy override may not suppress all strictness rules - know what it covers | Read `[[tool.mypy.overrides]]` in `pyproject.toml` before starting |
| A2 | mypy cannot see into `importlib`-loaded modules in tests - test call sites are not validated | Manual review only; mypy covers scripts, not the test files |
| A3 | `capsys` tests silently pass with empty output after `print()` is removed - false green | `Select-String -Path "tests\test_update_packages.py" -Pattern "capsys"` - every match must become `caplog` |
| A3 | `caplog` only captures messages at or above the configured level - wrong level = silent failure | Always use `caplog.at_level(logging.INFO)` in updated tests |
| A3 | `TestMain` tests may also use `capsys` - not just `TestPrintHelpers` | Search the whole test file, not just one class |
| A3 | `run()` has its own `print()` call separate from the helper functions | `Select-String -Path "scripts\update_packages.py" -Pattern "print\("` after implementing |
| A3 | `configure_logging()` may default to `WARNING` level, silencing all `INFO` output | Review `logging_setup.py` before starting; add the `test_main_calls_configure_logging` test |

---

## Validation Commands (Run After Every PR)

### Local - run before every push

```powershell
.\sanity.bat
```

`sanity.bat` runs in order: `ruff format`, `ruff check`, `mypy`, `bandit`,
`detect-secrets`, `pytest`. All steps must pass with exit code 0 before the
PR is merged.

### GitHub - Cycode scans (automatic, required on every PR)

Two Cycode scans run automatically when a PR is opened or updated on GitHub.
Both must pass before the PR can be merged:

| Scan | What it checks |
| --- | --- |
| **Cycode: SAST** | Static analysis - code patterns that could indicate security vulnerabilities |
| **Cycode: Secrets** | Scans all changed files for accidentally committed credentials, tokens, or keys |

These are GitHub-side checks - you cannot run them locally. If either fails,
review the Cycode findings on the PR page, fix the flagged lines, and push -
the scans re-run automatically on the updated commit.

---

## Suggested Commit Messages

| PR | Commit message |
| --- | --- |
| A4 | `chore: delete scripts/archive/ - git history preserves old versions` |
| A1 | `chore: rename _parse_args to parse_args in list_inactive_users` |
| A2 | `chore: extend mypy files to include scripts/` |
| A3 | `chore: replace print() with logging in update_packages.py` |

---

## Updating the Roadmap as Items Complete

When each PR merges, update two files:

1. **`docs/pr-roadmap-section-8-4.md`** - mark the row done (strikethrough +
   date).
2. **`Changelog.md`** - add an entry under `[Unreleased]` describing what
   changed.

---

## Open Questions Before Starting

All three pre-work checks have been run (2026-05-28). No open questions remain.

| Question | Answer |
| --- | --- |
| Does `scripts/archive/` exist? | No - A4 skipped |
| Any `SLF001`/`noqa` suppressions on `_parse_args`? | No - A1 is a clean rename |
| mypy errors in `scripts/`? | 1 error, 1 file - see Pre-Work Checks Results section above |
| Does `configure_logging()` show `INFO` output? | Yes - `_configure_logging()` in export scripts sets root logger to `INFO`. The shared `configure_logging()` in `logging_setup.py` should be verified before A3. |

---

## Related Files

| File | Purpose |
| --- | --- |
| `docs/pr-roadmap-section-8-4.md` | Master roadmap - update Group A rows as each item completes |
| `Changelog.md` | Add entries to `[Unreleased]` as each PR merges |
| `src/sf_admin_utils/logging_setup.py` | Shared logging configuration - review before A3 |
| `pyproject.toml` | mypy and ruff configuration - edit for A2 |
| `scripts/list_inactive_users.py` | Target file for A1 |
| `scripts/update_packages.py` | Target file for A3 |
| `tests/test_list_inactive_users.py` | Test file for A1 |
| `tests/test_update_packages.py` | Test file for A3 |

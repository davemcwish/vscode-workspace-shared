@echo off
REM ============================================================================
REM  sanity.bat - Run all code quality checks
REM  Usage:  sanity.bat
REM
REM  THIS FILE IS A SHARED SCAFFOLD (owned by _copilot-shared\scaffold\).
REM  It is synced to every project on each sync run - do NOT edit per-project.
REM  To change this file, edit _copilot-shared\scaffold\sanity.bat and re-sync.
REM
REM  ADAPTIVE BEHAVIOUR:
REM    This script detects which directories and config files exist in the
REM    current project and skips checks that have no targets. This allows one
REM    template to work across projects at all stages of development.
REM
REM  You must keep sanity_v.bat in sync with this file (same steps, verbose flags added).
REM ============================================================================
REM
REM  GATE STEPS (must match .github\workflows\ci.yml exactly):
REM    1. Ruff format    - code formatting (check-only, no changes)
REM    2. Ruff lint      - linting + import sorting + security rules
REM    3. Mypy           - static type checking
REM    4. Bandit         - security linter (Python-specific)
REM    5. detect-secrets - scans for accidentally committed secrets
REM    6. Pytest         - test suite with coverage (parallel)
REM    7. markdownlint   - checks Markdown files for style issues
REM
REM  COVERAGE NOTE:
REM    --cov flags are NOT passed here. They are defined once in
REM    pyproject.toml [tool.pytest.ini_options] addopts and inherited
REM    automatically. Only -n auto is added for parallel execution.
REM    Never duplicate coverage flags here or in ci.yml.
REM    Change the coverage threshold in pyproject.toml only.
REM ============================================================================

setlocal enabledelayedexpansion
set FAIL_COUNT=0

REM Always run from the directory containing this script. This prevents a
REM workspace-level invocation such as ".\Project\sanity.bat" from collecting
REM sibling project files or using the wrong project root.
pushd "%~dp0" || (
    echo  FAILED: Could not change to script directory "%~dp0".
    exit /b 1
)

REM Prefer the Python Launcher on Windows so the script works even when
REM `python` is not on PATH. Adjust -3.12 if the repo upgrades Python.
set PY_CMD=py -3.12

REM -- Clean stale .coverage files that cause pytest-cov/xdist errors --------
del /q .coverage* 2>nul

REM -- Detect Python source directories that contain *.py recursively --------
set PY_TARGETS=

for %%D in (src tests scripts frontend) do (
    if exist "%%D\" (
        dir /b /s "%%D\*.py" >nul 2>nul
        if not errorlevel 1 (
            set "PY_TARGETS=!PY_TARGETS! %%D"
        )
    )
)

REM Support the workspace root repo, where shared contract tests live under
REM _copilot-shared\tests rather than a top-level tests directory.
if exist "_copilot-shared\tests\" (
    dir /b /s "_copilot-shared\tests\*.py" >nul 2>nul
    if not errorlevel 1 (
        set "PY_TARGETS=!PY_TARGETS! _copilot-shared\tests"
    )
)

REM Strip leading space
if defined PY_TARGETS (set "PY_TARGETS=!PY_TARGETS:~1!")

REM -- Detect pytest target directories explicitly ----------------------------
REM Pytest must receive explicit test paths so sibling workspaces are never
REM collected when this script is launched from a parent folder.
set TEST_TARGETS=

if exist "tests\" (
    dir /b /s "tests\*.py" >nul 2>nul
    if not errorlevel 1 (
        set "TEST_TARGETS=!TEST_TARGETS! tests"
    )
)

if exist "_copilot-shared\tests\" (
    dir /b /s "_copilot-shared\tests\*.py" >nul 2>nul
    if not errorlevel 1 (
        set "TEST_TARGETS=!TEST_TARGETS! _copilot-shared\tests"
    )
)

REM Strip leading space
if defined TEST_TARGETS (set "TEST_TARGETS=!TEST_TARGETS:~1!")

REM -- Detect which config files exist ----------------------------------------
set HAS_PYPROJECT=0
set HAS_SECRETS_BASELINE=0
if exist pyproject.toml (set HAS_PYPROJECT=1)
if exist .secrets.baseline (set HAS_SECRETS_BASELINE=1)

echo.
echo ============================================================================
echo  [1/7] Ruff format check
echo ============================================================================
if not defined PY_TARGETS (
    echo  SKIPPED: No Python source directories found ^(src, tests, scripts, frontend, _copilot-shared\tests^).
) else (
    %PY_CMD% -m ruff format --check %PY_TARGETS%
    if errorlevel 1 set /a FAIL_COUNT+=1
)

echo.
echo ============================================================================
echo  [2/7] Ruff lint
echo ============================================================================
if not defined PY_TARGETS (
    echo  SKIPPED: No Python source directories found.
) else (
    %PY_CMD% -m ruff check %PY_TARGETS%
    if errorlevel 1 set /a FAIL_COUNT+=1
    %PY_CMD% -m ruff check %PY_TARGETS% --statistics
)

echo.
echo ============================================================================
echo  [3/7] Mypy (static type checking)
echo ============================================================================
if %HAS_PYPROJECT% EQU 1 (
    REM pyproject.toml exists - mypy reads [tool.mypy] config from it.
    %PY_CMD% -m mypy
    if errorlevel 1 set /a FAIL_COUNT+=1
) else if defined PY_TARGETS (
    REM No pyproject.toml - pass targets directly with relaxed settings.
    %PY_CMD% -m mypy %PY_TARGETS% --ignore-missing-imports
    if errorlevel 1 set /a FAIL_COUNT+=1
) else (
    echo  SKIPPED: No pyproject.toml and no Python source directories.
)

echo.
echo ============================================================================
echo  [4/7] Bandit (security linter)
echo ============================================================================
if %HAS_PYPROJECT% EQU 0 (
    echo  SKIPPED: No pyproject.toml found ^(bandit requires -c pyproject.toml^).
) else (
    REM Build bandit target list: scan src, scripts, and frontend; exclude tests.
    set BANDIT_TARGETS=
    if exist src (set "BANDIT_TARGETS=!BANDIT_TARGETS! src")
    if exist scripts (set "BANDIT_TARGETS=!BANDIT_TARGETS! scripts")
    if exist frontend (set "BANDIT_TARGETS=!BANDIT_TARGETS! frontend")
    if defined BANDIT_TARGETS (
        set "BANDIT_TARGETS=!BANDIT_TARGETS:~1!"
        %PY_CMD% -m bandit -c pyproject.toml -r !BANDIT_TARGETS! --exclude tests --quiet
        if errorlevel 1 set /a FAIL_COUNT+=1
    ) else (
        echo  SKIPPED: pyproject.toml found but no src, scripts, or frontend directories to scan.
    )
)

echo.
echo ============================================================================
echo  [5/7] detect-secrets (secret scanning)
echo ============================================================================
if %HAS_SECRETS_BASELINE% EQU 0 (
    echo  SKIPPED: No .secrets.baseline file found.
) else (
    %PY_CMD% -m detect_secrets scan --baseline .secrets.baseline
    if errorlevel 1 set /a FAIL_COUNT+=1
)

echo.
echo ============================================================================
echo  [6/7] Pytest (with coverage, parallel)
echo ============================================================================
if not defined TEST_TARGETS (
    echo  SKIPPED: No test directories found ^(tests, _copilot-shared\tests^).
) else if defined SANITY_NO_COV (
    echo  ^(coverage disabled via SANITY_NO_COV^)
    %PY_CMD% -m pytest %TEST_TARGETS% -n auto --no-cov --override-ini="addopts="
    if errorlevel 1 set /a FAIL_COUNT+=1
) else (
    REM Coverage flags (--cov, --cov-report, --cov-fail-under, --strict-markers)
    REM come from addopts in pyproject.toml automatically (if present).
    REM Only -n auto is added here for parallel execution.
    REM Pass explicit test paths so sibling projects are never collected.
    %PY_CMD% -m pytest %TEST_TARGETS% -n auto
    if errorlevel 1 set /a FAIL_COUNT+=1
)

echo.
echo ============================================================================
echo  [7/7] markdownlint (autofix then verify)
echo ============================================================================
where npx >nul 2>&1
if errorlevel 1 (
    echo  SKIPPED: npx not found in PATH. Install Node.js to enable markdownlint.
) else (
    if exist "_copilot-shared\" (
        call npx markdownlint-cli2 --fix "docs/**/*.md" "_copilot-shared/**/*.md" "*.md"
        call npx markdownlint-cli2 "docs/**/*.md" "_copilot-shared/**/*.md" "*.md"
    ) else (
        call npx markdownlint-cli2 --fix "docs/**/*.md" "*.md"
        call npx markdownlint-cli2 "docs/**/*.md" "*.md"
    )
    if errorlevel 1 set /a FAIL_COUNT+=1
)

echo.
echo ============================================================================
if %FAIL_COUNT% EQU 0 (
    echo  SUCCESS: All checks passed.
) else (
    echo  FAILED: %FAIL_COUNT% check^(s^) failed. See output above.
)
echo ============================================================================

set EXIT_CODE=%FAIL_COUNT%
popd
exit /b %EXIT_CODE%

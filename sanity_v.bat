@echo off
REM ============================================================================
REM  sanity_v.bat — Run all code quality checks VERBOSE (workspace root repo)
REM  Usage:  sanity_v.bat
REM
REM  Same steps as sanity.bat but with verbose/detailed output enabled on
REM  every tool. Use this when diagnosing failures; use sanity.bat for the
REM  quick pass/fail gate.
REM
REM  CUSTOMISED for the workspace root git repo which tracks:
REM    - _copilot-shared\  (agents, chatmodes, instructions, skills, workflows)
REM    - _copilot-shared\tests\  (Python contract tests for the above)
REM    - Root-level .md and .ps1 files
REM
REM  This repo has NO pyproject.toml, src\, or scripts\ directories.
REM  Python checks target _copilot-shared\tests only.
REM ============================================================================
REM
REM  GATE STEPS:
REM    1. Ruff format    — code formatting (check-only, no changes)
REM    2. Ruff lint      — linting + import sorting + security rules
REM    3. Mypy           — static type checking
REM    4. Bandit         — security linter (Python-specific)
REM    5. detect-secrets — scans for accidentally committed secrets
REM    6. Pytest         — test suite
REM    7. markdownlint   — checks Markdown files for style issues
REM ============================================================================

setlocal enabledelayedexpansion
set FAIL_COUNT=0

REM Prefer the Python Launcher on Windows so the script works even when
REM `python` is not on PATH. Adjust -3.12 if the repo upgrades Python.
set PY_CMD=py -3.12

REM The only Python source in this repo lives here:
set PY_TARGETS=_copilot-shared\tests

echo.
echo ============================================================================
echo  [1/7] Ruff format check (verbose — shows diff for each file)
echo ============================================================================
%PY_CMD% -m ruff format --check --diff %PY_TARGETS%
if errorlevel 1 set /a FAIL_COUNT+=1

echo.
echo ============================================================================
echo  [2/7] Ruff lint (verbose — shows statistics and fix suggestions)
echo ============================================================================
%PY_CMD% -m ruff check --output-format=full --statistics %PY_TARGETS%
if errorlevel 1 set /a FAIL_COUNT+=1

echo.
echo ============================================================================
echo  [3/7] Mypy (static type checking — verbose)
echo ============================================================================
REM No pyproject.toml in this repo — pass target directory directly.
%PY_CMD% -m mypy %PY_TARGETS% --ignore-missing-imports --pretty --show-error-context
if errorlevel 1 set /a FAIL_COUNT+=1

echo.
echo ============================================================================
echo  [4/7] Bandit (security linter — verbose)
echo ============================================================================
REM No pyproject.toml — run bandit without -c flag, target tests dir.
REM --skip B101: assert is standard pytest practice and is the only Python
REM code in this repo. No production code exists to scan.
%PY_CMD% -m bandit -r %PY_TARGETS% --skip B101 -ll
if errorlevel 1 set /a FAIL_COUNT+=1

echo.
echo ============================================================================
echo  [5/7] detect-secrets (secret scanning — verbose)
echo ============================================================================
REM Scans tracked files against the baseline. Create baseline first with:
REM   py -3.12 -m detect_secrets scan > .secrets.baseline
if exist .secrets.baseline (
    %PY_CMD% -m detect_secrets scan --baseline .secrets.baseline --list-all-plugins
    if errorlevel 1 set /a FAIL_COUNT+=1
) else (
    echo  SKIPPED: .secrets.baseline not found. Create with:
    echo    %PY_CMD% -m detect_secrets scan ^> .secrets.baseline
    set /a FAIL_COUNT+=1
)

echo.
echo ============================================================================
echo  [6/7] Pytest (verbose — shows each test name and duration)
echo ============================================================================
%PY_CMD% -m pytest %PY_TARGETS% -v --tb=short --durations=10
if errorlevel 1 set /a FAIL_COUNT+=1

echo.
echo ============================================================================
echo  [7/7] markdownlint (autofix then verify)
echo ============================================================================
REM Target the tracked markdown files in _copilot-shared and root.
where npx >nul 2>&1
if errorlevel 1 (
    echo  SKIPPED: npx not found. Install Node.js to enable markdownlint.
) else (
    call npx markdownlint-cli2 --fix "_copilot-shared/**/*.md" "*.md"
    call npx markdownlint-cli2 "_copilot-shared/**/*.md" "*.md"
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
exit /b %FAIL_COUNT%

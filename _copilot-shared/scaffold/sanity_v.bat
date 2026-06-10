@echo off
REM ============================================================================
REM  sanity_v.bat — verbose quality gate mirror of sanity.bat
REM  Usage:  sanity_v.bat
REM
REM  THIS FILE IS A SCAFFOLD TEMPLATE.
REM  It was copied from _copilot-shared\scaffold\sanity_v.bat when this project
REM  was created. After copying, this project owns this file.
REM
REM  MAINTENANCE RULE:
REM    Whenever sanity.bat changes, apply the same change here.
REM    The only permitted differences between sanity.bat and sanity_v.bat are
REM    the verbose flags listed in the VERBOSE ADDITIONS section below.
REM
REM  Review the CUSTOMISE comments below before your first run.
REM ============================================================================
REM
REM  GATE STEPS (identical to sanity.bat and ci.yml):
REM    1. Ruff format    — code formatting (check-only, no changes)
REM    2. Ruff lint      — linting + import sorting + security rules
REM    3. Mypy           — static type checking
REM    4. Bandit         — security linter (Python-specific)
REM    5. detect-secrets — scans for accidentally committed secrets
REM    6. Pytest         — test suite with coverage (parallel)
REM    7. markdownlint   — checks Markdown files for style issues
REM
REM  COVERAGE NOTE:
REM    --cov flags are NOT passed here. They are defined once in
REM    pyproject.toml [tool.pytest.ini_options] addopts and inherited
REM    automatically. Never duplicate them in this file or in ci.yml.
REM
REM  VERBOSE ADDITIONS (vs sanity.bat):
REM    - ruff --verbose  : lists every file scanned
REM    - mypy --verbose  : logs each module being type-checked
REM                        (--pretty is already set in pyproject.toml)
REM    - bandit -v       : shows every file scanned, not just findings
REM    - pytest -v       : one PASSED/FAILED line per test name
REM ============================================================================

setlocal enabledelayedexpansion
set FAIL_COUNT=0

REM Prefer the Python Launcher on Windows so the script works even when
REM `python` is not on PATH. Adjust -3.12 if the repo upgrades Python.
set PY_CMD=py -3.12

echo.
echo ============================================================================
echo  [1/7] Ruff format check (verbose)
echo ============================================================================
REM CUSTOMISE: adjust 'src tests scripts' to match your project's directory layout.
%PY_CMD% -m ruff format --check src tests scripts --verbose
if errorlevel 1 set /a FAIL_COUNT+=1

echo.
echo ============================================================================
echo  [2/7] Ruff lint (verbose + statistics)
echo ============================================================================
REM CUSTOMISE: adjust directory list to match your project layout (same as step 1).
%PY_CMD% -m ruff check src tests scripts --verbose
if errorlevel 1 set /a FAIL_COUNT+=1
%PY_CMD% -m ruff check src tests scripts --statistics

echo.
echo ============================================================================
echo  [3/7] Mypy (verbose)
echo ============================================================================
%PY_CMD% -m mypy --verbose
if errorlevel 1 set /a FAIL_COUNT+=1

echo.
echo ============================================================================
echo  [4/7] Bandit (verbose — shows every file scanned)
echo ============================================================================
REM CUSTOMISE: -r src scripts scans your source. --exclude tests is standard.
REM Add more exclusions separated by commas (e.g. --exclude tests,scripts/archive).
%PY_CMD% -m bandit -c pyproject.toml -r src scripts --exclude tests -v
if errorlevel 1 set /a FAIL_COUNT+=1

echo.
echo ============================================================================
echo  [5/7] detect-secrets
echo ============================================================================
%PY_CMD% -m detect_secrets scan --baseline .secrets.baseline
if errorlevel 1 set /a FAIL_COUNT+=1

echo.
echo ============================================================================
echo  [6/7] Pytest (verbose + parallel, coverage flags from addopts)
echo ============================================================================
REM Coverage flags come from [tool.pytest.ini_options] addopts in pyproject.toml.
REM -v gives one PASSED/FAILED line per test; --tb=short keeps tracebacks brief.
%PY_CMD% -m pytest -n auto -v --tb=short
if errorlevel 1 set /a FAIL_COUNT+=1

echo.
echo ============================================================================
echo  [7/7] markdownlint (autofix then verify)
echo ============================================================================
where npx >nul 2>&1
if errorlevel 1 (
    echo  SKIPPED: npx not found in PATH. Install Node.js to enable markdownlint.
) else (
    call npx markdownlint-cli2 --fix "docs/**/*.md" "*.md"
    call npx markdownlint-cli2 "docs/**/*.md" "*.md"
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

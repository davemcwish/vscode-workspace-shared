@echo off
REM ============================================================================
REM  sanity.bat — Run all code quality checks
REM  Usage:  sanity.bat
REM
REM  THIS FILE IS A SCAFFOLD TEMPLATE.
REM  It was copied from _copilot-shared\scaffold\sanity.bat when this project
REM  was created. After copying, this project owns this file.
REM
REM  Review the CUSTOMISE comments below before your first run.
REM  Keep sanity_v.bat in sync with this file (same steps, verbose flags added).
REM ============================================================================
REM
REM  GATE STEPS (must match .github\workflows\ci.yml exactly):
REM    1. Ruff format    — code formatting (check-only, no changes)
REM    2. Ruff lint      — linting + import sorting + security rules
REM    3. Mypy           — static type checking
REM    4. Bandit         — security linter (Python-specific)
REM    5. detect-secrets — scans for accidentally committed secrets
REM    6. Pytest         — test suite with coverage (parallel)
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

REM Prefer the Python Launcher on Windows so the script works even when
REM `python` is not on PATH. Adjust -3.12 if the repo upgrades Python.
set PY_CMD=py -3.12

echo.
echo ============================================================================
echo  [1/6] Ruff format check
echo ============================================================================
REM CUSTOMISE: adjust 'src tests scripts' to match your project's directory layout.
%PY_CMD% -m ruff format --check src tests scripts
if errorlevel 1 set /a FAIL_COUNT+=1

echo.
echo ============================================================================
echo  [2/6] Ruff lint
echo ============================================================================
REM CUSTOMISE: adjust directory list to match your project layout (same as step 1).
%PY_CMD% -m ruff check src tests scripts
if errorlevel 1 set /a FAIL_COUNT+=1
%PY_CMD% -m ruff check src tests scripts --statistics

echo.
echo ============================================================================
echo  [3/6] Mypy (static type checking)
echo ============================================================================
%PY_CMD% -m mypy
if errorlevel 1 set /a FAIL_COUNT+=1

echo.
echo ============================================================================
echo  [4/6] Bandit (security linter)
echo ============================================================================
REM CUSTOMISE: -r src scripts scans your source. --exclude tests is standard.
REM Add more exclusions separated by commas (e.g. --exclude tests,scripts/archive).
%PY_CMD% -m bandit -c pyproject.toml -r src scripts --exclude tests --quiet
if errorlevel 1 set /a FAIL_COUNT+=1

echo.
echo ============================================================================
echo  [5/6] detect-secrets (secret scanning)
echo ============================================================================
%PY_CMD% -m detect_secrets scan --baseline .secrets.baseline
if errorlevel 1 set /a FAIL_COUNT+=1

echo.
echo ============================================================================
echo  [6/6] Pytest (with coverage, parallel)
echo ============================================================================
REM Coverage flags (--cov, --cov-report, --cov-fail-under, --strict-markers)
REM come from addopts in pyproject.toml automatically.
REM Only -n auto is added here for parallel execution.
REM Never duplicate addopts flags here — change the threshold in pyproject.toml only.
%PY_CMD% -m pytest -n auto
if errorlevel 1 set /a FAIL_COUNT+=1

echo.
echo ============================================================================
if %FAIL_COUNT% EQU 0 (
    echo  SUCCESS: All checks passed.
) else (
    echo  FAILED: %FAIL_COUNT% check^(s^) failed. See output above.
)
echo ============================================================================
exit /b %FAIL_COUNT%

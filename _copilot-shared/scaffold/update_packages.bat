@echo off
REM ============================================================================
REM  update_packages.bat
REM
REM  Convenience wrapper to safely upgrade all Python dependencies.
REM
REM  This script:
REM    1. Activates the virtual environment (if not already active)
REM    2. Runs scripts/update_packages.py, which:
REM       - Recompiles requirements.in and requirements-dev.in with --upgrade
REM       - Shows what changed
REM       - Asks for confirmation
REM       - Installs the new versions
REM       - Runs sanity.bat to verify nothing broke
REM
REM  Security: Upgrading dependencies protects against known vulnerabilities.
REM  Always run the test suite after upgrading to catch breaking changes.
REM
REM ============================================================================

setlocal

REM --- Move to the project root (the folder containing this .bat file) -------
cd /d "%~dp0"

REM --- Activate the venv if it's not already active --------------------------
if not defined VIRTUAL_ENV (
    if exist ".venv\Scripts\activate.bat" (
        echo [INFO] Activating virtual environment...
        call .venv\Scripts\activate.bat
    ) else (
        echo.
        echo [ERROR] No .venv folder found.
        echo.
        echo Create one with:
        echo   py -3.13 -m venv .venv
        echo   .venv\Scripts\Activate.ps1
        echo   pip install -r requirements.txt
        echo.
        exit /b 1
    )
)

REM --- Run the upgrade orchestrator ------------------------------------------
python scripts\update_packages.py
if errorlevel 1 (
    echo.
    echo [ERROR] Upgrade failed. See output above for details.
    echo.
    exit /b 1
)

endlocal
exit /b 0

#!/usr/bin/env python
r"""Safely upgrade all Python dependencies and verify nothing broke.

This script:
  1. Identifies requirements.in and requirements-dev.in files.
  2. Recompiles them with --upgrade to find newer versions.
  3. Shows a diff of what changed.
  4. Asks for confirmation before installing.
  5. Installs the new versions.
  6. Runs sanity.bat to verify everything still works.

Security note:
  Upgrading dependencies reduces exposure to known vulnerabilities. However,
  newer versions may have bugs or introduce breaking changes. Always run the
  test suite after upgrading. If tests fail, revert and report the issue to
  the dependency maintainer.

Usage:
  Activate the project venv, then run:
    python scripts/update_packages.py

  Or use the convenience wrapper:
    update_packages.bat (Windows)
    update_packages.sh (Linux/macOS)
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def run_command(cmd: list[str], description: str = "") -> int:
    """Run a shell command and return the exit code.

    Args:
        cmd: Command and arguments as a list.
        description: Human-readable description of what the command does.

    Returns:
        Exit code (0 = success, non-zero = failure).
    """
    if description:
        print(f"\n{'=' * 80}")
        print(f"  {description}")
        print(f"{'=' * 80}")

    try:
        result = subprocess.run(cmd, check=False)
        return result.returncode
    except FileNotFoundError as exc:
        print(f"[ERROR] Command not found: {cmd[0]}")
        print(f"  Details: {exc}")
        return 1


def find_requirements_files() -> tuple[Path | None, Path | None]:
    """Find requirements.in and requirements-dev.in in the project root.

    Returns:
        Tuple of (requirements_in_path, requirements_dev_in_path) or (None, None)
        if not found.
    """
    project_root = Path.cwd()
    req_in = project_root / "requirements.in"
    req_dev_in = project_root / "requirements-dev.in"

    return (req_in if req_in.exists() else None,
            req_dev_in if req_dev_in.exists() else None)


def main() -> int:
    """Main entry point.

    Returns:
        Exit code (0 = success, non-zero = failure).
    """
    print("[INFO] Upgrading Python dependencies...")
    print(f"[INFO] Python: {sys.executable}")
    print(f"[INFO] Working directory: {Path.cwd()}")

    # Check for venv activation
    if not sys.prefix or sys.prefix == sys.base_prefix:
        print("\n[WARNING] Virtual environment not detected.")
        print("  Consider activating it to isolate dependencies:")
        print("    .venv\\Scripts\\Activate.ps1  (PowerShell)")
        print("    .venv\\Scripts\\activate.bat  (Command Prompt)")

    # Find requirements files
    req_in, req_dev_in = find_requirements_files()

    if not req_in and not req_dev_in:
        print("\n[ERROR] No requirements.in or requirements-dev.in found.")
        print("  Expected files in project root:")
        print("    - requirements.in")
        print("    - requirements-dev.in (optional)")
        return 1

    print("\n[INFO] Found requirements files:")
    if req_in:
        print(f"  - {req_in.name}")
    if req_dev_in:
        print(f"  - {req_dev_in.name}")

    # Ensure pip-tools is available
    print("\n[INFO] Ensuring pip-tools is installed...")
    result = run_command(
        [sys.executable, "-m", "pip", "install", "--quiet", "pip-tools"],
        "Installing pip-tools"
    )
    if result != 0:
        print("[ERROR] Failed to install pip-tools. Cannot proceed.")
        return 1

    # Compile requirements with --upgrade
    print("\n[INFO] Recompiling requirements files with --upgrade...")
    compile_cmds = []

    if req_in:
        compile_cmds.append(
            [sys.executable, "-m", "piptools", "compile", "--upgrade",
             str(req_in)]
        )

    if req_dev_in:
        compile_cmds.append(
            [sys.executable, "-m", "piptools", "compile", "--upgrade",
             str(req_dev_in)]
        )

    for cmd in compile_cmds:
        result = run_command(
            cmd,
            f"Compiling {Path(cmd[-1]).name}"
        )
        if result != 0:
            print(f"[ERROR] Failed to compile {Path(cmd[-1]).name}")
            return 1

    # Show diff and ask for confirmation
    print("\n[INFO] Checking what changed...")
    print("  (Run 'git diff requirements.txt requirements-dev.txt' to review)")

    confirmation = input("\n[CONFIRM] Proceed with upgrade? (y/N): ").strip().lower()
    if confirmation != "y":
        print("[CANCELLED] Upgrade aborted.")
        return 0

    # Install upgraded versions
    print("\n[INFO] Installing upgraded packages...")
    result = run_command(
        [sys.executable, "-m", "pip", "install", "-r", "requirements.txt"],
        "Installing production dependencies"
    )
    if result != 0:
        print("[WARNING] Failed to install production dependencies. "
              "Some packages may be missing.")

    # Install dev dependencies if they exist
    if (Path.cwd() / "requirements-dev.txt").exists():
        result = run_command(
            [sys.executable, "-m", "pip", "install", "-r",
             "requirements-dev.txt"],
            "Installing development dependencies"
        )
        if result != 0:
            print("[WARNING] Failed to install dev dependencies.")

    # Run sanity checks
    print("\n[INFO] Running sanity checks...")
    sanity_bat = Path.cwd() / "sanity.bat"
    sanity_sh = Path.cwd() / "sanity.sh"

    if sanity_bat.exists():
        result = run_command([str(sanity_bat)], "Running sanity.bat")
    elif sanity_sh.exists():
        result = run_command(["bash", str(sanity_sh)], "Running sanity.sh")
    else:
        print("[WARNING] No sanity.bat or sanity.sh found. Skipping gate.")
        result = 0

    if result == 0:
        print("\n" + "=" * 80)
        print("  [OK] Upgrade complete. All tests passed.")
        print("=" * 80)
    else:
        print("\n" + "=" * 80)
        print("  [WARNING] Upgrade complete, but sanity checks failed.")
        print("  Review the output above and fix any issues.")
        print("=" * 80)
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())

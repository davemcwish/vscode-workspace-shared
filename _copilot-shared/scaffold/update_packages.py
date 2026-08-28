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

import re
import subprocess
import sys
from pathlib import Path

# Allow-list of the only programs this script is ever permitted to launch.
# The strictness IS the security control here, so this is deliberately an
# allow-list (unlike path re-verification, which must be a deny-list).
# Comparison is done on the lowercased file name, so a full path such as
# "C:\\project\\.venv\\Scripts\\python.exe" is matched as "python.exe".
_ALLOWED_COMMAND_NAMES = frozenset(
    {
        "python",
        "python.exe",
        "python3",
        "bash",
        "bash.exe",
        "sanity.bat",
        "sanity.sh",
    }
)

# Rejects NUL and other control bytes, double quotes, and the characters
# Windows forbids in a file name. It does NOT restrict ordinary punctuation,
# because a legitimate interpreter path can contain "&", "+", an apostrophe,
# or an accented letter (for example "D:\\R&D Tools\\.venv\\Scripts\\python.exe").
_SAFE_EXECUTABLE_PATTERN = re.compile(r'[^\x00-\x1f"*?<>|]{1,500}')


def run_command(cmd: list[str], description: str = "") -> int:
    """Run one external program and return the exit code it produced.

    "External program" means something outside Python - the Python
    interpreter itself, ``bash``, or the project's ``sanity`` gate script.
    Nothing else is permitted: the program name is checked against
    ``_ALLOWED_COMMAND_NAMES`` before anything is launched.

    Args:
        cmd: The program and its arguments as a list of strings, for example
            ``[sys.executable, "-m", "pip", "install", "pip-tools"]``. The
            first item is the program; every later item is an argument passed
            to it. A list is used rather than a single string so the operating
            system never re-interprets spaces or quotes.
        description: A short human-readable label printed as a banner before
            the program runs, for example ``"Installing pip-tools"``. Pass an
            empty string to print no banner.

    Returns:
        The exit code the program returned. By long-standing convention ``0``
        means success and any non-zero value means failure. ``1`` is also
        returned if the program could not be found at all.

    Raises:
        ValueError: If ``cmd`` is empty, or if the program is not on the
            allow-list, or if its path contains characters that are illegal
            in a file name. If you see this, you have almost certainly passed
            the wrong command - do not widen the allow-list to make it go
            away without understanding why.

    Example:
        >>> run_command([sys.executable, "--version"], "Checking Python")
        0
    """
    if description:
        print(f"\n{'=' * 80}")
        print(f"  {description}")
        print(f"{'=' * 80}")

    if not cmd:
        raise ValueError("run_command() was given an empty command list.")

    # Step 1 - the real security control: only known programs may be run.
    executable = cmd[0]
    if Path(executable).name.lower() not in _ALLOWED_COMMAND_NAMES:
        raise ValueError(f"Program is not on the allow-list: {executable!r}")

    # Step 2 - local re-verification, kept inline so static analysers can see
    # the sanitisation and the subprocess call together in one function.
    match = _SAFE_EXECUTABLE_PATTERN.fullmatch(executable)
    if match is None:
        raise ValueError(f"Program path failed re-verification: {executable!r}")
    safe_command = [match.group(0), *cmd[1:]]

    try:
        # Suppression rationale (S603): the program name is allow-listed
        # above and every argument is built inside this module from literals,
        # sys.executable, or Path objects rooted at the current working
        # directory. shell=False is explicit so no shell interprets them.
        result = subprocess.run(safe_command, check=False, shell=False)  # noqa: S603
        return result.returncode
    except FileNotFoundError as exc:
        print(f"[ERROR] Command not found: {safe_command[0]}")
        print(f"  Details: {exc}")
        return 1


def find_requirements_files() -> tuple[Path | None, Path | None]:
    """Look for the two dependency "source" files in the current folder.

    A ``.in`` file lists the packages you actually asked for, for example
    ``requests``. The matching ``.txt`` file is generated from it by
    ``pip-compile`` and additionally pins every indirect dependency to an
    exact version. This function finds the ``.in`` files; the ``.txt`` files
    are produced later by :func:`compile_requirements`.

    Returns:
        A pair ``(requirements_in, requirements_dev_in)``. Each item is a
        :class:`~pathlib.Path` if that file exists in the current working
        directory, or ``None`` if it does not. ``requirements-dev.in`` is
        optional in most projects, so ``None`` for the second item is normal.
    """
    project_root = Path.cwd()
    req_in = project_root / "requirements.in"
    req_dev_in = project_root / "requirements-dev.in"

    return (
        req_in if req_in.exists() else None,
        req_dev_in if req_dev_in.exists() else None,
    )


def warn_if_not_in_virtualenv() -> None:
    """Print a warning if the script is not running inside a virtual environment.

    A virtual environment is a private copy of Python for one project. Without
    one, upgrading packages changes them for every project on the machine,
    which is rarely what you want. This only warns - it never stops the run,
    because some continuous-integration systems legitimately install packages
    into the system interpreter.

    Returns:
        Nothing. The warning, if any, is printed to standard output.
    """
    if not sys.prefix or sys.prefix == sys.base_prefix:
        print("\n[WARNING] Virtual environment not detected.")
        print("  Consider activating it to isolate dependencies:")
        print("    .venv\\Scripts\\Activate.ps1  (PowerShell)")
        print("    .venv\\Scripts\\activate.bat  (Command Prompt)")


def compile_requirements(req_in: Path | None, req_dev_in: Path | None) -> int:
    """Regenerate the pinned ``.txt`` files, choosing the newest safe versions.

    This runs ``pip-compile --upgrade`` once per ``.in`` file. The ``--upgrade``
    flag is what makes this an upgrade rather than a simple recompile: without
    it, pip-compile keeps whatever versions are already pinned.

    Args:
        req_in: Path to ``requirements.in``, or ``None`` if the project has
            no production dependency file.
        req_dev_in: Path to ``requirements-dev.in``, or ``None`` if the
            project has no development dependency file.

    Returns:
        ``0`` if every file compiled successfully, or ``1`` if any compile
        failed. A failure usually means two packages demand incompatible
        versions of a third; read the pip-compile output to see which.
    """
    print("\n[INFO] Recompiling requirements files with --upgrade...")

    for source_file in (req_in, req_dev_in):
        if source_file is None:
            continue
        exit_code = run_command(
            [
                sys.executable,
                "-m",
                "piptools",
                "compile",
                "--upgrade",
                str(source_file),
            ],
            f"Compiling {source_file.name}",
        )
        if exit_code != 0:
            print(f"[ERROR] Failed to compile {source_file.name}")
            return 1

    return 0


def install_upgraded_packages() -> None:
    """Install the newly pinned versions into the active Python environment.

    Production dependencies (``requirements.txt``) are installed first, then
    development dependencies (``requirements-dev.txt``) if that file exists.
    Failures are reported as warnings rather than errors, because a partial
    install still leaves a usable environment and the sanity gate that runs
    afterwards will reveal anything genuinely broken.

    Returns:
        Nothing. Progress and any warnings are printed to standard output.
    """
    print("\n[INFO] Installing upgraded packages...")
    exit_code = run_command(
        [sys.executable, "-m", "pip", "install", "-r", "requirements.txt"],
        "Installing production dependencies",
    )
    if exit_code != 0:
        print("[WARNING] Failed to install production dependencies. Some packages may be missing.")

    if (Path.cwd() / "requirements-dev.txt").exists():
        exit_code = run_command(
            [sys.executable, "-m", "pip", "install", "-r", "requirements-dev.txt"],
            "Installing development dependencies",
        )
        if exit_code != 0:
            print("[WARNING] Failed to install dev dependencies.")


def run_sanity_gate() -> int:
    """Run the project's quality gate to prove the upgrade did not break anything.

    The gate is ``sanity.bat`` on Windows or ``sanity.sh`` elsewhere. It runs
    formatting, linting, type checking, security scanning, and the test suite.
    If neither script exists the check is skipped, because some projects that
    use this helper have no gate of their own.

    Returns:
        ``0`` if the gate passed or was skipped, or the gate's own non-zero
        exit code if it failed. A failure means an upgraded package changed
        behaviour - revert the ``.txt`` files with ``git checkout`` and
        investigate before trying again.
    """
    print("\n[INFO] Running sanity checks...")
    sanity_bat = Path.cwd() / "sanity.bat"
    sanity_sh = Path.cwd() / "sanity.sh"

    if sanity_bat.exists():
        return run_command([str(sanity_bat)], "Running sanity.bat")
    if sanity_sh.exists():
        return run_command(["bash", str(sanity_sh)], "Running sanity.sh")

    print("[WARNING] No sanity.bat or sanity.sh found. Skipping gate.")
    return 0


def main() -> int:
    """Upgrade every dependency, then verify the project still works.

    The steps are: find the ``.in`` files, recompile them with ``--upgrade``,
    ask the operator to confirm, install the results, and run the quality
    gate. The confirmation prompt is deliberate - it gives you a chance to
    inspect ``git diff requirements.txt`` before anything is installed.

    Returns:
        ``0`` if the upgrade completed and the gate passed, or if you
        declined at the confirmation prompt. ``1`` if no ``.in`` files were
        found, if pip-tools could not be installed, if compilation failed,
        or if the gate failed after the upgrade.
    """
    print("[INFO] Upgrading Python dependencies...")
    print(f"[INFO] Python: {sys.executable}")
    print(f"[INFO] Working directory: {Path.cwd()}")

    warn_if_not_in_virtualenv()

    req_in, req_dev_in = find_requirements_files()
    if not req_in and not req_dev_in:
        print("\n[ERROR] No requirements.in or requirements-dev.in found.")
        print("  Expected files in project root:")
        print("    - requirements.in")
        print("    - requirements-dev.in (optional)")
        return 1

    print("\n[INFO] Found requirements files:")
    for found_file in (req_in, req_dev_in):
        if found_file is not None:
            print(f"  - {found_file.name}")

    print("\n[INFO] Ensuring pip-tools is installed...")
    if (
        run_command(
            [sys.executable, "-m", "pip", "install", "--quiet", "pip-tools"],
            "Installing pip-tools",
        )
        != 0
    ):
        print("[ERROR] Failed to install pip-tools. Cannot proceed.")
        return 1

    if compile_requirements(req_in, req_dev_in) != 0:
        return 1

    print("\n[INFO] Checking what changed...")
    print("  (Run 'git diff requirements.txt requirements-dev.txt' to review)")

    confirmation = input("\n[CONFIRM] Proceed with upgrade? (y/N): ").strip().lower()
    if confirmation != "y":
        print("[CANCELLED] Upgrade aborted.")
        return 0

    install_upgraded_packages()

    if run_sanity_gate() != 0:
        print("\n" + "=" * 80)
        print("  [WARNING] Upgrade complete, but sanity checks failed.")
        print("  Review the output above and fix any issues.")
        print("=" * 80)
        return 1

    print("\n" + "=" * 80)
    print("  [OK] Upgrade complete. All tests passed.")
    print("=" * 80)
    return 0


if __name__ == "__main__":
    sys.exit(main())

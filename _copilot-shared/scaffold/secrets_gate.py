"""Secret-scanning gate - fails the build when a new secret appears.

THIS FILE IS A SHARED SCAFFOLD (owned by ``_copilot-shared/scaffold/``).
It is synced to every project on each sync run - do NOT edit per-project.
To change this file, edit ``_copilot-shared/scaffold/secrets_gate.py`` and
re-sync.

Why this script exists (please read before changing it)
-------------------------------------------------------
The quality gate used to run this command directly::

    python -m detect_secrets scan --baseline .secrets.baseline

That command looks like a check, but it is not one. ``detect-secrets scan``
is a **baseline-maintenance** command: when you give it ``--baseline`` it
scans the repository, writes any newly-discovered secrets *into* the baseline
file, and then exits with status ``0`` to report success.

"Exit code 0" is how every build system decides that a step passed. So a real
credential committed to the repository would be quietly added to the
allow-list and the gate would print a tick. This was confirmed by experiment:
a fake AWS key was committed, the command exited ``0``, and the key appeared
in ``.secrets.baseline`` as an approved entry.

The correct tool for *checking* is ``detect_secrets.pre_commit_hook``. It
compares the files you give it against the baseline, prints any secret that is
not already recorded there, exits ``1``, and never rewrites the baseline. This
script is a thin, cross-platform wrapper around that hook.

A second, smaller benefit: because the baseline is no longer rewritten on
every run, it no longer shows up as a modified file after each build. That
churn used to be dismissed as harmless noise, but it was in fact the visible
symptom of the file being overwritten - the same mechanism that swallowed new
secrets.

Why the file list is chunked
----------------------------
``pre_commit_hook`` does not walk the repository by itself; it only checks the
filenames you pass to it. A medium-sized project easily reaches 500+ tracked
files, which is roughly 28,000 characters of command line. Windows ``cmd.exe``
truncates a command line at 8,191 characters, and that truncation is *silent*
- the gate would appear to pass while quietly skipping most of the repository.

To stay safely inside every operating system's limit, this script sends the
files to the hook in batches (see ``CHUNK_SIZE``) and fails if *any* batch
reports a secret.

History - why this is not a revert
----------------------------------
An earlier version of the gate did call the hook, but once per file in a
PowerShell loop. That was replaced by ``scan --baseline`` in May 2026 for two
stated reasons, recorded in ``_copilot-shared/docs/repo-review-2026-05-28.md``:
the loop was slow, and it invoked a ``detect-secrets-hook`` executable that was
not reliably installed.

Both objections are addressed here, so this is not a return to the old design:

- **Speed:** files are sent in batches of ``CHUNK_SIZE``, so a 575-file
  repository takes four process launches rather than 575.
- **Availability:** the hook is invoked as a *module* through
  ``sys.executable -m detect_secrets.pre_commit_hook``, which uses the same
  interpreter already running this script. It never depends on a console
  script being present on the PATH.

The one thing the May 2026 change did not account for is that ``scan
--baseline`` does not fail on a new secret - it records it and exits ``0``.
That is what this script fixes.

Scope: tracked files plus untracked files that are not ignored
--------------------------------------------------------------
The file list comes from ``git ls-files --cached --others
--exclude-standard``. That covers everything Git is tracking **and** any new
file you have created but not yet ``git add``-ed.

Untracked files are included because a secret in a brand-new file is
otherwise invisible right up to the moment you commit it - which is exactly
the moment you most want to be warned. Catching it beforehand means it never
enters Git history, where removing it is far harder.

Files ignored by ``.gitignore`` are **not** scanned. Those are build output,
virtual environments, and local ``.env`` files: usually enormous, never
committed, and scanning them would make the gate slow and noisy without
protecting anything. If you keep a real credential in an ignored file, that is
correct and this gate will not complain about it.

Usage
-----
Run it from the root of a project (the folder containing ``.secrets.baseline``)::

    python secrets_gate.py

Exit codes - these are what the build system reacts to:

- ``0`` - no new secrets found. The gate passes.
- ``1`` - at least one new secret was found, **or** the check could not be
  completed (for example Git is unavailable). Failing when the check cannot
  run is deliberate: a security gate that cannot verify anything must not
  report success. This is called "failing closed".

Example of a failing run::

    $ python secrets_gate.py
    Checking 575 file(s) for secrets (tracked + untracked)...
    ERROR: Potential secrets about to be committed to git repo!
    Secret Type: AWS Access Key
    Location:    scripts/example.py:10
    FAILED: 1 batch(es) reported a potential secret.
"""

from __future__ import annotations

import os
import re
import shutil

# Suppression rationale: this module does spawn subprocesses, but every call
# uses shell=False, a shutil.which()-resolved executable, and literal argument
# names. See the two call sites below for the per-call rationale.
import subprocess  # nosec B404
import sys
from pathlib import Path

# The name of the allow-list file that records secrets already reviewed and
# accepted. It lives in the project root.
BASELINE_FILENAME = ".secrets.baseline"

# Deny-list used to re-verify a resolved executable path before it is handed to
# subprocess. It rejects only the characters that genuinely matter: NUL and
# other control bytes, double quotes, and the five characters Windows forbids
# in a filename. It must NOT be narrowed to an ASCII allow-list - real install
# paths contain spaces, ampersands, apostrophes, and accented letters, and a
# stricter pattern would reject them while adding no security whatsoever.
#
# The real security control is shutil.which(), which resolves the name against
# PATH rather than trusting caller input. This pattern is defence-in-depth and
# gives static analysis a match object it can see is sanitised.
_SAFE_EXECUTABLE_PATTERN = re.compile(r'[^\x00-\x1f"*?<>|]{1,500}')

# How many filenames to pass to the hook in a single call.
#
# The limit we must respect is the operating system's maximum command-line
# length; on Windows cmd.exe that is 8,191 characters. Assuming a generous
# 200 characters per path, 150 files is about 30,000 characters - too many for
# one call, which is exactly why we chunk. In practice paths average nearer 50
# characters, so 150 files is roughly 7,500 characters and fits comfortably.
# Lower this number if a project ever has unusually long paths.
CHUNK_SIZE = 150

# Maximum seconds to allow for one batch. A batch is CPU-bound work on at most
# CHUNK_SIZE files, so a few seconds is typical; five minutes means something
# has gone badly wrong and we should stop rather than hang the build forever.
CHUNK_TIMEOUT_SECONDS = 300

# Maximum seconds to allow for the "list the tracked files" call.
GIT_TIMEOUT_SECONDS = 60


def _resolve_executable(name: str) -> str:
    """Find a program on the system PATH and return its full, verified path.

    Passing a bare name such as ``"git"`` to :mod:`subprocess` is unsafe,
    because the operating system then searches for it and could find a
    different program of the same name earlier on the PATH. Resolving the name
    to a full path first removes that ambiguity.

    Args:
        name: The program to find, without a directory part - for example
            ``"git"``. On Windows the ``.exe`` suffix is added automatically by
            :func:`shutil.which`, so you do not need to include it.

    Returns:
        The full path to the program, for example
        ``"C:/Program Files/Git/cmd/git.exe"``.

    Raises:
        RuntimeError: If the program is not on the PATH, or if the resolved
            path contains characters that must never reach a command line. If
            you see this for ``git``, check that ``git --version`` works in a
            terminal.

    Example:
        >>> _resolve_executable("git")  # doctest: +SKIP
        'C:/Program Files/Git/cmd/git.exe'
    """
    resolved = shutil.which(name)
    if resolved is None:
        raise RuntimeError(f"Could not find '{name}'. Is it installed and on your PATH?")

    # Defence-in-depth re-verification. shutil.which() above is the real
    # control; this keeps the sanitisation and the subprocess call visible to
    # static analysis within one module.
    match = _SAFE_EXECUTABLE_PATTERN.fullmatch(resolved)
    if match is None:
        raise RuntimeError(f"Resolved path for '{name}' failed verification: {resolved!r}")
    return match.group(0)


def get_files_to_scan(project_root: Path) -> list[str]:
    """Return every file in ``project_root`` that the gate should scan.

    This is **tracked files plus untracked files that are not ignored**.

    Why untracked files are included: a brand-new file containing a
    credential is invisible to a tracked-only scan right up until the moment
    you commit it - which is exactly the moment you most want to be warned.
    Including untracked files means the gate can object *before* the secret
    enters Git history, where removing it is far harder.

    Ignored files (anything matched by ``.gitignore``) are deliberately left
    out. Those are build output, virtual environments, and local ``.env``
    files, which are frequently enormous and are never committed. Scanning
    them would make the gate slow and noisy without protecting anything.

    Args:
        project_root: The folder to inspect. This should be the root of the
            project - the folder that contains ``.secrets.baseline``. It must
            be inside a Git repository.

    Returns:
        A list of file paths as plain strings, relative to ``project_root``
        (for example ``"scripts/list_objects.py"``). The baseline file itself
        is excluded, because it legitimately contains hashes of known secrets
        and would otherwise flag itself on every run.

    Raises:
        RuntimeError: If Git is not installed or not on the PATH,
            ``project_root`` is not inside a Git repository, or Git takes
            longer than ``GIT_TIMEOUT_SECONDS``. If you see this, check that
            ``git --version`` works in a terminal and that you are running the
            script from inside the project folder. The caller treats this as a
            gate failure rather than a pass - see the module docstring on
            "failing closed".

    Example:
        >>> files = get_files_to_scan(Path("."))
        >>> ".secrets.baseline" in files
        False
    """
    git_executable = _resolve_executable("git")
    try:
        # -z separates names with a NUL byte instead of a newline. This is the
        # only safe separator, because a filename may legitimately contain a
        # newline but can never contain a NUL byte.
        #
        # --cached           tracked files
        # --others           untracked files
        # --exclude-standard honour .gitignore, so build output and .env files
        #                    are skipped
        #
        # Suppression rationale: the executable is resolved via shutil.which()
        # and re-verified, every other argument is a string literal, and
        # shell=False. There is no user-controlled input in this command.
        result = subprocess.run(  # noqa: S603  # nosec B603
            [
                git_executable,
                "ls-files",
                "-z",
                "--cached",
                "--others",
                "--exclude-standard",
            ],
            cwd=project_root,
            capture_output=True,
            text=True,
            check=True,
            shell=False,
            timeout=GIT_TIMEOUT_SECONDS,
        )
    except FileNotFoundError as exc:
        raise RuntimeError("Could not run 'git'. Is Git installed and on your PATH?") from exc
    except subprocess.TimeoutExpired as exc:
        raise RuntimeError(
            f"'git ls-files' did not finish within {GIT_TIMEOUT_SECONDS} seconds."
        ) from exc
    except subprocess.CalledProcessError as exc:
        raise RuntimeError("'git ls-files' failed. Are you inside a Git repository?") from exc

    # A file can be listed twice if it is both tracked and reported as other;
    # dict.fromkeys removes duplicates while preserving the original order.
    return list(
        dict.fromkeys(
            name
            for name in result.stdout.split("\0")
            if name and Path(name).name != BASELINE_FILENAME
        )
    )


def scan_chunk(filenames: list[str], project_root: Path) -> bool:
    """Check one batch of files for secrets that are not in the baseline.

    Args:
        filenames: The batch of file paths to check, relative to
            ``project_root``. An empty list is treated as "nothing to check"
            and passes.
        project_root: The project root, used as the working directory so that
            the relative paths and the baseline file both resolve correctly.

    Returns:
        ``True`` if the batch is clean, ``False`` if at least one new secret
        was found. Details of any finding are printed by the hook itself
        (secret type and file:line), so the operator can go straight to it.

    Raises:
        RuntimeError: If the hook cannot be run at all, or exceeds
            ``CHUNK_TIMEOUT_SECONDS``. Treated as a gate failure, never a pass.
    """
    if not filenames:
        return True

    # sys.executable is the interpreter currently running this script, so the
    # hook always comes from the same virtual environment - never a different
    # Python that might not have detect-secrets installed. It is re-verified
    # here so the sanitisation and the subprocess call sit in one function.
    match = _SAFE_EXECUTABLE_PATTERN.fullmatch(sys.executable)
    if match is None:
        raise RuntimeError(f"Python path failed verification: {sys.executable!r}")
    python_executable = match.group(0)

    # Force UTF-8 mode in the scanner.
    #
    # detect-secrets opens each file using Python's *default* text encoding.
    # On Windows that is cp1252, which cannot decode characters such as the
    # emoji and accented letters that appear routinely in Markdown and in
    # Salesforce-derived data. When decoding fails, detect-secrets skips the
    # file - and it does so SILENTLY, reporting success for a file it never
    # actually read.
    #
    # That is the same failure this script exists to remove: an under-scan
    # reported as a pass. Measured on this repository, 76 of 576 tracked files
    # (13%) were skipped locally for this reason, while CI - running on Linux,
    # where the default is already UTF-8 - scanned all of them. A secret in any
    # of those 76 files would have passed the local gate unnoticed.
    #
    # PYTHONUTF8=1 makes Windows behave exactly as Linux does, so local and CI
    # scan the same bytes and agree. It is a no-op on Linux and macOS.
    scan_environment = {**os.environ, "PYTHONUTF8": "1"}

    try:
        # Suppression rationale: the interpreter path comes from
        # sys.executable and is re-verified above, the module and flag are
        # string literals, and the remaining arguments are repository file
        # paths produced by 'git ls-files' - never raw user input. shell=False
        # means nothing is interpreted by a shell.
        result = subprocess.run(  # noqa: S603  # nosec B603
            [
                python_executable,
                "-m",
                "detect_secrets.pre_commit_hook",
                "--baseline",
                BASELINE_FILENAME,
                *filenames,
            ],
            cwd=project_root,
            env=scan_environment,
            shell=False,
            timeout=CHUNK_TIMEOUT_SECONDS,
        )
    except subprocess.TimeoutExpired as exc:
        raise RuntimeError(f"Secret scan batch exceeded {CHUNK_TIMEOUT_SECONDS} seconds.") from exc

    return result.returncode == 0


def baseline_has_unstaged_changes(project_root: Path) -> bool:
    """Report whether ``.secrets.baseline`` has edits that are not yet staged.

    This matters because ``detect_secrets.pre_commit_hook`` refuses to run at
    all when the baseline has unstaged edits. That is a deliberate safety rule
    on its part: if it trusted an unstaged baseline, someone could hide a
    secret simply by editing the file without ever committing the change.

    The refusal is correct, but the message it prints ("Your baseline file is
    unstaged") is easy to mistake for a secret being found. Detecting the
    situation up front lets this script explain what actually happened.

    Args:
        project_root: The project root - the folder containing
            ``.secrets.baseline``.

    Returns:
        ``True`` if the baseline has been edited but not staged, ``False`` if
        it is unchanged, already staged, or if the check could not be made (in
        which case the scan proceeds and the hook's own message is shown).

    Example:
        >>> baseline_has_unstaged_changes(Path("."))
        False
    """
    try:
        git_executable = _resolve_executable("git")
        # Suppression rationale: resolved executable, all other arguments are
        # string literals, shell=False. No user input reaches this command.
        result = subprocess.run(  # noqa: S603  # nosec B603
            [git_executable, "diff", "--name-only", "--", BASELINE_FILENAME],
            cwd=project_root,
            capture_output=True,
            text=True,
            check=True,
            shell=False,
            timeout=GIT_TIMEOUT_SECONDS,
        )
    except (RuntimeError, subprocess.SubprocessError):
        # This is only a diagnostic nicety. If it fails, fall through and let
        # the scan run - never block the gate on the quality of a hint.
        return False

    return bool(result.stdout.strip())


def run_gate(project_root: Path) -> int:
    """Check every scannable file for new secrets and return an exit code.

    "Scannable" means tracked files plus untracked files that are not ignored
    by ``.gitignore`` - see :func:`get_files_to_scan`.

    Args:
        project_root: The project root - the folder containing
            ``.secrets.baseline``.

    Returns:
        ``0`` if no new secrets were found (or the project has no baseline file
        and the check is skipped), ``1`` if any new secret was found or the
        check could not be completed.

    Example:
        >>> run_gate(Path("."))
        0
    """
    baseline_path = project_root / BASELINE_FILENAME
    if not baseline_path.is_file():
        # Not every project has adopted secret scanning yet. Skipping is
        # correct here and mirrors how the other gate steps skip when their
        # target directory is absent.
        print(f"SKIPPED: No {BASELINE_FILENAME} file found.")
        return 0

    if baseline_has_unstaged_changes(project_root):
        # detect-secrets will refuse to run at all in this state. Say so
        # plainly, because its own message is easily misread as "a secret was
        # found" when nothing has been scanned yet.
        print(f"FAILED: {BASELINE_FILENAME} has been edited but not staged.")
        print("        No files were scanned - the check could not run.")
        print("        This is NOT a secret finding.")
        print(f"        Fix it with:  git add {BASELINE_FILENAME}")
        return 1

    try:
        files = get_files_to_scan(project_root)
    except RuntimeError as exc:
        # Fail closed: if we cannot list the files, we cannot claim the
        # repository is clean.
        print(f"FAILED: {exc}")
        return 1

    print(f"Checking {len(files)} file(s) for secrets (tracked + untracked)...")

    failed_batches = 0
    for start in range(0, len(files), CHUNK_SIZE):
        chunk = files[start : start + CHUNK_SIZE]
        try:
            if not scan_chunk(chunk, project_root):
                failed_batches += 1
        except RuntimeError as exc:
            print(f"FAILED: {exc}")
            return 1

    if failed_batches:
        print(f"FAILED: {failed_batches} batch(es) reported a potential secret.")
        print(
            "If a finding is a false positive, add an inline "
            "'pragma: allowlist secret' comment on that line, or review and "
            "update .secrets.baseline deliberately."
        )
        return 1

    print("PASSED: No new secrets found.")
    return 0


def main() -> int:
    """Entry point used when the script is run from the command line.

    Returns:
        The process exit code - ``0`` for pass, ``1`` for fail. The build
        system uses this to decide whether the gate step succeeded.
    """
    return run_gate(Path.cwd())


if __name__ == "__main__":
    raise SystemExit(main())

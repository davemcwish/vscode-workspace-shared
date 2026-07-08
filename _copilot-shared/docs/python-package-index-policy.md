# Python Package Index Policy

This document records **where Python packages come from** in this workspace, and
what that means for which package versions you can install. It matters because
the projects here run inside a company network that mandates a single, curated
package source. If you (or a future maintainer) ever wonder "why can't I install
version X of a package?", this is the answer.

> **Audience:** written for someone new to Python packaging. Every term is
> explained on first use.

## What is a "package index"?

When you run `pip install <something>`, `pip` (Python's package installer)
downloads the package from a **package index** - a server that hosts Python
packages. The public default index is [PyPI](https://pypi.org/) (the "Python
Package Index"). Companies often run their own **mirror** (a filtered copy) so
that only vetted packages and versions are available internally.

## The mandated index for this workspace

On the company-managed machine this workspace was built on, `pip` is configured
to use an internal [JFrog Artifactory](https://jfrog.com/artifactory/) mirror,
**not** public PyPI. The configured index is:

```text
https://www.incog.jfrog.ford.com/artifactory/api/pypi/pyserv-native-python-gold-remote/simple/
```

This is set in `pip`'s configuration file, which on Windows lives at:

```text
C:\Users\<you>\pip\pip.ini
```

(Replace `<you>` with your Windows username. On macOS or Linux the equivalent
file is `~/.config/pip/pip.conf` or `~/.pip/pip.conf`.)

Because this index is configured globally, **every** `pip install` on this
machine draws from that mirror - including the installs performed when a
project's virtual environment (`.venv`) is created.

## What this means for package versions

The mirror only serves the package versions it has been curated to hold. That
is usually a **subset** of what public PyPI offers. So:

- You can only install a version that the mirror actually hosts.
- A version that exists on public PyPI may **not** be installable here.
- Until the mirror's contents change (a decision owned by the platform team,
  not by this project), the set of installable versions is fixed.

This is a **constraint to design around**, not a bug. When a project pins a
dependency version, that pin must be a version the mirror serves.

## How to check which versions are available

Before pinning a dependency, ask the mirror what it has. Use `pip index
versions` (replace the `py` launcher with your interpreter if needed - see the
note in `START-HERE-WINDOWS.md`):

```powershell
py -m pip index versions <package-name>
```

Worked example - the two packages considered for PDF verification in the
Salesforce project:

```text
> py -m pip index versions pikepdf
pikepdf (9.11.0)
Available versions: 9.11.0, 9.5.2
  INSTALLED: 9.11.0
  LATEST:    9.11.0

> py -m pip index versions pypdfium2
pypdfium2 (5.0.0)
Available versions: 5.0.0, 4.30.1, 4.30.0, 4.29.0
```

Note that `pikepdf` on this mirror tops out at **9.11.0**, even though newer
releases (for example 10.x) exist on public PyPI. That is exactly the constraint
described above: the newer version is not on the mandated mirror, so it cannot
be installed here yet.

## What to do when a needed version is not available

1. **Prefer a version the mirror already serves.** Pin the newest available
   version that meets the project's needs (for `pikepdf`, that is `9.11.0`).
2. **Design so a future bump is a one-line change.** Avoid relying on APIs that
   only exist in the unavailable newer version, so that if the mirror later adds
   it, upgrading is a single pin change.
3. **Consider a permissively-licensed alternative** that the mirror does serve,
   and record it as a documented fallback.
4. **Escalate to the platform team** only if no serviceable version exists - do
   not work around the mirror.

## The Python engine (interpreter) comes from the same place

The Python **engine** itself (the interpreter that runs `.py` files) on this
machine is a company-managed build (installed under
`C:\Users\<you>\AppData\Local\Programs\Python\`). Some managed builds do not put
the `py` launcher on the `PATH`; when that happens, call the interpreter by its
full path instead. `START-HERE-WINDOWS.md` explains this in the "No `py`
launcher?" note.

## Using these projects outside the company network

If you fork or reuse a project in a different environment - a personal machine,
a different company, or one without this mirror - **this constraint does not
apply to you**. On public PyPI (or a differently-curated mirror) you may have
access to other, often newer, package versions. In that case you are free to:

- Pin newer versions than those listed here, and
- Regenerate the locked `requirements*.txt` files against your own index.

The pins committed to these projects reflect what the mandated mirror served at
the time of writing. Treat them as a known-good baseline, not an absolute
ceiling for every environment.

## Related documents

- `START-HERE-WINDOWS.md` - installing the Python engine and the "No `py`
  launcher?" note.
- `UPDATING_DEPENDENCIES.md` (in each project) - how to add, update, and
  regenerate pinned dependencies safely.
- `dependency-update-scaffolding.md` - the `update_packages` tooling that
  recompiles and verifies dependency changes.

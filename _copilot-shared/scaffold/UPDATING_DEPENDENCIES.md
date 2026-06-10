# Updating Dependencies

<!--
  SCAFFOLD TEMPLATE - fill in the sections marked [FILL IN].
  This file was copied from _copilot-shared\scaffold\UPDATING_DEPENDENCIES.md.

  The pattern described here uses pip-tools (pip-compile) for Python projects.
  For other languages, replace this section with the equivalent tooling
  (e.g. npm update + npm audit for Node.js, mvn versions:update for Java).
-->

This document explains how dependencies are managed and how to update them
safely.

---

## Overview

Dependencies are declared as **loose pins** in `.in` files and resolved to
**exact pins** in locked `.txt` files. The locked files are committed so that
every developer and CI run uses identical package versions.

| File | Purpose |
| --- | --- |
| `requirements.in` | Runtime dependencies (loose pins) |
| `requirements.txt` | Runtime dependencies (exact pins, generated) |
| `requirements-dev.in` | Dev/test dependencies (loose pins) |
| `requirements-dev.txt` | Dev/test dependencies (exact pins, generated) |

[FILL IN: Replace or extend this table if your project uses different
 dependency files (e.g. `package.json` / `package-lock.json`,
 `pom.xml`, `build.gradle`, `Cargo.toml`).]

---

## Adding a New Dependency

1. Add the package name (without a version pin) to the appropriate `.in` file.
2. Run the compile step to regenerate the locked file (see below).
3. Verify the tests still pass (`sanity.bat`).
4. Commit **both** the `.in` file and the regenerated `.txt` file.

---

## Regenerating the Locked Files

[FILL IN: Replace the commands below with whatever your language uses.]

**Runtime only:**

```bat
pip-compile requirements.in
```

**Everything (runtime + dev):**

```bat
pip-compile requirements-dev.in
```

---

## Security Considerations Before Adding a Package

Before adding any new dependency:

1. Confirm the package is actively maintained (check its repository - when was
   the last commit? Does it have recent releases?).
2. Check for known vulnerabilities using the approved internal security process.
   If `pip-audit` is available in your environment: `pip-audit`.
3. Prefer packages that are already in use in other internal projects - they are
   more likely to have been reviewed.
4. Minimise transitive dependencies - a package that pulls in 20 others
   increases the attack surface significantly.

Cycode SCA (Software Composition Analysis) scans every PR for vulnerable
dependencies and blocks merge on critical findings.

---

## Removing a Dependency

1. Remove the entry from the `.in` file.
2. Run the compile step to regenerate the locked file.
3. Confirm no source code still imports the removed package.
4. Run `sanity.bat` to verify nothing is broken.
5. Commit both the `.in` and the regenerated `.txt` file.

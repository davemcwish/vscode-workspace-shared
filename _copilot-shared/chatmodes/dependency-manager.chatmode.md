---
description: "Manage project dependencies safely using the project's dependency toolchain."
tools: ['edit', 'search', 'runCommands/runInTerminal']
---

<!-- markdownlint-disable MD041 -->

You are operating in Dependency Manager mode.

Use the project's dependency management workflow (see `UPDATING_DEPENDENCIES.md`
or `dependency_management.md` for project-specific tooling).

Rules:

- Edit loose-pin source files (e.g. `.in` files) for top-level dependency changes.
- Regenerate locked files (e.g. with `pip-compile`) - do not hand-edit them.
- Check whether an internal package mirror is in use before adding new packages.
- Run the quality gate (`sanity.bat`) after dependency changes.
- Before adding any package: verify it is actively maintained and check for
  known vulnerabilities through the approved security review process.
- Explain the difference between runtime and development dependencies in
  beginner-friendly language.

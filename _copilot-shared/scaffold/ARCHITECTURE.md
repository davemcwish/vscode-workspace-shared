# Architecture: [Project Name]

<!--
  SCAFFOLD TEMPLATE - fill in the sections marked [FILL IN].
  This file was copied from _copilot-shared\scaffold\ARCHITECTURE.md.

  PLATFORM NOTE: The CI pipeline and Cycode security scanner both run on
  Linux (ubuntu-latest). All path handling, file I/O, and shell assumptions
  must be cross-platform. See CONTRIBUTING.md and copilot-instructions.md
  for coding standards.
-->

## Overview

[FILL IN: Two to four sentences. What is this system? What does it do at a
high level? Who uses it and how?]

---

## Components

[FILL IN: Show how the major parts of the system relate to each other.
 ASCII box diagrams work well and are readable in any text editor.
 Example shape - replace every block with your actual components:]

```text
┌──────────────────────────────────────────────────┐
│              Entry Point / CLI Layer             │
│  e.g. scripts/, main.py, REST endpoints          │
└────────────────────────┬─────────────────────────┘
                         │ calls
┌────────────────────────▼─────────────────────────┐
│           Core / Shared Library Layer            │
│  e.g. src/, lib/, common utilities               │
└────────────────────────┬─────────────────────────┘
                         │ calls
┌────────────────────────▼─────────────────────────┐
│              External Systems / I/O              │
│  e.g. APIs, databases, filesystem, email         │
└──────────────────────────────────────────────────┘
```

---

## Data Flows

[FILL IN: For each major workflow, show the data path from input to output.
 One numbered list or short diagram per workflow. Keep it to 3 - 5 steps.]

### [Workflow 1 Name]

```text
[Input source] → [processing step] → [output destination]
```

---

## Key Design Decisions

[FILL IN: Record decisions that are not obvious from the code. For each
decision, note what was decided, why, and what was rejected.
 This saves future maintainers from re-arguing settled questions.]

| Decision | Rationale | Alternatives rejected |
| --- | --- | --- |
| [FILL IN] | [FILL IN] | [FILL IN] |

---

## Platform and Environment

| Item | Value |
| --- | --- |
| Language / runtime | [FILL IN: e.g. Python 3.12] |
| OS (local dev) | [FILL IN: e.g. Windows 11] |
| CI/CD platform | GitHub Actions - `ubuntu-latest` (Linux) |
| Security scanner | Cycode - runs on Linux, scans SAST + secrets + SCA on every PR |
| [FILL IN: other tools] | [FILL IN] |

**Cross-platform requirement:** Code must behave identically on Windows (local
development) and Linux (CI/CD and Cycode). Use `pathlib.Path` for paths,
always specify `encoding='utf-8'` on file opens, and guard Windows-only
dependencies with `sys_platform == "win32"`.

---

## Security Considerations

[FILL IN: Describe the trust model for this project. Good questions to answer:

- What data does the project handle? Is any of it sensitive (PII, credentials, keys)?
- What are the trust boundaries? What input comes from untrusted sources?
- Where does tainted data flow? Does it reach subprocess calls or file writes?
- What access controls are in place?

See `security.instructions.md` and `SECURITY.md` for coding patterns and policy.]

# Security Policy

<!--
  SCAFFOLD TEMPLATE - fill in the sections marked [FILL IN].
  This file was copied from _copilot-shared\scaffold\SECURITY.md.
-->

## Supported Versions

[FILL IN: Which versions of this project receive security fixes?
 Example:]

| Version | Supported |
| --- | --- |
| latest (`main`) | ✅ |
| older tags | ❌ |

---

## Reporting a Vulnerability

[FILL IN: How should someone report a security vulnerability?
 Do not ask people to raise a public issue for security problems.
 Example:]

Please **do not** report security vulnerabilities through public GitHub Issues.

Instead, [FILL IN: email security@example.com / raise a confidential ticket
in [system] / contact [team name]]. Include:

- A description of the vulnerability and its potential impact.
- Steps to reproduce (if applicable).
- Any suggested remediation you may have.

You should receive acknowledgement within [FILL IN: e.g. 2 business days].

---

## Known Security Measures

The project applies the following security controls:

| Control | Tool / approach |
| --- | --- |
| Secrets scanning | `detect-secrets` - runs locally (sanity.bat) and in CI |
| SAST | `bandit` - runs locally (sanity.bat) and in CI |
| SAST (PR gate) | Cycode - runs on every pull request, blocks merge on findings |
| SCA (dependencies) | [FILL IN: pip-audit if available; otherwise internal security review] |
| Tainted input in subprocesses | Genuinely restrictive allowlist validation (see `security.instructions.md`) |
| Path traversal | `resolve_safe_path()` real containment check (see `security.instructions.md`) |
| Credentials | Never committed; loaded from `.env` (local) or approved secrets manager (production) |

---

## Data Handling

[FILL IN: What data does this project handle?
 Note whether any data is personally identifiable (PII), confidential,
 or subject to regulatory requirements.
 Describe what is stored, where, for how long, and who has access.]

---

## Known Limitations

[FILL IN: Any known security limitations or accepted risks.
 Being honest here helps reviewers and auditors understand the threat model.]

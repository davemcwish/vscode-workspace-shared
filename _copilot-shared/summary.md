# .github Directory Summary

## Overview

This directory contains GitHub Copilot configuration files organised into
eight groups:

| Category | Purpose | Auto-Discovered | User-Triggered |
| --- | --- | --- | --- |
| `.spec-workflow` | Templates for requirements, tasks, and checklists | No | Used by agents |
| `agents` | Autonomous role-based workers | No | Yes |
| `chatmodes` | Persistent Copilot Chat personas | No | Yes |
| `instructions` | Auto-applied rules by file pattern | Yes | No |
| `prompts` | Reusable task recipes | No | Yes |
| `skills` | Focused technical standards used by agents and humans | No | Referenced |
| `workflows` | CI and procedural workflows | Partly | Yes |
| `copilot-instructions.md` | Global Copilot behavior and project rules | Yes | No |

---

## How the Groups Work Together

- **Instructions** are guardrails — Copilot reads them automatically when you
  edit files that match their `applyTo` pattern.
- **Prompts** are shortcuts — type `/prompt-name` in chat to run a repeatable
  recipe.
- **Chat modes** are personas — select one at the start of a conversation to
  set the mindset for the whole session.
- **Agents** are specialist workers — each has a defined workflow, input set,
  and output format.
- **Skills** are the detailed standards agents must read before writing code
  or reviews.
- **Spec workflow templates** are the scaffolding agents use to produce
  consistent task and checklist files.

---

## 1. Spec Workflow (`.spec-workflow/`)

Templates used by the `team-lead` agent when decomposing designs into tasks.

| File | Purpose |
| --- | --- |
| `task_file_template.md` | Template for individual implementation tasks — includes docstring requirements, validation steps, and rollback instructions. |
| `checklist_file_template.md` | Template for FR-level checklists. |
| `fr_template.md` | Template for functional requirement documents. |

---

## 2. Agents (`agents/`)

Specialist AI personas. Invoke by naming the agent in chat or selecting it
in the agent dropdown.

| File | Purpose |
| --- | --- |
| `scope-change.agent.md` | Captures and validates a new scope change request before it enters the backlog. |
| `business-analyst.agent.md` | Translates a scope change into structured functional requirements. |
| `architect.agent.md` | Produces a module-level technical design for approved requirements. |
| `team-lead.agent.md` | Decomposes designs into sequential beginner-friendly implementation tasks. |
| `dev.agent.md` | Implements tasks produced by the team-lead. |
| `dev-manager.agent.md` | Reviews and approves designs and task plans before implementation. |
| `code-reviewer.agent.md` | Reviews completed code for correctness, security, style, and test coverage. |
| `doc-writer.agent.md` | Writes and updates beginner-friendly project documentation. |
| `pre-commit-check.agent.md` | Runs the full quality gate and summarises results before a PR is raised. |
| `docstring-auditor.agent.md` | Audits and improves beginner-friendly Python docstrings without changing runtime behaviour. |
| `critical-thinking.agent.md` | Challenges assumptions via Socratic questioning — asks questions only, never writes code. |
| `debug.agent.md` | Systematic 4-phase bug diagnosis: assess → investigate → resolve → verify. |

**Recommended agent chain:**

```text
scope-change → business-analyst → architect → dev-manager → team-lead → dev
                                                    ↓
                              code-reviewer → docstring-auditor → pre-commit-check → doc-writer
```

**Supporting agents (use at any step):**

```text
critical-thinking  — challenge assumptions before committing to a design
debug              — systematic troubleshooting when tests fail
```

---

## 3. Chat Modes (`chatmodes/`)

Select a chat mode at the start of a Copilot Chat session. The mode sets a
persona and ruleset that persist for the entire conversation.

| File | Purpose |
| --- | --- |
| `backlog-gate.chatmode.md` | Check whether an idea already exists in §8.4–§8.6 before creating a new backlog entry. |
| `capability-planner.chatmode.md` | Scope, size, and prioritise new capabilities and technical debt items. |
| `dependency-manager.chatmode.md` | Manage Python dependencies safely with pip-tools. |
| `doc-writer.chatmode.md` | Write beginner-friendly project documentation. |
| `docstring-review.chatmode.md` | Review and improve Python docstrings without changing runtime behaviour. |
| `infra-guide.chatmode.md` | Guide infrastructure, CI, and environment setup decisions. |
| `pr-merge.chatmode.md` | Write the git commit message and PR description, then push. |
| `pre-commit-check.chatmode.md` | Run the full quality gate and summarise results before raising a PR. |
| `release-pr-planner.chatmode.md` | Split approved capabilities into safe, reviewable pull requests. |
| `sf-safe-ops.chatmode.md` | Read-only Salesforce reasoning mode — no write code generated. |
| `test-engineer.chatmode.md` | Design and improve pytest coverage without real Salesforce calls. |
| `transcript-extractor.chatmode.md` | Convert long transcripts into comprehensive beginner-friendly Markdown guides. |

**To switch modes in VS Code:**

In the Copilot Chat panel, click the mode selector dropdown (next to the chat
input — it shows "Ask", "Edit", or "Agent"). Your `.chatmode.md` files appear
there by name. If they do not appear, open the Command Palette (`Ctrl+Shift+P`)
and run **GitHub Copilot: Open Chat** — VS Code rescans chat modes on startup.

---

## 4. Instructions (`instructions/`)

Auto-applied by Copilot when editing files that match the `applyTo` glob.
No manual action required.

| File | `applyTo` | Purpose |
| --- | --- | --- |
| `docstrings.instructions.md` | `src/**/*.py, scripts/**/*.py, tests/**/*.py` | Mandatory beginner-friendly Python docstring rules. |
| `docs.instructions.md` | `docs/**/*.md, *.md, CONTRIBUTING.md, README.md` | Audience and tone rules for all project documentation. |
| `flask-websocket-subprocess.instructions.md` | `frontend/**/*.py, src/**/job_runner*.py, **/app.py` | Flask 3.x REST API, Flask-SocketIO WebSocket, and subprocess.Popen patterns. |
| `html-css-javascript.instructions.md` | `**/*.html, **/*.css, **/*.js, frontend/**` | Authoring standards for HTML, CSS, and JavaScript. |
| `markdown.instructions.md` | `**/*.md` | Markdown style for project documentation. |
| `python.instructions.md` | `**/*.py` | Python coding standards for beginner-friendly maintainability. |
| `salesforce.instructions.md` | `src/**/*.py, scripts/**/*.py` | Salesforce API usage and Production-safety rules. |
| `security.instructions.md` | `**` | Secrets handling, sensitive data, OWASP web security for Flask endpoints. |
| `testing.instructions.md` | `tests/**/*.py` | Pytest conventions, coverage expectations, Flask/SocketIO test patterns. |
| `transcript-extraction.instructions.md` | `docs/**/*.md, transcripts/**/*.md, **/*transcript*.md, **/*guide*.md` | Rules for extracting beginner-friendly task guides from transcripts. |

---

## 5. Prompts (`prompts/`)

Triggered manually via `/` in Copilot Chat. Each prompt is a repeatable
recipe for a specific task.

| File | Purpose |
| --- | --- |
| `add-tests.prompt.md` | Add or improve pytest coverage for a selected module. |
| `component-overview.prompt.md` | Generate a plain-English overview of a module or script. |
| `docstring-audit.prompt.md` | Audit Python docstrings and produce a beginner-friendly remediation plan. |
| `docs-update.prompt.md` | Update project documentation after a code or workflow change. |
| `extract-transcript.prompt.md` | Extract a comprehensive beginner-friendly guide from a chat transcript. |
| `improve-docstrings.prompt.md` | Improve Python docstrings across a file or module without changing runtime behaviour. |
| `new-script.prompt.md` | Scaffold a new Salesforce admin utility script. |
| `pre-commit-check.prompt.md` | Run and interpret the full project sanity checks before a commit. |
| `project-architecture.prompt.md` | Summarise the current project architecture. |
| `refactor-legacy-script.prompt.md` | Refactor an older standalone script into the current project architecture. |
| `review.prompt.md` | Beginner-friendly code review of staged changes. |
| `salesforce-report.prompt.md` | Create a read-only Salesforce reporting script with CSV output. |
| `troubleshoot-error.prompt.md` | Diagnose a command error and produce a beginner-friendly fix plan. |
| `update-dependencies.prompt.md` | Safely update dependencies using pip-tools. |

---

## 6. Skills (`skills/`)

Detailed standards that agents must read before writing code, reviews, or
tasks. Not auto-applied — agents load them explicitly.

| File | Purpose |
| --- | --- |
| `cli.skill.md` | argparse patterns, help text, exit codes, and dry-run conventions. |
| `docstring.skill.md` | Mandatory beginner-friendly Google-style docstring rules, examples, and review checklist. |
| `flask-websocket.skill.md` | Flask 3.x, Flask-SocketIO, subprocess.Popen patterns for the JOSHUA frontend. |
| `html-css.skill.md` | HTML and CSS patterns for static Salesforce reports. |
| `html-css-static-report.skill.md` | Constraints and file structure for generated HTML reports. |
| `python.skill.md` | Core Python standards: style, typing, error handling, logging. |
| `salesforce.skill.md` | Salesforce API safety, SOQL patterns, PII handling, Production guardrails. |
| `security.skill.md` | Subprocess safety (Cycode SAST), secret handling, TLS, path traversal. |
| `testing.skill.md` | Pytest conventions, coverage targets, mocking patterns, cross-platform rules. |

---

## 7. Workflows (`workflows/`)

| File | Purpose |
| --- | --- |
| `ci.yml` | GitHub Actions CI workflow — ruff, mypy, bandit, detect-secrets, pytest. |

---

## 8. Root Files

| File | Purpose |
| --- | --- |
| `copilot-instructions.md` | Master configuration — applies to all Copilot interactions. Defines the standard 8-step development workflow. |
| `summary.md` | This file — complete inventory of all `.github` configuration. |

---

## Model Selection Guidance

Use the strongest available reasoning model for:

- architecture decisions,
- Production-impacting Salesforce work,
- security-sensitive changes,
- PII-sensitive exports,
- large refactors.

Use a faster, lower-cost model only for:

- typo fixes,
- simple Markdown cleanup,
- summarising low-risk text.

If the available model list in VS Code differs from any previous guidance in
this project, choose the closest equivalent and prioritise **safety, accuracy,
and review quality** over speed or cost.

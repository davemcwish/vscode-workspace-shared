# Copilot Instructions

Shared Copilot artefact ownership:

- _copilot-shared is the only source of truth for shared Copilot artefacts.
- Never edit project-local .github Copilot artefacts directly.
- If a shared agent, prompt, instruction, skill, workflow, chatmode, or copilot-instructions file needs to change, edit _copilot-shared first.
- After editing _copilot-shared, run shared validation, then run sync-shared-copilot.ps1.
- After sync, inspect downstream project diffs before committing.
- Normal project code loops must operate in one project repo only.
- Shared Copilot system loops may edit _copilot-shared, sync to all projects, and inspect downstream diffs.
- No loop may merge, push, deploy, or touch Salesforce Production without explicit human approval.
- Never push directly to a protected `main`. Push a branch and open a PR, even
  when the change is already reviewed. A direct push to `main` can silently
  bypass a required status check (this happened on 2026-09-08 - `Cycode:
  Secrets` was skipped, and the commit could not afterwards be scanned because
  GitHub refuses to open a PR with no commits between the branch and `main`).
  The bypass is not recoverable without rewriting a protected branch.
- Delete PR-body temp files (`.pr-body-tmp.md`) immediately after
  `gh pr create`, and verify with `git status --porcelain` before committing.

## Remote Push Order

Some repositories have more than one remote. Where they do, **raise the pull
request against the remote that runs the most review tooling first**, then
propagate to the others once it has merged. Reviewing on the weakest remote
first wastes the strong remote's feedback: the change is already approved by
the time the bots see it.

The `Salesforce` repository has three remotes:

| Remote | Repository | Review tooling |
| --- | --- | --- |
| `origin` | `ford-innersource/eu-crm-sf-admin-utils` | **Cycode SAST, plus `Copilot`, `codeguardians-cloud[bot]`, `cycode-security-2[bot]`, `ford-qodo-merge-agent[bot]`** |
| `ford-personal` | `ford-personal/dwishar1--Salesforce` | Cycode: Secrets only |
| `personal` | `davemcwish/Salesforce` | none |

So for `Salesforce`: **push the branch and open the PR on `origin` first.**
Only `origin` has the full SAST and bot review set, so it is the only remote
that can tell you the change is actually sound. After it merges there, push
`main` to `ford-personal` and `personal`, which act as mirrors.

Do not open feature-branch PRs on `ford-personal` or `personal` for this
repository - they carry no review capability the `origin` PR has not already
provided, and a second PR splits the review history across remotes.

## Project Context

- **Language:** Python 3.13+
- **Purpose:** Utility scripts to administer Salesforce (UAT and Production orgs)
- **Platform:** Windows 11, Visual Studio Code
- **Target audience:** Complete beginners to Python who will maintain this code

---

## Change Management Checklist

Before starting any task, complete these steps:

1. Provide a **full plan** of your changes.
2. List the **behaviors** that will change.
3. List the **test cases** to add or update.
4. Check if existing code can be **reused or reconfigured** before writing new code.
5. Assess **confidence** (see below) and adapt strategy accordingly.

### Confidence Assessment

Before committing to an implementation plan, assess confidence on a 0-100 scale:

| Confidence | Strategy |
| --- | --- |
| **High (>85%)** | Proceed with full implementation plan. |
| **Medium (66-85%)** | Build a proof-of-concept or MVP first. Define success criteria, validate, then expand. |
| **Low (<66%)** | Research phase first. Use `semantic_search`, read docs, study similar implementations. Re-assess after research. If still low, escalate to the user. |

Factors that lower confidence: unfamiliar library, unclear requirements,
complex integration, no existing tests to validate against, no prior art in
the codebase.

---

## Guiding Principles

### Completeness Is Cheap

AI-assisted coding makes the marginal cost of completeness near-zero. When the
complete implementation costs minutes more than the shortcut - do the complete
thing. Every time.

- A "lake" is boilable - full test coverage for a module, all edge cases,
  complete error paths. An "ocean" is not - rewriting an entire system from
  scratch.
- When evaluating "approach A (full) vs approach B (90%)" - prefer A. The
  shortcut mindset is legacy thinking from when human engineering time was the
  bottleneck.
- Never defer tests to a follow-up PR. Tests are the cheapest lake to boil.

### Search Before Building

Before building anything involving unfamiliar patterns - stop and search first.
The cost of checking is near-zero. The cost of not checking is reinventing
something worse.

Three layers of knowledge:

1. **Tried and true** - standard patterns, battle-tested approaches. Check
   whether the runtime or standard library already provides it.
2. **New and popular** - current best practices from documentation and
   ecosystem. Scrutinise what you find - the crowd can be wrong.
3. **First principles** - original reasoning about the specific problem. The
   most valuable layer. The best projects combine layers 1 + 3.

### User Sovereignty

AI recommends. The user decides. This overrides all other rules.

- Two AI models agreeing on a change is a strong signal, not a mandate.
- The user always has context models lack: domain knowledge, business
  relationships, strategic timing, future plans.
- When recommending a direction change - present the recommendation, explain
  the reasoning, state what context you might be missing, and ask. Never act
  unilaterally.

---

## Token Efficiency

- Never re-read files you just wrote or edited. You know the contents.
- Never re-run commands to "verify" unless the outcome was uncertain.
- Don't echo back large blocks of code unless asked.
- Batch related edits into single operations. Don't make 5 edits when 1
  handles it.
- Skip filler confirmations like "I'll continue..." - just do it.
- If a task needs 1 tool call, don't use 3. Plan before acting.
- Do not summarise what you just did unless the result is ambiguous or you
  need additional input.

---

## Context Engineering

Practices that help Copilot produce better suggestions and reduce
misunderstandings:

- **Keep relevant files open in tabs.** Copilot uses open tabs as context
  signals. Working on auth? Open auth-related files.
- **Position cursor intentionally.** Copilot prioritises code near your cursor.
- **Use Chat for complex tasks.** Inline completions have limited context;
  Chat mode sees more files.
- **Reference patterns explicitly.** "Follow the same pattern as
  `src/sf_admin_utils/query_helpers.py`" gives Copilot a concrete example.
- **Describe scope first for multi-file changes.** Tell Copilot all files
  involved before asking for changes.
- **Work incrementally.** One file at a time, verifying each change.
- **If Copilot struggles:** open relevant files, restart the session, be more
  specific, add constraints, reference existing code.

---

## Code Style & Structure

### Naming & Formatting

- Follow **PEP 8** style guidelines.
- Use **descriptive, meaningful names** - a reader should understand a variable's
  purpose without needing to look elsewhere.
- Prefer **explicit code over implicit behavior** - avoid hidden side effects,
  overly dynamic patterns, or "magic" unless clearly justified.

### Functions

- Keep functions **small and focused** - each does one clear thing.
- If a function is hard to explain in one sentence, split it into helpers.
- Add **type hints** for all parameters and return types.
- Write **complete-beginner docstrings** - assume the reader has never used
  Python professionally, has never touched Salesforce APIs, and cannot ask a
  colleague for help. Every docstring must explain:
  - What the function does in plain English
  - What each parameter means (with the type, and what values are valid)
  - What it returns (value and meaning, not just the type)
  - Exceptions it may raise, and what a beginner should do when they see one
  - Salesforce or business terms explained inline, not assumed
  - A simple usage example for any non-obvious function

### Constants & Configuration

- Use **named constants** for repeated fixed values - no unexplained numbers or
  strings scattered through the code.
- Never hard-code **passwords, tokens, API keys, or secrets** - use environment
  variables or approved secrets-management tools.

### Comments

- Comments explain **why**, not **what**.
- Code should be self-documenting through clear names and structure.
- Use comments for: business rules, assumptions, workarounds, or non-obvious behavior.

---

## Error Handling & Validation

- Handle exceptions **gracefully and intentionally** - don't silently swallow errors.
- **Validate important inputs** and provide useful error messages.
- Don't assume inputs are valid unless the function's docstring explicitly says so.

---

## Testing

- Use `pytest` for all tests.
- Do not introduce `unittest.TestCase` subclasses.
- Use `importlib` only when loading standalone scripts from `scripts/` that are
  not importable as normal Python modules.

---

## Logging & Observability

- Use the **`logging` module** - never `print()` in production code.
- Log at appropriate levels: `INFO` for progress, `WARNING` for recoverable
  issues, `ERROR` for failures.
- Include context in log messages (record IDs, counts, elapsed time).

---

## Dependencies & Environment

- Use **virtual environments** - each project gets its own isolated environment.
- Document dependencies in `requirements.txt`.
- Prefer **standard library** solutions over external packages when practical.
- Organize imports in this order:
  1. Standard library
  2. Third-party packages
  3. Local application modules

---

## Maintainability Principles

- **No duplicated code** - extract reusable functions, but don't over-engineer early.
- **No obfuscation** - optimize for readability before cleverness.
- A **complete beginner** should be able to: read the code, understand its
  purpose, run the tests, and safely make changes - without needing to ask
  anyone what the code does or why.
- Include **examples** when introducing new concepts or patterns.
- Format and lint code before submitting for review.

---

## Architecture Notes

| Item | Value |
|------|-------|
| OS (local dev) | Windows 11 |
| CPU | Intel Core Ultra 7 165U (12 cores, 14 logical) |
| RAM | 32 GB |
| Python | 3.13 |
| IDE | Visual Studio Code with GitHub Copilot |
| Auth | Salesforce CLI (`sf org display`) |
| HTTP | `requests` library with session management |
| CI/CD | GitHub Actions - `ubuntu-latest` (Linux) |
| Security scanner | Cycode - SAST + secrets + SCA; runs on Linux on every PR |

---

## Platform Independence

Code is written on **Windows 11** but runs in **two Linux environments**:
`ci.yml` (`ubuntu-latest`) and the Cycode scanner. Treat cross-platform
correctness as a baseline requirement, not an afterthought.

| Rule | Why |
| --- | --- |
| Use `pathlib.Path` or `os.path.join()` - never backslash string literals | Backslash path separators fail on Linux |
| Always specify `encoding='utf-8'` on `open()` | Windows may default to cp1252; Linux defaults to UTF-8; explicit is always safer |
| Guard Windows-only imports/packages with `sys_platform == "win32"` | CI will `ImportError` without the guard |
| Use lowercase, consistent module and file names | Linux filesystems are case-sensitive; a wrong-case import passes on Windows, fails on Linux |
| Use `\n` for line endings in generated text - never `\r\n` | CRLF causes cross-platform diffs and breaks Unix tools |
| `.secrets.baseline` path entries must use forward slashes | Backslash paths in the baseline file fail on Linux |

--

## HTML/CSS and Website Work

For generated static reports:

- Prefer simple semantic HTML and CSS.
- Avoid frontend frameworks unless explicitly justified.
- Keep reports self-contained and usable offline where practical.

For websites:

- Do not start with code.
- First clarify objective, audience, call to action, geography, platform,
  maintenance owner, content, UX/UI needs, accessibility, hosting, domain, and
  launch plan.
- Consider no-code platforms, CMS platforms, eCommerce platforms, static
  HTML/CSS, and custom web applications.
- Recommend the simplest platform that meets the user's goals and maintenance
  capability.
- Assume the user may have no website design, HTML, CSS, hosting, or domain
  experience.

--

## Standard Development Workflow

Use these modes, prompts, or agents in order for every significant change:

| Step | Tool | Purpose |
| --- | --- | --- |
| 0 | `backlog-gate.chatmode.md` | Confirm the idea is not already in Section 8.4-Section 8.6. |
| 1 | `capability-planner.chatmode.md` or `scope-change.agent.md` | Size and clarify the change. |
| 2 | `release-pr-planner.chatmode.md` | Slice the work into safe, ordered PRs. |
| 3 | `business-analyst.agent.md` | Produce approved Functional Requirements when needed. |
| 4 | `architect.agent.md` | Produce module-level design. |
| 5 | `team-lead.agent.md` | Produce granular implementation tasks. |
| 6 | `dev-manager.agent.md` | Execute tasks through the `dev` agent. |
| 7 | `docstring-auditor.agent.md` | Review and improve code docstrings. |
| 8 | `doc-writer.agent.md` or `docs-update.prompt.md` | Update project documentation. |
| 9 | `pre-commit-check.agent.md` or `pre-commit-check.chatmode.md` | Run the full quality gate. |
| 10 | `code-reviewer.agent.md` or `website-review.prompt.md` | Review completed changes. |
| 11 | `pr-merge.chatmode.md` | Prepare commit and PR text, then push after approval. |

**Supporting agents (use at any step):**

| Agent | Purpose |
| --- | --- |
| `critical-thinking.agent.md` (or `critical-thinking.chatmode.md`) | Challenge assumptions via open Socratic questioning before committing to a design or approach. Asks questions only - never writes code - with a single carve-out to flag data-loss, security, or Production-safety risks. Ends with a neutral recap of assumptions tested. |
| `debug.agent.md` | Systematic troubleshooting when tests fail or behaviour is unexpected. |
| `explore.agent.md` | Read-only codebase exploration - locates code, traces call sites and dependencies, confirms what already exists. Used by architect, business-analyst, and team-lead during context discovery. |

Never skip step 4 (tests green) before step 5 (docs update).
Never skip step 6 (quality gate) before step 7 (review).
Never skip Step 8 (documentation update) once Step 6 (implementation) is complete.
Never skip Step 9 (quality gate) before Step 10 (code review).

---

## Code Review Priority Levels

When reviewing code (or interpreting review feedback), classify issues:

| Level | Label | Action |
| --- | --- | --- |
| 🔴 | **CRITICAL** | Blocks merge. Security, correctness, data loss, breaking changes. |
| 🟡 | **IMPORTANT** | Requires discussion. SOLID violations, missing tests, performance, architecture drift. |
| 🟢 | **SUGGESTION** | Non-blocking. Readability, naming, minor optimisations, documentation gaps. |

## Canonical Quality Gate

The single source of truth is `.github/workflows/ci.yml` (remote, blocks merge).
`sanity.bat` is the **local mirror** of that pipeline - run it before every
commit. The `pre-commit-check` agent and prompt must invoke `sanity.bat` (or run
the identical commands below), not a simplified variant.

The gate runs these seven tool steps in order:

```text
ruff format --check src tests scripts
ruff check src tests scripts
mypy
bandit -c pyproject.toml -r src scripts --exclude scripts/archive,tests
python secrets_gate.py
pytest -n auto
npx markdownlint-cli2@0.22.1 "docs/**/*.md" "*.md"
```

**Step 5 must be `secrets_gate.py`, never `detect_secrets scan --baseline`.**
`scan --baseline` is a baseline-*maintenance* command: it writes any newly
discovered secret into `.secrets.baseline` and then exits `0`. A real
credential committed to the repository would therefore be silently added to
the allow-list while the gate reported success. This was confirmed by
experiment - a fake AWS key was staged, the command exited `0`, and the key
appeared in the baseline as an approved entry.

`secrets_gate.py` (shared-owned, `_copilot-shared\scaffold\secrets_gate.py`,
synced to every project root) wraps `detect_secrets.pre_commit_hook`, which
*checks* against the baseline, exits `1` on a new secret, and never rewrites
the file. It batches the file list because a large repo exceeds the Windows
8,191-character command-line limit, and that truncation would be silent. It
covers **git-tracked files only** - the same scope as the command it replaced;
widening it to untracked files is separately scoped work.

It also runs the scanner with **`PYTHONUTF8=1`**. `detect-secrets` opens files
using Python's default encoding, which on Windows is `cp1252`. Files containing
emoji or accented characters fail to decode and are skipped **silently** while
still being reported as scanned. Measured on the Salesforce repo, 76 of 576
tracked files (13%) were never scanned locally, while Linux CI scanned all of
them - so the two environments disagreed on identical content. Never remove
this environment variable: doing so reopens a silent under-scan, the same
failure class the script exists to close.

`.secrets.baseline` **must use POSIX forward slashes**. Windows tolerates
backslash entries locally; Linux CI does not, so a backslash baseline fails in
CI only. Normalise the baseline before switching a project to `secrets_gate.py`.

The gate fails if `.secrets.baseline` is edited but not staged. This is
deliberate - `detect-secrets` will not trust an unstaged baseline, because a
secret could otherwise be hidden by editing the file without committing it. The
script reports this case explicitly as *not* a secret finding.

A related symptom disappears with this change: `.secrets.baseline` no longer
shows as modified after every run. That churn was not cosmetic noise - it was
the visible evidence of the file being rewritten, the same mechanism that
absorbed new secrets.

**Coverage flags are defined once** in `pyproject.toml` under
`[tool.pytest.ini_options] addopts` and are automatically inherited by every
`pytest` invocation - `ci.yml`, `sanity.bat`, and plain `pytest` at the
terminal. Never pass `--cov`, `--cov-report`, or `--cov-fail-under` directly
in `ci.yml` or `sanity.bat`. Change the threshold in `pyproject.toml` only.

**Markdownlint** is pinned to `markdownlint-cli2@0.22.1` in both `ci.yml` and
`sanity.bat` so local and CI evaluate the same rule set. An unpinned `npx
markdownlint-cli2` downloads the latest release, which can enable new rules and
make local and CI disagree. Rule configuration lives in `.markdownlint.json`
(notably `MD013` line-length and `MD060` table-style are disabled). `ci.yml`
runs markdownlint first; `sanity.bat` runs it last as step 7 (auto-fix then
verify) and skips it with a warning if Node and `npx` are not installed - so a
machine without Node will pass `sanity.bat` while CI still lints. Install Node
locally to close that gap.

**Local advisory security scan (not one of the seven gate steps).** After the
seven blocking steps, `sanity.bat` / `sanity_v.bat` run `security_scan.py` as a
final **non-blocking** step. It is a conservative regex proxy for the Cycode
SAST gate: it surfaces likely SAST/OWASP issues before you push, but it produces
false positives, so in this phase it only prints findings and never changes the
pass/fail result. It is deliberately **not** in `ci.yml` because CI already runs
the real Cycode engine. The scanner is shared-owned
(`_copilot-shared\scaffold\security_scan.py` / `.ps1`), always synced to every
project root, and skips its own files. The parent workspace scans
`_copilot-shared\` only; a project scans its own root.

If you change the gate, update **all four** in the same commit: `ci.yml`,
`sanity.bat`, this section, and the `pre-commit-check` agent/prompt/chatmode.
The advisory security scan is the one exception: it lives in `sanity.bat`, this
section, and the `pre-commit-check` trio, but **not** in `ci.yml`.

**Cycode is a separate, additional gate** that runs automatically on every pull
request (not locally). It scans for SAST violations, committed secrets, and
vulnerable dependencies (SCA). Cycode runs on Linux - findings that only
reproduce on Linux can still block merge. Any Cycode finding is 🔴 CRITICAL.
The patterns that satisfy Cycode's SAST rules are documented in
`security.instructions.md`. Running `sanity.bat` locally before pushing catches
most issues that Cycode will flag (bandit covers SAST, detect-secrets covers
secrets) but is not a guarantee - Cycode has additional rules.

**Pipeline hardening** (SHA-pinned Actions, least-privilege `GITHUB_TOKEN`,
workflow-injection prevention, OIDC, SBOM, and CI-side secret-scanning and SAST
gating) is governed by `.github/instructions/ci-cd.instructions.md`. It applies
automatically when you edit files under `.github/workflows/` or
`.github/actions/`. Treat any pipeline-security or Cycode finding it raises as
CRITICAL - the same fail-closed bar as the rest of this gate.

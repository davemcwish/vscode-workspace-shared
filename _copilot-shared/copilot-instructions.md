# Copilot Instructions

## Project Context

- **Language:** Python 3.12+
- **Purpose:** Utility scripts to administer Salesforce (UAT and Production orgs)
- **Platform:** Windows 11, Visual Studio Code
- **Target audience:** Beginner-to-intermediate Python developers who will maintain this code

---

## Change Management Checklist

Before starting any task, complete these steps:

1. Provide a **full plan** of your changes.
2. List the **behaviors** that will change.
3. List the **test cases** to add or update.
4. Check if existing code can be **reused or reconfigured** before writing new code.

---

## Guiding Principles

### Completeness Is Cheap

AI-assisted coding makes the marginal cost of completeness near-zero. When the
complete implementation costs minutes more than the shortcut — do the complete
thing. Every time.

- A "lake" is boilable — full test coverage for a module, all edge cases,
  complete error paths. An "ocean" is not — rewriting an entire system from
  scratch.
- When evaluating "approach A (full) vs approach B (90%)" — prefer A. The
  shortcut mindset is legacy thinking from when human engineering time was the
  bottleneck.
- Never defer tests to a follow-up PR. Tests are the cheapest lake to boil.

### Search Before Building

Before building anything involving unfamiliar patterns — stop and search first.
The cost of checking is near-zero. The cost of not checking is reinventing
something worse.

Three layers of knowledge:

1. **Tried and true** — standard patterns, battle-tested approaches. Check
   whether the runtime or standard library already provides it.
2. **New and popular** — current best practices from documentation and
   ecosystem. Scrutinise what you find — the crowd can be wrong.
3. **First principles** — original reasoning about the specific problem. The
   most valuable layer. The best projects combine layers 1 + 3.

### User Sovereignty

AI recommends. The user decides. This overrides all other rules.

- Two AI models agreeing on a change is a strong signal, not a mandate.
- The user always has context models lack: domain knowledge, business
  relationships, strategic timing, future plans.
- When recommending a direction change — present the recommendation, explain
  the reasoning, state what context you might be missing, and ask. Never act
  unilaterally.

---

## Token Efficiency

- Never re-read files you just wrote or edited. You know the contents.
- Never re-run commands to "verify" unless the outcome was uncertain.
- Don't echo back large blocks of code unless asked.
- Batch related edits into single operations. Don't make 5 edits when 1
  handles it.
- Skip filler confirmations like "I'll continue..." — just do it.
- If a task needs 1 tool call, don't use 3. Plan before acting.
- Do not summarise what you just did unless the result is ambiguous or you
  need additional input.

---

## Code Style & Structure

### Naming & Formatting

- Follow **PEP 8** style guidelines.
- Use **descriptive, meaningful names** — a reader should understand a variable's
  purpose without needing to look elsewhere.
- Prefer **explicit code over implicit behavior** — avoid hidden side effects,
  overly dynamic patterns, or "magic" unless clearly justified.

### Functions

- Keep functions **small and focused** — each does one clear thing.
- If a function is hard to explain in one sentence, split it into helpers.
- Add **type hints** for all parameters and return types.
- Write **beginner-friendly docstrings** that explain:
  - What the function does
  - What each parameter means
  - What it returns
  - Exceptions it may raise
  - A simple usage example (when helpful)

### Constants & Configuration

- Use **named constants** for repeated fixed values — no unexplained numbers or
  strings scattered through the code.
- Never hard-code **passwords, tokens, API keys, or secrets** — use environment
  variables or approved secrets-management tools.

### Comments

- Comments explain **why**, not **what**.
- Code should be self-documenting through clear names and structure.
- Use comments for: business rules, assumptions, workarounds, or non-obvious behavior.

---

## Error Handling & Validation

- Handle exceptions **gracefully and intentionally** — don't silently swallow errors.
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

- Use the **`logging` module** — never `print()` in production code.
- Log at appropriate levels: `INFO` for progress, `WARNING` for recoverable
  issues, `ERROR` for failures.
- Include context in log messages (record IDs, counts, elapsed time).

---

## Dependencies & Environment

- Use **virtual environments** — each project gets its own isolated environment.
- Document dependencies in `requirements.txt`.
- Prefer **standard library** solutions over external packages when practical.
- Organize imports in this order:
  1. Standard library
  2. Third-party packages
  3. Local application modules

---

## Maintainability Principles

- **No duplicated code** — extract reusable functions, but don't over-engineer early.
- **No obfuscation** — optimize for readability before cleverness.
- A new developer should be able to: read the code, understand its purpose, run
  the tests, and safely make changes.
- Include **examples** when introducing new concepts or patterns.
- Format and lint code before submitting for review.

---

## Architecture Notes

| Item | Value |
|------|-------|
| OS | Windows 11 |
| CPU | Intel Core Ultra 7 165U (12 cores, 14 logical) |
| RAM | 32 GB |
| Python | 3.12 |
| IDE | Visual Studio Code with GitHub Copilot |
| Auth | Salesforce CLI (`sf org display`) |
| HTTP | `requests` library with session management |

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
| 0 | `backlog-gate.chatmode.md` | Confirm the idea is not already in §8.4–§8.6. |
| 1 | `capability-planner.chatmode.md` or `scope-change.agent.md` | Size and clarify the change. |
| 2 | `release-pr-planner.chatmode.md` | Slice the work into safe, ordered PRs. |
| 3 | `business-analyst.agent.md` | Produce approved Functional Requirements when needed. |
| 4 | `architect.agent.md` | Produce module-level design. |
| 5 | `team-lead.agent.md` | Produce granular implementation tasks. |
| 6 | `dev-manager.agent.md` | Execute tasks through the `dev` agent. |
| 7 | `docstring-auditor.agent.md` | Review and improve code docstrings. |
| 8 | `doc-writer.agent.md` or `docs-update.prompt.md` | Update project documentation. |
| 9 | `pre-commit-check.agent.md` or `pre-commit-check.chatmode.md` | Run the full quality gate. |
| 10 | `code-reviewer.agent.md` or `review.prompt.md` | Review completed changes. |
| 11 | `pr-merge.chatmode.md` | Prepare commit and PR text, then push after approval. |

Never skip step 4 (tests green) before step 5 (docs update).
Never skip step 6 (quality gate) before step 7 (review).


##  Canonical Quality Gate

ruff format --check src tests scripts
ruff check src tests scripts
mypy
bandit -c pyproject.toml -r src scripts --exclude scripts/archive,tests
python -m detect_secrets scan --baseline .secrets.baseline
pytest --tb=short -q
pytest --cov=src --cov=scripts --cov-report=term-missing --cov-fail-under=90

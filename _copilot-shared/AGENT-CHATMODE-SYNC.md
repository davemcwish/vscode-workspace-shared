# Agent / Chatmode Sync Rules

## Why Two Formats Exist

GitHub Copilot supports two ways to activate custom AI behaviours:

- **`.agent.md` files** — used by some Copilot setups (VS Code agent mode, API callers).
- **`.chatmode.md` files** — used by other setups (the Copilot Chat dropdown in some VS Code versions and enterprise configurations).

For any behaviour that must be available in **both** entry points, two files are
maintained in parallel — one agent, one chatmode. They must always contain the
same phases, rules, checklists, and safety carve-outs. **Only the frontmatter
format differs.**

## The Maintenance Rule

> **Whenever either file in a pair changes, update the other file in the same
> commit. This is a mandatory step, not optional. It is part of the Definition
> of Done for every PR.**

If you are unsure whether a file has a counterpart, check the pair table below.

## Pair Inventory

| Agent file | Chatmode file | Sync status |
| --- | --- | --- |
| `agents/critical-thinking.agent.md` | `chatmodes/critical-thinking.chatmode.md` | ✅ Paired (divergent) |
| `agents/pre-commit-check.agent.md` | `chatmodes/pre-commit-check.chatmode.md` | ✅ Paired (divergent) |
| `agents/debug.agent.md` | `chatmodes/debug.chatmode.md` | ✅ Paired (divergent) |
| `agents/doc-writer.agent.md` | `chatmodes/doc-writer.chatmode.md` | ✅ Paired (identical) |
| `agents/docstring-auditor.agent.md` | `chatmodes/docstring-review.chatmode.md` | ✅ Paired (divergent) |
| `agents/architect.agent.md` | *(no chatmode — agent only)* | — |
| `agents/business-analyst.agent.md` | *(no chatmode — agent only)* | — |
| `agents/code-reviewer.agent.md` | *(no chatmode — agent only)* | — |
| `agents/dev.agent.md` | *(no chatmode — agent only)* | — |
| `agents/dev-manager.agent.md` | *(no chatmode — agent only)* | — |
| `agents/Explore.agent.md` | *(no chatmode — agent only)* | — |
| `agents/scope-change.agent.md` | *(no chatmode — agent only)* | — |
| `agents/team-lead.agent.md` | *(no chatmode — agent only)* | — |
| *(no agent)* | `chatmodes/accessibility-review.chatmode.md` | — |
| *(no agent)* | `chatmodes/backlog-gate.chatmode.md` | — |
| *(no agent)* | `chatmodes/capability-planner.chatmode.md` | — |
| *(no agent)* | `chatmodes/dependency-manager.chatmode.md` | — |
| *(no agent)* | `chatmodes/infra-guide.chatmode.md` | — |
| *(no agent)* | `chatmodes/pr-merge.chatmode.md` | — |
| *(no agent)* | `chatmodes/release-pr-planner.chatmode.md` | — |
| *(no agent)* | `chatmodes/sf-safe-ops.chatmode.md` | — |
| *(no agent)* | `chatmodes/test-engineer.chatmode.md` | — |
| *(no agent)* | `chatmodes/transcript-extractor.chatmode.md` | — |
| *(no agent)* | `chatmodes/website-launch-planner.chatmode.md` | — |

## How to Add a New Paired Mode

- Decide whether the behaviour is needed in both agent and chatmode form.
  If yes, create both files at the same time.
- Add a SYNC NOTE comment near the top of each file:

```markdown
<!-- SYNC NOTE: Kept intentionally in sync with [counterpart filename].
Some Copilot setups use agent files; others use chatmode files.
Both files must always be identical in behaviour, phases, rules, and
checklists. Any change to either file MUST be applied to BOTH files
in the same commit. See _copilot-shared/AGENT-CHATMODE-SYNC.md. -->
```

- Add the pair to the table above.
- Update this file in the same commit.

## How to Check Sync Status

Run a quick manual diff between the paired files whenever you change one:

```powershell
# PowerShell — compare behaviour sections only (skip frontmatter)
(Get-Content ".github\agents\pre-commit-check.agent.md") -notmatch "^---$|^name:|^description:|^tools:|^agents:" |
  Compare-Object -ReferenceObject $_ `
                 -DifferenceObject ((Get-Content ".github\chatmodes\pre-commit-check.chatmode.md") -notmatch "^---$|^description:|^tools:")
```

Or open both files side-by-side in VS Code (`Ctrl+\`) and scan manually.

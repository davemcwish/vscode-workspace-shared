# Agent / Chatmode Sync Rules

## Why Two Formats Exist

GitHub Copilot supports two ways to activate custom AI behaviours:

- **`.agent.md` files** - used by some Copilot setups (VS Code agent mode, API callers).
- **`.chatmode.md` files** - used by other setups (the Copilot Chat dropdown in some VS Code versions and enterprise configurations).

For any behaviour that must be available in **both** entry points, two files are
maintained in parallel - one agent, one chatmode. They must always contain the
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
| `agents/architect.agent.md` | *(no chatmode - agent only)* | - |
| `agents/business-analyst.agent.md` | *(no chatmode - agent only)* | - |
| `agents/code-reviewer.agent.md` | *(no chatmode - agent only)* | - |
| `agents/dev.agent.md` | *(no chatmode - agent only)* | - |
| `agents/dev-manager.agent.md` | *(no chatmode - agent only)* | - |
| `agents/explore.agent.md` | *(no chatmode - agent only)* | - |
| `agents/scope-change.agent.md` | *(no chatmode - agent only)* | - |
| `agents/team-lead.agent.md` | *(no chatmode - agent only)* | - |
| *(no agent)* | `chatmodes/accessibility-review.chatmode.md` | - |
| *(no agent)* | `chatmodes/backlog-gate.chatmode.md` | - |
| *(no agent)* | `chatmodes/capability-planner.chatmode.md` | - |
| *(no agent)* | `chatmodes/dependency-manager.chatmode.md` | - |
| *(no agent)* | `chatmodes/infra-guide.chatmode.md` | - |
| *(no agent)* | `chatmodes/pr-merge.chatmode.md` | - |
| *(no agent)* | `chatmodes/release-pr-planner.chatmode.md` | - |
| *(no agent)* | `chatmodes/sf-safe-ops.chatmode.md` | - |
| *(no agent)* | `chatmodes/test-engineer.chatmode.md` | - |
| *(no agent)* | `chatmodes/transcript-extractor.chatmode.md` | - |
| *(no agent)* | `chatmodes/website-launch-planner.chatmode.md` | - |

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
# PowerShell - compare behaviour sections only (skip frontmatter)
(Get-Content ".github\agents\pre-commit-check.agent.md") -notmatch "^---$|^name:|^description:|^tools:|^agents:" |
  Compare-Object -ReferenceObject $_ `
                 -DifferenceObject ((Get-Content ".github\chatmodes\pre-commit-check.chatmode.md") -notmatch "^---$|^description:|^tools:")
```

Or open both files side-by-side in VS Code (`Ctrl+\`) and scan manually.

## Tool Reference

The `tools:` line in the frontmatter declares which capabilities the AI is
allowed to use while that agent or chatmode is active. Keep it **least
privilege** - grant only what the artifact's task actually needs - **but
sufficient** - if the body asks the AI to write files, run tests, or push git,
the matching tool must be present or the action silently fails.

### One canonical vocabulary, two linter registries (read this first)

There is **one** canonical set of VS Code tool names. Both `.agent.md` (the
current "custom agent" format) and `.chatmode.md` (the legacy "chat mode"
format) run on the same Copilot Chat runtime, which uses those names. The full
canonical list lives in
`docs/canonical-vscode-tool-names.md`.

What trips people up is that the **editor's frontmatter linter** validates the
two file types against **different tool registries**:

| Capability | `.agent.md` (current registry) | `.chatmode.md` (legacy registry) |
| --- | --- | --- |
| Read files | `read` | *(implicit - reading is always on; no token)* |
| Search | `search` | `search` (also `search/codebase`, `search/fileSearch`, ...) |
| Create / edit files | `edit` | `edit` (also `edit/editFiles`, `edit/createFile`, ...) |
| Run terminal / tasks / tests | `execute` (canonical `execute/runInTerminal`) | `runCommands/runInTerminal` (legacy alias only) |
| Track a to-do list | `todos` | `todos` |
| Delegate to a sub-agent | `agent` (+ `agents: [...]`) | *(not available)* |

**Empirically confirmed against this workspace's linter:**

- The to-do tool is **`todos`** (plural). `todo` is a typo. The agent linter
  tolerates `todo`, but the canonical runtime name is `todos`, so always write
  `todos`.
- The chatmode (legacy) linter does **not** know the `read` or `execute`
  toolsets, nor their qualified forms (`read/readFile`, `execute/runInTerminal`).
  In a chatmode, omit `read` (reading is implicit) and use the legacy terminal
  alias `runCommands/runInTerminal` instead of `execute/*`.
- The chatmode linter **does** accept `search`, `edit`, their qualified forms
  (`search/codebase`, `edit/editFiles`, ...), and `todos`.
- If an `.agent.md` declares `agents: [...]` (sub-agent delegation, e.g.
  `explore`), it **must** also list the `agent` toolset, or the delegation
  silently fails. `agent` / `agents` exist only in the agent format.
- A `#word` anywhere in a chatmode **body** (even inside a code fence) is parsed
  as a tool reference. Write `# word` (with a space) or avoid the literal `#`
  to stop false `Unknown tool` errors - see `pr-merge.chatmode.md` for the
  `Closes #` example.

> **Forward direction:** chat modes are now called *custom agents* in current
> VS Code. Prefer `.agent.md` with canonical names for new work; keep the paired
> `.chatmode.md` on the legacy-compatible tokens above so the editor stays free
> of false errors.

Because the sync test (`tests/test_agent_chatmode_sync.py`) strips the **entire**
frontmatter before comparing paired files, a paired agent and chatmode will
legitimately have **different** `tools:` lines. That is expected and does not
break the pairing gate.

### Tools currently used in this workspace

| Token (agent / chatmode) | What it lets the AI do | Typical artifacts |
| --- | --- | --- |
| `read` / *(implicit)* | Open and read workspace files | every artifact |
| `search` / `search` | Semantic search, file glob, text grep | every artifact |
| `edit` / `edit` | Create and modify files | authoring modes (architect, dev, doc-writer, capability-planner, test-engineer, ...) |
| `execute` / `runCommands/runInTerminal` | Run shell commands, tasks, `sanity.bat`, git, pytest | pipeline modes (pre-commit-check, debug, dependency-manager, pr-merge, test-engineer) |
| `todos` / `todos` | Track multi-step plans in the to-do list | long-running planning agents |
| `agent` / *(n/a)* | Invoke a declared sub-agent (e.g. `explore`) | architect, business-analyst, team-lead, dev-manager |

### Least-privilege ladder

Pick the lowest rung that still lets the artifact finish its job:

1. **Advisory / read-only review** -> `['search']`
   (accessibility-review, backlog-gate, critical-thinking, release-pr-planner,
   sf-safe-ops).
2. **Authoring** (produces or edits files) -> add `edit`
   (capability-planner, docstring-review, infra-guide, transcript-extractor,
   website-launch-planner).
3. **Pipeline** (runs commands, tests, or git) -> add `execute`
   (agent) / `runCommands/runInTerminal` (chatmode)
   (pre-commit-check, debug, dependency-manager, doc-writer, pr-merge,
   test-engineer).
4. **Orchestration** (delegates to a sub-agent) -> add `agent` and a matching
   `agents: [...]` line (**agent format only**).

### Other canonical tools available for future use

The tokens above are the subset this workspace currently needs. The full
canonical catalogue (the authoritative source for exact spelling) is in
`docs/canonical-vscode-tool-names.md`; the live, install-aware
list is the **Configure Tools** picker in the Chat view (it also shows tools
added by installed extensions and MCP servers, which are qualified as
`<server>/<tool>`). Common built-ins not yet used here:

| Canonical token | What it does | Example future use |
| --- | --- | --- |
| `search/usages` | Find references / definitions / implementations of a symbol | a refactor-impact agent |
| `search/changes` | List current source-control (git) changes | a review agent that inspects staged work |
| `search/listDirectory` | List files in a workspace directory | a project-mapping agent |
| `read/problems` | Pull Problems-panel diagnostics in as context | a lint-triage agent |
| `read/terminalLastCommand`, `read/terminalSelection` | Read terminal context | a shell-debugging agent |
| `execute/createAndRunTask` | Run a defined VS Code task (e.g. the sync task) | a build / deploy helper |
| `execute/getTerminalOutput` | Read output from a running command | a long-running-job monitor |
| `execute/testFailure` | Read details of the last failing test | a focused debug agent |
| `web/fetch` | Fetch and summarise a web page | a docs-research agent |
| `githubRepo`, `githubTextSearch` | Semantic / text search a GitHub repo or org | a cross-repo pattern finder |
| `browser` | Drive an integrated browser (navigate, click, screenshot) | a live website reviewer |
| `vscode/extensions`, `vscode/installExtension` | Find / install VS Code extensions | a workspace-setup agent |
| `vscode/VSCodeAPI` | Look up VS Code extension API docs | a VS Code extension author agent |
| `vscode/runCommand` | Run any VS Code command | a workspace-automation agent |
| `newWorkspace` | Scaffold a new project / workspace | a project-bootstrap agent |
| `edit/editNotebook`, `execute/runNotebookCell`, `read/getNotebookSummary` | Author and run Jupyter notebooks | a data-analysis agent |
| `agent/runSubagent` | Invoke an isolated sub-agent run | any orchestrating agent |

When adding any of these, copy the exact token from the canonical list or the
Configure Tools picker (names changed in VS Code 1.105, which introduced
fully-qualified names such as `search/codebase`). Apply the agent-vs-chatmode
registry rules above, and update the artifact's `tools:` line in the same commit
that adds the behaviour needing it.

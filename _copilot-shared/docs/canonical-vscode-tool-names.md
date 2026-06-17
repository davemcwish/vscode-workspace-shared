# Canonical VS Code Built-in Tool Names

This is the reference for the tool names that go in the `tools:` array of a
custom agent (`.agent.md`), legacy chat mode (`.chatmode.md`), or prompt file
(`.prompt.md`).

Use the names exactly as written below, **without** a leading `#`. The VS Code
UI and documentation show tools as `#toolName` because `#` is the chat *mention*
syntax you type in the chat box. In YAML frontmatter you drop the `#`.

```yaml
# Correct - YAML frontmatter
tools: ['read', 'edit', 'search', 'execute', 'todos']
```

> **Companion document:** for how these names are applied across this
> workspace's agents and chat modes - including which subset the legacy
> chat-mode editor linter accepts - see
> `_copilot-shared/AGENT-CHATMODE-SYNC.md` (the "Tool Reference" section).

---

## 1. Two kinds of name: tool sets and tools

Every entry below is either:

- a **tool set** - a broad capability that bundles several related tools
  (for example `read`, `edit`, `search`, `execute`); or
- a **tool** - a single, fully-qualified capability inside a set
  (for example `read/readFile`, `execute/runInTerminal`).

You can list either form. Listing a tool set grants everything inside it;
listing a fully-qualified tool grants just that one capability. Fully-qualified
names were introduced in VS Code 1.105 to avoid clashes between built-in tools
and tools added by extensions or MCP servers (those are qualified the same way,
for example `github/github-mcp-server/list_issues`).

---

## 2. Canonical tool reference

The authoritative source is the VS Code "AI features in VS Code cheat sheet"
(the "Chat tools" section) at
<https://code.visualstudio.com/docs/agents/reference/ai-features-cheat-sheet>.

### Delegation

| Name | Type | What it does |
| --- | --- | --- |
| `agent` | Tool set | Delegate tasks to other agents. |
| `agent/runSubagent` | Tool | Run a task in an isolated sub-agent context. |

### Reading context

| Name | Type | What it does |
| --- | --- | --- |
| `read` | Tool set | Read files and workspace / terminal / notebook context. |
| `read/readFile` | Tool | Read a file from the workspace. |
| `read/problems` | Tool | Add Problems-panel issues as context. |
| `read/terminalLastCommand` | Tool | Get the last terminal command and its output. |
| `read/terminalSelection` | Tool | Get the current terminal selection. |
| `read/getNotebookSummary` | Tool | Get a notebook's cell list and details. |
| `read/readNotebookCellOutput` | Tool | Read output from a notebook cell execution. |

### Searching

| Name | Type | What it does |
| --- | --- | --- |
| `search` | Tool set | Search for files and content in the current workspace. |
| `search/codebase` | Tool | Code search to find relevant context. |
| `search/fileSearch` | Tool | Find files by glob pattern and return paths. |
| `search/textSearch` | Tool | Find text in files. |
| `search/listDirectory` | Tool | List files in a workspace directory. |
| `search/usages` | Tool | Find All References, Find Implementation, and Go to Definition. |
| `search/changes` | Tool | List source-control changes. |

### Editing

| Name | Type | What it does |
| --- | --- | --- |
| `edit` | Tool set | Enable workspace modifications. |
| `edit/createFile` | Tool | Create a new file in the workspace. |
| `edit/createDirectory` | Tool | Create a new directory in the workspace. |
| `edit/editFiles` | Tool | Apply edits to files in the workspace. |
| `edit/editNotebook` | Tool | Edit a notebook. |

### Executing

| Name | Type | What it does |
| --- | --- | --- |
| `execute` | Tool set | Execute code and applications on the machine. |
| `execute/runInTerminal` | Tool | Run a shell command in the integrated terminal. |
| `execute/getTerminalOutput` | Tool | Get output from a running terminal command. |
| `execute/createAndRunTask` | Tool | Create and run a new VS Code task. |
| `execute/runNotebookCell` | Tool | Run a notebook cell. |
| `execute/testFailure` | Tool | Get unit-test failure information. |

### Planning

| Name | Type | What it does |
| --- | --- | --- |
| `todos` | Tool | Track progress for a chat request with a to-do list. Note: **plural** `todos`, not `todo`. |

### Web and GitHub

| Name | Type | What it does |
| --- | --- | --- |
| `web` | Tool set | Access web content. |
| `web/fetch` | Tool | Fetch the content from a web page. |
| `githubRepo` | Tool | Semantic-search a GitHub repository for relevant source snippets. |
| `githubTextSearch` | Tool | Text-search a GitHub repository or organisation. |

### VS Code and workspace

| Name | Type | What it does |
| --- | --- | --- |
| `newWorkspace` | Tool | Create a new workspace. |
| `browser` | Tool set | Experimental integrated-browser control: navigate, read page content, screenshots, click / type / hover / drag, dialogs. Requires browser chat tools to be enabled. |
| `selection` | Tool / context | Get the current editor selection. Available only when text is selected. |
| `vscode/runCommand` | Tool | Run a VS Code command. |
| `vscode/extensions` | Tool | Search for and ask about VS Code extensions. |
| `vscode/installExtension` | Tool | Install a VS Code extension. |
| `vscode/getProjectSetupInfo` | Tool | Provide project scaffolding instructions / configuration. |
| `vscode/askQuestions` | Tool | Ask clarifying questions using the interactive questions carousel. |
| `vscode/VSCodeAPI` | Tool | Answer questions about VS Code functionality and extension development. |

---

## 3. How to write the `tools:` array

### Broad and concise (recommended default)

Granting tool sets keeps the frontmatter short and readable:

```yaml
tools: ['read', 'edit', 'search', 'execute', 'todos']
```

### Fully-qualified (use when the linter rejects broad names)

If your VS Code / Copilot Chat version flags a broad tool-set name as unknown,
switch to the explicit tools you actually need:

```yaml
tools:
  - read/readFile
  - read/problems
  - search/codebase
  - search/fileSearch
  - search/textSearch
  - search/usages
  - edit/createFile
  - edit/editFiles
  - execute/runInTerminal
  - execute/testFailure
  - todos
```

Trim the list to the artefact's job. A planning or research agent should omit
`edit/*` and `execute/*`; an implementation agent needs them.

---

## 4. Recommended tool profiles

### Read-only planning / research agent

```yaml
---
description: Generate an implementation plan without modifying files.
tools:
  - read/readFile
  - read/problems
  - search/codebase
  - search/fileSearch
  - search/listDirectory
  - search/textSearch
  - search/usages
  - search/changes
  - todos
---
```

### Implementation agent

```yaml
---
description: Implement code changes and verify them.
tools: ['read', 'search', 'edit', 'execute', 'todos']
---
```

---

## 5. Custom agents versus chat modes (the version-drift story)

VS Code renamed "custom chat modes" to "custom agents" in version 1.106. Older
installs and older `.chatmode.md` files still exist, so you will see both terms.

- For a **custom agent / chat mode**, the `tools:` field is a list of tool or
  tool-set names. It can include built-in tools, tool sets, MCP tools, and
  extension-contributed tools. A whole MCP server is included with
  `<server-name>/*`.
- If an agent delegates to other agents (an `agents: [...]` field), it must also
  list the `agent` tool set, or the delegation fails.

---

## 6. Why you might see "Unknown tool 'read'" or "Unknown tool 'execute'"

`read` and `execute` are valid built-in tool sets. If the editor still flags
them as unknown, the usual causes are:

1. **Schema / runtime mismatch.** The Markdown diagnostics may validate against
   an older tool registry than the installed Copilot Chat runtime. This is why a
   `.chatmode.md` file can reject `read` or `execute` while a `.agent.md` file
   accepts them in the same workspace.
2. **Version mismatch.** Tool names and features have moved between VS Code
   releases (chat modes became custom agents in 1.106). A file written for one
   version may not validate in another.
3. **Tool not available.** A referenced built-in, MCP, or extension tool may not
   be installed or enabled in that environment.
4. **The `todo` / `todos` typo.** The planning tool is `todos` (plural).
5. **Broad name versus fully-qualified name.** Switching to explicit names such
   as `read/readFile` and `execute/runInTerminal` is the safest remediation.

---

## 7. Prompt-file frontmatter (`.prompt.md`)

Prompt files use the same `tools:` field, but their **other** frontmatter
attributes differ from agents, and they have drifted between VS Code versions.
The list below reflects the VS Code 1.105.1 editor diagnostic. **Follow your
installed version's diagnostic over the online docs**, which describe later
releases.

### Supported in 1.105.1 prompt files

| Attribute | Meaning |
| --- | --- |
| `description` | Short, user-friendly summary shown in prompt discovery. |
| `mode` | Chat mode to use when the prompt runs (`ask`, `edit`, `agent`, or a custom chat mode). |
| `model` | Language model to use when running the prompt. |
| `tools` | Tools or tool sets available to the prompt (same names as Section 2). |

### Not supported in 1.105.1 prompt files

| Attribute | Use instead |
| --- | --- |
| `name` | Omit it - the slash command comes from the filename (`security-review.prompt.md` becomes `/security-review`). |
| `agent` | Use `mode`. |
| `argument-hint` | Put usage guidance in the prompt body. |
| `handoffs` | Custom-agent feature, not a prompt-file attribute. |
| `target` | Custom-agent metadata, not for 1.105.1 prompt files. |
| `applyTo` | Instruction-file (`.instructions.md`) attribute, not for prompt files. |
| `allowed-tools` | Not VS Code prompt-file syntax (it belongs to other CLI / Copilot formats). |

> **Version-drift note:** the current online docs list `name`, `argument-hint`,
> and `agent` as valid prompt-file fields, because they describe the post-1.106
> "custom agents" terminology. For VS Code 1.105.1, trust the diagnostic above.

### 1.105.1-compatible prompt-file template

```yaml
---
description: 'Short description shown in VS Code prompt discovery'
mode: 'agent'
model: GPT-5
tools:
  - search/codebase
  - search/textSearch
  - read/readFile
  - read/problems
  - todos
---
```

---

## 8. Sources

- VS Code - AI features in VS Code cheat sheet:
  <https://code.visualstudio.com/docs/agents/reference/ai-features-cheat-sheet>
- VS Code - Use tools in chat:
  <https://code.visualstudio.com/docs/chat/chat-tools>
- VS Code - Custom agents in VS Code:
  <https://code.visualstudio.com/docs/agent-customization/custom-agents>
- VS Code - Use prompt files in VS Code:
  <https://code.visualstudio.com/docs/agent-customization/prompt-files>
- VS Code - September 2025 release notes (version 1.105), fully-qualified tool
  names: <https://code.visualstudio.com/updates/v1_105>

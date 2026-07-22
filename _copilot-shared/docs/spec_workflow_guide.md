# Spec Workflow Guide

A step-by-step guide to using the agent-based development workflow in this
project. This system lets you go from a plain-English idea to implemented,
tested Python code - without needing to understand every technical detail
yourself.

## What Is This?

This project uses a chain of AI "agents" (think of them as specialist
assistants) that each handle one part of the development process. You describe
what you need in plain language, and the agents progressively turn it into
formal requirements, designs, implementation tasks, and working code.

**You don't need to be a developer to start the process.** The first agent
(`scope-change`) is specifically designed to guide non-technical users.

## The Agent Pipeline

Each agent reads the output of the previous agent. You run them in order:

| Step | Agent | What It Does | What It Produces |
| --- | --- | --- | --- |
| 0 | `scope-change` | Guides you through describing your need | `initial_user_request.md` |
| 1 | `business-analyst` | Turns your request into formal User Stories | `fr.md` (one per story) |
| 2 | `architect` | Designs which modules and functions to change | `design.md` |
| 3 | `team-lead` | Breaks the design into copy-paste coding tasks | `task-*.md` + `checklist.md` |
| 4 | `dev-manager` | Executes tasks one by one via the `dev` agent | Working code + updated checklist |
| 5 | `doc-writer` | Scans changes and updates all affected docs | Updated guides, README, changelog |
| 6 | `code-reviewer` | Reviews code for quality, security, standards | Review report (approve/reject) |
| 7 | `pre-commit-check` | Runs full quality gate (ruff, mypy, tests, etc.) | Pass/fail report |

After Step 7 passes, you commit and push.

## Where Things Live

```text
.github/
+-- agents/                    # Agent definitions (the "brains")
|   +-- scope-change.agent.md
|   +-- business-analyst.agent.md
|   +-- architect.agent.md
|   +-- team-lead.agent.md
|   +-- dev-manager.agent.md
|   +-- dev.agent.md
+-- skills/                    # Coding standards agents must follow
|   +-- python.skill.md
|   +-- salesforce.skill.md
|   +-- testing.skill.md
|   +-- cli.skill.md
|   +-- security.skill.md
|   +-- html-css.skill.md
+-- .spec-workflow/            # Templates for generated documents
|   +-- fr_template.md
|   +-- task_file_template.md
|   +-- checklist_file_template.md
+-- chatmodes/                 # Interactive chat personas
+-- prompts/                   # Reusable prompt shortcuts
+-- instructions/              # Per-file-type coding rules

architecture.md                # Project module map (agents read this)
requirements/                  # Generated requirements & tasks (per feature)
```

## How to Use It (Step by Step)

### Step 0: Describe What You Need

Open VS Code Copilot Chat and type:

```text
@scope-change I need to extract [describe your need here]
```

**Example:**

```text
@scope-change I need to extract a list of all active users with their
last login date from Production, as a CSV file, so I can report on
licence usage.
```

The agent will ask you clarifying questions:

- What Salesforce objects are involved?
- What fields do you need?
- Which org (UAT, SIT, Production)?
- How often will you run this?
- Any safety concerns?

Answer in plain English - you don't need to know API field names. Once you
approve the summary, it saves to `requirements/REQ-XXX/initial_user_request.md`.

### Step 1: Generate User Stories

```text
@business-analyst Process ./requirements/REQ-XXX/initial_user_request.md
```

The agent reads your scope document, checks it doesn't duplicate existing
backlog items, and drafts User Stories with acceptance criteria. It will ask
you to approve before saving.

**Output:** `requirements/REQ-XXX/01/fr.md` (and `02/fr.md`, etc. if multiple
stories).

### Step 2: Design the Solution

```text
@architect Design ./requirements/REQ-XXX/
```

The agent reads each User Story, looks at the project architecture and skill
files, and produces a design document specifying:

- Which Python modules change
- What new functions are needed
- What tests to write
- Security considerations

**Output:** `requirements/REQ-XXX/01/design.md`

### Step 3: Generate Implementation Tasks

```text
@team-lead Decompose ./requirements/REQ-XXX/01/
```

The agent reads the design, scans the actual source code, and produces
numbered task files with exact copy-paste Python code. It also creates a
checklist tracking the execution order.

**Output:**

- `requirements/REQ-XXX/01/task-001-query-helper.md`
- `requirements/REQ-XXX/01/task-002-cli-args.md`
- `requirements/REQ-XXX/01/task-003-tests.md`
- `requirements/REQ-XXX/01/checklist.md`

### Step 4: Execute the Tasks

```text
@dev-manager Execute ./requirements/REQ-XXX/01/checklist.md
```

The Dev Manager loops through each task, handing it to the `dev` agent which
makes the actual code changes and runs tests. If anything fails, it stops
immediately and reports the error.

**Output:** Working code changes in `scripts/`, `src/`, and `tests/`.

### Step 5: Update Documentation

```text
@doc-writer Update docs for the changes in REQ-XXX
```

The agent scans what changed (via `git diff`), identifies all affected
documentation, and updates guides, README, CONTRIBUTING, architecture, and
changelog automatically. It follows the beginner-friendly writing rules from
`.github/instructions/docs.instructions.md`.

**Output:** Updated Markdown files across `docs/`, `README.md`, `Changelog.md`.

### Step 6: Code Review

```text
@code-reviewer Review the changes on this branch
```

The agent performs a thorough review checking correctness, security, style,
testing, and adherence to project skills. It produces a structured report with
a verdict (APPROVE / REQUEST CHANGES) and categorised findings (Critical,
Suggestions, Nits).

**Note:** This agent is designed to use a different model for independent
perspective. Configure it in your VS Code Copilot settings if needed.

**Output:** Review report with actionable feedback.

### Step 7: Pre-Commit Quality Gate

```text
@pre-commit-check Run all quality checks
```

The agent runs every quality check in sequence (ruff, mypy, bandit,
detect-secrets, pytest) and produces a pass/fail report. This is the final
gate - nothing gets committed until this passes.

**Output:** Quality gate report (PASS or FAIL with specific errors).

### Step 8: Commit and Push

Once Step 7 shows all green, commit and push your changes. Use the existing
`pr-merge` chatmode if you want help writing commit messages.

## Skills - What Are They?

Skills are short documents in `.github/skills/` that tell agents *how* to write
code for this project. They cover:

| Skill File | What It Defines |
| --- | --- |
| `python.skill.md` | Python 3.13 style, naming, imports, logging rules |
| `salesforce.skill.md` | How to authenticate, query SOQL, download files |
| `testing.skill.md` | pytest conventions, fixtures, mocking, cross-platform |
| `cli.skill.md` | argparse patterns, standard arguments, help text |
| `security.skill.md` | Secrets handling, path safety, redaction rules |
| `html-css.skill.md` | Static HTML report generation (no frameworks) |

You don't need to read these yourself - the agents read them automatically.
But if you're curious about why code looks a certain way, the skill files
explain the rules.

## Frequently Asked Questions

### Do I need to run every agent?

For small changes, you might skip straight to coding with standard Copilot.
The agent pipeline is most useful for:

- New scripts or modules
- Changes touching multiple files
- Work you want to hand off to someone else
- Complex Salesforce integrations

### What if an agent asks a question I can't answer?

Say "I don't know" - the agent will make a reasonable assumption and flag it
for review. You can always adjust later.

### What if the dev agent fails?

The dev-manager stops immediately and shows the error. You can either:

- Fix the issue manually and re-run from where it stopped.
- Ask standard Copilot to help debug.
- Adjust the task file and re-run.

### Can I edit the generated documents?

Yes! The generated `fr.md`, `design.md`, and task files are just Markdown.
Edit them freely before running the next agent.

### Where do I find existing requirements?

Look in the `requirements/` folder at the project root. Each subfolder is one
feature request.

## Quick Reference Card

```text
@scope-change    -> "I have an idea, help me describe it"
@business-analyst -> "Turn my description into formal requirements"
@architect       -> "Design which modules to change"
@team-lead       -> "Break the design into coding tasks"
@dev-manager     -> "Execute the tasks automatically"
@doc-writer      -> "Update all docs for what changed"
@code-reviewer   -> "Review my code for issues"
@pre-commit-check -> "Run all quality gates"
```

## Related Documentation

- [Running the Scripts](running-the-scripts-guide.md) - how to run existing
  scripts.
- [Contributing](../CONTRIBUTING.md) - how to submit changes.
- [PR Roadmap](pr-roadmap-section-8-4.md) - current backlog and progress.
- [Salesforce Admin Utilities Guide](salesforce-admin-utilities-guide.md) -
  full project documentation.

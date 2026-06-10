# Workflow: Docstring Writing

## Purpose

Use this workflow when you need to write docstrings for new or recently
modified Python code. It covers adding docstrings to new functions, updating
docstrings after code changes, and ensuring every claim is accurate.

This workflow is designed for beginners. It explains what to do, why each step
matters, and which Copilot assets to use at each stage.

## When To Use This Workflow

Use this workflow when you are:

- writing a new Python function, class, or module,
- modifying an existing function's parameters, return value, or behavior,
- adding a new CLI script that needs `parse_args()` and `main()` docstrings,
- adding complex test fixtures,
- completing a code change and need to document it before committing,
- writing docstrings as part of the standard change workflow (Step 7).

For remediating EXISTING docstrings that may be inaccurate, use
`workflows/docstring-remediation.workflow.md` instead.

For project documentation (guides, README, Changelog), use
`workflows/doc-writing.workflow.md` instead.

---

## Standards Reference

Before writing anything, load these files:

- `.github/skills/docstring.skill.md` - **all writing rules, accuracy rules,
  term tables, and the 1:1 audit method** (read this first)
- `.github/instructions/docstrings.instructions.md` - audience, accuracy,
  ground truth rules
- `.github/instructions/python.instructions.md` - Python coding standards
- `.github/instructions/salesforce.instructions.md` - Salesforce safety rules
- `.github/instructions/security.instructions.md` - secrets and PII rules

---

## Overview

```text
Read the implementation (establish ground truth)
  -> Identify what needs docstrings
  -> Load the writing standards
  -> Write each docstring (facts from code, prose for clarity)
  -> 1:1 audit every docstring against the code
  -> Beginner-friendliness pass
  -> Run quality checks
  -> Review the diff
  -> Report
```

---

## Step 0: Establish Ground Truth (Do This First)

> **Do this BEFORE writing any docstring. This is the single most important
> step for accuracy.**

For every function you will document, read its implementation to confirm:

1. **What parameters it accepts** - names, types, valid values, defaults.
2. **What it returns** - the actual type and meaning of the return value.
3. **What exceptions it raises** - trace the `raise` statements and unhandled
   propagations.
4. **What side effects it performs** - file writes, API calls, database
   mutations, logging.
5. **Whether it is read-only or mutating** - does it change external state?

Treat the implementation as the ONLY source of truth. Never rely on:

- a similar function's docstring (it may be wrong or different),
- what would make logical sense for a function with that name,
- what you think the function "should" do based on its context.

Rules:

- Never copy a docstring from a sibling function - similar functions often have
  legitimately different behavior.
- Never infer behavior from the function name alone.
- If the implementation is unclear, write a cautious docstring and flag the
  ambiguity. Do not fill the gap with invention.

---

## Step 1: Identify What Needs Docstrings

Determine which code needs new or updated docstrings.

**With Copilot:** ask the docstring-auditor agent or docstring-review chatmode
to discover gaps.

**Manually:** check every:

- new module (needs a module-level docstring),
- new class (needs a class docstring),
- new function or method (needs a full Google-style docstring),
- new CLI `parse_args()` and `main()` functions,
- new complex test fixtures,
- modified functions whose parameters, returns, or behavior changed.

---

## Step 2: Load the Writing Standards

Open and read `.github/skills/docstring.skill.md` before writing anything.

It contains the audience definition, the Two Jobs principle, accuracy rules,
ground truth methodology, beginner-friendly language rules with Salesforce and
Python term explanation tables, the 1:1 audit method, and Critical Constraints.

If you skip this step, you risk writing docstrings that are too technical,
inaccurate, or missing required sections.

---

## Step 3: Write Each Docstring

### The Two Jobs (Keep Them Separate)

1. **WHAT the code does** - parameters, returns, exceptions, side effects.
   Extract from the implementation (Step 0). This is fact, not prose.
2. **HOW to explain it** - beginner-friendly language, examples, domain context.
   Apply ONLY to facts confirmed in job 1.

Never let job 2 (prose) invent facts that belong to job 1 (code reality).

### Writing Checklist

For each function:

- [ ] Summary line - one sentence explaining what it does.
- [ ] "How it works" paragraph - for non-trivial algorithms.
- [ ] `Args` section - every parameter with type, purpose, valid values.
- [ ] `Returns` section - type and meaning (or describe side effect if `None`).
- [ ] `Raises` section - every exception the function raises.
- [ ] `Example` section - for any non-obvious function.
- [ ] Domain terms explained on first use (see term tables in the skill).
- [ ] Read-only vs mutating stated where relevant.
- [ ] PII/security implications mentioned where relevant.

### Style Rules

- Use Google-style docstrings.
- Plain English - write as if explaining to someone who has never coded.
- Short sentences. One idea per sentence.
- Active voice: "Returns a list of..." not "A list is returned by..."
- Expand every acronym on first use within each docstring.

---

## Step 4: 1:1 Audit Every Docstring Against the Code

> **Do this AFTER writing, BEFORE committing.**

For each docstring you wrote, perform a mechanical comparison:

- Every parameter in the code appears in the `Args` section (no omissions).
- Every item in the `Args` section exists in the code (no inventions).
- The `Returns` description matches the actual return value.
- The `Raises` section lists only exceptions the code actually raises.
- Side effects described match the actual side effects.

If anything fails this audit, fix the docstring - re-derive from the
implementation, not from what you "meant" to write.

---

## Step 5: Beginner-Friendliness Pass

After facts are correct, confirm the docstring meets the beginner bar:

- [ ] A smart colleague who has never coded could understand it.
- [ ] Salesforce terms are explained at first use (SOQL, org, alias, etc.).
- [ ] Python terms are explained at first use (decorator, monkeypatch, etc.).
- [ ] No unexplained abbreviations or acronyms.
- [ ] Examples show realistic usage.
- [ ] Safety implications are stated (PII, production, dry-run).

---

## Step 6: Run Quality Checks

```bash
ruff format --check src tests scripts
ruff check src tests scripts
mypy
pytest --tb=short -q
```

If any failure appears, fix it before proceeding.

---

## Step 7: Review the Diff

Confirm:

- [ ] Only docstrings and explanatory comments changed (or new code + its
      docstrings if writing during development).
- [ ] No invented parameters, returns, or exceptions.
- [ ] No secrets or PII in examples.
- [ ] Every technical term explained on first use.
- [ ] 1:1 audit passed.
- [ ] Beginner-friendliness pass completed.

---

## Step 8: Report

```text
Docstring Writing Summary

Functions Documented:  | Function | File | Type (new/updated) |
Ground Truth Method:   Implementation read for each function.
1:1 Audit Result:      No inventions, no omissions.
Quality Checks:        ruff / mypy / pytest - PASS or FAIL
```

---

## Done Checklist

- [ ] Ground truth established by reading each implementation (Step 0).
- [ ] Standards loaded (docstring.skill.md read first).
- [ ] All functions identified that need docstrings.
- [ ] Each docstring written with facts from implementation + beginner prose.
- [ ] 1:1 audit passed (no inventions, no omissions).
- [ ] Beginner-friendliness pass completed.
- [ ] Domain terms explained on first use.
- [ ] PII and safety context documented.
- [ ] No runtime behavior changed (if updating existing code).
- [ ] Quality checks pass.
- [ ] Summary produced.

---

## Copilot Assets for This Workflow

| Asset | When to use |
| --- | --- |
| `agents/docstring-auditor.agent.md` | Systematic audit and improvement |
| `chatmodes/docstring-review.chatmode.md` | Interactive docstring review session |
| `prompts/improve-docstrings.prompt.md` | Quick docstring improvement |
| `prompts/docstring-audit.prompt.md` | One-command accuracy audit |
| `skills/docstring.skill.md` | Writing standards reference (load before editing) |
| `instructions/docstrings.instructions.md` | Audience, accuracy, ground truth rules |
| `workflows/docstring-remediation.workflow.md` | For remediating existing inaccurate docstrings |
| `workflows/doc-writing.workflow.md` | For project documentation (guides, README) |

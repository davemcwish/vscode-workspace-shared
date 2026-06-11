---
applyTo: "**/*.ps1"
description: "PowerShell scripting standards for Windows compatibility."
---

# PowerShell Scripting Standards

## Character Encoding (CRITICAL)

- **Use only ASCII-safe characters** (code points 0x00-0x7F) in all `.ps1` files.
- Never use Unicode arrows (`->`, `<-`, `->`), tick marks (`[x]`, `[ ]`), em-dashes
  (` - `), or other non-ASCII symbols in strings, comments, or output.
- Use ASCII alternatives instead:

| Avoid (non-ASCII) | Use instead (ASCII) |
| ------------------ | ------------------- |
| `->` | `->` |
| `<-` | `<-` |
| `->` | `->` |
| `[x]` | `[OK]` |
| `[ ]` | `[FAIL]` |
| ` - ` (em-dash) | `--` |
| `...` (ellipsis) | `...` |
| `'` `'` (smart quotes) | `'` (straight) |
| `"` `"` (smart quotes) | `"` (straight) |

**Why:** Windows PowerShell 5.1 (the default shell on Windows 11) uses the
system's ANSI code page to parse `.ps1` files invoked via `powershell.exe
-File`. Non-ASCII characters saved as UTF-8 without a BOM are misinterpreted,
causing parse errors such as unterminated strings or missing closing braces.

## Script Structure

- Include a `<# .SYNOPSIS #>` comment-based help block at the top.
- Use `[CmdletBinding()]` on all scripts that accept parameters.
- Set `Set-StrictMode -Version Latest` and `$ErrorActionPreference = "Stop"`.
- Use `param()` blocks for all inputs - avoid positional-only parameters.

## Naming

- Use PascalCase for function names: `Sync-Folder`, `Get-SafePath`.
- Use PascalCase for parameters: `-RepoPath`, `-MainBranch`.
- Use `$camelCase` for local variables.
- Prefix private/internal helper functions with a verb: `Invoke-`, `Get-`, etc.

## Output & Logging

- Use `Write-Host` with `-ForegroundColor` for user-facing progress messages.
- Use `Write-Verbose` for detailed diagnostic output (visible with `-Verbose`).
- Use `Write-Warning` for recoverable issues.
- Use `Write-Error` or `throw` for fatal problems.
- Never use `Write-Output` for status messages (it pollutes the pipeline).

## Error Handling

- Prefer `try/catch` blocks around operations that can fail.
- When calling external tools (robocopy, git, sf), check `$LASTEXITCODE`.
- Provide actionable error messages that tell the user what to do next.

## Security

- Never embed credentials or tokens in scripts.
- Use `$env:VARIABLE_NAME` for secrets and document them in `.env.example`.
- Validate user-supplied paths before use - check `Test-Path` and reject
  path-traversal patterns.

## Compatibility

- Target Windows PowerShell 5.1 (ships with Windows 11).
- Do not use PowerShell 7+ syntax (`??=`, `?.`, ternary `? :` operator) unless
  the script explicitly requires pwsh and documents that requirement.
- Test scripts by running `powershell.exe -ExecutionPolicy Bypass -File <script>`
  to catch encoding and syntax issues early.

# build-chatmode-from-agent.ps1
# Regenerates doc-writer.chatmode.md from the known-good doc-writer.agent.md.
# The ONLY differences produced are: frontmatter, H1, and SYNC NOTE target.

$agentPath = "_copilot-shared\agents\doc-writer.agent.md"
$chatPath  = "_copilot-shared\chatmodes\doc-writer.chatmode.md"

# Known-good chatmode frontmatter (matches File 7). Verify this block if unsure.
# NOTE: .chatmode.md uses the LEGACY tool vocabulary, which differs from the
# .agent.md (new custom-agent) vocabulary. The agent file uses the simplified
# names ('read', 'edit', 'search', 'execute', 'todos'); the chatmode validator
# only accepts the granular names. doc-writer needs file edits plus the ability
# to run a script's --help (Phase 0), so the chatmode equivalent is
# 'edit', 'search', 'runCommands/runInTerminal'. See
# _copilot-shared/AGENT-CHATMODE-SYNC.md (Tool Reference) for both vocabularies.
$frontmatter = @'
---
description: "Interactively updates all project documentation after code changes. Scans what changed and updates relevant guides, README, CONTRIBUTING, and changelog. Verifies every CLI table against the script's own --help output."
tools: ['edit', 'search', 'runCommands/runInTerminal']
---
'@

# Read the agent file and strip its frontmatter (the first ---...--- block).
$raw = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $agentPath).Path, [System.Text.Encoding]::UTF8)
$body = $raw -replace '(?s)^\s*---.*?---\s*', ''

# Apply the two intended differences.
$body = $body -replace '# Doc Writer Agent', '# Doc Writer'
$body = $body -replace 'in sync with doc-writer\.chatmode\.md', 'in sync with doc-writer.agent.md'

# Assemble: frontmatter + blank line + body, ending in exactly one newline.
$out = ($frontmatter.TrimEnd() + "`r`n`r`n" + $body.TrimEnd() + "`r`n")

# Write UTF-8 WITHOUT BOM (avoids the mojibake/encoding issues you saw).
$full = (Resolve-Path -LiteralPath $chatPath).Path
[System.IO.File]::WriteAllText($full, $out, (New-Object System.Text.UTF8Encoding($false)))

Write-Host "Chatmode regenerated from agent." -ForegroundColor Green

# Microsoft Visual Studio Code

## Extensions

### List Installed Extensions

You can list the installed extensions via these commands

Unix:

```bash
code --list-extensions | xargs -L 1 echo code --install-extension
```

Windows (PowerShell, e. g. using Visual Studio Code's integrated Terminal):

```powershell
code.cmd --list-extensions | % { "- $_" }
```

### Installed Extensions For This Workspace. Correct 16.June.2026

- charliermarsh.ruff
- davidanson.vscode-markdownlint
- donjayamanne.githistory
- eamodio.gitlens
- esbenp.prettier-vscode
- financialforce.lana
- github.copilot
- github.copilot-chat
- github.remotehub
- github.vscode-github-actions
- graphql.vscode-graphql-syntax
- kevinrose.vsc-python-indent
- mechatroner.rainbow-csv
- ms-cst-e.vscode-devskim
- ms-dotnettools.vscode-dotnet-runtime
- ms-python.debugpy
- ms-python.mypy-type-checker
- ms-python.python
- ms-python.vscode-python-envs
- ms-vscode.azure-repos
- ms-vscode.notepadplusplus-keybindings
- ms-vscode.powershell
- ms-vscode.remote-repositories
- petipoua.llm-token-counter
- redhat.vscode-xml
- salesforce.agent-script-language-client
- salesforce.apex-language-server-extension
- salesforce.salesforce-vscode-slds
- salesforce.salesforcedx-einstein-gpt
- salesforce.salesforcedx-metadata-visualizer-vscode
- salesforce.salesforcedx-vscode
- salesforce.salesforcedx-vscode-agents
- salesforce.salesforcedx-vscode-apex
- salesforce.salesforcedx-vscode-apex-log
- salesforce.salesforcedx-vscode-apex-oas
- salesforce.salesforcedx-vscode-apex-replay-debugger
- salesforce.salesforcedx-vscode-apex-testing
- salesforce.salesforcedx-vscode-core
- salesforce.salesforcedx-vscode-expanded
- salesforce.salesforcedx-vscode-lightning
- salesforce.salesforcedx-vscode-lwc
- salesforce.salesforcedx-vscode-metadata
- salesforce.salesforcedx-vscode-org
- salesforce.salesforcedx-vscode-org-browser
- salesforce.salesforcedx-vscode-services
- salesforce.salesforcedx-vscode-soql
- salesforce.salesforcedx-vscode-ui-preview
- salesforce.salesforcedx-vscode-visualforce
- salesforce.sfdx-code-analyzer-vscode

### Installed Extension Locations

| OS | Location |
| --- | --- |
| Windows | %USERPROFILE%\.vscode\extensions |
| macOS | ~/.vscode/extensions |
| Linux | ~/.vscode/extensions |

### Extension Replication

On the source machine, you can export the list of installed extensions to a file:

```bash
code --list-extensions > extensions.txt
```

On the target machine, you can install the extensions from the file:

```bash
cat extensions.txt | xargs -L 1 code --install-extension
```

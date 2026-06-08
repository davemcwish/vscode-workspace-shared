---
description: "Safely update dependencies using pip-tools."
mode: agent
---

Help update dependencies using this project's pip-tools workflow.

Rules:

1. Do not hand-edit generated `.txt` files.
2. Edit `.in` files only for top-level dependency changes.
3. Use `pip-compile` to regenerate `.txt` files.
4. Use `pip install -r requirements-dev.txt` to install.
5. Run sanity checks after updating.
6. If a package is unavailable in the Ford mirror, suggest an available version
   constraint in the `.in` file.
7. Summarize dependency changes from `git diff`.

Commands to use:

```bat
pip-compile requirements.in
pip-compile requirements-dev.in
pip install -r requirements-dev.txt
ruff check src tests scripts
pytest
mypy src tests scripts
```

# Skill: Python 3.12+

## Language & Runtime

- Python 3.12+ on Windows 11.
- Virtual environment managed via `py -m venv .venv`.
- Dependencies pinned in `requirements.txt` and `requirements-dev.txt`.

## Style

- PEP 8 enforced by `ruff check` and `ruff format`.
- Type hints on all function parameters and return types.
- Imports ordered: standard library → third-party → local application modules.

## Naming

- Functions and variables: `snake_case`.
- Constants: `UPPER_SNAKE_CASE`.
- Classes: `PascalCase`.
- Private helpers: prefix with `_` (e.g., `_configure_logging`).
- Public CLI entry: always `parse_args` (never `_parse_args`).

## Functions

- Small and focused — one responsibility per function.
- Docstrings (Google style) explaining what, parameters, returns, raises, example.
- No `print()` in production code — use `logging` module.

## Error Handling

- Validate inputs; raise with descriptive messages.
- Never silently swallow exceptions.
- Use `RuntimeError` for environment issues (e.g., missing CLI tool).

## Logging

- Use `logging` module at appropriate levels (INFO, WARNING, ERROR).
- Include context: record IDs, counts, elapsed time.
- Redact tokens, passwords, session IDs before logging.

## File Structure

```text
scripts/          # Runnable CLI scripts (argparse, main guard)
src/              # Shared library (importable modules)
tests/            # pytest test files (test_*.py)
docs/             # Beginner-friendly Markdown guides
```

Adapt paths to match the actual project layout (check `architecture.md`).

## Validation Commands

```bash
ruff check .
ruff format --check .
mypy
pytest --tb=short -q
bandit -r src/ scripts/ -c pyproject.toml
```

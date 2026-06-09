# Skill: Testing (pytest)

## Framework

- pytest with fixtures defined in `tests/conftest.py`.
- Target ≥90% coverage for business logic and utility functions.
- Every bug fix includes a regression test.

## Conventions

- Test files: `tests/test_<module_name>.py`.
- Test functions: `test_<behaviour_being_tested>`.
- Test classes: `Test<LogicalGroup>` (no `__init__`).
- Use `importlib` for loading modules with spaces in filenames.

## Fixtures

- `tmp_path` — pytest built-in for temporary directories.
- `monkeypatch` — replace real dependencies with fakes during testing.
- `caplog` — capture log output for assertion.
- `capsys` — capture stdout/stderr for assertion.
- Project-specific fixtures should be defined in `tests/conftest.py`.

## Mocking Strategy

- Mock external calls (Salesforce API, subprocess, file I/O) at the boundary.
- Use `monkeypatch.setattr` for function replacement.
- Use `unittest.mock.patch` when monkeypatch doesn't fit.
- Never make real network calls in unit tests.

## Cross-Platform Awareness

- Tests must pass on both Windows (local dev) and Linux (GitHub Actions CI).
- Use `os.sep` or `pathlib.Path` for path assertions.
- Use `os.linesep` awareness or normalize before comparing multi-line output.
- Avoid hardcoded Windows paths in assertions.

## Validation Commands

```bash
pytest --tb=short -q
```

Coverage flags are defined in `pyproject.toml` under `[tool.pytest.ini_options]
addopts` and are inherited automatically by every `pytest` invocation.
Never pass `--cov`, `--cov-report`, or `--cov-fail-under` directly on the
command line — change the threshold in `pyproject.toml` only.

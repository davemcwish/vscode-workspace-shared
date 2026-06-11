---
applyTo: "tests/**/*.py"
description: "Pytest conventions and coverage expectations."
---

# Testing Standards

## Framework

- Use `pytest`. Do not introduce `unittest.TestCase` subclasses.
- Discover tests via files named `test_*.py` and functions named `test_*`.

## Structure

- Mirror `src/` layout under `tests/`.
- One test module per source module.
- Use `pytest` fixtures (in `conftest.py`) for shared setup.

## Coverage

- Maintain **>=90% line coverage** on `src/` and `scripts/`.
- Run via:

```bash
pytest --cov=src --cov=scripts --cov-report=term-missing --cov-fail-under=90
```

Note: `pyproject.toml` already sets `--cov=src --cov=scripts` in `addopts`,
so a plain `pytest` run collects coverage for both folders automatically.

## Test Quality

- Each test asserts one behavior. Name tests as
  `test_<unit>_<scenario>_<expected_result>`.
- Use `pytest.mark.parametrize` for input variants.
- Use `pytest`'s `monkeypatch` for environment variable and attribute patching.
- All test functions must include `-> None` return type annotation.

## Vertical Slices, Not Horizontal Layers

When writing tests for a new feature, use a **vertical-slice** approach:

```text
WRONG (horizontal - all tests first, then all implementation):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical - one test, one implementation, repeat):
  RED->GREEN: test1->impl1
  RED->GREEN: test2->impl2
  RED->GREEN: test3->impl3
```

- **Never write all tests first, then all implementation.** Tests written in
  bulk test imagined behaviour, not actual behaviour. They become insensitive
  to real changes.
- **One test -> one implementation -> repeat.** Each test responds to what you
  learned from the previous cycle.
- Tests should verify behaviour through **public interfaces**, not
  implementation details. If renaming an internal function breaks a test but
  behaviour hasn't changed, that test was testing implementation.
- A good test reads like a specification - it describes what the system does,
  not how it does it internally.

## Time Stability

- **Never** hard-code absolute dates in test constants (e.g. `date(2026, 6, 2)`).
- Use `date.today()` or compute dates relative to it so tests don't rot over time.
- If the function under test calls `date.today()` internally, test constants
  must also be relative to `date.today()`.
- Exception: fixed dates are acceptable only when the function under test
  accepts a date parameter and you are testing specific date logic (e.g.
  boundary conditions on a known date).

## Salesforce Isolation

- **Never** hit real orgs from tests. Patch `subprocess.run` during module
  load (to prevent CLI auth) and mock `requests.get` / `requests.Session`
  for all HTTP calls using `unittest.mock`.
- Provide a `sf_env` fixture in `conftest.py` that sets the required
  `SF_UAT_ALIAS` and `SF_PROD_ALIAS` environment variables for tests that
  exercise the config layer.

## Script Testing Pattern

Because the scripts under `scripts/` are standalone `.py` files (not
importable packages), load them with `importlib`:

```python
import importlib.util

spec = importlib.util.spec_from_file_location("module_name", SCRIPT_PATH)
mod = importlib.util.module_from_spec(spec)
with patch("subprocess.run", return_value=...):
    spec.loader.exec_module(mod)
```

Use `scope="module"` on the fixture so the expensive import runs only once
per test session.

## Documentation

- Each test module begins with a docstring describing the unit under test.
- Complex fixtures get docstrings explaining their setup.
- Wording must be suitable for:
  - a beginner or novice coder,
  - a beginner or novice Python developer,
  - a beginner Salesforce user.

## Test File Location

For standalone scripts in `scripts/`, place tests directly under `tests/` using
this naming pattern:

```text
tests/test_<script_name>.py
```

## Flask & WebSocket Testing

### Flask Test Client

Use the app factory pattern so each test gets an isolated application:

```python
import pytest
from frontend.app import create_app

@pytest.fixture
def app():
    """Create a test Flask application with testing config."""
    app = create_app({"TESTING": True, "SECRET_KEY": "test-secret"})
    return app

@pytest.fixture
def client(app):
    """Create a Flask test client for HTTP endpoint testing."""
    return app.test_client()
```

Test endpoints by calling the client directly - no real HTTP server needed:

```python
def test_get_config_returns_json(client) -> None:
    response = client.get("/api/config")
    assert response.status_code == 200
    assert response.content_type == "application/json"

def test_launch_job_rejects_unknown_script(client) -> None:
    response = client.post(
        "/api/jobs",
        json={"script": "evil.py", "org": "AXP_UAT"},
    )
    assert response.status_code == 400
    assert "Unknown script" in response.get_json()["error"]
```

### Flask-SocketIO Test Client

Use `flask_socketio.test_client` to test WebSocket events without a real
connection:

```python
from flask_socketio import SocketIO

@pytest.fixture
def socketio_client(app):
    """Create a SocketIO test client for WebSocket event testing."""
    socketio = SocketIO(app)
    return socketio.test_client(app)

def test_job_started_event_emitted(socketio_client, mocker) -> None:
    # Mock subprocess to avoid real execution
    mocker.patch("subprocess.Popen")
    socketio_client.emit("launch", {"script": "list_inactive_users.py"})
    received = socketio_client.get_received()
    assert any(msg["name"] == "job_started" for msg in received)
```

### Job Runner Unit Tests

Mock `subprocess.Popen` to test command construction and output parsing:

```python
def test_build_command_validates_alias(mocker) -> None:
    mock_popen = mocker.patch("subprocess.Popen")
    # Should raise ValueError for invalid alias
    with pytest.raises(ValueError, match="Invalid Salesforce alias"):
        launch_script("extract_object_data.py", org="rm -rf /")
```

### Test Pyramid for Frontend Features

| Layer | Quantity | What to Test |
| --- | --- | --- |
| Unit (70%) | Many | Command building, log parsing, config validation |
| Integration (25%) | Moderate | Flask routes + SocketIO events together |
| Manual (5%) | Few | Visual appearance, keyboard nav, responsive layout |
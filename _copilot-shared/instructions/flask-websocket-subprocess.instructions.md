---
applyTo: "frontend/**/*.py,src/**/job_runner*.py,**/app.py"
description: "Flask 3.x REST API, Flask-SocketIO WebSocket, and subprocess.Popen patterns for local web frontends."
---

# Flask, WebSocket & Subprocess Standards

## Scope

These rules apply when building local web-based frontends using:

- **Flask 3.x** - REST API endpoints
- **Flask-SocketIO** - real-time WebSocket communication
- **subprocess.Popen** - launching Python scripts as child processes
- **threading** - capturing subprocess output without blocking Flask

This is NOT a public-facing web application. It runs on `localhost` for a
single user. Security focus is on input validation and subprocess safety,
not internet-scale threats.

---

## Flask Application Structure

### Factory Pattern

Use the Flask application factory pattern for testability:

```python
def create_app(config: dict | None = None) -> Flask:
    """Create and configure the Flask application.

    Args:
        config: Optional configuration overrides (used in tests).

    Returns:
        Configured Flask application instance.
    """
    app = Flask(__name__, static_folder="static", template_folder="templates")
    app.config.from_mapping(
        SECRET_KEY=os.environ.get("FLASK_SECRET_KEY", os.urandom(24).hex()),
        JSON_SORT_KEYS=False,
    )
    if config:
        app.config.from_mapping(config)
    register_routes(app)
    return app
```

### Route Organisation

- Group routes into Blueprint modules when the route count exceeds ~10.
- For small apps (< 10 routes), a single `register_routes(app)` function is
  acceptable.
- Always return JSON from API endpoints - use `flask.jsonify()`.
- Always set explicit HTTP status codes: `return jsonify(...), 200`.

### Error Handling

Register global error handlers:

```python
@app.errorhandler(400)
def bad_request(error: Exception) -> tuple:
    return jsonify({"error": str(error)}), 400

@app.errorhandler(404)
def not_found(error: Exception) -> tuple:
    return jsonify({"error": "Resource not found"}), 404

@app.errorhandler(500)
def internal_error(error: Exception) -> tuple:
    logger.exception("Unhandled server error")
    return jsonify({"error": "Internal server error"}), 500
```

### Request Validation

Validate ALL incoming request data before processing:

```python
@app.route("/api/jobs", methods=["POST"])
def launch_job() -> tuple:
    data = request.get_json(silent=True)
    if not data:
        return jsonify({"error": "Request body must be JSON"}), 400
    script = data.get("script", "")
    if script not in ALLOWED_SCRIPTS:
        return jsonify({"error": f"Unknown script: {script!r}"}), 400
    # ... proceed with validated data
```

---

## Flask-SocketIO (WebSocket)

### Initialisation

```python
from flask_socketio import SocketIO, emit

socketio = SocketIO(app, cors_allowed_origins="*", async_mode="eventlet")
```

- Use `eventlet` as the async mode for Windows compatibility.
- Set `cors_allowed_origins="*"` only for localhost development. If ever
  exposed beyond localhost, restrict origins.

### Event Naming

Use lowercase snake_case for all event names:

| Direction | Event | Purpose |
| --- | --- | --- |
| Server -> Client | `log` | Real-time log line from subprocess |
| Server -> Client | `job_started` | Job has begun executing |
| Server -> Client | `job_complete` | Job finished (includes exit code, elapsed) |
| Server -> Client | `job_error` | Job failed with error |
| Client -> Server | `confirm` | User confirmed a warning prompt |

### Emitting Events

Always emit from background threads using `socketio.emit()` (not `emit()`):

```python
# From a background thread (subprocess watcher):
socketio.emit("log", {"level": "INFO", "message": line, "timestamp": ts})

# From a Flask route handler or SocketIO event handler:
emit("job_started", {"job_id": job_id, "script": script_name})
```

### Connection Lifecycle

Handle connect/disconnect for cleanup:

```python
@socketio.on("connect")
def handle_connect() -> None:
    logger.info("Client connected: %s", request.sid)

@socketio.on("disconnect")
def handle_disconnect() -> None:
    logger.info("Client disconnected: %s", request.sid)
```

---

## Subprocess Management (Job Runner)

### Launching Processes

Follow ALL rules from `security.instructions.md` for subprocess safety.
Additionally:

```python
import subprocess
import threading

def launch_script(command: list[str], job_id: str) -> subprocess.Popen:
    """Launch a script as a subprocess with stdout/stderr capture.

    Args:
        command: Validated command list (see security.instructions.md).
        job_id: Unique identifier for this job run.

    Returns:
        The Popen process object.

    Raises:
        FileNotFoundError: If the script path does not exist.
        ValueError: If command validation fails.
    """
    process = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,  # merge stderr into stdout
        text=True,
        bufsize=1,  # line-buffered
        shell=False,
    )
    # Start a watcher thread to read output line-by-line
    watcher = threading.Thread(
        target=_stream_output,
        args=(process, job_id),
        daemon=True,
    )
    watcher.start()
    return process
```

### Output Streaming

Read subprocess output line-by-line and emit via WebSocket:

```python
def _stream_output(process: subprocess.Popen, job_id: str) -> None:
    """Read process stdout line-by-line and emit to WebSocket.

    Runs in a daemon thread. Exits when the process completes.
    """
    assert process.stdout is not None  # guaranteed by PIPE
    for line in process.stdout:
        stripped = line.rstrip("\n")
        level = _parse_log_level(stripped)
        if level in ("INFO", "WARNING", "ERROR", "CRITICAL"):
            socketio.emit("log", {
                "level": level,
                "message": stripped,
                "timestamp": _utc_now_iso(),
            })
    process.wait()
    socketio.emit("job_complete", {
        "job_id": job_id,
        "exit_code": process.returncode,
    })
```

### Single Job Constraint

Only one job may run at a time. Enforce this:

```python
_current_job: subprocess.Popen | None = None
_job_lock = threading.Lock()

def start_job(command: list[str], job_id: str) -> bool:
    global _current_job
    with _job_lock:
        if _current_job is not None and _current_job.poll() is None:
            return False  # job already running
        _current_job = launch_script(command, job_id)
        return True
```

### Aborting Jobs

On Windows, use `process.terminate()` (sends SIGTERM equivalent):

```python
def abort_current_job() -> bool:
    global _current_job
    with _job_lock:
        if _current_job is None or _current_job.poll() is not None:
            return False  # nothing to abort
        _current_job.terminate()
        return True
```

### Timeout Protection

Set a maximum runtime for any job to prevent runaway processes:

```python
MAX_JOB_RUNTIME_SECONDS = 3600  # 1 hour

# In the watcher thread, after process.wait():
if elapsed > MAX_JOB_RUNTIME_SECONDS:
    process.terminate()
    socketio.emit("job_error", {"job_id": job_id, "error": "Job timed out"})
```

---

## Configuration

- Store app configuration in a JSON file (e.g. `frontend/config.json`).
- **Gitignore** the config file - it contains local paths.
- Provide a `config.example.json` with placeholder values.
- Load config at startup; expose via REST for the frontend to read/update.

---

## Logging

- Use Python's `logging` module - never `print()`.
- Flask's built-in logger is accessible via `app.logger`.
- Set log level via environment variable or config: `LOG_LEVEL=INFO`.
- The Job Runner's subprocess output goes to WebSocket, not to Flask logs
  (unless also mirrored for debugging).

---

## Dependencies

Keep frontend dependencies in a **separate** requirements file
(`frontend/requirements-frontend.txt`) so they do not pollute the main
library's dependencies:

```text
flask>=3.0,<4.0
flask-socketio>=5.3,<6.0
eventlet>=0.36,<1.0
```

Pin with compatible-release bounds (not exact pins) for local tooling that
does not go through CI/CD pipelines. The main project `requirements.txt`
retains exact pins.

---

## Anti-Patterns

| Anti-Pattern | Why It's Bad | Do Instead |
| --- | --- | --- |
| `subprocess.run(f"python {script}")` | Shell injection risk, tainted input | Use list form + validated paths |
| `from flask import *` | Pollutes namespace, unclear imports | Import only what you need |
| Blocking the main thread with `process.wait()` | Freezes Flask and WebSocket | Use a daemon thread |
| Storing secrets in `config.json` | Committed accidentally | Use environment variables |
| `socketio.emit()` inside a tight loop without sleep | Floods the client | Batch or throttle emissions |
| Global mutable state without a lock | Race conditions | Use `threading.Lock()` |

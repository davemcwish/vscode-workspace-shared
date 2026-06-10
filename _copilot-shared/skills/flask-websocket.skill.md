# Skill: Flask, WebSocket & Subprocess (Local Web Frontend)

## Purpose

Standards for building the JOSHUA terminal - a local web-based frontend for
running Salesforce admin scripts. Uses Flask 3.x for REST, Flask-SocketIO for
real-time log streaming, and `subprocess.Popen` for launching scripts.

## Technology Stack

| Layer | Technology | Version |
| --- | --- | --- |
| HTTP Server | Flask | 3.x |
| WebSocket | Flask-SocketIO | 5.x |
| Async Backend | eventlet | 0.36+ |
| Process Management | subprocess.Popen + threading | stdlib |
| Frontend | Vanilla HTML + CSS + JS | No frameworks |
| Template Engine | Jinja2 (via Flask) | Bundled |
| Font | woprcrt-terminal | Local asset |

## Architecture Rules

- **Single-page application** - one `index.html` template served by Flask.
- **No frontend build tools** - no npm, no webpack, no bundlers.
- **REST for commands** - all user actions (launch job, save config) go through
  REST endpoints returning JSON.
- **WebSocket for events** - all server-initiated updates (log lines, job
  status) go through SocketIO events.
- **One job at a time** - no concurrent subprocess execution. Enforced by a
  global lock.
- **Scripts run in isolation** - launched via `subprocess.Popen`, not imported.
  This matches existing project architecture where scripts are standalone.

## Flask Route Conventions

- Prefix all API routes with `/api/`.
- Use HTTP verbs correctly: `GET` for reads, `POST` for actions, `PUT` for
  updates, `DELETE` for removals.
- Always validate request bodies before processing.
- Always return JSON with an explicit status code.
- Use Flask's `abort()` for standard HTTP errors.
- Keep route handlers thin - delegate to service functions.

## WebSocket Conventions

- Event names: lowercase `snake_case` (e.g. `job_started`, `log`, `confirm`).
- All payloads are JSON objects (dicts), never bare strings.
- Every event payload includes a `timestamp` field (ISO 8601 UTC).
- Server-to-client events include a `level` or `type` field for client routing.
- Client-to-server events include the `job_id` for correlation.

## Subprocess Safety (extends `security.skill.md`)

- **NEVER** pass user input directly to subprocess commands.
- **ALWAYS** validate script names against an allowlist (`ALLOWED_SCRIPTS`).
- **ALWAYS** validate org aliases with `validate_salesforce_alias()`.
- **ALWAYS** use list-form commands: `["python", script_path, "--org", safe_alias]`.
- **ALWAYS** set `shell=False` explicitly.
- **ALWAYS** capture output via `stdout=PIPE, stderr=STDOUT`.
- **ALWAYS** run output reading in a daemon thread to avoid blocking Flask.

## Output Streaming Pattern

```text
subprocess.Popen
      │
      ▼
  daemon thread reads stdout line-by-line
      │
      ▼
  parse log level (INFO/WARNING/ERROR)
      │
      ▼
  filter: emit only INFO and above to WebSocket
      │
      ▼
  socketio.emit("log", {...}) → browser terminal
```

## Testing Strategy

| Layer | Tool | Approach |
| --- | --- | --- |
| Job Runner | pytest + `unittest.mock` | Mock subprocess.Popen, verify command construction |
| Flask Routes | Flask test client | `app.test_client()`, assert JSON responses |
| WebSocket | Flask-SocketIO test client | `socketio.test_client(app)`, capture emitted events |
| Frontend | Manual + browser DevTools | Visual, interaction, responsive checks |

### Test Isolation

- Use Flask's `TESTING=True` config.
- Use the app factory pattern so each test gets a fresh app instance.
- Mock `subprocess.Popen` - never actually launch real scripts in unit tests.
- For integration tests, use a known safe script (e.g. `echo "hello"`).

## File Structure

```text
frontend/
├── app.py                     ← Flask entry point (python app.py)
├── config.example.json        ← Template configuration (committed)
├── config.json                ← Local config (gitignored)
├── requirements-frontend.txt  ← Flask + SocketIO + eventlet
├── static/
│   ├── css/
│   │   └── joshua.css         ← WOPR theme styles
│   ├── js/
│   │   ├── joshua.js          ← Main app logic
│   │   ├── terminal.js        ← Terminal log component
│   │   ├── lcd.js             ← LCD clock + timer
│   │   └── modal.js           ← WOPR-themed modals
│   └── fonts/
│       └── woprcrt-terminal/  ← Font assets
├── templates/
│   └── index.html             ← Single page (Jinja2)
src/
└── sf_admin_utils/
    └── job_runner.py           ← Subprocess management + log capture
tests/
├── test_job_runner.py          ← Unit tests for job_runner
└── test_app.py                 ← Flask + SocketIO tests
```

## Configuration Schema

```json
{
  "orgs": {
    "prod": "AXP_PROD",
    "uat": "AXP_UAT"
  },
  "defaults": {
    "org": "AXP_UAT",
    "output_dir": "output"
  }
}
```

- Load at startup with `json.load()`.
- Validate against expected keys before using.
- Expose read/write via `GET /api/config` and `PUT /api/config`.

## Performance Considerations

- **Line buffering** (`bufsize=1`) on subprocess output ensures real-time
  streaming without waiting for buffer flush.
- **Daemon threads** exit automatically when the main process exits - no
  zombie threads.
- **Throttle rapid log emissions** if a script produces more than ~50 lines/sec
  to avoid flooding the browser WebSocket buffer.
- **eventlet monkey-patching** must happen at the top of `app.py` before any
  other imports: `import eventlet; eventlet.monkey_patch()`.

## Launch Pattern

```python
if __name__ == "__main__":
    import eventlet
    eventlet.monkey_patch()
    import webbrowser
    webbrowser.open("http://localhost:5000")
    socketio.run(app, host="127.0.0.1", port=5000, debug=False)
```

- Bind to `127.0.0.1` (not `0.0.0.0`) - localhost only.
- Open browser automatically on launch.
- `debug=False` in production use; `debug=True` only during development.

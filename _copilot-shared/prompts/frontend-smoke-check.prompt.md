---
description: "Verify the Flask frontend is healthy after any HTML, JS, or Python change: all tabs present, no console errors, init guards in place."
mode: agent
---

<!-- markdownlint-disable MD041 -->

Run a smoke check on the Flask frontend. Perform each step in order and report
any failures immediately.

## Step 1: Server is Running

Confirm the Flask server process is active. If it is not running, remind the
user to start it first (see `docs/frontend_guide.md` "Starting the Server")
and stop - do not proceed until the server is up.

Expected: `socketio.run(app, ...)` is executing and the terminal shows
`Serving on http://127.0.0.1:5000`.

## Step 2: Both Tabs Are Present

Open (or refresh) `http://127.0.0.1:5000` in a browser. Confirm the following
tabs are visible and clickable:

- [ ] **Configuration** tab
- [ ] **Run Scripts** tab

If either tab is missing, the browser is serving a stale cached `index.html`.
Fix: restart the Python server process, then do a hard refresh (`Ctrl + F5`).

## Step 3: No Console Errors on Load

Open DevTools (`F12`), switch to the **Console** tab, and hard-refresh
(`Ctrl + F5`). Confirm:

- [ ] Zero red `TypeError` or `ReferenceError` entries on page load.
- [ ] No `Cannot read properties of null (reading 'addEventListener')`.

If errors are present, note the exact message and the line number from the
stack trace.

## Step 4: Defensive Init Guards Are in Place

Inspect `frontend/static/js/app.js`. Confirm:

- [ ] `setPanelHidden()` (or equivalent) checks `if (el)` before calling
  `classList.toggle(...)`.
- [ ] `DOMContentLoaded` calls each setup function independently (e.g.
  `setupTabs()`, `loadConfig()`, `loadScripts()`) so that one early return
  does not prevent the others from running.

## Step 5: Configuration Tab Functionality

Click the **Configuration** tab and confirm:

- [ ] Org alias inputs for PROD, UAT, and SIT are visible.
- [ ] **Verify All** button is present.
- [ ] Clicking **Verify All** shows a status result for each org (Connected,
  Unreachable, Expired, or Not configured) without a page crash.
- [ ] The status accurately reflects the current network state: if you are
  off the corporate VPN, orgs should show **Unreachable**, not **Connected**.

## Step 6: Run Scripts Tab Functionality

Click the **Run Scripts** tab and confirm:

- [ ] The script selector dropdown is populated (not empty).
- [ ] Selecting a script shows its description and argument form.
- [ ] The **Run** button is visible.
- [ ] The Output Log panel is visible.

## Step 7: Connection Status Indicator

Check the status indicator (top-right corner):

- [ ] Shows **Idle** (not "Running") when no job is active.
- [ ] WebSocket connection badge shows **Connected**.

---

## Output Format

Return a report in this format:

```markdown
# Frontend Smoke Check

## Verdict

PASS / FAIL / PARTIAL

## Step Results

| Step | Check | Status | Notes |
| --- | --- | --- | --- |
| 1 | Server running | PASS/FAIL | |
| 2 | Both tabs present | PASS/FAIL | |
| 3 | No console errors on load | PASS/FAIL | |
| 4 | Defensive init guards in place | PASS/FAIL | |
| 5 | Configuration tab functional | PASS/FAIL | |
| 6 | Run Scripts tab functional | PASS/FAIL | |
| 7 | Connection status indicator | PASS/FAIL | |

## Failures

(List any failed steps with the exact error or missing element.)

## Recommended Actions

(One bullet per failure, specific and actionable.)
```

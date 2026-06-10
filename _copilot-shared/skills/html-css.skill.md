# Skill: HTML & CSS (Static Reports)

## Purpose

Generate local static HTML reports from existing CSV manifests and script
outputs. These are read-only summary views - not web applications.

## Constraints

- No JavaScript frameworks (React, Vue, Angular, etc.).
- No build tools (webpack, vite, etc.).
- No web server required for viewing - files open directly in a browser.
- Minimal or zero JavaScript; prefer CSS-only interactivity (details/summary,
  `:hover` states, print stylesheets).
- Accessible: semantic HTML5, sufficient colour contrast, screen-reader friendly.

## Technology

- Python generates HTML files using string templates or `jinja2`.
- CSS in a separate `.css` file or inlined in `<style>` blocks.
- Reports are self-contained (no CDN dependencies) for offline corporate use.

## File Structure

```text
scripts/generate_report.py    # Python script that reads CSV and writes HTML
templates/                    # Jinja2 templates (if used)
reports/                      # Generated output (gitignored)
```

## Styling Standards

- Use CSS custom properties (variables) for colours and spacing.
- Mobile-responsive layout using CSS Grid or Flexbox.
- Print stylesheet (`@media print`) for PDF-friendly output.
- Ford brand colours only if mandated; otherwise neutral professional palette.

## Validation

- Open generated HTML in a browser; verify renders without errors.
- Validate with `python -m py_compile scripts/generate_report.py`.
- Run associated pytest tests.

```bash
pytest tests/test_generate_report.py --tb=short -q
```

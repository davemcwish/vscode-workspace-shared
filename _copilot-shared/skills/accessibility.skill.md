---
name: accessibility
description: "Human-facing skill for implementing accessible web UIs to WCAG 2.2 AA: keyboard/focus, ARIA, contrast, targets, forms, and testing. General guidance, not legal advice."
owner: "TODO: team-or-DL"
lastReviewed: "2026-07-01"
reviewCadence: "quarterly"
---

# Skill: Web Accessibility

> **Role & precedence.** This skill is *explanatory* (human onboarding) and
> **non-normative**. Where accessibility techniques touch code that is also a
> security concern - JavaScript that manages focus, updates ARIA live regions,
> injects status text, or builds DOM nodes - the technical controls are governed
> by `website-security.skill.md` and the security instruction files
> (`security.instructions.md`, `security.instructions.owasp-expanded.md`). In
> particular, update live regions and announcements with `textContent`, never
> `innerHTML`. On any conflict, follow the **stricter security rule**, then meet
> the accessibility requirement (the two are almost always compatible).
>
> **Legal note:** accessibility *legislation* (EAA, ADA, AODA, Section 508,
> EN 301 549) is summarized in `website-privacy-legal.skill.md`. This skill
> covers *implementation*; that skill covers *legal obligation*. This is general
> guidance, not legal advice.
>
> **Related skills:** `website-security.skill.md`, `website-privacy-legal.skill.md`.

## Purpose

Accessibility means making software, websites, reports, documents, and tools
usable by as many people as possible, including people using screen readers,
keyboards, zoom, high contrast settings, captions, or other assistive technology.

This skill applies to:

- HTML pages,
- CSS styling,
- generated static reports,
- public websites,
- internal web pages,
- Markdown documentation,
- CLI output where readability matters.

## Core Principle

Accessibility is not a final polish step. It should be considered from the
start of design, content, implementation, testing, and review.

## Beginner-Friendly Rule

Assume the person maintaining the project may not know accessibility terminology.

When giving accessibility advice, explain:

- what the issue is,
- who it affects,
- why it matters,
- how to fix it,
- how to test it.

---

## HTML Accessibility

Use semantic HTML wherever possible.

Prefer:

```html
<button type="button">Download report</button>
```

over:

```html
<div onclick="downloadReport()">Download report</div>
```

Why:

- `button` is automatically keyboard-accessible,
- screen readers understand it as an action,
- browsers provide expected behavior.

## Page Structure

Every page should have:

- one clear `h1`,
- headings in logical order,
- a `main` landmark for primary content,
- meaningful section headings,
- descriptive page title,
- language set where appropriate.

Example:

```html
<html lang="en">
  <head>
    <title>Inactive User Report</title>
  </head>
  <body>
    <header>...</header>
    <main>
      <h1>Inactive User Report</h1>
    </main>
  </body>
</html>
```

## Links and Buttons

Use:

- links for navigation,
- buttons for actions.

Good link text:

```html
<a href="report.html">View inactive user report</a>
```

Poor link text:

```html
<a href="report.html">Click here</a>
```

## Images

Images must have `alt` text.

Use helpful alternative text when the image communicates meaning:

```html
<img src="chart.png" alt="Bar chart showing inactive users by department">
```

Use empty alt text for decorative images:

```html
<img src="divider.png" alt="">
```

## Forms

Forms should have:

- visible labels,
- clear instructions,
- helpful error messages,
- keyboard-accessible controls,
- required fields marked clearly.

Example:

```html
<label for="email">Email address</label>
<input id="email" name="email" type="email" autocomplete="email">
```

---

## CSS Accessibility

## Color Contrast

Text must have enough contrast against its background.

Avoid:

- pale gray text on white,
- blue text on dark blue,
- red/green-only status indicators.

Do not rely on color alone.

Bad:

```html
<p class="red">Failed</p>
```

Better:

```html
<p class="status status-error">Failed: 3 records could not be exported.</p>
```

## Focus Styles

Keyboard users must be able to see where focus is.

Do not remove focus outlines unless replacing them with an equally visible style.

Bad:

```css
button:focus {
  outline: none;
}
```

Better:

```css
button:focus-visible {
  outline: 3px solid #005fcc;
  outline-offset: 2px;
}
```

## Interactive Widget Accessibility (ARIA Patterns)

When using ARIA roles for interactive widgets, the role creates a **keyboard
contract** - screen reader users and keyboard users expect specific key
interactions. Declaring the role without implementing the keys is worse than
not declaring it at all.

### Tablist / Tab Panels

If you use `role="tablist"` with `role="tab"` children:

- **Left/Right arrow keys** must switch between tabs.
- Only the active tab has `tabindex="0"`. All others have `tabindex="-1"`.
  This is called "roving tabindex".
- `aria-selected="true"` on the active tab; `"false"` on all others.
- The associated panel must be shown/hidden in sync.
- **Home/End** (optional) jump to first/last tab.
- **Tab key** moves focus OUT of the tablist to the panel content, not between
  tabs (arrow keys handle that).

### Modal / Dialog Focus Management

When opening a dialog (`role="dialog"` or `<dialog>`):

1. **Capture** `document.activeElement` before opening.
2. **Move focus** to the first focusable element inside the dialog.
3. **Trap focus** - Tab and Shift+Tab must cycle within the dialog only.
4. **Close on Escape** - the dialog must close when Escape is pressed.
5. **Restore focus** to the previously captured element on close.

Without focus trapping, keyboard users can "fall behind" the dialog into
content they cannot see, making the dialog unusable.

### Live Regions for Streaming Content

When content updates dynamically (log panels, status messages, notifications):

- Use `aria-live="polite"` for non-urgent updates (log lines, status changes).
- Use `aria-live="assertive"` for urgent alerts (errors, job failures).
- Use `role="log"` for chronological streaming content (e.g. terminal output).
- Set `aria-atomic="false"` on log regions so screen readers announce only new
  additions, not the entire region.

Without live regions, screen reader users have no way to know content changed.

### Menu / Menubar

If using `role="menu"` with `role="menuitem"` children:

- **Up/Down arrow keys** navigate items.
- **Enter/Space** activates the item.
- **Escape** closes the menu and returns focus to the trigger.
- Only one item has `tabindex="0"` at a time (roving tabindex).

## Responsive Layout

Layouts should work at different sizes:

- desktop browser,
- tablet,
- phone,
- zoomed desktop view.

Avoid fixed-width layouts that force horizontal scrolling.

Prefer:

```css
.container {
  max-width: 70rem;
  width: min(100% - 2rem, 70rem);
  margin-inline: auto;
}
```

## Motion

Avoid unnecessary animation.

If animation is used, respect reduced-motion preferences:

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms;
    animation-iteration-count: 1;
    scroll-behavior: auto;
    transition-duration: 0.01ms;
  }
}
```

---

## Tables

Use tables only for tabular data.

Tables should include headers:

```html
<table>
  <caption>Inactive users by department</caption>
  <thead>
    <tr>
      <th scope="col">Department</th>
      <th scope="col">Inactive Users</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Sales</td>
      <td>12</td>
    </tr>
  </tbody>
</table>
```

---

## Generated Reports

Generated reports should:

- have a clear title,
- explain what data is shown,
- include generated date/time if useful,
- explain filters applied,
- use semantic headings,
- include table captions,
- avoid exposing unnecessary PII,
- support printing where relevant,
- work without external dependencies where practical.

---

## Markdown Accessibility

Markdown documentation should:

- use headings in order,
- use descriptive link text,
- avoid "click here",
- include alt text for images,
- use tables only where they improve clarity,
- avoid huge walls of text,
- define acronyms on first use,
- use plain English.

Good:

```markdown
See the [Salesforce setup guide](docs/salesforce-setup.md).
```

Poor:

```markdown
Click [here](docs/salesforce-setup.md).
```

---

## CLI Accessibility and Readability

Command-line output should:

- use clear wording,
- not rely only on color,
- include counts and file paths,
- explain errors in plain English,
- avoid overwhelming stack traces unless debugging is requested.

Good:

```text
ERROR: Could not find the Salesforce CLI.
Install it, then run `sf org display --target-org <alias>` to verify login.
```

---

## Review Checklist

When reviewing accessibility, check:

- [ ] Page has one clear `h1`.
- [ ] Heading order is logical.
- [ ] Semantic HTML is used.
- [ ] Links have meaningful text.
- [ ] Buttons are used for actions.
- [ ] Images have useful `alt` text.
- [ ] Forms have labels.
- [ ] Focus indicators are visible.
- [ ] Color contrast is sufficient.
- [ ] Content does not rely on color alone.
- [ ] Layout works on desktop, tablet, and phone.
- [ ] Text remains readable when zoomed.
- [ ] Tables have headers and captions where useful.
- [ ] Generated reports avoid unnecessary PII.
- [ ] Documentation uses plain English.
- [ ] ARIA roles have matching keyboard interactions implemented.
- [ ] Tablist uses arrow keys (not Tab) to switch tabs.
- [ ] Modals trap focus and restore it on close.
- [ ] Live regions announce dynamic content to screen readers.
- [ ] Scripts use `defer` to avoid render-blocking.

## Practical Testing

At minimum:

1. Use only the keyboard to navigate.
2. Zoom the page to 200%.
3. Test at phone width.
4. Check that focus is visible.
5. Confirm images have alt text.
6. Confirm forms have labels.
7. Confirm status messages are understandable without color.
8. Test arrow keys in tablists and menus.
9. Open a modal and verify Tab does not escape the dialog.
10. Close a modal and verify focus returns to the trigger element.
11. Confirm streaming content (logs, status) is announced by screen readers.
12. Verify no render-blocking scripts delay first paint.

## Important Note

This skill provides practical accessibility guidance for project work. It is not
a substitute for formal legal accessibility review where one is required.

---

## Cross-References

- `website-security.skill.md` - technical web controls that intersect with
  accessibility: safe DOM updates (`textContent`/`createElement` over
  `innerHTML`) for live regions and dynamic status messages, and safe handling of
  any third-party accessibility/overlay widgets (pin + SRI, validate origins).
- `website-privacy-legal.skill.md` - the legal side of accessibility (EAA, ADA,
  AODA, Section 508, EN 301 549) and consent-UI accessibility obligations.
- `security.instructions.md` / `security.instructions.owasp-expanded.md` -
  canonical, normative security rules (source of truth for any code).

> **Overlap rule of thumb:** accessibility decides *how the UI must behave for
> all users*; the security skills decide *how the supporting code must be written
> safely*. Apply both - and the stricter security rule when they differ.

> **Currentness:** WCAG 2.2 AA, EN 301 549, and the EAA (in force 28 June 2025)
> evolve; verify the current success criteria and any national transposition
> before relying on a specific requirement.

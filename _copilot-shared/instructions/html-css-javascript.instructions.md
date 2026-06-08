---
applyTo: "**/*.html,**/*.css,**/*.js,frontend/**"
description: "Authoring standards for HTML, CSS, and JavaScript — beginner-friendly, accessible, maintainable."
---

# HTML, CSS & JavaScript Authoring Standards

## Target Audience

All HTML, CSS, and JavaScript in this project must be written so that someone
with **no prior web development experience** can:

- read the code and understand what each section does,
- modify a colour, label, or layout without breaking anything,
- learn foundational web concepts directly from the comments in the file.

This mirrors the Python docstring philosophy in `docstrings.instructions.md` —
comments teach, not just document.

---

## General Principles

- **Prefer simple, standard HTML and CSS** over frameworks (React, Vue, Tailwind,
  Bootstrap) unless a framework is explicitly justified and approved.
- **One file is fine for prototypes and small reports.** Split into separate
  `.html`, `.css`, and `.js` files only when a single file exceeds ~500 lines of
  any one language, or when multiple pages share styles/scripts.
- **No build tools required.** The output must open directly in a browser with no
  compile step, no `npm install`, no bundler. This keeps the project accessible
  to beginners and usable offline.
- **Semantic HTML first.** Use the right element for the job (`<button>` for
  actions, `<a>` for navigation, `<table>` for tabular data). Never use a `<div>`
  where a semantic element exists.
- **Progressive enhancement.** The page should display meaningful content even if
  JavaScript fails to load. Use JS to *enhance*, not to render all content.

---

## File Naming

- Use **lowercase kebab-case** for all web filenames:
  `joshua-terminal.html`, `report-styles.css`, `timer-logic.js`.
- No spaces in filenames — spaces break URLs and many CLI tools.
- Prototype or test-rig files should include the word `prototype` or `test-rig`
  in the filename so they are clearly distinguished from production files.

---

## HTML Standards

### Document Structure

Every HTML file must include:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Descriptive Page Title</title>
</head>
<body>
  <!-- Page content here -->
</body>
</html>
```

Explain in a comment block at the top:

- What the page does.
- Who it is for.
- Any prerequisites (e.g. "open directly in a browser — no server needed").

### Heading Hierarchy

- One `<h1>` per page.
- Headings in logical order (`<h1>` → `<h2>` → `<h3>`). Never skip levels.

### Accessibility Baseline

- All images must have `alt` text (use `alt=""` for purely decorative images).
- All form controls must have associated `<label>` elements.
- Interactive elements must be keyboard-accessible.
- Colour must not be the only way to convey information.
- Use `aria-live="polite"` for regions that update dynamically (e.g. log panels).
- Respect `prefers-reduced-motion` in CSS for animations.

### No Inline Event Handlers

```html
<!-- Bad — mixing HTML and JavaScript logic -->
<button onclick="start()">Start</button>

<!-- Good — separation of concerns -->
<button id="btnStart">Start</button>
```

Attach event listeners in `<script>` blocks or `.js` files using
`addEventListener`.

---

## CSS Standards

### Organisation

Structure CSS in this order within each file or `<style>` block:

1. **Reset / box-sizing** — normalise browser defaults.
2. **Custom properties (variables)** — colours, spacing, font stacks.
3. **Typography** — base font, headings, links.
4. **Layout** — page-level structure (grid, flex containers).
5. **Components** — individual UI pieces (buttons, cards, panels).
6. **Utilities** — small helper classes (visually-hidden, etc.).
7. **Animations / transitions** — keyframes, motion.
8. **Print styles** — `@media print` rules (required for reports).

### Custom Properties

Use CSS custom properties for any value repeated more than once:

```css
:root {
  --colour-primary: teal;
  --colour-danger: tomato;
  --spacing-md: 16px;
  --font-mono: "Courier New", Courier, monospace;
}
```

Name them with the pattern `--category-name` (e.g. `--colour-primary`,
`--spacing-lg`, `--radius-sm`).

### Naming

- Use **descriptive class names** that explain purpose, not appearance:
  `.status-bar`, `.log-entry`, `.timer-display` — not `.red-text`, `.big-box`.
- Use **BEM-lite** for component variants if needed:
  `.btn`, `.btn--primary`, `.btn--danger`.
- Avoid IDs for styling. IDs are for JavaScript hooks only.

### Responsive Design

- Use relative units (`rem`, `em`, `%`, `vw/vh`) over fixed `px` where practical.
- Use Flexbox or Grid for layout — never floats.
- Include at least one `@media` breakpoint for narrow screens (≤ 600px) if the
  content could be viewed on a phone or tablet.
- Test that horizontal scroll does not appear at common viewport widths.

### No `!important`

Never use `!important` unless overriding a third-party style that cannot be
changed. Document the reason in a comment if forced to use it.

---

## JavaScript Standards

### Strict Mode

Every `<script>` block and every `.js` file must begin with:

```javascript
"use strict";
```

This catches common mistakes (undeclared variables, silent failures) that would
otherwise confuse beginners.

### Variable Declarations

- Use `const` by default.
- Use `let` only when reassignment is genuinely needed.
- **Never** use `var` — it has confusing scoping rules that trip up beginners.

### Functions

- Prefer **named functions** over anonymous arrow functions for top-level logic —
  named functions appear in stack traces and are easier to search for.
- Arrow functions are fine for short callbacks (event handlers, array methods).
- Add a **JSDoc comment** above every function:

```javascript
/**
 * Place the orbiting square at the correct position along the LCD perimeter.
 *
 * How it works:
 * The square travels clockwise around the rectangle's edge. We calculate
 * how far along the total perimeter it should be, then convert that
 * distance into (x, y) coordinates.
 *
 * @param {HTMLElement} square - The small square element to position.
 * @param {HTMLElement} container - The rectangle it orbits around.
 * @param {number} progress - A value from 0 to 1 representing how far
 *   around the perimeter the square has travelled (0 = top-left corner,
 *   0.5 = bottom-right area, 1 = back to top-left).
 */
function placeOrbitSquare(square, container, progress) {
  // ...
}
```

### DOM Access

- Cache DOM lookups — call `getElementById` or `querySelector` once and store
  the result in a variable. Repeated lookups are slow and harder to read.
- Use `getElementById` for unique elements (faster, clearer intent).
- Use `querySelector` / `querySelectorAll` for class-based or complex selectors.

### Event Handling

- Always use `addEventListener` — never inline `onclick` attributes.
- Remove event listeners when elements are destroyed (relevant for SPAs or
  dynamic content).

### Web Components (Custom Elements)

When using Web Components (`class extends HTMLElement`):

- Define the component class **before** calling `customElements.define(...)`.
- Use Shadow DOM (`this.attachShadow({ mode: "open" })`) to encapsulate styles
  so they do not leak into or from the host page.
- Explain in a block comment what Shadow DOM is and why it is used — assume the
  reader has never heard of it.
- Keep the component self-contained: all HTML, CSS, and JS for that component
  live inside its class definition.
- Dispatch **Custom Events** (`new CustomEvent(...)`) for communication with the
  outside world. Explain what `bubbles` and `composed` mean in a comment.

### Animation

- Use `requestAnimationFrame` for visual animations — never `setInterval` or
  `setTimeout` for frame-based rendering.
- Explain in a comment that `requestAnimationFrame` synchronises with the
  browser's screen refresh rate (~60 fps) and pauses when the tab is hidden.
- Use **time-based animation** (multiply by delta-time) rather than
  frame-counting, so animations run at the same speed regardless of frame rate.

### No Global Pollution

- Wrap page-level scripts in an IIFE or use `{ }` block scope if not using
  modules.
- Web Component logic lives inside the class — no globals needed.
- The only acceptable globals are the Custom Element registration
  (`customElements.define(...)`) and minimal page-wiring code.

---

## Commenting & Documentation Standards

### Mandatory File-Header Block Comment

Every HTML file must begin (immediately after `<!DOCTYPE html>`) with a block
comment that includes ALL of the following:

1. **What this file is** — one-sentence purpose.
2. **Who it is for** — audience and skill level.
3. **How to use it** — "open in browser" or server setup steps.
4. **Key web concepts used** — bulleted list of technologies (HTML, CSS, JS,
   Web Components, Canvas, etc.) so the reader knows what to expect.
5. **Architecture diagram** — ASCII box diagram showing the component
   structure and data flow (see `joshua-terminal-test-rig.html` for the
   reference example).

Example:

```html
<!DOCTYPE html>
<!--
  ============================================================================
  My Component — Purpose Statement
  ============================================================================

  What this file is:
    A self-contained HTML page that does X.

  Who it is for:
    - Developers with zero HTML/CSS/JavaScript experience.

  How to use it:
    Open this file directly in any modern browser. No server needed.

  Key web concepts used:
    - HTML          → structure
    - CSS           → styling
    - JavaScript    → interactivity
    - Web Component → reusable custom element

  Architecture:
    ┌─────────────────────────────────┐
    │  Host Page                      │
    │  ┌───────────────────────────┐  │
    │  │  <my-component>           │  │
    │  │  (Shadow DOM)             │  │
    │  └───────────────────────────┘  │
    └─────────────────────────────────┘
  ============================================================================
-->
```

### Named Section Headers in CSS and JavaScript

Use boxed `========` comment blocks to divide code into logical sections.
Each section header must name the section and briefly state its purpose:

```css
/*
  =========================================================================
  RESET & BOX-SIZING
  =========================================================================
  Browsers apply default margins/padding. This section normalises them.
*/
```

```javascript
// =========================================================================
//  ORBIT SQUARE POSITIONING
// =========================================================================
```

This visual structure lets a reader scan the file's outline without reading
every line — like chapters in a book.

### Block Comment at the Top of Every Section

Each `<style>` block, `<script>` block, or external `.css`/`.js` file must open
with a block comment explaining:

- What this section/file does.
- How it fits into the overall page.
- Any concepts a beginner might not know.

### Inline Comments: Explain *Why* and *What It Is*

Because the target reader may not know HTML/CSS/JS at all, inline comments in
this project go beyond the normal "explain why" rule:

- **Explain what the construct is** the first time it appears:
  ```css
  /* "box-sizing: border-box" makes width/height include padding and border.
     Without this, adding padding would make elements wider than you expect. */
  *, *::before, *::after {
    box-sizing: border-box;
  }
  ```

- **Explain browser behaviour** that is not obvious:
  ```javascript
  // requestAnimationFrame asks the browser to call our function just before
  // the next screen repaint (~60 times per second). It automatically pauses
  // when the tab is not visible, saving CPU.
  requestAnimationFrame(render);
  ```

- **Explain design decisions:**
  ```css
  /* We use a radial-gradient background to create a subtle spotlight effect
     centred slightly above the middle of the page. This draws the eye toward
     the terminal component. */
  body {
    background: radial-gradient(ellipse at 50% 38%, darkslateblue 0%, midnightblue 100%);
  }
  ```

- **Explain every CSS property on first use** — not just unusual ones. If a
  property appears for the first time in the file, add a short inline comment
  explaining what it does, even for common properties like `display: flex` or
  `position: relative`. Assume the reader has never written CSS before.

### JSDoc: Include "How it works" Explanations

Every JavaScript function must have a JSDoc comment that includes not only
the standard `@param` and `@returns` tags, but also a **"How it works"**
paragraph explaining the algorithm or technique in plain English:

```javascript
/**
 * Place a small square at a position along the perimeter of a rectangle.
 *
 * How it works:
 *   Imagine "unwrapping" the rectangle's border into a straight line.
 *   The total length is the perimeter. Given a progress value (0 to 1),
 *   we calculate the distance along that line, then figure out which edge
 *   the point falls on and convert back to (x, y) coordinates.
 *
 * @param {HTMLElement} square    - The element to position.
 * @param {HTMLElement} container - The rectangle it orbits.
 * @param {number}      progress  - 0 to 1, how far around the perimeter.
 */
```

### Comment Density Guideline

For this project, aim for approximately **one comment per 3–5 lines of code** in
CSS and JavaScript sections. This is intentionally higher than production norms
because the goal is education.

### Terms to Always Explain on First Use

| Term | Explanation to include in comment |
| --- | --- |
| DOM | "(the Document Object Model — the browser's in-memory tree of HTML elements)" |
| Shadow DOM | "(an isolated mini-document inside a Web Component — styles and IDs inside cannot clash with the main page)" |
| Custom Element | "(a reusable HTML tag you define yourself, like `<joshua-terminal>`, using a JavaScript class)" |
| `requestAnimationFrame` | "(asks the browser to run this function before the next screen repaint — about 60 times per second)" |
| CSS custom property | "(a variable defined with `--name` that you can reuse throughout your CSS)" |
| Flexbox | "(a CSS layout mode that arranges children in a row or column with flexible sizing)" |
| Grid | "(a CSS layout mode that arranges children in rows and columns, like a spreadsheet)" |
| `::before` / `::after` | "(pseudo-elements — invisible extra elements CSS creates before/after an element's content, useful for decorations)" |
| `box-shadow` | "(adds a shadow effect around an element — like the shadow a card casts on a desk)" |
| `radial-gradient` | "(a colour transition that radiates outward from a centre point, like a spotlight)" |
| `linear-gradient` | "(a colour transition in a straight line from one side to another)" |
| `transition` | "(tells the browser to animate smoothly between old and new CSS values when they change)" |
| `transform` | "(moves, rotates, scales, or skews an element without affecting surrounding layout)" |
| `z-index` | "(controls which element appears in front when elements overlap — higher numbers are on top)" |
| `will-change` | "(a hint telling the browser to prepare for an upcoming animation on this property — improves performance)" |
| Canvas / `<canvas>` | "(an HTML element that provides a blank drawing surface — JavaScript draws pixels onto it)" |
| `getContext('2d')` | "(gets the 2D drawing API for a canvas — lets you draw shapes, text, and images)" |
| Event bubbling | "(when an event on a child element travels up through its parents — lets a parent listen for events from any descendant)" |
| `composed: true` | "(allows a Custom Event to escape the Shadow DOM boundary so the host page can hear it)" |

---

## Security

- **Never** include API keys, tokens, passwords, or secrets in HTML/JS files.
- If the page fetches data from an API, the API key must come from a server-side
  proxy or environment variable — never embedded in client-side code.
- Avoid `eval()`, `innerHTML` with user-supplied data, and `document.write()`.
- Use `textContent` instead of `innerHTML` when inserting plain text.
- If accepting user input, sanitise it before rendering.

---

## Performance

- Minimise DOM queries — cache element references.
- Avoid layout thrashing (reading layout properties then immediately writing
  style changes in a loop).
- Use `will-change` sparingly and only on elements that actually animate.
- For `<canvas>` animations, clear only the regions that changed when practical.
- Limit `setInterval` / `setTimeout` usage — prefer `requestAnimationFrame` for
  visual updates.

---

## Testing & Validation

- Open the file directly in a browser (no server needed for static files).
- Check the browser's Developer Tools Console for errors.
- Test keyboard navigation (Tab, Enter, Escape).
- Test at viewport widths: 360px (phone), 768px (tablet), 1280px+ (desktop).
- Validate HTML with the W3C Validator (`https://validator.w3.org/`) for
  production files.
- Run Lighthouse (in Chrome DevTools) for accessibility and performance scores
  on production files.

---

## File & Folder Structure

For the Salesforce project:

```text
frontend/
├── joshua-terminal.html       ← main dashboard (self-contained prototype)
├── components/                 ← reusable Web Components (when split out)
├── styles/                     ← shared CSS (when split out)
└── assets/                     ← images, icons, fonts
```

For generated static reports (produced by Python scripts):

```text
reports/
├── templates/                  ← Jinja2 or string-template HTML
└── output/                     ← generated .html files (gitignored)
```

---

## Relationship to Other Instruction Files

| File | Relationship |
| --- | --- |
| `docs.instructions.md` | Tone and audience rules apply to HTML comments too |
| `security.instructions.md` | No secrets in client-side code |
| `html-css-review.prompt.md` | Use this prompt to review finished work |
| `website-launch-planner.chatmode.md` | Use for live websites; not needed for local reports |

---

## Reference Implementation

The file `frontend/joshua-terminal-test-rig.html` is the **gold standard**
for this project's HTML/CSS/JS commenting style. All new web files must match
its level of detail. Key patterns demonstrated there:

- File-header block comment with all 5 mandatory fields + architecture diagram.
- Named section headers (`========` blocks) for every CSS and JS region.
- Every CSS property explained on first use (even `display: flex`).
- JSDoc with "How it works" paragraph on every function.
- All terms from the glossary table explained inline on first occurrence.
- Design rationale comments on non-obvious visual choices.
- `~1 comment per 3–5 lines` density maintained throughout.

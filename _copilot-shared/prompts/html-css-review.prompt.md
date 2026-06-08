---
description: "Review HTML and CSS for accessibility, responsiveness, maintainability, and beginner readability."
mode: ask
---

Review the selected HTML, CSS, template, generated report, or website files.

Assume the reader may be new to HTML, CSS, accessibility, browser testing,
responsive design, and website launch work.

## Review Scope

Check the selected files for:

1. HTML structure.
2. CSS structure.
3. Accessibility.
4. Responsive design.
5. Browser and device compatibility.
6. Visual consistency.
7. Maintainability.
8. Performance.
9. Security and privacy.
10. Beginner readability.
11. Launch readiness, if this is a website rather than a local static report.

## Important Distinction

First identify which type of work this is:

| Type | Meaning |
| --- | --- |
| Static report | Generated HTML/CSS intended to be opened locally or shared internally |
| Website | Public or internal website that may need hosting, domain, launch, analytics, and maintenance |
| Template | HTML/CSS used by Python or another tool to generate output |
| Prototype | Early design that is not yet production-ready |

If the type is unclear, state your assumption before reviewing.

## HTML Review Checklist

Check:

- semantic HTML elements such as `header`, `main`, `nav`, `section`, `article`,
  `footer`, and `button`,
- one clear `h1` per page,
- heading levels in logical order,
- meaningful link text,
- forms with labels,
- buttons used for actions and links used for navigation,
- tables used for tabular data, not layout,
- images with useful `alt` text,
- no placeholder text left behind,
- no duplicated IDs,
- no inline event handlers unless explicitly justified.

## CSS Review Checklist

Check:

- clear organization,
- reusable classes,
- consistent spacing,
- consistent colors,
- consistent typography,
- CSS custom properties where helpful,
- no excessive `!important`,
- no fragile selectors,
- no unnecessary duplication,
- print styles if this is a report,
- responsive layout using Flexbox, Grid, or simple flow layout,
- readable comments explaining non-obvious design decisions.

## Accessibility Review Checklist

Check:

- keyboard navigation,
- visible focus indicators,
- sufficient color contrast,
- text is readable at common zoom levels,
- forms have labels and helpful error messages,
- interactive elements have accessible names,
- page language is set where appropriate,
- content does not rely on color alone,
- animations are avoided or respectful of reduced-motion preferences,
- tables have headers where needed.

## Responsive and Device Review Checklist

Check whether the design works for:

- Windows desktop browser,
- macOS desktop browser,
- Linux desktop browser,
- Android tablet,
- iPad,
- Android phone,
- iPhone.

Review:

- mobile-first layout,
- narrow screen behavior,
- touch target size,
- wrapping text,
- horizontal scrolling,
- image scaling,
- navigation behavior,
- page load size.

## Static Report-Specific Checks

If this is a generated static report, check:

- works without a web server,
- does not depend on external CDNs unless explicitly approved,
- handles empty data gracefully,
- includes generated date/time if useful,
- includes data source notes,
- avoids exposing PII unnecessarily,
- has print-friendly styling,
- can be opened directly in a browser.

## Website-Specific Checks

If this is a website, check:

- objective is clear,
- target audience is clear,
- main call to action is visible,
- navigation is understandable,
- contact or conversion path works,
- page titles and meta descriptions are present,
- privacy/cookie requirements are considered,
- analytics are considered,
- domain/hosting/SSL launch steps are documented,
- post-launch maintenance owner is identified.

## Output Format

Return this structure:

```markdown
# HTML/CSS Review

## Summary

[Plain-English overall assessment.]

## Assumptions

- [State whether this is a static report, website, template, or prototype.]

## Verdict

APPROVE / REQUEST CHANGES / COMMENT ONLY

## Findings

| Severity | File:Line | Area | Issue | Why It Matters | Suggested Fix |
| --- | --- | --- | --- | --- | --- |

## Accessibility Assessment

[Beginner-friendly explanation of accessibility status.]

## Responsive Design Assessment

[Explain how well this supports desktop, tablet, and phone.]

## Maintainability Assessment

[Explain whether a beginner developer could safely update this later.]

## Security and Privacy Notes

[Call out PII, external resources, forms, analytics, or unsafe content.]

## Positive Notes

[What was done well.]

## Recommended Next Steps

1. [Most important next action.]
2. [Next action.]
```

## Severity Guide

| Severity | Meaning |
| --- | --- |
| Blocker | Must fix before release or sharing |
| Major | Should fix before release |
| Minor | Useful improvement |
| Nit | Small style/readability issue |

## Rules

- Be constructive and beginner-friendly.
- Explain why each issue matters.
- Do not suggest a frontend framework unless the current approach cannot
  reasonably meet the need.
- Prefer simple HTML and CSS where possible.
- Do not invent requirements that are not present.
- If launch readiness cannot be assessed, say what information is missing.

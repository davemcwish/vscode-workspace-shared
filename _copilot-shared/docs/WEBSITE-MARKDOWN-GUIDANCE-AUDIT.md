# Website Markdown Guidance Audit

## Purpose

This audit records the current state of the shared website Copilot markdown
artifacts and identifies cleanup work needed to keep the website guidance
consistent, beginner-friendly, ASCII-safe, and maintainable.

## Inventory Summary

Current website artifacts include:

- 39 website prompt files under `_copilot-shared/prompts/`
- 8 website skill files under `_copilot-shared/skills/`
- 1 website artifact manifest
- 1 consolidated website planning guide pointer document

## Overall Assessment

The website prompt library is broad and mostly coherent. Most newer review
prompts follow a consistent structure with principles, missing-context handling,
review areas, severity rules, recommendation rules, output format, findings,
priority actions, escalation guidance, and open questions.

The main issues are isolated stale manifest entries, mojibake status symbols,
and a small number of prompt files with duplicated, missing, stale, or copied
sections.

## Findings

### 1. Manifest status symbols contain mojibake

`_copilot-shared/WEBSITE-ARTIFACT-MANIFEST.md` contains corrupted status labels
such as:

- `oe... Installed`
- `Y"\u00C2\u00B2 To create`
- `Y"\u00C2\u00B2 To verify`
- `Å¡a Optional`
- `Y" -  External`

These should be replaced with ASCII-safe status labels:

- `Installed`
- `To create`
- `To verify`
- `Optional`
- `External`

### 2. Manifest statuses are stale

The manifest marks several artifacts as `To create` or `To verify` even though
the files now exist. The manifest should be refreshed so installed artifacts are
marked consistently.

Examples include:

- `website-from-idea-to-launch.prompt.md`
- `website-platform-decision.prompt.md`
- `website-seo-review.prompt.md`
- `website-local-seo-check.prompt.md`
- `website-conversion-review.prompt.md`
- `website-html-css-review.prompt.md`
- `website-monthly-review.prompt.md`
- `website-maintenance-plan.prompt.md`
- `website-launch.skill.md`
- `website-growth.skill.md`

### 3. `website-performance-review.prompt.md` appears to contain growth-plan content

The heading audit shows `website-performance-review.prompt.md` begins with:

- `# Website Growth Plan Prompt`
- `# Website Growth Plan`

This appears to be copied from `website-growth-plan.prompt.md` and should be
replaced with a true website performance review prompt.

### 4. `website-review.prompt.md` returned no markdown headings

The heading audit returned no headings for `website-review.prompt.md`. This file
should be checked for one of the following conditions:

- empty file
- malformed markdown
- missing headings
- encoding issue
- obsolete file replaced by more specific review prompts

### 5. `website-local-seo-check.prompt.md` has duplicate output sections

The file contains two `# Local SEO Check` sections. The shorter duplicate should
be removed or merged.

### 6. `website-seo-review.prompt.md` has duplicate and possibly truncated output sections

The file contains duplicate `# SEO Review` sections and a suspicious truncated
heading:

- `## Rev`

This file should be cleaned and normalized.

### 7. `website-html-css-review.prompt.md` lacks an initial prompt title

The file starts with `## Review Scope` instead of a top-level prompt title.
Add a title such as:

`# Website HTML, CSS, and JavaScript Review Prompt`

### 8. `website-platform-decision.prompt.md` lacks an initial prompt title

The file starts with `## First Clarify the Need`. Add a title such as:

`# Website Platform Decision Prompt`

The `Salesforce Considerations` section should also be reviewed to determine
whether the generic website prompt should instead use broader wording such as
`CRM, Marketing, and Business-System Considerations`.

### 9. Some prompt titles omit `Website`

Several prompt titles are understandable but less consistent than the newer
files. Optional normalization candidates include:

- `# Conversion Review Prompt`
- `# Digital Sustainability Review Prompt`
- `# Online Presence Review Prompt`
- `# SEO Review Prompt`
- `# Local SEO Check Prompt`
- `# Security and Privacy Review Prompt`

These could be renamed to include `Website` for consistency.

## Recommended Standard Structure

Website review prompts should generally follow this structure:

```markdown
# Website [Area] Review Prompt

## [Area] principles

## Ask for missing context first

## Review areas

## [Area] readiness checks

## Severity rules

## Recommendation rules

## Output format

# Website [Area] Review

## Verdict

## Beginner-Friendly Summary

## Important Note

## Assumptions and Missing Data

## Review Scope

## Findings

## What Not To Do

## Priority Actions

## 30-Day [Area] Improvement Plan

## Escalation Needed

## Open Questions

## Output style rules

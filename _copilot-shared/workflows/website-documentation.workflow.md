# Workflow: Website Documentation

## Purpose

This workflow ensures that **every website discussion produces well-structured,
linked, beginner-friendly markdown documents** that serve as an offline reference.

These documents are not throwaway chat logs - they are the project's permanent
record. A complete beginner should be able to read them months later and
understand every decision made, why it was made, and what to do next.

---

## When to Use This Workflow

Use this workflow whenever:

- A website project begins (any stage from idea to launch).
- A significant decision is made about platform, design, content, or technology.
- A planning session, review, or audit is completed.
- The user explicitly requests documentation of discussions.

**Rule:** If the discussion produced a decision, recommendation, or action plan  -
it must be documented.

---

## Output Location

All website documentation should be saved in the user's chosen project folder.
Suggest a structure like:

```text
my-website-project/
├── docs/
│   ├── 01-website-brief.md
│   ├── 02-platform-decision.md
│   ├── 03-legal-compliance.md
│   ├── 04-content-plan.md
│   ├── 05-design-decisions.md
│   ├── 06-launch-checklist.md
│   ├── 07-promotion-plan.md
│   ├── 08-maintenance-plan.md
│   └── 09-analytics-setup.md
├── assets/
│   └── (images, logos, brand files)
└── README.md
```

The numbering reflects the recommended order of creation but is not rigid.
Documents can be created in any order as decisions are made.

---

## Document Templates

### Template: Website Brief

```markdown
# Website Brief

## Last Updated
[Date]

## Project Summary
- **Website name/business:** [Name]
- **Website purpose:** [What the site exists to achieve]
- **Target audience:** [Who will visit - be specific]
- **Primary geography:** [Where the audience is located]
- **Launch target date:** [When - even approximate]

## Goals
What does "success" look like? List 1 - 3 measurable goals.
1. [Goal 1 - e.g. "10 enquiries per month from the contact form"]
2. [Goal 2]
3. [Goal 3]

## Key Pages Required
- [ ] Homepage
- [ ] About
- [ ] Services / Products
- [ ] Contact
- [ ] [Other pages specific to this project]

## Constraints
- **Budget:** [Total budget for website creation]
- **Ongoing budget:** [Monthly budget for hosting, maintenance, marketing]
- **Technical skill:** [Owner's comfort with technology - beginner/intermediate/advanced]
- **Maintenance owner:** [Who will update the site after launch?]
- **Domain:** [Already owned? If so, what is it?]

## Decisions Still Needed
- [ ] Platform choice (see `02-platform-decision.md`)
- [ ] Content (who writes it?)
- [ ] Design (template, custom, or brand guidelines?)
- [ ] Legal compliance (see `03-legal-compliance.md`)

## Notes
[Any additional context, preferences, or constraints]
```

### Template: Platform Decision

```markdown
# Platform Decision

## Last Updated
[Date]

## Decision
**Chosen platform:** [Platform name]
**Decided on:** [Date]
**Decision maker:** [Who made the final call]

## Options Considered

### Option 1: [Platform Name]
- **What it is:** [Brief description]
- **Monthly cost:** [£X]
- **Pros:** [List]
- **Cons:** [List]
- **Best for:** [When this platform shines]
- **Rejected because:** [Why not chosen]

### Option 2: [Platform Name]
[Same structure]

### Option 3: [Platform Name]
[Same structure]

## Why [Chosen Platform] Was Selected
[Explain the reasoning - budget, skill level, features, scalability, etc.]

## What This Decision Means Going Forward
- [Implications for design flexibility]
- [Implications for maintenance]
- [Implications for cost over time]
- [Migration difficulty if we change later]

## References
- [Link to platform documentation]
- [Link to relevant skill file used]
```

### Template: Legal Compliance Record

```markdown
# Legal Compliance Record

## Last Updated
[Date]

## Applicable Laws
Based on target audience geography:

| Law | Jurisdiction | Applies? | Actions Required |
| --- | --- | --- | --- |
| GDPR | EU/EEA | [Yes/No] | [List] |
| UK GDPR | United Kingdom | [Yes/No] | [List] |
| CPRA | California, USA | [Yes/No] | [List] |
| LGPD | Brazil | [Yes/No] | [List] |
| Privacy Act | Australia | [Yes/No] | [List] |
| POPIA | South Africa | [Yes/No] | [List] |
| PDPA | Singapore | [Yes/No] | [List] |
| ADA / Section 508 | USA | [Yes/No] | [List] |
| EAA | EU | [Yes/No] | [List] |
| [Other] | [Country] | [Yes/No] | [List] |

## Privacy Policy
- [ ] Created
- [ ] Covers all data collection (analytics, forms, cookies, third-party)
- [ ] Includes contact details for data requests
- [ ] Published at [URL]

## Cookie Consent
- [ ] Required? [Yes/No - based on tools used and audience geography]
- [ ] Tool chosen: [Cookiebot / CookieYes / None needed / etc.]
- [ ] Implemented and tested

## Accessibility
- [ ] Target level: [WCAG 2.1 AA / other]
- [ ] Tested with: [Tool names]
- [ ] Manual testing completed: [Yes/No]

## Outstanding Actions
- [ ] [Action items that still need completing]

## Review Schedule
- [ ] Next legal compliance review: [Date - at least annually]
```

---

## Documentation Rules

### Structure Rules

1. **One topic per document.** Don't combine platform decision with legal
   compliance in one file.
2. **Clear headings.** A reader should understand the document's content from
   headings alone.
3. **Date everything.** Every document has a "Last Updated" field.
4. **Link between documents.** When one document references another, use a
   relative markdown link.
5. **Number documents.** Use prefix numbers for recommended reading order.

### Content Rules

1. **Write for a complete beginner.** Someone who has never built a website
   should understand every sentence.
2. **Explain all jargon.** If you use a technical term, define it in parentheses
   the first time.
3. **Record the reasoning, not just the decision.** "We chose WordPress because
   the maintenance owner is comfortable with it and the budget is £50/month" is
   useful. "We chose WordPress" alone is not.
4. **Include alternatives considered.** Future readers need to know what was
   evaluated and why it was rejected.
5. **Keep it current.** When a decision changes, update the document - don't
   just add a note at the bottom.

### Format Rules

1. Use standard markdown (not platform-specific extensions).
2. Use tables for comparisons.
3. Use checklists (`- [ ]`) for action items.
4. Use blockquotes (`>`) for important warnings or notes.
5. Keep line length under 80 characters for readability in plain text editors.
6. Use relative links between documents (not absolute paths).

---

## When to Create Each Document

| Project Stage | Documents to Create |
| --- | --- |
| Initial discussion | Website Brief |
| Platform selection | Platform Decision |
| Legal review | Legal Compliance Record |
| Content planning | Content Plan |
| Design discussion | Design Decisions |
| Pre-launch | Launch Checklist |
| Post-launch | Promotion Plan, Maintenance Plan, Analytics Setup |
| Ongoing | Update all documents as decisions change |

---

## The README.md

Every website project documentation folder should have a `README.md` that:

1. Explains what the project is.
2. Lists all documentation files with a one-line description of each.
3. Indicates the current project status (planning / building / live / archived).
4. Names the maintenance owner and their contact.
5. Records the last review date.

Example:

```markdown
# [Business Name] Website Documentation

## Status: [Planning / In Development / Live / Archived]

## Quick Reference
- **Live URL:** [URL or "not yet live"]
- **Platform:** [WordPress / Squarespace / etc.]
- **Hosting:** [Provider name]
- **Maintenance owner:** [Name]
- **Last reviewed:** [Date]

## Documentation Index
| # | Document | Description |
| --- | --- | --- |
| 01 | [Website Brief](docs/01-website-brief.md) | Goals, audience, constraints |
| 02 | [Platform Decision](docs/02-platform-decision.md) | Why we chose [platform] |
| 03 | [Legal Compliance](docs/03-legal-compliance.md) | Privacy, cookies, accessibility |
| 04 | [Content Plan](docs/04-content-plan.md) | Pages, copy, content schedule |
| 05 | [Design Decisions](docs/05-design-decisions.md) | Colours, fonts, layout rationale |
| 06 | [Launch Checklist](docs/06-launch-checklist.md) | Pre-launch verification |
| 07 | [Promotion Plan](docs/07-promotion-plan.md) | Marketing channels and schedule |
| 08 | [Maintenance Plan](docs/08-maintenance-plan.md) | Ongoing tasks and responsibilities |
| 09 | [Analytics Setup](docs/09-analytics-setup.md) | What we measure and how |
```

---

## Integration With Copilot Artifacts

When using Copilot prompts, agents, or workflows for website work:

1. **Before starting:** Open the relevant documentation files for context.
2. **During discussion:** Note key decisions and recommendations.
3. **After completion:** Update or create the relevant documentation file.
4. **Cross-reference:** Link from documentation to the Copilot artifact used
   (e.g. "Platform selected using `/platform-decision` prompt").

### Which Artifact Produces Which Document

| Copilot Artifact | Document It Should Produce/Update |
| --- | --- |
| `website-launch-planner` chatmode | Website Brief, Platform Decision |
| `/platform-decision` prompt | Platform Decision |
| `/website-from-idea-to-launch` prompt | Website Brief (initial draft) |
| `/seo-review` prompt | Promotion Plan (SEO section) |
| `/monthly-website-review` prompt | Maintenance Plan (update with findings) |
| `/website-maintenance-plan` prompt | Maintenance Plan |
| `website-privacy-legal` skill | Legal Compliance Record |
| `website-security` skill | Launch Checklist (security section) |
| `website-analytics` skill | Analytics Setup |

---

## Critical Constraints

- Never leave a significant decision undocumented.
- Never use technical jargon without explanation.
- Never create documentation without a "Last Updated" date.
- Never assume the reader has context - write as if they're reading this for
  the first time, months from now.
- Always record WHY a decision was made, not just WHAT was decided.
- Always link related documents to each other.
- Always keep documentation current - outdated docs are worse than no docs
  (they mislead).
- Always store documentation alongside the project, not in a separate system.

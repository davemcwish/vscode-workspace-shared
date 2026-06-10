---
description: "Help choose the simplest sustainable platform for a website, report, dashboard, or tool."
mode: ask
---

Help choose the best platform or technical approach for the capability I
describe.

Assume the user may be minimally computer literate and may not know the
difference between a no-code website builder, CMS, static HTML/CSS, generated
report, command-line tool, local web app, or custom web application.

Do not jump straight to implementation.

## First Clarify the Need

Ask or infer:

1. What is the main goal?
   - Generate leads
   - Sell products
   - Share information
   - Produce reports
   - Support an internal process
   - Automate Salesforce administration
   - Provide a dashboard
   - Collect form submissions
   - Enable user accounts or workflows

2. Who is the target user?
   - Public visitors
   - Customers
   - Internal employees
   - Salesforce admins
   - Developers
   - Managers or executives
   - External partners

3. How often will it be used?
   - One-time
   - Occasionally
   - Weekly or monthly
   - Daily
   - Continuously

4. Who will maintain it?
   - Non-technical person
   - Salesforce admin
   - Python developer
   - Web developer
   - Marketing/content owner
   - External agency
   - Unknown

5. What geography matters?
   - Global
   - Regional
   - Country-specific
   - State/province/county-specific
   - Local
   - Where is the business legally based?
   - Where are most users or visitors expected to be?
   - Are local language, currency, tax, payment, hosting, privacy, cookie,
     accessibility, or legal-page requirements relevant?
   - Should local or regional providers be compared with global platforms?

6. What data is involved?
   - Public data
   - Internal data
   - Salesforce data
   - PII
   - Customer data
   - Payment data
   - Generated files such as CSV, PDF, ZIP, Excel, or logs

7. What does "done" look like?

8. Social media and online presence:
   - Does the business already use social media?
   - Which platforms are active?
   - Which platforms bring enquiries, bookings, sales, or trust?
   - Should the website link to social profiles?
   - Should social profiles link back to the website?
   - Is a "link in bio" page needed?
   - Are reviews, testimonials, or social proof needed?
   - Are social ads, campaign links, or tracking pixels planned?
   - Does the platform need good share-preview support?

## Options To Consider

Compare only relevant options.

| Option | Examples | Best For | Avoid When |
| --- | --- | --- | --- |
| Existing CLI script | Python script or admin command | Developer/admin-run tasks and automation | Non-technical users need a visual interface |
| Generated static report | Python-generated HTML/CSS, CSV, Excel, or PDF output | Read-only summaries, offline review, simple sharing | Users need live filtering, editing, forms, or accounts |
| Static HTML/CSS website | GitHub Pages, Netlify, Cloudflare Pages, local hosting, internal hosting, or equivalent | Simple fast website with developer support | Non-technical users must update content often |
| No-code website builder | Wix, Squarespace, or trusted local equivalents | Fast beginner-managed brochure site | Complex workflows or deep integrations are needed |
| Content management system | WordPress or regionally popular CMS platforms | Content-heavy site, blog, flexible pages, regular updates | No one can maintain updates, backups, plugins, and security |
| eCommerce platform | Shopify, WooCommerce, or local eCommerce platforms | eCommerce, product catalogues, tax, payments, and shipping | The site is not primarily a store or local payment/tax needs are not supported |
| Local or regional hosting provider | Country-specific hosting or managed WordPress providers | Local support, billing, data hosting, or regional trust | Provider lacks reliability, backups, SSL, security, or beginner support |
| Local Flask/FastAPI app | Internal interactive workflow | Controlled internal use | Public scalable website is needed |
| Custom web app | Accounts, workflows, integrations, dashboards | Complex workflows or custom business logic | A simpler platform meets the need |
| Power BI or dashboard tool | Business reporting and charts | Reports, dashboards, and data analysis | Custom workflows or public web pages are required |

## Decision Criteria

Evaluate:

- user skill level,
- maintainability,
- cost,
- time to launch,
- security,
- PII risk,
- Salesforce Production risk,
- hosting complexity,
- content update frequency,
- accessibility,
- device support,
- integration needs,
- rollback plan,
- long-term ownership,
- social media and online presence needs,
- profile-linking needs,
- share-preview needs,
- review or testimonial needs,
- messaging-platform needs,
- advertising or tracking needs,
- the business's ability to maintain both the website and social profiles.

## Output Format

Return:

```markdown
# Platform Decision

## Beginner-Friendly Summary

[Plain-English recommendation.]

## Recommended Option

[Chosen option.]

## Why This Fits

- [Reason 1]
- [Reason 2]
- [Reason 3]

## Alternatives Considered

| Option | Pros | Cons | Decision |
| --- | --- | --- | --- |

## User Skill and Maintenance Fit

[Explain who can maintain this and what skills they need.]

## Social Media and Online Presence Considerations

[Explain profile links, share previews, reviews, testimonials, messaging,
advertising, tracking, embedded feeds, and maintenance responsibilities.]

## Security and PII Considerations

[Explain sensitive data risks and mitigations.]

## Salesforce Considerations

[Explain read-only/mutating behavior, Production risk, and testing needs.]

## Cost and Complexity

[Low/Medium/High with explanation.]

## Implementation Path

1. [First step]
2. [Second step]
3. [Third step]

## Testing and Validation

- [What must be tested.]

## Documentation Needed

- [What guides or README sections must be updated.]

## Risks and Mitigations

| Risk | Impact | Mitigation |
| --- | --- | --- |

## Final Recommendation

[Clear final answer.]
```

## Rules

- Recommend the simplest sustainable option.
- Do not recommend custom code when a no-code or CMS platform better fits.
- Do not recommend a frontend framework unless the benefits clearly outweigh
  the maintenance cost.
- If Salesforce Production or PII is involved, highlight the risk clearly.
- If the user is unsure, provide a safe default and explain what would change
  the recommendation.
- If recommending specific providers, pricing, regional hosting, social platform
  features, advertising rules, API access, verification rules, or compliance
  features, verify the latest information from official provider sources before
  making a final recommendation.
  
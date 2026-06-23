---
description: Review a website plan, page, HTML/CSS project, CMS site, eCommerce site, or no-code website for beginner-friendly SEO, search visibility, and findability.
---

# SEO Review Prompt

You are reviewing a website for search engine optimization, findability, and
content clarity.

SEO should support the website's real business or organisational goal. Do not
treat SEO as a separate technical exercise.

**Currentness warning:** Search engine behaviour, ranking systems, structured
data support, search result features, webmaster tool interfaces, platform
defaults, and SEO best practices change over time. Give beginner-friendly
guidance, but recommend verifying current information with search engine
documentation, platform documentation, and live testing where decisions matter.

---

## SEO safety principles

- Do not promise rankings, traffic, leads, or sales.
- Do not recommend keyword stuffing, hidden text, doorway pages, copied content,
  fake reviews, fake locations, or manipulative link schemes.
- Do not treat SEO as more important than clarity, accessibility, trust, or
  conversion quality.
- Do not assume analytics data and search visibility data are the same thing.
- Do not assume Google is the only search surface; mention Bing where relevant.
- If the site operates in a regulated area, flag unsupported health, financial,
  legal, safety, environmental, or other high-risk claims.
- Prefer practical, beginner-safe recommendations over advanced tactics.

---

## Ask for missing context first

If not provided, ask:

- What is the website for?
- What is the main goal or conversion?
- Who is the target audience?
- Which country, region, city, or service area matters?
- Is the website local, national, international, internal, or public?
- What products, services, topics, categories, locations, or problems should the
  website be found for?
- What search intent matters most: informational, commercial research,
  transactional, support, local, or brand search?
- Is the site built with HTML/CSS, a CMS, a no-code builder, an eCommerce
  platform, or a custom app?
- Are Google Search Console, Bing Webmaster Tools, analytics, or conversion
  tracking already configured?
- Are there existing pages, headings, page titles, meta descriptions, URLs,
  schema/structured data, sitemap, robots.txt, or canonical tags to review?
- Are there important competitors, alternatives, or comparison searches?
- Are there legal, regulatory, brand, medical, financial, safety, environmental,
  or advertising claim constraints?
- Is the site new, redesigned, migrated, or already live?

---

## Beginner review guidance

When reviewing, explain issues in plain language.

For each recommendation, make clear:

- what is wrong,
- why it matters,
- how to fix it,
- whether the fix is beginner-friendly,
- whether it needs a developer, CMS admin, SEO specialist, legal review, or
  platform support.

Prioritise fixes that improve both visitors and search engines, such as clearer
page purpose, better headings, useful content, internal links, indexability,
mobile usability, and accurate business information.

---

## Specific checks to perform

### Search intent

Check whether each important page clearly matches what the visitor is likely
trying to do: learn, compare, buy, book, enquire, solve a problem, or find a
local provider.

### Titles and meta descriptions

Check whether page titles and meta descriptions are unique, specific, readable,
and aligned with the page purpose. Do not recommend stuffing keywords into them.

### Headings

Check whether each page has one clear H1 and logical H2/H3 sections. Headings
should help visitors scan the page and understand the structure.

### Content quality

Check whether the page answers real visitor questions, includes useful details,
and avoids vague filler language. Flag thin, duplicated, outdated, or generic
content.

### Trust and claims

Check whether claims are supported by evidence. Flag risky claims involving
health, finance, law, safety, sustainability, "best", "guaranteed", reviews,
awards, certifications, or comparisons.

### Internal links

Check whether important pages link to each other naturally. Recommend internal
links where they help users continue their journey.

### Indexing and crawlability

Check for obvious risks such as missing sitemap, blocked pages, accidental
noindex, broken links, redirect chains, duplicate URLs, missing canonical tags,
or important pages that are hard to reach.

### Structured data

If appropriate, suggest beginner-safe structured data opportunities such as
Organization, LocalBusiness, Product, BreadcrumbList, FAQPage, Article, or
Review snippets. Warn that structured data must match visible page content and
must not invent reviews, ratings, prices, availability, or claims.

### Local SEO

If the website serves a local area, check whether local intent is addressed with
service area, address or location details where appropriate, opening hours,
contact details, reviews, Google Business Profile alignment, and location/service
pages where genuinely useful.

### eCommerce SEO

If the website sells products, check category pages, product names, descriptions,
stock/availability wording, product images, reviews, shipping/returns
information, duplicate manufacturer descriptions, and structured data.

### Search visibility tools

Recommend setting up Google Search Console and Bing Webmaster Tools for public
websites that rely on search visibility. Explain that analytics shows what
visitors do after arriving, while search visibility tools show impressions,
queries, indexing, and search-related issues.

---

## Review areas

Review the site or plan against these areas:

1. Search intent and audience fit
2. Business goal and conversion alignment
3. Homepage clarity
4. Page purpose and target audience
5. Page titles
6. Meta descriptions
7. H1/H2/H3 heading structure
8. Content usefulness, specificity, and readability
9. Service, product, category, topic, and location wording
10. Trust signals, proof, reviews, credentials, policies, and contact details
11. Unsupported, risky, or regulated claims
12. Internal links and navigation paths
13. Image alt text, image filenames, and image size
14. URL readability
15. Mobile usability
16. Page speed and performance risks
17. Indexing and crawlability risks
18. Noindex, robots.txt, canonical, redirect, and duplicate URL risks
19. XML sitemap or platform equivalent
20. Structured data/schema opportunities and risks
21. Duplicate, thin, outdated, copied, or unclear content
22. Local SEO fit where relevant
23. eCommerce/category/product SEO where relevant
24. Social sharing previews
25. Accessibility issues that affect findability or comprehension
26. Search visibility tools: Google Search Console and Bing Webmaster Tools
27. Measurement, analytics, and conversion tracking
28. Content ownership and maintenance risks

---

## Output format

Return:

```markdown
# SEO Review

## Verdict

PASS / NEEDS IMPROVEMENT / HIGH RISK

## Summary

Short summary of the most important SEO and findability opportunities.

## Assumptions and Missing Context

List any assumptions made and any context still needed.

## Highest Priority Issues

| Priority | Issue | Why It Matters | Suggested Fix | Owner |
| --- | --- | --- | --- | --- |

## Findings

| Severity | Area | Issue | Why It Matters | Suggested Fix |
| --- | --- | --- | --- | --- |

## Suggested Page Title and Meta Description Improvements

| Page | Suggested Page Title | Suggested Meta Description | Notes |
| --- | --- | --- | --- |

## Search Phrases to Consider

| Search Phrase | Search Intent | Suggested Page | Notes |
| --- | --- | --- | --- |

## Content and Trust Improvements

| Page / Area | Improvement | Evidence or Detail Needed |
| --- | --- | --- |

## Technical SEO Checks

| Check | Status | Notes | Suggested Fix |
| --- | --- | --- | --- |
| Indexability | Unknown / OK / Issue |  |  |
| Robots.txt | Unknown / OK / Issue |  |  |
| Sitemap | Unknown / OK / Issue |  |  |
| Canonical tags | Unknown / OK / Issue |  |  |
| Redirects | Unknown / OK / Issue |  |  |
| Broken links | Unknown / OK / Issue |  |  |
| Mobile usability | Unknown / OK / Issue |  |  |
| Page speed | Unknown / OK / Issue |  |  |
| Structured data | Unknown / OK / Issue |  |  |

## Search Visibility Tools

State whether Google Search Console and Bing Webmaster Tools appear to be set up
or should be set up.

## Local SEO Notes

Include only if relevant.

## eCommerce SEO Notes

Include only if relevant.

## Priority Actions

1.
2.
3.

## Maintenance Recommendations

List ongoing checks, ownership, and review frequency.
```

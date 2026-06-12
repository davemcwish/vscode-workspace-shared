---
description: Review website performance, page speed, mobile experience, assets, scripts, caching, third-party tools, monitoring, and practical remediation.
---

# Website Performance Review Prompt

You are helping review website performance in a beginner-friendly, practical,
and ethical way.

The goal is to identify performance issues that make the website slower, harder
to use, more expensive to operate, less accessible, or less likely to support
the user's goals.

Focus on practical improvements that a small team, beginner, or non-technical
website owner can understand and maintain. Prefer simple fixes before complex
engineering work.

Do not assume the user has Lighthouse reports, Core Web Vitals data, analytics,
server logs, CDN logs, or monitoring tools. If evidence is missing, say what is
missing and provide safe manual checks.

**Currentness warning:** Performance tooling, browser behavior, hosting features,
CDN features, image formats, framework defaults, analytics tools, and platform
recommendations change over time. Where specific tools, thresholds, platform
features, provider pricing, or browser behavior matter, tell the user to verify
current details from official sources.

## Performance principles

- Prioritize user experience over artificial scores.
- Review mobile performance first unless the website is truly desktop-only.
- Focus on priority journeys, not only the homepage.
- Prefer reducing unnecessary work before adding complex tooling.
- Do not recommend removing accessibility, privacy, consent, or security features
  just to improve speed.
- Do not recommend breaking analytics, forms, checkout, booking, login, or other
  critical journeys without a tested replacement.
- Separate must-fix performance risks from optional optimizations.
- Explain tradeoffs in plain language.
- Tie recommendations to likely user impact, maintenance effort, and business
  value.

## Ask for missing context first

If not provided, ask concise questions about:

- What is the website for?
- What pages or journeys matter most?
- Is the website public, internal, local, national, international, eCommerce,
  service-based, booking-based, donation-based, membership-based, content-based,
  no-code, CMS-based, static, or a custom web application?
- What platform or technology is used?
- What hosting, CDN, CMS, theme, page builder, or framework is used?
- What devices and connection speeds matter most?
- Are there current performance reports, analytics, Core Web Vitals-style data,
  Lighthouse reports, WebPageTest results, server logs, or user complaints?
- Are there heavy images, video, maps, chat widgets, ads, analytics tags,
  personalization tools, or third-party embeds?
- Who can make content, design, hosting, or code changes?
- Are there launch, campaign, seasonal, migration, or peak-traffic deadlines?

## Review areas

Check performance across:

1. Priority pages and user journeys.
2. Mobile experience.
3. Page weight and number of requests.
4. Images, graphics, icons, video, audio, and animation.
5. HTML, CSS, JavaScript, fonts, and framework/page-builder overhead.
6. Third-party scripts, tags, widgets, embeds, chat, maps, ads, and analytics.
7. Caching, compression, CDN, hosting, and server response.
8. Rendering behavior, layout shifts, and perceived speed.
9. Accessibility and low-bandwidth usability.
10. Privacy, consent, and tag-loading behavior.
11. Monitoring, measurement, and ownership.
12. Performance budgets and regression prevention.
13. Practical remediation sequencing.

## Performance readiness checks

Check whether:

- Priority pages have been identified.
- The website has been tested on mobile.
- Performance has been tested on a realistic connection.
- Images are compressed and appropriately sized.
- Video and animation are necessary and optimized.
- Unused scripts, plugins, widgets, or embeds are reviewed.
- Fonts are limited and loaded sensibly.
- Caching and compression are enabled where appropriate.
- Critical journeys still work after optimization.
- Someone owns ongoing performance review.
- There is a way to detect performance regressions.

## Evidence to collect

Useful evidence may include:

- URLs for the homepage and priority pages.
- Lighthouse or PageSpeed Insights reports.
- WebPageTest or browser DevTools screenshots.
- Real-user monitoring or analytics data.
- Core Web Vitals-style field data where available.
- Hosting, CDN, CMS, plugin, or theme information.
- Image and video sizes.
- List of third-party scripts and tags.
- User complaints or support tickets about slowness.
- Recent changes, launches, campaigns, migrations, or incidents.

If evidence is unavailable, provide a practical manual review plan.

## Core Web Vitals-style guidance

Use Core Web Vitals-style thinking to discuss:

- loading speed,
- responsiveness,
- visual stability,
- perceived speed,
- mobile usability,
- user frustration.

Avoid overfitting to a single score. Explain that field data from real users is
more useful than one synthetic lab run when available.

## Mobile performance guidance

Pay special attention to:

- slow mobile connections,
- large images,
- heavy JavaScript,
- intrusive banners or popups,
- chat widgets,
- maps,
- autoplay media,
- font loading,
- tap targets,
- layout shifts,
- long forms,
- checkout, booking, account, or donation flows.

## Image and media guidance

Check whether:

- images are larger than needed,
- appropriate modern formats are used where supported,
- thumbnails and responsive image sizes are available,
- decorative images can be simplified or removed,
- hero images are optimized,
- lazy loading is used appropriately,
- video is compressed, deferred, captioned, and not autoplayed unnecessarily,
- animation respects accessibility and motion-sensitivity needs.

## CSS, JavaScript, and font guidance

Check whether:

- unused CSS or JavaScript is excessive,
- page builders or frameworks add avoidable weight,
- critical functionality depends on slow scripts,
- scripts block rendering unnecessarily,
- fonts are too numerous or heavy,
- fallback fonts are acceptable,
- layout shifts are caused by late-loading assets,
- code splitting, bundling, minification, or deferral may help.

## Third-party script guidance

Review:

- analytics tags,
- tag managers,
- advertising pixels,
- heatmaps and session recording,
- chat widgets,
- maps,
- booking widgets,
- social embeds,
- review widgets,
- consent tools,
- A/B testing tools,
- personalization scripts,
- CRM or marketing automation scripts.

For each third party, ask whether it is necessary, owned, consent-aware,
accessible, secure, monitored, and worth its performance cost.

## Caching, CDN, and hosting guidance

Check whether:

- static assets are cached appropriately,
- compression is enabled,
- CDN delivery is appropriate,
- server response is slow,
- hosting is underpowered or misconfigured,
- redirects add unnecessary delay,
- SSL/TLS and certificate setup are healthy,
- regional hosting or CDN choices fit the audience,
- cache changes have a safe purge and rollback process.

## Accessibility and user-experience guidance

Performance recommendations must not reduce accessibility. Check whether slow
loading affects:

- keyboard users,
- screen reader users,
- users with cognitive load concerns,
- users on low-end devices,
- users on low-bandwidth connections,
- users who rely on captions, transcripts, or clear text alternatives.

## Analytics and monitoring guidance

Recommend practical monitoring such as:

- periodic performance checks for priority pages,
- analytics review of slow pages or high-exit pages,
- uptime and error monitoring where appropriate,
- real-user monitoring if the site scale justifies it,
- checks after releases, plugin updates, campaigns, migrations, or content-heavy
  changes.

## Severity rules

Use these severities:

- **Blocker**: A critical journey is unusable or extremely slow for a meaningful
  group of users.
- **Major**: A performance issue likely harms conversions, accessibility,
  search visibility, user trust, or operational reliability.
- **Minor**: A performance issue should be improved but does not appear to block
  important journeys.
- **Nit**: A small cleanup or polish issue.

## Recommendation rules

For each recommendation:

- Explain the likely user impact.
- State whether it is beginner-friendly or needs technical help.
- Identify the owner where possible.
- Avoid recommending expensive tools before simpler fixes.
- Include a validation method.
- Mention risks or tradeoffs.
- Separate urgent fixes from optional improvements.

## Output format

Return:

```markdown
# Website Performance Review

## Verdict

PASS / NEEDS IMPROVEMENT / HIGH RISK

## Beginner-Friendly Summary

Short plain-language summary of the most important performance issues and what
to do first.

## Important Note

State that performance recommendations should be validated with current tools,
real user evidence where available, and the website's actual priority journeys.

## Assumptions and Missing Data

List assumptions made and evidence still needed.

## Review Scope

List the pages, journeys, platform, devices, and evidence reviewed.

## Current Evidence

Summarize available performance reports, analytics, complaints, logs, or manual
checks.

## Performance Health Check

| Area | Status | Notes |
| --- | --- | --- |
| Priority pages identified | Unknown / OK / Issue |  |
| Mobile performance checked | Unknown / OK / Issue |  |
| Page weight reviewed | Unknown / OK / Issue |  |
| Images and media reviewed | Unknown / OK / Issue |  |
| CSS, JavaScript, and fonts reviewed | Unknown / OK / Issue |  |
| Third-party scripts reviewed | Unknown / OK / Issue |  |
| Caching, CDN, and hosting reviewed | Unknown / OK / Issue |  |
| Critical journeys tested | Unknown / OK / Issue |  |
| Monitoring in place | Unknown / OK / Issue |  |
| Performance owner assigned | Unknown / OK / Issue |  |

## Findings

| Severity | Area | Issue | Why It Matters | Suggested Fix | Owner |
| --- | --- | --- | --- | --- | --- |

## Priority Page Review

Summarize performance concerns for the homepage and other priority pages.

## Mobile Performance Review

Summarize mobile-specific risks and fixes.

## Image and Media Review

Summarize image, video, audio, animation, and icon issues.

## CSS, JavaScript, and Font Review

Summarize code, framework, page-builder, and font-loading issues.

## Third-Party Script Review

| Tool / Script | Purpose | Risk | Recommendation |
| --- | --- | --- | --- |

## Caching, CDN, and Hosting Review

Summarize hosting, caching, compression, CDN, redirects, and server response
issues.

## Accessibility and User-Experience Impact

Explain how performance issues may affect real users, especially users on mobile,
low-bandwidth connections, assistive technology, or older devices.

## Monitoring and Measurement Plan

List practical checks, tools, owners, and review frequency.

## Performance Budget Recommendation

Suggest simple limits or rules for page weight, images, scripts, third parties,
and release checks.

## What Not To Do

List risky shortcuts to avoid.

## Priority Actions

1.
2.
3.

## 30-Day Performance Improvement Plan

| Week | Action | Owner | Evidence of Completion |
| --- | --- | --- | --- |
| Week 1 |  |  |  |
| Week 2 |  |  |  |
| Week 3 |  |  |  |
| Week 4 |  |  |  |

## Escalation Needed

State whether a developer, hosting provider, platform vendor, accessibility
reviewer, analytics owner, privacy reviewer, or agency should be involved.

## Open Questions

List unanswered questions.

## Output style rules

- Be beginner-friendly.
- Be specific and practical.
- Avoid unsupported claims.
- Do not promise performance scores, rankings, conversions, or revenue.
- Separate urgent fixes from optional improvements.

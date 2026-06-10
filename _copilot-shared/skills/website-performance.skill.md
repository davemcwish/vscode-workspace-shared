# Skill: Website Performance and Speed

## Purpose

This skill covers performance optimisation for **public websites** - ensuring
pages load quickly for all visitors regardless of device, connection speed, or
geographic location.

It is written for **complete beginners** who may not know what a CDN is, why
images need optimisation, or how to interpret a Lighthouse report.

**Currentness warning:** Browser behaviour, Core Web Vitals metrics,
Lighthouse scoring, device capabilities, network conditions, hosting
features, CDN behaviour, image formats, and performance best practices change
over time. Before making final performance decisions, verify current guidance
from authoritative sources and test the actual website.

---

## Why Performance Matters

- **Visitors leave.** 53% of mobile users abandon a site that takes longer than
  3 seconds to load (Google research). Every additional second costs conversions.
- **Search engines penalise slow sites.** Google uses page speed as a ranking
  factor. A slow site appears lower in search results.
- **Accessibility.** Visitors on slow connections (rural areas, developing
  countries, mobile data) are disproportionately affected by heavy pages.
- **Hosting costs.** Larger pages use more bandwidth, which may cost more.

---

## Field Data vs Lab Data

Performance tools do not all measure the same thing.

| Data Type | What It Means | Examples | Use It For |
| --- | --- | --- | --- |
| Lab data | A controlled test run using simulated or fixed conditions | Lighthouse, local browser tests, PageSpeed Insights lab section | Debugging and comparing changes |
| Field data | Real visitor experience collected from actual users | Chrome UX Report, real user monitoring, PageSpeed Insights field section | Understanding real-world performance |
| Synthetic monitoring | Repeated scheduled tests from chosen locations/devices | Uptime/performance monitoring tools | Detecting regressions over time |

Beginner rule:

Use lab data to diagnose problems, but use field data where available to
understand what real visitors experience.

---

## Core Web Vitals (Google's Speed Metrics)

Core Web Vitals are Google-defined user-experience metrics that focus on
loading speed, responsiveness, and visual stability. The exact metrics,
thresholds, reporting details, and tooling can change over time, so verify
current guidance before treating a number as final.

At a beginner level, the key idea is simple: the site should load quickly,
respond promptly, and avoid unexpected layout movement.

Google measures three key things about your page:

| Metric | Full Name | What It Measures | Good Score |
| --- | --- | --- | --- |
| **LCP** | Largest Contentful Paint | How long until the biggest visible element (image, heading) appears | Under 2.5 seconds |
| **INP** | Interaction to Next Paint | How quickly the page responds when someone clicks or taps | Under 200 milliseconds |
| **CLS** | Cumulative Layout Shift | How much the page content jumps around as it loads | Under 0.1 |

### How to Check Your Scores

- **Google PageSpeed Insights** (pagespeed.web.dev) - enter your URL, get scores
  and specific recommendations.
- **Lighthouse** - built into Chrome/Edge DevTools (F12 → Lighthouse tab). Run
  on mobile and desktop.
- **Google Search Console** → Core Web Vitals report (shows scores for all pages
  as seen by real visitors).
- **WebPageTest** (webpagetest.org) - advanced testing with different locations
  and connection speeds.

---

## Performance Budget

A performance budget is a limit you set before the site becomes slow.

It can include limits for:

- page weight,
- image weight,
- JavaScript size,
- CSS size,
- font files,
- third-party scripts,
- number of requests,
- target load time,
- Core Web Vitals targets.

Beginner example:

| Metric | Suggested Budget |
| --- | --- |
| Homepage total page weight | Under 2 MB where practical |
| Content page total page weight | Under 1.5 MB where practical |
| Largest hero image | Under 300 KB where practical |
| Number of HTTP requests | Under 50 where practical |
| JavaScript total | Under 300 KB compressed where practical |
| Largest Contentful Paint | Under 2.5 seconds |
| Interaction to Next Paint | Under 200 milliseconds |
| Cumulative Layout Shift | Under 0.1 |
| Third-party scripts | Only those with a clear business purpose |
| Fonts | Use system fonts or one font family unless there is a clear reason |
| Mobile test | Must remain usable on a mid-range phone over a slow connection |

The exact numbers depend on the website type, audience, media needs, and
business goals. The important part is to set limits before adding more images,
scripts, plugins, apps, fonts, or embeds.

Write the budget down. Check it monthly. If a new feature pushes the page over
budget, either optimise something else, remove unnecessary weight, or document
why the exception is acceptable.

---

## Image Optimisation

Images are typically the heaviest part of a web page. Poorly optimised images
are the #1 cause of slow websites.

### Rules

| Rule | Why |
| --- | --- |
| Use modern formats (WebP or AVIF) | 30 - 50% smaller than JPEG/PNG at the same quality |
| Resize images to the size they display | A 4000px image displayed at 800px wastes bandwidth |
| Compress images before upload | Tools: Squoosh (web), ShortPixel, TinyPNG |
| Use responsive images (`srcset`) | Serve smaller images to mobile devices |
| Lazy-load below-the-fold images | Don't load images the visitor hasn't scrolled to yet |
| Always set `width` and `height` attributes | Prevents layout shift (CLS) as images load |

### What "Lazy Loading" Means

By default, a browser loads ALL images on a page immediately - even ones at the
bottom that the visitor can't see yet. Lazy loading tells the browser: "Only
load this image when the visitor scrolls near it."

Add `loading="lazy"` to any image below the initial visible area:

```html
<img src="photo.webp" alt="Description" width="800" height="600" loading="lazy">
```

Do NOT lazy-load the first visible image (above the fold) - it should load
immediately for good LCP.

### Image and Media Governance

Images are one of the easiest ways for a website to become slow over time.

Document simple rules for future content editors:

- maximum image dimensions,
- preferred file formats,
- target file sizes,
- where original high-resolution images are stored,
- who is allowed to upload large media,
- when to use video instead of images,
- when not to use autoplaying media,
- how to add alt text,
- how to test the page after adding media.

Beginner rule:

Do not upload full-size camera images directly to normal website pages unless
the platform automatically resizes and optimises them.

---

## Font Loading

Custom fonts (Google Fonts, Adobe Fonts, self-hosted) can block page rendering
if not handled carefully.

### Font Rules

- **Self-host fonts** when possible (avoids extra DNS lookup to Google/Adobe).
- Use `font-display: swap` in your `@font-face` rule (shows text immediately in
  a fallback font, swaps to the custom font when loaded).
- Only load the font weights and styles you actually use (loading Bold, Italic,
  Light, ExtraBold when you only use Regular and Bold wastes bandwidth).
- Use WOFF2 format (smallest file size, supported by all modern browsers).
- Preload your most important font file:

```html
<link rel="preload" href="/fonts/main.woff2" as="font" type="font/woff2" crossorigin>
```

Fonts can improve branding, but they can also slow down rendering and cause
layout shifts.

Additional beginner rules:

- Use system fonts if branding does not require custom fonts.
- If using web fonts, use as few font families, weights, and styles as
  practical.
- Avoid loading fonts from unnecessary third-party services.
- Preload only critical fonts when you understand the impact.
- Test whether text is readable while fonts load.
- Check for layout shifts caused by font swapping.

Do not add multiple font families just because a theme or template makes it
easy.

---

## CSS and JavaScript Performance

### CSS

- Load CSS in the `<head>` (so the browser knows how to style the page before
  showing content).
- Minimise CSS file size - remove unused rules (tools: PurgeCSS, UnCSS).
- Avoid `@import` inside CSS files (causes sequential loading - slow).
- For critical styles needed immediately, consider inlining them in the HTML.

### JavaScript

- JavaScript blocks rendering by default. A large script stops the page from
  appearing until it downloads and runs.
- Add `defer` to script tags (loads in parallel, runs after HTML is parsed):

```html
<script src="main.js" defer></script>
```

- Add `async` only for scripts that don't depend on other scripts (e.g.
  analytics - loads and runs as soon as ready, order not guaranteed).
- Remove JavaScript you don't use. Every library, plugin, and widget adds weight.
- If you don't need JavaScript, don't include it. A simple brochure site may
  need zero JavaScript.

---

## Caching

Caching means saving a copy of your files so repeat visitors don't download them
again.

### Browser Caching

Tell the browser "you can keep this file for X time without checking again."
Set via HTTP headers:

- `Cache-Control: public, max-age=31536000` for static assets with hashed
  filenames (CSS, JS, images that change filename when updated).
- `Cache-Control: public, max-age=3600` for HTML pages (shorter - so visitors
  see updates within an hour).

### CDN (Content Delivery Network)

A CDN copies your website files to servers all around the world. When someone in
Sydney visits your site, they get files from a server in Sydney - not London.

**What it is:** A network of servers in many countries that serve your files from
the closest location to each visitor.

**Why it helps:**

- Faster load times for visitors far from your origin server.
- Reduces load on your hosting server.
- Often includes DDoS protection (stops attacks that try to overwhelm your site).

**Popular CDNs:** Cloudflare (free tier available), Fastly, AWS CloudFront,
Bunny CDN.

**For static sites:** Platforms like Netlify, Cloudflare Pages, and Vercel
include a CDN by default - no extra setup needed.

---

## Minimising Requests

Every file your page loads (images, CSS, JS, fonts, third-party scripts)
requires a network request. Each request has overhead (DNS lookup, connection,
waiting). Fewer requests = faster page.

### How to Reduce Requests

- Combine multiple small CSS files into one.
- Use CSS sprites or SVG icons instead of many small image files (where
  practical).
- Remove third-party scripts you don't need (every analytics tool, chat widget,
  social embed, and tracking pixel adds requests).
- Use a single font family with limited weights rather than multiple font families.

## Third-Party Scripts

Third-party scripts include analytics, advertising pixels, chat widgets, maps,
social media embeds, review widgets, booking tools, A/B testing tools, heatmaps,
session replay tools, payment widgets, and embedded videos.

Each third-party script can affect:

- loading speed,
- responsiveness,
- privacy and consent,
- security risk,
- reliability,
- mobile data usage,
- visitor trust.

Before adding a third-party script, ask:

- What business purpose does it serve?
- Is there a lighter alternative?
- Does it need to load on every page?
- Can it load after consent or after interaction?
- What happens if the third-party service is slow or unavailable?
- Who owns the script after launch?

Beginner rule:

Every third-party script should have a named owner, a documented reason, and a
review date.

---

## Mobile Performance

Mobile devices have:

- Slower processors than desktops.
- Higher latency connections (4G/LTE has ~50ms latency vs ~5ms for wired).
- Data caps (heavy pages cost your visitors money in some countries).

### Rules for Mobile

- Test on real mobile devices or Chrome DevTools mobile simulation.
- Always run Lighthouse in "Mobile" mode (it simulates a mid-range phone on 4G).
- Aim for total page weight under 1.5 MB for content pages.
- Critical content should be visible within 3 seconds on a 4G connection.

### Mobile and Network Reality Check

A website that feels fast on a developer's laptop and office broadband may feel
slow on a mid-range phone, weak Wi-Fi, or mobile data connection.

Test at least:

- homepage,
- most important landing page,
- most important conversion page,
- largest content page,
- checkout or booking flow if applicable,
- page with the most third-party embeds if applicable.

Where possible, test on:

- desktop,
- mobile,
- slower network conditions,
- logged-out visitor state,
- consent accepted,
- consent rejected,
- first visit,
- repeat visit.

---

## Platform-Specific Notes

### WordPress

- Use a caching plugin (WP Super Cache, W3 Total Cache, or LiteSpeed Cache).
- Use an image optimisation plugin (ShortPixel, Imagify, or Smush).
- Minimise plugins - every plugin adds CSS and JavaScript.
- Choose a lightweight theme (avoid "multipurpose" themes that load everything).
- Consider a CDN plugin or Cloudflare integration.

### Static Site Generators (Hugo, Eleventy, Astro, Jekyll)

- Already fast by default (no database, no server-side processing).
- Focus on image optimisation and font loading.
- Deploy to CDN-backed hosting (Netlify, Cloudflare Pages, Vercel).

### No-Code Builders (Wix, Squarespace, Webflow)

- Limited control over performance internals.
- Focus on: optimising images before upload, limiting animations, removing
  unused sections, and avoiding excessive third-party integrations.
- Accept that these platforms may never score 100 on Lighthouse - aim for
  "good enough" (green scores on Core Web Vitals).

### eCommerce (Shopify, WooCommerce, BigCommerce)

- Product images are usually the biggest performance issue - optimise them.
- Limit apps/plugins (each adds scripts).
- Use built-in lazy loading if available.
- Test product listing pages (many images) and checkout flow separately.

## Performance Regressions

Performance can get worse after launch because of:

- new images,
- new plugins,
- new apps,
- theme changes,
- tracking pixels,
- chat widgets,
- review widgets,
- embedded videos,
- added fonts,
- advertising tags,
- CMS updates,
- hosting changes.

Treat performance as an ongoing maintenance task, not a one-time launch task.

When performance changes suddenly after a website update, plugin change, cookie
banner change, hosting migration, or platform migration, check whether the
measurement setup or page weight changed before assuming visitor behaviour
changed.

---

## Performance Checklist for Launch

Before going live:

- [ ] Performance budget documented.
- [ ] Run Lighthouse on mobile and desktop.
- [ ] Core Web Vitals are green where practical, or exceptions are documented.
- [ ] All images are optimised using modern format, correct size, and
      compression.
- [ ] Image and media upload rules documented for future editors.
- [ ] Images below the fold use lazy loading.
- [ ] The first visible image is not lazy-loaded if it affects LCP.
- [ ] Fonts use WOFF2 format where practical.
- [ ] Font families, weights, and loading behaviour reviewed.
- [ ] JavaScript uses `defer` or `async` where appropriate.
- [ ] Unused CSS and JavaScript is removed.
- [ ] Third-party scripts reviewed for necessity, page scope, owner, and
      performance impact.
- [ ] Caching headers are configured.
- [ ] CDN configured where appropriate.
- [ ] Page weight is within the documented performance budget or exceptions are
      documented.
- [ ] Key pages tested on mobile and slower network conditions.
- [ ] Performance tested with consent accepted and consent rejected where a
      consent banner is used.
- [ ] Baseline performance results recorded for future comparison.
- [ ] Performance owner named.
- [ ] First post-launch performance review scheduled.

---

## Ongoing Performance Maintenance

| Frequency | Action |
| --- | --- |
| Weekly during first month after launch | Check key pages for obvious speed, layout, and interaction issues |
| Monthly | Review analytics, search console, and page speed signals for performance or usability problems |
| Monthly | Check whether new content added unusually large images, videos, embeds, or downloads |
| Quarterly | Re-test key pages with lab tools and compare against baseline |
| Quarterly | Review third-party scripts, apps, plugins, embeds, fonts, and tracking tags |
| Quarterly | Check Core Web Vitals or equivalent real-user performance data where available |
| On every major content update | Check image sizes, page weight, layout stability, and mobile usability |
| On every theme/platform/plugin/app change | Re-test key pages before and after the change |
| On every new marketing tag or embed | Review performance, consent, privacy, and security impact |
| Annually | Re-check performance budget, hosting fit, CDN configuration, and media rules |

---

## Interpreting a Lighthouse Report

When you run Lighthouse, you get scores from 0 - 100:

| Score Range | Meaning | Action |
| --- | --- | --- |
| 90 - 100 (green) | Good | Maintain - no urgent action |
| 50 - 89 (orange) | Needs improvement | Review specific recommendations |
| 0 - 49 (red) | Poor | Prioritise fixes - significant user impact |

Lighthouse also provides **specific recommendations** ranked by estimated impact.
Start with the highest-impact item and work down.

Lighthouse is useful, but it is still lab data. Do not treat a single Lighthouse
score as the whole truth. Compare it with field data where available, especially
for pages with real traffic.

**Common recommendations and what they mean:**

- "Serve images in next-gen formats" → Convert to WebP/AVIF.
- "Eliminate render-blocking resources" → Defer JavaScript, inline critical CSS.
- "Reduce unused CSS/JavaScript" → Remove libraries or features you don't use.
- "Properly size images" → Resize to display dimensions.
- "Enable text compression" → Configure gzip/Brotli on your server.

---

## Critical Constraints

- Never sacrifice usability for performance; do not remove content people need.
- Never ignore mobile performance; many visitors use phones and slower networks.
- Never judge performance from a developer machine alone; test realistic devices
  and networks.
- Never treat Lighthouse or lab scores as the only truth; compare with field data
  where available.
- Never add features, third-party scripts, apps, plugins, embeds, fonts, or media
  assets without considering performance cost.
- Never upload large original images directly to normal pages without
  optimisation.
- Never let performance ownership be unclear after launch.
- Always measure before and after changes; do not guess - test.
- Always have a performance budget, even informal.
- Always optimise images before upload unless the platform reliably performs
  resizing, compression, and modern-format delivery automatically.
- Always record baseline performance results at launch.
- Always re-test after major content, theme, plugin, app, script, hosting, or
  platform changes.
- Always document the reason, owner, and review date for third-party scripts.

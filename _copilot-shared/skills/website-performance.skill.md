# Skill: Website Performance and Speed

## Purpose

This skill covers performance optimisation for **public websites** — ensuring
pages load quickly for all visitors regardless of device, connection speed, or
geographic location.

It is written for **complete beginners** who may not know what a CDN is, why
images need optimisation, or how to interpret a Lighthouse report.

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

## Core Web Vitals (Google's Speed Metrics)

Google measures three key things about your page:

| Metric | Full Name | What It Measures | Good Score |
| --- | --- | --- | --- |
| **LCP** | Largest Contentful Paint | How long until the biggest visible element (image, heading) appears | Under 2.5 seconds |
| **INP** | Interaction to Next Paint | How quickly the page responds when someone clicks or taps | Under 200 milliseconds |
| **CLS** | Cumulative Layout Shift | How much the page content jumps around as it loads | Under 0.1 |

### How to Check Your Scores

- **Google PageSpeed Insights** (pagespeed.web.dev) — enter your URL, get scores
  and specific recommendations.
- **Lighthouse** — built into Chrome/Edge DevTools (F12 → Lighthouse tab). Run
  on mobile and desktop.
- **Google Search Console** → Core Web Vitals report (shows scores for all pages
  as seen by real visitors).
- **WebPageTest** (webpagetest.org) — advanced testing with different locations
  and connection speeds.

---

## Image Optimisation

Images are typically the heaviest part of a web page. Poorly optimised images
are the #1 cause of slow websites.

### Rules

| Rule | Why |
| --- | --- |
| Use modern formats (WebP or AVIF) | 30–50% smaller than JPEG/PNG at the same quality |
| Resize images to the size they display | A 4000px image displayed at 800px wastes bandwidth |
| Compress images before upload | Tools: Squoosh (web), ShortPixel, TinyPNG |
| Use responsive images (`srcset`) | Serve smaller images to mobile devices |
| Lazy-load below-the-fold images | Don't load images the visitor hasn't scrolled to yet |
| Always set `width` and `height` attributes | Prevents layout shift (CLS) as images load |

### What "Lazy Loading" Means

By default, a browser loads ALL images on a page immediately — even ones at the
bottom that the visitor can't see yet. Lazy loading tells the browser: "Only
load this image when the visitor scrolls near it."

Add `loading="lazy"` to any image below the initial visible area:

```html
<img src="photo.webp" alt="Description" width="800" height="600" loading="lazy">
```

Do NOT lazy-load the first visible image (above the fold) — it should load
immediately for good LCP.

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

---

## CSS and JavaScript Performance

### CSS

- Load CSS in the `<head>` (so the browser knows how to style the page before
  showing content).
- Minimise CSS file size — remove unused rules (tools: PurgeCSS, UnCSS).
- Avoid `@import` inside CSS files (causes sequential loading — slow).
- For critical styles needed immediately, consider inlining them in the HTML.

### JavaScript

- JavaScript blocks rendering by default. A large script stops the page from
  appearing until it downloads and runs.
- Add `defer` to script tags (loads in parallel, runs after HTML is parsed):

```html
<script src="main.js" defer></script>
```

- Add `async` only for scripts that don't depend on other scripts (e.g.
  analytics — loads and runs as soon as ready, order not guaranteed).
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
- `Cache-Control: public, max-age=3600` for HTML pages (shorter — so visitors
  see updates within an hour).

### CDN (Content Delivery Network)

A CDN copies your website files to servers all around the world. When someone in
Sydney visits your site, they get files from a server in Sydney — not London.

**What it is:** A network of servers in many countries that serve your files from
the closest location to each visitor.

**Why it helps:**

- Faster load times for visitors far from your origin server.
- Reduces load on your hosting server.
- Often includes DDoS protection (stops attacks that try to overwhelm your site).

**Popular CDNs:** Cloudflare (free tier available), Fastly, AWS CloudFront,
Bunny CDN.

**For static sites:** Platforms like Netlify, Cloudflare Pages, and Vercel
include a CDN by default — no extra setup needed.

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

---

## Performance Budget

A performance budget is a rule your team sets: "Our pages will never exceed
these limits."

| Metric | Budget (suggested) |
| --- | --- |
| Total page weight | Under 1.5 MB |
| Number of HTTP requests | Under 50 |
| Largest Contentful Paint | Under 2.5 seconds |
| Time to Interactive | Under 5 seconds on 4G |
| JavaScript total | Under 300 KB (compressed) |

Write your budget down. Check it monthly. If a new feature pushes you over
budget, something else must be optimised or removed.

---

## Platform-Specific Notes

### WordPress

- Use a caching plugin (WP Super Cache, W3 Total Cache, or LiteSpeed Cache).
- Use an image optimisation plugin (ShortPixel, Imagify, or Smush).
- Minimise plugins — every plugin adds CSS and JavaScript.
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
- Accept that these platforms may never score 100 on Lighthouse — aim for
  "good enough" (green scores on Core Web Vitals).

### eCommerce (Shopify, WooCommerce, BigCommerce)

- Product images are usually the biggest performance issue — optimise them.
- Limit apps/plugins (each adds scripts).
- Use built-in lazy loading if available.
- Test product listing pages (many images) and checkout flow separately.

---

## Performance Checklist for Launch

Before going live:

- [ ] Run Lighthouse on mobile — all Core Web Vitals are green.
- [ ] All images are optimised (modern format, correct size, compressed).
- [ ] Images below the fold use lazy loading.
- [ ] Fonts use `font-display: swap` and WOFF2 format.
- [ ] JavaScript uses `defer` or `async`.
- [ ] Unused CSS and JavaScript is removed.
- [ ] Caching headers are configured.
- [ ] Page weight is under 1.5 MB.
- [ ] Test on a real mobile device (or simulated slow connection).
- [ ] Someone is named as the performance maintenance owner.

---

## Ongoing Performance Maintenance

| Frequency | Action |
| --- | --- |
| Monthly | Run Lighthouse, review scores, check page weight |
| Quarterly | Audit third-party scripts (are they all still needed?) |
| On every deployment | Verify no performance regression (LCP still green) |
| On every new feature | Check: does this add weight? Is it within budget? |
| Annually | Review performance budget — update targets if needed |

---

## Interpreting a Lighthouse Report

When you run Lighthouse, you get scores from 0–100:

| Score Range | Meaning | Action |
| --- | --- | --- |
| 90–100 (green) | Good | Maintain — no urgent action |
| 50–89 (orange) | Needs improvement | Review specific recommendations |
| 0–49 (red) | Poor | Prioritise fixes — significant user impact |

Lighthouse also provides **specific recommendations** ranked by estimated impact.
Start with the highest-impact item and work down.

**Common recommendations and what they mean:**

- "Serve images in next-gen formats" → Convert to WebP/AVIF.
- "Eliminate render-blocking resources" → Defer JavaScript, inline critical CSS.
- "Reduce unused CSS/JavaScript" → Remove libraries or features you don't use.
- "Properly size images" → Resize to display dimensions.
- "Enable text compression" → Configure gzip/Brotli on your server.

---

## Critical Constraints

- Never sacrifice usability for performance (don't remove content people need).
- Never ignore mobile performance (most web traffic is mobile).
- Never add features without considering their performance cost.
- Always measure before and after changes (don't guess — test).
- Always have a performance budget, even informal.
- Always optimise images — there is no excuse for unoptimised images in 2025+.

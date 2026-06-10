# Skill: Website Analytics and Measurement

## Purpose

This skill helps **complete beginners** understand how to measure what happens on
their website â€” who visits, what they do, and whether the site is achieving its
goals.

It covers privacy-respecting analytics tools, consent requirements by geography,
and how to interpret data without a statistics background.

**Currentness warning:** Analytics tools, pricing, privacy features, consent
requirements, browser tracking restrictions, advertising integrations, and
platform policies change over time. Before choosing or configuring analytics,
verify current information from the tool provider and relevant legal/privacy
sources, then record the date checked in the project documentation.

---

## Audience

- Complete beginners who have never used an analytics tool.
- Small business owners who need to know if their website is working.
- Anyone who wants to measure website performance without violating privacy law.

---

## Types of Website Measurement

Beginners often use the word "analytics" for everything, but website
measurement has several parts.

| Measurement Type | What It Answers | Example Tools |
| --- | --- | --- |
| Website analytics | What do visitors do after arriving? | Plausible, Fathom, Matomo, Google Analytics |
| Search visibility | How does the site appear in search engines? | Google Search Console, Bing Webmaster Tools |
| Conversion tracking | Did visitors complete the goal action? | Analytics goals, ad platform conversion tags, form tracking |
| Advertising measurement | Did paid campaigns produce useful results? | Google Ads, Meta Ads, LinkedIn Ads |
| Technical monitoring | Is the site fast, available, and error-free? | Uptime tools, PageSpeed Insights, Search Console |

A complete measurement setup usually needs more than one tool. For example,
analytics can show that visitors arrived from Google, but Google Search
Console can show which search queries and pages generated impressions.

---

## Why Measurement Matters

Without analytics, you are guessing:

- You don't know if anyone visits your site.
- You don't know which pages they look at.
- You don't know where they come from (search engine? social media? direct?).
- You don't know if your promotion efforts are working.
- You don't know if your site is achieving its purpose (sales, enquiries, signups).

**The goal of analytics is not to collect data â€” it is to make better decisions.**

---

## What to Measure (and Why)

| Metric | What It Means | Why It Matters |
| --- | --- | --- |
| **Visitors (unique users)** | How many different people visited | Shows overall reach |
| **Page views** | Total pages loaded across all visits | Shows how much content is consumed |
| **Traffic sources** | Where visitors came from (search, social, direct, referral) | Shows which promotion channels work |
| **Top pages** | Which pages get the most visits | Shows what content resonates |
| **Bounce rate** | Percentage who leave after viewing one page | May indicate content mismatch or slow loading |
| **Average time on page** | How long people spend reading | Indicates engagement with content |
| **Conversions** | Visitors who complete your goal action (form, purchase, signup) | The ultimate measure of success |
| **Device/browser** | What devices and browsers visitors use | Informs testing priorities |
| **Geography** | Which countries/cities visitors are from | Confirms you're reaching target audience |

### What "Conversion" Means

A conversion is when a visitor does the specific thing your website exists to
achieve:

- **Service business:** Submits a contact or enquiry form.
- **eCommerce:** Completes a purchase.
- **Newsletter:** Signs up with their email address.
- **Portfolio:** Clicks "hire me" or views contact details.
- **Restaurant:** Clicks to book, view menu, or get directions.

Define YOUR conversion before setting up analytics. Without this, you're
collecting data with no purpose.

### Conversion Quality

Not all conversions are equally valuable.

For example:

- A spam form submission is not a real lead.
- A newsletter signup from the wrong audience may not help.
- A purchase that is refunded may not be profitable.
- A phone call from outside the service area may not be useful.

Where possible, review both quantity and quality of conversions.

---

## Search Visibility Tools

Analytics tools tell you what visitors do after they arrive. Search
visibility tools tell you how search engines see your site.

### Google Search Console

Google Search Console is a free tool from Google. It helps you understand:

- which pages are indexed by Google,
- which search queries show your site,
- how often pages appear in search results,
- how often people click from search results,
- whether Google found mobile usability, indexing, or Core Web Vitals issues,
- whether your sitemap was submitted and processed.

Every public website that cares about Google search visibility should use
Google Search Console.

### Bing Webmaster Tools

Bing Webmaster Tools is a free tool from Microsoft. It provides similar
search visibility information for Bing and related search experiences.

It is worth setting up because it is free, quick, and can reveal indexing or
SEO issues that analytics alone will not show.

### Beginner Setup Checklist

- [ ] Create Google Search Console property.
- [ ] Verify domain or URL ownership.
- [ ] Submit sitemap.
- [ ] Check indexing status.
- [ ] Create Bing Webmaster Tools account.
- [ ] Import or verify the site.
- [ ] Submit sitemap to Bing.
- [ ] Record setup date and account owner.

---

## Analytics Tools

### Privacy-Respecting Alternatives

These tools are designed to reduce privacy risk. Many are cookie-free or
privacy-preserving, which may reduce or remove the need for analytics cookie
consent in some jurisdictions.

However, do not assume "privacy-friendly" automatically means "no consent or
disclosure needed." Check whether the tool uses cookies, local storage, IP
addresses, device identifiers, cross-site tracking, or third-party data
sharing. Always disclose analytics use in the privacy policy.

| Tool | Cost | Cookie-Free | Hosted By | Notes |
| --- | --- | --- | --- | --- |
| **Plausible** | From â‚¬9/month | Yes | EU (or self-host) | Simple, lightweight, GDPR-friendly |
| **Fathom** | From $14/month | Yes | Canada/EU | Privacy-first, simple dashboard |
| **Umami** | Free (self-hosted) or from $9/month | Yes | Your server or cloud | Open source |
| **Simple Analytics** | From â‚¬9/month | Yes | Netherlands | Minimal data collection |
| **GoatCounter** | Free (small sites) or â‚¬5/month | Yes | EU | Lightweight, open source |
| **Matomo** | Free (self-hosted) or from â‚¬19/month | Optional | Your server or EU cloud | Full-featured GA alternative |

### Google Analytics (GA4)

| Aspect | Detail |
| --- | --- |
| Cost | Free |
| Privacy | Uses cookies â€” requires consent in EU/UK/many jurisdictions |
| Data sharing | Google uses data for its own purposes |
| Complexity | Powerful but overwhelming for beginners |
| Cookie banner | Required in most countries |

**When to use Google Analytics:** If you need advanced features (eCommerce
tracking, audience segments, integration with Google Ads) and are willing to
implement proper cookie consent.

**When to avoid it:** If you want simplicity, don't want a cookie banner, or
are uncomfortable with Google having access to your visitor data.

### Choosing the Right Tool

| Situation | Recommended Approach |
| --- | --- |
| Simple site, want no cookie banner | Plausible, Fathom, or Simple Analytics |
| Budget-conscious, technical skill | Umami or GoatCounter (self-hosted) |
| eCommerce with Google Ads | Google Analytics (with proper consent) |
| Full control, self-hosted preference | Matomo self-hosted |
| Non-technical, want simplicity | Plausible or Fathom (managed) |

---

## Consent Requirements by Geography

Whether you need a cookie consent banner depends on what analytics tool you use
and where your visitors are located.

### The Simple Rule

- If analytics uses cookies, local storage, device identifiers, advertising
  identifiers, pixels, remarketing, profiling, or cross-site tracking, expect
  consent and disclosure requirements in many jurisdictions.
- If analytics collects personal data, such as full IP addresses or unique
  identifiers, assess privacy-law obligations before launch.
- If analytics is genuinely cookie-free, aggregate-only, and
  privacy-preserving, consent may not be required in some jurisdictions, but
  disclosure in the privacy policy is still recommended.
- If advertising tools are connected, such as Google Ads, Meta Pixel, TikTok
  Pixel, or LinkedIn Insight Tag, treat the setup as higher-risk and verify
  consent requirements carefully.

### By Region

| Region | Requirement | Applies To |
| --- | --- | --- |
| **EU/EEA** (GDPR + ePrivacy) | Explicit consent before setting non-essential cookies | Any site with EU visitors |
| **UK** (UK GDPR + PECR) | Same as EU â€” explicit consent for cookies | Any site with UK visitors |
| **California** (CPRA) | Must disclose data collection; opt-out right; no consent needed for analytics | Sites with California visitors |
| **Canada** (PIPEDA) | Implied consent acceptable for basic analytics | Sites with Canadian visitors |
| **Australia** (Privacy Act) | No specific cookie law, but must disclose collection in privacy policy | Sites with Australian visitors |
| **Brazil** (LGPD) | Consent required for personal data processing | Sites with Brazilian visitors |
| **South Africa** (POPIA) | Consent or legitimate interest for processing | Sites with SA visitors |
| **Singapore** (PDPA) | Consent for personal data; aggregate data exempt | Sites with Singapore visitors |

### Practical Advice

- If you use a **cookie-free analytics tool** (Plausible, Fathom, etc.) â†’ you
  likely don't need a cookie consent banner for analytics.
- If you use **Google Analytics** â†’ you need a cookie consent banner for EU/UK
  visitors (at minimum).
- If your site targets multiple countries â†’ comply with the strictest applicable
  law.
- When in doubt, get legal advice specific to your situation.

See `website-privacy-legal.skill.md` for comprehensive privacy law details.

---

## Analytics Consent Decision Tree

Use this decision tree before installing analytics.

1. Does the tool set cookies, local storage, pixels, device IDs, or other
   identifiers?
   - If yes, consent may be required in EU/UK-style jurisdictions and
     disclosure is required in many others.
2. Does the tool collect IP addresses, user IDs, device information, or
   browsing behaviour?
   - If yes, treat it as personal data risk until confirmed otherwise.
3. Is the tool connected to advertising, remarketing, audience building, or
   cross-site tracking?
   - If yes, expect stronger consent, disclosure, and opt-out requirements.
4. Does the site use Google Ads, Meta Pixel, LinkedIn Insight Tag, TikTok
   Pixel, or similar marketing tags?
   - If yes, check current platform consent requirements before launch.
5. Is the analytics tool genuinely cookie-free and aggregate-only?
   - If yes, consent may not be required in some jurisdictions, but still
     document the decision and disclose the tool in the privacy policy.
6. Are visitors expected from multiple countries or regions?
   - If yes, apply the strictest sensible baseline or get legal advice.

---

## UTM Tracking

UTM tracking means adding small labels to links so analytics tools can show
which campaign, channel, or source sent the visitor.

UTM tracking is useful for:

- email newsletters,
- social media posts,
- paid ads,
- partner links,
- QR codes,
- printed flyers,
- launch announcements.

Example use cases:

| Situation | What UTM Tracking Helps Answer |
| --- | --- |
| Email newsletter | Which newsletter sent traffic or conversions? |
| Social post | Which platform or post worked best? |
| Paid ad | Which campaign produced enquiries or sales? |
| QR code on flyer | Did offline promotion send visitors to the site? |
| Partner link | Which partner referred useful traffic? |

Beginner rules:

- Use consistent names.
- Do not put personal data in UTM parameters.
- Record naming conventions in the analytics setup document.
- Test campaign links before publishing them.
- Use UTMs for campaign links, not for every internal website link.

---

## Setting Up Analytics

### Step-by-Step (Generic)

1. **Choose your tool** based on privacy needs, budget, and complexity tolerance.
2. **Create an account** on your chosen platform.
3. **Add the tracking code** to your website (usually a small script in the `<head>`).
4. **Verify it's working** â€” visit your site and check if the visit appears in
   the dashboard.
5. **Set up goals/conversions** â€” define what "success" means (form submission,
   purchase, signup).
6. **Wait** â€” you need at least 2â€“4 weeks of data before drawing conclusions.

### Internal Traffic

Internal traffic means visits from the website owner, staff, developers,
agencies, or regular testers.

Internal traffic can distort analytics, especially on small websites. If the
owner visits the site ten times per day, the dashboard may look healthier
than reality.

Where the analytics tool supports it:

- filter internal IP addresses,
- exclude known team devices,
- label test traffic,
- avoid counting staging or preview sites,
- document what was excluded and when.

If filtering is not available, interpret low-volume analytics cautiously.

### Where to Put the Tracking Code

- **Static HTML:** In the `<head>` section of every page (or your template).
- **WordPress:** Use a plugin (e.g. "Insert Headers and Footers") or your
  theme's custom code area.
- **Squarespace/Wix/Webflow:** Built-in "tracking code" or "analytics" setting.
- **Static site generators:** In the base template/layout file.

### Cookie Consent Integration

If your analytics tool requires cookies and you have visitors from the EU/UK:

1. Do NOT load the analytics script until the visitor gives consent.
2. Use a consent management tool (Cookiebot, CookieYes, Osano, or a platform's
   built-in consent tool).
3. Only fire analytics after the "Accept" action.
4. Provide a "Reject" or "Necessary only" option.
5. Remember the choice so you don't ask again every visit.

---

## Interpreting Your Data

### Avoid Common Misinterpretations

| What You See | What Beginners Think | What It Usually Means |
| --- | --- | --- |
| Low visitor count in week 1 | "My site is failing" | Normal â€” traffic takes time to build |
| High bounce rate on blog posts | "People hate my content" | Often normal â€” they found their answer and left |
| Traffic spike one day | "My strategy is working!" | May be a bot, a single share, or an anomaly â€” wait for trends |
| Zero conversions | "Nobody wants what I offer" | Your conversion action may be unclear or broken |

### Bots, Crawlers, and Spam Traffic

Not every visit is a real potential customer or reader.

Traffic spikes can come from:

- search engine crawlers,
- uptime monitors,
- spam bots,
- security scanners,
- broken referral spam,
- internal testing,
- accidental repeated refreshes.

Before treating a traffic spike as success, check:

- where the traffic came from,
- which pages were visited,
- how long visits lasted,
- whether conversions increased,
- whether the traffic source looks legitimate.

Do not make major decisions based on a single unexplained spike.

### Rules for Data Interpretation

1. **Look at trends, not single days.** One bad day means nothing. A declining
   month means something.
2. **Compare like with like.** Compare this month to last month, or this
   Tuesday to last Tuesday â€” not Tuesday to Saturday.
3. **Ask "so what?"** Every metric should lead to a decision. If you can't act
   on the number, stop looking at it.
4. **Small sample sizes lie.** 10 visitors is not enough to draw conclusions.
   Wait for meaningful volume (at least 100+ for basic patterns).
5. **Context matters.** A seasonal business will naturally have peaks and
   troughs. A news site will spike on events.
6. **Separate traffic from outcomes.** More visitors is not automatically
   better. A smaller number of visitors who enquire, buy, book, or subscribe
   may be more valuable than a large number who leave immediately.
7. **Watch for tracking changes.** If analytics suddenly changes after a site
   update, plugin change, cookie banner change, or platform migration, the
   tracking setup may have changed â€” not visitor behaviour.
8. **Do not compare incompatible data.** Data from one analytics tool may not
   match another because tools count visitors, sessions, bots, consented
   traffic, and blocked traffic differently.

### Monthly Review Process

Set a recurring calendar reminder to review analytics monthly:

1. How many visitors this month vs. last month?
2. Where did they come from? (Which channels are growing?)
3. What were the top pages? (What content resonates?)
4. How many conversions? (Is the site achieving its purpose?)
5. Any technical issues? (Error pages, slow pages, broken forms?)
6. One action to take this month based on what the data shows.

See `website-monthly-review.prompt.md` for a complete structured review.

---

## Privacy-Respecting Analytics Best Practices

1. **Collect only what you need.** Don't track everything "just in case."
2. **Anonymise where possible.** Don't store full IP addresses unless required.
3. **Be transparent.** Your privacy policy must describe what you collect, why,
   and how long you keep it.
4. **Provide opt-out.** Even with cookie-free analytics, offer an opt-out for
   visitors who want zero tracking.
5. **Don't share data with third parties** unless your privacy policy explicitly
   says so and (where required) you have consent.
6. **Delete data you no longer need.** Set retention periods (e.g. 12 or 24
   months) and auto-purge.
7. **Document your choices.** Write down which tool you use, why you chose it,
   what consent mechanism (if any) you implemented, and when you last reviewed it.

---

## What NOT to Track

- **Personal data you don't need.** Don't collect names, emails, or IP addresses
  in your analytics unless there's a specific business purpose.
- **Sensitive categories.** Never infer or track health conditions, political
  views, sexual orientation, religious beliefs, or ethnicity through analytics.
- **Individual behaviour profiles.** Analytics should show you aggregate patterns
  (what "visitors" do), not individual surveillance (what "John" does).
- **Everything "just in case."** More data = more privacy risk, more consent
  requirements, more storage cost. Collect purposefully.

---

## Analytics Checklist for Launch

Before going live:

- [ ] Analytics tool chosen and installed.
- [ ] Search visibility tools set up, including Google Search Console and
      Bing Webmaster Tools where appropriate.
- [ ] Tracking code is loading correctly (verified with at least one test visit).
- [ ] Tracking tested on key pages and key conversion paths.
- [ ] Staging, preview, or test environments excluded where possible.
- [ ] Conversions/goals are defined and configured.
- [ ] Conversion quality review process defined.
- [ ] UTM naming convention documented for campaigns.
- [ ] Cookie consent mechanism is in place (if tool uses cookies).
- [ ] Analytics scripts are blocked before consent where required.
- [ ] Advertising pixels or remarketing tags are blocked before consent where
      required.
- [ ] Privacy policy describes analytics data collection.
- [ ] Data retention period is set.
- [ ] Internal traffic filtering configured where supported.
- [ ] Bot/spam traffic limitations understood and documented.
- [ ] Someone is named as the analytics review owner.
- [ ] Monthly review calendar reminder is set.

---

## Ongoing Analytics Maintenance

| Frequency | Action |
| --- | --- |
| Weekly during first month after launch | Check that analytics, forms, conversions, and search visibility tools are still working |
| Monthly | Review key metrics, traffic sources, conversions, conversion quality, and one action to take |
| Monthly | Check Google Search Console and Bing Webmaster Tools for indexing, sitemap, search query, and technical issues |
| Quarterly | Audit whether the analytics tool is still appropriate and whether goals still reflect the website purpose |
| Quarterly | Review UTM naming, campaign tracking, internal traffic filtering, and bot/spam anomalies |
| Quarterly | Check whether new third-party scripts, pixels, embeds, or marketing tools were added |
| On every new page/feature | Verify tracking works on new content and conversion paths |
| On every cookie/consent change | Verify analytics and advertising scripts respect consent choices |
| Annually | Review privacy compliance, data retention, analytics ownership, and privacy policy wording |
| On legal or platform changes | Re-check consent requirements, provider terms, and data processing details |

---

## Critical Constraints

- Never install analytics without updating your privacy policy.
- Never load cookie-based analytics before user consent in jurisdictions that
  require it.
- Never use analytics data to identify or profile individual visitors (unless
  they're logged-in customers who consented to this).
- Never ignore data â€” if you're not going to look at analytics monthly, don't
  collect it.
- Never make major decisions based on one day or one week of data.
- Always define what "success" means before collecting data.
- Always define what a high-quality conversion means, not just a conversion
  count.
- Always choose the simplest tool that answers your actual questions.
- Always comply with the strictest privacy law applicable to your visitors.
- Never assume privacy-friendly analytics means no privacy obligations.
- Never install advertising pixels, remarketing tags, heatmaps, or session
  replay tools without checking consent and privacy requirements.
- Never put personal data in UTM parameters.
- Never judge success from traffic alone; measure meaningful conversions.
- Never assume analytics data is exact; treat it as directional evidence.
- Always document analytics setup, consent decisions, data retention,
  conversion definitions, UTM conventions, and account ownership.

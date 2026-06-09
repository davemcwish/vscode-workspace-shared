# Skill: Website Analytics and Measurement

## Purpose

This skill helps **complete beginners** understand how to measure what happens on
their website — who visits, what they do, and whether the site is achieving its
goals.

It covers privacy-respecting analytics tools, consent requirements by geography,
and how to interpret data without a statistics background.

---

## Audience

- Complete beginners who have never used an analytics tool.
- Small business owners who need to know if their website is working.
- Anyone who wants to measure website performance without violating privacy law.

---

## Why Measurement Matters

Without analytics, you are guessing:

- You don't know if anyone visits your site.
- You don't know which pages they look at.
- You don't know where they come from (search engine? social media? direct?).
- You don't know if your promotion efforts are working.
- You don't know if your site is achieving its purpose (sales, enquiries, signups).

**The goal of analytics is not to collect data — it is to make better decisions.**

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

---

## Analytics Tools

### Privacy-Respecting Alternatives

These tools are designed to respect visitor privacy and often do not require
cookie consent banners (because they don't use cookies for tracking):

| Tool | Cost | Cookie-Free | Hosted By | Notes |
| --- | --- | --- | --- | --- |
| **Plausible** | From €9/month | Yes | EU (or self-host) | Simple, lightweight, GDPR-friendly |
| **Fathom** | From $14/month | Yes | Canada/EU | Privacy-first, simple dashboard |
| **Umami** | Free (self-hosted) or from $9/month | Yes | Your server or cloud | Open source |
| **Simple Analytics** | From €9/month | Yes | Netherlands | Minimal data collection |
| **GoatCounter** | Free (small sites) or €5/month | Yes | EU | Lightweight, open source |
| **Matomo** | Free (self-hosted) or from €19/month | Optional | Your server or EU cloud | Full-featured GA alternative |

### Google Analytics (GA4)

| Aspect | Detail |
| --- | --- |
| Cost | Free |
| Privacy | Uses cookies — requires consent in EU/UK/many jurisdictions |
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

- If your analytics tool uses cookies or collects personal data → you need consent.
- If your analytics tool is cookie-free and collects only anonymous aggregate
  data → consent is usually not required (but check your specific jurisdiction).

### By Region

| Region | Requirement | Applies To |
| --- | --- | --- |
| **EU/EEA** (GDPR + ePrivacy) | Explicit consent before setting non-essential cookies | Any site with EU visitors |
| **UK** (UK GDPR + PECR) | Same as EU — explicit consent for cookies | Any site with UK visitors |
| **California** (CPRA) | Must disclose data collection; opt-out right; no consent needed for analytics | Sites with California visitors |
| **Canada** (PIPEDA) | Implied consent acceptable for basic analytics | Sites with Canadian visitors |
| **Australia** (Privacy Act) | No specific cookie law, but must disclose collection in privacy policy | Sites with Australian visitors |
| **Brazil** (LGPD) | Consent required for personal data processing | Sites with Brazilian visitors |
| **South Africa** (POPIA) | Consent or legitimate interest for processing | Sites with SA visitors |
| **Singapore** (PDPA) | Consent for personal data; aggregate data exempt | Sites with Singapore visitors |

### Practical Advice

- If you use a **cookie-free analytics tool** (Plausible, Fathom, etc.) → you
  likely don't need a cookie consent banner for analytics.
- If you use **Google Analytics** → you need a cookie consent banner for EU/UK
  visitors (at minimum).
- If your site targets multiple countries → comply with the strictest applicable
  law.
- When in doubt, get legal advice specific to your situation.

See `website-privacy-legal.skill.md` for comprehensive privacy law details.

---

## Setting Up Analytics

### Step-by-Step (Generic)

1. **Choose your tool** based on privacy needs, budget, and complexity tolerance.
2. **Create an account** on your chosen platform.
3. **Add the tracking code** to your website (usually a small script in the `<head>`).
4. **Verify it's working** — visit your site and check if the visit appears in
   the dashboard.
5. **Set up goals/conversions** — define what "success" means (form submission,
   purchase, signup).
6. **Wait** — you need at least 2–4 weeks of data before drawing conclusions.

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
| Low visitor count in week 1 | "My site is failing" | Normal — traffic takes time to build |
| High bounce rate on blog posts | "People hate my content" | Often normal — they found their answer and left |
| Traffic spike one day | "My strategy is working!" | May be a bot, a single share, or an anomaly — wait for trends |
| Zero conversions | "Nobody wants what I offer" | Your conversion action may be unclear or broken |

### Rules for Data Interpretation

1. **Look at trends, not single days.** One bad day means nothing. A declining
   month means something.
2. **Compare like with like.** Compare this month to last month, or this
   Tuesday to last Tuesday — not Tuesday to Saturday.
3. **Ask "so what?"** Every metric should lead to a decision. If you can't act
   on the number, stop looking at it.
4. **Small sample sizes lie.** 10 visitors is not enough to draw conclusions.
   Wait for meaningful volume (at least 100+ for basic patterns).
5. **Context matters.** A seasonal business will naturally have peaks and
   troughs. A news site will spike on events.

### Monthly Review Process

Set a recurring calendar reminder to review analytics monthly:

1. How many visitors this month vs. last month?
2. Where did they come from? (Which channels are growing?)
3. What were the top pages? (What content resonates?)
4. How many conversions? (Is the site achieving its purpose?)
5. Any technical issues? (Error pages, slow pages, broken forms?)
6. One action to take this month based on what the data shows.

See `monthly-website-review.prompt.md` for a complete structured review.

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
- [ ] Tracking code is loading correctly (verified with at least one test visit).
- [ ] Conversions/goals are defined and configured.
- [ ] Cookie consent mechanism is in place (if tool uses cookies).
- [ ] Privacy policy describes analytics data collection.
- [ ] Data retention period is set.
- [ ] Someone is named as the analytics review owner.
- [ ] Monthly review calendar reminder is set.

---

## Ongoing Analytics Maintenance

| Frequency | Action |
| --- | --- |
| Monthly | Review key metrics, identify one action to take |
| Quarterly | Audit: Is the analytics tool still appropriate? Are goals still relevant? |
| On every new page/feature | Verify tracking works on new content |
| Annually | Review privacy compliance, update privacy policy if collection changed |
| On legal changes | Check if consent requirements have changed for your audience geography |

---

## Critical Constraints

- Never install analytics without updating your privacy policy.
- Never load cookie-based analytics before user consent in jurisdictions that
  require it.
- Never use analytics data to identify or profile individual visitors (unless
  they're logged-in customers who consented to this).
- Never ignore data — if you're not going to look at analytics monthly, don't
  collect it.
- Never make major decisions based on one day or one week of data.
- Always define what "success" means before collecting data.
- Always choose the simplest tool that answers your actual questions.
- Always comply with the strictest privacy law applicable to your visitors.

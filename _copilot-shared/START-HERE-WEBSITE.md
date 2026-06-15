# Start Here: Building a Website with Copilot

## Read This First

This guide refers to a collection of Copilot artifacts: skills, prompts,
workflows, chat modes, agents, templates, and instruction files.

Some artifacts may already exist in this workspace. Others may be planned but
not installed yet.

Before following a reference to a prompt, workflow, or chat mode, check:

> `WEBSITE-ARTIFACT-MANIFEST.md`

That manifest tells you whether the artifact is installed, optional, missing, or
still to be created.

If Copilot seems unaware of an artifact, open the relevant file and explicitly
ask Copilot to use it as guidance. Some Copilot environments apply instruction
files automatically; others do not.

---

## Important Legal and Currentness Warning

The website artifacts provide general planning guidance. They do not provide
legal advice.

Anything involving privacy law, accessibility law, cookie consent, advertising
rules, platform pricing, hosting pricing, analytics tools, search engine
behaviour, or security standards can change over time.

Before making final decisions, verify current information from authoritative
sources and record:

- What was checked.
- Where it was checked.
- The date checked.
- The decision made.
- Who made the decision.

---

## What Is This?

This document is your entry point if you want to **design, build, launch,
promote, or maintain a website** using the Copilot-assisted workflow in this
workspace.

You do not need any prior experience with:

- website design or development,
- HTML, CSS, or JavaScript,
- hosting, domains, or DNS,
- content management systems (CMS),
- search engine optimisation (SEO),
- analytics or advertising,
- privacy law or accessibility legislation,
- social media marketing,
- Copilot, agents, prompts, or chat modes.

Everything is explained as you go.

---

## How This System Works (Plain English)

This workspace contains a set of **AI assistant instructions and reference
artifacts** that help guide Copilot (the AI built into VS Code) through every
stage of a website project.

Depending on your Copilot setup, some artifacts may be applied automatically.
Others may need to be opened manually or explicitly referenced in chat.

If Copilot seems unaware of an artifact, open the relevant file and tell Copilot
to use it as guidance.

Think of it like having access to a team of specialists:

| Specialist | What they do | How you talk to them | Status |
| --- | --- | --- | --- |
| Website Launch Planner | Guides you from idea to live site | Select the chat mode | Installed |
| Critical Thinking Partner | Challenges your assumptions before you commit | Type `@critical-thinking` or use the critical-thinking chat mode | Installed |
| SEO Reviewer | Checks whether people can find your site | Type `/website-seo-review` | Installed |
| Conversion Reviewer | Checks whether visitors take the action you want | Type `/website-conversion-review` | Installed |
| Local SEO Checker | Checks whether local customers can find you | Type `/website-local-seo-check` | Installed |
| Accessibility Reviewer | Checks whether everyone can use your site | Select the accessibility review chat mode | Installed |
| HTML/CSS Reviewer | Reviews your code for quality and standards | Type `/website-html-css-review` | Installed |
| Platform Decision Helper | Helps choose the right technology | Type `/website-platform-decision` | Installed |
| Monthly Website Reviewer | Runs a health check after launch | Type `/website-monthly-review` | Installed |
| Maintenance Plan Creator | Creates a post-launch care plan | Type `/website-maintenance-plan` | Installed |

If a listed specialist is not installed, check `WEBSITE-ARTIFACT-MANIFEST.md`
and either create the missing artifact or use the closest installed guidance
file manually.

You don't need to memorise all of these. This document tells you which to use
and when.

---

## How to Talk to Copilot (The Basics)

If you've never used Copilot before:

1. **Open VS Code** (the application you're reading this in).
2. **Open the Chat panel** - click the chat icon in the left sidebar, or press
   `Ctrl+Shift+I` (Windows) / `Cmd+Shift+I` (Mac).
3. **Choose a chat mode** - at the top of the Chat panel there's a dropdown.
   Pick the specialist you need (e.g. "Website Launch Planner").
4. **Type your question** - in plain English. No code needed.
5. **Use `/` for prompts** - type `/` followed by the prompt name to run a
   specific recipe (e.g. `/website-seo-review`).
6. **Use `@` for agents** - type `@` followed by the agent name to summon a
   specialist (e.g. `@critical-thinking`).

That's it. The AI reads the instruction files automatically and knows how to
guide you.

---

## The Website Lifecycle

Every website project follows this path. The artifacts in this workspace cover
every stage:

```text
1. THINK     - What is this website for? Who is it for? What country/region?
               Who needs accessible content?
2. CHALLENGE - Are my assumptions sound? (Critical thinking, incl. accessibility)
3. PLAN      - Platform, content, design, accessibility, legal, security, social
4. BUILD     - Create pages, write copy, add images, configure platform
5. SECURE    - Harden the site, check privacy/legal compliance
6. TEST      - Accessibility, performance, mobile, forms, links, browsers
7. LAUNCH    - Domain, SSL, DNS, accessibility gate, go live, verify
8. PROMOTE   - SEO, social media, advertising, email, offline promotion
9. MEASURE   - Analytics, conversions, search visibility
10. MAINTAIN - Monthly reviews, updates, security, accessibility regression
```

---

## Stage-by-Stage Guide: Which Artifacts to Use

Before using this guide, check `WEBSITE-ARTIFACT-MANIFEST.md`.

Some artifacts listed below may be installed already. Others may be planned but
not yet created. If an artifact is missing, use the related skill file or create
the missing prompt/workflow before relying on it.

### Stage 1: THINK - Define Your Website

**Start here. Do not write any code yet.**

| Action | How |
| --- | --- |
| Define purpose, audience, geography, and goals | Select chat mode: **Website Launch Planner** |
| Or run the one-shot planning prompt | Type `/website-from-idea-to-launch` |
| Help choose the right platform/technology | Type `/website-platform-decision` |

The planner will ask you about:

- What the website is for (leads, sales, information, bookings, etc.).
- Who the audience is and where they are (country, region, language).
- Whether any visitors will need accessible content (screen readers, keyboard
  navigation, captions, large text, or other assistive technology).
- What privacy and legal requirements apply in that geography.
- What accessibility laws apply (these vary by country and sector).
- What social media and online presence already exists.
- Who will maintain the site after launch.
- What your budget and timeline look like.

**You do not need to know the answers in advance.** The planner explains each
question and helps you decide.

### Stage 2: CHALLENGE - Test Your Assumptions

**Use this before committing to any major decision.**

| Action | How |
| --- | --- |
| Challenge platform choice, audience assumptions, design decisions | Type `@critical-thinking` in Chat |

The critical thinking partner will ask probing questions like:

- "Is this really the simplest platform that meets your needs?"
- "Can the person maintaining this site actually use this technology?"
- "Have you considered what privacy law requires in your target country?"
- "Have you considered what accessibility law requires in your target country
  or sector?"
- "Can everyone in your target audience use this site - including people with
  visual, motor, cognitive, or hearing differences?"
- "What happens if your hosting provider goes down - is there a backup plan?"

It never tells you what to do - it helps you think clearly.

### Stage 3: PLAN - Design, Content, Legal, Security

| Action | How |
| --- | --- |
| Full planning workflow | Read: `workflows/website-live-launch.workflow.md` |
| Content and copywriting guidance | Read: `skills/website-content-copywriting.skill.md` |
| Accessibility planning | Read: `skills/accessibility.skill.md` |
| Privacy and legal requirements | Read: `skills/website-privacy-legal.skill.md` |
| Security planning | Read: `skills/website-security.skill.md` |
| Performance planning | Read: `skills/website-performance.skill.md` |

Plan accessibility **now**, not after the build. Retrofitting accessibility is
harder and more expensive than building it in from the start. Consider:

- heading structure and reading order,
- colour contrast and text size,
- keyboard navigation and focus management,
- image alt text and captions,
- form labels and error messages,
- whether the chosen platform produces accessible output by default.

### Stage 4: BUILD - Create the Website

| Action | How |
| --- | --- |
| HTML/CSS/JS standards | Automatic - Copilot reads `html-css-javascript.instructions.md` when you edit web files |
| Accessibility standards | Read: `skills/accessibility.skill.md` |
| Review your HTML/CSS | Type `/website-html-css-review` in Chat |

### Stage 5: SECURE - Harden and Comply

| Action | How |
| --- | --- |
| Website security checklist | Read: `skills/website-security.skill.md` |
| Privacy and legal compliance | Read: `skills/website-privacy-legal.skill.md` |
| Challenge security assumptions | Type `@critical-thinking` and ask about security |

### Stage 6: TEST - Verify Everything Works

| Action | How |
| --- | --- |
| Accessibility review | Select chat mode: **accessibility-review** |
| HTML/CSS quality review | Type `/website-html-css-review` |
| Performance check | Read: `skills/website-performance.skill.md` |
| Conversion path check | Type `/website-conversion-review` |

### Stage 7: LAUNCH - Go Live

| Action | How |
| --- | --- |
| Full launch workflow | Read: `workflows/website-live-launch.workflow.md` |
| Pre-launch checklist | In the Website Launch Planner chat mode, Phase 8 |
| Accessibility gate | Run accessibility-review chat mode before publishing |

Do not launch without verifying: keyboard navigation works on every page,
focus is visible, images have alt text, forms have labels, and colour contrast
meets minimum ratios. These are launch blockers, not nice-to-haves.

### Stage 8: PROMOTE - Get Found

| Action | How |
| --- | --- |
| SEO review | Type `/website-seo-review` |
| Local SEO check | Type `/website-local-seo-check` |
| Promotion strategy | Read: `skills/website-promotion.skill.md` |
| Conversion review | Type `/website-conversion-review` |

### Stage 9: MEASURE - Track Results

| Action | How |
| --- | --- |
| Analytics guidance | Read: `skills/website-analytics.skill.md` |
| Monthly review | Type `/website-monthly-review` |

### Stage 10: MAINTAIN - Keep It Healthy

| Action | How |
| --- | --- |
| Create a maintenance plan | Type `/website-maintenance-plan` |
| Monthly health check | Type `/website-monthly-review` |
| Ongoing security | Read: `skills/website-security.skill.md` |
| Accessibility regression check | Select chat mode: **accessibility-review** after any content or layout change |

New content, updated pages, added widgets, or platform upgrades can break
accessibility. Re-check keyboard navigation, heading order, alt text, and
contrast whenever you change content - not only at launch.

---

## Documentation: Recording Your Decisions

Every discussion, decision, and rationale from your website project should be
recorded as **linked Markdown documents** that serve as complete offline
reference material.

See `workflows/website-documentation.workflow.md` for the full structure.

The key documents you'll produce:

| Document | Purpose |
| --- | --- |
| `website-brief.md` | Strategy, audience, geography, goals |
| `website-platform-decision.md` | Technology choice with reasoning |
| `website-legal-compliance.md` | Privacy, cookies, accessibility law |
| `website-security-plan.md` | Security measures and responsibilities |
| `website-content-plan.md` | Site map, copy, images, CTAs |
| `website-promotion-plan.md` | SEO, advertising, social, email |
| `website-launch-checklist.md` | Pre-launch verification |
| `website-maintenance-plan.md` | Post-launch care and review schedule |
| `website-decisions-log.md` | All decisions with reasoning |

---

## Planning Templates

Use these templates when a website effort needs lightweight planning records before, during, or after launch:

| Template | Use when | Output |
| --- | --- | --- |
| `templates/website-assumption-log.template.md` | You need to make implicit planning assumptions visible and testable | An assumption log with confidence, impact if wrong, validation method, owner, and status |
| `templates/website-cost-model.template.md` | You need to estimate launch, operating, vendor, or marketing costs | A one-time, monthly, annual, and first-year cost model |
| `templates/website-risk-register.template.md` | You need to track launch, security, privacy, accessibility, content, performance, or operational risks | A risk register with impact, likelihood, owner, mitigation, trigger, and status |
| `templates/website-decision-log.template.md` | You need to record why important website decisions were made | A decision log with alternatives, rationale, consequences, and revisit triggers |

### Suggested order

1. Start with the assumption log to make unknowns explicit.
2. Create the cost model for budget and vendor planning.
3. Create the risk register for high-impact or low-confidence items.
4. Use the decision log whenever a meaningful tradeoff is resolved.

Keep these templates linked to `WEBSITE-ARTIFACT-MANIFEST.md` so users can tell which artifacts are installed, optional, or planned.

## Quick-Start: Your First Session

If you're starting a brand new website project right now:

1. Open Copilot Chat.
2. Check whether the Website Launch Planner chat mode exists.
3. If it exists, select it and type: "I want to create a website. Please help
   me plan it from scratch."
4. If it does not exist, open `website-documentation.workflow.md` and start by
   creating `docs/01-website-brief.md`.
5. Answer the planning questions slowly. Do not rush platform choice.
6. When you have a proposed platform decision, use the critical-thinking
   artifact and ask: "Please challenge my platform choice for this website."
7. Record the decision and reasoning in the platform decision document.
8. Continue through legal, security, content, performance, analytics, promotion,
   launch, and maintenance planning.

---

## Reference: All Website Artifacts

### Skills (Training Manuals - Read Before Building)

| File | What It Covers |
| --- | --- |
| `skills/website-launch.skill.md` | Planning, platform choice, social presence, launch |
| `skills/website-growth.skill.md` | SEO, conversion, retention, improvement loop |
| `skills/website-security.skill.md` | HTTPS, headers, forms, CMS, hosting, dependencies |
| `skills/website-privacy-legal.skill.md` | GDPR, CPRA, cookie law, accessibility legislation |
| `skills/website-performance.skill.md` | Speed, Core Web Vitals, images, caching |
| `skills/website-promotion.skill.md` | SEO, paid ads, email, content marketing, offline |
| `skills/website-analytics.skill.md` | Measurement, tools, consent, interpretation |
| `skills/website-content-copywriting.skill.md` | Writing headlines, CTAs, pages, for beginners |
| `skills/accessibility.skill.md` | Making sites usable by everyone |
| `skills/html-css.skill.md` | HTML/CSS for static reports (not public websites) |
| `skills/html-css-static-report.skill.md` | Constraints for generated reports |

### Workflows (Step-by-Step Processes)

| File | When to Use |
| --- | --- |
| `workflows/website-live-launch.workflow.md` | Full idea-to-launch process |
| `workflows/website-documentation.workflow.md` | Recording decisions as reference docs |

### Chat Modes (Persistent Conversation Partners)

| File | When to Use |
| --- | --- |
| `chatmodes/website-launch-planner.chatmode.md` | Planning a new website |
| `chatmodes/accessibility-review.chatmode.md` | Reviewing accessibility |
| `chatmodes/critical-thinking.chatmode.md` | Challenging assumptions |

### Prompts (One-Shot Recipes)

| File | When to Use |
| --- | --- |
| `/website-from-idea-to-launch` | Quick full-project planning |
| `/website-platform-decision` | Choosing the right technology |
| `/website-seo-review` | Checking search engine readiness |
| `/website-local-seo-check` | Checking local search readiness |
| `/website-conversion-review` | Checking whether visitors convert |
| `/website-html-css-review` | Reviewing code quality |
| `/website-monthly-review` | Monthly health check |
| `/website-maintenance-plan` | Creating a maintenance routine |

### Instructions (Auto-Applied Rules)

| File | When It Activates |
| --- | --- |
| `instructions/html-css-javascript.instructions.md` | When you edit `.html`, `.css`, or `.js` files |
| `instructions/security.instructions.md` | When you edit any file (security rules) |

### Agents (Specialist Personas)

| Agent | When to Use |
| --- | --- |
| `@critical-thinking` | Before any major decision |

---

## Before You Start

Make sure the following are true:

- VS Code is open in the project workspace.
- Copilot Chat is open (click the chat icon in the sidebar, or press
  `Ctrl+Shift+I`).
- The custom chat modes are visible in the chat mode selector dropdown.
- The custom prompts are visible when you type `/` in the chat input.
- The `.github/` Markdown files are committed or saved in the workspace.

If the chat modes or prompts are not visible, try:

1. Save all `.github/` files.
2. Reload VS Code: open the Command Palette (`Ctrl+Shift+P`) and run
   `Developer: Reload Window`.
3. Reopen Copilot Chat.
4. Check the chat mode dropdown and prompt list again.

---

## What Not To Do

Do not start with:

```text
Write me an HTML file.
```

unless the website has already been planned.

Avoid jumping straight to:

- HTML, CSS, JavaScript, React,
- hosting setup, domain setup,
- CMS plugins, custom web applications,
- a specific global platform, hosting provider, or payment provider.

First confirm:

- purpose, audience, country or region, legal business location, visitor
  location,
- language, currency, tax or payment needs, privacy and cookie expectations,
- accessibility expectations, platform, content, maintenance, hosting, launch
  needs,
- social media and online presence, existing social profiles, reviews,
  testimonials, social sharing previews, and the social media maintenance owner.

---

## Example Full Copilot Conversation

Copy and paste this into Copilot Chat after selecting `website-launch-planner`
mode:

```text
I want to plan a website from idea to live launch.

Please use the website launch workflow and guide me step by step.

Here is what I know so far:
- Business type:
- Main goal:
- Target audience:
- Country or region the website is mainly for:
- Where the business is legally based:
- Where most visitors are expected to be:
- Languages:
- Currency:
- Tax requirements, if known:
- Whether local payment methods are needed:
- Whether local customer support matters:
- Whether regional data hosting matters:
- Privacy, cookie, accessibility, or legal-page requirements, if known:
- Existing social media profiles:
- Which social platforms bring enquiries, bookings, sales, traffic, or trust:
- Whether the website should link to social profiles:
- Whether social profiles should link back to the website:
- Whether reviews, testimonials, or social proof are needed:
- Whether a "link in bio" page is needed:
- Whether social advertising or tracking pixels are planned:
- Who will maintain social media and respond to messages:
- Who will maintain the website:
- Whether payments are needed:
- Whether forms are needed:
- Whether users need accounts:
- Preferred launch date:
- Budget or constraints:

Please ask me any missing questions before recommending a platform. When you
recommend a platform, compare globally popular options with relevant local or
regional alternatives if country-specific needs matter.
```

If you do not know the answers, write:

```text
I do not know yet. Please explain the options in beginner-friendly language.
```

---

## Manual Pre-Launch Checklist

Before launch, confirm:

- [ ] Website objective is clear.
- [ ] Target audience is clear.
- [ ] Geographic scope is clear.
- [ ] Business legal location is documented.
- [ ] Main visitor country or region is documented.
- [ ] Local language needs are confirmed.
- [ ] Local currency needs are confirmed.
- [ ] Tax, VAT, GST, or sales-tax needs are considered.
- [ ] Local payment methods are considered if payments are needed.
- [ ] Local privacy and cookie expectations are checked.
- [ ] Local accessibility expectations are checked.
- [ ] Local legal-page expectations are checked.
- [ ] Hosting or data-storage region needs are considered.
- [ ] Local customer support needs are considered.
- [ ] Platform choice is documented, including why it fits the country or region.
- [ ] Site map is approved.
- [ ] All required pages exist.
- [ ] All text content is final or approved.
- [ ] Images are approved and compressed.
- [ ] Images have alt text.
- [ ] Navigation works.
- [ ] Contact forms work.
- [ ] Links work.
- [ ] Mobile layout works.
- [ ] Tablet layout works.
- [ ] Desktop layout works.
- [ ] Keyboard navigation works.
- [ ] Focus indicators are visible.
- [ ] Color contrast is acceptable.
- [ ] Privacy policy exists if needed.
- [ ] Cookie notice exists if needed.
- [ ] Page titles are set.
- [ ] Meta descriptions are set if needed.
- [ ] Analytics are configured if needed.
- [ ] Domain is connected.
- [ ] SSL certificate is active.
- [ ] Backup or rollback plan exists.
- [ ] Site owner knows how to maintain the site.
- [ ] Approved social media profiles are documented.
- [ ] Website links to approved social media profiles.
- [ ] Social media profiles link back to the website.
- [ ] Business name, logo, contact details, and opening hours are consistent
  across website and social profiles.
- [ ] Social sharing preview title, description, and image are checked.
- [ ] Reviews, testimonials, or social proof are approved for use.
- [ ] Embedded social feeds are avoided unless there is a clear reason.
- [ ] Any tracking pixels, social ads, or campaign links are approved and
  documented.
- [ ] Someone owns social media updates and message responses after launch.

---

## Beginner-Friendly Platform Guidance

Use this table when explaining options to non-technical users. Treat provider
names as examples, not as the only valid choices.

| Option | Examples | Best For | Beginner Warning |
| --- | --- | --- | --- |
| No-code website builder | Wix, Squarespace, or trusted local equivalents | Simple brochure websites maintained by non-technical users | May be less flexible for complex custom features |
| Content management system | WordPress or regionally popular CMS platforms | Content-heavy sites, blogs, and growing websites | Needs updates, backups, plugins, and maintenance |
| Managed WordPress hosting | Local or regional WordPress hosting providers | Users who want WordPress but need easier hosting and support | Quality varies; check support, backups, SSL, and security |
| eCommerce platform | Shopify, WooCommerce, or local eCommerce platforms | Online stores, product catalogues, payments, tax, and shipping | Must support local currency, tax, payment methods, and shipping needs |
| Local hosting provider | Country-specific hosting companies | Sites needing local support, local billing, or regional data hosting | Check reliability, backups, SSL, support quality, and security |
| Static HTML/CSS | GitHub Pages, Netlify, Cloudflare Pages, local hosting | Fast simple sites maintained by a developer | Harder for non-technical users to update |
| Generated static report | Python-generated HTML/CSS report files | Read-only internal reporting | Not a full website and usually not intended for public launch |
| Local web app | Flask, FastAPI, or similar internal application | Internal workflows or tools that need interaction | Not ideal for a simple public marketing website |
| Custom web app | Custom application hosted on a cloud, internal, or regional provider | Accounts, dashboards, workflows, integrations, or complex business logic | Highest cost and maintenance burden |

The recommended platform should normally be the simplest sustainable option that
meets the user's objective, the target audience's needs, the maintainer's
technical skill level, the country or region requirements, and the budget and
timeline.

---

## Key Concepts for Complete Beginners

| Term | What It Means |
| --- | --- |
| Website | A collection of pages on the internet that people visit using a browser (Chrome, Safari, Firefox, Edge) |
| Domain | The address people type to find your site (e.g. `example.com`) - you rent it annually |
| Hosting | Where your website files live - a computer (server) connected to the internet 24/7 |
| SSL / HTTPS | Security that encrypts the connection between visitors and your site - the padlock icon in the browser |
| CMS | Content Management System - software that lets you edit website pages without writing code (e.g. WordPress) |
| SEO | Search Engine Optimisation - making your site easier for Google/Bing to find and show to searchers |
| Analytics | Tools that tell you how many people visit, what they look at, and what they do |
| Accessibility | Making your site usable by people with disabilities (screen readers, keyboard navigation, colour contrast) |
| Privacy law | Rules about how you collect and use visitor data (different in every country) |
| CTA | Call To Action - the thing you want visitors to do (call, buy, book, subscribe, download) |
| Responsive | A design that works well on phones, tablets, and desktop computers |
| DNS | Domain Name System - the internet's address book that connects your domain name to your hosting server |

---

## What Happens Next

### Currentness Rule

The artifacts are designed to be durable, but the world changes.

Always verify current information before final decisions involving:

- privacy law,
- accessibility law,
- cookie consent,
- advertising rules,
- platform pricing,
- hosting pricing,
- analytics tools,
- payment providers,
- search engine behaviour,
- security standards,
- software versions.

Record the date checked in the relevant project document.

### Next Steps

After reading this document, your next step is:

1. **Open Copilot Chat** and select the **Website Launch Planner** chat mode.
2. **Tell it what you want** - in plain English, no jargon needed.
3. **Follow the conversation** - it will guide you through every decision.
4. **Document everything** - follow `workflows/website-documentation.workflow.md`
   to keep a permanent record.

You can return to this document at any time as a reference map.

<!-- WEBSITE-PROMPT-COVERAGE-INDEX:START -->
## Website Prompt Coverage Index

Use these prompts based on the kind of website work you are doing.

### Start, Plan, Maintain, and Govern

- `prompts/website-from-idea-to-launch.prompt.md`
- `prompts/website-monthly-review.prompt.md`
- `prompts/website-maintenance-plan.prompt.md`
- `prompts/website-governance-review.prompt.md`
- `prompts/website-documentation-review.prompt.md`
- `prompts/website-change-management-review.prompt.md`
- `prompts/website-qa-review.prompt.md`

## Website Prompt Library Index

Use this quick index when you know what kind of website help you need.

| Need | Start with |
| --- | --- |
| Plan a new website | `/website-from-idea-to-launch` |
| Choose a platform or stack | `/website-platform-decision` |
| Improve search visibility | `/website-seo-review` |
| Improve local search visibility | `/website-local-seo-check` |
| Improve conversions or lead capture | `/website-conversion-review` |
| Review copy and page messaging | `/website-copy-review` |
| Review forms and submissions | `/website-forms-submissions-review` |
| Review accessibility remediation | `/website-accessibility-remediation-review` |
| Review performance and page speed | `/website-performance-review` |
| Review privacy and security | `/website-security-privacy-review` |
| Review cookies and consent | `/website-cookie-consent-review` |
| Review analytics and measurement | `/website-analytics-review` |
| Plan ongoing growth | `/website-growth-plan` |
| Create a maintenance plan | `/website-maintenance-plan` |
| Run a monthly health check | `/website-monthly-review` |
| Review backups and recovery | `/website-backup-restore-review` |
| Review monitoring and incidents | `/website-monitoring-review` and `/website-incident-response-review` |
| Review vendors and third-party tools | `/website-vendor-management-review` and `/website-third-party-tools-review` |
| Review AI chatbot behavior | `/website-ai-chatbot-review` |

### Content, Copy, Search, Growth, and Experimentation

- `prompts/website-copy-review.prompt.md`
- `prompts/website-content-governance-review.prompt.md`
- `prompts/website-search-review.prompt.md`
- `prompts/website-growth-plan.prompt.md`
- `prompts/website-conversion-review.prompt.md`
- `prompts/website-forms-submissions-review.prompt.md`
- `prompts/website-experimentation-review.prompt.md`
- `prompts/website-online-presence-review.prompt.md`
- `prompts/website-seo-review.prompt.md`
- `prompts/website-review.prompt.md` - General website review prompt for broad site quality checks.
- `prompts/website-local-seo-check.prompt.md`

### Accessibility, Localization, Performance, and Sustainability

- `prompts/website-accessibility-remediation-review.prompt.md`
- `prompts/website-localization-review.prompt.md`
- `prompts/website-performance-review.prompt.md`
- `prompts/website-digital-sustainability-review.prompt.md`

### Privacy, Security, Consent, Accounts, and Access

- `prompts/website-security-privacy-review.prompt.md`
- `prompts/website-access-permissions-review.prompt.md`
- `prompts/website-data-retention-review.prompt.md`
- `prompts/website-cookie-consent-review.prompt.md`
- `prompts/website-account-login-review.prompt.md`

### Analytics, Monitoring, Incidents, Resilience, and Operations

- `prompts/website-analytics-review.prompt.md`
- `prompts/website-monitoring-review.prompt.md`
- `prompts/website-incident-response-review.prompt.md`
- `prompts/website-business-continuity-review.prompt.md`
- `prompts/website-backup-restore-review.prompt.md`
- `prompts/website-migration-review.prompt.md`

### Vendors, Tools, AI, Costs, and Third Parties

- `prompts/website-ai-chatbot-review.prompt.md`
- `prompts/website-third-party-tools-review.prompt.md`
- `prompts/website-vendor-management-review.prompt.md`
- `prompts/website-cost-ownership-review.prompt.md`

### Notes

- `website-monitoring-review.prompt.md`, `website-incident-response-review.prompt.md`, `website-business-continuity-review.prompt.md`, and `website-backup-restore-review.prompt.md` are complementary, not duplicates.
- `website-security-privacy-review.prompt.md`, `website-access-permissions-review.prompt.md`, `website-data-retention-review.prompt.md`, `website-cookie-consent-review.prompt.md`, and `website-account-login-review.prompt.md` cover different parts of the privacy/security/access lifecycle.
- `website-ai-chatbot-review.prompt.md`, `website-search-review.prompt.md`, `website-third-party-tools-review.prompt.md`, and `website-vendor-management-review.prompt.md` overlap intentionally around tools, vendors, data, and user experience.
<!-- WEBSITE-PROMPT-COVERAGE-INDEX:END -->

## Website-adjacent shared prompts

These shared prompts are part of the website artifact workflow even though their filenames do not start with `website-`.

- `prompts/website-html-css-review.prompt.md` - Reviews HTML/CSS implementation quality, maintainability, accessibility-supporting markup, responsive behavior, performance-sensitive front-end patterns, and practical remediation opportunities.
- `prompts/website-platform-decision.prompt.md` - Compares website platform options, tradeoffs, ownership needs, integration considerations, operating model fit, implementation risks, and decision criteria.

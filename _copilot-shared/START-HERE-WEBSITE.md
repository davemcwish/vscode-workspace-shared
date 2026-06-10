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
| Website Launch Planner | Guides you from idea to live site | Select the chat mode if installed | To create or verify |
| Critical Thinking Partner | Challenges your assumptions before you commit | Type `@critical-thinking` or use the critical-thinking chat mode | Installed |
| SEO Reviewer | Checks whether people can find your site | Type `/seo-review` if installed | To create |
| Conversion Reviewer | Checks whether visitors take the action you want | Type `/conversion-review` if installed | To create |
| Local SEO Checker | Checks whether local customers can find you | Type `/local-seo-check` if installed | To create or verify |
| Accessibility Reviewer | Checks whether everyone can use your site | Select the accessibility review chat mode if installed | To create or verify |
| HTML/CSS Reviewer | Reviews your code for quality and standards | Type `/html-css-review` if installed | To create or verify |
| Platform Decision Helper | Helps choose the right technology | Type `/platform-decision` if installed | To create |
| Monthly Website Reviewer | Runs a health check after launch | Type `/monthly-website-review` if installed | To create |
| Maintenance Plan Creator | Creates a post-launch care plan | Type `/website-maintenance-plan` if installed | To create |

If a listed specialist is not installed, check `WEBSITE-ARTIFACT-MANIFEST.md`
and either create the missing artifact or use the closest installed guidance
file manually.

You don't need to memorise all of these. This document tells you which to use
and when.

---

## How to Talk to Copilot (The Basics)

If you've never used Copilot before:

1. **Open VS Code** (the application you're reading this in).
2. **Open the Chat panel** â€” click the chat icon in the left sidebar, or press
   `Ctrl+Shift+I` (Windows) / `Cmd+Shift+I` (Mac).
3. **Choose a chat mode** â€” at the top of the Chat panel there's a dropdown.
   Pick the specialist you need (e.g. "Website Launch Planner").
4. **Type your question** â€” in plain English. No code needed.
5. **Use `/` for prompts** â€” type `/` followed by the prompt name to run a
   specific recipe (e.g. `/seo-review`).
6. **Use `@` for agents** â€” type `@` followed by the agent name to summon a
   specialist (e.g. `@critical-thinking`).

That's it. The AI reads the instruction files automatically and knows how to
guide you.

---

## The Website Lifecycle

Every website project follows this path. The artifacts in this workspace cover
every stage:

```text
1. THINK     â€” What is this website for? Who is it for? What country/region?
2. CHALLENGE â€” Are my assumptions sound? (Critical thinking)
3. PLAN      â€” Platform, content, design, legal, security, social presence
4. BUILD     â€” Create pages, write copy, add images, configure platform
5. SECURE    â€” Harden the site, check privacy/legal compliance
6. TEST      â€” Accessibility, performance, mobile, forms, links, browsers
7. LAUNCH    â€” Domain, SSL, DNS, go live, verify
8. PROMOTE   â€” SEO, social media, advertising, email, offline promotion
9. MEASURE   â€” Analytics, conversions, search visibility
10. MAINTAIN â€” Monthly reviews, updates, security patches, content freshness
```

---

## Stage-by-Stage Guide: Which Artifacts to Use

Before using this guide, check `WEBSITE-ARTIFACT-MANIFEST.md`.

Some artifacts listed below may be installed already. Others may be planned but
not yet created. If an artifact is missing, use the related skill file or create
the missing prompt/workflow before relying on it.

### Stage 1: THINK â€” Define Your Website

**Start here. Do not write any code yet.**

| Action | How |
| --- | --- |
| Define purpose, audience, geography, and goals | Select chat mode: **Website Launch Planner** |
| Or run the one-shot planning prompt | Type `/website-from-idea-to-launch` |
| Help choose the right platform/technology | Type `/platform-decision` |

The planner will ask you about:

- What the website is for (leads, sales, information, bookings, etc.).
- Who the audience is and where they are (country, region, language).
- What privacy and legal requirements apply in that geography.
- What social media and online presence already exists.
- Who will maintain the site after launch.
- What your budget and timeline look like.

**You do not need to know the answers in advance.** The planner explains each
question and helps you decide.

### Stage 2: CHALLENGE â€” Test Your Assumptions

**Use this before committing to any major decision.**

| Action | How |
| --- | --- |
| Challenge platform choice, audience assumptions, design decisions | Type `@critical-thinking` in Chat |

The critical thinking partner will ask probing questions like:

- "Is this really the simplest platform that meets your needs?"
- "Can the person maintaining this site actually use this technology?"
- "Have you considered what privacy law requires in your target country?"
- "What happens if your hosting provider goes down â€” is there a backup plan?"

It never tells you what to do â€” it helps you think clearly.

### Stage 3: PLAN â€” Design, Content, Legal, Security

| Action | How |
| --- | --- |
| Full planning workflow | Read: `workflows/website-live-launch.workflow.md` |
| Content and copywriting guidance | Read: `skills/website-content-copywriting.skill.md` |
| Privacy and legal requirements | Read: `skills/website-privacy-legal.skill.md` |
| Security planning | Read: `skills/website-security.skill.md` |
| Performance planning | Read: `skills/website-performance.skill.md` |

### Stage 4: BUILD â€” Create the Website

| Action | How |
| --- | --- |
| HTML/CSS/JS standards | Automatic â€” Copilot reads `html-css-javascript.instructions.md` when you edit web files |
| Accessibility standards | Read: `skills/accessibility.skill.md` |
| Review your HTML/CSS | Type `/html-css-review` in Chat |

### Stage 5: SECURE â€” Harden and Comply

| Action | How |
| --- | --- |
| Website security checklist | Read: `skills/website-security.skill.md` |
| Privacy and legal compliance | Read: `skills/website-privacy-legal.skill.md` |
| Challenge security assumptions | Type `@critical-thinking` and ask about security |

### Stage 6: TEST â€” Verify Everything Works

| Action | How |
| --- | --- |
| Accessibility review | Select chat mode: **accessibility-review** |
| HTML/CSS quality review | Type `/html-css-review` |
| Performance check | Read: `skills/website-performance.skill.md` |
| Conversion path check | Type `/conversion-review` |

### Stage 7: LAUNCH â€” Go Live

| Action | How |
| --- | --- |
| Full launch workflow | Read: `workflows/website-live-launch.workflow.md` |
| Pre-launch checklist | In the Website Launch Planner chat mode, Phase 8 |

### Stage 8: PROMOTE â€” Get Found

| Action | How |
| --- | --- |
| SEO review | Type `/seo-review` |
| Local SEO check | Type `/local-seo-check` |
| Promotion strategy | Read: `skills/website-promotion.skill.md` |
| Conversion review | Type `/conversion-review` |

### Stage 9: MEASURE â€” Track Results

| Action | How |
| --- | --- |
| Analytics guidance | Read: `skills/website-analytics.skill.md` |
| Monthly review | Type `/monthly-website-review` |

### Stage 10: MAINTAIN â€” Keep It Healthy

| Action | How |
| --- | --- |
| Create a maintenance plan | Type `/website-maintenance-plan` |
| Monthly health check | Type `/monthly-website-review` |
| Ongoing security | Read: `skills/website-security.skill.md` |

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

### Skills (Training Manuals â€” Read Before Building)

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
| `/platform-decision` | Choosing the right technology |
| `/seo-review` | Checking search engine readiness |
| `/local-seo-check` | Checking local search readiness |
| `/conversion-review` | Checking whether visitors convert |
| `/html-css-review` | Reviewing code quality |
| `/monthly-website-review` | Monthly health check |
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

## Key Concepts for Complete Beginners

| Term | What It Means |
| --- | --- |
| Website | A collection of pages on the internet that people visit using a browser (Chrome, Safari, Firefox, Edge) |
| Domain | The address people type to find your site (e.g. `example.com`) â€” you rent it annually |
| Hosting | Where your website files live â€” a computer (server) connected to the internet 24/7 |
| SSL / HTTPS | Security that encrypts the connection between visitors and your site â€” the padlock icon in the browser |
| CMS | Content Management System â€” software that lets you edit website pages without writing code (e.g. WordPress) |
| SEO | Search Engine Optimisation â€” making your site easier for Google/Bing to find and show to searchers |
| Analytics | Tools that tell you how many people visit, what they look at, and what they do |
| Accessibility | Making your site usable by people with disabilities (screen readers, keyboard navigation, colour contrast) |
| Privacy law | Rules about how you collect and use visitor data (different in every country) |
| CTA | Call To Action â€” the thing you want visitors to do (call, buy, book, subscribe, download) |
| Responsive | A design that works well on phones, tablets, and desktop computers |
| DNS | Domain Name System â€” the internet's address book that connects your domain name to your hosting server |

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
2. **Tell it what you want** â€” in plain English, no jargon needed.
3. **Follow the conversation** â€” it will guide you through every decision.
4. **Document everything** â€” follow `workflows/website-documentation.workflow.md`
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
- `prompts/website-review.prompt.md` â€” General website review prompt for broad site quality checks.
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

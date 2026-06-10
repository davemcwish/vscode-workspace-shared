---
description: Review a website for ethical conversion, lead generation, trust, calls to action, forms, bookings, payments, accessibility, privacy, analytics, and customer journey friction.
---

# Conversion Review Prompt

You are reviewing a website or website plan for ethical conversion.

Conversion means helping the right visitor take the right next step. Depending on
the website, this may mean making an enquiry, calling, booking, buying, donating,
signing up, downloading, registering, applying, visiting a location, requesting a
quote, or contacting support.

A good conversion review improves clarity, trust, usability, and follow-through.
It must not rely on manipulation, misleading claims, fake urgency, fake scarcity,
fake reviews, hidden costs, confusing consent, or inaccessible design.

This review should be practical for a small team, beginner, or non-technical
website owner. Prefer clear, realistic improvements over unnecessary redesigns.

**Currentness warning:** Analytics tools, consent requirements, payment flows,
booking tools, advertising platforms, platform features, accessibility
expectations, review-platform rules, and privacy/cookie requirements change over
time. Where current legal, compliance, provider, payment, tracking, or platform
details matter, tell the user what to verify from official sources.

---

## Ethical conversion principles

- Help the right user take the right next step.
- Make the offer, price, process, eligibility, and next step clear.
- Reduce friction without hiding important information.
- Use real trust signals only.
- Do not recommend fake reviews, fake testimonials, fake locations, fake
  urgency, fake scarcity, misleading countdowns, hidden fees, hidden terms,
  forced opt-ins, confusing cancellation paths, or manipulative consent.
- Do not promise rankings, traffic, leads, sales, or conversion improvements.
- Do not recommend collecting unnecessary personal data.
- Do not make forms longer than needed.
- Do not hide privacy, refund, cancellation, complaint, or contact information.
- Flag accessibility, privacy, security, payment, legal, claims, or regulated
  content risks.

---

## Ask for missing context first

If not provided, ask concise questions about:

- What is the main website goal?
- What is the primary conversion action?
- What secondary actions matter?
- Who is the target audience?
- What problem, need, or intent brings visitors to the site?
- What country, region, city, language, currency, or service area matters?
- Is this a public website, internal website, eCommerce site, service site,
  booking site, local business site, membership site, donation site, content
  site, static site, generated static report, or custom web application?
- Does the business want enquiries, calls, bookings, purchases, donations,
  downloads, newsletter signups, applications, repeat visits, quote requests, or
  support requests?
- What pages, files, flows, screenshots, analytics, or form examples should be
  reviewed?
- Are forms, booking links, phone links, email links, payment links, downloads,
  maps, chat, WhatsApp, social messages, or customer portals used?
- What happens after a visitor submits a form, books, buys, calls, downloads, or
  signs up?
- Who receives leads, orders, messages, bookings, or support requests?
- What is the expected response time?
- Are analytics, conversion events, call tracking, booking reports, payment
  reports, or campaign tracking available?
- Are privacy, cookie, consent, refund, cancellation, accessibility, complaints,
  payment, or regulated-content requirements relevant?
- Are testimonials, reviews, logos, photos, accreditations, awards, or case
  studies approved for use?
- Are there known issues with spam, failed enquiries, missed calls, abandoned
  forms, abandoned carts, complaints, or support questions?

If data is unavailable, mark it as missing rather than inventing results.

---

## Review areas

Review:

1. Main conversion goal
2. Primary and secondary calls to action
3. Page-level calls to action
4. Above-the-fold clarity
5. Offer clarity and relevance to the target audience
6. Navigation clarity
7. Contact details and contact confidence
8. Forms and form length
9. Form labels, error messages, required fields, and confirmation behaviour
10. Phone, email, map, chat, WhatsApp, and social-message paths where relevant
11. Booking journey where relevant
12. Payment, checkout, donation, or order journey where relevant
13. Account signup, login, or membership journey where relevant
14. Download, quote request, application, or support journey where relevant
15. Trust signals
16. Testimonials, reviews, case studies, logos, certifications, awards, and
    social proof
17. Pricing, fees, quote process, refund, cancellation, delivery, and next-step
    clarity
18. Privacy wording and consent near forms, analytics, pixels, newsletter
    signups, payments, and downloads
19. Accessibility barriers that may block conversion
20. Mobile conversion path
21. Page speed and performance issues that may affect conversion
22. Friction, confusion, anxiety, or unnecessary steps
23. Lead handling after form submission
24. Auto-replies, confirmation messages, thank-you pages, and next-step
    instructions
25. Spam protection and bot mitigation
26. Analytics, events, goals, funnels, call tracking, campaign tracking, or
    conversion measurement
27. Local conversion factors such as opening hours, service area, directions,
    reviews, business listings, and local phone numbers where relevant
28. Ethical risks such as misleading claims, dark patterns, hidden costs, fake
    urgency, or manipulative consent

---

## Conversion journey checks

When reviewing a journey, check:

- Can the visitor understand the offer quickly?
- Is the next step obvious?
- Is the call to action specific?
- Is the call to action repeated at sensible points?
- Is the visitor reassured before taking action?
- Are costs, eligibility, timing, location, limitations, and next steps clear?
- Is the journey easy on mobile?
- Is the journey usable with keyboard navigation and assistive technology?
- Are forms short enough for the purpose?
- Are required fields genuinely required?
- Are errors clear and helpful?
- Does the user receive confirmation?
- Does the business receive the enquiry, booking, payment, or signup?
- Is there a backup owner or backup notification path?
- Is sensitive or unnecessary personal data avoided?
- Are privacy, consent, payment, cancellation, refund, or complaints details
  visible where relevant?

---

## Severity rules

Use these severities:

- **High:** Blocks or seriously harms the main conversion, causes lost leads or
  orders, creates legal/privacy/payment/security risk, or creates a major
  accessibility barrier.
- **Medium:** Creates friction, confusion, trust concerns, or missed
  opportunities but does not fully block the journey.
- **Low:** Useful improvement, polish, wording, layout, or measurement
  enhancement.

---

## Recommendation rules

For each recommendation, explain:

- what the issue is,
- why it affects conversion or trust,
- what to change,
- who should own it,
- whether technical help is needed,
- how to verify the fix.

Prefer recommendations that are specific and testable.

Do not recommend large redesigns unless smaller changes cannot solve the
conversion problem.

---

## Output format

Return:

```markdown
# Conversion Review

## Verdict

PASS / NEEDS IMPROVEMENT / HIGH RISK

## Beginner-Friendly Summary

Summarise the main conversion strengths, weaknesses, and most important next
step in plain English.

## Assumptions and Missing Data

List assumptions made and data that was not available, such as analytics,
conversion counts, form test results, booking reports, payment reports, call
tracking, or user feedback.

## Main Conversion Goal

State the main conversion goal in one sentence.

## Primary and Secondary Actions

List the primary action and any secondary actions.

## Target Audience and Intent

State who the visitor is, what they are likely trying to do, and what reassurance
they may need.

## Conversion Journey Reviewed

Describe the page or journey reviewed, such as homepage to contact form,
service page to call, product page to checkout, booking journey, donation flow,
signup flow, quote request, download, or support request.

## Findings

| Severity | Area | Issue | Why It Matters | Suggested Fix | Owner |
| --- | --- | --- | --- | --- | --- |

## Page-Level Call to Action Review

| Page | Current CTA | Recommended CTA | Notes |
| --- | --- | --- | --- |

## Above-the-Fold and Offer Clarity

Review whether the visitor can quickly understand what is offered, who it is for,
where it applies, why it matters, and what to do next.

## Trust and Reassurance Review

Review contact details, credentials, reviews, testimonials, case studies, logos,
awards, guarantees, policies, response times, pricing clarity, refund/cancellation
information, and social proof. Flag any proof that needs approval or evidence.

## Form and Lead Capture Review

Review form length, required fields, labels, error messages, privacy wording,
confirmation behaviour, notification routing, spam protection, and backup
handling.

## Booking, Payment, Checkout, Donation, or Signup Review

Use this section where relevant. Review steps, friction, clarity, fees,
eligibility, delivery, cancellation/refund terms, confirmation, error handling,
and abandonment risks.

## Mobile Conversion Review

Review whether the main conversion path is easy to complete on a phone.

## Accessibility and Usability Barriers

List barriers involving keyboard access, focus order, headings, labels, error
messages, contrast, small text, unclear links/buttons, images, PDFs, maps,
videos, or inaccessible widgets.

## Privacy, Consent, and Data Collection

Review privacy wording, consent, newsletter opt-ins, tracking pixels, analytics,
payment data handling, unnecessary personal data, and third-party tools.

## Analytics and Conversion Tracking

Review whether the main conversion actions are measurable, such as form
submissions, calls, bookings, purchases, donations, downloads, signups, quote
requests, and campaign links.

## Local Conversion Factors

Use this section where relevant. Review opening hours, service area, location,
directions, local phone number, local reviews, business listings, and local trust
signals.

## Lead Handling Checklist

- [ ] Contact form sends to the correct inbox.
- [ ] A backup recipient is configured.
- [ ] Test submissions have been completed.
- [ ] Auto-reply text is approved if used.
- [ ] Thank-you page or confirmation message explains the next step.
- [ ] Spam protection is enabled.
- [ ] Privacy wording is present where needed.
- [ ] Lead response owner is assigned.
- [ ] Expected response time is documented.
- [ ] Missed leads, failed forms, or spam are monitored.
- [ ] Leads are stored and handled appropriately.
- [ ] Newsletter or marketing consent is separate where required.

## Critical Journey Test Checklist

- [ ] Primary CTA works.
- [ ] Secondary CTAs work.
- [ ] Phone links work on mobile.
- [ ] Email links work.
- [ ] Forms submit successfully.
- [ ] Form errors are understandable.
- [ ] Confirmation messages appear.
- [ ] Notifications arrive in the correct inbox.
- [ ] Booking links work where relevant.
- [ ] Payment or checkout works where relevant.
- [ ] Downloads work where relevant.
- [ ] Maps/directions work where relevant.
- [ ] Analytics or conversion events record the action where configured.
- [ ] Privacy/consent behaviour works where relevant.

## Ethical Conversion Risks

List any dark patterns, misleading claims, fake urgency, fake scarcity, hidden
fees, confusing consent, inaccessible interactions, unapproved testimonials, or
unsupported claims.

## Priority Actions

1.
2.
3.

## Recommended Experiments or Improvements

List small, realistic improvements that can be tested or reviewed later.

## Escalation Needed

List anything needing a developer, designer, platform support, accessibility
specialist, legal/privacy reviewer, payment provider, analytics specialist, or
business owner decision.

## Verification Plan

Explain how to verify that the recommended fixes worked, such as retesting the
journey, checking form notifications, reviewing analytics events, confirming
bookings/payments, checking accessibility, or asking users for feedback.
```

## Rules

Use beginner-friendly language.

Keep recommendations realistic for a small team or non-technical owner.

Clearly separate conversion blockers from optional improvements.

Do not recommend unnecessary redesigns.

Do not invent analytics, conversion, sales, booking, or lead data.

Do not recommend fake reviews, fake locations, fake urgency, misleading claims,
hidden fees, hidden terms, keyword stuffing, copied content, or manipulative
consent.

Do not promise rankings, traffic, leads, sales, bookings, or conversion
improvements.

If current legal, compliance, analytics, payment, privacy, advertising, platform,
or provider details matter, tell the user what to verify from official sources.

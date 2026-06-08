---
description: Review a website for conversion, lead generation, trust, calls to action, and customer journey friction.
---

# Conversion Review Prompt

You are reviewing a website or website plan for conversion.

Conversion means helping the right visitor take the right next step. Depending on
the website, this may mean making an enquiry, calling, booking, buying, signing
up, downloading, registering, or requesting a quote.

## Ask for missing context first

If not provided, ask:

- What is the main website goal?
- What action should visitors take?
- Who is the target audience?
- What country or region is the website for?
- Is this a public website, internal website, eCommerce site, service site, booking site, or static report?
- Does the business want enquiries, calls, bookings, purchases, newsletter signups, or repeat visits?
- What pages or files should be reviewed?
- Are forms, booking links, phone links, payment links, or chat/messaging links used?

## Review areas

Review:

1. Main call to action
2. Page-level calls to action
3. Above-the-fold clarity
4. Navigation clarity
5. Contact details
6. Forms
7. Booking or payment journeys if relevant
8. Trust signals
9. Testimonials, reviews, and social proof
10. Pricing or quote-process clarity
11. Friction and confusion
12. Mobile conversion path
13. Accessibility barriers that may block conversion
14. Lead handling after form submission
15. Auto-replies or confirmation messages
16. Privacy wording near forms
17. Spam protection
18. Analytics or event tracking

## Output format

Return:

```markdown
# Conversion Review

## Verdict

PASS / NEEDS IMPROVEMENT / HIGH RISK

## Main Conversion Goal

State the main goal in one sentence.

## Findings

| Severity | Area | Issue | Why It Matters | Suggested Fix |
| --- | --- | --- | --- | --- |

## Page-Level Call to Action Review

| Page | Current CTA | Recommended CTA | Notes |
| --- | --- | --- | --- |

## Lead Handling Checklist

- [ ] Contact form sends to the correct inbox.
- [ ] A backup recipient is configured.
- [ ] Test submissions have been completed.
- [ ] Auto-reply text is approved if used.
- [ ] Spam protection is enabled.
- [ ] Privacy wording is present where needed.
- [ ] Lead response owner is assigned.
- [ ] Expected response time is documented.

## Priority Actions

1.
2.
3.
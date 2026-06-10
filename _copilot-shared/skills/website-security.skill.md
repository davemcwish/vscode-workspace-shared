# Skill: Website Security

## Purpose

This skill covers security for **public websites** - from simple brochure sites
to CMS-powered platforms, eCommerce stores, and custom web applications.

It is written for **complete beginners** who may not have heard of HTTPS, CSP,
XSS, or CSRF before. Every term is explained at the point it first appears.

**Currentness warning:** Security threats, platform defaults, browser
behaviour, TLS recommendations, CMS vulnerabilities, plugin risks, hosting
features, and security best practices change over time. Before launch and
during maintenance, verify current guidance from authoritative sources and
the platform or hosting provider.

---

## Audience

- Complete beginners building their first website.
- Small business owners maintaining a site without a dedicated security team.
- Developers who are new to web security.

The test: "Could someone who has never configured a web server understand this
and take action?" If not, rewrite.

---

## The Security Mindset

Security is not a one-time task you do before launch. It is a continuous
practice throughout the website's life.

The three questions to ask about every feature, page, form, or integration:

1. **What could go wrong?** - What if someone tries to abuse this?
2. **What data is at risk?** - Personal information, passwords, payment details?
3. **Who is responsible?** - Who monitors, patches, and responds to issues?

---

## HTTPS (Encrypted Connections)

**What it is:** HTTPS encrypts the connection between your visitor's browser and
your website. Without it, anyone on the same network (coffee shop Wi-Fi, hotel,
office) can read what your visitors type - including passwords and form data.

**What to do:**

- Every public website MUST use HTTPS. No exceptions.
- Get an SSL/TLS certificate (a digital document that proves your site is
  genuine). Most hosting providers offer free certificates via Let's Encrypt.
- Redirect all HTTP traffic to HTTPS (so visitors who type `http://` are
  automatically moved to the secure version).
- Set the `Strict-Transport-Security` header (HSTS) - this tells browsers to
  always use HTTPS, even if someone types `http://`.

**How to verify:** Visit your site and check for the padlock icon in the browser
address bar. If there's a warning instead, the certificate is misconfigured.

---

## Security Headers

Security headers are instructions your website sends to the browser that say
"here are the security rules for this site." They cost nothing and prevent
entire categories of attack.

### Essential Headers

| Header | What It Does | Beginner Explanation |
| --- | --- | --- |
| `Content-Security-Policy` (CSP) | Controls which scripts, styles, images, and fonts can load | Prevents attackers from injecting malicious scripts |
| `X-Content-Type-Options: nosniff` | Stops browsers from guessing file types | Prevents a text file being executed as a script |
| `X-Frame-Options: DENY` | Prevents your site being embedded in someone else's page | Stops "clickjacking" where attackers overlay invisible buttons |
| `Referrer-Policy: strict-origin-when-cross-origin` | Controls what URL information is shared when visitors click links to other sites | Protects visitor privacy |
| `Permissions-Policy` | Disables browser features you don't need (camera, microphone, geolocation) | Reduces attack surface |
| `Strict-Transport-Security` | Forces HTTPS for all future visits | Prevents downgrade attacks |

### Content Security Policy Caution

Content Security Policy is powerful, but a strict policy can break scripts,
styles, fonts, images, forms, payments, analytics, maps, or embedded content
if it is configured incorrectly.

For new or complex sites, consider this rollout approach:

1. Inventory scripts, styles, fonts, images, frames, forms, and third-party
   services.
2. Start with a simple policy.
3. Use report-only mode where the hosting platform supports it.
4. Review violations.
5. Fix legitimate issues.
6. Move to enforcement when confident.

For clickjacking protection, modern CSP can use `frame-ancestors`. Some
sites also keep `X-Frame-Options` as a legacy fallback where suitable.

Do not copy a CSP from another website without understanding it. CSP must
match the actual services your website uses.

### How to Set Them

- **Static hosting (Netlify, Cloudflare Pages, Vercel):** Configuration file
  (e.g. `_headers`, `netlify.toml`, `vercel.json`).
- **Apache server:** `.htaccess` file.
- **Nginx server:** `nginx.conf` or site configuration.
- **WordPress:** Security plugin (e.g. Really Simple Security) or `.htaccess`.
- **No-code builders:** Usually handled by the platform - verify in browser
  DevTools → Network → Response Headers.

---

## Form Security

If your website has any forms (contact, booking, login, newsletter signup),
they are a target for abuse.

### Spam Protection

- Use a CAPTCHA or invisible challenge (e.g. reCAPTCHA, hCaptcha, Turnstile).
- Add a honeypot field (a hidden field that real users never fill in - bots do).
- Rate-limit form submissions (prevent thousands of submissions per minute).

### Input Validation

- Never trust user input. Validate on the server, not just in the browser.
- Limit field lengths (a "name" field doesn't need 10,000 characters).
- Reject or sanitise HTML in text fields to prevent XSS (Cross-Site Scripting  - 
  where an attacker injects malicious code through a form field that gets
  displayed to other users).

### CSRF Protection

CSRF (Cross-Site Request Forgery) is when an attacker tricks a logged-in user's
browser into submitting a form they didn't intend to submit.

- Every form that changes data must include a CSRF token (a unique secret value
  that proves the form submission came from your site, not an attacker's).
- Most CMS platforms and web frameworks include CSRF protection - ensure it is
  enabled, not disabled.

### File Upload Security

If your site allows file uploads:

- Restrict allowed file types (e.g. only `.jpg`, `.png`, `.pdf`).
- Check file content, not just the file extension (attackers rename `.exe` to `.jpg`).
- Store uploads outside the web-accessible directory.
- Scan uploads for malware if possible.
- Limit file size.

---

## Secrets Management

Secrets are private values that grant access to systems. Examples include:

- API keys,
- payment provider secret keys,
- SMTP passwords,
- database passwords,
- CMS salts or secret keys,
- webhook signing secrets,
- private tokens,
- deployment keys.

### Secrets Management Rules

- Never put secrets in public code repositories.
- Never paste secrets into public issues, chat logs, screenshots, or support
  forums.
- Use environment variables, hosting secret stores, or platform-provided
  secret management.
- Give each service its own key where possible.
- Rotate secrets when a contractor leaves or a leak is suspected.
- Remove unused keys.
- Restrict each key to the minimum permissions needed.
- Document who can create, view, rotate, and revoke secrets.

### If a Secret Is Exposed

1. Revoke or rotate it immediately.
2. Check logs for suspicious use.
3. Replace it in the website or hosting environment.
4. Remove it from code history if needed.
5. Document what happened and what was changed.

---

## CMS and Platform Security

If you use WordPress, Joomla, Drupal, or any CMS:

### Keep Everything Updated

- **Core CMS** - update within days of a security release.
- **Plugins/extensions** - update regularly; remove any you don't actively use.
- **Themes** - update or replace abandoned themes.

### Admin Panel Hardening

- Use a strong, unique password (minimum 16 characters, random).
- Enable two-factor authentication (2FA) on all admin accounts.
- Limit login attempts (block after 5 failed attempts).
- Change the default admin URL if the platform supports it.
- Restrict admin access by IP address if practical.
- Remove unused admin accounts immediately.

### Plugin/Extension Safety

- Only install plugins from the official marketplace or trusted sources.
- Check when the plugin was last updated - abandoned plugins are a security risk.
- Check the number of active installations and reviews.
- Remove any plugin you are not actively using - every plugin is attack surface.

---

## Domain and DNS Security

The domain is the website's address. DNS is the system that tells browsers,
email providers, and other services where that domain points.

Losing control of the domain or DNS can be worse than losing the website
files, because attackers could redirect visitors, intercept email, or take
the business offline.

### Domain Security Checklist

- Use a reputable domain registrar.
- Enable multi-factor authentication on the registrar account.
- Use a strong, unique password.
- Enable domain lock or transfer lock where available.
- Record who legally owns the domain.
- Record who has access to the registrar account.
- Record the renewal date and payment method.
- Use more than one recovery contact where appropriate.
- Keep recovery email addresses current.
- Do not register critical business domains under a personal account that
  only one person controls.

### DNS Security Checklist

- Limit who can edit DNS records.
- Record what each DNS record does.
- Review DNS changes before applying them.
- Keep a backup copy of important DNS records.
- Remove obsolete verification records when no longer needed.
- Use DNS provider security features where available.
- Check DNS after launch, domain migration, hosting migration, or email
  provider changes.

### Questions to Document

- Who owns the domain?
- Who can renew it?
- Who can change DNS?
- What happens if the main account owner leaves?
- What happens if the payment card expires?
- How quickly could the domain or DNS be recovered?

---

## Email Security and Deliverability

Many websites send email: contact form notifications, booking confirmations,
password resets, order confirmations, invoices, newsletters, or admin alerts.

If email is misconfigured, messages may go to spam or fail silently. If email
authentication is weak, attackers may spoof the domain.

### Key Terms

| Term | What It Means |
| --- | --- |
| SPF | A DNS record that says which servers are allowed to send email for the domain |
| DKIM | A cryptographic signature proving the email was authorised by the domain |
| DMARC | A DNS policy telling receivers what to do when SPF or DKIM checks fail |

### Email Security Checklist

- Identify every system that sends email for the domain.
- Configure SPF for authorised senders.
- Configure DKIM for each email-sending service.
- Configure DMARC, starting cautiously if needed and tightening over time.
- Test website form notifications.
- Test order, booking, account, or password-reset emails if applicable.
- Monitor whether important website emails are being delivered.
- Avoid using one person's personal inbox as the only recipient for critical
  website messages.
- Document who receives website email notifications.
- Document what happens if the recipient leaves the organisation.

Email configuration often involves DNS records. Coordinate email changes with
whoever manages the domain and DNS.

---

## Hosting and Infrastructure Security

### Shared Hosting

- Acceptable for simple brochure sites.
- Ensure the host provides automatic backups, SSL, and security updates.
- You share a server with other websites - a compromise of another site could
  affect yours.

### Managed Hosting

- The hosting provider handles security patches, backups, and monitoring.
- More expensive but significantly less maintenance burden.
- Good choice for WordPress and other CMS platforms.

### VPS or Dedicated Server

- You are responsible for all security: firewall, SSH, updates, monitoring.
- Only choose this if you (or someone on your team) can maintain it.
- Secure SSH access (key-based authentication, disable password login, change
  default port).
- Configure a firewall (allow only ports 80, 443, and your SSH port).
- Enable automatic security updates for the operating system.
- Set up intrusion detection if practical.

### Static Hosting (Netlify, Cloudflare Pages, GitHub Pages, Vercel)

- No server to secure - the platform handles infrastructure.
- Lowest attack surface for simple sites.
- Still need to secure forms (use a form service or serverless function).

---

## Payment and eCommerce Security

If the website accepts payments, security and legal obligations increase.

Beginner rule:

Do not store card details yourself. Use a reputable payment processor or
eCommerce platform, such as a recognised payment gateway, hosted checkout,
or managed commerce platform.

### Payment Security Checklist

- Use a reputable payment provider.
- Prefer hosted checkout or tokenised payments where possible.
- Do not store raw card numbers or CVV codes.
- Enable multi-factor authentication on payment provider accounts.
- Limit who can issue refunds or change payout settings.
- Enable payment provider alerts for suspicious activity.
- Test checkout before launch.
- Test refunds if relevant.
- Document who owns the payment provider account.
- Document how disputes, fraud, and chargebacks are handled.
- Understand applicable PCI DSS responsibilities.
- Keep refund, shipping, cancellation, and terms pages accurate.

If the site sells regulated goods or services, get specialist legal and
payment-provider advice before launch.

---

## Third-Party Dependencies and Embeds

Every third-party script, font, widget, or embed you add to your site is code
you do not control running on your visitors' browsers.

### Third-Party Dependencies and Embeds Rules

- Only add third-party code you genuinely need.
- Use `integrity` attributes (Subresource Integrity - SRI) on CDN-loaded
  scripts and stylesheets to detect tampering.
- Review what data third-party scripts send (many tracking scripts send visitor
  data to servers in other countries - privacy law may require consent for this).
- Audit your third-party dependencies at least quarterly.
- If a third-party service is discontinued or compromised, remove it immediately.

### Social Media Embeds

Embedding live social feeds (Facebook, Instagram, X) loads their tracking
scripts onto your site. This:

- may require cookie consent under privacy law,
- slows your page,
- gives the social platform data about your visitors.

Prefer simple links to social profiles unless there is a clear business reason
for embedding.

---

## Account Ownership and Offboarding

Websites often depend on many accounts: domain registrar, hosting, CMS,
analytics, email, payment provider, ad platforms, plugins, stock image
libraries, repositories, and social media.

### Account Ownership Checklist

- Use named accounts where possible, not shared logins.
- Enable multi-factor authentication.
- Record who owns each account.
- Record backup administrators where appropriate.
- Use business-controlled email addresses for critical accounts.
- Avoid critical accounts being controlled only by a contractor or one
  employee's personal email.
- Review account access regularly.
- Remove access promptly when staff, agencies, freelancers, or contractors no
  longer need it.

### Offboarding Checklist

When someone leaves the project:

- Remove CMS/admin access.
- Remove hosting access.
- Remove repository access.
- Remove analytics access.
- Remove email platform access.
- Remove payment provider access if applicable.
- Remove ad platform access if applicable.
- Rotate shared passwords or secrets they knew.
- Confirm ownership of files, assets, licenses, and documentation.

---

## Backup and Recovery

- Automate backups (daily for active sites, weekly for static sites).
- Store backups in a different location from your website (different server,
  different provider, or cloud storage).
- Test restoring from a backup at least once before you need it.
- Document who can restore the site and how long it takes.
- Keep at least 30 days of backup history.

Also document:

- who is responsible for backups,
- where backups are stored,
- how often backups run,
- how long backups are retained,
- how to restore from backup,
- how long restoration should take,
- who has permission to restore,
- when the last restore test was completed.

A backup that has never been restored is only an assumption.

---

## Monitoring and Incident Response

## Security Contact and Vulnerability Reporting

Even small websites should have a way for someone to report a security issue.

At minimum:

- provide a monitored contact email address,
- decide who reviews security reports,
- decide how urgent issues are escalated,
- record who can take the site offline if visitors are at risk.

Larger or more technical projects can also consider a `security.txt` file,
which gives researchers a standard way to find security contact details.

### What to Monitor

- Uptime (is the site accessible?).
- SSL certificate expiry (certificates expire - set a renewal reminder).
- Unexpected file changes (for CMS sites - a sign of compromise).
- Failed login attempts (many failures may indicate a brute-force attack).
- Form submission spikes (may indicate spam or abuse).

### What to Do If Compromised

1. Take the site offline if visitors are at risk.
2. Restore from the most recent clean backup.
3. Change all passwords (hosting, CMS admin, database, FTP/SSH, email).
4. Review and remove any files you did not create.
5. Update all software (CMS, plugins, themes, server packages).
6. Review access logs to understand what happened.
7. If personal data was exposed, you may be legally required to notify
   affected users and your data protection authority (see
   `website-privacy-legal.skill.md`).

---

## Ongoing Security Maintenance

| Frequency | Action |
| --- | --- |
| Weekly | Check for CMS/plugin/theme/app updates and review form submissions for spam or abuse |
| Weekly | Check important website emails are being delivered if the site relies on forms, bookings, orders, or account emails |
| Monthly | Review admin accounts, failed logins, SSL certificate status, uptime, and access logs where available |
| Monthly | Confirm backups are running and stored where expected |
| Quarterly | Test restoring from backup |
| Quarterly | Audit third-party scripts, embeds, plugins, apps, and integrations |
| Quarterly | Review domain, DNS, registrar, hosting, CMS, analytics, email, and payment account access |
| Quarterly | Review secrets, API keys, webhook secrets, and unused access tokens |
| Annually | Review hosting contract, domain renewal, account ownership, incident response plan, and security contact |
| On every change | Test security headers, forms, authentication, payments, and consent behaviour affected by the change |
| When someone leaves | Remove access and rotate shared credentials or secrets they knew |

---

## Security Checklist for Launch

Before going live, confirm:

- [ ] HTTPS is active and HTTP redirects to HTTPS.
- [ ] Domain ownership, registrar access, renewal date, and recovery contacts
      are documented.
- [ ] DNS records are documented and access is limited.
- [ ] Domain registrar, DNS provider, hosting provider, CMS, analytics, email,
      and payment accounts use strong passwords and multi-factor
      authentication where available.
- [ ] Security headers are set (CSP, X-Content-Type-Options, X-Frame-Options,
      HSTS, Referrer-Policy, Permissions-Policy).
- [ ] CSP has been tested carefully, preferably with report-only mode first
      where practical.
- [ ] Clickjacking protection reviewed using `frame-ancestors` and/or
      suitable legacy headers.
- [ ] Forms have spam protection and input validation.
- [ ] Website email delivery has been tested.
- [ ] SPF, DKIM, and DMARC have been considered or configured for the sending
      domain.
- [ ] File uploads are restricted and validated (if applicable).
- [ ] Admin panels are protected with strong passwords and 2FA.
- [ ] Unused plugins, themes, and admin accounts are removed.
- [ ] Third-party scripts are minimised and audited.
- [ ] Third-party scripts, pixels, embeds, plugins, apps, and integrations
      have named owners and documented reasons for use.
- [ ] Secrets, API keys, webhook secrets, SMTP passwords, and payment keys are
      stored securely outside public code.
- [ ] Backups are configured and tested.
- [ ] Restore process is documented and a restore test has been completed
      where practical.
- [ ] Monitoring is configured (uptime, SSL, login attempts).
- [ ] Someone is named as the security maintenance owner.
- [ ] An incident response plan exists (even a simple one-page document).
- [ ] Security contact or vulnerability reporting route is documented.
- [ ] Account offboarding process is documented.
- [ ] Payment provider security and PCI responsibilities are understood if
      payments are accepted.

---

## Critical Constraints

- Never leave domain ownership, DNS access, or renewal responsibility
  undocumented.
- Never rely on one person's personal account as the only access path for a
  business-critical website.
- Never store secrets, API keys, payment keys, SMTP passwords, or tokens in a
  public repository.
- Never accept payments without understanding payment-provider security,
  refund, dispute, and PCI responsibilities.
- Never assume backups work until a restore has been tested.
- Never add third-party scripts, plugins, apps, pixels, or embeds without a
  named owner and clear reason.
- Never disable HTTPS for convenience.
- Never use the same password for multiple accounts.
- Never install plugins from unknown or untrusted sources.
- Never ignore security update notifications.
- Never store passwords, API keys, payment keys, SMTP passwords, webhook
  secrets, or private tokens in website code or public repositories.
- Never trust user input - validate everything on the server.
- Never embed third-party scripts without understanding what data they access.
- Always have a tested backup before making changes.
- Always know who is responsible for security maintenance.
- Always document account ownership, backup ownership, security ownership,
  and incident response responsibilities.
- Always remove access when staff, agencies, freelancers, or contractors no
  longer need it.
- Always verify current security guidance before launch and during major
  platform, hosting, payment, or CMS changes.

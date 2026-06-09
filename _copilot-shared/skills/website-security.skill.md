# Skill: Website Security

## Purpose

This skill covers security for **public websites** — from simple brochure sites
to CMS-powered platforms, eCommerce stores, and custom web applications.

It is written for **complete beginners** who may not have heard of HTTPS, CSP,
XSS, or CSRF before. Every term is explained at the point it first appears.

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

1. **What could go wrong?** — What if someone tries to abuse this?
2. **What data is at risk?** — Personal information, passwords, payment details?
3. **Who is responsible?** — Who monitors, patches, and responds to issues?

---

## HTTPS (Encrypted Connections)

**What it is:** HTTPS encrypts the connection between your visitor's browser and
your website. Without it, anyone on the same network (coffee shop Wi-Fi, hotel,
office) can read what your visitors type — including passwords and form data.

**What to do:**

- Every public website MUST use HTTPS. No exceptions.
- Get an SSL/TLS certificate (a digital document that proves your site is
  genuine). Most hosting providers offer free certificates via Let's Encrypt.
- Redirect all HTTP traffic to HTTPS (so visitors who type `http://` are
  automatically moved to the secure version).
- Set the `Strict-Transport-Security` header (HSTS) — this tells browsers to
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

### How to Set Them

- **Static hosting (Netlify, Cloudflare Pages, Vercel):** Configuration file
  (e.g. `_headers`, `netlify.toml`, `vercel.json`).
- **Apache server:** `.htaccess` file.
- **Nginx server:** `nginx.conf` or site configuration.
- **WordPress:** Security plugin (e.g. Really Simple Security) or `.htaccess`.
- **No-code builders:** Usually handled by the platform — verify in browser
  DevTools → Network → Response Headers.

---

## Form Security

If your website has any forms (contact, booking, login, newsletter signup),
they are a target for abuse.

### Spam Protection

- Use a CAPTCHA or invisible challenge (e.g. reCAPTCHA, hCaptcha, Turnstile).
- Add a honeypot field (a hidden field that real users never fill in — bots do).
- Rate-limit form submissions (prevent thousands of submissions per minute).

### Input Validation

- Never trust user input. Validate on the server, not just in the browser.
- Limit field lengths (a "name" field doesn't need 10,000 characters).
- Reject or sanitise HTML in text fields to prevent XSS (Cross-Site Scripting —
  where an attacker injects malicious code through a form field that gets
  displayed to other users).

### CSRF Protection

CSRF (Cross-Site Request Forgery) is when an attacker tricks a logged-in user's
browser into submitting a form they didn't intend to submit.

- Every form that changes data must include a CSRF token (a unique secret value
  that proves the form submission came from your site, not an attacker's).
- Most CMS platforms and web frameworks include CSRF protection — ensure it is
  enabled, not disabled.

### File Upload Security

If your site allows file uploads:

- Restrict allowed file types (e.g. only `.jpg`, `.png`, `.pdf`).
- Check file content, not just the file extension (attackers rename `.exe` to `.jpg`).
- Store uploads outside the web-accessible directory.
- Scan uploads for malware if possible.
- Limit file size.

---

## CMS and Platform Security

If you use WordPress, Joomla, Drupal, or any CMS:

### Keep Everything Updated

- **Core CMS** — update within days of a security release.
- **Plugins/extensions** — update regularly; remove any you don't actively use.
- **Themes** — update or replace abandoned themes.

### Admin Panel Hardening

- Use a strong, unique password (minimum 16 characters, random).
- Enable two-factor authentication (2FA) on all admin accounts.
- Limit login attempts (block after 5 failed attempts).
- Change the default admin URL if the platform supports it.
- Restrict admin access by IP address if practical.
- Remove unused admin accounts immediately.

### Plugin/Extension Safety

- Only install plugins from the official marketplace or trusted sources.
- Check when the plugin was last updated — abandoned plugins are a security risk.
- Check the number of active installations and reviews.
- Remove any plugin you are not actively using — every plugin is attack surface.

---

## Hosting and Infrastructure Security

### Shared Hosting

- Acceptable for simple brochure sites.
- Ensure the host provides automatic backups, SSL, and security updates.
- You share a server with other websites — a compromise of another site could
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

- No server to secure — the platform handles infrastructure.
- Lowest attack surface for simple sites.
- Still need to secure forms (use a form service or serverless function).

---

## Third-Party Dependencies and Embeds

Every third-party script, font, widget, or embed you add to your site is code
you do not control running on your visitors' browsers.

### Rules

- Only add third-party code you genuinely need.
- Use `integrity` attributes (Subresource Integrity — SRI) on CDN-loaded
  scripts and stylesheets to detect tampering.
- Review what data third-party scripts send (many tracking scripts send visitor
  data to servers in other countries — privacy law may require consent for this).
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

## Backup and Recovery

- Automate backups (daily for active sites, weekly for static sites).
- Store backups in a different location from your website (different server,
  different provider, or cloud storage).
- Test restoring from a backup at least once before you need it.
- Document who can restore the site and how long it takes.
- Keep at least 30 days of backup history.

---

## Monitoring and Incident Response

### What to Monitor

- Uptime (is the site accessible?).
- SSL certificate expiry (certificates expire — set a renewal reminder).
- Unexpected file changes (for CMS sites — a sign of compromise).
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
| Weekly | Check for CMS/plugin updates, review form submissions for spam patterns |
| Monthly | Review admin accounts, check SSL certificate status, review access logs |
| Quarterly | Audit third-party scripts and embeds, review backup integrity |
| Annually | Review hosting contract, check domain renewal, rotate passwords |
| On every change | Test that security headers are still present after deployments |

---

## Security Checklist for Launch

Before going live, confirm:

- [ ] HTTPS is active and HTTP redirects to HTTPS.
- [ ] Security headers are set (CSP, X-Content-Type-Options, X-Frame-Options,
      HSTS, Referrer-Policy, Permissions-Policy).
- [ ] Forms have spam protection and input validation.
- [ ] File uploads are restricted and validated (if applicable).
- [ ] Admin panels are protected with strong passwords and 2FA.
- [ ] Unused plugins, themes, and admin accounts are removed.
- [ ] Third-party scripts are minimised and audited.
- [ ] Backups are configured and tested.
- [ ] Monitoring is configured (uptime, SSL, login attempts).
- [ ] Someone is named as the security maintenance owner.
- [ ] An incident response plan exists (even a simple one-page document).

---

## Critical Constraints

- Never disable HTTPS for convenience.
- Never use the same password for multiple accounts.
- Never install plugins from unknown or untrusted sources.
- Never ignore security update notifications.
- Never store passwords, API keys, or secrets in your website's code.
- Never trust user input — validate everything on the server.
- Never embed third-party scripts without understanding what data they access.
- Always have a tested backup before making changes.
- Always know who is responsible for security maintenance.

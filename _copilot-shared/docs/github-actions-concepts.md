# GitHub Actions - Concepts Before You Build

This document answers the five questions you should understand before
implementing the GitHub Actions CI workflow for this project (Group B).
It is a companion to [`docs/github-actions-guide.md`](github-actions-guide.md),
which covers the step-by-step implementation.

---

## 1. What Is GitHub Actions?

GitHub Actions is an automation system built directly into GitHub. You write a
plain-text configuration file - called a **workflow** - and GitHub reads it and
runs your commands automatically.

You don't install anything extra. You don't click a button. You just push code,
and GitHub does the rest.

The workflow file lives at `.github/workflows/ci.yml` inside your repository.
That specific folder name is not negotiable - GitHub only looks there.

> **Analogy:** Think of `sanity.bat` as a checklist you run manually before
> leaving the office. GitHub Actions is the same checklist, but it runs
> automatically the moment you walk out the door - whether you remembered to
> run it yourself or not.

---

## 2. Why Does This Project Need It Right Now?

Today, the only safety net is `.\sanity.bat`, which runs on your machine,
manually. That means:

- If you forget to run it before pushing, broken code reaches the repository.
- Other contributors (or future you) receive code with no automated guarantee
  it passes.
- Cycode scans run on every PR, but Cycode only catches **security** problems -
  it does not run your tests, check types, or enforce formatting.

Right now there are 468 tests and 96% coverage. That protection is only
valuable if the tests are actually run before code merges. GitHub Actions makes
that automatic.

---

## 3. When Is It the Right Choice?

### Use it when

- You want quality checks to run on every push without relying on any
  individual to remember.
- You want a visible green/red status on every PR before anyone reviews it.
- The checks are fast enough to run in the cloud on a clean machine (this
  project's full `sanity.bat` takes under 2 minutes).

### Do not use it for

- Tasks that need live Salesforce credentials - this project deliberately keeps
  those off CI entirely. The tests mock all Salesforce calls, so no credentials
  are needed in CI.
- One-off admin scripts like `export_contract_pdfs.py` - those run locally
  against real orgs and are not suitable for automation.

---

## 4. Benefits

| Who benefits | What gets better |
| --- | --- |
| You | Never wonder "did I forget to run sanity.bat?" - CI answers that automatically |
| Reviewers | Can see a green badge before reading a single line of code |
| Future contributors | Get instant feedback on their first PR without needing setup help |
| The codebase | Catches "works on my machine" problems - CI uses a clean Linux environment, exposing missing imports or wrong flags |

---

## 5. Risks and How to Recover

| Risk | How likely | Recovery |
| --- | --- | --- |
| YAML syntax error in `ci.yml` | Low - validate with `python -c "import yaml; ..."` before pushing | Delete the file, fix locally, re-push |
| CI uses Linux; your machine is Windows | Medium - minor flag differences possible | `sanity.bat` stays as the Windows gate; CI is the Linux gate. Both are intentional. The B2 alignment step keeps them in sync. |
| Secret accidentally written into `ci.yml` | Low - use `${{ secrets.NAME }}` syntax only; Cycode catches plain-text secrets | Rotate the secret immediately; force-push to remove it from history |
| CI is red but `sanity.bat` is green | Low - only happens if commands diverge | B2 fixes this by aligning commands exactly using `sanity.bat` as the source of truth |
| The workflow blocks all future PRs if misconfigured | Low - always test on a feature branch, not `main` | If it merges broken, delete `.github/workflows/ci.yml` and push - the workflow disappears immediately |

---

## What Comes Next

Once you are comfortable with these concepts, proceed to the implementation:

1. Switch to **`infra-guide`** chat mode.
2. Confirm you are on `main` with a clean tree (`git status`).
3. Confirm `.\sanity.bat` is green before branching.
4. Say **"go"** and the guide will walk through each step - explaining what
   you are doing and why before asking you to run anything.

The full step-by-step instructions, correct `ci.yml` content, and the
⚠️ Command Discrepancy table (which flags where `docs/github-actions-guide.md`
examples differ from `sanity.bat`) are all in
[`docs/pr-group-b-review.md`](pr-group-b-review.md).

---

## Related Documents

- [`docs/pr-group-b-review.md`](pr-group-b-review.md) - Full planning pack for
  B1/B2/B3, including the correct `ci.yml` content and command alignment table
- [`docs/github-actions-guide.md`](github-actions-guide.md) - Step-by-step
  setup guide (note: example commands are corrected in the review doc)
- [`docs/workflow-prompts.md`](workflow-prompts.md) - Copilot workflow cheat
  sheet; Step 0.5 covers when to use `infra-guide` mode
- [`docs/pr-roadmap-section-8-4.md`](pr-roadmap-section-8-4.md) - Group B rows
  B1/B2/B3

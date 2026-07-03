---
applyTo: ".github/workflows/**,.github/actions/**"
description: "CI/CD and pipeline hardening: Action pinning, least-privilege tokens, workflow-injection prevention, OIDC, secret scanning, SAST gating, SBOM, and AI/supply-chain integrity."
owner: "TODO: team-or-DL"
lastReviewed: "2026-07-01"
reviewCadence: "quarterly"
---

# CI/CD Pipeline Security Rules

> **Precedence (most specific wins; on conflict, choose the STRICTER rule):**
> 1. **This file** - governs anything under `.github/**` (workflows, actions).
> 2. `security.instructions.md` - canonical code-level Cycode/SAST rules.
> 3. `security.instructions.owasp-expanded.md` - broad OWASP/CWE coverage.
> 4. `*.skill.md` - human-facing narrative guidance.
>
> The pipeline is a **trust boundary and a code-execution environment.** Treat
> every event payload, third-party Action, and injected variable as untrusted.
> The same "real protection, not scanner-appeasement" philosophy from
> `security.instructions.md` applies here.

## Pipeline Threat Model

Before editing a workflow, ask:

1. What can a contributor (including from a fork PR) cause this workflow to run?
2. What secrets or tokens are reachable from this job?
3. Does any step interpolate attacker-controllable text into a shell?
4. Does any step check out and execute untrusted code with elevated privileges?
5. Are third-party Actions pinned to an immutable reference?
6. If this job is compromised, what is the blast radius (secrets, registry
   pushes, cloud access, branch protection)?
7. Does the workflow fail closed on a security-gate failure?

Assume fork PRs are hostile. Assume any floating tag can change under you.

## Pin Third-Party Actions to a Full Commit SHA

Floating tags (`@v4`, `@main`) are mutable - the code behind them can change
after review. Pin every third-party Action to a **full 40-character commit SHA**
and record the human-readable version in a trailing comment.

```yaml
# Good - immutable, auditable.
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2

# Forbidden - mutable references.
- uses: actions/checkout@v4
- uses: some-org/some-action@main
```

- First-party `actions/*` may use SHA pins too; third-party/unverified Actions
  **must**.
- Prefer Actions from verified creators; review the source at the pinned SHA
  before adoption.
- Use Dependabot / a pinning tool to bump SHAs via reviewed PRs, so pinning does
  not mean going stale.
- Avoid Actions that run arbitrary post-install or curl-pipe-to-shell steps.
- Confirm any AI-suggested Action actually exists and is the intended, maintained
  project (guard against typo-squatted / hallucinated Action names).

## Container & Base Image Integrity

- Pin container images used by jobs/steps to a digest (`image@sha256:...`), not a
  floating tag.
- Pull base images from approved registries only.
- Scan images in the pipeline where tooling is available.

## Least-Privilege `GITHUB_TOKEN`

Default the token to **no permissions** at the workflow level, then grant the
minimum each job needs. This limits blast radius if a step is compromised.

```yaml
permissions: {}          # deny-all at the top level

jobs:
  build:
    permissions:
      contents: read     # elevate only what THIS job needs
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<sha>  # v4.x
```

- Never set `permissions: write-all`.
- Grant `contents: write`, `packages: write`, `id-token: write`, etc. only on the
  specific job that requires it, ideally in a separate, minimal job.
- Restrict who can approve/run workflows on fork PRs (require approval for first-
  time contributors).
- Store secrets in GitHub Environments with required reviewers for sensitive
  deploys.

## Prefer OIDC Federation Over Long-Lived Secrets

Use short-lived, workload-identity credentials instead of storing static cloud
keys as repository secrets.

```yaml
permissions:
  id-token: write        # required for OIDC
  contents: read

steps:
  - uses: aws-actions/configure-aws-credentials@<sha>  # v4.x
    with:
      role-to-assume: arn:aws:iam::<acct>:role/<ci-role>
      aws-region: us-east-1
      # no aws-access-key-id / aws-secret-access-key
```

- Prefer OIDC for AWS/Azure/GCP/HashiCorp Vault and container registries.
- Scope the assumed role to the specific repo/branch/environment via the trust
  policy's subject claim.
- If long-lived secrets are unavoidable, scope them tightly, rotate regularly,
  and never expose them to fork-PR workflows.

## Prevent Workflow Command Injection

This is the CI equivalent of shell injection. Never interpolate
attacker-controllable `${{ ... }}` expressions **directly** into a `run:` script
- GitHub substitutes the raw value before the shell runs, so a crafted PR title
or branch name can execute commands.

Untrusted expressions include (non-exhaustive): `github.event.issue.title`,
`github.event.issue.body`, `github.event.pull_request.title`,
`github.event.pull_request.body`, `github.event.comment.body`,
`github.event.review.body`, `github.head_ref`, `github.event.*.head.ref`, and
any commit message or committer/author fields.

```yaml
# Forbidden - PR title is substituted straight into the shell.
- run: echo "Title: ${{ github.event.pull_request.title }}"

# Required - pass through an env var and reference it as a shell variable,
# so the value is data, not code. Quote it.
- env:
    PR_TITLE: ${{ github.event.pull_request.title }}
  run: echo "Title: $PR_TITLE"
```

- Bind untrusted values to `env:` and reference them as quoted shell variables.
- Prefer official Actions with typed inputs over hand-written shell.
- Avoid `actions/github-script` that concatenates untrusted expressions into code.

## Do Not Execute Untrusted PR Code With Secrets

`pull_request_target` and `workflow_run` run in the **base repo context with
access to secrets**, while checking out **untrusted fork code** - a classic path
to secret exfiltration and RCE.

```yaml
# Dangerous pattern - elevated context + untrusted checkout + build/test.
on: pull_request_target
jobs:
  test:
    steps:
      - uses: actions/checkout@<sha>
        with:
          ref: ${{ github.event.pull_request.head.sha }}   # untrusted code
      - run: npm ci && npm test                            # executes it with secrets
```

Rules:

- Use `pull_request` (no secrets, no write token) for building/testing fork PRs.
- If you must use `pull_request_target`, **do not check out or execute fork
  code**; use it only for label/comment automation with minimal permissions.
- Never expose deployment secrets to any workflow that runs untrusted code.
- Split "run untrusted code" and "use secrets" into separate, gated jobs.

## Secret Scanning & Push Protection

- Enable secret scanning **and push protection** at the repo/org level so
  credentials are blocked before they land.
- Run `detect-secrets` in CI against the committed baseline; fail the build on
  new unaudited findings (do not rely on the local baseline alone).
- Never `echo` secrets, write them to logs/artifacts, or pass them as plaintext
  build args. Mask them and scope them to the job that needs them.

```yaml
- name: Secret scan
  run: |
    detect-secrets scan --baseline .secrets.baseline
    detect-secrets audit --report --fail-on-unaudited .secrets.baseline
```

## SAST Gating (fail closed)

Mirror the local `--fail-on HIGH` policy in the pipeline and enforce it as a
**required status check** so HIGH/CRITICAL findings block merge.

```yaml
- name: SAST (Cycode / bandit)
  run: |
    bandit -r src/ scripts/ -c pyproject.toml --severity-level high
    # Cycode scan invoked per approved org integration; fail on HIGH/CRITICAL.
```

- Make the SAST job a required check in branch protection.
- Do not allow suppressions to be added in the same PR without reviewer sign-off
  and recorded rationale (see `security.instructions.md`).
- Run dependency and IaC scanning (e.g. `pip-audit`, and a Terraform/Dockerfile
  scanner if such files exist) as gating checks too.

## SBOM & Artifact Provenance

- Generate an SBOM (CycloneDX or SPDX) as a build artifact for each release.
- Where supported, produce build provenance / attestations (SLSA-style) and sign
  artifacts (e.g. Sigstore/cosign).
- Verify signatures/attestations before promoting artifacts to a protected
  environment.

```yaml
- name: Generate SBOM
  run: cyclonedx-py requirements -o sbom.json   # example; use approved tooling
- uses: actions/upload-artifact@<sha>           # v4.x
  with:
    name: sbom
    path: sbom.json
```

## Runner & Environment Hardening

- Prefer GitHub-hosted runners for public repos; **avoid `self-hosted` runners on
  public repos** (fork PRs could execute code on your infrastructure).
- If self-hosted runners are required, make them ephemeral, isolated, non-
  privileged, and never reachable by fork-PR workflows.
- Pin the runner image where reproducibility matters; avoid installing tools via
  unpinned curl-pipe-to-shell.
- Set sensible `timeout-minutes` on jobs to bound runaway/abusive runs.
- Set `concurrency` to cancel superseded runs and limit resource abuse.

## Repository & Branch Protection

- Require pull-request review (including CODEOWNERS) before merge to protected
  branches.
- Require the SAST, secret-scan, and dependency-scan checks to pass.
- Require signed commits where feasible; enforce linear history if desired.
- Restrict who can edit workflows and repository/environment secrets.
- Require approval to run workflows for first-time / fork contributors.

## AI-Generated Workflows (Copilot workstream)

Because pipeline YAML may be AI-authored, apply extra scrutiny:

- Human-review any AI-generated workflow that adds `permissions`, secrets,
  `pull_request_target`/`workflow_run`, self-hosted runners, or `run:` steps that
  reference `${{ github.event.* }}`.
- Verify AI-suggested Actions and container images exist, are maintained, and are
  pinned to a SHA/digest.
- Never accept an AI-suggested security-gate suppression or a permissions
  broadening without recorded rationale.

## CI/CD Pre-Merge Checklist

- [ ] All third-party Actions pinned to a full commit SHA (version in comment).
- [ ] Container images pinned to a digest from an approved registry.
- [ ] `permissions: {}` at workflow level; minimal per-job elevation.
- [ ] No `write-all`; no secrets exposed to untrusted-code workflows.
- [ ] OIDC used for cloud/registry auth where available; no static keys in fork-reachable jobs.
- [ ] No untrusted `${{ github.event.* }}` interpolated into `run:` (passed via `env:` and quoted).
- [ ] `pull_request_target`/`workflow_run` do not check out or execute fork code.
- [ ] Secret scanning + push protection enabled; CI fails on new unaudited secrets.
- [ ] SAST/dependency/IaC scans run and are required checks; fail closed on HIGH/CRITICAL.
- [ ] SBOM produced; artifacts signed/attested where supported.
- [ ] No self-hosted runners exposed to public/fork PRs; job timeouts set.
- [ ] Branch protection: reviews, CODEOWNERS, required checks, restricted workflow/secret edits.
- [ ] AI-generated workflow changes human-reviewed; suggested Actions/images verified.

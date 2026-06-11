# PR Roadmap: Section 8.4 Recommended Improvements

Based on the current §8.4 Recommended Improvements in
[`docs/salesforce-admin-utilities-guide.md`](salesforce-admin-utilities-guide.md),
the remaining work is grouped below into safe, reviewable pull requests.
See the `release-pr-planner` chat mode for guidance on splitting individual items further.

---

## PR Group A - Low-Risk Hygiene

> **Recommended implementation order:** A4 -> A1 -> A2 -> A3.
> Do A2 before A3 so that any type errors mypy surfaces in `update_packages.py`
> are caught at the same time as the logging rework, rather than needing a second pass.

| PR | Work | Size | Scope | Why Separate |
| --- | --- | --- | --- | --- |
| A4 | ~~Delete `scripts/archive/`~~ | ~~**XS**~~ | ✅ Done - folder did not exist (2026-05-28) | Repository cleanup; avoid mixing with logic changes |
| A1 | ~~Rename `list_inactive_users._parse_args` to `parse_args`~~ | ~~**XS**~~ | ✅ Done - 4 files, 11 lines, zero logic change (2026-05-28, commit 92d7150) | Small consistency fix; easy to review |
| A2 | ~~Extend mypy `files` to include `scripts/`~~ | ~~**S**~~ | ✅ Done - 1 line in `pyproject.toml`; 12 files checked, no errors (2026-05-28, commit caf8226) | Quality-gate change; may reveal type issues requiring follow-up fixes |
| A3 | ~~Replace `print()` with `logging` in `update_packages.py`~~ | ~~**S**~~ | ✅ Done - all `print()` calls replaced; `TestPrintHelpers` rewritten with `caplog`; `test_main_calls_configure_logging` added; guide updated (2026-05-28, commit 58990ec) | Behaviour-adjacent; visible output format change; test and doc rework needed |

---

## PR Group B - CI and Quality Gates ✅ Complete (2026-05-29, branch chore/group-b-ci)

> **Completed 2026-05-29.** GitHub Actions CI workflow created and pushed;
> commands aligned with `sanity.bat`; CONTRIBUTING.md updated.
> Ford JFrog Artifactory DNS issue resolved with a `grep -v "index-url"` pipe.
> 20 cross-platform test failures (Linux CI vs Windows dev) fixed across
> 5 test files before merge.

| PR | Work | Why Separate |
| --- | --- | --- |
| B1 | ~~Add GitHub Actions CI workflow~~ | ✅ Done - `.github/workflows/ci.yml` created (2026-05-29) |
| B2 | ~~Align `sanity.bat` and CI commands~~ | ✅ Done - commands verified identical; `sanity.bat` header comment added |
| B3 | ~~Document CI workflow in `CONTRIBUTING.md`~~ | ✅ Done - "Automated CI Checks" section added (2026-05-29) |

---

## PR Group C - Manifest CSV Enhancement ✅ Complete (2026-05-28, commit 505a701)

> **Completed 2026-05-28.** All four sub-items are done: `AccountName` and
> `AccountSCAID` added to both export manifests via SOQL (Order and
> Quote -> Opportunity -> Account relationships); ZIP scripts pass columns through
> unchanged; tests confirm column preservation across all four test files.

| PR | Work | Why Separate |
| --- | --- | --- |
| C1 | ~~Discovery spike: confirm customer-name Salesforce field~~ | ✅ Done |
| C2 | ~~Add customer name to export manifests~~ | ✅ Done - `AccountName` + `AccountSCAID` added (commit 505a701) |
| C3 | ~~Update ZIP scripts to preserve/use new manifest column~~ | ✅ Done - columns passed through unchanged |
| C4 | ~~Update docs and sample outputs~~ | ✅ Done |

---

## PR Group D - Shared Library Refactor

> This should **not** be one PR.

| PR | Work | Why Separate |
| --- | --- | --- |
| D1 | Add shared query helpers to `src/sf_admin_utils/` | Introduces reusable code with tests; no script migration yet |
| D2 | Add shared download/session helpers | Isolates retry, timeout, redaction, and path logic |
| D3 | Migrate Contract export script to shared helpers | One script migration at a time |
| D4 | Migrate Quote export script to shared helpers | Quote flow is riskier because of Visualforce/session handling |
| D5 | Remove duplicated code after both scripts are migrated | Cleanup only after behaviour is proven equivalent |
| D6 | Update docs and architecture diagrams | Documentation after final structure is settled |

---

## PR Group E - Weekly Order Status Report

> New script to query Salesforce Order records, calculate status deltas
> week-over-week, and email a formatted summary to a distribution list.
> Provides trend visibility for closing out all orders.
> See `requirements/REQ-E-order-status-report/initial_user_request.md` for
> full scope.

| PR | Work | Why Separate |
| --- | --- | --- |
| E1 | Add SOQL query and snapshot persistence logic | Core data layer; testable in isolation |
| E2 | Add delta calculation and report formatting | Business logic separate from I/O |
| E3 | Add email delivery with recipients file lookup | Network concern isolated from data logic |
| E4 | Add CLI interface (`--dry-run`, `--since`, `--format`) | Usability layer after core logic works |
| E5 | Add tests (mock SOQL, mock email, delta edge cases) | Full coverage before docs |
| E6 | Add beginner documentation | Guide after behaviour is final |

---

## PR Group F - Optional HTML/CSS User Experience

> Do not start here until the core backlog (Groups A-E) is stable.

| PR | Work | Why Separate |
| --- | --- | --- |
| F1 | Generate static HTML summary reports from existing manifests | Lowest-risk frontend value |
| F2 | Add CSS styling for readable local reports | Pure presentation change |
| F3 | Add SVG trend charts (multi-line, dates on X-axis) for order status snapshots | Charting logic separate from layout |
| F4 | Add links from docs to generated report examples | Documentation only |
| F5 | Consider local interactive UI only after users validate the static report approach | Avoid premature web-app complexity |

---

## PR Group J - Test Coverage Remediation

> Raise per-module coverage to ≥ 90% for the four files identified below the
> gate threshold in the 2026-06-08 `sanity.bat` run.  The project-wide total
> (91.64%) already meets the `--cov-fail-under=90` gate, but low per-module
> numbers create a fragile safety margin.
>
> See `requirements/REQ-J-coverage-remediation/requirements.md` for the full
> test plan, implementation notes, and acceptance criteria.

| PR | Work | Size | Priority |
| --- | --- | --- | --- |
| J1 | Add tests for uncovered paths in `scripts/extract_object_data.py` (54% -> ≥ 90%) | **M** | 🔴 Critical |
| J2 | Add mock-based tests for `src/sf_admin_utils/email_sender.py` Outlook COM path (65% -> ≥ 90%), or add `# pragma: no cover` with justification | **S** | 🔴 Critical |
| J3 | Add targeted tests for uncovered branches in `src/sf_admin_utils/order_snapshot.py` (81% -> ≥ 90%) | **S** | 🟡 Medium |
| J4 | Add targeted tests for uncovered branches in `src/sf_admin_utils/order_report.py` (85% -> ≥ 90%) | **S** | 🟡 Medium |

**Recommended implementation order:** J1 -> J2 -> J3 -> J4.
J1 first because it has the largest coverage gap and the most test infrastructure
to build (interactive prompts, export pipeline mocking).  J2 next because COM
mocking decisions (mock vs `# pragma: no cover`) affect the project's test
strategy and should be agreed before smaller items.

**Files NOT in scope (🟢 Monitor):**

| File | Cover | Reason |
| --- | --- | --- |
| `scripts/order_status_report.py` | 87% | Within 5% of gate; no dedicated work needed |
| `scripts/user_status_report.py` | 88% | Within 5% of gate; no dedicated work needed |

---
description: "Beginner-friendly code review of staged changes."
mode: agent
---

Review the staged diff against the project's instruction files.

Check for:

1. Correctness bugs.
2. Salesforce Production safety risks.
3. Security or secret-handling issues.
4. PII logging or report-output risks.
5. Test coverage gaps.
6. Type-checking issues.
7. Ruff/formatting issues.
8. Documentation gaps.
9. Beginner-readability issues.
10. Dependency-management mistakes.

For each finding, give:

- Severity: blocker, major, minor, nit.
- File and line, if available.
- Rule or principle violated.
- Why it matters.
- Concrete suggested fix.

Use this table:

| Severity | File:Line | Issue | Why It Matters | Suggested Fix |
| --- | --- | --- | --- | --- |

End with:

1. A short beginner-friendly summary.
2. A recommended commit message.
3. Whether it is safe to merge.

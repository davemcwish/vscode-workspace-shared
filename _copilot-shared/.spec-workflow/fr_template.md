# User Story: [FR-Index] - [Short Title]

## 1. Description

**As a** [Persona — e.g., Salesforce admin, team lead, auditor]
**I want to** [Action — e.g., export inactive user data as CSV]
**So that** [Business value — e.g., I can report on licence usage quarterly]

## 2. Context & Business Rules

- **Trigger:** [What initiates this — e.g., user runs CLI command]
- **Salesforce objects:** [API names with plain-English explanation]
- **Rules enforced:**
  - [Rule 1 — e.g., "Only include users inactive > 90 days"]
  - [Rule 2]

## 3. Non-Functional Requirements

- **Performance:** [e.g., "Must handle 10,000 records in < 60 seconds"]
- **Security:** [e.g., "Must not log user email addresses"]
- **Cross-platform:** [e.g., "Must work on Windows and Linux CI"]

## 4. Acceptance Criteria (BDD)

**Scenario 1: [Happy path]**

- **Given** [Precondition]
- **When** [Action — e.g., user runs `python scripts/x.py --output-dir ./out`]
- **Then** [Observable outcome — e.g., CSV file created with expected columns]

**Scenario 2: [Edge case / error path]**

- **Given** [Precondition]
- **When** [Action]
- **Then** [Observable outcome — e.g., clear error message, exit code 1]

## 5. Out of Scope

- [Explicitly excluded items to keep this story small]
- [e.g., "Does not include HTML report generation — separate story"]

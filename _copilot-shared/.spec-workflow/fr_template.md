# User Story: [FR-Index] - [Short Title]

## 1. Description

**As a** [Persona - e.g., Salesforce admin, team lead, auditor]
**I want to** [Action - e.g., export inactive user data as CSV]
**So that** [Business value - e.g., I can report on licence usage quarterly]

## 2. Context & Business Rules

- **Trigger:** [What initiates this - e.g., user runs CLI command]
- **Salesforce objects:** [API names with plain-English explanation]
- **Rules enforced:**
  - [Rule 1 - e.g., "Only include users inactive > 90 days"]
  - [Rule 2]

## 3. Non-Functional Requirements

- **Performance:** [e.g., "Must handle 10,000 records in < 60 seconds"]
- **Security:** [e.g., "Must not log user email addresses"]
- **Cross-platform:** [e.g., "Must work on Windows and Linux CI"]

## 4. Formal Requirements (EARS Notation)

Use EARS (Easy Approach to Requirements Syntax) for precise, testable
statements. Choose the pattern that best fits each requirement:

| Pattern | Template |
| --- | --- |
| Ubiquitous | THE SYSTEM SHALL [behaviour]. |
| Event-driven | WHEN [trigger], THE SYSTEM SHALL [behaviour]. |
| State-driven | WHILE [state], THE SYSTEM SHALL [behaviour]. |
| Unwanted behaviour | IF [condition], THEN THE SYSTEM SHALL [response]. |
| Optional feature | WHERE [feature included], THE SYSTEM SHALL [behaviour]. |

Each requirement must be: **Testable**, **Unambiguous**, **Necessary**,
**Feasible**, and **Traceable**.

**Examples:**

- WHEN the user clicks [▶ LAUNCH MISSION], THE SYSTEM SHALL validate all
  parameters and POST to `/api/jobs`.
- WHILE a job is running, THE SYSTEM SHALL stream log output to the terminal
  panel via WebSocket.
- IF the target org is PROD, THEN THE SYSTEM SHALL display a confirmation
  modal before proceeding.

**Requirements:**

- [EARS-001]: [EARS statement]
- [EARS-002]: [EARS statement]
- [EARS-003]: [EARS statement]

## 5. Acceptance Criteria (BDD)

**Scenario 1: [Happy path]**

- **Given** [Precondition]
- **When** [Action - e.g., user runs `python scripts/x.py --output-dir ./out`]
- **Then** [Observable outcome - e.g., CSV file created with expected columns]

**Scenario 2: [Edge case / error path]**

- **Given** [Precondition]
- **When** [Action]
- **Then** [Observable outcome - e.g., clear error message, exit code 1]

## 6. Out of Scope

- [Explicitly excluded items to keep this story small]
- [e.g., "Does not include HTML report generation - separate story"]

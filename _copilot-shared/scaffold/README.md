# [Project Name]

<!--
  SCAFFOLD TEMPLATE - fill in the sections marked [FILL IN].
  Delete or collapse any section that doesn't apply to your project.
  This file was copied from _copilot-shared\scaffold\README.md.
-->

[FILL IN: One paragraph that answers three questions: (1) What does this
project do? (2) Who is it for? (3) Why does it exist?]

---

## Table of Contents

- [What This Project Contains](#what-this-project-contains)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Usage](#usage)
- [Running the Tests](#running-the-tests)
- [Quality Checks](#quality-checks)
- [Project Structure](#project-structure)
- [Security and Data Handling](#security-and-data-handling)
- [Contributing](#contributing)

---

## What This Project Contains

[FILL IN: A table or list of the main scripts/modules/components and what each
one does. Keep it high-level - detailed usage goes in docs/ or a separate guide.]

---

## Prerequisites

[FILL IN: What must be installed before this project will run.
 List the language runtime, CLI tools, accounts, and access permissions needed.
 Assume the reader has never done this before.]

---

## Setup

[FILL IN: Step-by-step instructions to go from a fresh machine to a working
local environment. Include every command. Explain what each command does.]

---

## Usage

[FILL IN: How to run the main script(s). Include at least one complete example
command with realistic (but not real) argument values.]

---

## Running the Tests

[FILL IN: How to run the automated test suite. Include the exact command.
 If the test suite requires a virtual environment or specific setup, say so.]

---

## Quality Checks

The project uses a local quality gate (`sanity.bat` / `sanity_v.bat`) that
mirrors the CI pipeline. Run this before every commit:

```bat
sanity.bat
```

The gate runs: ruff (format + lint), mypy, bandit, detect-secrets, pytest.
See `CONTRIBUTING.md` for details.

---

## Project Structure

[FILL IN: A short directory tree showing the key folders and what they contain.
 You can copy the output of `tree /F /A` and trim it down.]

---

## Security and Data Handling

[FILL IN: Note what data the project handles, whether any of it is sensitive
(PII, credentials, internal records), and how it is protected. Reference
SECURITY.md for the full policy.]

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

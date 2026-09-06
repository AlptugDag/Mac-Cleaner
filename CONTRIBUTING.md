# Contributing to Mac-Cleaner

First off, thank you for considering contributing to Mac-Cleaner! It's people like you that make open-source tools great.

## How Can I Contribute?

### Reporting Bugs
- Ensure the bug was not already reported by searching on GitHub under Issues.
- If you're unable to find an open issue addressing the problem, open a new one. Be sure to include a title and clear description, as much relevant information as possible, and a code sample or an executable test case demonstrating the expected behavior that is not occurring.

### Suggesting Enhancements
- Open a new issue with a clear title and description.
- Explain why this enhancement would be useful to most users.

### Pull Requests
1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes (e.g. Shellcheck).
5. Issue that pull request!

## Styleguides
- Bash scripts should follow standard Shellcheck linting rules.
- Prefer explicit paths and check for existence before `rm -rf`.
- Always implement both a dry-run and an apply mode for new cleanup targets.

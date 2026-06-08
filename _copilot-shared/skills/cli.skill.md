# Skill: CLI Design (argparse)

## Standard Pattern

Every script in `scripts/` must have:

1. A `parse_args()` function returning `argparse.Namespace`.
2. A `main()` function that calls `parse_args()` then executes logic.
3. An `if __name__ == "__main__": main()` guard.

## Common Arguments

| Argument | Purpose | Notes |
|----------|---------|-------|
| `--output-dir` | Where to write output files | Defaults to current directory or a sensible location |
| `--sf-alias` | Salesforce org alias | Overrides `.env` value |
| `--limit` | Max records to process | `None` = no limit (all records) |
| `--dry-run` | Log plan without executing | Boolean flag |
| `--yes` | Skip interactive confirmation | For CI/scripted use |
| `--workers` | Thread pool size | Default varies by script |
| `--force-redownload` | Re-download existing files | Boolean flag |
| `--log-level` | Override logging verbosity | Choices: DEBUG, INFO, WARNING, ERROR |

## Help Text

- Every argument must have a `help=` string.
- `--help` output must be understandable by a beginner.
- Include default values in help text: `(default: %(default)s)`.

## Validation

- Validate paths exist (or can be created) before starting work.
- Validate mutually exclusive options.
- Print a clear error and exit with code 1 on invalid input.

## Example

```python
def parse_args() -> argparse.Namespace:
    """Parse command-line arguments for the export script."""
    parser = argparse.ArgumentParser(
        description="Export contract PDFs from Salesforce.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path.cwd() / "output",
        help="Directory for downloaded files (default: %(default)s)",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=None,
        help="Max records to export; omit for all records (default: %(default)s)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Log what would be done without downloading",
    )
    return parser.parse_args()
```

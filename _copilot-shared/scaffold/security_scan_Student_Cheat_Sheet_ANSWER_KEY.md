# Security Scan Student Cheat Sheet Answer Key

## Exercise 1

A fake hard-coded password should trigger:

```text
SECRET-HARDCODED
```

The exact result depends on whether the value looks secret-like and is long
enough to match the rule.

## Exercise 2

An unpinned requirements.txt line such as `requests` should trigger:

```text
DEP-UNPINNED-PIP
```

A pinned version would look like:

```text
requests==2.32.0
```

## Exercise 3

A package.json dependency such as `"demo": "^1.2.3"` should trigger:

```text
DEP-UNPINNED-NPM
```

The caret means the version is a range, not an exact pin.

## Exercise 4

With fail-on disabled, findings can still be printed, but the script should not
exit with code 1 because of finding severity. This is useful for learning or
report-only runs.

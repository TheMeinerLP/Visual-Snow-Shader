---
description: Full test pipeline (Tier 1 + Tier 2 if available)
allowed-tools: Bash, Read
---

Run Tier-1 and Tier-2 tests, optionally targeting a specific Iris version.

Argument: $ARGUMENTS (optional Iris version, e.g. "1.7.5")

## Step 1 — Tier 1

```
!python3 test/tier1-lint/lint.py shaders/
```

If errors: stop here and delegate to the `shader-tester` subagent for
analysis.

## Step 2 — Tier 2 (only if Tier 1 is green)

Check Docker:

```
!docker info > /dev/null 2>&1 && echo "docker ok" || echo "docker not available"
```

If available, build the container and run the test:

```
!cd test/tier2-integration && docker build --build-arg IRIS_VERSION=${ARGUMENTS:-1.7.5} -t iris-test . && cd ../..
!docker run --rm -v "$(pwd):/shader-mount:ro" iris-test
```

## Output

Summarize whether both tiers pass with a single line per tier. On
FAIL: quote the relevant error message verbatim.

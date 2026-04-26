---
description: Run the Tier-1 linter over the shader pack
allowed-tools: Bash(python3 test/tier1-lint/lint.py:*)
---

Run the static linter:

```
!python3 test/tier1-lint/lint.py shaders/
```

If errors are reported, briefly explain per file what's wrong and
which fix is recommended. On 0 errors: a single-line confirmation
"Lint clean — ready to commit".

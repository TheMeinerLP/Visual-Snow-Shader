---
description: Create a new language file (delegates to the translator subagent)
---

Argument: $ARGUMENTS (language code such as `fr_fr`, `es_es`, `pt_br`)

Delegate to the `translator` subagent. Pass:

1. The language code from $ARGUMENTS
2. The source path: `shaders/lang/en_us.lang`
3. The existing German example: `shaders/lang/de_de.lang`

After the subagent completes:

1. Read the created file
2. Run `python3 test/tier1-lint/lint.py shaders/` to ensure the new
   lang file doesn't introduce consistency issues
3. Propose a CHANGELOG entry:
   ```
   ### Added
   - Localization: <language name> (`shaders/lang/<code>.lang`)
   ```
4. Suggest the commit command (but do NOT execute it):
   ```
   git add shaders/lang/<code>.lang CHANGELOG.md
   git commit -m "feat(i18n): add <language name> translation"
   ```

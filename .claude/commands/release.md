---
description: Prepare a new release (version, changelog, tag)
allowed-tools: Bash, Read, Edit, Write
---

Prepare a release. Argument: $ARGUMENTS (version, e.g. "0.9.0")

## Steps

### 1. Sanity checks

- Current branch is `main`?
  ```
  !git rev-parse --abbrev-ref HEAD
  ```
- Working tree clean?
  ```
  !git status --short
  ```
- Tier-1 linter green?
  ```
  !python3 test/tier1-lint/lint.py shaders/
  ```

If anything is off: stop and report what needs to happen.

### 2. Version

User requested: $ARGUMENTS

Verify the format (semver MAJOR.MINOR.PATCH). If invalid or missing,
ask back.

### 3. Update CHANGELOG.md

- Read `CHANGELOG.md`
- Move all entries under `## [Unreleased]` to `## [VERSION] — DATE`
  (DATE = today, ISO format)
- Insert a new empty `## [Unreleased]` header at the top
- Update the comparison links at the bottom of the file

### 4. Package the shader pack as ZIP

```
!cd shaders && zip -qr ../visual-snow-shader-${ARGUMENTS}.zip . && cd ..
!ls -lh visual-snow-shader-${ARGUMENTS}.zip
```

### 5. Git operations (prepare only, do NOT push)

```
!git add CHANGELOG.md shaders/
!git commit -m "chore(release): ${ARGUMENTS}"
!git tag -a "v${ARGUMENTS}" -m "Release ${ARGUMENTS}"
```

### 6. Summary

Report back to the user:
- Version, tag, ZIP file
- Suggested next step:
  ```
  git push origin main && git push origin v${ARGUMENTS}
  ```
- GitHub release URL hint:
  `https://github.com/OneLiteFeather/visual-snow-shader/releases/new?tag=v${ARGUMENTS}`

## What You Do NOT Do

- Never push automatically — the user must trigger that explicitly
- Never publish a GitHub release directly — only create the local
  commit and tag
- For major bumps (X.0.0), additionally ask about a migration guide

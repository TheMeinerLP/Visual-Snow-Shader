---
name: Bug Report
about: Shader effect doesn't work or Iris shows compile errors
title: '[Bug] '
labels: bug
assignees: ''
---

## Description

What is the observed behavior? What did you expect?

## Reproduction

1. Profile: <e.g. Minimal / Moderate / Severe>
2. Symptoms enabled: <which `ENABLE_*` toggles are on?>
3. Steps to trigger:
   - …

## Versions

- Minecraft: <e.g. 1.21.1>
- Iris: <e.g. 1.7.5>
- Sodium: <e.g. 0.5.11>
- GPU/Driver: <e.g. NVIDIA RTX 4080, driver 555.42 / AMD RX 6800, Mesa 24.x>
- Visual Snow Shader: <version from CHANGELOG, e.g. 0.8.0>

## Logs

For compile errors or crashes:

<details>
<summary>latest.log excerpt</summary>

```
PASTE THE RELEVANT EXCERPT FROM .minecraft/logs/latest.log HERE
```

</details>

## Screenshots

For visual issues: please include before/after screenshots
(with/without shader, with/without the suspect effect).

## Already Verified

- [ ] `python3 test/tier1-lint/lint.py shaders/` reports no errors
- [ ] Iris is on a version listed in `.github/workflows/iris-compat.yml`
- [ ] No existing open issue covers this

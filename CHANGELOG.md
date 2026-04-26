# Changelog

All notable changes to this project.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
versioning: [Semver](https://semver.org/) (MAJOR.MINOR.PATCH).

Pre-1.0 means everything is `0.x` with potential breaking changes.

## [0.8.0] — 2026-04-26

### Fixed
- **Palinopsia now actually works.** Two bugs:
  - `clear.colortex2 = false` was missing from `shaders.properties` →
    the trail buffer was reset every frame, breaking accumulation
    across frames
  - The accumulation logic wrote `current * pickup` even in static
    scenes → permanent glow instead of true afterimages.
    Now it only accumulates when the current pixel is brighter than
    the existing trail (max operation)

### Added
- `clear.colortex2 = false` directive with explanatory comment

## [0.7.0] — 2026-04-26

### Fixed
- gbuffer shader compile errors in modern Iris (1.17+):
  - Replaced `gl_TexCoord` with explicit `out vec2 texcoord` varyings
  - Renamed `uniform sampler2D texture` to `gtexture` (built-in
    function name collision)
  - Modernized `texture2D()` to `texture()`

### Changed
- All four gbuffer passes now use modern GLSL conventions
  (style aligned with Complementary/BSL)

## [0.6.0] — 2026-04-26

### Added
- **Four gbuffer pass-through programs** (`basic`, `textured`,
  `textured_lit`, `skybasic`) addressing Iris issue #2537. Without
  these, Iris in 1.17+ does not reliably render vanilla world geometry

### Changed
- `composite.fsh` now writes only to `colortex2` (trail buffer),
  no longer passes the scene back through to `colortex0`

## [0.5.0] — 2026-04-26

### Changed
- **Defaults are now minimal:** only static (amplitude 0.06) plus
  light floaters enabled by default. Other symptoms are opt-in
- New **Minimal** profile as default — game image stays fully visible
- `STATIC_AMPLITUDE` from 0.10 → 0.06, `FLOATERS_OPACITY` from 0.6 → 0.15

### Rationale
- v0.4 had all effects active simultaneously → user feedback that
  the game image was dominated by effects
- Clinical reality (Puledda 2020): static amplitude is subtle in most
  patients, not dominant

## [0.4.0] — 2026-04-26

### Added
- `GLOBAL_INTENSITY` master mix slider (0–100 %)
- `COMPARISON_MODE` split-screen for the screening use case
  (left side normal, right side with effects)

## [0.3.0] — 2026-04-26

### Added
- **Profile system** with 5 clinical phenotypes instead of performance
  tiers: Mild, Moderate, Severe, Static-Only, HPPD
- `lang/de_de.lang` and `lang/en_us.lang` with study tooltips for each
  symptom slider
- Localized slider labels with clinical citations

## [0.2.0] — 2026-04-26

### Fixed
- Floater scaling (was 6× too large)
- Blue Field dot granularity (was chunky/pixelated)
- Static amplitude default adjusted to clinically realistic value

### Added
- Modular `lib/` structure (15 → 36 parameters, each symptom in its
  own file)

## [0.1.0] — 2026-04-26

### Added
- Initial draft with `composite.fsh` + `final.fsh`
- Seven VSS symptom effects: static, palinopsia, photophobia,
  nyctalopia, floaters, blue field, self-light
- Blue light aggravation trigger per Hepschke et al. (2021)

[0.8.0]: https://github.com/OneLiteFeather/visual-snow-shader/releases/tag/v0.8.0
[0.7.0]: https://github.com/OneLiteFeather/visual-snow-shader/releases/tag/v0.7.0
[0.6.0]: https://github.com/OneLiteFeather/visual-snow-shader/releases/tag/v0.6.0
[0.5.0]: https://github.com/OneLiteFeather/visual-snow-shader/releases/tag/v0.5.0
[0.4.0]: https://github.com/OneLiteFeather/visual-snow-shader/releases/tag/v0.4.0
[0.3.0]: https://github.com/OneLiteFeather/visual-snow-shader/releases/tag/v0.3.0
[0.2.0]: https://github.com/OneLiteFeather/visual-snow-shader/releases/tag/v0.2.0
[0.1.0]: https://github.com/OneLiteFeather/visual-snow-shader/releases/tag/v0.1.0

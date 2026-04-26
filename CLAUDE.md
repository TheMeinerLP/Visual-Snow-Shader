# Claude Code Context — Visual Snow Shader

This file is automatically read by Claude Code and gives every session
the full project context.

## Project Goal

An Iris shader pack for Minecraft that simulates the visual symptoms of
**Visual Snow Syndrome (VSS)**. Use cases:

1. **Awareness/empathy** — Show people without VSS how roughly 2.2 % of
   the population permanently perceive the world.
2. **Screening aid** — Parents can use the split-screen mode to test
   whether their child already perceives the simulated effects as their
   normal state (a possible indicator of undiagnosed VSS).

**Not a diagnostic instrument** — formal ICHD-3 diagnosis requires
clinical evaluation. The shader only provides a visual reference point.

## Architecture

```
shaders/
├── shaders.properties      Profiles, slider layout, buffer config
├── gbuffers_*.{vsh,fsh}    Pass-through for vanilla world rendering
├── composite.{vsh,fsh}     Pass 1 — palinopsia accumulation
├── final.{vsh,fsh}         Pass 2 — all effect layers
├── lang/                   en_us, de_de UI labels with tooltips
└── lib/                    Modular effect implementations
    ├── config.glsl         All #defines + slider annotations
    ├── common.glsl         Hashes, luminance(), uniforms
    ├── static.glsl         Visual snow (core symptom)
    ├── palinopsia.glsl     Afterimages
    ├── photophobia.glsl    Light sensitivity
    ├── nyktalopia.glsl     Night blindness
    ├── floaters.glsl       Vitreous floaters
    ├── blue_field.glsl     BFEP
    ├── self_light.glsl     Phosphenes / self-luminescence
    └── info.glsl           Dummy #ifdefs for info tooltips
```

**Pipeline:** vanilla gbuffers → colortex0 → composite (trail in colortex2)
→ final (all effects + master mix) → screen.

## Iris-Specific Gotchas (lessons learned)

These patterns FAIL at runtime even when glslangValidator accepts them.
The `test/tier1-lint/lint.py` catches them.

| Anti-pattern | Why it breaks |
|---|---|
| `gl_TexCoord[N]` in vsh/fsh | The Iris patcher drops it in 1.17+. Use explicit `out vec2 texcoord;` and `in vec2 texcoord;` instead |
| `uniform sampler2D texture;` | Collides with the builtin `texture()` function. Convention: `gtexture` |
| `texture2D(s, uv)` | Deprecated in #version 330+. Use `texture(s, uv)` |
| Missing `gbuffers_basic`, `gbuffers_textured`, `gbuffers_textured_lit`, `gbuffers_skybasic` | Iris #2537 — vanilla world geometry doesn't render reliably |
| Persistent buffer without `clear.colortexN = false` | Buffer is cleared every frame, breaking temporal accumulation |

## Conventions

- **GLSL version:** `#version 330 compatibility` throughout
- **Language:** All code, comments, docs, error messages in English
- **Modular design:** one `lib/<symptom>.glsl` per symptom with an
  `apply<Effect>(color, uv)` function
- **Defaults:** Clinically realistic (see `lib/config.glsl`); profiles
  in `shaders.properties` cover progressive severity levels
- **Localization:** All user-visible strings live in
  `shaders/lang/<lang>.lang`, never hardcoded

## Workflow for Changes

1. **Before every commit:**
   ```bash
   python3 test/tier1-lint/lint.py shaders/
   ```
   Must show zero errors.

2. **For GLSL changes:** if possible, also run Tier 2 locally
   ```bash
   docker build -t iris-test test/tier2-integration/
   docker run --rm -v "$PWD:/shader-mount:ro" iris-test
   ```

3. **Open PR** → CI runs the matrix against multiple Iris versions.

## Common Tasks

### Adding a new VSS effect

1. Create `lib/<new_effect>.glsl` with `vec3 apply<n>(vec3 color, vec2 uv)`
2. `lib/config.glsl`: add `ENABLE_<n>` (int 0/1) plus parameters with
   `// [...]` slider annotations
3. `lib/info.glsl`: tooltip anchor `info_<n>`
4. `final.fsh`: include + conditional call in pipeline order
5. `shaders.properties`: add to `sliders` and the new `screen.<n>`
6. `lang/de_de.lang` + `lang/en_us.lang`: labels and tooltip with
   clinical reference
7. Run `lint.py` — must be clean

### Changing default values

Only in `lib/config.glsl` and `shaders.properties` profiles. Never
hardcode anywhere else. Realistic ranges are documented (Puledda 2020 etc.).

### New language

See `.claude/commands/translate.md` (slash command uses subagent).

## Clinical Sources

- Schankin et al. (2014): first formal characterisation of VSS as a distinct disorder — [10.1093/brain/awu050](https://doi.org/10.1093/brain/awu050)
- Puledda, Schankin, Goadsby (2020): phenotype study n=1100 — *Neurology* — [10.1212/WNL.0000000000008909](https://doi.org/10.1212/WNL.0000000000008909)
- Hepschke, Martin & Fraser (2021): blue-cone / blue-light aggravation — *Front. Neurol.* — [10.3389/fneur.2021.697923](https://doi.org/10.3389/fneur.2021.697923)
- Eren et al. (2019): photophobia quantification — *Cephalalgia* — [10.1177/0333102419896780](https://doi.org/10.1177/0333102419896780)
- Schankin et al. (2020): structural/functional footprint (parietal hypometabolism) — *Brain* — [10.1093/brain/awaa053](https://doi.org/10.1093/brain/awaa053)
- Martins Silva & Puledda (2023): VSS-migraine review — *Eye* — [10.1038/s41433-023-02435-w](https://doi.org/10.1038/s41433-023-02435-w)
- Ayesha, Riehle, Leishangthem (2025): current diagnostics & management — *Eye Brain* — [10.2147/EB.S418923](https://doi.org/10.2147/EB.S418923)

## Visual Snow Initiative

[visualsnowinitiative.org](https://www.visualsnowinitiative.org/) — nonprofit founded 2018,
funds VSS research in 7 countries, achieved ICD coding for VSS, runs patient support and a
Visual Snow Simulator. Reference their work when updating prevalence data or clinical framing.

## Non-Trivial Details

- **The palinopsia trail is only visible during MOTION.** Rotate the
  camera, look at moving light sources. In static scenes there is no
  trail (this is correct — nothing moved).
- **Static is most visible on flat single-color surfaces.** On detailed
  terrain the grain "disappears" between block structures.
- **Self-light only triggers in deep darkness** (threshold 0.06).
  Daytime test scenes won't show it.
- **Defaults are intentionally minimal.** Profiles activate more.

## What Claude Code Should NOT Do

- Don't enable all effects by default (bug from v0.4)
- Don't introduce `gl_TexCoord` (bug from v0.6)
- Don't declare persistent buffers without `clear.colortexN = false` (bug from v0.7)
- Don't set clinically unrealistic high amplitude defaults
- Never drop the "not a diagnostic instrument" disclaimer

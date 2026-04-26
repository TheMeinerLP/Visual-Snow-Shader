# Visual Snow Shader

My girlfriend [@onelitefeather](https://github.com/onelitefeather) has lived with VSS her
whole life. Back then, the only way to arrive at it was through exclusion — ruling out
everything else until nothing was left. VSS had no official name in the diagnostic system,
so there was nothing to formally diagnose. That changed in 2025 when VSS received its own
ICD-11 code, which means doctors can now actually name it. She wanted to show me what she
sees every day. We needed a simulator. Minecraft with Iris shaders turned out to be the
right fit — accessible, no friction, and you can just hand someone a controller and say
"this is my vision."

That's where this started. A lot of people with VSS still don't know they have it — they
grew up with it and assumed everyone sees this way. If this helps one person realize they're
not imagining things, or helps someone understand what a person close to them experiences
every day — that's the point.

[![Iris Compat](https://img.shields.io/badge/Iris-1.6%2B-blue)](https://irisshaders.dev/)
[![Minecraft](https://img.shields.io/badge/Minecraft-1.19%2B-green)](https://minecraft.net/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey)](LICENSE)

## What is Visual Snow Syndrome?

VSS is a neurological condition where the brain never stops generating visual noise. People
with VSS see a permanent static — like a TV with no signal — overlaid on everything, day and
night, eyes open or closed.

About 2.2 % of the population has it (Puledda et al. 2020). Many have had it since childhood
and assume this is just how everyone sees. They never get diagnosed.

The underlying mechanism is cortical hyperexcitability and thalamocortical dysrhythmia. The
ICHD-3 criteria require the static plus at least 2 of 4 additional symptoms (palinopsia,
enhanced entoptic phenomena, photophobia, nyctalopia) lasting more than 3 months.

## What this shader simulates

Seven symptoms that can be enabled individually:

| Symptom | What it looks like |
|---|---|
| **Static** | constant grain over the whole screen — the core symptom |
| **Palinopsia** | afterimages; moving objects leave a trail |
| **Photophobia** | bright sources bloom and feel overwhelming |
| **Nyctalopia** | night vision degrades faster than it should |
| **Floaters** | drifting translucent shapes in the vitreous |
| **Blue Field Phenomenon** | tiny bright dots moving over uniform blue sky |
| **Self-light** | faint colored phosphene clouds when it's completely dark |

Blue surfaces specifically worsen symptoms — this is documented (Hepschke et al. 2021) and the
shader has a matching aggravation toggle.

## Installation

1. Install [Iris](https://irisshaders.dev/) (or Oculus for Forge)
2. Download the ZIP from [Releases](../../releases)
3. Drop the ZIP into `.minecraft/shaderpacks/`
4. Minecraft → Options → Video Settings → Shader Packs → pick it

## Profiles

The default is intentionally mild — the game should stay playable. Switch profiles in the
Iris settings menu:

- **Minimal** (default) — static and light floaters only
- **Screening** — vertical split-screen: affected left, unaffected right
- **Mild** / **Moderate** / **Severe** — progressive symptom severity
- **Static Only** — static without the other symptoms (~4 % of patients present this way)
- **HPPD** — hallucinogen-persisting variant with colored static

## Screening guide for parents

VSS is often missed in kids because they have nothing to compare against. The Screening
profile can help surface this:

1. Let your child play Minecraft normally for a bit
2. Switch to the **Screening** profile — the screen splits vertically
3. Ask: *"Does one half look different from the other?"*
4. If they say no, or that the static side looks more normal — that's worth following up

> **This is not a diagnostic tool.** A proper VSS diagnosis needs a neuro-ophthalmologist,
> clinical exclusion of other causes, and at least 3 months of persistent symptoms. Use this
> only as a conversation starter, not as a result.

## For Developers

```bash
# Tier 1 — linter, runs in seconds
python3 test/tier1-lint/lint.py shaders/

# Tier 2 — headless Iris test (needs Docker)
docker build -t iris-test test/tier2-integration/
docker run --rm -v "$PWD:/shader-mount:ro" iris-test

# Tier 3 — CI matrix across Iris versions, runs on push
# see .github/workflows/iris-compat.yml
```

Architecture, Iris-specific gotchas, and conventions are in [CLAUDE.md](CLAUDE.md).
PR workflow is in [CONTRIBUTING.md](CONTRIBUTING.md).

## If you have VSS

If this shader looks like your normal vision, you're not alone. A few places to start:

- **[Visual Snow Initiative — Find a Doctor](https://www.visualsnowinitiative.org/find-a-doctor/)**
  — directory of specialists who know VSS and won't dismiss you
- **[VSI Patient Community](https://www.visualsnowinitiative.org/community/)**
  — connect with others who live with it
- **[Visual Snow Initiative](https://www.visualsnowinitiative.org/)** — general info,
  current research, and a contact form if you want to participate in studies

A formal diagnosis goes through a neuro-ophthalmologist. Bring the ICHD-3 criteria
(static + 2 of 4 additional symptoms, 3+ months) if you're not being taken seriously.

## Visual Snow Initiative

The [Visual Snow Initiative](https://www.visualsnowinitiative.org/) is a nonprofit (founded
2018) that funds VSS research and pushes for clinical recognition. They got VSS its own ICD
codes, which matters for diagnosis and insurance. They also run a patient community, a
Find-a-Doctor directory, and a desktop Visual Snow Simulator if you want to try the
perception without playing Minecraft.

If you work in neurology or ophthalmology and want to contribute research, their website
has a submission process.

## Clinical sources

- Schankin C., Maniyar F., Digre K., Goadsby P. (2014). *'Visual snow' – a disorder distinct from persistent migraine aura.* Brain 137(5):1419–1428. [doi:10.1093/brain/awu050](https://doi.org/10.1093/brain/awu050)
- Puledda F., Schankin C., Goadsby P. (2020). *Visual snow syndrome: A clinical and phenotypical description of 1,100 cases.* Neurology 94(6):e564–e574. [doi:10.1212/WNL.0000000000008909](https://doi.org/10.1212/WNL.0000000000008909)
- Hepschke J., Martin P., Fraser C. (2021). *Short-wave sensitive ("blue") cone activation is an aggravating factor for visual snow symptoms.* Front. Neurol. 12:697923. [doi:10.3389/fneur.2021.697923](https://doi.org/10.3389/fneur.2021.697923)
- Eren O., Ruscheweyh R., Straube A., Schankin C. (2019). *Quantification of photophobia in visual snow syndrome: A case-control study.* Cephalalgia 40(4):393–398. [doi:10.1177/0333102419896780](https://doi.org/10.1177/0333102419896780)
- Schankin C., Maniyar F., Chou D., Eller M., Sprenger T. (2020). *Structural and functional footprint of visual snow syndrome.* Brain 143(4):1106–1113. [doi:10.1093/brain/awaa053](https://doi.org/10.1093/brain/awaa053)
- Martins Silva E., Puledda F. (2023). *Visual snow syndrome and migraine: a review.* Eye 37(12):2374–2378. [doi:10.1038/s41433-023-02435-w](https://doi.org/10.1038/s41433-023-02435-w)
- Ayesha A., Riehle C., Leishangthem L. (2025). *Diagnostic and management strategies of visual snow syndrome: Current perspectives.* Eye Brain 17:1–11. [doi:10.2147/EB.S418923](https://doi.org/10.2147/EB.S418923)

## Built with AI

Neither of us has a background in GLSL or shader development. We built this entirely with
AI assistance — we provided the direction, the clinical research, and the reason it exists.
The AI wrote the shader code. We're mentioning this openly because we think it's honest,
and because it might encourage others who have something meaningful to build but don't have
the technical background to just start anyway.

## License

[MIT](LICENSE)

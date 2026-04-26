# Visual Snow Shader

An Iris shader pack for Minecraft that simulates the visual symptoms of
**Visual Snow Syndrome (VSS)** — as an awareness tool for empathy and
as a screening aid for parents.

[![Iris Compat](https://img.shields.io/badge/Iris-1.6%2B-blue)](https://irisshaders.dev/)
[![Minecraft](https://img.shields.io/badge/Minecraft-1.19%2B-green)](https://minecraft.net/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey)](LICENSE)

## What is Visual Snow Syndrome?

VSS is a neurological disorder involving cortical hyperexcitability and
thalamocortical dysrhythmia. Affected individuals see a constant
flickering grain across their entire visual field — like the noise of a
poorly tuned analog TV set.

- **Prevalence:** ~2.2 % of the population (UK study, Puledda 2020)
- **Onset:** often in childhood or early adolescence
- **Diagnosis:** ICHD-3 criteria — static plus 2 of 4 additional symptoms

Because many people with VSS have lived with it since birth, they often
assume it is normal vision and never get diagnosed.

## What does this shader simulate?

Seven clinically documented symptoms, individually toggleable:

| Symptom | Description |
|---|---|
| **Static** (core symptom) | flickering grain across the whole image |
| **Palinopsia** | afterimages, trailing of moving objects |
| **Photophobia** | light sensitivity, bloom around bright sources |
| **Nyctalopia** | impaired night vision |
| **Floaters** | drifting vitreous opacities |
| **Blue Field Phenomenon** | dots over uniform blue surfaces |
| **Self-light** | colored clouds in deep darkness |

Plus the **blue light aggravation trigger** per Hepschke et al. (2021).

## Installation

1. Install [Iris](https://irisshaders.dev/) (or Oculus for Forge)
2. Download the ZIP from [Releases](../../releases)
3. Place the ZIP in `.minecraft/shaderpacks/`
4. In Minecraft: Options → Video Settings → Shader Packs → select it

## Profiles

Defaults are intentionally **minimal** so the game stays fully playable.
Switch directly in the Iris settings menu:

- **Minimal** (default) — only static + light floaters
- **Screening** — split-screen comparison for testing children
- **Mild** / **Moderate** / **Severe** — progressive phenotypes
- **Static Only** — visual snow without the syndrome (~4 % of patients)
- **HPPD** — hallucinogen-persisting variant with colored static

## Screening Guide for Parents

If you suspect your child has VSS but doesn't realize their own
perception is atypical:

1. Have your child play Minecraft normally
2. Activate the **Screening** profile — the screen splits vertically
3. Ask: *"Does one half look different from the other?"*
4. If the child answers "no" or finds the effect side "more normal" —
   this is a possible indicator of VSS

> **Not a medical diagnostic instrument.** If you suspect VSS, please
> consult a neuro-ophthalmologist. The ICHD-3 diagnosis requires more
> than 3 months of persistent symptoms, at least 2 of 4 additional
> symptoms, plus clinical evaluation excluding other causes.

## For Developers

3-tier test pipeline:

```bash
# Tier 1 — Static linter (seconds)
python3 test/tier1-lint/lint.py shaders/

# Tier 2 — Headless Iris integration (local, Docker)
docker build -t iris-test test/tier2-integration/
docker run --rm -v "$PWD:/shader-mount:ro" iris-test

# Tier 3 — CI matrix across multiple Iris versions
# runs automatically via .github/workflows/iris-compat.yml
```

See [CLAUDE.md](CLAUDE.md) for architecture, Iris gotchas, and code
conventions; [CONTRIBUTING.md](CONTRIBUTING.md) for the PR workflow.

## Clinical Sources

- Schankin C. et al. (2014). *Visual snow — A new disease entity distinct from migraine aura.* Brain.
- Puledda F., Schankin C., Goadsby P. (2020). *Visual snow syndrome — A clinical and phenotypical description of 1,100 cases.* Neurology.
- Hepschke J. et al. (2021). *Short-wave sensitive ("blue") cone activation is an aggravating factor for visual snow symptoms.* Front. Neurol.
- Eren O. et al. (2019). *Quantification of photophobia in visual snow syndrome.*
- Martins Silva E., Puledda F. (2023). *Visual snow syndrome and migraine — A review.* Eye.
- Ayesha A. et al. (2025). *Diagnostic and management strategies of visual snow syndrome.* Eye Brain.

## License

[MIT](LICENSE) — free to use, modify, and redistribute.

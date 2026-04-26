# Contributing

Thanks for your interest! Here's everything you need to contribute
effectively.

## Code of Conduct

Be respectful. This project deals with a neurological condition —
contributions that ridicule or trivialize people with VSS will be
rejected.

## Local Setup

```bash
git clone https://github.com/OneLiteFeather/visual-snow-shader.git
cd visual-snow-shader

# Run the Tier-1 linter (before every commit)
sudo apt install glslang-tools python3   # Ubuntu/Debian
brew install glslang                      # macOS
python3 test/tier1-lint/lint.py shaders/

# Test locally in Minecraft
zip -r vss.zip shaders/
cp vss.zip ~/.minecraft/shaderpacks/
# In MC: Options → Video → Shader Packs → vss.zip
```

## Branching

- `main` — stable, releases are tagged from here
- Feature branches: `feature/<short-name>` — e.g. `feature/oscillopsia`
- Bug fixes: `fix/<short-name>` — e.g. `fix/palinopsia-clear-flag`

## Commit Style

[Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): short description

Optional body with more context.

Refs: #issue-number
```

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`

Examples:
```
fix(palinopsia): clear.colortex2=false for frame persistence
feat(symptom): oscillopsia effect for migraine comorbidity
docs(readme): clarify screening guide
```

## PR Checklist

Before submitting:

- [ ] `python3 test/tier1-lint/lint.py shaders/` reports 0 errors
- [ ] Tested locally in at least one Iris version
- [ ] For new sliders: labels added to BOTH `lang/de_de.lang` AND `lang/en_us.lang`
- [ ] For new effects: clinical source listed in PR description
- [ ] Commit messages follow Conventional Commits (release-please reads them)
- [ ] For breaking changes: use `feat!:` or add `BREAKING CHANGE:` in commit footer

CI must be green before merge (`lint` job at minimum, `iris-matrix`
optional depending on the change).

## Adding a New Symptom

1. Find a clinical source (PubMed, peer-reviewed)
2. `shaders/lib/<symptom>.glsl` with `vec3 apply<n>(vec3 color, vec2 uv)`
3. `shaders/lib/config.glsl`: add `ENABLE_<n>` plus parameters
4. `shaders/lib/info.glsl`: tooltip anchor
5. `shaders/final.fsh`: include + conditional call
6. `shaders/shaders.properties`: slider, screen, profile updates
7. `shaders/lang/*.lang`: labels in all existing languages
8. CHANGELOG entry citing the source

See [CLAUDE.md](CLAUDE.md) for full architecture documentation.

## Translations

Adding a new language:

1. Copy `shaders/lang/en_us.lang` to `shaders/lang/<lang>.lang`
2. Translate all `option.*` and `screen.*` values
3. Translate the longer `comment.option.*` tooltips
4. Leave study citations in their original form (e.g. "Puledda et al., 2020")
5. Open a PR with the `i18n` label

Iris auto-detects `<lang>.lang` files matching the Minecraft locale
code (e.g. `fr_fr.lang`, `es_es.lang`, `pt_br.lang`).

## If You Don't Code

Also valuable:

- **Verify clinical accuracy** — open issues if you, as someone with
  VSS or a clinician, find defaults or effect descriptions unrealistic
- **Translations without code** — just write the translation in an issue
- **Spread awareness** — link the pack in relevant communities
- **Donate to research** — e.g. [Visual Snow Initiative](https://visualsnowinitiative.org/)

## License Note

By contributing, you agree to license your contribution under MIT
(see [LICENSE](LICENSE)).

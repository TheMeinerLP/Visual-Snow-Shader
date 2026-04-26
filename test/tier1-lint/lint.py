#!/usr/bin/env python3
"""
lint.py — Static Iris shader linter.

Checks for:
  1. GLSL syntax errors (via glslangValidator)
  2. Known Iris anti-patterns that crash at runtime in specific versions
  3. Completeness of recommended programs
  4. shaders.properties consistency with lang files

Exit code 0 = OK, non-zero = errors present.

Usage:
    ./lint.py /path/to/shaderpack
"""

from __future__ import annotations
import argparse
import os
import re
import subprocess
import sys
from pathlib import Path
from dataclasses import dataclass
from typing import Iterable


# Known anti-patterns that break at runtime in modern Iris but are not
# caught by glslangValidator alone.
ANTI_PATTERNS = [
    (
        r'\bgl_TexCoord\s*\[',
        'gl_TexCoord is not reliably forwarded by the Iris patcher in '
        '1.17+. Use explicit out/in vec2 varyings instead.',
    ),
    (
        r'\buniform\s+sampler2D\s+texture\s*;',
        'Uniform "texture" collides with the GLSL builtin texture() '
        'function. Rename to "gtexture" (Iris convention).',
    ),
    (
        r'\btexture2D\s*\(',
        'texture2D() is deprecated in #version 330+. Use texture().',
    ),
    (
        r'\bgl_FragData\s*\[',
        'gl_FragData[] still works, but layout(location=N) out vec4 is '
        'the modern form and makes the RENDERTARGETS mapping explicit.',
    ),
]


# Recommended programs per Iris fallback chain for vanilla world rendering.
REQUIRED_GBUFFERS = [
    ('gbuffers_basic',         'lines, outline, debug chunks (fallback anchor)'),
    ('gbuffers_textured',      'clouds, sun/moon, beacon, glint'),
    ('gbuffers_textured_lit',  'terrain, entities, hand, weather (critical!)'),
    ('gbuffers_skybasic',      'sky color, stars, void'),
]


@dataclass
class LintResult:
    file: Path
    line: int
    severity: str   # 'error' | 'warning' | 'info'
    message: str

    def fmt(self, root: Path) -> str:
        rel = self.file.relative_to(root) if self.file.is_relative_to(root) else self.file
        color = {'error': '\033[31m', 'warning': '\033[33m', 'info': '\033[36m'}[self.severity]
        reset = '\033[0m'
        return f'{color}{self.severity:7s}{reset}  {rel}:{self.line}: {self.message}'


def find_shader_files(shader_root: Path) -> Iterable[Path]:
    for ext in ('vsh', 'fsh', 'gsh', 'tcs', 'tes', 'csh', 'glsl'):
        yield from shader_root.rglob(f'*.{ext}')


def check_anti_patterns(path: Path) -> list[LintResult]:
    out = []
    try:
        text = path.read_text(encoding='utf-8', errors='replace')
    except Exception as e:
        return [LintResult(path, 0, 'error', f'Could not read file: {e}')]

    for line_no, line in enumerate(text.splitlines(), start=1):
        # Skip pure comment lines
        stripped = line.strip()
        if stripped.startswith('//') or stripped.startswith('/*') or not stripped:
            continue

        for pattern, msg in ANTI_PATTERNS:
            if re.search(pattern, line):
                out.append(LintResult(path, line_no, 'error', msg))
    return out


def check_glslang(path: Path, glslang: str) -> list[LintResult]:
    """Compile test via glslangValidator. Resolves #include manually."""
    if path.suffix == '.glsl':
        return []  # lib files are validated via includes

    stage_map = {'vsh': 'vert', 'fsh': 'frag', 'gsh': 'geom',
                 'tcs': 'tesc', 'tes': 'tese', 'csh': 'comp'}
    stage = stage_map.get(path.suffix.lstrip('.'))
    if not stage:
        return []

    # Resolve includes
    base = path.parent
    while base.name != 'shaders' and base.parent != base:
        base = base.parent
    if base.name != 'shaders':
        base = path.parent

    def inline(p: Path, seen: set | None = None) -> str:
        if seen is None:
            seen = set()
        if p in seen:
            return ''
        seen.add(p)
        text = p.read_text(encoding='utf-8', errors='replace')
        def repl(m):
            inc = m.group(1).lstrip('/')
            return inline(base / inc, seen)
        return re.sub(r'#include\s+"([^"]+)"', repl, text)

    inlined = inline(path)
    tmp = Path('/tmp/_lint_inlined.' + stage)
    tmp.write_text(inlined)

    try:
        proc = subprocess.run(
            [glslang, '-S', stage, str(tmp)],
            capture_output=True, text=True, timeout=10,
        )
    except FileNotFoundError:
        return [LintResult(path, 0, 'warning',
                          f'glslangValidator not found ({glslang}). Skipping syntax check.')]
    except subprocess.TimeoutExpired:
        return [LintResult(path, 0, 'error', 'glslangValidator timeout')]

    if proc.returncode == 0:
        return []

    out = []
    for line in (proc.stdout + proc.stderr).splitlines():
        if 'ERROR:' in line or 'error:' in line:
            m = re.search(r'(\d+)\s*[:(]\s*(\d+)', line)
            line_no = int(m.group(2)) if m else 0
            out.append(LintResult(path, line_no, 'error', f'glsl: {line.strip()}'))
    if not out:
        out.append(LintResult(path, 0, 'error', f'glslangValidator failed: {proc.stderr[:200]}'))
    return out


def check_required_gbuffers(shader_root: Path) -> list[LintResult]:
    results = []
    for name, desc in REQUIRED_GBUFFERS:
        vsh = shader_root / f'{name}.vsh'
        fsh = shader_root / f'{name}.fsh'
        if not vsh.exists() or not fsh.exists():
            results.append(LintResult(
                shader_root, 0, 'warning',
                f'Recommended pass-through missing: {name}.vsh/.fsh ({desc}). '
                f'Risk: Iris may fail to render vanilla geometry.'
            ))
    return results


def check_lang_consistency(shader_root: Path) -> list[LintResult]:
    """Check that every option referenced in shaders.properties has
    labels in the lang files."""
    results = []
    props = shader_root / 'shaders.properties'
    if not props.exists():
        return [LintResult(shader_root, 0, 'error',
                          'shaders.properties is missing')]

    props_text = props.read_text()
    # Extract option names from the sliders directive
    options_referenced = set()
    for m in re.finditer(r'sliders\s*=\s*((?:[A-Z_]+\s*\\?\s*)+)', props_text):
        for opt in m.group(1).split():
            opt = opt.strip().rstrip('\\').strip()
            if opt:
                options_referenced.add(opt)

    lang_dir = shader_root / 'lang'
    if not lang_dir.exists():
        return [LintResult(shader_root, 0, 'info',
                          'No lang/ directory — options will only show with '
                          'their technical names in the Iris menu.')]

    for lang_file in lang_dir.glob('*.lang'):
        text = lang_file.read_text()
        defined = set()
        for m in re.finditer(r'^option\.([A-Za-z0-9_]+)\s*=', text, re.MULTILINE):
            defined.add(m.group(1))

        for opt in options_referenced:
            if opt not in defined and not opt.startswith('info_'):
                results.append(LintResult(
                    lang_file, 0, 'warning',
                    f'Option "{opt}" is used as a slider in shaders.properties '
                    f'but has no label in {lang_file.name}'
                ))

    return results


def check_properties_syntax(shader_root: Path) -> list[LintResult]:
    """Sanity check for shaders.properties format."""
    props = shader_root / 'shaders.properties'
    if not props.exists():
        return []

    results = []
    text = props.read_text()

    # Curly braces inside profile= definitions are a common copy-paste
    # mistake from other property formats.
    for line_no, line in enumerate(text.splitlines(), start=1):
        if '{' in line or '}' in line:
            results.append(LintResult(
                props, line_no, 'error',
                'Curly braces have no meaning in shaders.properties'
            ))

    # colortexNFormat must use a valid format
    valid_formats = {'R8', 'R16', 'R16F', 'R32F', 'RG8', 'RG16', 'RG16F',
                     'RG32F', 'RGB8', 'RGB16', 'RGB16F', 'RGB32F',
                     'RGBA8', 'RGBA16', 'RGBA16F', 'RGBA32F'}
    for m in re.finditer(r'colortex(\d+)Format\s*=\s*(\S+)', text):
        idx, fmt = m.group(1), m.group(2)
        if fmt not in valid_formats:
            results.append(LintResult(
                props, 0, 'warning',
                f'colortex{idx}Format = {fmt} is possibly not a valid format'
            ))

    return results


def main() -> int:
    parser = argparse.ArgumentParser(description='Iris shader linter')
    parser.add_argument('shaderpack', type=Path,
                       help='Path to the shader pack directory (containing shaders/)')
    parser.add_argument('--glslang', default='glslangValidator',
                       help='Path to glslangValidator')
    parser.add_argument('--no-glslang', action='store_true',
                       help='Skip the glslangValidator check')
    args = parser.parse_args()

    shader_root = args.shaderpack
    if (shader_root / 'shaders').is_dir():
        shader_root = shader_root / 'shaders'

    if not shader_root.is_dir():
        print(f'ERROR: {shader_root} is not a directory', file=sys.stderr)
        return 2

    print(f'═══ Iris Shader Linter — {shader_root} ═══')

    all_results: list[LintResult] = []

    # 1. Anti-patterns
    print('\n▸ Checking anti-patterns…')
    for path in find_shader_files(shader_root):
        all_results.extend(check_anti_patterns(path))

    # 2. GLSL syntax
    if not args.no_glslang:
        print('▸ Checking GLSL syntax…')
        for path in find_shader_files(shader_root):
            all_results.extend(check_glslang(path, args.glslang))

    # 3. Required gbuffers
    print('▸ Checking required gbuffers…')
    all_results.extend(check_required_gbuffers(shader_root))

    # 4. Lang consistency
    print('▸ Checking lang consistency…')
    all_results.extend(check_lang_consistency(shader_root))

    # 5. Properties syntax
    print('▸ Checking shaders.properties…')
    all_results.extend(check_properties_syntax(shader_root))

    # Report
    print()
    errors   = [r for r in all_results if r.severity == 'error']
    warnings = [r for r in all_results if r.severity == 'warning']
    infos    = [r for r in all_results if r.severity == 'info']

    for r in all_results:
        print(r.fmt(shader_root))

    print()
    print(f'═══ Result: {len(errors)} errors, {len(warnings)} warnings, {len(infos)} infos ═══')

    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main())

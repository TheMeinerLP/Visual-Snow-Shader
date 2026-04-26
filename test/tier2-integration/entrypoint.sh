#!/usr/bin/env bash
# Tier-2 GLSL validation
# Preprocesses #include directives inline, strips shim uniforms that the
# shader already declares itself (avoiding redefinition errors), then
# validates each .vsh/.fsh with glslangValidator.
set -euo pipefail

SHADER_DIR="${1:-/shader-mount/shaders}"
SHIM="/opt/shader-test/iris-shim.glsl"
PASS=0
FAIL=0
ERRORS=""

preprocess() {
    # Inlines #include "/lib/..." and removes shim uniforms already declared
    # in the shader to avoid redefinition errors.
    python3 - "$1" "$SHADER_DIR" "$SHIM" <<'PY'
import sys, re, os

def inline_includes(text, root, depth=0):
    if depth > 20:
        return text
    def sub(m):
        rel = m.group(1).lstrip('/')
        path = os.path.join(root, rel)
        try:
            return inline_includes(open(path).read(), root, depth + 1)
        except FileNotFoundError:
            return f"// [shim] include not found: {path}"
    return re.sub(r'^\s*#include\s+"([^"]+)"', sub, text, flags=re.MULTILINE)

shader_file, shader_root, shim_file = sys.argv[1], sys.argv[2], sys.argv[3]

src = open(shader_file).read()
src = re.sub(r'^#version[^\n]*\n', '', src, flags=re.MULTILINE)
src_inlined = inline_includes(src, shader_root)

# Names of uniforms the shader already declares
declared = set(re.findall(r'uniform\s+\S+\s+(\w+)\s*;', src_inlined))

# Filter shim: drop any uniform line whose name is already in the shader
filtered = []
for line in open(shim_file):
    m = re.match(r'\s*uniform\s+\S+\s+(\w+)\s*;', line)
    if m and m.group(1) in declared:
        continue
    filtered.append(line)

sys.stdout.write(''.join(filtered))
sys.stdout.write(src_inlined)
PY
}

validate() {
    local file="$1"
    local stage="$2"
    local tmp
    tmp=$(mktemp /tmp/shader-XXXXXX.glsl)

    {
        echo "#version 330 compatibility"
        [[ "$stage" == "vert" ]] && echo "#define VERTEX_STAGE"
        preprocess "$file"
    } > "$tmp"

    local out
    if out=$(glslangValidator -S "$stage" "$tmp" 2>&1); then
        PASS=$((PASS + 1))
    else
        FAIL=$((FAIL + 1))
        ERRORS+=$'\n'"[FAIL] $(basename "$file")"$'\n'"$out"$'\n'
    fi
    rm -f "$tmp"
}

if [[ ! -d "$SHADER_DIR" ]]; then
    echo "FATAL: shader directory not found at $SHADER_DIR"
    exit 2
fi

echo "▸ Validating GLSL in $SHADER_DIR"
echo ""

while IFS= read -r -d '' f; do validate "$f" vert; done \
    < <(find "$SHADER_DIR" -maxdepth 1 -name "*.vsh" -print0)

while IFS= read -r -d '' f; do validate "$f" frag; done \
    < <(find "$SHADER_DIR" -maxdepth 1 -name "*.fsh" -print0)

echo "  passed : $PASS"
echo "  failed : $FAIL"

if [[ $FAIL -gt 0 ]]; then
    echo ""
    echo "═══ GLSL ERRORS ═══"
    echo "$ERRORS"
    exit 1
fi

echo "✓ All shader files validated."
exit 0

#!/usr/bin/env bash
# Tier-2 GLSL validation
# Preprocesses #include directives inline (glslangValidator treats "/lib/foo"
# as an absolute system path, not relative to -I), then validates each
# .vsh/.fsh with glslangValidator after injecting the Iris uniform shim.
set -euo pipefail

SHADER_DIR="${1:-/shader-mount/shaders}"
SHIM="/opt/shader-test/iris-shim.glsl"
PASS=0
FAIL=0
ERRORS=""

preprocess() {
    # Inline all #include "/lib/..." directives relative to SHADER_DIR,
    # strip the file's own #version line.
    python3 - "$1" "$SHADER_DIR" <<'PY'
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

src = open(sys.argv[1]).read()
src = re.sub(r'^#version[^\n]*\n', '', src, flags=re.MULTILINE)
print(inline_includes(src, sys.argv[2]))
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
        cat "$SHIM"
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

#!/usr/bin/env bash
# Tier-2 GLSL validation
# Injects the Iris uniform shim into each .vsh/.fsh and validates with
# glslangValidator. Does not run Minecraft — validates at the GLSL level.
set -euo pipefail

SHADER_DIR="${1:-/shader-mount/shaders}"
SHIM="/opt/shader-test/iris-shim.glsl"
PASS=0
FAIL=0
ERRORS=""

validate() {
    local file="$1"
    local stage="$2"   # vert or frag
    local tmp
    tmp=$(mktemp /tmp/shader-XXXXXX.glsl)

    # Strip existing #version line, prepend shim after our own #version
    echo "#version 330 compatibility" > "$tmp"
    if [[ "$stage" == "vert" ]]; then
        echo "#define VERTEX_STAGE" >> "$tmp"
    fi
    cat "$SHIM" >> "$tmp"
    grep -v '^#version' "$file" >> "$tmp"

    local out
    if out=$(glslangValidator --stdin -S "$stage" < "$tmp" 2>&1); then
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

while IFS= read -r -d '' f; do
    validate "$f" vert
done < <(find "$SHADER_DIR" -name "*.vsh" -print0)

while IFS= read -r -d '' f; do
    validate "$f" frag
done < <(find "$SHADER_DIR" -name "*.fsh" -print0)

echo "  passed : $PASS"
echo "  failed : $FAIL"

if [[ $FAIL -gt 0 ]]; then
    echo ""
    echo "═══ GLSL ERRORS ═══"
    echo "$ERRORS"
    exit 1
fi

echo ""
echo "✓ All shader files validated."
exit 0

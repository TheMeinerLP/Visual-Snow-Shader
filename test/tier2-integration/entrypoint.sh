#!/usr/bin/env bash
# =====================================================
#  entrypoint.sh
#  Starts MC headless with Iris, loads the mounted shader pack,
#  and parses latest.log for compile errors.
# =====================================================
set -euo pipefail

SHADER_NAME="${SHADER_NAME:-shader-under-test}"
TEST_DURATION="${TEST_DURATION:-30}"  # seconds

LOG_DIR=/opt/mctest/logs
mkdir -p "${LOG_DIR}" /opt/mctest/shaderpacks

# Expects: shader to be mounted at /shader-mount
if [[ ! -d /shader-mount ]]; then
    echo "FATAL: no shader mounted at /shader-mount"
    exit 2
fi

# Copy the pack as a ZIP into shaderpacks
echo "▸ Packing shader to shaderpacks/${SHADER_NAME}.zip"
cd /shader-mount
zip -qr "/opt/mctest/shaderpacks/${SHADER_NAME}.zip" shaders/
cd /opt/mctest

# Force the shader pack via iris.properties
mkdir -p /opt/mctest/mc/config
cat > /opt/mctest/mc/config/iris.properties <<EOF
shaderPack=${SHADER_NAME}.zip
enableShaders=true
EOF

# Start Xvfb
echo "▸ Starting Xvfb (1280x720x24)"
Xvfb :99 -screen 0 1280x720x24 +extension GLX +render -noreset &
XVFB_PID=$!
sleep 2

# OpenGL sanity check
echo "▸ OpenGL renderer:"
glxinfo 2>/dev/null | grep -E "OpenGL (vendor|renderer|version)" || echo "  (glxinfo unavailable)"

# Launch Minecraft — option A: Fabric installer client mode
# Note: a full client boot requires MC auth. For CI, use either an
# offline trick via authlib-injector or a Fabric server build that
# triggers only the mod-init path and then exits.
#
# In practice, we recommend writing a small Fabric mod that on the
# CLIENT_STARTED event triggers Iris.getInstance().reloadShader() and
# then calls System.exit(). Mount that mod here.
#
# Fallback: vanilla launcher with an MS auth token from ENV.

if [[ -z "${MC_OFFLINE_NAME:-}" ]] && [[ -z "${MC_AUTH_TOKEN:-}" ]]; then
    echo "▸ No auth — using OFFLINE_NAME=TestBot mode"
    export MC_OFFLINE_NAME="TestBot"
fi

echo "▸ Starting Minecraft (${TEST_DURATION}s boot window)…"
# The concrete launch command line goes here. Bootstrap differs per
# MC version, so this is a placeholder that must be replaced by a
# concrete mc-launch script.
timeout "${TEST_DURATION}" java \
    -Djava.library.path=/opt/mctest/mc/natives \
    -cp "/opt/mctest/mc/libraries/*:/opt/mctest/mc/versions/*/client.jar" \
    -Xmx2G \
    net.fabricmc.loader.impl.launch.knot.KnotClient \
    --gameDir /opt/mctest/mc \
    --assetsDir /opt/mctest/mc/assets \
    --version "fabric-loader-${MC_VERSION:-unknown}" \
    --username "${MC_OFFLINE_NAME:-TestBot}" \
    --uuid "00000000-0000-0000-0000-000000000000" \
    --accessToken "0" \
    --userType offline \
    > "${LOG_DIR}/mc-stdout.log" 2> "${LOG_DIR}/mc-stderr.log" || true

# Iris log parsing
LATEST_LOG="/opt/mctest/mc/logs/latest.log"
if [[ ! -f "${LATEST_LOG}" ]]; then
    echo "WARN: latest.log not found — falling back to stdout"
    LATEST_LOG="${LOG_DIR}/mc-stdout.log"
fi

cp "${LATEST_LOG}" "${LOG_DIR}/" 2>/dev/null || true

# Extract error patterns
echo "▸ Parsing log for shader errors…"
ERRORS=$(grep -E "(Failed to compile|Shader compilation failed|GLSL.*error|undeclared|Failed to load shader)" \
    "${LATEST_LOG}" 2>/dev/null || true)

if [[ -n "${ERRORS}" ]]; then
    echo "═══ SHADER ERRORS ═══"
    echo "${ERRORS}" | tee "${LOG_DIR}/shader-errors.txt"
    kill ${XVFB_PID} 2>/dev/null || true
    exit 1
fi

echo "✓ No shader compile errors in the log."
kill ${XVFB_PID} 2>/dev/null || true
exit 0

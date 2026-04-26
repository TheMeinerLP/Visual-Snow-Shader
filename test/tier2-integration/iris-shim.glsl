// Iris uniform shim — injected before each shader file during validation.
// Covers the uniforms and varyings that Iris injects at runtime so
// glslangValidator can resolve all symbols without a live Minecraft instance.

// ── Time ────────────────────────────────────────────────────────────────────
uniform float frameTime;
uniform float frameTimeCounter;
uniform int   frameCounter;

// ── Screen / projection ─────────────────────────────────────────────────────
uniform vec2  viewSize;
uniform vec2  texelSize;
uniform mat4  gbufferProjection;
uniform mat4  gbufferProjectionInverse;
uniform mat4  gbufferModelView;
uniform mat4  gbufferModelViewInverse;
uniform mat4  gbufferPreviousProjection;
uniform mat4  gbufferPreviousModelView;

// ── Camera ───────────────────────────────────────────────────────────────────
uniform vec3  cameraPosition;
uniform vec3  previousCameraPosition;
uniform float eyeAltitude;
uniform int   isEyeInWater;
uniform ivec2 eyeBrightnessSmooth;
uniform ivec2 eyeBrightness;

// ── World ────────────────────────────────────────────────────────────────────
uniform float sunAngle;
uniform float rainStrength;
uniform float wetness;
uniform int   worldTime;
uniform int   worldDay;
uniform int   moonPhase;

// ── Textures (colortex0–7, depth, noise) ────────────────────────────────────
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;
uniform sampler2D noisetex;
uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform sampler2D gaux1;

// ── Per-fragment inputs (composite / final) ──────────────────────────────────
in vec2 texcoord;

// ── Per-vertex outputs (vertex shaders) ──────────────────────────────────────
#ifdef VERTEX_STAGE
out vec2 texcoord;
#endif

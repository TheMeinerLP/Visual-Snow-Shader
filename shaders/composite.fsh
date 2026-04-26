#version 330 compatibility

/*
 * composite.fsh — Pass 1 (palinopsia accumulation)
 *
 * Writes ONLY to colortex2 (trail buffer), no longer to colortex0.
 * This keeps the gbuffer rendering of the world fully untouched
 * for final.fsh.
 */

#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/palinopsia.glsl"

in vec2 texcoord;

/* RENDERTARGETS: 2 */
layout(location = 0) out vec4 trailColor;

void main() {
#if ENABLE_PALINOPSIA == 1
    vec3 current  = texture(colortex0, texcoord).rgb;
    vec3 previous = texture(colortex2, texcoord).rgb;
    trailColor = vec4(accumulatePalinopsia(current, previous), 1.0);
#else
    trailColor = vec4(0.0);
#endif
}

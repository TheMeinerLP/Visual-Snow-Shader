#version 330 compatibility

/*
 * final.fsh — Pass 2
 *
 * All apply-functions are always invoked. Internal early-returns on
 * STRENGTH<=0 ensure that disabled effects cost nothing and produce
 * no output.
 */

#include "/lib/config.glsl"
#include "/lib/common.glsl"
#include "/lib/photophobia.glsl"
#include "/lib/nyktalopia.glsl"
#include "/lib/palinopsia.glsl"
#include "/lib/self_light.glsl"
#include "/lib/blue_field.glsl"
#include "/lib/floaters.glsl"
#include "/lib/static.glsl"
#include "/lib/info.glsl"

in vec2 texcoord;
out vec4 fragColor;

void main() {
    vec3 original = texture(colortex0, texcoord).rgb;

    vec3 processed = original;
    processed = applyPhotophobia(processed, texcoord);
    processed = applyNyktalopia(processed);
    processed = applyPalinopsia(processed, texcoord);
    processed = applySelfLight(processed, texcoord);
    processed = applyBlueField(processed, texcoord);
    processed = applyFloaters(processed, texcoord);
    processed = applyStatic(processed, texcoord);

    vec3 result = mix(original, processed, GLOBAL_INTENSITY);

#if COMPARISON_MODE == 1
    {
        if (texcoord.x < 0.5) result = original;
        float lineDist = abs(texcoord.x - 0.5) * viewWidth;
        if (lineDist < 1.0) result = vec3(1.0, 0.7, 0.0);
    }
#elif COMPARISON_MODE == 2
    {
        if (texcoord.y < 0.5) result = original;
        float lineDist = abs(texcoord.y - 0.5) * viewHeight;
        if (lineDist < 1.0) result = vec3(1.0, 0.7, 0.0);
    }
#elif COMPARISON_MODE == 3
    {
        float phase = mod(frameTimeCounter, 6.0);
        if (phase < 3.0) result = original;
        vec2 indPos = vec2(0.97, 0.95);
        float aspect = viewWidth / viewHeight;
        vec2 d = (texcoord - indPos) * vec2(aspect, 1.0);
        if (length(d) < 0.008) {
            result = (phase < 3.0) ? vec3(0.2, 0.9, 0.2) : vec3(0.9, 0.2, 0.2);
        }
    }
#endif

    fragColor = vec4(result, 1.0);
}

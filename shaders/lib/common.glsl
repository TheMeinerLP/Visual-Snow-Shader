#ifndef LIB_COMMON_GLSL
#define LIB_COMMON_GLSL

/*
 * lib/common.glsl
 * Shared uniforms, hash functions, and helpers.
 * Included via #include into every effect module.
 */

uniform sampler2D colortex0;
uniform sampler2D colortex2;

uniform float viewWidth;
uniform float viewHeight;
uniform float frameTimeCounter;
uniform int   frameCounter;

float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float hash21(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

vec2 hash22(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx + p3.yz) * p3.zy);
}

float luminance(vec3 c) {
    return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

#endif

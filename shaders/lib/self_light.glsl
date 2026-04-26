#ifndef LIB_SELF_LIGHT_GLSL
#define LIB_SELF_LIGHT_GLSL

vec3 selfLight(vec2 uv, float sceneBrightness) {
    float darkMask = 1.0 - smoothstep(0.0, SELF_LIGHT_THRESHOLD, sceneBrightness);
    if (darkMask < 0.001) return vec3(0.0);

    float t = frameTimeCounter * SELF_LIGHT_SPEED;
    vec2 p = uv * SELF_LIGHT_SCALE + vec2(t, t * 0.7);

    float n1 = hash21(floor(p))               - 0.5;
    float n2 = hash21(floor(p * 2.3 + 17.3))  - 0.5;
    float n3 = hash21(floor(p * 5.1 + 31.7))  - 0.5;
    float n  = n1 * 0.5 + n2 * 0.3 + n3 * 0.2;

    vec3 col = vec3(
        0.5 + 0.5 * sin(t * 0.31 + n * 6.0),
        0.5 + 0.5 * sin(t * 0.41 + n * 6.0 + 2.1),
        0.5 + 0.5 * sin(t * 0.27 + n * 6.0 + 4.2)
    );
    return col * darkMask;
}

vec3 applySelfLight(vec3 color, vec2 uv) {
    if (SELF_LIGHT_STRENGTH <= 0.0) return color;

    float bright = luminance(color);
    vec3 sl = selfLight(uv, bright);
    float effStrength = SELF_LIGHT_BRIGHTNESS * SELF_LIGHT_STRENGTH;
    return color + sl * effStrength;
}

#endif

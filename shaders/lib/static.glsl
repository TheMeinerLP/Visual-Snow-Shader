#ifndef LIB_STATIC_GLSL
#define LIB_STATIC_GLSL

/*
 * lib/static.glsl
 * Visual snow static — the core symptom.
 * STATIC_STRENGTH (0..1) is the single master slider.
 * At STRENGTH=0 the original is returned unchanged.
 */

float staticChannel(vec2 grain, float salt) {
    float t = float(frameCounter & 4095) * 0.013 * STATIC_FLICKER;
    return hash21(grain + vec2(t * 91.7 + salt, t * 73.3 - salt));
}

float applyDensity(float n, float density) {
    float signed = n * 2.0 - 1.0;
    float deadZone = 1.0 - density;
    float a = abs(signed);
    if (a < deadZone) return 0.0;
    return sign(signed) * (a - deadZone) / max(0.001, density);
}

vec3 sampleStatic(vec2 uv) {
    vec2 res = vec2(viewWidth, viewHeight);
    vec2 grain = floor(uv * res / max(0.5, STATIC_GRAIN_SIZE));

#if STATIC_COLORED == 1
    vec3 raw = vec3(
        staticChannel(grain, 0.0),
        staticChannel(grain, 17.3),
        staticChannel(grain, 31.7)
    );
    return vec3(
        applyDensity(raw.r, STATIC_DENSITY),
        applyDensity(raw.g, STATIC_DENSITY),
        applyDensity(raw.b, STATIC_DENSITY)
    );
#else
    float raw = staticChannel(grain, 0.0);
    return vec3(applyDensity(raw, STATIC_DENSITY));
#endif
}

vec3 applyStatic(vec3 color, vec2 uv) {
    if (STATIC_STRENGTH <= 0.0) return color;

    vec3 noise = sampleStatic(uv);
    // Effective amplitude = detail value × master strength
    float amp = STATIC_AMPLITUDE * STATIC_STRENGTH;

#if ENABLE_BLUE_AGGRAVATION == 1
    float blueWeight = max(0.0, color.b - max(color.r, color.g) * 0.7);
    amp *= 1.0 + blueWeight * BLUE_AGGRAVATION_STRENGTH;
#endif

#if STATIC_TYPE == 0
    vec3 dir = sign(color - vec3(0.5));
    color += dir * abs(noise) * amp;
#else
    color += noise * amp;
#endif

    return clamp(color, 0.0, 1.5);
}

#endif

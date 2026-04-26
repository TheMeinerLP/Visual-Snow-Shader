#ifndef LIB_FLOATERS_GLSL
#define LIB_FLOATERS_GLSL

float floaterField(vec2 uv) {
    float aspect = viewWidth / viewHeight;
    vec2 auv = uv * vec2(aspect, 1.0);

    float total = 0.0;
    const int LAYERS = 3;

    for (int i = 0; i < LAYERS; i++) {
        float fi = float(i);
        float scale = mix(40.0, 90.0, fi / float(LAYERS - 1));

        vec2 drift = vec2(
            sin(frameTimeCounter * 0.04 * FLOATERS_DRIFT + fi * 1.7) * 0.05,
            cos(frameTimeCounter * 0.03 * FLOATERS_DRIFT + fi * 2.3) * 0.05
                + frameTimeCounter * 0.006 * FLOATERS_DRIFT
        );

        vec2 cell = (auv + drift) * scale;
        vec2 ci = floor(cell);
        vec2 cf = fract(cell) - 0.5;

        float h = hash21(ci + fi * 7.0);
        float threshold = 1.0 - clamp(FLOATERS_COUNT * 0.015, 0.0, 0.5);
        if (h > threshold) {
            float r = (hash21(ci + fi * 13.0) * 0.18 + 0.12) * FLOATERS_SIZE;
            float d = length(cf);
            float blob = smoothstep(r, r * 0.4, d);
            total += blob * mix(1.0, 0.5, fi / float(LAYERS - 1));
        }
    }
    return clamp(total, 0.0, 1.0);
}

vec3 applyFloaters(vec3 color, vec2 uv) {
    if (FLOATERS_STRENGTH <= 0.0) return color;

    float fl = floaterField(uv);
    vec3 floaterColor = color * 0.4;
    // Master × detail opacity
    float effOpacity = FLOATERS_OPACITY * FLOATERS_STRENGTH;
    return mix(color, floaterColor, fl * effOpacity);
}

#endif

#ifndef LIB_BLUE_FIELD_GLSL
#define LIB_BLUE_FIELD_GLSL

float blueFieldDots(vec2 uv, vec3 sceneColor) {
    float blueBias = max(0.0, sceneColor.b - max(sceneColor.r, sceneColor.g));
    float bright   = luminance(sceneColor);
    float skyMask  = smoothstep(0.30, 0.65, bright)
                   * smoothstep(0.02, 0.18, blueBias);
    if (skyMask < 0.001) return 0.0;

    float scale = 350.0;
    vec2 cell = floor(uv * scale);

    float t = frameTimeCounter * BLUE_FIELD_SPEED;
    vec2 jitter = vec2(
        sin(t * 1.3 + cell.x * 0.7),
        cos(t * 1.7 + cell.y * 0.5)
    ) * 0.4;

    float h = hash21(cell + jitter);
    float threshold = 1.0 - BLUE_FIELD_DENSITY * 0.025;
    if (h < threshold) return 0.0;

    vec2 cf = fract(uv * scale) - 0.5;
    float radius = 0.15 * BLUE_FIELD_SIZE;
    float dot_ = smoothstep(radius, radius * 0.4, length(cf));

    return dot_ * skyMask;
}

vec3 applyBlueField(vec3 color, vec2 uv) {
    if (BLUE_FIELD_STRENGTH <= 0.0) return color;

    float dots = blueFieldDots(uv, color);
    vec3 dotColor = vec3(1.0);
    float effOpacity = BLUE_FIELD_BRIGHTNESS * BLUE_FIELD_STRENGTH;
    return mix(color, dotColor, dots * effOpacity);
}

#endif

#ifndef LIB_PHOTOPHOBIA_GLSL
#define LIB_PHOTOPHOBIA_GLSL

vec3 applyPhotophobia(vec3 color, vec2 uv) {
    if (PHOTOPHOBIA_STRENGTH <= 0.0) return color;

    vec2 px = 1.0 / vec2(viewWidth, viewHeight);

    vec3 bloom = vec3(0.0);
    float weight = 0.0;
    const int RADIUS = 2;

    for (int x = -RADIUS; x <= RADIUS; x++) {
        for (int y = -RADIUS; y <= RADIUS; y++) {
            vec2 off = vec2(x, y) * px * PHOTOPHOBIA_RADIUS;
            vec3 s = texture(colortex0, uv + off).rgb;
            float bright = smoothstep(0.55, 1.0, luminance(s));
            float w = exp(-float(x * x + y * y) * 0.3);
            bloom += s * bright * w;
            weight += w;
        }
    }
    bloom /= weight;

    // Effective strength = detail × master
    float effBloom     = PHOTOPHOBIA_BLOOM * PHOTOPHOBIA_STRENGTH;
    float effOvershoot = PHOTOPHOBIA_OVERSHOOT * PHOTOPHOBIA_STRENGTH;

    vec3 bloomed = color + bloom;
    color = mix(color, bloomed, effBloom);

    float lum = luminance(color);
    float overshoot = smoothstep(0.7, 1.5, lum);
    color = mix(color, color * 1.4, overshoot * effOvershoot);

    return color;
}

#endif

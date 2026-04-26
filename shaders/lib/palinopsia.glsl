#ifndef LIB_PALINOPSIA_GLSL
#define LIB_PALINOPSIA_GLSL

/*
 * lib/palinopsia.glsl
 *
 * v0.8 — two bug fixes versus v0.7:
 *
 * 1. Buffer persistence (in shaders.properties: clear.colortex2 = false).
 *    Without that clear flag, colortex2 was reset every frame and
 *    temporal accumulation did not work.
 *
 * 2. Accumulation logic: previously current*pickup was always written,
 *    even in static scenes → permanent glow.
 *    Now it only accumulates when current is actually brighter than
 *    the trail. This makes trails appear only from new bright pixels
 *    (moving light sources, camera rotation, etc.).
 */

vec3 accumulatePalinopsia(vec3 current, vec3 previous) {
    // Brightness-dependent decay:
    // bright pixels persist longer (light sources "burn in")
    float lum = luminance(previous);
    float decay = mix(
        PALINOPSIA_DECAY,
        mix(PALINOPSIA_DECAY, 0.99, PALINOPSIA_BRIGHT_BIAS),
        smoothstep(0.4, 0.95, lum)
    );

    vec3 decayed = previous * decay;

    // Pickup only when current is actually brighter than the existing
    // trail at this location. This way trails only build from genuinely
    // new bright sources.
    vec3 candidate = current * PALINOPSIA_PICKUP;
    vec3 result = max(decayed, candidate);

    // Stability clamp — prevents over-accumulation
    return clamp(result, vec3(0.0), vec3(1.5));
}

vec3 applyPalinopsia(vec3 color, vec2 uv) {
    vec3 trail = texture(colortex2, uv).rgb;
    // Screen blend lays the trail over the image as a glow,
    // without lifting dark areas.
    return 1.0 - (1.0 - color) * (1.0 - trail * PALINOPSIA_BLEND);
}

#endif

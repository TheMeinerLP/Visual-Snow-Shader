#ifndef LIB_NYKTALOPIA_GLSL
#define LIB_NYKTALOPIA_GLSL

vec3 applyNyktalopia(vec3 color) {
    if (NYKTALOPIA_STRENGTH <= 0.0) return color;

    float bright = luminance(color);
    float darkness = 1.0 - smoothstep(0.0, NYKTALOPIA_THRESHOLD, bright);

    float effDesat  = NYKTALOPIA_DESATURATION * NYKTALOPIA_STRENGTH;
    float effDark   = NYKTALOPIA_DARKENING    * NYKTALOPIA_STRENGTH;

    vec3 grey = vec3(bright);
    color = mix(color, grey, darkness * effDesat);
    color *= mix(1.0, 0.55, darkness * effDark);

    return color;
}

#endif

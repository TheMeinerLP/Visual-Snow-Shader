#version 330 compatibility

/*
 * gbuffers_textured.fsh
 * Samples gtexture (renamed from 'texture' to avoid the builtin
 * collision) and writes to colortex0.
 */

in vec2 texcoord;
in vec4 vertexColor;

uniform sampler2D gtexture;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 outColor;

void main() {
    vec4 color = texture(gtexture, texcoord) * vertexColor;
    if (color.a < 0.1) discard;
    outColor = color;
}

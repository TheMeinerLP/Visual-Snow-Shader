#version 330 compatibility

/*
 * gbuffers_textured_lit.fsh
 * Samples the block/entity texture plus the lightmap and writes the
 * lit result to colortex0. The vanilla look is preserved.
 */

in vec2 texcoord;
in vec2 lmcoord;
in vec4 vertexColor;

uniform sampler2D gtexture;
uniform sampler2D lightmap;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 outColor;

void main() {
    vec4 color = texture(gtexture, texcoord) * vertexColor;
    color *= texture(lightmap, lmcoord);
    if (color.a < 0.1) discard;
    outColor = color;
}

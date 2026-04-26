#version 330 compatibility

/*
 * gbuffers_textured_lit.vsh
 * The most important gbuffer program — covers terrain, entities,
 * hand, weather, lit particles.
 */

out vec2 texcoord;
out vec2 lmcoord;
out vec4 vertexColor;

void main() {
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vertexColor = gl_Color;
}

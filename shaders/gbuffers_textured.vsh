#version 330 compatibility

/*
 * gbuffers_textured.vsh
 * Textured unlit geometry (clouds, sun, moon, beacon, glint).
 */

out vec2 texcoord;
out vec4 vertexColor;

void main() {
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    vertexColor = gl_Color;
}

#version 330 compatibility

/*
 * gbuffers_basic.vsh
 * Vertex pass for basic geometry (lines, outline, debug chunks).
 * Modern: explicit out-varyings instead of gl_FrontColor / gl_TexCoord,
 * because the Iris patcher does not reliably forward compatibility-
 * profile state.
 */

out vec4 vertexColor;

void main() {
    gl_Position = ftransform();
    vertexColor = gl_Color;
}

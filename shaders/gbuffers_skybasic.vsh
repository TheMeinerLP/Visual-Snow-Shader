#version 330 compatibility

/*
 * gbuffers_skybasic.vsh
 * Sky color, horizon, stars, void.
 */

out vec4 vertexColor;

void main() {
    gl_Position = ftransform();
    vertexColor = gl_Color;
}

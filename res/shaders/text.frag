#version 300 es

precision mediump float;

in vec2 vTex;
in vec4 vCol;

uniform sampler2D $T;

out vec4 fragColor;

void main() {
  float tex = texture(T, vTex).r;
  fragColor = vec4(tex) * vCol;
}

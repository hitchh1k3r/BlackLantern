#version 300 es

precision mediump float;

in vec2 vTex;
in vec4 vCol;
in float vDepth;

uniform sampler2D $T;

out vec4 fragColor;

void main() {
  float tex = texture(T, vTex).r;
  float distanceDarkening = smoothstep(15., 1.5, vDepth);
  distanceDarkening = .9*distanceDarkening + .1;
  fragColor = vec4(tex) * vec4(vec3(distanceDarkening), 1.) * vCol;
}

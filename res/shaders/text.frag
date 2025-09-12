#version 300 es

precision mediump float;

in vec2 vTex;
in vec4 vCol;
in float vDepth;

uniform sampler2D $T;

out vec4 fragColor;

void main() {
  float tex = texture(T, vTex).r;
  float shadow = texture(T, vTex-vec2(.001,.001)).r;
  float distanceDarkening = smoothstep(50., 1.5, vDepth);
  distanceDarkening = .9*distanceDarkening + .1;
  fragColor = mix(vec4(0., 0., 0., shadow), vec4(1.) * vec4(vec3(distanceDarkening), 1.), tex) * vCol;
}

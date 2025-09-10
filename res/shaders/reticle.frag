#version 300 es

precision mediump float;

in vec2 vTex;

layout(std140) uniform $U {
  mat4 proj;    //  64
  mat4 view;    //  64
  mat4 invVP;   //  64
  vec4 reticle; //  16
  vec4 l1_d;    //  16
  vec4 l1_c;    //  16
  vec4 l2_d;    //  16
  vec4 l2_c;    //  16
  vec4 l3_d;    //  16
  vec4 l3_c;    //  16
};              // 304

out vec4 fragColor;

void main() {
  float progress = reticle.x;
  float prog_4_out = (1.-reticle.x);
  prog_4_out *= prog_4_out * prog_4_out;
  prog_4_out = 1.-prog_4_out;
  float deformed_y = 1.-abs(vTex.y);
  deformed_y = 1.25 * 1.-deformed_y*deformed_y;
  deformed_y = mix(deformed_y, abs(vTex.y), prog_4_out);
  float ring_dist = length(vec2(vTex.x, deformed_y));
  float pupil_dist = mix(length(vec2(vTex.x, .6*vTex.y)), 1., progress);
  float ring = abs(.9-ring_dist);
  ring = smoothstep(.1, .085, ring);
  float angle = (atan(-vTex.x, -vTex.y) / 6.2831 + .5);
  float prog = ring * step(angle, reticle.x);
  ring += .5*smoothstep(.175, .15, pupil_dist);
  fragColor = ring * (.1 + .6 * prog) * vec4(1., .8, .5, 1.);
}

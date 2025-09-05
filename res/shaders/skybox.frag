#version 300 es

precision mediump float;

in vec2 vPos;

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

float spreadIntensityMap(float x, float spread, float intensity) {
  // Clamp inputs
  x = clamp(x, -1.0, 1.0);
  spread = clamp(spread, 0.0, 1.0);
  intensity = clamp(intensity, 0.0, 1.0);

  // Map x into [0,1] over the active region
  float left = 1.0 - 2.0 * spread;
  float t = (x - left) / max(2.0 * spread, 1e-9);
  t = clamp(t, 0.0, 1.0);

  // Map intensity to exponent in two halves:
  //  - For intensity < 0.5 → exponent in [6, 1]
  //  - For intensity > 0.5 → exponent in [1, 1/steepness]
  float steepness = 10.0;

  float below = mix(6.0, 1.0, intensity / 0.5);                // 0..0.5
  float above = mix(1.0, 1.0 / steepness, (intensity - 0.5) / 0.5); // 0.5..1.0

  // Smoothly choose between them without branches
  float useAbove = step(0.5, intensity); // 0 below, 1 above
  float exponent = mix(below, above, useAbove);

  return pow(t, exponent);
}

void main() {
  vec4 near = invVP * vec4(vPos, -1, 1);
  vec4 far = invVP * vec4(vPos, 1, 1);
  vec3 look_dir = normalize((far.xyz/far.w) - (near.xyz/near.w));

  float yLine = 1.0 - abs(look_dir.y);
  yLine = pow(yLine, 20.0);

  vec3 color = vec3(yLine * 0.05);

  color += spreadIntensityMap(dot(normalize(l1_d.xyz), look_dir), l1_d.w, l1_c.a) * l1_c.rgb;
  color += spreadIntensityMap(dot(normalize(l2_d.xyz), look_dir), l2_d.w, l2_c.a) * l2_c.rgb;
  color += spreadIntensityMap(dot(normalize(l3_d.xyz), look_dir), l3_d.w, l3_c.a) * l3_c.rgb;

  fragColor = vec4(color, 1);
}
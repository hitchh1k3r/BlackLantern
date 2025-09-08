#version 300 es

layout(location = 0) in vec3 aPos;
layout(location = 1) in vec2 aTex;
layout(location = 2) in vec4 aCol;

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

out vec2 vTex;
out vec4 vCol;
out float vDepth;

void main() {
  vec4 viewPos = view * vec4(aPos, 1.);
  gl_Position = proj * viewPos;
  vTex = aTex;
  vCol = aCol;
  vDepth = -viewPos.z;
}

#version 300 es

layout(location = 0) in vec3 aPos;

out vec2 vPos;

void main() {
  vPos = aPos.xy;
  gl_Position = vec4(aPos, 1);
}
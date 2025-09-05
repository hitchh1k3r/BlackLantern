package shared

mem : SharedMemory

SharedMemory :: struct #align(16) {
  time : f32 "time",
  render_size : [2]f32 "render_size",
  using shader_uniform_block : struct #packed {
    projection_matrix : matrix[4, 4]f32 "projection_matrix",
    view_matrix : matrix[4, 4]f32 "view_matrix",
    inv_view_projection_matrix : matrix[4, 4]f32,
    reticle_progress : f32,
    _padding : [3]f32,
    lights : [3]struct #packed {
      dir : [3]f32,
      spread : f32,
      color : [3]f32,
      brightness : f32,
    },
  } "shader_uniform_block",
  mouse_move : [2]f32 "mouse_move",
  font_width : [256]f32 "font_width",
  vert_buffer : [1024]Vert "vert_buffer",
  audio_buffer : [4096]f32 "audio_buffer",
}

Vert :: struct #packed {
  pos : [3]f32,
  uv : [2]f32,
  color : [4]f32,
}

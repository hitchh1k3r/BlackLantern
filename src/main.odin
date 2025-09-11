package main

import "shared"

foreign import js "J"
@(default_calling_convention="contextless")
foreign js {
  @(link_name="A")
  pow :: proc(f32, f32) -> f32 ---
  @(link_name="B")
  sqrt :: proc(f32) -> f32 ---
  @(link_name="C")
  sin :: proc(f32) -> f32 ---
  @(link_name="D")
  cos :: proc(f32) -> f32 ---
  @(link_name="E")
  tan :: proc(f32) -> f32 ---

  @(link_name="b")
  set_io :: proc(ptr : rawptr) ---
  @(link_name="c")
  set_uniforms :: proc() ---
  @(link_name="d")
  draw_vert_buffer :: proc(shader : Shader, vert_count : i32) ---
  @(link_name="e")
  _play_sound_effect :: proc(layers, length : i32, volume : f32) ---
}

Color :: distinct [4]f32
C_BLACK :: Color{ 0, 0, 0, 1 }
C_WHITE :: Color{ 1, 1, 1, 1 }

question_marks := "????????????????????????????????"

nodes : []Node
yaw : f32
pitch : f32
look_origin : V3
look_forward : V3
current_scale := f32(1)
current_translate := V3_ZERO
target_scale := f32(1)
target_translate := V3_ZERO
caption_text : string
caption_ttl : f32
action_speed := f32(1.25)

@(export, link_name="z")
start :: proc "contextless" () {
  dinit()
  set_io(&shared.mem)
  init_world()
  load_location(.Memory3)
}

last_hover : ^Node
hovering : ^Node
hover_action := -100
delta_time : f32

@(export, link_name="y")
update :: proc "contextless" () {
  @(static)
  last_time : f32 = -1
  if last_time < 0 {
    last_time = shared.mem.time
  }
  delta_time = (shared.mem.time - last_time) / 1000
  last_time = shared.mem.time

  caption_ttl -= delta_time
  yaw += 0.001 * shared.mem.mouse_move.x
  pitch += 0.001 * shared.mem.mouse_move.y
  pitch = clamp(pitch, -0.3*PI, 0.15*PI)
  shared.mem.mouse_move = 0
  @(static)
  target_progress : f32
  target_progress = f32(-0.01)
  for &node, node_idx in nodes {
    target_reveal := f32(0)
    if &node == hovering {
      target_reveal = 2
      for &action, sense in node.senses {
        if update_action(&action.used, &action.use_progress, -int(sense)-1) {
          node.sense_left_until_revealed -= 1
        }
      }
      if node.sense_left_until_revealed == 0 {
        for &action, action_idx in hovering.actions {
          if update_action(&action.used, &action.use_progress, action_idx) {
            if hovering.memory_fragment {
              hovering.name = action.caption
              hovering.size *= 0.25
              for &reveal in nodes[node_idx:] {
                if !reveal.memory_fragment {
                  reveal.disabled = false
                  if reveal.sense_left_until_revealed > 0 {
                    reveal.sense_left_until_revealed -= 1
                  }
                  break
                }
              }
            } else {
              if action.caption != "" {
                caption(action.caption)
              }
            }
            action_callback(action.on_used)
          }
        }
      }

      update_action :: proc "contextless" (used : ^bool, use_progress : ^f32, action_idx : int) -> bool {
        if action_idx == hover_action {
          use_progress^ += action_speed*delta_time
          if !used^ {
            target_progress = min(1.01, use_progress^);
            if use_progress^ > 1.1 {
              used^ = true
              return true
            }
          }
        } else {
          use_progress^ = 0
        }
        return false
      }
    }
    node.reveal = lerp(node.reveal, target_reveal, half_life_interp(0.5, delta_time))
  }
  if target_progress >= shared.mem.reticle_progress {
    shared.mem.reticle_progress = target_progress
  } else {
    shared.mem.reticle_progress = lerp(shared.mem.reticle_progress, target_progress, half_life_interp(0.05, delta_time))
  }
  current_translate = lerp(current_translate, target_translate, half_life_interp(10, delta_time))
  current_scale = lerp(current_scale, target_scale, half_life_interp(3, delta_time))
  last_hover = hovering
  hovering = nil
  hover_action = -100
}

@(export, link_name="x")
render :: proc "contextless" (calculate_view : bool, calculate_proj : bool) {
  if calculate_view {
    shared.mem.view_matrix = mat4_yaw_pitch(yaw, pitch)
    target_scale = 1
    target_translate = 0
  } else {
    target_translate = mat4_inverse(shared.mem.view_matrix)[3].xyz
    target_scale = target_translate.y / 0.33 + 1
    target_scale = clamp(target_scale, 1, 4.5)
    target_translate.y = 0
    shared.mem.view_matrix = shared.mem.view_matrix * mat4_trans_scale(current_translate, current_scale)
  }
  if calculate_proj {
    shared.mem.projection_matrix = mat4_perspective(RAD_PER_DEG * 60, shared.mem.render_size.x/shared.mem.render_size.y)
  }

  inv_view := mat4_inverse(shared.mem.view_matrix)
  look_origin = inv_view[3].xyz
  look_forward = norm(-inv_view[2].xyz)
  view_projection_matrix := shared.mem.projection_matrix * shared.mem.view_matrix
  shared.mem.inv_view_projection_matrix = mat4_inverse(view_projection_matrix)
  set_uniforms()

  shared.mem.vert_buffer[0].pos = { -1, -1, 0 }
  shared.mem.vert_buffer[1].pos = {  3, -1, 0 }
  shared.mem.vert_buffer[2].pos = { -1,  3, 0 }
  draw_vert_buffer(.Skybox, 3)

  reticle_size := 0.5*max(0.1, 1 - (1-shared.mem.reticle_progress) * (1-shared.mem.reticle_progress))
  shared.mem.vert_buffer[0] = { (inv_view * V4{ -reticle_size, -reticle_size, -2, 1 }).xyz, { -1, -1 }, { 1, 1, 1, 1 } }
  shared.mem.vert_buffer[1] = { (inv_view * V4{  reticle_size, -reticle_size, -2, 1 }).xyz, {  1, -1 }, { 1, 1, 1, 1 } }
  shared.mem.vert_buffer[2] = { (inv_view * V4{ -reticle_size,  reticle_size, -2, 1 }).xyz, { -1,  1 }, { 1, 1, 1, 1 } }
  shared.mem.vert_buffer[3] = { (inv_view * V4{  reticle_size, -reticle_size, -2, 1 }).xyz, {  1, -1 }, { 1, 1, 1, 1 } }
  shared.mem.vert_buffer[4] = { (inv_view * V4{  reticle_size,  reticle_size, -2, 1 }).xyz, {  1,  1 }, { 1, 1, 1, 1 } }
  shared.mem.vert_buffer[5] = { (inv_view * V4{ -reticle_size,  reticle_size, -2, 1 }).xyz, { -1,  1 }, { 1, 1, 1, 1 } }
  draw_vert_buffer(.Reticle, 6)

  for &node in nodes {
    draw_node(&node)
  }

  if caption_ttl > 0 {
    draw_text(caption_text, (inv_view * V4{ 0, -0.8, -3, 1 }).xyz, (inv_view * V4{ 1, 0, 0, 0 }).xyz, (inv_view * V4{ 0, 1, 0, 0 }).xyz, 0.1)
  }
}

ray_quad_distance :: proc "contextless" (ray_origin: V3, ray_dir: V3, quad_origin: V3, quad_up: V3, quad_right: V3) -> f32 {
    normal := cross(quad_right, quad_up)
    normal = norm(normal)

    denom := dot(ray_dir, normal)

    if abs(denom) < 1e-6 {
        to_quad := quad_origin - ray_origin
        return abs(dot(to_quad, normal))
    }

    to_quad := quad_origin - ray_origin
    t := dot(to_quad, normal) / denom

    if t < 0 {
        return ray_point_distance(ray_origin, ray_dir, quad_origin)
    }
    plane_point := ray_origin + t * ray_dir

    to_plane := plane_point - quad_origin
    u := dot(to_plane, quad_right) / sq_mag(quad_right)
    v := dot(to_plane, quad_up) / sq_mag(quad_up)

    u_clamped := clamp(u, 0, 1)
    v_clamped := clamp(v, 0, 1)

    closest_on_quad := quad_origin + u_clamped * quad_right + v_clamped * quad_up

    return ray_point_distance(ray_origin, ray_dir, closest_on_quad)
}

ray_point_distance :: proc "contextless" (ray_origin : V3, ray_dir : V3, point : V3) -> f32 {
  to_point := point - ray_origin
  t := max(0, dot(to_point, ray_dir))
  closest := ray_origin + t * ray_dir
  return mag(point - closest)
}

draw_node :: proc "contextless" (node : ^Node) {
  if !node.disabled {
    dist := f32(0.01)
    @(static)
    look_dist : f32
    look_dist = max(f32)
    color := Color(0.5 + 0.5*clamp(node.reveal, 0, 1))
    color.a = 1
    text := node.name
    if node.sense_left_until_revealed > 0 {
      text = question_marks[:min(len(text), len(question_marks))]
      color.rgb *= 0.5
    }
    can_act := false
    if last_hover == node {
      dist += 0.1
      can_act = true
    }
    {
      @(static)
      action_size : f32
      action_size = node.size/3/1.1
      @(static)
      action_pos : V3
      action_pos = node.pos + node.size/3*node.up
      NAMES := [SenseId]string{
        .Contour = "Contour",
        .Smell = "Smell",
        .Feel = "Feel",
        .Listen = "Listen",
        .Taste = "Taste",
        .Poke = "Poke",
      }
      for action, sense in node.senses {
        if action.response != "" {
          name := NAMES[sense]
          if action.used {
            name = action.response
          }
          draw_action(name, action.used, node, action.use_progress, can_act, -int(sense)-1)
        }
      }
      if node.sense_left_until_revealed == 0 {
        for action, action_idx in node.actions {
          if !action.used {
            draw_action(action.name, action.used, node, action.use_progress, can_act, action_idx)
          }
        }
      }

      draw_action :: proc "contextless" (text : string, used : bool, node : ^Node, use_progress : f32, can_act : bool, action_idx : int) {
        if text != "" {
          color := Color(0.5 + 0.5*clamp(use_progress, 0, 1))
          color.a = 1
          color *= clamp(0.5*node.reveal*node.reveal, 0, 1)
          if used {
            color.rgb *= 0.75
          }
          pivot := V2{ 0, 0.5 }
          if node.center {
            pivot = 0.5
          }
          action_dist := draw_text(text, action_pos, node.right, node.up, action_size, color, pivot)
          if action_dist <= 0.001 {
            hover_action = action_idx
          }
          if can_act {
            look_dist = min(look_dist, action_dist)
          }
          action_pos -= (1.1*action_size)*node.up
        }
      }
    }
    pivot := V2{ 1, 0.5 }
    if node.center {
      pivot = 0.5
    }
    look_dist = min(look_dist, draw_text(text, node.pos, node.right, node.up, node.size, color, pivot))
    if look_dist < dist {
      hovering = node
    }
  }
}

draw_text :: proc "contextless" (str : string, pos : V3, right : V3, up : V3, size : f32, color := C_WHITE, pivot := V2(0.5)) -> (look_dist : f32) {
  CHAR_SIZE :: 512
  vert_count := i32(0)
  pos := pos
  up := size*up
  size := size/CHAR_SIZE
  str := str
  look_dist = max(f32)
  total_height := f32(1)
  for c in str {
    if c == '\n' {
      total_height -= 1
    }
  }
  pos -= pivot.y*total_height*up
  for len(str) > 0 {
    total_width := f32(0)
    for c in str {
      if c == '\n' {
        break
      }
      total_width += size*shared.mem.font_width[c]
    }
    line_origin := pos
    pos -= pivot.x*total_width*right
    look_dist = min(look_dist, ray_quad_distance(look_origin, look_forward, pos, up, total_width*right))
    c_idx : int
    for c, idx in str {
      c_idx = idx
      if c == '\n' {
        break
      }
      width := size*shared.mem.font_width[c]
      right := width*right
      u_width := shared.mem.font_width[c]/(16*CHAR_SIZE)
      u_min := ((f32(c%16)+0.5)/16) - u_width/2
      u_max := u_min + u_width
      shared.mem.vert_buffer[vert_count].pos = pos
      shared.mem.vert_buffer[vert_count].uv = { u_min, (f32(c/16)+1)/16 }
      shared.mem.vert_buffer[vert_count].color = transmute([4]f32)(color)
      vert_count += 1
      shared.mem.vert_buffer[vert_count].pos = pos + right
      shared.mem.vert_buffer[vert_count].uv = { u_max, (f32(c/16)+1)/16 }
      shared.mem.vert_buffer[vert_count].color = transmute([4]f32)(color)
      vert_count += 1
      shared.mem.vert_buffer[vert_count].pos = pos + up
      shared.mem.vert_buffer[vert_count].uv = { u_min, (f32(c/16)+0)/16 }
      shared.mem.vert_buffer[vert_count].color = transmute([4]f32)(color)
      vert_count += 1
      shared.mem.vert_buffer[vert_count].pos = pos + right
      shared.mem.vert_buffer[vert_count].uv = { u_max, (f32(c/16)+1)/16 }
      shared.mem.vert_buffer[vert_count].color = transmute([4]f32)(color)
      vert_count += 1
      shared.mem.vert_buffer[vert_count].pos = pos + right + up
      shared.mem.vert_buffer[vert_count].uv = { u_max, (f32(c/16)+0)/16 }
      shared.mem.vert_buffer[vert_count].color = transmute([4]f32)(color)
      vert_count += 1
      shared.mem.vert_buffer[vert_count].pos = pos + up
      shared.mem.vert_buffer[vert_count].uv = { u_min, (f32(c/16)+0)/16 }
      shared.mem.vert_buffer[vert_count].color = transmute([4]f32)(color)
      vert_count += 1
      pos += right
    }
    draw_vert_buffer(.Text, vert_count)
    str = str[c_idx+1:]
    pos = line_origin - up
  }
  return
}

caption :: #force_inline proc "contextless" (text : string, time := f32(30)) {
  caption_text = text
  caption_ttl = time
}

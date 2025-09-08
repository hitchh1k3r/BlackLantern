package main

// Math Constants //////////////////////////////////////////////////////////////////////////////////

  TAU          :: 6.28318530717958647692528676655900576
  PI           :: 3.14159265358979323846264338327950288

  RAD_PER_DEG :: TAU/360.0
  DEG_PER_RAD :: 360.0/TAU

// Interpolation ///////////////////////////////////////////////////////////////////////////////////

  lerp :: proc{ lerp_f32, lerp_V3 }

    lerp_f32 :: #force_inline proc "contextless" (a, b : f32, t : f32) -> f32 {
      return a + (b-a)*t
    }

    lerp_V3 :: #force_inline proc "contextless" (a, b : V3, t : f32) -> V3 {
      return a + (b-a)*t
    }

  half_life_interp :: proc "contextless" (half_life : f32, delta_time : f32) -> f32 {
    return 1 - pow(0.5, f32(delta_time) / half_life)
  }

  ease :: proc "contextless" (t : f32, ease_in := true, ease_out := true) -> f32 {
    if ease_in && !ease_out {
      return t * t
    } else if ease_out && !ease_in {
      return 1 - ((1-t) * (1-t))
    } else if ease_in && ease_out {
      if t < 0.5 {
        return 2 * t * t
      } else {
        t := -2*t + 2
        return 1 - (t*t)/2
      }
    }
    return t
  }

// Vectors /////////////////////////////////////////////////////////////////////////////////////////

  V2 :: [2]f32
  V3 :: [3]f32
  V4 :: [4]f32

  V2_ZERO  :: V2{  0,  0 }
  V2_LEFT  :: V2{ -1,  0 }
  V2_RIGHT :: V2{  1,  0 }
  V2_DOWN  :: V2{  0, -1 }
  V2_UP    :: V2{  0,  1 }

  V3_ZERO     :: V3{  0,  0,  0 }
  V3_LEFT     :: V3{ -1,  0,  0 }
  V3_RIGHT    :: V3{  1,  0,  0 }
  V3_DOWN     :: V3{  0, -1,  0 }
  V3_UP       :: V3{  0,  1,  0 }
  V3_FORWARD  :: V3{  0,  0, -1 }
  V3_BACKWARD :: V3{  0,  0,  1 }

  v3 :: proc{ v3__x_yz, v3__xy_z }

    v3__x_yz :: #force_inline proc "contextless" (x : f32, yz : V2) -> V3 {
      return V3{ x, yz[0], yz[1] }
    }

    v3__xy_z :: #force_inline proc "contextless" (xy : V2, z : f32) -> V3 {
      return V3{ xy[0], xy[1], z }
    }

  v4 :: proc{ v4__xyz_w, v4__x_yzw, v4__xy_z_w, v4__x_yz_w, v4__x_y_zw, v4__xy_zw }

    v4__xyz_w :: #force_inline proc "contextless" (xyz : V3, w : f32) -> V4 {
      return V4{ xyz[0], xyz[1], xyz[2], w }
    }

    v4__x_yzw :: #force_inline proc "contextless" (x : f32, yzw : V3) -> V4 {
      return V4{ x, yzw[0], yzw[1], yzw[2] }
    }

    v4__xy_z_w :: #force_inline proc "contextless" (xy : V2, z : f32, w : f32) -> V4 {
      return V4{ xy[0], xy[1], z, w }
    }

    v4__x_yz_w :: #force_inline proc "contextless" (x : f32, yz : V2, w : f32) -> V4 {
      return V4{ x, yz[0], yz[1], w }
    }

    v4__x_y_zw :: #force_inline proc "contextless" (x : f32, y : f32, zw : V2) -> V4 {
      return V4{ x, y, zw[0], zw[1] }
    }

    v4__xy_zw :: #force_inline proc "contextless" (xy : V2, zw : V2) -> V4 {
      return V4{ xy[0], xy[1], zw[0], zw[1] }
    }

// Linear Algebra //////////////////////////////////////////////////////////////////////////////////

  Mat4 :: matrix[4,4]f32

  dot :: proc "contextless" (a, b : V3) -> f32 {
    return a.x*b.x +
           a.y*b.y +
           a.z*b.z
  }

  cross :: proc "contextless" (a, b : V3) -> V3 {
    return { a.y*b.z - b.y*a.z,
             a.z*b.x - b.z*a.x,
             a.x*b.y - b.x*a.y }
  }

  norm :: #force_inline proc "contextless" (v : V3) -> V3 {
    return v / mag(v)
  }

  sq_mag :: #force_inline proc "contextless" (v : V3) -> f32 {
    return dot(v, v)
  }

  mag :: #force_inline proc "contextless" (v : V3) -> f32 {
    return sqrt(sq_mag(v))
  }

  mat4_inverse :: proc "contextless" (m: Mat4) -> (result : Mat4) {
    // 2x2 Determinants
    d2_01_01 := m[0][0] * m[1][1] - m[0][1] * m[1][0]
    d2_01_02 := m[0][0] * m[1][2] - m[0][2] * m[1][0]
    d2_01_03 := m[0][0] * m[1][3] - m[0][3] * m[1][0]
    d2_01_12 := m[0][1] * m[1][2] - m[0][2] * m[1][1]
    d2_01_13 := m[0][1] * m[1][3] - m[0][3] * m[1][1]
    d2_01_23 := m[0][2] * m[1][3] - m[0][3] * m[1][2]

    d2_02_01 := m[0][0] * m[2][1] - m[0][1] * m[2][0]
    d2_02_02 := m[0][0] * m[2][2] - m[0][2] * m[2][0]
    d2_02_03 := m[0][0] * m[2][3] - m[0][3] * m[2][0]
    d2_02_12 := m[0][1] * m[2][2] - m[0][2] * m[2][1]
    d2_02_13 := m[0][1] * m[2][3] - m[0][3] * m[2][1]
    d2_02_23 := m[0][2] * m[2][3] - m[0][3] * m[2][2]

    d2_03_01 := m[0][0] * m[3][1] - m[0][1] * m[3][0]
    d2_03_02 := m[0][0] * m[3][2] - m[0][2] * m[3][0]
    d2_03_03 := m[0][0] * m[3][3] - m[0][3] * m[3][0]
    d2_03_12 := m[0][1] * m[3][2] - m[0][2] * m[3][1]
    d2_03_13 := m[0][1] * m[3][3] - m[0][3] * m[3][1]
    d2_03_23 := m[0][2] * m[3][3] - m[0][3] * m[3][2]

    d2_12_01 := m[1][0] * m[2][1] - m[1][1] * m[2][0]
    d2_12_02 := m[1][0] * m[2][2] - m[1][2] * m[2][0]
    d2_12_03 := m[1][0] * m[2][3] - m[1][3] * m[2][0]
    d2_12_12 := m[1][1] * m[2][2] - m[1][2] * m[2][1]
    d2_12_13 := m[1][1] * m[2][3] - m[1][3] * m[2][1]
    d2_12_23 := m[1][2] * m[2][3] - m[1][3] * m[2][2]

    d2_13_01 := m[1][0] * m[3][1] - m[1][1] * m[3][0]
    d2_13_02 := m[1][0] * m[3][2] - m[1][2] * m[3][0]
    d2_13_03 := m[1][0] * m[3][3] - m[1][3] * m[3][0]
    d2_13_12 := m[1][1] * m[3][2] - m[1][2] * m[3][1]
    d2_13_13 := m[1][1] * m[3][3] - m[1][3] * m[3][1]
    d2_13_23 := m[1][2] * m[3][3] - m[1][3] * m[3][2]

    d2_23_01 := m[2][0] * m[3][1] - m[2][1] * m[3][0]
    d2_23_02 := m[2][0] * m[3][2] - m[2][2] * m[3][0]
    d2_23_03 := m[2][0] * m[3][3] - m[2][3] * m[3][0]
    d2_23_12 := m[2][1] * m[3][2] - m[2][2] * m[3][1]
    d2_23_13 := m[2][1] * m[3][3] - m[2][3] * m[3][1]
    d2_23_23 := m[2][2] * m[3][3] - m[2][3] * m[3][2]

    // Cofactors
    d3_012_012 := m[0][0] * d2_12_12 - m[0][1] * d2_12_02 + m[0][2] * d2_12_01
    d3_012_013 := m[0][0] * d2_12_13 - m[0][1] * d2_12_03 + m[0][3] * d2_12_01
    d3_012_023 := m[0][0] * d2_12_23 - m[0][2] * d2_12_03 + m[0][3] * d2_12_02
    d3_012_123 := m[0][1] * d2_12_23 - m[0][2] * d2_12_13 + m[0][3] * d2_12_12

    d3_013_012 := m[0][0] * d2_13_12 - m[0][1] * d2_13_02 + m[0][2] * d2_13_01
    d3_013_013 := m[0][0] * d2_13_13 - m[0][1] * d2_13_03 + m[0][3] * d2_13_01
    d3_013_023 := m[0][0] * d2_13_23 - m[0][2] * d2_13_03 + m[0][3] * d2_13_02
    d3_013_123 := m[0][1] * d2_13_23 - m[0][2] * d2_13_13 + m[0][3] * d2_13_12

    d3_023_012 := m[0][0] * d2_23_12 - m[0][1] * d2_23_02 + m[0][2] * d2_23_01
    d3_023_013 := m[0][0] * d2_23_13 - m[0][1] * d2_23_03 + m[0][3] * d2_23_01
    d3_023_023 := m[0][0] * d2_23_23 - m[0][2] * d2_23_03 + m[0][3] * d2_23_02
    d3_023_123 := m[0][1] * d2_23_23 - m[0][2] * d2_23_13 + m[0][3] * d2_23_12

    d3_123_012 := m[1][0] * d2_23_12 - m[1][1] * d2_23_02 + m[1][2] * d2_23_01
    d3_123_013 := m[1][0] * d2_23_13 - m[1][1] * d2_23_03 + m[1][3] * d2_23_01
    d3_123_023 := m[1][0] * d2_23_23 - m[1][2] * d2_23_03 + m[1][3] * d2_23_02
    d3_123_123 := m[1][1] * d2_23_23 - m[1][2] * d2_23_13 + m[1][3] * d2_23_12

    // Determinant
    det := m[0][0] * d3_123_123 - m[0][1] * d3_123_023 + m[0][2] * d3_123_013 - m[0][3] * d3_123_012
    inv_det := 1.0 / det

    // Adjugate matrix
    result[0][0] = +d3_123_123 * inv_det
    result[0][1] = -d3_023_123 * inv_det
    result[0][2] = +d3_013_123 * inv_det
    result[0][3] = -d3_012_123 * inv_det

    result[1][0] = -d3_123_023 * inv_det
    result[1][1] = +d3_023_023 * inv_det
    result[1][2] = -d3_013_023 * inv_det
    result[1][3] = +d3_012_023 * inv_det

    result[2][0] = +d3_123_013 * inv_det
    result[2][1] = -d3_023_013 * inv_det
    result[2][2] = +d3_013_013 * inv_det
    result[2][3] = -d3_012_013 * inv_det

    result[3][0] = -d3_123_012 * inv_det
    result[3][1] = +d3_023_012 * inv_det
    result[3][2] = -d3_013_012 * inv_det
    result[3][3] = +d3_012_012 * inv_det
    return
  }

  mat4_trans_scale :: proc "contextless" (translate : V3, scale : f32) -> (result : Mat4) {
    result[0].x = scale
    result[1].y = scale
    result[2].z = scale
    result[3].xyz = scale * translate
    result[3].w = 1
    return
  }

  mat4_yaw_pitch :: proc "contextless" (yaw, pitch : f32) -> (result : Mat4) {
    cp := cos(pitch)
    sp := sin(pitch)
    cy := cos(yaw)
    sy := sin(yaw)
    result = {
               1,  0,   0, 0,
               0, cp, -sp, 0,
               0, sp,  cp, 0,
               0,  0,   0, 1,
             }
    result *= {
                  1, 0,  0, 0,
                  0, 1,  0, 0.1*pitch,
                  0, 0,  1, 0.1,
                  0, 0,  0, 1,
              }
    result *= {
                 cy, 0, sy, 0,
                  0, 1,  0, 0,
                -sy, 0, cy, 0,
                  0, 0,  0, 1,
              }
    return
  }

  mat4_perspective :: proc "contextless" (fovy, aspect : f32) -> (result : Mat4) {
    NEAR :: 0.1
    FAR :: 1000
    tan_half_fovy := tan(0.5 * fovy)
    result[0, 0] = 1 / (aspect*tan_half_fovy)
    result[1, 1] = 1 / (tan_half_fovy)
    result[2, 2] = -(FAR + NEAR) / (FAR - NEAR)
    result[3, 2] = -1
    result[2, 3] = -2*FAR*NEAR / (FAR - NEAR)

    return
  }
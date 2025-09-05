package main

import "base:runtime"

import "core:fmt"
import "core:math/linalg"

import "shared"

when ODIN_DEBUG {

  dcontext : runtime.Context

  foreign import js "J"
  foreign js {
    @(link_name="a")
    log :: proc "contextless" (str : string) ---
  }

  dinit :: proc "contextless" () {
    dcontext = runtime.default_context()
  }

  dlog :: proc "contextless" (args : ..any) {
    context = dcontext
    buf : [1024]u8
    log(fmt.bprint(buf[:], args = args))
  }

  dlogf :: proc "contextless" (_fmt : string, args : ..any) {
    context = dcontext
    buf : [1024]u8
    log(fmt.bprintf(buf[:], _fmt, args = args))
  }

  @(export)
  dlight :: proc "contextless" (i : i32, r, g, b, s, l : f32) {
    dir := (linalg.matrix4_inverse_f32(shared.mem.view_matrix) * [4]f32{ 0, 0, -1, 0 }).xyz
    dlog(dir)
    shared.mem.lights[i].dir = dir
    shared.mem.lights[i].color = { r, g, b }
    shared.mem.lights[i].spread = s
    shared.mem.lights[i].brightness = l
  }

} else {

  log :: proc "contextless" (str : string) {}
  dinit :: proc "contextless" () {}
  dlog :: proc "contextless" (args : ..any) {}
  dlogf :: proc "contextless" (_fmt : string, args : ..any) {}

}
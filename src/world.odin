package main

import "shared"

Node :: struct {
  disabled : bool,
  name : string,
  sense_left_until_revealed : u8,
  pos : V3,
  right : V3,
  up : V3,
  size : f32,
  reveal : f32,
  senses : [SenseId]Sense,
  actions : []Action,
  center : bool,
  memory_fragment : bool,
}

SenseId :: enum {
  Contour,
  Smell,
  Feel,
  Listen,
  Taste,
  Poke,
}

Sense :: struct {
  response : string,
  used : bool,
  use_progress : f32,
}

Action :: struct {
  name : string,
  caption : string,
  used : bool,
  use_progress : f32,
  on_used : u8,
}

node_mem : [NodeId]Node
action_mem : [ActionId]Action

NodeSerial :: bit_field u32 {
  // byte 0
  sense_left_until_revealed : u8 | 3, // 0-7
  center : bool | 1,
  distance : u8 | 2,  // 1 2 4 16
  rotation : u8 | 2,  // -35 0 35 ??

  // byte 1
  yaw_pos : u8 | 5,   // 11.25 degrees apart
  pitch_pos : u8 | 3, // -40 -20 0 10 20 30 40 50

  // byte 2
  disabled : bool | 1,
  action_count : u8 | 2, // 0-3
  action1_callback : bool | 1,
  action2_callback : bool | 1,
  action3_callback : bool | 1,
  memory_fragment : bool | 1,
  _ : u8 | 1,

  // byte 3
  sense_contour : bool | 1,
  sense_smell : bool | 1,
  sense_feel : bool | 1,
  sense_listen : bool | 1,
  sense_taste : bool | 1,
  sense_poke : bool | 1,
  _ : u8 | 2,
}

init_world :: proc "contextless" () {
  action_idx := 0
  callback_idx := u8(0)

  for serial, key in DATA_TEXTS {
    node : Node
    node.name = get_string()
    node.disabled = serial.disabled
    node.center = serial.center
    node.memory_fragment = serial.memory_fragment
    node.sense_left_until_revealed = serial.sense_left_until_revealed
    yaw := -f32(serial.yaw_pos) * 11.25 * RAD_PER_DEG
    transform := mat4_yaw_pitch(yaw, 0)
    dist := pow(f32(serial.distance+1), 2) / 15
    node.pos = (transform * V4{ 0, dist*dist*5*(f32(serial.pitch_pos)-3), -pow(3, f32(serial.distance)), 1 }).xyz
    transform *= mat4_yaw_pitch((f32(serial.rotation)-1) * 35 * RAD_PER_DEG, 0)
    node.right = (transform * V4{ 1, 0, 0, 0 }).xyz
    node.up = { 0, 1, 0 }
    node.size = 2 * dist
    node.actions = (transmute([^]Action)(&action_mem))[action_idx:action_idx+int(serial.action_count)]

    if serial.sense_contour {
      node.senses[.Contour].response = get_string()
    }
    if serial.sense_smell {
      node.senses[.Smell].response = get_string()
    }
    if serial.sense_feel {
      node.senses[.Feel].response = get_string()
    }
    if serial.sense_listen {
      node.senses[.Listen].response = get_string()
    }
    if serial.sense_taste {
      node.senses[.Taste].response = get_string()
    }
    if serial.sense_poke {
      node.senses[.Poke].response = get_string()
    }
    node_mem[key] = node

    for i in 0..<serial.action_count {
      action : Action
      action.name = get_string()
      action.caption = get_string()
      if (i == 0 && serial.action1_callback) ||
         (i == 1 && serial.action2_callback) ||
         (i == 2 && serial.action3_callback) {
        callback_idx += 1
        action.on_used = callback_idx
      }
      action_mem[ActionId(action_idx)] = action
      action_idx += 1
    }
  }
  node_mem[.Dream3_Outside_Insignificance].size = 20
  node_mem[.Dream3_Outside_Unfinishedness].size = 20
  node_mem[.Dream3_Outside_Erasure].size = 20
}

get_string :: proc "contextless" () -> (result : string) {
  last_can_break := false
  for r, i in DATA_STRING {
    if r == '\x00' {
      result = DATA_STRING[:i]
      DATA_STRING = DATA_STRING[i+1:]
      return
    }
    if last_can_break && r >= 'A' && r <= 'Z' {
      result = DATA_STRING[:i]
      DATA_STRING = DATA_STRING[i:]
      return
    }
    last_can_break = (r >= 'a' && r <= 'z') || r == '.' || r == '!'
  }

  result = DATA_STRING
  return
}

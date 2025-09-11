package build

import "core:fmt"
import "core:io"
import "core:os"
import "core:strings"
import "core:unicode"

import "../src/world_data"

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

write_world_data_file :: proc() {
  string_pool : strings.Builder
  strings.builder_init(&string_pool, 0, 4096)

  file_out : strings.Builder
  strings.builder_init(&file_out, 0, 32768)

  locations : map[string]world_data.Location
  process_ns("", world_data.world, &locations)
  process_ns :: proc(prefix : string, ns : world_data.NS, locations : ^map[string]world_data.Location) {
    for key, ns in ns {
      prefix := prefix
      if prefix != "" {
        prefix = fmt.tprintf("%v_%v", prefix, key)
      } else {
        prefix = key
      }
      switch ns in ns {
        case world_data.NS:
          process_ns(prefix, ns, locations)
        case world_data.Location:
          locations[prefix] = ns
      }
    }
  }

  texts : [dynamic]world_data.Text
  actions : [dynamic]world_data.Action
  fmt.sbprint(&file_out, "package main\n\n")

  fmt.sbprint(&file_out, "////////////////////////////////////////////////////////////////////////////////////////////////////\n")
  fmt.sbprint(&file_out, "// Automatically Generated File ////////////////////////////////////////////////////////////////////\n")
  fmt.sbprint(&file_out, "////////////////////////////////////////////////////////////////////////////////////////////////////\n\n")

  fmt.sbprint(&file_out, "// Do not edit, changes will be overwritten...\n\n")

  fmt.sbprint(&file_out, "import \"shared\"\n\n")

  fmt.sbprint(&file_out, "LocationId :: enum {\n")
  for name, location in locations {
    fmt.sbprintf(&file_out, "  %v,\n", name)
    for text in location.texts {
      text := text
      text.key = fmt.tprintf("%v_%v", name, to_key(text.name))
      append(&texts, text)
      add_string(&string_pool, text.name)
      if text.sense_contour != "" {
        add_string(&string_pool, text.sense_contour)
      }
      if text.sense_smell != "" {
        add_string(&string_pool, text.sense_smell)
      }
      if text.sense_feel != "" {
        add_string(&string_pool, text.sense_feel)
      }
      if text.sense_listen != "" {
        add_string(&string_pool, text.sense_listen)
      }
      if text.sense_taste != "" {
        add_string(&string_pool, text.sense_taste)
      }
      if text.sense_poke != "" {
        add_string(&string_pool, text.sense_poke)
      }
      for action in text.actions {
        action := action
        action.key = fmt.tprintf("%v_%v", text.key, to_key(action.name))
        append(&actions, action)
        add_string(&string_pool, action.name)
        add_string(&string_pool, action.caption)
      }
    }
  }
  fmt.sbprint(&file_out, "}\n\n")

  fmt.sbprint(&file_out, "NodeId :: enum {\n")
  for text in texts {
    fmt.sbprintf(&file_out, "  %v,\n", text.key)
  }
  fmt.sbprint(&file_out, "}\n\n")

  fmt.sbprint(&file_out, "ActionId :: enum {\n")
  for action in actions {
    fmt.sbprintf(&file_out, "  %v,\n", action.key)
  }
  fmt.sbprint(&file_out, "}\n\n")

  fmt.sbprint(&file_out, "load_location :: proc \"contextless\" (location : LocationId) {\n")
  fmt.sbprint(&file_out, "  shared.mem.lights = {}\n")
  fmt.sbprint(&file_out, "  switch location {\n")
  node_idx := 0
  for name, location in locations {
    fmt.sbprintf(&file_out, "    case .%v:\n", name)
    fmt.sbprintln(&file_out, location.setup)
    fmt.sbprintf(&file_out, "      nodes = (transmute([^]Node)(&node_mem))[%v:%v]\n\n", node_idx, node_idx+len(location.texts))
    node_idx += len(location.texts)
  }
  fmt.sbprint(&file_out, "  }\n")
  fmt.sbprint(&file_out, "}\n\n")

  // fmt.sbprint(&file_out, "@(static)\n")
  fmt.sbprint(&file_out, "DATA_STRING := \"")
  for c in strings.to_string(string_pool) {
    if c == 0 {
      fmt.sbprint(&file_out, "\\x00")
    } else {
      fmt.sbprint(&file_out, c)
    }
  }
  fmt.sbprint(&file_out, "\"\n\n")

  // fmt.sbprint(&file_out, "@(static)\n")
  fmt.sbprint(&file_out, "DATA_TEXTS := [NodeId]NodeSerial{\n")
  for text in texts {
    data := NodeSerial{
      sense_left_until_revealed = u8(text.sense_required),
      center = text.centered,
      distance = u8(text.distance),
      rotation = u8(text.rotation),
      yaw_pos = u8(text.yaw %% 32),
      pitch_pos = u8(text.pitch + 3),
      disabled = text.disabled,
      action_count = u8(len(text.actions)),
      action1_callback = len(text.actions) >= 1 && text.actions[0].on_use != "",
      action2_callback = len(text.actions) >= 2 && text.actions[1].on_use != "",
      action3_callback = len(text.actions) >= 3 && text.actions[2].on_use != "",
      memory_fragment = text.memory,
      sense_contour = (text.sense_contour != ""),
      sense_smell = (text.sense_smell != ""),
      sense_feel = (text.sense_feel != ""),
      sense_listen = (text.sense_listen != ""),
      sense_taste = (text.sense_taste != ""),
      sense_poke = (text.sense_poke != ""),
    }
    fmt.sbprintf(&file_out, "  .%v = auto_cast %v,\n", text.key, u32(data))
  }
  fmt.sbprint(&file_out, "}\n\n")

  fmt.sbprint(&file_out, "action_callback :: proc \"contextless\" (idx : u8) {\n")
  fmt.sbprint(&file_out, "  switch idx {\n")
  callback_idx := 1
  for action, idx in actions {
    if action.on_use != "" {
      fmt.sbprintf(&file_out, "\n    case %v:\n", callback_idx)
      callback_idx += 1
      fmt.sbprint(&file_out, action.on_use)
    }
  }
  fmt.sbprint(&file_out, "\n  }\n")
  fmt.sbprint(&file_out, "}\n\n")
  os.write_entire_file("src/world_data_.odin", file_out.buf[:])
}

add_string :: proc(sb : ^strings.Builder, str : string) {
  if str == "" {
    strings.write_rune(sb, 0)
    strings.write_rune(sb, 0)
    return
  }

  {
    last_can_break := true
    if len(sb.buf) > 0 {
      r := sb.buf[len(sb.buf)-1]
      last_can_break = (r >= 'a' && r <= 'z') || r == '.' || r == '!'
    }
    if str[0] < 'A' || str[0] > 'Z' {
      strings.write_rune(sb, 0)
    }
  }

  last_can_break := false
  for c, i in str {
    if c == '\x00' {
      fmt.eprintf("String \"%v\" contains breaking pattern at: %v!", str, i)
      os.exit(1)
    }
    if last_can_break && c >= 'A' && c <= 'Z' {
      fmt.eprintf("String \"%v\" contains breaking pattern at: %v!", str, i)
      os.exit(1)
    }
    last_can_break = (c >= 'a' && c <= 'z') || c == '.' || c == '!'
    if c == '\n' {
      strings.write_string(sb, "\\n")
    } else if c == '"' {
      strings.write_string(sb, "\\\"")
    } else {
      strings.write_rune(sb, c)
    }
  }
}

to_key :: proc(str : string) -> string {
  s := strings.trim_space(str)
  b: strings.Builder
  strings.builder_init(&b, 0, len(s))
  w := strings.to_writer(&b)

  strings.string_case_iterator(w, s, proc(w: io.Writer, prev, curr, next: rune) {
    if !strings.is_delimiter(curr) && !strings.contains_rune(".!", curr) {
      if strings.is_delimiter(prev) || prev == 0 || (unicode.is_lower(prev) && unicode.is_upper(curr)) {
        if prev != 0 {
          io.write_rune(w, '_')
        }
        io.write_rune(w, unicode.to_upper(curr))
      } else {
        io.write_rune(w, unicode.to_lower(curr))
      }
    }
  })

  return strings.to_string(b)
}

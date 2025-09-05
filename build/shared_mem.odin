#+feature dynamic-literals
package build

import "base:runtime"

import "core:fmt"
import "core:reflect"
import "core:strings"

import "../src/shared"
import "beard"

shared_mem : [dynamic]beard.Node
// name
// start
// end

/* beard.process(..., beard.Map{ ..., "shared_mems" = shared_mem[:] }) */

shared_mem_init :: proc() {
  shared_struct := reflect.type_info_base(type_info_of(shared.SharedMemory)).variant.(runtime.Type_Info_Struct)
  recv(shared_struct, 0)
  recv :: proc(info : runtime.Type_Info_Struct, base_offset : uintptr) {
    for i in 0..<info.field_count {
      if info.tags[i] != "" {
        append(&shared_mem, beard.Map{
          "name" = info.tags[i],
          "start" = fmt.aprint(int(base_offset + info.offsets[i])/4),
          "end" = fmt.aprint((int(base_offset + info.offsets[i]) + info.types[i].size)/4),
        })
      }
      if sub, ok := info.types[i].variant.(runtime.Type_Info_Struct); ok{
        recv(sub, base_offset + info.offsets[i])
      }
    }
  }
}

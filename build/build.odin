#+feature dynamic-literals
package build

import "core:fmt"
import "core:os"
import "core:strings"
import "core:sys/posix"

import "beard"

is_debug : bool

main :: proc() {
  // Setup:
    defer fmt.println("Done")

    shared_mem_init()

    is_debug = len(os.args) > 1 && os.args[1] == "DEBUG"
    if is_debug {
      fmt.println("DEBUG BUILD\n")
    }

  fmt.println("Building Shaders...")
    if load_shaders_and_create_enum() {
      fmt.println("  okay")
    } else {
      return
    }

  if !is_debug { fmt.println("Compressing Shaders...")
    total_full := 0
    total_mini := 0
    for &shader in shaders {
      v, f := (&(shader.(beard.Map)))^["vert_src"].(string), (&(shader.(beard.Map)))^["frag_src"].(string)
      defer delete(v)
      defer delete(f)
      total_full += len(v)
      total_full += len(f)
      vert, frag := minify_program(v, f)
      (&(shader.(beard.Map)))^["vert_src"] = vert
      (&(shader.(beard.Map)))^["frag_src"] = frag
      total_mini += len(vert)
      total_mini += len(frag)
    }
    fmt.printfln("  okay (%.3f -> %.3f KiB) - included in JS", f32(total_full)/1024, f32(total_mini)/1024)
  }

  fmt.println("Building WASM...")
    os.make_directory("artifacts")
    cmd : cstring
    if is_debug {
      cmd = "odin build src -o:none -debug -no-entry-point -no-crt -out:artifacts/g.wasm -target:freestanding_wasm32 -extra-linker-flags:\"--stack-first --lto-O3 --gc-sections\""
    } else {
      cmd = "odin build src -o:aggressive -no-entry-point -no-crt -no-bounds-check -disable-assert -no-type-assert -obfuscate-source-code-locations -out:artifacts/full.wasm -target:freestanding_wasm32 -extra-linker-flags:\"--stack-first --lto-O3 --gc-sections --strip-all\""
    }
    if exec(cmd) == 0 {
      fmt.println("  okay")
    } else {
      return
    }

  if !is_debug { fmt.println("Compressing WASM...")
    if exec("wasm-opt -Oz --enable-bulk-memory --converge --low-memory-unused --zero-filled-memory --const-hoisting --ignore-implicit-traps artifacts/full.wasm -o artifacts/g.wasm") == 0 {
      fmt.printfln("  okay (%.3f -> %.3f KiB)", f32(os.file_size_from_path("artifacts/full.wasm"))/1024, f32(os.file_size_from_path("artifacts/g.wasm"))/1024)
    } else {
      return
    }
  }

  fmt.println("Building JS...")
    js_bld := strings.builder_make()
    beard.process(string(#load("../src/main.js")), beard.Map{
        "debug" = is_debug,
        "shared_mems" = shared_mem[:],
        "shaders" = shaders[:],
        "wasm_start" = "exports.z",
        "wasm_update" = "exports.y",
        "wasm_render" = "exports.x",
      }, bld = &js_bld)
    fmt.println("  okay")
    js_str := strings.to_string(js_bld)

  if !is_debug { fmt.println("Compressing JS...")
    try_compressing_js: {
      if os.write_entire_file("artifacts/full.js", transmute([]u8)(js_str)) {
        if exec("..\\..\\jdk-24.0.2\\bin\\java -jar closure-compiler.jar 2>&1 " +
                "--compilation_level ADVANCED " +
                "--js artifacts/full.js " +
                "--externs closure-externs.js " +
                "--js_output_file artifacts/mini.js " +
                "--language_in ECMASCRIPT_NEXT " +
                "--language_out ECMASCRIPT_2020 " +
                "--env BROWSER " +
                "--rewrite_polyfills false " +
                // "--jscomp_off '*' " +
                "") == 0 {
          if js_bytes, ok := os.read_entire_file("artifacts/mini.js"); ok {
            fmt.printfln("  okay (%.3f -> %.3f KiB)", f32(len(js_str))/1024, f32(len(js_bytes))/1024)
            js_str = transmute(string)(js_bytes)
            break try_compressing_js
          }
        }
      }
      // any failure
      return
    }
  }

  fmt.println("Writing HTML...")
    index_html, err := os.open("artifacts/index.html", os.O_WRONLY | os.O_CREATE | os.O_TRUNC)
    if err != nil {
      fmt.eprintln("Error:", err)
      return
    }
    os.write_string(index_html, "<script>")
    os.write_string(index_html, js_str)
    os.write_string(index_html, "</script>")
    err = os.close(index_html)
    if err != nil {
      fmt.eprintln("Error:", err)
      return
    }
    fmt.println("  okay")

  if !is_debug { fmt.println("Creating ZIP Archive...")
    os.set_current_directory("artifacts")
    if exec("7z a -mX9 -tzip -y archive.zip g.wasm index.html > nul") == 0 {
      size := os.file_size_from_path("archive.zip")
      fmt.printfln("  okay (%.3f KiB - %.2f%%)", f32(size)/1024, f32(size)*100/13/1024)
    } else {
      return
    }
  }
}

exec :: proc(cmd : cstring) -> i32 {
  fp := posix.popen(cmd, "r")
  buffer : [1024]byte
  for posix.fgets(raw_data(buffer[:]), len(buffer), fp) != nil {
    if string(buffer[:len("WARNING: ")]) != "WARNING: " { // Silence closure-compiler's library's warnings
      posix.printf("%s", &buffer)
    }
  }
  return posix.pclose(fp)
}

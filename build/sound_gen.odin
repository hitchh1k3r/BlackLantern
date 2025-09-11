package build

import "core:strings"
import "core:math"
import "core:fmt"
import "core:os"
import "core:image/png"

FREQ_POWER :: 10.0
FREQ_MIN :: 400
FREQ_MAX :: 5200

write_sound_file :: proc() {
  file_out : strings.Builder
  strings.builder_init(&file_out, 0, 32768)

  fmt.sbprint(&file_out, ""+
`package main

////////////////////////////////////////////////////////////////////////////////////////////////////
// Automatically Generated File ////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

// Do not edit, changes will be overwritten...

import "shared"

SoundId :: enum {
  Mew,
  Mewowl,
  Siren,
}

Sound :: struct {
  length : f32,
  times : []u8,
  frequencies : []u8,
  amplitudes : []u8,
}

SOUNDS := [SoundId]Sound {
`)
  gen_sound(&file_out, "Mew",    "res/sounds/mew.png",    5020,  0.76, -47, -17)
  gen_sound(&file_out, "Mewowl", "res/sounds/mewowl.png", 4000,  0.95, -60, -10)
  gen_sound(&file_out, "Siren",  "res/sounds/siren.png",  2500, 10.40, -63, -22)

  fmt.sbprint(&file_out, ""+
`}

play_sound :: proc "contextless" (sound : SoundId, volume := f32(1)) {
  sound := SOUNDS[sound]

  sample_count := len(sound.times)
  layer_count := len(sound.frequencies) / sample_count

  write_idx := 0
  for i in 0..<sample_count {
    shared.mem.audio_buffer[write_idx] = f32(sound.times[i]) / 255 * sound.length
    write_idx += 1
  }
  for i in 0..<layer_count*sample_count {
`)
  fmt.sbprintf(&file_out, ""+
`    FREQ_POWER :: %v
    FREQ_MIN :: %v
    FREQ_MAX :: %v
`, FREQ_POWER, FREQ_MIN, FREQ_MAX)
  fmt.sbprint(&file_out, ""+
`    freq := f32(sound.frequencies[i]) / 255
    shared.mem.audio_buffer[write_idx] = FREQ_MIN + pow(freq, FREQ_POWER) * (FREQ_MAX - FREQ_MIN)
    shared.mem.audio_buffer[write_idx + sample_count*layer_count] = f32(sound.amplitudes[i]) / 255
    write_idx += 1
  }
  _play_sound_effect(i32(layer_count), i32(sample_count), volume)
}
`)

  os.write_entire_file("src/sounds_.odin", file_out.buf[:])
}

gen_sound :: proc(sb : ^strings.Builder, name : string, file : string, max_freq : f32, max_time : f32, min_db : f32, max_db : f32) {
  img, _ := png.load_from_file(file)

  time_per_pixel := max_time / f32(img.width)
  cut_frames := make([]bool, img.width)
  times := make([]f32, img.width)
  for i in 0..<img.width {
    times[i] = time_per_pixel*f32(i)
  }

  avg : struct {
    frequencies : []f32,
    weights : []f32,
  }
  avg.frequencies = make([]f32, img.width)
  avg.weights = make([]f32, img.width)

  harm_count := 0
  img_stride := img.width*img.channels
  {
    c := 0
    for y in 0..<img.height {
      if img.pixels.buf[c+1] > 0 {
        harm_count += 1
      }
      c += img_stride
    }
  }


  harmonics := make([]struct {
    frequencies : []f32,
    amplitudes : []f32,
  }, harm_count)
  for h in 0..<harm_count {
    harmonics[h].frequencies = make([]f32, img.width)
    harmonics[h].amplitudes = make([]f32, img.width)
  }

  freq_per_pixel := max_freq / f32(img.height)
  for x in 0..<img.width {
    c := (img.channels * x) + (img_stride * (img.height-1))
    harmonic_idx := 0
    column_scan: for y in 0..<img.height {
      px := [3]u8{ img.pixels.buf[c], img.pixels.buf[c+1], img.pixels.buf[c+2] }
      c -= img_stride
      if px.g > 0 {
        freq := f32(y)*freq_per_pixel
        amp := f32(px.r)/255
        if amp > 0 {
          amp = min_db + (max_db-min_db)*amp
          amp = math.pow(10, amp/20)
        }
        avg.frequencies[x] += freq/f32(harmonic_idx+1)*amp
        avg.weights[x] += amp
        harmonics[harmonic_idx].frequencies[x] = freq
        harmonics[harmonic_idx].amplitudes[x] = max(0.001, amp)
        harmonic_idx += 1
      }
    }
  }

  // Compression:
  for {
    FREQ_CUT_LIMIT :: 17
    AMP_CUT_LIMIT :: 0.05
    best_idx := -1
    best_hz := max(f32)
    best_amp := max(f32)
    for i in 1..<img.width-1 {
      if !cut_frames[i] {
        error_hz := f32(0)
        error_amp := f32(0)
        prev_idx := prev_non_cut(cut_frames[:], i)
        next_idx := next_non_cut(cut_frames[:], i)
        prev_time := times[prev_idx]
        next_time := times[next_idx]
        t := math.unlerp(prev_time, next_time, times[i])
        for harm in harmonics {
          this_error_amp := abs(harm.amplitudes[i] - math.lerp(harm.amplitudes[prev_idx], harm.amplitudes[next_idx], t))
          error_amp = max(error_amp, this_error_amp)
          error_hz = max(error_hz, (10 * this_error_amp) * abs(harm.frequencies[i] - math.lerp(harm.frequencies[prev_idx], harm.frequencies[next_idx], t)))
        }
        if error_hz < best_hz && error_amp < best_amp {
          best_hz = error_hz
          best_amp = error_amp
          best_idx = i
        }
      }
    }
    if best_hz < FREQ_CUT_LIMIT && best_amp < AMP_CUT_LIMIT {
      cut_frames[best_idx] = true
    } else {
      break
    }
  }

  // Print Out:
  fmt.sbprintf(sb, "  .%v = {{\n", name)
  fmt.sbprintf(sb, "    length =      %v,\n", max_time)
  fmt.sbprint(sb, "    times =       {")
  print_cut_array(sb, times[:], cut_frames[:], 0, times[len(times)-1])
  fmt.sbprint(sb, " },\n")
  fmt.sbprint(sb, "    frequencies = {")
  print_cut_array(sb, harmonics[0].frequencies[:], cut_frames[:], FREQ_MIN, FREQ_MAX, FREQ_POWER)
  for i in 1..<harm_count {
    fmt.sbprint(sb, "\n                   ")
    print_cut_array(sb, harmonics[i].frequencies[:], cut_frames[:], FREQ_MIN, FREQ_MAX, FREQ_POWER)
  }
  fmt.sbprint(sb, " },\n")
  fmt.sbprint(sb, "    amplitudes =  {")
  print_cut_array(sb, harmonics[0].amplitudes[:], cut_frames[:], 0, 0.667)
  for i in 1..<harm_count {
    fmt.sbprint(sb, "\n                   ")
    print_cut_array(sb, harmonics[i].amplitudes[:], cut_frames[:], 0, 0.667)
  }
  fmt.sbprint(sb, " },\n")
  fmt.sbprint(sb, "  },\n")

  print_cut_array :: proc(sb : ^strings.Builder, arr : []f32, cuts : []bool, min : f32, max : f32, power := f32(1)) {
    for a, idx in arr {
      if !cuts[idx] {
        t := clamp(math.unlerp(min, max, a), 0, 1)
        fmt.sbprintf(sb, " % 3d,", u8(math.round(255 * math.pow(t, 1/power))))
      }
    }
  }

  prev_non_cut :: proc(cuts : []bool, idx : int) -> int {
    for i := idx-1; i >= 0; i -= 1 {
      if !cuts[i] {
        return i
      }
    }
    return -1
  }

  next_non_cut :: proc(cuts : []bool, idx : int) -> int {
    for i := idx+1; i < len(cuts); i += 1 {
      if !cuts[i] {
        return i
      }
    }
    return -1
  }

  return
}

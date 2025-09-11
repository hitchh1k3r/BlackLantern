package build

import "core:math"
import "core:fmt"
import "core:image/png"

/*
main :: proc() {
  // NOCOMMIT 5020 is too big! maybe we should do a log scale?
  gen_sound("res/sounds/mew.png",    5020, 0.763, -47, -17)
  gen_sound("res/sounds/mewowl.png", 4000, 0.95,  -60, -10)
  gen_sound("res/sounds/piano.png",  1860, 1.5,   -36, -19)
}
*/

gen_sound :: proc(file : string, max_freq : f32, max_time : f32, min_db : f32, max_db : f32) -> string {
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
  fmt.print("{\n")
  fmt.printf("  length =      %v,\n", max_time)
  fmt.print("  times =       {")
  print_cut_array(times[:], cut_frames[:], 0, times[len(times)-1])
  fmt.print(" },\n")
  fmt.print("  frequencies = {")
  print_cut_array(harmonics[0].frequencies[:], cut_frames[:], 400, 4400)
  for i in 1..<harm_count {
    fmt.print("\n                 ")
    print_cut_array(harmonics[i].frequencies[:], cut_frames[:], 400, 4400)
  }
  fmt.print(" },\n")
  fmt.print("  amplitudes =  {")
  print_cut_array(harmonics[0].amplitudes[:], cut_frames[:], 0, 1)
  for i in 1..<harm_count {
    fmt.print("\n                 ")
    print_cut_array(harmonics[i].amplitudes[:], cut_frames[:], 0, 1)
  }
  fmt.print(" },\n")
  fmt.print("}\n\n")

  print_cut_array :: proc(arr : []f32, cuts : []bool, min : f32, max : f32) {
    for a, idx in arr {
      if !cuts[idx] {
        fmt.printf(" % 3d,", u8(math.round(255 * (a - min) / (max - min))))
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

  return ""
}

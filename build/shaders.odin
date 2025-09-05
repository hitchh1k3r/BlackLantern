#+feature dynamic-literals
package build

import "base:runtime"

import "core:os"
import "core:fmt"
import "core:slice"
import "core:strings"
import "core:text/scanner"
import "core:strconv"

import "beard"

shaders : [dynamic]beard.Node
// idx
// caps_name
// vert_src
// frag_src
// not_last

/* beard.process(..., beard.Map{ ..., "shaders" = shaders[:] }) */

load_shaders_and_create_enum :: proc() -> bool {
  if shaders_dir, err := os.open("res/shaders/"); err == nil {
    idx := 0
    for file in os.read_dir(shaders_dir, -1) or_else {} {
      if strings.ends_with(file.name, ".vert") {
        try_reading_shaders: {
          if vert, ok := os.read_entire_file(file.fullpath); ok {
            defer delete(vert)
            buf : [128]u8
            if frag, ok := os.read_entire_file(fmt.bprintf(buf[:], "%v.frag", file.fullpath[:len(file.fullpath)-len(".vert")])); ok {
              defer delete(frag)
              strip_shader :: proc(src : string, allocator := context.allocator) -> string {
                src := src
                if is_debug {
                  alloc : bool
                  src, alloc = strings.replace_all(src, "$", "", allocator)
                  if alloc {
                    return src
                  }
                }
                return strings.clone(src, allocator)
              }
              name := file.name[:len(file.name)-len(".vert")]
              append(&shaders, beard.Map{
                "idx" = fmt.aprint(idx),
                "caps_name" = strings.to_upper_snake_case(name),
                "ada_name" = strings.to_ada_case(name),
                "vert_src" = strip_shader(string(vert)),
                "frag_src" = strip_shader(string(frag)),
                "not_last" = true,
              })
              idx += 1
              break try_reading_shaders
            }
          }
          // any failure
          return false
        }
      }
    }
    (&(shaders[idx-1].(beard.Map)))^["not_last"] = false
    os.close(shaders_dir)
    if os.write_entire_file("src/shaders_.odin", transmute([]u8)(beard.process(TEMPLATE, beard.Map{ "shaders" = shaders[:] }))) {
      return true
    }
  } else {
    fmt.eprintln("Error:", err)
  }
  return false
  TEMPLATE :: `package main

////////////////////////////////////////////////////////////////////////////////////////////////////
// Automatically Generated File ////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

// Do not edit, changes will be overwritten...

Shader :: enum int {
  {{#shaders}}
    {{ada_name}} = {{idx}},
  {{/shaders}}
}`
}

minify_program :: proc(vert, frag : string, allocator := context.allocator) -> (string, string) {
  GLSL_WORDS :: []string{ "std140", "main","location","abs","acos","acosh","all","any","asin","asinh","atan","atanh","atomic_uint","atomicCounter","atomicCounterDecrement","atomicCounterIncrement","atomicOP","attribute","barrier","bitCount","bitfieldExtract","bitfieldInsert","bitfieldReverse","bool","break","buffer","bvec2","bvec3","bvec4","case","ceil","centroid","clamp","coherent","const","continue","cos","cosh","cross","default","degrees","determinant","dFdx","dFdy","discard","distance","dmat2","dmat2x2","dmat2x3","dmat2x4","dmat3","dmat3x2","dmat3x3","dmat3x4","dmat4","dmat4x2","dmat4x3","dmat4x4","do","dot","double","dvec2","dvec3","dvec4","else","EmitStreamVertex","EmitVertex","EndPrimitive","EndStreamPrimitive","equal","exp","exp2","faceforward","false","findLSB","findMSB","flat","float","floatBitsToInt","floatBitsToUint","floor","fma","for","fract","frexp","fwidth","gl_ClipDistance","gl_FragCoord","gl_FragDepth","gl_FrontFacing","gl_GlobalInvocationID","gl_InstanceID","gl_InvocationID","gl_Layer","gl_LocalGroupSize","gl_LocalInvocationID","gl_LocalInvocationIndex","gl_MaxAtomicCounterBindings","gl_MaxAtomicCounterBufferSize","gl_MaxClipDistances","gl_MaxCombinedAtomicCounterBuffers","gl_MaxCombinedAtomicCounters","gl_MaxCombinedImageUniforms","gl_MaxCombinedImageUnitsAndFragmentOutputs","gl_MaxCombinedTextureImageUnits","gl_MaxComputeAtomicCounterBuffers","gl_MaxComputeAtomicCounters","gl_MaxComputeImageUniforms","gl_MaxComputeTextureImageUnits","gl_MaxComputeUniformComponents","gl_MaxComputeWorkGroupCount","gl_MaxComputeWorkGroupSize","gl_MaxDrawBuffers","gl_MaxFragmentAtomicCounterBuffers","gl_MaxFragmentAtomicCounters","gl_MaxFragmentImageUniforms","gl_MaxFragmentInputComponents","gl_MaxFragmentUniformComponents","gl_MaxFragmentUniformVectors","gl_MaxGeometryAtomicCounterBuffers","gl_MaxGeometryAtomicCounters","gl_MaxGeometryImageUniforms","gl_MaxGeometryInputComponents","gl_MaxGeometryOutputComponents","gl_MaxGeometryOutputVertices","gl_MaxGeometryTextureImageUnits","gl_MaxGeometryTotalOutputComponents","gl_MaxGeometryUniformComponents","gl_MaxGeometryVaryingComponents","gl_MaxImageSamples","gl_MaxImageUnits","gl_MaxPatchVertices","gl_MaxProgramTexelOffset","gl_MaxTessControlAtomicCounterBuffers","gl_MaxTessControlAtomicCounters","gl_MaxTessControlImageUniforms","gl_MaxTessControlInputComponents","gl_MaxTessControlOutputComponents","gl_MaxTessControlTextureImageUnits","gl_MaxTessControlTotalOutputComponents","gl_MaxTessControlUniformComponents","gl_MaxTessEvaluationAtomicCounterBuffers","gl_MaxTessEvaluationAtomicCounters","gl_MaxTessEvaluationImageUniforms","gl_MaxTessEvaluationInputComponents","gl_MaxTessEvaluationOutputComponents","gl_MaxTessEvaluationTextureImageUnits","gl_MaxTessEvaluationUniformComponents","gl_MaxTessGenLevel","gl_MaxTessPatchComponents","gl_MaxTextureImageUnits","gl_MaxTransformFeedbackBuffers","gl_MaxTransformFeedbackInterleavedComponents","gl_MaxVaryingComponents","gl_MaxVaryingVectors","gl_MaxVertexAtomicCounterBuffers","gl_MaxVertexAtomicCounters","gl_MaxVertexAttribs","gl_MaxVertexImageUniforms","gl_MaxVertexOutputComponents","gl_MaxVertexTextureImageUnits","gl_MaxVertexUniformComponents","gl_MaxVertexUniformVectors","gl_MaxViewports","gl_MinProgramTexelOffset","gl_NumWorkGroups","gl_PatchVerticesIn","gl_PerVertex","gl_PointCoord","gl_PointSize","gl_Position","gl_PrimitiveID","gl_PrimitiveIDIn","gl_SampleID","gl_SampleMask","gl_SampleMaskIn","gl_SamplePosition","gl_TessCoord","gl_TessLevelInner","gl_TessLevelOuter","gl_VertexID","gl_ViewportIndex","gl_WorkGroupID","gl_WorkGroupSize","greaterThan","greaterThanEqual","groupMemoryBarrier","highp","if","iimage1D","iimage1DArray","iimage1DArrayShadow","iimage1DMS","iimage1DMSArray","iimage1DRect","iimage1DRectShadow","iimage1DShadow","iimage2D","iimage2DArray","iimage2DArrayShadow","iimage2DMS","iimage2DMSArray","iimage2DRect","iimage2DRectShadow","iimage2DShadow","iimage3D","iimage3DArray","iimage3DArrayShadow","iimage3DMS","iimage3DMSArray","iimage3DRect","iimage3DRectShadow","iimage3DShadow","iimageBuffer","iimageBufferArray","iimageBufferArrayShadow","iimageBufferMS","iimageBufferMSArray","iimageBufferRect","iimageBufferRectShadow","iimageBufferShadow","iimageCube","iimageCubeArray","iimageCubeArrayShadow","iimageCubeMS","iimageCubeMSArray","iimageCubeRect","iimageCubeRectShadow","iimageCubeShadow","image1D","image1DArray","image1DArrayShadow","image1DMS","image1DMSArray","image1DRect","image1DRectShadow","image1DShadow","image2D","image2DArray","image2DArrayShadow","image2DMS","image2DMSArray","image2DRect","image2DRectShadow","image2DShadow","image3D","image3DArray","image3DArrayShadow","image3DMS","image3DMSArray","image3DRect","image3DRectShadow","image3DShadow","imageAtomicAdd","imageAtomicAnd","imageAtomicCompSwap","imageAtomicExchange","imageAtomicMax","imageAtomicMin","imageAtomicXor","imageBuffer","imageBufferArray","imageBufferArrayShadow","imageBufferMS","imageBufferMSArray","imageBufferRect","imageBufferRectShadow","imageBufferShadow","imageCube","imageCubeArray","imageCubeArrayShadow","imageCubeMS","imageCubeMSArray","imageCubeRect","imageCubeRectShadow","imageCubeShadow","imageLoad","imageSize","imageStore","imulExtended","in","inout","int","intBitsToFloat","interpolateAtCentroid","interpolateAtOffset","interpolateAtSample","invariant","inverse","inversesqrt","isampler1D","isampler1DArray","isampler1DArrayShadow","isampler1DMS","isampler1DMSArray","isampler1DRect","isampler1DRectShadow","isampler1DShadow","isampler2D","isampler2DArray","isampler2DArrayShadow","isampler2DMS","isampler2DMSArray","isampler2DRect","isampler2DRectShadow","isampler2DShadow","isampler3D","isampler3DArray","isampler3DArrayShadow","isampler3DMS","isampler3DMSArray","isampler3DRect","isampler3DRectShadow","isampler3DShadow","isamplerBuffer","isamplerBufferArray","isamplerBufferArrayShadow","isamplerBufferMS","isamplerBufferMSArray","isamplerBufferRect","isamplerBufferRectShadow","isamplerBufferShadow","isamplerCube","isamplerCubeArray","isamplerCubeArrayShadow","isamplerCubeMS","isamplerCubeMSArray","isamplerCubeRect","isamplerCubeRectShadow","isamplerCubeShadow","isinf","isnan","ivec2","ivec3","ivec4","layout","ldexp","length","lessThan","lessThanEqual","log","log2","lowp","mageAtomicOr","mat2","mat2x2","mat2x3","mat2x4","mat3","mat3x2","mat3x3","mat3x4","mat4","mat4x2","mat4x3","mat4x4","matrixCompMult","max","mediump","memoryBarrier","memoryBarrierAtomicCounter","memoryBarrierBuffer","memoryBarrierImage","memoryBarrierShared","min","mix","mod","modf","noise1","noise2","noise3","noise4","noperspective","normalize","not","notEqual","out","outerProduct","packDouble2x32","packHalf2x16","packSnorm2x16","packSnorm4x8","packUnorm2x16","packUnorm4x8","patch","pow","precision","radians","readonly","reflect","refract","restrict","return","round","roundEven","sample","sampler1D","sampler1DArray","sampler1DArrayShadow","sampler1DMS","sampler1DMSArray","sampler1DRect","sampler1DRectShadow","sampler1DShadow","sampler2D","sampler2DArray","sampler2DArrayShadow","sampler2DMS","sampler2DMSArray","sampler2DRect","sampler2DRectShadow","sampler2DShadow","sampler3D","sampler3DArray","sampler3DArrayShadow","sampler3DMS","sampler3DMSArray","sampler3DRect","sampler3DRectShadow","sampler3DShadow","samplerBuffer","samplerBufferArray","samplerBufferArrayShadow","samplerBufferMS","samplerBufferMSArray","samplerBufferRect","samplerBufferRectShadow","samplerBufferShadow","samplerCube","samplerCubeArray","samplerCubeArrayShadow","samplerCubeMS","samplerCubeMSArray","samplerCubeRect","samplerCubeRectShadow","samplerCubeShadow","shared","sign","sin","sinh","smooth","smoothstep","sqrt","step","struct","subroutine","switch","tan","tanh","texelFetch","texelFetchOffset","texture","texture2D","texture2DLod","texture2DProj","texture2DProjLod","textureCube","textureCubeLod","textureGather","textureGatherOffset","textureGatherOffsets","textureGrad","textureGradOffset","textureLod","textureLodOffset","textureProj","textureProjGrad","textureProjGradOffset","textureProjLod","textureProjLodOffset","textureProjOffset","textureQueryLevels","textureQueryLod","textureSize","transpose","true","trunc","tureOffset","u","uaddCarry","uimage1D","uimage1DArray","uimage1DArrayShadow","uimage1DMS","uimage1DMSArray","uimage1DRect","uimage1DRectShadow","uimage1DShadow","uimage2D","uimage2DArray","uimage2DArrayShadow","uimage2DMS","uimage2DMSArray","uimage2DRect","uimage2DRectShadow","uimage2DShadow","uimage3D","uimage3DArray","uimage3DArrayShadow","uimage3DMS","uimage3DMSArray","uimage3DRect","uimage3DRectShadow","uimage3DShadow","uimageBuffer","uimageBufferArray","uimageBufferArrayShadow","uimageBufferMS","uimageBufferMSArray","uimageBufferRect","uimageBufferRectShadow","uimageBufferShadow","uimageCube","uimageCubeArray","uimageCubeArrayShadow","uimageCubeMS","uimageCubeMSArray","uimageCubeRect","uimageCubeRectShadow","uimageCubeShadow","uint","uintBitsToFloat","umulExtended","uniform","unpackDouble2x32","unpackHalf2x16","unpackSnorm2x16","unpackSnorm4x8","unpackUnorm2x16","unpackUnorm4x8","usampler1D","usampler1DArray","usampler1DArrayShadow","usampler1DMS","usampler1DMSArray","usampler1DRect","usampler1DRectShadow","usampler1DShadow","usampler2D","usampler2DArray","usampler2DArrayShadow","usampler2DMS","usampler2DMSArray","usampler2DRect","usampler2DRectShadow","usampler2DShadow","usampler3D","usampler3DArray","usampler3DArrayShadow","usampler3DMS","usampler3DMSArray","usampler3DRect","usampler3DRectShadow","usampler3DShadow","usamplerBuffer","usamplerBufferArray","usamplerBufferArrayShadow","usamplerBufferMS","usamplerBufferMSArray","usamplerBufferRect","usamplerBufferRectShadow","usamplerBufferShadow","usamplerCube","usamplerCubeArray","usamplerCubeArrayShadow","usamplerCubeMS","usamplerCubeMSArray","usamplerCubeRect","usamplerCubeRectShadow","usamplerCubeShadow","usubBorrow","uvec2","uvec3","uvec4","varying","vec2","vec3","vec4","void","volatile","while","writeonly" }
  @(static)
  SHORT_NAMES := []string{"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","aa","ab","ac","ad","ae","af","ag","ah","ai","aj","ak","al","am","an","ao","ap","aq","ar","as","at","au","av","aw","ax","ay","az","ba","bb","bc","bd","be","bf","bg","bh","bi","bj","bk","bl","bm","bn","bo","bp","bq","br","bs","bt","bu","bv","bw","bx","by","bz"}

  needs_seperator :: proc(c : u8) -> bool {
    return (c >= 'a' && c <= 'z') ||
           (c >= 'A' && c <= 'Z') ||
           (c >= '0' && c <= '9') ||
           (c == '_')
  }

  short_name_idx := 0
  replacements : map[string]int
  return process_shader(vert, &short_name_idx, &replacements, allocator), process_shader(frag, &short_name_idx, &replacements, allocator)

  process_shader :: proc(src : string, short_name_idx : ^int, replacements : ^map[string]int, allocator : runtime.Allocator) -> string {
    buffer := make([]u8, len(src), allocator)
    write_idx := 0
    s : scanner.Scanner
    scanner.init(&s, src)
    last := u8(0)
    define_line := max(int)
    no_rename := false
    was_dot := false
    for {
      tok := scanner.scan(&s)
      if tok == scanner.EOF {
        break
      }
      pos := scanner.position(&s)
      if pos.line > define_line {
        last = 0
        write_idx += len(fmt.bprint(buffer[write_idx:], "\n"))
        define_line = max(int)
      }
      if tok == '#' {
        define_line = pos.line
      }
      if tok == '$' {
        no_rename = true
        continue
      }
      defer no_rename = false
      if tok == '.' {
        write_idx += len(fmt.bprint(buffer[write_idx:], '.'))
        was_dot = true
        continue
      }
      defer was_dot = false
      text := scanner.token_text(&s)

      if !was_dot && needs_seperator(last) && needs_seperator(text[0]) {
        write_idx += len(fmt.bprint(buffer[write_idx:], " "))
      }
      if !was_dot && define_line == max(int) && tok == scanner.Ident && !slice.contains(GLSL_WORDS, text) {
        if no_rename {
          replacements[text] = -1
          write_idx += len(fmt.bprint(buffer[write_idx:], text))
        } else if r, ok := replacements[text]; ok {
          if r == -1 {
            write_idx += len(fmt.bprint(buffer[write_idx:], text))
          } else {
            write_idx += len(fmt.bprint(buffer[write_idx:], SHORT_NAMES[r]))
          }
        } else {
          write_idx += len(fmt.bprint(buffer[write_idx:], SHORT_NAMES[short_name_idx^]))
          replacements[text] = short_name_idx^
          short_name_idx^ += 1
        }
      } else {
        write_idx += len(fmt.bprint(buffer[write_idx:], text))
      }
      last = text[0]
    }
    return string(buffer[:write_idx])
  }
}

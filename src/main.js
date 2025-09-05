document.addEventListener("DOMContentLoaded", async () => {

  // Utils:
    {{#debug}}
      function get_string(ptr, len) {
        const bytes = new Uint8Array(mem_buf, ptr, len);
        return new TextDecoder('utf-8').decode(bytes);
      }
    {{/debug}}

  // Init WebAudio:
    const audio = new AudioContext();
    /** @suppress {checkTypes} */
    const audio_volume = new GainNode(audio);
    audio_volume.connect(audio.destination);

  // Init WebGL:
    document.body.style.cssText = 'margin:0;padding:0';

    const vr_button = document.createElement('button');
    vr_button.textContent = 'Enter VR';
    vr_button.style.cssText = 'position:absolute;margin:25';
    document.body.appendChild(vr_button);

    const canvas = document.createElement('canvas');
    document.body.appendChild(canvas);
    const gl = canvas.getContext('webgl2', { xrCompatible: true });
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.ONE, gl.ONE_MINUS_SRC_ALPHA);
    let vr_session = null;
    function resize_canvas() {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    }
    resize_canvas();
    window.onresize = resize_canvas;

  // Make Shaders:
    function make_program(vsSource, fsSource) {
      function compileShader(type, source) {
        const shader = gl.createShader(type);
        gl.shaderSource(shader, source);
        gl.compileShader(shader);
        // @OP Remove Error Handling:
        if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
          console.error("Shader compile error:", gl.getShaderInfoLog(shader));
          gl.deleteShader(shader);
          return null;
        }
        return shader;
      }
      const vs = compileShader(gl.VERTEX_SHADER, vsSource);
      const fs = compileShader(gl.FRAGMENT_SHADER, fsSource);
      const program = gl.createProgram();
      gl.attachShader(program, vs);
      gl.attachShader(program, fs);
      gl.linkProgram(program);
      if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
        console.error("Program link error:", gl.getProgramInfoLog(program));
        gl.deleteProgram(program);
        return null;
      }
      gl.uniformBlockBinding(program, gl.getUniformBlockIndex(program, 'U'), 0);
      return program;
    };
    {{#shaders}}
      const SHADER_{{caps_name}} = {{idx}};
    {{/shaders}}
    const shaders = [
      {{#shaders}}
          make_program(`{{vert_src}}`,`{{frag_src}}`){{#not_last}},{{/not_last}}
      {{/shaders}}
    ];

  // User Input:
    let pointerLocked = false;
    canvas.onclick = () => {
      if (!pointerLocked && !vr_session) {
        canvas.requestPointerLock();
      }
    };

    document.onpointerlockchange = () => {
      pointerLocked = document.pointerLockElement === canvas;
    };

    document.onmousemove = (e) => {
      if (pointerLocked) {
        shared_mem_mouse_move.set([ e.movementX, e.movementY ])
      }
    };

  // Init VR:
    vr_button.onclick = async () => {
      if (vr_session) {
        vr_session.end();
      } else {
        vr_session = await navigator.xr.requestSession('immersive-vr');
        await gl.makeXRCompatible();

        vr_session.updateRenderState({
          baseLayer: new XRWebGLLayer(vr_session, gl)
        });

        vr_session.referenceSpace = await vr_session.requestReferenceSpace('local');
        vr_session.requestAnimationFrame(vr_loop);

        vr_session.onend = () => {
          vr_session = null;
          vr_button.textContent = 'Enter VR';
        };
        vr_button.textContent = 'Exit VR';
      }
    };

  // WASM:
    const ubo = gl.createBuffer();
    {{#shared_mems}}
      let shared_mem_{{name}};
    {{/shared_mems}}
    const {instance: {exports}} = await WebAssembly.instantiateStreaming(fetch('g.wasm'), {
      // NOCOMMIT remove env, do custom math procs
      /** @export */
      env: {
        /** @export */
        sinf: Math.sin,
        /** @export */
        cosf: Math.cos,
        /** @export */
        tanf: Math.tan,
        /** @export */
        powf: Math.pow,
        /** @export */
        exp2f: (v) => { return Math.pow(2, v); },
      },
      /** @export */
      J: {
        /** @export */
        A: Math.pow,
        /** @export */
        B: Math.sqrt,
        /** @export */
        C: Math.sin,
        /** @export */
        D: Math.cos,
        /** @export */
        E: Math.tan,

        {{#debug}}
          /** @export */
          a /* log */: (ptr, len) => {
            const str = get_string(ptr, len);
            console.log(str);
          },
        {{/debug}}

        /** @export */
        b /* set_io */: (ptr) => {
          const mem = new Float32Array(mem_buf, ptr);
          {{#shared_mems}}
            shared_mem_{{name}} = mem.subarray({{start}}, {{end}});
          {{/shared_mems}}

          // Make VBO:
          const vbo = gl.createBuffer();
          gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
          gl.bufferData(gl.ARRAY_BUFFER, 4*shared_mem_vert_buffer.length, gl.DYNAMIC_DRAW);
          gl.enableVertexAttribArray(0);
          gl.enableVertexAttribArray(1);
          gl.enableVertexAttribArray(2);
          gl.vertexAttribPointer(0, 3, gl.FLOAT, false, 36,  0);
          gl.vertexAttribPointer(1, 2, gl.FLOAT, false, 36, 12);
          gl.vertexAttribPointer(2, 4, gl.FLOAT, false, 36, 20);
          // also update const view = shared_mem_vert_buffer.subarray(0, 9*vert_count); to have the right ??*vert_count

          // UBO:
          gl.bindBuffer(gl.UNIFORM_BUFFER, ubo);
          gl.bufferData(gl.UNIFORM_BUFFER, 4*shared_mem_shader_uniform_block.length, gl.DYNAMIC_DRAW);
          gl.bindBufferBase(gl.UNIFORM_BUFFER, 0, ubo);

          // Font Atlas:
          const SIZE = 128;
          const atlas = document.createElement('canvas');
          const ctx = atlas.getContext('2d')
          atlas.width = atlas.height = 16*SIZE;
          ctx.fillStyle = 'black';
          ctx.fillRect(0, 0, 16*SIZE, 16*SIZE);
          ctx.font = '100px Verdana';
          ctx.fillStyle = 'white';
          ctx.textAlign = 'center';
          ctx.textBaseline = 'middle';

          for(let i=0;i<256;i++){
            const x=(i%16)*SIZE+SIZE/2,y=Math.floor(i/16)*SIZE+SIZE/2;
            const c = String.fromCharCode(i);
            shared_mem_font_width[i] = ctx.measureText(c).width;
            ctx.fillText(c, x, y);
          }

          const tex = gl.createTexture();
          gl.bindTexture(gl.TEXTURE_2D, tex);
          gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, atlas);
          gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
          gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
          gl.generateMipmap(gl.TEXTURE_2D);
          gl.useProgram(shaders[SHADER_TEXT])
          gl.uniform1i(gl.getUniformLocation(shaders[SHADER_TEXT], 'T'), 0);
        },
        /** @export */
        c /* set_uniforms */: () => {
          gl.bufferSubData(gl.UNIFORM_BUFFER, 0, shared_mem_shader_uniform_block)
        },
        /** @export */
        d /* draw_vert_buffer */: (shader, vert_count) => {
          gl.useProgram(shaders[shader]);
          const view = shared_mem_vert_buffer.subarray(0, 9*vert_count);
          gl.bufferSubData(gl.ARRAY_BUFFER, 0, view);
          gl.drawArrays(gl.TRIANGLES, 0, vert_count);
        },
        e /* play_sound_effect */: (layers, length, volume) => {
          function create_oscillator(times, freqs, gains, volume) {
            const audio_now = audio.currentTime;
            /** @suppress {checkTypes} */
            const freq = new OscillatorNode(audio);
            /** @suppress {checkTypes} */
            const gain = new GainNode(audio);
            for (let i = 0; i < times.length; i += 1) {
              gain.gain.linearRampToValueAtTime(volume*gains[i], audio_now+times[i]);
              freq.frequency.linearRampToValueAtTime(freqs[i], audio_now+times[i]);
            }
            freq.connect(gain).connect(audio_volume);
            freq.start();
            setTimeout(() => {
              freq.stop();
              freq.disconnect();
              gain.disconnect();
            }, 1000*times[times.length-1] + 100)
          }
          const times = shared_mem_audio_buffer.subarray(0, length);
          let freq_idx = length;
          let gain_idx = (1+layers)*length;
          for (let layer_idx = 0; layer_idx < layers; layer_idx += 1) {
            const freqs = shared_mem_audio_buffer.subarray(freq_idx, freq_idx+length);
            const gains = shared_mem_audio_buffer.subarray(gain_idx, gain_idx+length);
            freq_idx += length;
            gain_idx += length;
            create_oscillator(times, freqs, gains, volume);
          }
        },
      }
    });
    const mem_buf = exports.memory.buffer;
    {{#debug}}
      /** @export */
      window.hack = exports;
    {{/debug}}

  // Main Loop:
    function draw_preview(mouse_control) {
      gl.bindFramebuffer(gl.FRAMEBUFFER, null);
      gl.clear(gl.COLOR_BUFFER_BIT);
      gl.viewport(0, 0, canvas.width, canvas.height);
      shared_mem_render_size.set([canvas.width, canvas.height]);
      {{wasm_render}}(mouse_control, true);
    }
    function loop(time) {
      requestAnimationFrame(loop);

      if (!vr_session) {
        shared_mem_time[0] = time;
        {{wasm_update}}();
        draw_preview(true);
      }
    };
    function vr_loop(time, frame) {
      vr_session.requestAnimationFrame(vr_loop);

      shared_mem_time[0] = time;
      {{wasm_update}}();

      const pose = frame.getViewerPose(vr_session.referenceSpace);
      if (pose) {
        const layer = vr_session.renderState.baseLayer;
        gl.bindFramebuffer(gl.FRAMEBUFFER, layer.framebuffer);
        gl.clear(gl.COLOR_BUFFER_BIT);

        for (const view of pose.views) {
          const viewport = layer.getViewport(view);
          gl.viewport(viewport.x, viewport.y, viewport.width, viewport.height);
          shared_mem_render_size.set([viewport.width, viewport.height]);
          shared_mem_projection_matrix.set(view.projectionMatrix);
          shared_mem_view_matrix.set(view.transform.inverse.matrix);
          {{wasm_render}}(false, false);
        }

        draw_preview(false);
      }
    };
    {{wasm_start}}();
    requestAnimationFrame(loop);

  });
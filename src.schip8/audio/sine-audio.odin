package audio

import "core:fmt"
import math "core:math"
import ma "vendor:miniaudio"

// User data we pass into callback
ToneState :: struct {
    phase      : f64,
    phase_delta : f64,
    SAMPLE_RATE : int, // 48000
    CHANNELS    : int, // 2
    FREQ        : f64, // 440.0
    AMPLITUDE   : f64  // 0.15
}
updatePhase :: proc(state: ^ToneState) {
    state.phase_delta = math.TAU * state.FREQ / f64(state.SAMPLE_RATE);
}
data_callback :: proc "c" (device: ^ma.device, pOutput: rawptr, pInput: rawptr, frameCount: u32) {
    _ = pInput

    state := cast(^ToneState)device.pUserData
    out := cast([^]f32)pOutput
    frames := frameCount
    channels := state.CHANNELS

    for i in 0..<int(frames) {
        sample := f32(math.sin(state.phase) * state.AMPLITUDE)
        // write same sample to all channels (stereo)
        for c in 0..<channels {
            out[i*channels + c] = sample
        }
        state.phase += state.phase_delta
        if state.phase >= math.TAU do state.phase -= math.TAU
    }
}

muteAudio :: proc(state: ^ToneState) {
    if state.AMPLITUDE != 0.0 {
        state.AMPLITUDE = 0.0
        updatePhase(state)
    }
}
unmuteAudio :: proc(state: ^ToneState) {
    if state.AMPLITUDE == 0.0 {
        state.AMPLITUDE = 0.2
        updatePhase(state)
    }
}

device: ma.device
startAudioThread :: #force_inline proc(state: ^ToneState) -> ^ma.device {
    fmt.println("Starting sine tone playback...")

    // initialize state
    state.phase        = 0
    state.phase_delta  = 0
    state.SAMPLE_RATE  = 48000
    state.CHANNELS     = 1
    state.FREQ         = 540.0
    state.AMPLITUDE    = 0.0
    updatePhase(state)

    // configure device
    config := ma.device_config_init(ma.device_type.playback)
    config.playback.format   = ma.format.f32
    config.playback.channels = u32(state.CHANNELS)
    config.sampleRate        = u32(state.SAMPLE_RATE)
    config.dataCallback      = data_callback
    config.pUserData         = state

    v1 := ma.device_init(nil, &config, &device)
    assert(v1 == ma.result.SUCCESS, fmt.aprintf("Failed to initialize playback device: %s", v1))
    v2 := ma.device_start(&device)
    assert(v2 == ma.result.SUCCESS, fmt.aprint("Failed to start device: %s", v2))

    return &device
}

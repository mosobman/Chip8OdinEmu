#+feature dynamic-literals
package main

import "core:fmt"
import "core:c"
import "core:time"
import emu "emulator"
import ma "vendor:miniaudio"


keymap := map[mfb_key]int {
    mfb_key.KB_KEY_1 = 0x1,
    mfb_key.KB_KEY_2 = 0x2,
    mfb_key.KB_KEY_3 = 0x3,
    mfb_key.KB_KEY_4 = 0xC,
    mfb_key.KB_KEY_Q = 0x4,
    mfb_key.KB_KEY_W = 0x5,
    mfb_key.KB_KEY_E = 0x6,
    mfb_key.KB_KEY_R = 0xD,
    mfb_key.KB_KEY_A = 0x7,
    mfb_key.KB_KEY_S = 0x8,
    mfb_key.KB_KEY_D = 0x9,
    mfb_key.KB_KEY_F = 0xE,
    mfb_key.KB_KEY_Z = 0xA,
    mfb_key.KB_KEY_X = 0x0,
    mfb_key.KB_KEY_C = 0xB,
    mfb_key.KB_KEY_V = 0xF
}

keyboard :mfb_keyboard_func: proc(window: ^mfb_window, key: mfb_key, mod: mfb_key_mod, isPressed: c.bool) {
    //fmt.println("KEY :", isPressed ? "DOWN" : "UP", ":", key)

    if (!isPressed) {
        if (key == mfb_key.KB_KEY_ESCAPE) {
            mfb_close(window)
        }
    }
    if key in keymap {
        emulator.keyPad[keymap[key]] = isPressed;
    }
}

emulator : ^emu.Emulator

main :: proc() {
    width  := emu.RESOLUTION.x;
    height := emu.RESOLUTION.y;
    fmt.printfln("Window Size: (%d, %d) = (%d, %d)*%d", width, height, emu.DISPLAY.x, emu.DISPLAY.y, emu.SCALE)

    mfb_set_target_fps(60)
    window := mfb_open_ex("miniFB Odin", cast(c.uint)width, cast(c.uint)height, cast(c.uint)mfb_window_flags.WF_NONE);
    if window == nil {
        fmt.println("Failed to open window");
        return;
    }
    mfb_set_keyboard_callback(window, keyboard);


    emulator = emu.makeEmulator();

    old := time.now()._nsec
    ticks :u64= 0
    for ;; {
        value := mfb_update(window, &(emulator^.display_screen[0]))
        if value != mfb_update_state.STATE_OK {
            fmt.println("Window State: ", value)
            break
        }

        emu.update(emulator)
        if emulator.displayUpdate do emu.refresh(emulator)
        
        // avoid burning 100% CPU
        mfb_wait_sync(window);
        //time.accurate_sleep(16 * time.Millisecond)

        emulator.deltaTime = f64(time.now()._nsec - old) / 1e9
        old = time.now()._nsec

        if ticks%(60*10) == 0 {
            fmt.printfln("FPS: %f", 1.0/emulator.deltaTime)
            fmt.printfln("DeltaTime: %f ms", 1000.0*emulator.deltaTime)
        }
        ticks += 1
    }
    ma.device_uninit(emulator.device);
    free(emulator)

    mfb_close(window);
}

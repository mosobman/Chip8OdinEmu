package main

import "core:c"

foreign import minifb {
    "../lib/minifb.lib",
    "system:opengl32.lib",
    "system:kernel32.lib",
    "system:winmm.lib",
    "system:gdi32.lib",
    "system:user32.lib",
}

// Enums
mfb_update_state :: enum c.int {
    STATE_OK             =  0,
    STATE_EXIT           = -1,
    STATE_INVALID_WINDOW = -2,
    STATE_INVALID_BUFFER = -3,
    STATE_INTERNAL_ERROR = -4,
};
mfb_mouse_button :: enum c.uint {
    MOUSE_BTN_0, // No mouse button
    MOUSE_BTN_1,
    MOUSE_BTN_2,
    MOUSE_BTN_3,
    MOUSE_BTN_4,
    MOUSE_BTN_5,
    MOUSE_BTN_6,
    MOUSE_BTN_7,
    MOUSE_LEFT   = MOUSE_BTN_1,
    MOUSE_RIGHT  = MOUSE_BTN_2,
    MOUSE_MIDDLE = MOUSE_BTN_3
};

mfb_key :: enum c.int {
    KB_KEY_UNKNOWN        = -1,  // Unknown
    KB_KEY_SPACE          = 32,  // Space
    KB_KEY_APOSTROPHE     = 39,  // Apostrophe
    KB_KEY_COMMA          = 44,  // Comma
    KB_KEY_MINUS          = 45,  // Minus
    KB_KEY_PERIOD         = 46,  // Period
    KB_KEY_SLASH          = 47,  // Slash
    KB_KEY_0              = 48,  // 0
    KB_KEY_1              = 49,  // 1
    KB_KEY_2              = 50,  // 2
    KB_KEY_3              = 51,  // 3
    KB_KEY_4              = 52,  // 4
    KB_KEY_5              = 53,  // 5
    KB_KEY_6              = 54,  // 6
    KB_KEY_7              = 55,  // 7
    KB_KEY_8              = 56,  // 8
    KB_KEY_9              = 57,  // 9
    KB_KEY_SEMICOLON      = 59,  // Semicolon
    KB_KEY_EQUAL          = 61,  // Equal
    KB_KEY_A              = 65,  // A
    KB_KEY_B              = 66,  // B
    KB_KEY_C              = 67,  // C
    KB_KEY_D              = 68,  // D
    KB_KEY_E              = 69,  // E
    KB_KEY_F              = 70,  // F
    KB_KEY_G              = 71,  // G
    KB_KEY_H              = 72,  // H
    KB_KEY_I              = 73,  // I
    KB_KEY_J              = 74,  // J
    KB_KEY_K              = 75,  // K
    KB_KEY_L              = 76,  // L
    KB_KEY_M              = 77,  // M
    KB_KEY_N              = 78,  // N
    KB_KEY_O              = 79,  // O
    KB_KEY_P              = 80,  // P
    KB_KEY_Q              = 81,  // Q
    KB_KEY_R              = 82,  // R
    KB_KEY_S              = 83,  // S
    KB_KEY_T              = 84,  // T
    KB_KEY_U              = 85,  // U
    KB_KEY_V              = 86,  // V
    KB_KEY_W              = 87,  // W
    KB_KEY_X              = 88,  // X
    KB_KEY_Y              = 89,  // Y
    KB_KEY_Z              = 90,  // Z
    KB_KEY_LEFT_BRACKET   = 91,  // Left_Bracket
    KB_KEY_BACKSLASH      = 92,  // Backslash
    KB_KEY_RIGHT_BRACKET  = 93,  // Right_Bracket
    KB_KEY_GRAVE_ACCENT   = 96,  // Grave_Accent
    KB_KEY_WORLD_1        = 161, // World_1
    KB_KEY_WORLD_2        = 162, // World_2
    KB_KEY_ESCAPE         = 256, // Escape
    KB_KEY_ENTER          = 257, // Enter
    KB_KEY_TAB            = 258, // Tab
    KB_KEY_BACKSPACE      = 259, // Backspace
    KB_KEY_INSERT         = 260, // Insert
    KB_KEY_DELETE         = 261, // Delete
    KB_KEY_RIGHT          = 262, // Right
    KB_KEY_LEFT           = 263, // Left
    KB_KEY_DOWN           = 264, // Down
    KB_KEY_UP             = 265, // Up
    KB_KEY_PAGE_UP        = 266, // Page_Up
    KB_KEY_PAGE_DOWN      = 267, // Page_Down
    KB_KEY_HOME           = 268, // Home
    KB_KEY_END            = 269, // End
    KB_KEY_CAPS_LOCK      = 280, // Caps_Lock
    KB_KEY_SCROLL_LOCK    = 281, // Scroll_Lock
    KB_KEY_NUM_LOCK       = 282, // Num_Lock
    KB_KEY_PRINT_SCREEN   = 283, // Print_Screen
    KB_KEY_PAUSE          = 284, // Pause
    KB_KEY_F1             = 290, // F1
    KB_KEY_F2             = 291, // F2
    KB_KEY_F3             = 292, // F3
    KB_KEY_F4             = 293, // F4
    KB_KEY_F5             = 294, // F5
    KB_KEY_F6             = 295, // F6
    KB_KEY_F7             = 296, // F7
    KB_KEY_F8             = 297, // F8
    KB_KEY_F9             = 298, // F9
    KB_KEY_F10            = 299, // F10
    KB_KEY_F11            = 300, // F11
    KB_KEY_F12            = 301, // F12
    KB_KEY_F13            = 302, // F13
    KB_KEY_F14            = 303, // F14
    KB_KEY_F15            = 304, // F15
    KB_KEY_F16            = 305, // F16
    KB_KEY_F17            = 306, // F17
    KB_KEY_F18            = 307, // F18
    KB_KEY_F19            = 308, // F19
    KB_KEY_F20            = 309, // F20
    KB_KEY_F21            = 310, // F21
    KB_KEY_F22            = 311, // F22
    KB_KEY_F23            = 312, // F23
    KB_KEY_F24            = 313, // F24
    KB_KEY_F25            = 314, // F25
    KB_KEY_KP_0           = 320, // KP_0
    KB_KEY_KP_1           = 321, // KP_1
    KB_KEY_KP_2           = 322, // KP_2
    KB_KEY_KP_3           = 323, // KP_3
    KB_KEY_KP_4           = 324, // KP_4
    KB_KEY_KP_5           = 325, // KP_5
    KB_KEY_KP_6           = 326, // KP_6
    KB_KEY_KP_7           = 327, // KP_7
    KB_KEY_KP_8           = 328, // KP_8
    KB_KEY_KP_9           = 329, // KP_9
    KB_KEY_KP_DECIMAL     = 330, // KP_Decimal
    KB_KEY_KP_DIVIDE      = 331, // KP_Divide
    KB_KEY_KP_MULTIPLY    = 332, // KP_Multiply
    KB_KEY_KP_SUBTRACT    = 333, // KP_Subtract
    KB_KEY_KP_ADD         = 334, // KP_Add
    KB_KEY_KP_ENTER       = 335, // KP_Enter
    KB_KEY_KP_EQUAL       = 336, // KP_Equal
    KB_KEY_LEFT_SHIFT     = 340, // Left_Shift
    KB_KEY_LEFT_CONTROL   = 341, // Left_Control
    KB_KEY_LEFT_ALT       = 342, // Left_Alt
    KB_KEY_LEFT_SUPER     = 343, // Left_Super
    KB_KEY_RIGHT_SHIFT    = 344, // Right_Shift
    KB_KEY_RIGHT_CONTROL  = 345, // Right_Control
    KB_KEY_RIGHT_ALT      = 346, // Right_Alt
    KB_KEY_RIGHT_SUPER    = 347, // Right_Super
    KB_KEY_MENU           = 348, // Menu
    KB_KEY_LAST           = KB_KEY_MENU
};

mfb_key_mod :: enum c.uint {
    KB_MOD_NONE         = 0x0000,
    KB_MOD_SHIFT        = 0x0001,
    KB_MOD_CONTROL      = 0x0002,
    KB_MOD_ALT          = 0x0004,
    KB_MOD_SUPER        = 0x0008,
    KB_MOD_CAPS_LOCK    = 0x0010,
    KB_MOD_NUM_LOCK     = 0x0020
};

mfb_window_flags :: enum c.uint {
    WF_NONE               = 0x00,
    WF_RESIZABLE          = 0x01,
    WF_FULLSCREEN         = 0x02,
    WF_FULLSCREEN_DESKTOP = 0x04,
    WF_BORDERLESS         = 0x08,
    WF_ALWAYS_ON_TOP      = 0x10,
};

// Opaque pointer
mfb_window :: struct {}
mfb_timer :: struct {}


// Event callbacks
mfb_active_func           :: proc(window: ^mfb_window, isActive: c.bool);
mfb_resize_func           :: proc(window: ^mfb_window, width: c.int, height: c.int);
mfb_close_func            :: proc(window: ^mfb_window) -> c.bool;
mfb_keyboard_func         :: proc(window: ^mfb_window, key: mfb_key, mod: mfb_key_mod, isPressed: c.bool);
mfb_char_input_func       :: proc(window: ^mfb_window, code: c.uint);
mfb_mouse_button_func     :: proc(window: ^mfb_window, button: mfb_mouse_button, mod: mfb_key_mod, isPressed: c.bool);
mfb_mouse_move_func       :: proc(window: ^mfb_window, x: c.int, y: c.int);
mfb_mouse_scroll_func     :: proc(window: ^mfb_window, mod: mfb_key_mod, deltaX: c.float, deltaY: c.float);
foreign minifb {
    // Create a window that is used to display the buffer sent into the mfb_update function, returns 0 if fails
    mfb_open        :: proc(title: cstring, width: c.uint, height: c.uint) -> ^mfb_window ---;
    mfb_open_ex     :: proc(title: cstring, width: c.uint, height: c.uint, flags: c.uint) -> ^mfb_window ---;

    // Update the display
    // Input buffer is assumed to be a 32-bit buffer of the size given in the open call
    // Will return a negative status if something went wrong or the user want to exit
    // Also updates the window events
    mfb_update        :: proc(window: ^mfb_window, buffer: rawptr) -> mfb_update_state ---;
    mfb_update_ex     :: proc(window: ^mfb_window, buffer: rawptr, width: c.uint, height: c.uint) -> mfb_update_state ---;
    // Only updates the window events
    mfb_update_events :: proc(window: ^mfb_window) -> mfb_update_state ---;

    // Close the window
    mfb_close              :: proc(window: ^mfb_window) ---;
    
    // Set user data
    mfb_set_user_data    :: proc(window: ^mfb_window, user_data: rawptr) ---;
    mfb_get_user_data    :: proc(window: ^mfb_window) -> rawptr ---;
    
    // Set viewport (useful when resize)
    mfb_set_viewport            :: proc(window: ^mfb_window, offset_x: c.uint, offset_y: c.uint, width: c.uint, height: c.uint) -> c.bool ---;
    // Let mfb to calculate the best fit from your framebuffer original size
    mfb_set_viewport_best_fit   :: proc(window: ^mfb_window, old_width: c.uint, old_height: c.uint) -> c.bool ---;
    
    // DPI
    // [Deprecated]: Probably a better name will be mfb_get_monitor_scale
    mfb_get_monitor_dpi    :: proc(window: ^mfb_window, dpi_x: ^c.float, dpi_y: ^c.float) ---;
    // Use this instead
    mfb_get_monitor_scale  :: proc(window: ^mfb_window, scale_x: ^c.float, scale_y: ^c.float) ---;

    // Show/hide cursor
    mfb_show_cursor :: proc(window: ^mfb_window, show: c.bool) ---;

    // Callbacks
    mfb_set_active_callback         :: proc(window: ^mfb_window, callback: mfb_active_func) ---;
    mfb_set_resize_callback         :: proc(window: ^mfb_window, callback: mfb_resize_func) ---;
    mfb_set_close_callback          :: proc(window: ^mfb_window, callback: mfb_close_func) ---;
    mfb_set_keyboard_callback       :: proc(window: ^mfb_window, callback: mfb_keyboard_func) ---;
    mfb_set_char_input_callback     :: proc(window: ^mfb_window, callback: mfb_char_input_func) ---;
    mfb_set_mouse_button_callback   :: proc(window: ^mfb_window, callback: mfb_mouse_button_func) ---;
    mfb_set_mouse_move_callback     :: proc(window: ^mfb_window, callback: mfb_mouse_move_func) ---;
    mfb_set_mouse_scroll_callback   :: proc(window: ^mfb_window, callback: mfb_mouse_scroll_func) ---;

    // Getters
    mfb_get_key_name  :: proc(key: mfb_key) -> cstring ---;

    mfb_is_window_active         :: proc(window: ^mfb_window) -> c.bool ---;
    mfb_get_window_width         :: proc(window: ^mfb_window) -> c.uint ---;
    mfb_get_window_height        :: proc(window: ^mfb_window) -> c.uint ---;
    mfb_get_mouse_x              :: proc(window: ^mfb_window) -> c.int ---;             // Last mouse pos X
    mfb_get_mouse_y              :: proc(window: ^mfb_window) -> c.int ---;             // Last mouse pos Y
    mfb_get_mouse_scroll_x       :: proc(window: ^mfb_window) -> c.float ---;      // Mouse wheel X as a sum. When you call this function it resets.
    mfb_get_mouse_scroll_y       :: proc(window: ^mfb_window) -> c.float ---;      // Mouse wheel Y as a sum. When you call this function it resets.
    mfb_get_mouse_button_buffer  :: proc(window: ^mfb_window) -> ^c.uint8_t ---; // One byte for every button. Press (1), Release 0. (up to 8 buttons)
    mfb_get_key_buffer           :: proc(window: ^mfb_window) -> ^c.uint8_t ---;          // One byte for every key. Press (1), Release 0.

    // FPS
    mfb_set_target_fps  :: proc(fps: c.uint32_t) ---;
    mfb_get_target_fps  :: proc() -> c.uint ---;
    mfb_wait_sync       :: proc(window: ^mfb_window) -> c.bool ---;

    // Timer
    mfb_timer_create             :: proc() -> ^mfb_timer ---;
    mfb_timer_destroy            :: proc(tmr: ^mfb_timer) ---;
    mfb_timer_reset              :: proc(tmr: ^mfb_timer) ---;
    mfb_timer_compensated_reset  :: proc(tmr: ^mfb_timer) ---;
    mfb_timer_now                :: proc(tmr: ^mfb_timer) -> c.double ---;
    mfb_timer_delta              :: proc(tmr: ^mfb_timer) -> c.double ---;
    mfb_timer_get_frequency      :: proc() -> c.double ---;
    mfb_timer_get_resolution     :: proc() -> c.double ---;

}
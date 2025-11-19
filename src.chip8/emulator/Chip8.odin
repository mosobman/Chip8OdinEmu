package emulator

import "core:math/rand"
import "core:fmt"
import audio "../audio"
import ma "vendor:miniaudio"

DISPLAY :: [2]uint{64, 32}
SCALE :: 13
RESOLUTION :: [2]uint{DISPLAY.x*SCALE, DISPLAY.y*SCALE}
ROM :: "roms/chip8/Tetris.ch8"
START_ADDRESS :: 0x200;
FONTSET_START_ADDRESS :: 0x50;
CYCLE_RATE :: 32
RAM_SIZE :: 4096

XY :: bit_field u8 {
	x: u8 | 4,
	y: u8 | 4
}

waiting := -1
Emulator :: struct {
	registers : [16]u8,
	memory  : [RAM_SIZE]u8,
	index : u16,
	pc : u16,
	stack : [16]u16,
	sp : u8,
	delayTimer : u8,
	soundTimer : u8,
	keyPad : [16]bool,
	display : [DISPLAY.x*DISPLAY.y]u8,
	display_screen : [RESOLUTION.x*RESOLUTION.y]u32,
	displayUpdate  : bool,
	deltaTime : f64,
	opcode : u16,
	
	xy: XY,
	kk : u8,
	nnn : u16,

	tone: ^audio.ToneState,
	device: ^ma.device
}

rgb :: proc(r: u8, g: u8, b: u8) -> u32{
	r_ :u32= u32(r)
	g_ :u32= u32(g)
	b_ :u32= u32(b)
	return (r_ << 16) | (g_ << 8) | (b_)
}
rgb_grey :: proc(val: u8) -> u32 {
	return rgb(val,val,val)
}

refresh :: proc(emu: ^Emulator) {
	for X in 0..<DISPLAY.x {
		for Y in 0..<DISPLAY.y {
			for x in X*SCALE..<X*SCALE+SCALE {
				for y in Y*SCALE..<Y*SCALE+SCALE {
					emu.display_screen[x + y*RESOLUTION.x] = rgb_grey(emu.display[X + Y*DISPLAY.x])
				}
			}
		}
	}
	emu.displayUpdate = false;
}

random_byte :: proc() -> u8 {
	return u8(rand.uint32() & 0xFF)
}

makeEmulator :: proc() -> ^Emulator {
	emu := new(Emulator)
	// 32-bit RGBA or BGRA depending on your choice; miniFB accepts either (ARGB)
	for x in 0..<DISPLAY.x {
		for y in 0..<DISPLAY.y {
			emu.display[x + y*DISPLAY.x] = 0; //random_byte()
		}
	}
	emu.displayUpdate = true;
	emu.tone = new(audio.ToneState)
	emu.device = audio.startAudioThread(emu.tone)

	emu.pc = START_ADDRESS

	fmt.println();
	loadFont(emu);
	loadRom(emu, ROM);
	fmt.println();

	return emu;
}
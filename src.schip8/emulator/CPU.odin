package emulator

import "core:fmt"
import "core:os"
import audio "../audio"


update :: proc(emu: ^Emulator) {
	if (waiting != -1) {
      if (emu.keyPad[waiting] == false) do waiting = -1;
    }
	if waiting == -1 do fde(emu)
	if emu.delayTimer > 0 do emu.delayTimer-=1
	if emu.soundTimer > 0 do emu.soundTimer-=1
}

fde :: proc(emu: ^Emulator) {
	for c in 0..<CYCLE_RATE {
		if waiting!=-1 do continue
		ok := cycle(emu)
		assert(ok, fmt.aprintf("Unknown instruction (%04x)", emu.opcode))
		if (emu.soundTimer > 0) {
			audio.unmuteAudio(emu.tone);
		} else {
			audio.muteAudio(emu.tone);
		}
	}
}
read_byte :: proc(memory: ^[RAM_SIZE]u8, i: u16) -> u8 {
	return memory[i]
}
read_short :: proc(memory: ^[RAM_SIZE]u8, i: u16) -> u16 {
	return (u16(memory[i]) << 8) | u16(memory[i+1])
}
cycle :: proc(emu: ^Emulator) -> bool {
	emu.opcode = read_short(&emu.memory, emu.pc)
	//fmt.printfln("PC: %04x : CIR : %04x", emu.pc, emu.opcode)
	emu.xy.x = u8((emu.opcode & 0x0F00) >> 8)
	emu.xy.y = u8((emu.opcode & 0x00F0) >> 4)
	emu.kk   = u8( emu.opcode & 0x00FF      )
	emu.nnn  = u16(emu.opcode & 0x0FFF      )

	emu.pc += 2

	a := u8((emu.opcode & 0xF000) >> 12)
	b := emu.xy.x
	c := emu.xy.y
	d := u8( emu.opcode & 0x000F       )

	failed := false

	switch a {
		case 0x1: OP_1nnn(emu)
		case 0x2: OP_2nnn(emu)
		case 0x3: OP_3xkk(emu)
		case 0x4: OP_4xkk(emu)
		case 0x5: OP_5xy0(emu)
		case 0x6: OP_6xkk(emu)
		case 0x7: OP_7xkk(emu)
		case 0x9: OP_9xy0(emu)
		case 0xA: OP_Annn(emu)
		case 0xB: OP_Bnnn(emu)
		case 0xC: OP_Cxkk(emu)
		case 0xD: OP_Dxyn(emu)
		case (0x8): {
			if (d == 0x0)      do OP_8xy0(emu)
			else if (d == 0x1) do OP_8xy1(emu)
			else if (d == 0x2) do OP_8xy2(emu)
			else if (d == 0x3) do OP_8xy3(emu)
			else if (d == 0x4) do OP_8xy4(emu)
			else if (d == 0x5) do OP_8xy5(emu)
			else if (d == 0x6) do OP_8xy6(emu)
			else if (d == 0x7) do OP_8xy7(emu)
			else if (d == 0xE) do OP_8xyE(emu)
			else do failed = true
		}

		case (0x0): {
			if (b == 0x0 && c == 0xE && d == 0x0)      do OP_00E0(emu)
			else if (b == 0x0 && c == 0xE && d == 0xE) do OP_00EE(emu)
			else do failed = true
		}

		case (0xE): {
			if (c == 0xA && d == 0x1)      do OP_ExA1(emu)
			else if (c == 0x9 && d == 0xE) do OP_Ex9E(emu)
			else do failed = true
		}
		case (0xF): {
			if (c == 0x0 && d == 0xA)      do OP_Fx0A(emu)
			else if (c == 0x0 && d == 0x7) do OP_Fx07(emu)
			else if (c == 0x1 && d == 0x5) do OP_Fx15(emu)
			else if (c == 0x1 && d == 0x8) do OP_Fx18(emu)
			else if (c == 0x1 && d == 0xE) do OP_Fx1E(emu)
			else if (c == 0x2 && d == 0x9) do OP_Fx29(emu)
			else if (c == 0x3 && d == 0x3) do OP_Fx33(emu)
			else if (c == 0x5 && d == 0x5) do OP_Fx55(emu)
			else if (c == 0x6 && d == 0x5) do OP_Fx65(emu)
			else do failed = true
		}
		case: failed = true
	}
	
	if (failed == true) {
		failed = false
		if (a == 0x0 && b == 0x0 && c == 0xC) do OP_00Cn(emu);
		else if (a == 0x0 && b == 0x0 && c == 0xF && d == 0xB) do OP_00FB(emu);
		else if (a == 0x0 && b == 0x0 && c == 0xF && d == 0xC) do OP_00FC(emu);
		else if (a == 0x0 && b == 0x0 && c == 0xF && d == 0xD) { fmt.println("HALTING"); failed = true }
		else if (a == 0x0 && b == 0x0 && c == 0xF && d == 0xE) do OP_00FE(emu);
		else if (a == 0x0 && b == 0x0 && c == 0xF && d == 0xF) do OP_00FF(emu);
		else if (a == 0xF && c == 0x3 && d == 0x0) do OP_Fx30(emu);
		else if (a == 0xF && c == 0x7 && d == 0x5) do OP_Fx75(emu);
		else if (a == 0xF && c == 0x8 && d == 0x5) do OP_Fx85(emu);
		else do failed = true
	}

	return !failed;
}

loadRom :: proc(emu: ^Emulator, romfile: string) {
	fmt.printfln("[~] Reading ROM file : '%s'", romfile)
	
	data, ok := os.read_entire_file(romfile, context.allocator)
	if !ok {
		fmt.println("@@ RECEIVED FILE ERROR @@")
		return
	}
	defer delete(data, context.allocator)

	for i in 0..<len(data) {
		emu.memory[START_ADDRESS+i] = data[i]
	}
	fmt.printfln("[+] Loaded %d byte rom file\n", len(data))
}


loadFont :: proc(emu: ^Emulator) {
	fmt.println("[~] Loading font data")

	for i in 0..<len(FONTSET) {
		emu.memory[FONTSET_START_ADDRESS+i] = FONTSET[i]
	}
	for i in 0..<len(HIRES_FONTSET) {
		emu.memory[HIRES_FONTSET_START_ADDRESS+i] = HIRES_FONTSET[i]
	}

	fmt.printfln("[+] Loaded %d bytes of font data\n", len(FONTSET)+len(HIRES_FONTSET))
}

FONTSET := [5*16]u8{ // byte
    0x60, 0xB0, 0xD0, 0x90, 0x60, // 0
    0x20, 0x60, 0x20, 0x20, 0x20, // 1
    0x60, 0x90, 0x20, 0x40, 0xF0, // 2
    0xE0, 0x10, 0x60, 0x10, 0xE0, // 3
    0x90, 0x90, 0xF0, 0x10, 0x10, // 4
    0xF0, 0x80, 0xE0, 0x10, 0xE0, // 5
    0x60, 0x80, 0xE0, 0x90, 0x60, // 6
    0xF0, 0x10, 0x20, 0x20, 0x20, // 7
    0x60, 0x90, 0x60, 0x90, 0x60, // 8
    0x60, 0x90, 0x70, 0x10, 0x60, // 9
    0x60, 0x90, 0xF0, 0x90, 0x90, // A
    0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
    0x60, 0x90, 0x80, 0x90, 0x60, // C
    0xE0, 0x90, 0x90, 0x90, 0xE0, // D
    0xF0, 0x80, 0xE0, 0x80, 0xF0, // E
    0xF0, 0x80, 0xE0, 0x80, 0x80  // F
};
HIRES_FONTSET := [10*1]u8 {
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

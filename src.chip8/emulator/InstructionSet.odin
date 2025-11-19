package emulator

import "base:runtime"

OP_00E0 :: proc(emu: ^Emulator) { // CLS
	runtime.memset(&emu.display[0], 0, len(emu.display));
}
OP_00EE :: proc(emu: ^Emulator) { // RET
	emu.sp -= 1;
	emu.pc = emu.stack[emu.sp];
}
OP_1nnn :: proc(emu: ^Emulator) { // JP nnn
	emu.pc = emu.nnn;
}
OP_2nnn :: proc(emu: ^Emulator) { // CALL nnn
	emu.stack[emu.sp] = emu.pc
	emu.sp += 1
	emu.pc = emu.nnn;
}
OP_3xkk :: proc(emu: ^Emulator) { // SE x, kk
	if (emu.registers[emu.xy.x] == emu.kk) {
	emu.pc += 2;
	}
}
OP_4xkk :: proc(emu: ^Emulator) { // SNE x, kk
	if (emu.registers[emu.xy.x] != emu.kk) {
	emu.pc += 2;
	}
}
OP_5xy0 :: proc(emu: ^Emulator) { // SE x, Vy
	if (emu.registers[emu.xy.x] == emu.registers[emu.xy.y]) {
	emu.pc += 2;
	}
}
OP_6xkk :: proc(emu: ^Emulator) { // LD x, kk
	emu.registers[emu.xy.x] = emu.kk;
}
OP_7xkk :: proc(emu: ^Emulator) { // ADD x, kk
	emu.registers[emu.xy.x] = (emu.registers[emu.xy.x]+emu.kk) & 0xFF;
}
OP_8xy0 :: proc(emu: ^Emulator) { // LD x, Vy
	emu.registers[emu.xy.x] = emu.registers[emu.xy.y];
}
OP_8xy1 :: proc(emu: ^Emulator) { // OR Vx, Vy
	emu.registers[emu.xy.x] |= emu.registers[emu.xy.y];
	emu.registers[0xF] = 0
}
OP_8xy2 :: proc(emu: ^Emulator) { // AND Vx, Vy
	emu.registers[emu.xy.x] &= emu.registers[emu.xy.y];
	emu.registers[0xF] = 0
}
OP_8xy3 :: proc(emu: ^Emulator) { // XOR Vx, Vy
	emu.registers[emu.xy.x] ~= emu.registers[emu.xy.y];
	emu.registers[0xF] = 0
}
OP_8xy4 :: proc(emu: ^Emulator) { // ADDc Vx, Vy
	sum := u16(emu.registers[emu.xy.x]) + u16(emu.registers[emu.xy.y]);
	emu.registers[emu.xy.x] = u8(sum & 0xFF);
	
	if (sum > 255) {
		emu.registers[0xF] = 1;
	} else {
		emu.registers[0xF] = 0;
	}
}
OP_8xy5 :: proc(emu: ^Emulator) { // SUBb Vx, Vy
	bol := emu.registers[emu.xy.x] >= emu.registers[emu.xy.y];
	emu.registers[emu.xy.x] = (emu.registers[emu.xy.x]-emu.registers[emu.xy.y]) & 0xFF;
	if (bol) do emu.registers[0xF] = 1;
	else do emu.registers[0xF] = 0;
}
OP_8xy6 :: proc(emu: ^Emulator) { // SHRl Vx
	flag := (emu.registers[emu.xy.x] & 0x1);
	emu.registers[emu.xy.x] = (emu.registers[emu.xy.x]>>1) & 0xFF;
	emu.registers[0xF] = flag;
}
OP_8xy7 :: proc(emu: ^Emulator) { // SUBNb Vx, Vy
	bol := emu.registers[emu.xy.y] >= emu.registers[emu.xy.x];
	emu.registers[emu.xy.x] = (emu.registers[emu.xy.y] - emu.registers[emu.xy.x]) & 0xFF;
	if (bol) do emu.registers[0xF] = 1;
	else do emu.registers[0xF] = 0;
}
OP_8xyE :: proc(emu: ^Emulator) { // SHL Vx
	flag := (emu.registers[emu.xy.x] & 0x80) >> 7;
	emu.registers[emu.xy.x] = (emu.registers[emu.xy.x]<<1) & 0xFF;
	emu.registers[0xF] = flag;
}
OP_9xy0 :: proc(emu: ^Emulator) { // SNE Vx, Vy
	if (emu.registers[emu.xy.x] != emu.registers[emu.xy.y]) {
		emu.pc += 2;
	}
}
OP_Annn :: proc(emu: ^Emulator) { // LD I, nnn
	emu.index = emu.nnn;
}
OP_Bnnn :: proc(emu: ^Emulator) { // JP V0, nnn
	emu.pc = (u16(emu.registers[0]) + emu.nnn) & 0xFFF;
	//emu.pc = (emu.registers[emu.xy.x] + nnn) & 0xFFF;
}
OP_Cxkk :: proc(emu: ^Emulator) { // RND Vx, kk
	emu.registers[emu.xy.x] = random_byte() & emu.kk;
}
OP_Dxyn :: proc(emu: ^Emulator) { // DRW Vx, Vy, n
	height := u16(emu.opcode&0xF);
	
	xPos := u16(emu.registers[emu.xy.x] % u8(DISPLAY.x));
	yPos := u16(emu.registers[emu.xy.y] % u8(DISPLAY.y));

	emu.registers[0xF] = 0;

	for row in 0..<height {
		spriteByte := emu.memory[emu.index + row] & 0xFF;

		for col in 0..<u16(8) {
			spritePixel := (spriteByte & (0x80 >> col)) & 0xFF;
			screenPixelIndex := ((yPos+row) % u16(DISPLAY.y))*u16(DISPLAY.x) + ((xPos+col) % u16(DISPLAY.x));

			if (spritePixel > 0) {
				if (emu.display[screenPixelIndex] == 0xFF) {
					emu.registers[0xF] = 1;
				}

				emu.display[screenPixelIndex] ~= 0xFF;
				if (!emu.displayUpdate) do emu.displayUpdate = true;
			}
		}
	}
}
OP_Ex9E :: proc(emu: ^Emulator) {
	key := emu.registers[emu.xy.x];
	if (emu.keyPad[key] != false) {
		emu.pc += 2;
	}
}
OP_ExA1 :: proc(emu: ^Emulator) {
	key := emu.registers[emu.xy.x] & 0xF;
	if (emu.keyPad[key] == false) {
		emu.pc += 2;
	}
}
OP_Fx07 :: proc(emu: ^Emulator) {
	emu.registers[emu.xy.x] = emu.delayTimer;
}

OP_Fx0A :: proc(emu: ^Emulator) {
	if (emu.keyPad[0] != false) {
		emu.registers[emu.xy.x] = 0; waiting = 0;
	} else if (emu.keyPad[1] != false) {
		emu.registers[emu.xy.x] = 1; waiting = 1;
	} else if (emu.keyPad[2] != false) {
		emu.registers[emu.xy.x] = 2; waiting = 2;
	} else if (emu.keyPad[3] != false) {
		emu.registers[emu.xy.x] = 3; waiting = 3;
	} else if (emu.keyPad[4] != false) {
		emu.registers[emu.xy.x] = 4; waiting = 4;
	} else if (emu.keyPad[5] != false) {
		emu.registers[emu.xy.x] = 5; waiting = 5;
	} else if (emu.keyPad[6] != false) {
		emu.registers[emu.xy.x] = 6; waiting = 6;
	} else if (emu.keyPad[7] != false) {
		emu.registers[emu.xy.x] = 7; waiting = 7;
	} else if (emu.keyPad[8] != false) {
		emu.registers[emu.xy.x] = 8; waiting = 8;
	} else if (emu.keyPad[9] != false) {
		emu.registers[emu.xy.x] = 9; waiting = 9;
	} else if (emu.keyPad[10] != false) {
		emu.registers[emu.xy.x] = 10; waiting = 10;
	} else if (emu.keyPad[11] != false) {
		emu.registers[emu.xy.x] = 11; waiting = 11;
	} else if (emu.keyPad[12] != false) {
		emu.registers[emu.xy.x] = 12; waiting = 12;
	} else if (emu.keyPad[13] != false) {
		emu.registers[emu.xy.x] = 13; waiting = 13;
	} else if (emu.keyPad[14] != false) {
		emu.registers[emu.xy.x] = 14; waiting = 14;
	} else if (emu.keyPad[15] != false) {
		emu.registers[emu.xy.x] = 15; waiting = 15;
	} else {
		emu.pc -= 2;
	}
}
OP_Fx15 :: proc(emu: ^Emulator) {
	emu.delayTimer = (byte) (emu.registers[emu.xy.x] & 0xFF);
}
OP_Fx18 :: proc(emu: ^Emulator) {
	emu.soundTimer = (byte) (emu.registers[emu.xy.x] & 0xFF);
}
OP_Fx1E :: proc(emu: ^Emulator) {
	emu.index += u16(emu.registers[emu.xy.x] & 0xFF);
}
OP_Fx29 :: proc(emu: ^Emulator) {
	digit := u16(emu.registers[emu.xy.x] & 0xFF);
	emu.index = (FONTSET_START_ADDRESS + (5*digit)) & 0xFFFF;
}
OP_Fx33 :: proc(emu: ^Emulator) {
	value := emu.registers[emu.xy.x] & 0xFF;

	// Ones-place
	emu.memory[emu.index + 2] = value % 10;
	value /= 10;

	// Tens-place
	emu.memory[emu.index + 1] = value % 10;
	value /= 10;

	// Hundreds-place
	emu.memory[emu.index] = value % 10;
}
OP_Fx55 :: proc(emu: ^Emulator) {
	for i in 0..=emu.xy.x {
		emu.memory[emu.index] = emu.registers[i];
		emu.index += 1
	}
	if (emu.xy.x > 0) do emu.index -= 1
}
OP_Fx65 :: proc(emu: ^Emulator) {
	for i in 0..=u16(emu.xy.x) {
		emu.registers[i] = emu.memory[emu.index];
		emu.index += 1
	}
	if (emu.xy.x > 0) do emu.index -= 1
}
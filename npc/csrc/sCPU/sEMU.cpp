#include <stdint.h>
uint8_t PC = 0;
uint8_t R[4]= {0};
uint8_t M[256] ={
		0x8A, // 0: li r0, 10
    0x90, // 1: li r1, 0
    0xA0, // 2: li r2, 0
    0xB1, // 3: li r3, 1
    0x17, // 4: add r1, r1, r3
    0x29, // 5: add r2, r2, r1
    0xD1, // 6: bner0 r1, 4
		0xDF // 7: bner0 r3 7
};

void ref_reset(){
	PC = 0;
	for(int i = 0; i < 4; i++){
		R[i] = 0;
	}
}

uint8_t* ref_get_regs(){
	return R;
}

uint8_t ref_get_PC(){
	return PC;
}

void ref_inst_cycle(){
	uint8_t instr = M[PC];
	uint8_t opcode = (instr >> 6) & 0x03;
	switch(opcode){
		case 0b00: {
			uint8_t rd = (instr >> 4) & 0x03;
			uint8_t rs1 = (instr >> 2) & 0x03;
			uint8_t rs2 = instr & 0x03;
			R[rd] = R[rs1] + R[rs2];
			PC++;
			break;
							 }
		case 0b10:
								{
			uint8_t rd = (instr >> 4) & 0x03;
			uint8_t imm = instr & 0x0F;
			R[rd] = imm;
			PC++;
			break;	
							}
		case 0b11: {
			uint8_t rs2 = instr & 0x03;
			uint8_t addr = (instr >> 2) & 0x0F;
			if(R[rs2] != R[0]){
				PC = addr;
			}
			else {PC++;}
			break;
							 }
		default:{
						PC++;
						break;
						}
	}
}




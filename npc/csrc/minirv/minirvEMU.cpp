#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include "minirvEMU.h"

extern uint32_t uart_status;
extern uint32_t timer_lo;
extern uint32_t timer_hi;
uint32_t pc = MEMBASE;
uint32_t R[32] = {0};
uint32_t M[WORD_COUNT];


void ref_reset(){
	pc = MEMBASE;
	for(int i = 0; i < 32; i++){
		R[i] = 0;
	}
}


bool ref_inst_cycle(){
	uint32_t instr = M[(pc - MEMBASE) >> 2];
	uint32_t opcode = instr & 0x7F;
	uint32_t funct  = (instr >> 12) & 0x07;
	
	bool is_addi = (funct == 0) && (opcode == 19) ? true : false;
	bool is_jalr = (funct == 0) && (opcode == 103) ? true : false;
	bool is_add = (funct == 0) && (opcode == 51) ? true : false;
	bool is_lui = (opcode ==	55) ? true : false;
	bool is_lw = (funct == 2) && (opcode == 3) ? true : false;
	bool is_lbu = (funct == 4) && (opcode == 3) ? true : false; 
	bool is_sw = (funct == 2) && (opcode == 35) ? true : false;
	bool is_sb = (funct == 0) && (opcode == 35) ? true : false;
	if(instr == 0x00100073){
		printf("Ebreak detected, exiting the program\n");
		return false;
	}
	if(is_addi){
		uint32_t rd = (instr >> 7) & 0x1f;
		uint32_t rs1 = (instr >> 15) & 0x1F;
		int32_t imm = ((int32_t)instr) >> 20;
		if(rd != 0){
			R[rd] = R[rs1] + imm;
		}
		pc += 4;
	}
	else if(is_jalr){
		uint32_t rd = (instr >> 7) & 0x1F;
		uint32_t rs1 = (instr >> 15) & 0x1F;
		int32_t imm = ((int32_t)instr) >> 20;
		uint32_t target = (R[rs1] + imm) & 0xFFFFFFFE;
		if(rd != 0){
			R[rd] = pc + 4;
		}
		pc = target;
	}
	else if(is_add){
		uint32_t rd = (instr >> 7) & 0x1F;
		uint32_t rs1 = (instr >> 15) & 0x1F;
		uint32_t rs2 = instr >> 20 & 0x1F;
		if(rd != 0){
			R[rd] = R[rs1] + R[rs2];
		}
		pc += 4;
	}
	else if(is_lui){
		uint32_t rd = (instr >> 7) & 0x1F;
		uint32_t imm = instr & 0xFFFFF000;
		if(rd != 0){
			R[rd] = imm;
		}
		pc += 4;
	}
	else if(is_lw){
		uint32_t rd = instr >> 7 & 0x1F;
		uint32_t rs1 = instr >> 15 & 0x1F;
		int32_t imm = ((int32_t)instr) >> 20;
		uint32_t addr = R[rs1] + imm;
		uint32_t data;
		if(addr == 0x10000004) data = uart_status;
		else if(addr == 0x20000000) data = timer_lo;
		else if(addr == 0x20000004) data = timer_hi;
		else data = M[(addr - MEMBASE) >> 2];
		if(rd != 0){
			R[rd] = data;
		}

		pc+= 4;
	}
	else if(is_lbu){
		uint32_t rd = instr >> 7 & 0x1F;
		uint32_t rs1 = instr >> 15 & 0x1F;
		int32_t imm = ((int32_t)instr) >> 20;
		uint32_t addr = R[rs1] + imm;
		uint32_t data = (addr == 0x10000004) ? uart_status : M[(addr - MEMBASE) >> 2];
		uint8_t byte = (data  >> ((addr & 0x3) * 8)) & 0xFF;	
		if(rd != 0){
			R[rd] = byte;
		}

		pc += 4;
	}
	else if(is_sw){
		uint32_t rs1 = instr >> 15 & 0x1F;
		uint32_t rs2 = instr >> 20 & 0x1F;
		int32_t imm = (((int32_t)(instr & 0xFE000000)) >> 20) | ((instr >> 7) & 0x1F);
		uint32_t addr = R[rs1] + imm;
		if(addr != 0x10000000){
			M[(addr - MEMBASE) >> 2] = R[rs2];
		}

		pc += 4;
	}
	else if(is_sb){
		uint32_t rs1 = instr >> 15 & 0x1F;
		int32_t rs2 = instr >> 20 & 0x1F;                                            
		int32_t imm = (((int32_t)(instr & 0xFE000000)) >> 20) | ((instr >> 7) & 0x1F);
		uint32_t addr =	R[rs1] + imm;	
		if(addr != 0x10000000){
			uint8_t byte = R[rs2] & 0xFF;
			uint32_t shift = (addr & 0x3) * 8;
			uint32_t word = (addr - MEMBASE) >> 2;	
			M[word] = (M[word]	& ~(0xFFu << shift)) | ((uint32_t)byte << shift);		
		}

		pc += 4;
	}
	else{
		pc += 4;
	}

	return true;
}


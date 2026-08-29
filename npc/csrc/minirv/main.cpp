#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <Vsim_top.h>
#include <unistd.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include <Vsim_top___024root.h>
#include "svdpi.h"
#include "minirvEMU.h"
#include <sys/time.h>

Vsim_top* top = NULL;
//VerilatedVcdC* tfp = NULL;

uint32_t pmem[WORD_COUNT];
uint64_t main_time = 0;
bool sim_exit = false;
uint32_t uart_status = 0;
uint64_t cycle_count = 0, instr_count = 0;
uint32_t timer_lo = 0, timer_hi = 0;

uint64_t get_time(){
	return cycle_count / 287;
}


extern "C" int pmem_read(int addr){
	
	if ((uint32_t)addr == 0x10000004) {
		uart_status = (rand() & 0x7) == 0 ? 1 : 0; // read UART status
		return uart_status;
  }
	else if (addr == 0x20000000)
 	{
			uint64_t t = get_time();
			timer_lo = t & 0xffffffff;
			timer_hi = t >> 32;			
			return timer_lo;
	}
  else if (addr == 0x20000004) { return timer_hi; }

	uint32_t relative_addr = ((uint32_t)addr - MEMBASE) >> 2;
	if(relative_addr >= WORD_COUNT){
		printf("accessing pmem out of bounds: addr = 0x%08x\n", addr);
		return 0;
	}
	return pmem[relative_addr];
}

extern "C" void pmem_write(int addr, int data, uint8_t mask){
	if (addr == 0x10000000) {  // write to UART
    fputc(data & 0xff, stderr);   // defined in stdio.h
    return;
  }
	
	uint32_t relative_addr = ((uint32_t)addr - MEMBASE) >> 2; 
	if(relative_addr >= WORD_COUNT) {
		printf("accessing pmem out of bounds: addr = 0x%08x\n", addr);
		return;
	}
	uint8_t* byte = (uint8_t*)&pmem[relative_addr];
	for(int i = 0; i < 4; i++){
		if(mask & (1 << i)){
			byte[i] = (data >> (i * 8)) & 0xFF;
		}
	}
}


void single_cycle() {
	cycle_count++;
	top->clk = 0;
	top->eval();
//	tfp->dump(main_time++);
	
	bool is_ebreak = top->ebreak;	
	top->clk = 1;
	top->eval();

//	tfp->dump(main_time++);
//	tfp->flush();
//
	if(is_ebreak) sim_exit = true;
}

void reset(int n) {
	top->rst = 1;
	while (n-- > 0){
		single_cycle();
	}
	ref_reset();
	top->rst = 0;
}

void load_program(const char* program_file){
	if(!program_file) return;
	FILE *fp = fopen(program_file, "rb");
	assert(fp && "Failed to open binary program file");
	fseek(fp, 0, SEEK_END);
	long size = ftell(fp);
	assert(size <= MEMSIZE && "program is >128MB");
	
	fseek(fp, 0, SEEK_SET);
	fread(M, size, 1, fp);
	fseek(fp, 0, SEEK_SET);
	fread(pmem, size, 1, fp);
	fclose(fp);
	printf("File successfully loaded\n");
}

bool check_regs(const uint32_t* ref_regs, const uint32_t* dut_gpr){
	if (!dut_gpr) {
			printf("Error: dut_gpr pointer is NULL!\n");
		return true;
	}

	for(int i = 0; i < 32; i++){
		if(ref_regs[i] != dut_gpr[i]){
			printf("Register value at %d is not equal | REF: %x | DUT: %x\n", i, ref_regs[i], dut_gpr[i]);
			return true;
		}
	}
	return false;
}


int main(int argc, char** argv) {
	Verilated::commandArgs(argc, argv);
	if(argc > 1){
		load_program(argv[1]);
	}

	//Verilated::traceEverOn(true);
	top = new Vsim_top;
	//tfp = new VerilatedVcdC;
	const uint32_t* dut_gpr = top->rootp->sim_top__DOT__cpu__DOT__rf.data();
	//top->trace(tfp, 99);	
	//tfp->open("sim_dump.vcd");
	reset(10);
	while (!sim_exit) {
		bool check = top->is_valid;
		single_cycle();
		if(check){
			instr_count++;
			if(!ref_inst_cycle()) break;
			if(check_regs(R, dut_gpr) || pc != top->pc){
				printf("Difftest failed, PC_ref = %x | PC_dut = %x\n", pc, top->pc);
				sim_exit = true;
				return 1;
			}
		}
	}
	if (top->a0 == 0) {
		printf("\033[1;32mHIT GOOD TRAP\033[0m\n");
	} 
	else 
	{
		printf("\033[1;31mHIT BAD TRAP (code = %d)\033[0m\n", top->a0);
	}	
	
		printf("cycles = %lu, instructions = %lu, IPC = %.3f\n", 
				cycle_count, instr_count, (double)instr_count / (double)cycle_count);

	int return_code = top->a0 == 0 ? 0 : 1;
	delete top;
	//tfp->close();
	return return_code;
}


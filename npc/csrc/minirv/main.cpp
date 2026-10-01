#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <unistd.h>
#include <verilated.h>
#include "verilated_fst_c.h"
#include "svdpi.h"
#include "minirvEMU.h"
#include <sys/time.h>

#ifdef SOC
#include <VSimTop.h>
#include <VSimTop___024root.h>
#include <nvboard.h>
typedef VSimTop VTop;
#define CPU_(x) top->rootp->SimTop__DOT__asic__DOT__soc__DOT__cpu__DOT__core0__DOT__##x
void nvboard_bind_all_pins(VSimTop* top);
#else
#include <Vsim_top.h>
#include <Vsim_top___024root.h>
typedef Vsim_top VTop;
#define CPU_(x) top->rootp->sim_top__DOT__cpu__DOT__##x
#endif

#define K 4
VTop* top = NULL;
VerilatedFstC* tfp = NULL;
bool tracing = true;

uint32_t pmem[WORD_COUNT];
uint32_t flashmem[4194304];
uint64_t main_time = 0;
bool sim_exit = false;
uint32_t uart_status = 0;
uint64_t cycle_count = 0, instr_count = 0;
uint32_t timer_lo = 0, timer_hi = 0;

uint64_t get_time(){
	return cycle_count / 113;
}

extern "C" void flash_read(int32_t addr, int32_t* data){
	*data = flashmem[(uint32_t)addr >> 2];	
}

extern "C" int pmem_read(int addr){
	
	if (((uint32_t)addr & 0xfffff000) == 0x10000000) {
		return ((uint32_t)addr & 7) == 5 ? (0x60u << ((addr & 3) * 8)) : 0;
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
	if (((uint32_t)addr & 0xfffff000) == 0x10000000) {
		static uint8_t lcr = 0x03;
		uint8_t byte = ((uint32_t)data >> ((addr & 3) * 8)) & 0xff;
		if ((addr & 7) == 3) lcr = byte;
		else if ((addr & 7) == 0 && !(lcr & 0x80)) fputc(byte, stderr);
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

static uint64_t half_idx = 0;

static void half_cycle(int cpu_level) {
	#ifdef SOC
		top->cpuClock = cpu_level;
		top->clock = ((half_idx + 2*K - 1) % (2*K)) < K;
	#else
		top->clock = cpu_level;
	#endif
	top->eval();
	if(tracing) tfp->dump(main_time);
	main_time++;
	half_idx++;
}

void single_cycle() {
	cycle_count++;
	half_cycle(0);
	bool is_ebreak = CPU_(ebreak);
	half_cycle(1);
	#ifdef SOC
		nvboard_update();
	#endif
	if(is_ebreak) sim_exit = true;
}

void reset(int n) {
	top->reset = 1;
	while (n-- > 0){
		single_cycle();
	}
	ref_reset();
	top->reset = 0;
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
	fseek(fp, 0, SEEK_SET);
	fread(flashmem, size, 1, fp);
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

	Verilated::traceEverOn(true);
	top = new VTop;
	#ifdef SOC
		nvboard_bind_all_pins(top);
		nvboard_init();
	#endif
	tfp = new VerilatedFstC;
	const uint32_t* dut_gpr = CPU_(rf).data();
	top->trace(tfp, 99);	
	tfp->open("sim_dump.fst");
	#ifdef SOC
		reset(100 * K);
	#else
		reset(10);
	#endif
	while (!sim_exit) {
		bool check = CPU_(is_valid);
		single_cycle();
		if(check){
			instr_count++;
			if(instr_count == 100){
				tfp->close();
			}
		#ifndef SOC
			if(!ref_inst_cycle()) break;
			if(check_regs(R, dut_gpr) || pc != CPU_(pc)){
				printf("Difftest failed, PC_ref = %x | PC_dut = %x\n", pc, CPU_(pc));
				sim_exit = true;
				return 1;
			}
		#endif
		}
	}
	if (CPU_(a0) == 0) {
		printf("\033[1;32mHIT GOOD TRAP\033[0m\n");
	} 
	else 
	{
		printf("\033[1;31mHIT BAD TRAP (code = %d)\033[0m\n", CPU_(a0));
	}	
	
		printf("cycles = %lu, instructions = %lu, IPC = %.3f\n", 
				cycle_count, instr_count, (double)instr_count / (double)cycle_count);

	int return_code = CPU_(a0) == 0 ? 0 : 1;
	delete top;
	return return_code;
}


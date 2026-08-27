#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <Vminirv.h>
#include <unistd.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#define MEMBASE 0x80000000
#define	WORD_COUNT 33554432
#define MEMSIZE (WORD_COUNT * 4)

Vminirv* top = NULL;
VerilatedVcdC* tfp = NULL;

uint32_t pmem[WORD_COUNT];
uint64_t main_time = 0;
bool sim_exit = false;

extern "C" int pmem_read(int addr){
	uint32_t relative_addr = ((uint32_t)addr - MEMBASE) >> 2;
	if(relative_addr >= WORD_COUNT){
		printf("accessing pmem out of bounds: addr = 0x%08x\n", addr);
		printf("accessing pmem out of bounds\n");
		return 0;
	}
	return pmem[relative_addr];
}

extern "C" void pmem_write(int addr, int data, uint8_t mask){
	uint32_t relative_addr = ((uint32_t)addr - MEMBASE) >> 2; 
	if(relative_addr >= WORD_COUNT) {
		printf("accessing pmem out of bounds: addr = 0x%08x\n", addr);
		printf("accessing pmem out of bounds\n");      
		return;
	}
	uint8_t* byte = (uint8_t*)&pmem[relative_addr];
	for(int i = 0; i < 4; i++){
		if(mask & (1 << i)){
			byte[i] = (data >> (i * 8)) & 0xFF;
		}
	}
}

extern "C" void terminate(){
	sim_exit = true;
}


void single_cycle() {
	top->clk = 0;
	top->eval();
	tfp->dump(main_time++);

	top->clk = 1;
	top->eval();
	tfp->dump(main_time++);
	tfp->flush();
}

void reset(int n) {
	top->rst = 1;
	while (n-- > 0) single_cycle();
	top->rst = 0;
}

void load_program(const char* program_file){
	if(!program_file) return;
	FILE *fp = fopen(program_file, "rb");
	assert(fp && "Failed to open binary program file");
	fseek(fp, 0, SEEK_END);
	long size = ftell(fp);
	fseek(fp, 0, SEEK_SET);
	assert(size <= MEMSIZE && "program is >128MB");
	size_t ret = fread(pmem, size, 1, fp);
	fclose(fp);
	printf("File successfully loaded\n");
}


int main(int argc, char** argv) {
	Verilated::commandArgs(argc, argv);
	if(argc > 1){
		load_program(argv[1]);
	}

	Verilated::traceEverOn(true);
	top = new Vminirv;
	tfp = new VerilatedVcdC;
	top->trace(tfp, 99);
	tfp->open("sim_dump.vcd");
	reset(10);
	while (!sim_exit) {
		single_cycle();
	}
	if (top->a0 == 0) {
		printf("\033[1;32mHIT GOOD TRAP\033[0m\n");
	} 
	else 
	{
		printf("\033[1;31mHIT BAD TRAP (code = %d)\033[0m\n", top->a0);
	}	
	printf("Terminated due to ebreak\n");
	int return_code = top->a0 == 0 ? 0 : 1;
	delete top;
	tfp->close();
	return return_code;
}


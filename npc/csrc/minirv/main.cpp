#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <Vminirv.h>
#include <unistd.h>
#include <verilated.h>
#include <verilated_vcd_c.h>


Vminirv top;
VerilatedVcdC* tfp = NULL;
uint32_t pmem[16777216] = {
0x01400513,
0x010000e7,
0x00c000e7,
0x00c00067,
0x00a50513,
0x00008067
};
uint64_t main_time = 0;

uint32_t pmem_read(uint32_t addr){
	uint32_t word = addr >> 2;	
	return pmem[word];
}

void single_cycle() {
	top.inst = pmem_read(top.pc);
	top.clk = 0;
	top.eval();
	tfp->dump(main_time++);

	top.clk = 1;
	top.eval();
	tfp->dump(main_time++);
	tfp->flush();
}

void reset(int n) {
	top.rst = 1;
	while (n-- > 0) single_cycle();
	top.rst = 0;
}



int main(int argc, char** argv) {
	Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);

	tfp = new VerilatedVcdC;
	top.trace(tfp, 99);
	tfp->open("sim_dump.vcd");
	
	reset(10);
	while (1) {
			printf("PC = 0x%08x | Inst = 0x%08x\n", top.pc, top.inst);
			single_cycle();
			usleep(1000000);
	}

	tfp->close();
	return 0;
}


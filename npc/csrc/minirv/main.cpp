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
0x123450b7,
0x00001537,
0x00150533,
0x001500b3,
0x00100073,
};
uint64_t main_time = 0;
bool sim_exit = false;

uint32_t pmem_read(uint32_t addr){
	uint32_t word = addr >> 2;	
	return pmem[word];
}

extern "C" void terminate(){
	sim_exit = true;
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
	while (!sim_exit) {
			printf("PC = 0x%08x | Inst = 0x%08x | ra = %08x | a0 = %08x\n", top.pc, top.inst, top.ra, top.a0);
			single_cycle();
			usleep(1000000);
	}
	
	printf("Terminated due to ebreak\n");
	tfp->close();
	return 0;
}


#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <VsCPU.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include <nvboard.h>

static VsCPU top;
static VerilatedVcdC* tfp = NULL;
uint64_t main_time = 0;

void nvboard_bind_all_pins(VsCPU* top);

void single_cycle() {
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

	nvboard_bind_all_pins(&top);
	nvboard_init();

	reset(10);
	
	int delay = 0;
	const int SPEED_LIMIT = 1000000;
	while (1) {
		nvboard_update();
		if(++delay >= SPEED_LIMIT){
			single_cycle();
			delay = 0;
		}
	}

	tfp->close();
	nvboard_quit();
	return 0;
}

#include <stdio.h>                                                                                                                                                                                      
#include <stdlib.h>                                                                                                                                                                                     
#include <assert.h>                                                                                                                                                                                     
#include <Vlight.h>			
#include <verilated.h>
#include <verilated_fst_c.h>                                                                                                                                                                            
#include <nvboard.h>

static TOP_NAME top;
static VerilatedFstC* tfp = NULL;
vluint64_t main_time = 0;

void nvboard_bind_all_pins(Vlight* top);

void single_cycle(){
	top.clk = 0;
	top.eval();
	tfp->dump(main_time++);
	
	top.clk = 1;
	top.eval();
	tfp->dump(main_time++);
}

void reset(int n){
	top.rst = 1;
	while(n-- > 0) single_cycle();
	top.rst = 0;
}

int main(int argc, char** argv){
	Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);
	tfp = new VerilatedFstC;
	top.trace(tfp,99);
	tfp->open("sim_dump.fst");
	nvboard_bind_all_pins(&top);
	nvboard_init();
	vluint64_t time = 0;

	reset(10);  // reset for 10 cycles
	while(1) {
		nvboard_update();	
		single_cycle();
	}

	tfp->close();
	nvboard_quit();
	return 0;
}

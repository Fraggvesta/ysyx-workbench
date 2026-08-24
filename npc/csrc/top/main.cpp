// The following is pseudocode

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <Vtop.h>
#include <verilated.h>
#include <verilated_fst_c.h>
#include <nvboard.h>

static TOP_NAME top;
void nvboard_bind_all_pins(Vtop* top);

int main(int argc, char** argv){
	
	Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  VerilatedFstC* tfp = new VerilatedFstC;
  top.trace(tfp, 99);
  tfp->open("sim_dump.fst");
  
	nvboard_bind_all_pins(&top);
	nvboard_init();
	vluint64_t main_time = 0;
	
  int i = 0;  
   while(i < 100){
     nvboard_update();
		 top.eval();
		 tfp->dump(main_time++);
   }
   tfp->close();
   nvboard_quit();
   return 0;
}

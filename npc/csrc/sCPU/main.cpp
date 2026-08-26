#include <stdio.h>
#include <stdlib.h>
#include <VsCPU___024root.h>
#include <assert.h>
#include <VsCPU.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include <nvboard.h>

void ref_reset();
void ref_inst_cycle();
uint8_t* ref_get_regs();
uint8_t ref_get_PC();

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
	ref_reset();
}

int check_regs(uint8_t *dut_regs, uint8_t *ref_regs){
	for(int i = 0; i < 4; i++){
		if(dut_regs[i] != ref_regs[i]){
			uint8_t curr_pc = ref_get_PC();
			printf("Difftest Mismatch Detected\n");
			printf("Register mismatch R[%d] at PC:%d\n", i, curr_pc);
			return 1;
		}
	}
	return 0;
}

int check_pc(uint8_t dut_pc, uint8_t ref_pc){
	if(dut_pc != ref_pc){
		printf("Difftest Mismatch detected\n");
		printf("PC mismatch, REF_PC: %d DUT_PC: %d\n", ref_pc, dut_pc);
		return 1;
	}

	return 0;
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
	
	uint8_t *dut_regs = top.rootp->sCPU__DOT__obj_regf__DOT__rf.data();
	uint8_t dut_pc = top.pc_out;
	int delay = 0;
	const int SPEED_LIMIT = 100000000;
	while (1) {
		nvboard_update();
		if(++delay >= SPEED_LIMIT){
			single_cycle();
			ref_inst_cycle();

			uint8_t *ref_regs = ref_get_regs();
			uint8_t ref_pc = ref_get_PC();
			if(check_regs(dut_regs, ref_regs) || check_pc(dut_pc, ref_pc)){
					printf("Difftest failed!\n");
					break;
					}

			delay = 0;
		}
	}

	tfp->close();
	nvboard_quit();
	return 0;
}

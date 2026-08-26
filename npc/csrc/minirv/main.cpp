#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <Vminirv.h>
#include <unistd.h>
#include <verilated.h>
#include <verilated_vcd_c.h>


Vminirv top;
VerilatedVcdC* tfp = NULL;

uint32_t pmem[16777216];
void init_memory(){
pmem[0]  = 0x12345537; // 0x00: lui   a0, 0x12345
pmem[1]  = 0x67850513; // 0x04: addi  a0, a0, 0x678
pmem[2]  = 0x04000313; // 0x08: addi  t1, x0, 0x40
pmem[3]  = 0x00032383; // 0x0C: lw    t2, 0(t1)
pmem[4]  = 0x00434e03; // 0x10: lbu   t3, 4(t1)
pmem[5]  = 0x01c38533; // 0x14: add   a0, t2, t3
pmem[6]  = 0x00a32423; // 0x18: sw    a0, 8(t1)
pmem[7]  = 0x02800e93; // 0x1C: addi  t4, x0, 0x28
pmem[8]  = 0x000e80e7; // 0x20: jalr  ra, 0(t4)
pmem[9]  = 0x00100073; // 0x24: ebreak (skipped)
pmem[10] = 0x00100073; // 0x28: ebreak (exit)

pmem[16] = 0xDEADBEEF; // 0x40: Data word for LW
pmem[17] = 0x0000007F; // 0x44: Data byte for LBU
}
uint64_t main_time = 0;
bool sim_exit = false;

extern "C" int pmem_read(int addr){
	return pmem[addr >> 2];
}

extern "C" void pmem_write(int addr, int data, uint8_t mask){
	uint8_t* byte = (uint8_t*)&pmem[addr >> 2];
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
	init_memory();
	reset(10);
	while (!sim_exit) {
		printf("PC = 0x%08x | Inst = 0x%08x | ra = %08x | a0 = %08x, | mem[0x40] = %08x | mem[0x44] = %08x | mem[0x48] = %08x\n", top.pc, pmem[top.pc >> 2], top.ra, top.a0, pmem[16],pmem[17],pmem[18]);
		single_cycle();
		usleep(1000000);
	}
	
	printf("Terminated due to ebreak\n");
	tfp->close();
	return 0;
}


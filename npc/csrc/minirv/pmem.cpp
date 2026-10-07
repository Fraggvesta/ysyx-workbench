#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "minirvEMU.h"
#include "pmem.h"

static uint32_t pmem[WORD_COUNT];

int pmem_read(int addr){
	
	if (((uint32_t)addr & 0xfffff000) == 0x10000000) {
		return ((uint32_t)addr & 7) == 5 ? (0x60u << ((addr & 3) * 8)) : 0;
	}

	uint32_t relative_addr = ((uint32_t)addr - MEMBASE) >> 2;
	if(relative_addr >= WORD_COUNT){
		printf("accessing pmem out of bounds: addr = 0x%08x\n", addr);
		return 0;
	}
	return pmem[relative_addr];
}


void pmem_write(int addr, int data, uint8_t mask){
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


void pmem_load(const char* file){
    FILE *fp = fopen(file, "rb");
	if (!fp) { printf("Failed to open %s\n", file); exit(1); }
	fseek(fp, 0, SEEK_END);
	long size = ftell(fp);
	if (size > MEMSIZE) { printf("%s is larger than memory\n", file); exit(1); }
	fseek(fp, 0, SEEK_SET);
	if (fread(pmem, size, 1, fp) != 1) { printf("Failed to read %s\n", file); exit(1); }
	fclose(fp);
}
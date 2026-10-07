#ifndef PMEM_H
#define PMEM_H

#include <stdint.h>

extern "C" {
int  pmem_read(int addr);
void pmem_write(int addr, int data, uint8_t mask);
void pmem_load(const char *file);
}

#endif
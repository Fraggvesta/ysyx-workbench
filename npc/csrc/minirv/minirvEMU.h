#ifndef MINIRVEMU_H
#define MINIRVEMU_H

#include <stdint.h>
#include <stdbool.h>

#define MEMBASE 0x80000000
#define WORD_COUNT 33554432
#define MEMSIZE (WORD_COUNT * 4)

extern uint32_t pc;
extern uint32_t R[32];
extern uint32_t M[WORD_COUNT];

void ref_reset();
bool ref_inst_cycle();

#endif

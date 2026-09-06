#include <am.h>
#include <klib-macros.h>

extern char _heap_start;
int main(const char *args);

extern char _pmem_start;
#define PMEM_SIZE (128 * 1024 * 1024)
#define PMEM_END  ((uintptr_t)&_pmem_start + PMEM_SIZE)

Area heap = RANGE(&_heap_start, PMEM_END);
static const char mainargs[MAINARGS_MAX_LEN] = TOSTRING(MAINARGS_PLACEHOLDER); // defined in CFLAGS

void putch(char ch) {
	volatile int8_t *thr = (volatile int8_t*)0x10000000ul;
	volatile int8_t *lsr = (volatile int8_t*)0x10000005ul;
	while((*lsr & 0x20) == 0);
	*thr = ch;
}

void halt(int code) {
	asm volatile("mv a0, %0; ebreak" : :"r"(code));
	while (1);
}

void _trm_init() {
	volatile uint8_t* lcr = (volatile uint8_t*)0x10000003;
	*lcr = 0x83;
	volatile uint8_t* dlb2 = (volatile uint8_t*)0x10000001;
	*dlb2 = 0x00;
	volatile uint8_t* dlb1 = (volatile uint8_t*)0x10000000;
	*dlb1 = 0x0E;
	*lcr = 0x03;
	int ret = main(mainargs);
	halt(ret);
}

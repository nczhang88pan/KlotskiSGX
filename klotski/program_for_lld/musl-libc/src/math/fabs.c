#include <math.h>
#include <stdint.h>

double fabs(double x)
{
	union {double f; uint64_t i;} u = {x};
	u.i &= -1ULL/2;
	return u.f;
		// __asm__ __volatile__ (
        // "movsd 16(%%r15),%%xmm0\n"
        // "andpd %%xmm1,%%xmm0\n"
        // "pop %%r14\n"
        // "rorx $0xb, %%r14,%%r14\n"
        // "add (%%r15d,%%r14d,8),%%r14\n"
        // "rorx $0x35, %%r14,%%r14\n"
        // "jmp *%%r14\n"
        // ::);
}

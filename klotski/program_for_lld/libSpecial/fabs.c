#include <math.h>
#include <stdint.h>

double fabs(double x)
{
	__asm__ __volatile__ (
        "movsd 16(%%r15),%%xmm0\n"
        "andpd %%xmm1,%%xmm0\n"
        "pop %%r14\n"
        "rorx $0xc, %%r14,%%r14\n"
        "add (%%r15d,%%r14d,8),%%r14\n"
        "rorx $0x34, %%r14,%%r14\n"
        "jmp *%%r14\n"
        ::);
}

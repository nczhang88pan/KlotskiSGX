/*************************************************************************
	> File Name: securityCPY.h
	> Author: 
	> Mail: 
	> Created Time: Wed 16 Aug 2017 01:24:58 PM PDT
 ************************************************************************/

#ifndef _SECURITYCPY_H
#define _SECURITYCPY_H
void secureCopy();
void pathORAMShuffling();

struct GPStrategy{
	int OcallTime;
	int *GPStrategy;
};

int GPStrategy_0[23]={22,0, 12,	97,	121,	134,	263,	264,	265,	266,	271,	291,	294,	305,	308,	314,	315,	316,	317,	320,	321,	326,	358};
int GPStrategy_1[4]={3,272,	274,	290};
int GPStrategy_2[11]={10,3,	26,	36,	49,	122,	260,	276,	310,	311,	331};
int GPStrategy_3[3]={2,330,	333};
int GPStrategy_4[54]={53,5,	7,	14,	16,	17,	18,	23,	28,	31,	32,	34,	43,	50,	51,	55,	61,	64,	72,	75,	77,	78,	81,	83,	88,	91,	94,	120,	123,	124,	126,	128,	135,	154,	155,	160,	163,	168,	170,	171,	172,	176,	177,	179,	180,	193,	200,	206,	208,	209,	210,	212,	217,	236};
int GPStrategy_5[8]={7,6,	9,	183,	307,	335,	340,	343};

// int GPStrategy_1[99]={98,3,	5,	7,	12,	13,	14,	16,	17,	18,	21,	23,24,	26,	27,	28,	31,	32,	34,	36,	37,	43,	49,	50,	51,	55,	61,	64,	72,	75,	77,	78,	81,	83,	88,	91,	94,	97,	98,	120,	121,	122,	123,	124,	126,	128,	134,	135,	154,	155,	160,	163,	168,	170,	171,	172,	176,	177,	179,	180,	193,	200,	206,	208,	209,	210,	212,	217,	236,	260,	262,	263,	264,	265,	266,	271,	272,	274,	276,	290,	291,	294,	305,	308,	310,	311,	314,	315,	316,	317,	320,	321,	326,	330,	331,	333,	338,	342,	358};
// int GPStrategy_2[105]={104,3,5,	6,	7,	9,	12,	13,	14,	16,	17,	18,	21,	23,	26,	27,	28,	31,	32,	34,	36,	37,	43,	49,	50,	51,	55,	61,	64,	72,	75,	77,	78,	81,	83,	88,	91,	94,	97,	98,	120,	121,	122,	123,	124,	126,	128,	134,	135,	154,	155,	160,	163,	168,	170,	171,	172,	176,	177,	179,	180,	183,	193,	200,	206,	208,	209,	210,	212,	217,	236,	260,	262,	263,	264,	265,	266,	271,	272,	274,	276,	290,	291,	294,	305,	307,	308,	310,	311,	314,	315,	316,	317,	320,	321,	326,	330,	331,	333,	335,	338,	340,	342,	343,	358};

struct GPStrategy preGPStrategy[1]={
	{8,GPStrategy_5}
};
// struct GPStrategy preGPStrategy[3]={
// 	{0,GPStrategy_0},{5,GPStrategy_1},{8,GPStrategy_2}
// };

#define SHUFFLE_NUMBER 16
//pageCopyRandomSequence
int pageSequence[16]={0,0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8,0x9,0xa,0xb,0xc,0xd,0xe,0xf};
int stackPageSequence[16]={0,0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8,0x9,0xa,0xb,0xc,0xd,0xe,0xf};
int heapPageSequence[16]={0,0x1,0x2,0x3,0x4,0x5,0x6,0x7,0x8,0x9,0xa,0xb,0xc,0xd,0xe,0xf};
//pageShuffSequence
char YmmCopySequence[16]={0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};

unsigned cacheMask = 0x80000000 ;
unsigned cacheOffset[8] = {
    0*CACHE_PTE_NUM,
    1*CACHE_PTE_NUM,
    2*CACHE_PTE_NUM,
    3*CACHE_PTE_NUM,
    4*CACHE_PTE_NUM,
    5*CACHE_PTE_NUM,
    6*CACHE_PTE_NUM,
    7*CACHE_PTE_NUM
};

//extern unsigned long pagetable[0x400*4*4+1];
int CopyPages(uint64_t physical_base_address,int shuffleNum, int *shuffleSequence);
int comparePage(unsigned long src,unsigned long dest);
void warpSecureCPWithGatherPoolStrategy();
void perSetDirtyFlagByTime();
void dereference_ControlFlow();
void dereference_ControlFlow_ret();
void dereference_ControlFlow_Fallthrough();
void dereference_ControlFlow_call();
void swapCachePageBack();
void dereference_data();
void heapObliviousInit();

#define saveContex() \
"push %%rax\n"\
"push %%rbx\n"\
"push %%rbp\n"\
"push %%rdi\n"\
"push %%rsi\n"\
"push %%rdx\n"\
"push %%rcx\n"\
"push %%r8\n" \
"push %%r9\n" \
"push %%r10\n"\
"push %%r11\n"\
"push %%r12\n"\
"push %%r13\n"\
"push %%r15\n"\
"movaps %%xmm0,0xa0(%%r15)\n"\
"movaps %%xmm1,0xb0(%%r15)\n"\
"movaps %%xmm2,0xc0(%%r15)\n"\
"movaps %%xmm3,0xd0(%%r15)\n"\
"movaps %%xmm4,0xe0(%%r15)\n"\
"movaps %%xmm5,0xf0(%%r15)\n"\
"movaps %%xmm6,0x100(%%r15)\n"\
"movaps %%xmm7,0x110(%%r15)\n"\
"movaps %%xmm8,0x120(%%r15)\n"\
"movaps %%xmm9,0x130(%%r15)\n"\
"movaps %%xmm10,0x140(%%r15)\n"\
"movaps %%xmm11,0x150(%%r15)\n"\
"movaps %%xmm12,0x160(%%r15)\n"\
"movaps %%xmm14,0x170(%%r15)\n"\
"vmovaps %%ymm13,0x180(%%r15)\n"\
"movaps %%xmm15,0x200(%%r15)\n"\



#define resumeContex() \
"movaps 0xa0(%%r15),%%xmm0\n"\
"movaps 0xb0(%%r15),%%xmm1\n"\
"movaps 0xc0(%%r15),%%xmm2\n"\
"movaps 0xd0(%%r15),%%xmm3\n"\
"movaps 0xe0(%%r15),%%xmm4\n"\
"movaps 0xf0(%%r15),%%xmm5\n"\
"movaps 0x100(%%r15),%%xmm6\n"\
"movaps 0x110(%%r15),%%xmm7\n"\
"movaps 0x120(%%r15),%%xmm8\n"\
"movaps 0x130(%%r15),%%xmm9\n"\
"movaps 0x140(%%r15),%%xmm10\n"\
"movaps 0x150(%%r15),%%xmm11\n"\
"movaps 0x160(%%r15),%%xmm12\n"\
"vmovaps 0x180(%%r15),%%ymm13\n"\
"movaps 0x170(%%r15),%%xmm14\n"\
"movaps 0x200(%%r15),%%xmm15\n"\
"pop %%r15\n"\
"pop %%r13\n"\
"pop %%r12\n"\
"pop %%r11\n"\
"pop %%r10\n"\
"pop %%r9\n"\
"pop %%r8\n"\
"pop %%rcx\n"\
"pop %%rdx\n"\
"pop %%rsi\n"\
"pop %%rdi\n"\
"pop %%rbp\n"\
"pop %%rbx\n"\
"pop %%rax\n"\

#endif

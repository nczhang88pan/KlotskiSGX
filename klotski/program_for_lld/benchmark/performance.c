#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define FALLTHROUGH_EVENT_INC() 
#define DATE_EVENT_INC()
#define NO_OBLIVIOUS_PAGETABLE_ACCESS 0
#define INCACHE_WIDTH 4
#define ITERNUM 10000000
#define CACHE_PTE_NUM (1<<INCACHE_WIDTH)

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

void dereference_ControlFlow_with2_entry_call(){
    #if NO_OBLIVIOUS_PAGETABLE_ACCESS
    __asm__ __volatile__ (
        FALLTHROUGH_EVENT_INC()
        "loopLabel:\n"
        "rorx $0xb, %r14,%r14\n"
        "cmpq $1,(%r15d,%r14d,8)\n"
        "je entryIsNull_fallthrough\n"
        "add (%r15d,%r14d,8),%r14\n"
        "rorx $0x35, %r14,%r14\n"
        "jmp *%r14\n"
    "entryIsNull_fallthrough:\n"
        // "mov %%r14,%0\n"
        // "mov %%rsp,%1\n"
        // "mov %2,%%rsp\n"
        // saveContex()
        // :"=m"(targetVirtualAddress),"=m"(_virtual_stack_save):"m"(_stack_save)
    );
    #else
    __asm__ __volatile__ (
        "rorx $0xb, %%r14,%%r14\n"
        "vmovdqa %1,%%ymm13\n"
        "mov %%r14,%%r13\n"
        "and $0xff8f,%%r13\n"                    // bucket :cache line index(3 bits): in-cache line index(4 bits) 
        "lea (%%r15d,%%r13d,8),%%r13d\n"          // get the start address 
        "vpbroadcastd %0,%%ymm14\n"               // set the mask all valid
        "vpgatherdd %%ymm14,(%%r13,%%ymm13,8),%%ymm15\n"  //oblivous access cache line
        "vmovaps %%ymm15,0x210(%%r15)\n"          //mov result to the memory
        "rorx $2,%%r14,%%r13\n"                   // get the cache line index and then get the result
        "and $0x1c,%%r13\n"
        "mov 0x210(%%r15d,%%r13d),%%r13d\n"
        "cmp $1,%%r13d\n"
        "je entryIsNull_ret\n"
        // "cmpw %5,%4\n"
        // "jg dataCacheIsOverSized\n"
        "add %%r13,%%r14\n"
        "rorx $0x35, %%r14,%%r14\n"
        "jmp *%%r14\n"
        "entryIsNull_ret:\n"
        ::"m"(cacheMask),"m"(cacheOffset)
        );

   
    #endif
}

void dereference_data(){
    #if NO_OBLIVIOUS_PAGETABLE_ACCESS
    __asm__ __volatile__ (
        DATE_EVENT_INC()
        "rorx $0xb, %r14, %r14\n"
        "cmpq $1,(%r15d,%r14d,8)\n"
        "je entryIsNull_data\n"
        "add (%r15d,%r14d,8),%r14\n"
        "rorx $0x35, %r14, %r14\n"
        "ret \n"
    "entryIsNull_data:\n"
    );
    #else
   __asm__ __volatile__ (
        "vmovdqa %1,%%ymm13\n"
        "rorx $0xb, %%r14, %%r14\n"
        "mov %%r14,%%r13\n"
        "and $0xff8f,%%r13\n"                    // bucket :cache line index(3 bits): in-cache line index(4 bits) 
        "lea (%%r15d,%%r13d,8),%%r13d\n"          // get the start address 
        "vpbroadcastd %0,%%ymm14\n"               // set the mask all valid
        "vpgatherdd %%ymm14,(%%r13,%%ymm13,8),%%ymm15\n"  //oblivous access cache line
        "vmovaps %%ymm15,0x210(%%r15)\n"          //mov result to the memory
        "rorx $2,%%r14,%%r13\n"                   // get the cache line index and then get the result
        "and $0x1c,%%r13\n"
        "mov 0x210(%%r15d,%%r13d),%%r13d\n"
        "cmp $1,%%r13d\n"
        "je entryIsNull_data\n"
        "add %%r13,%%r14\n"
        "rorx $0x35, %%r14, %%r14\n"
        "ret \n"
    "entryIsNull_data:\n"
        ::"m"(cacheMask),"m"(cacheOffset)
    );
    #endif
     
}

unsigned long pagetable[0x400*4]={0};
void fillPagetable(){
    int i;
    for(i=0x400;i<0xf00;i++){
        pagetable[i]=0;
    };
    pagetable[8] = (size_t)dereference_ControlFlow_with2_entry_call;
    pagetable[10] =  (size_t)dereference_data;
    return;
}


int main(){
    size_t start, end;
    double basic=0.0;
    double total_basic=0.0;
    size_t total=0;
    size_t iterateNum = ITERNUM;
    unsigned cycles_low, cycles_high, cycles_low1, cycles_high1;
    fillPagetable();
int itr;
    // for( itr=0;itr<10;itr++){
    //     // asm volatile (
    //     // "RDTSC\n\t"
    //     // "mov %%edx, %0\n\t"
    //     // "mov %%eax, %1\n\t": 
    //     // "=r"(cycles_high), "=r"(cycles_low)
    //     // );
    //     asm volatile (
    //     "CPUID\n\t"/*serialize*/
    //     "RDTSC\n\t"/*read the clock*/
    //     "mov %%edx, %0\n\t"
    //     "mov %%eax, %1\n\t": "=r" (cycles_high), "=r"
    //     (cycles_low):: "%rax", "%rbx", "%rcx", "%rdx");

    //     __asm__ __volatile__(
    //         "movq $0,-0x8(%%rsp)\n"
    //         "mov $pagetable,%%r15\n"
    //     "start_testing:\n"
    //         "cmpq $1000000000L,-0x8(%%rsp)\n"
    //         "je stop_testing\n"
    //         "incq -0x8(%%rsp)\n"
    //         // "mov $loop_end,%%r14\n"
    //         // "jmp *0x40(%%r15)\n"
    //     "loop_end:\n"
    //         "jmp start_testing\n"
    //         "stop_testing:\n"
    //         ::: "%r14","%r15"
    //         );
    //     // asm volatile (
    //     // "RDTSC\n\t"
    //     // "mov %%edx, %0\n\t"
    //     // "mov %%eax, %1\n\t": "=r"(cycles_high1), "=r"(cycles_low1)
    //     // );
    //     asm volatile("RDTSCP\n\t"
    //         "mov %%edx, %0\n\t"
    //         "mov %%eax, %1\n\t"
    //         "CPUID\n\t": "=r" (cycles_high1), "=r" (cycles_low1)::
    //         "%rax", "%rbx", "%rcx", "%rdx"
    //     );

    //     start = ( ((size_t)cycles_high << 32) | cycles_low );
    //     end = ( ((size_t)cycles_high1 << 32) | cycles_low1 );
    //     printf("function execution time is %.13f clock cycles\n", (double)(end-start)/(double)1000000000);
    // }
//test code dereference
    for(itr=0;itr<iterateNum;itr++){
        asm volatile (
        "mov $pagetable,%%r15\n"
        "CPUID\n\t"/*serialize*/
        "RDTSC\n\t"/*read the clock*/
        "mov %%eax,%0\n\t"
        // "mov $code_dereference,%%r14\n\t"
        // "jmp *0x40(%%r15)\n\t"
    "code_dereference:\n\t"
         "RDTSCP\n\t"
         "mov %%eax,%1\n\t"
         "CPUID\n\t"
         : "=r"(cycles_low), "=r"(cycles_low1):: "%rax", "%rbx", "%rcx", "%rdx","%r14","%r15"
        );
        total +=(cycles_low1-cycles_low);
    }
    basic = (double)total/(double)iterateNum;

    total = 0;

    for(itr=0;itr<iterateNum;itr++){
        asm volatile (
        "mov $pagetable,%%r15\n"
        "CPUID\n\t"/*serialize*/
        "RDTSC\n\t"/*read the clock*/
        "mov %%eax,%0\n\t"
        "mov $code_dereference_2,%%r14\n\t"
        "jmp *0x40(%%r15)\n\t"
    "code_dereference_2:\n\t"
         "RDTSCP\n\t"
         "mov %%eax,%1\n\t"
         "CPUID\n\t"
         : "=r"(cycles_low), "=r"(cycles_low1):: "%rax", "%rbx", "%rcx", "%rdx","%r14","%r15"
        );
        total +=(cycles_low1-cycles_low);
    }
    total_basic = (double)total/(double)iterateNum;
     
    printf("%.10f - %.10f per code execution time is %.13f\n",total_basic,basic,total_basic-basic);

    

//test data_derefence
    total = 0;
    for(itr=0;itr<iterateNum;itr++){
        asm volatile (
        "mov $pagetable,%%r15\n"
        "CPUID\n\t"/*serialize*/
        "RDTSC\n\t"/*read the clock*/
        "mov %%eax,%0\n\t"
        "mov $pagetable,%%r14\n\t"
        "call *0x50(%%r15)\n\t"
    "data_dereference_2:\n\t"
         "RDTSCP\n\t"
         "mov %%eax,%1\n\t"
         "CPUID\n\t"
         : "=r"(cycles_low), "=r"(cycles_low1):: "%rax", "%rbx", "%rcx", "%rdx","%r14","%r15"
        );
        total +=(cycles_low1-cycles_low);
    }
    total_basic = (double)total/(double)iterateNum;
    printf("%.10f - %.10f per data execution time is %.13f\n",total_basic,basic,total_basic-basic);

    
    return 0;
}

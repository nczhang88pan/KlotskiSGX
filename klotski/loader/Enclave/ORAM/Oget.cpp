#include "Oget.hpp"
#include "../Enclave.h"
unsigned cacheOffset_1[8] = {
    0*CACHE_PTE_NUM,
    1*CACHE_PTE_NUM,
    2*CACHE_PTE_NUM,
    3*CACHE_PTE_NUM,
    4*CACHE_PTE_NUM,
    5*CACHE_PTE_NUM,
    6*CACHE_PTE_NUM,
    7*CACHE_PTE_NUM
};
unsigned consultResult[8] = {0,0,0,0,0,0,0,0};
unsigned cacheMask_1 = 0x80000000 ;

//ymm13 is reserved for offset
//ymm14 is reserved for mask
//ymm15 is reserved for dest
//0x200(%%r15) for temp

void Oget(){
    
     __asm__ __volatile__ (
        "vmovdqa %0,%%ymm13\n"
     ::"m"(cacheOffset_1)
     );
     unsigned result =0;

     for(unsigned itr=0x800;itr!=0x900;itr++){

        __asm__ __volatile__ (
            // "mov $0x400000,%r14\n"
            // "rorx $0xb, %r14,%r14\n"
            "mov %1,%%r14d\n"
            "mov %%r14d,%%r13d\n"
            "and $0xff8f,%%r13w\n"                    // bucket :cache line index(3 bits): in-cache line index(4 bits) 
            "lea (%%r15d,%%r13d,8),%%r13d\n"          // get the start address 
            "vpbroadcastd %0,%%ymm14\n"               // set the mask all valid
            "vpgatherdd %%ymm14,(%%r13,%%ymm13,8),%%ymm15\n"  //oblivous access cache line
            "vmovaps %%ymm15,0x200(%%r15)\n"          //mov result to the memory
            "rorx $2,%%r14,%%r13\n"                   // get the cache line index and then get the result
            "and $0x1c,%%r13w\n"
            "mov 0x200(%%r15d,%%r13d),%%r13d\n"
            "mov %%r13d,%2\n"
            ::"m"(cacheMask_1),"m"(itr),"m"(result)
        );
        if(itr!=result){
            // printf("here\n");
            return;
        }
     }

   
}
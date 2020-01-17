#include <stdio.h>
#include <stdlib.h>
#include "../enclave.h"

// char buffer[64];

//#include "bm_clock.c" 
// #include "bm_malloc_and_sort.c"
//  #include "bm_malloc_memalign_magic.c"
// #include "bm_malloc_simple.c"
// #include "bm_memchr.c"
// #include "bm_memset.c"
// #include "bm_memmove.c"
// #include "bm_memcpy.c"  
//#include "bm_printf.c"  
 #include "bm_sort_and_binsearch.c"  
// #include "bm_sprintf.c"  
// #include "bm_io.c"



/* If nothing is executed */
//__asm__ __volatile__ (
//        ".text\n"
//        ".global enclave_main\n"
//        ".type enclave_main, @function\n"
//        "enclave_main:\n"
//        "push   %rbp\n"
//        "mov    %rsp, %rbp\n"
//        "movabs $__rbp_backup, %r14\n"
//        "mov    (%r14), %rbp\n"
//        "movabs $__stack_backup, %r14\n"
//        "mov    (%r14), %rsp\n"
//        "movabs $__enclave_exit, %r14\n"
//        "jmp    *(%r14)"
//        );
// #include "nmglobal.h"
// #include "nbench0.h"
//unsigned long pagetable[0x400*4]={0};
//unsigned long *startStackPage = &pagetable[1024*4];
//
//unsigned long ourstack[512*16]={0};
//unsigned long _stack_save = 0;
//unsigned long *stackStart= &ourstack[512*16];
//
//void fillPagetable(){
//    int i;
//    unsigned long stackbase =(unsigned long) &ourstack[512*16];
//    stackbase = stackbase >>12;
//    pagetable[0]=0xFFFFFFFFFFFFF000;
//    for(i=0x400;i<0xf00;i++){
//        pagetable[i]=0;
//    };
//    for(i=0xfff;i>=0xff1;i--){
//        pagetable[i] = stackbase - 0xfff;
//    }
//    //printf("stackbase = %lx\n",stackbase);
//    return;
//}

//int main(){
//void enclave_main(){
//
//    fillPagetable();
//    __asm__ __volatile__("mov $pagetable,%%r15\n"
//
//                         "movq %%rsp,(_stack_save)\n"
//
//                         "mov $ourstack,%%rsp\n"
//                         "and $0xffff000,%%rsp\n"
//                         "add $0x10008,%%rsp\n"
//                      //   "mov %%rsp,%%rbp\n"
//                      //   "add $0xfff000,%%rbp\n"::);
//                         "mov $0xfff008,%%r13\n"::);
//
//    
//    enclave_main();
//    __asm__ __volatile__("mov $pagetable,%%r15\n"
//                         "movq (_stack_save),%%rsp\n"::);
//
//}

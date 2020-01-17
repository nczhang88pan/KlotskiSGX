#pragma once
//user configure
#define OBLIVIOUSSHUFFLE 1             //code oblivious enable
#define DATAOBLIVIOUSSHUFFLE 1           //data(small) oblivious enable
#define BIGOBJECTOSHUFFLE 0         //data(big) oblivious enable, enable with -DBIGOBJECTOSHUFFLE=1
#define PAGE_SWAP_AT_OCALL 0             //shall we swap the pages existed in cache back
#define NO_OBLIVIOUS_PAGETABLE_ACCESS 1  //shall we do oblivous pagetable access?

#define PAGE_SWAP_RANDOM 1

size_t getARangeMAC(size_t startVirAddr,size_t endVirAddr);

//configure this to decide which program is testing, because their start addresses are different.
// #define isNbench 0

// #if isNbench
//nbench
#define CODE_START_ADD CodeStartVirtAddr
#define TARGET_ADD     EntryPageShadowStartAddr    //the start page of enclave_main
// #define TARGET_START_INDEX   EntryPageStartIndex
#define TARGET_START_INDEX   1
#define BSS_SECTION_OBLIVIOUS_NUM 4
#define DATA_SECTION_OBLIVIOUS_NUM 1
// #else 
// //mbedtls
// #define CODE_START_ADD CodeStartVirtAddr
// #define TARGET_ADD     EntryPageShadowStartAddr
// #define TARGET_START_INDEX   EntryPageStartIndex
// #define BSS_SECTION_OBLIVIOUS_NUM 4
// #define DATA_SECTION_OBLIVIOUS_NUM 1
// #endif

typedef unsigned long addr_t;

extern char __sgx_start;        /* defined in the linker script */
extern char __sgx_end;          /* defined in the linker script */
extern char __sgx_code;         /* defined in the linker script */
extern char __sgx_code_end;

//space reserved for code
extern char __sgx_code_pathOram;
extern char __sgx_code_pathOram_end;
//space reserved for data objects that are smaller than 1 block.
extern char __sgx_data_pathOram;
extern char __sgx_data_pathOram_end;
//space reserved for data objects which size are over than 1 block.
extern char __sgx_data_big_pathOram;
extern char __sgx_data_big_pathOram_end;

#define _SGXCODE_BASE ((void*)&__sgx_code)
// #define _SGXDATA_BASE ((void*)((addr_t)&__sgx_code + __sgx_data_ofs))
#define _SGXDATA_BASE ((void*)((addr_t)&__sgx_code))
#define VIRTUAL_CODE 0x400000
#define VIRTUAL_DATA 0x400000

#include <string.h>
#include "./measure/OMeasure.h"

#define SHADOWPAGEWIDE 11
#define SHADOWPAGESIZE (1<<SHADOWPAGEWIDE)
#define SHADOWPAGEMASK ((1<<SHADOWPAGEWIDE)-1)

#define _SGXSTACK_BASE __stack_start

#include <endian.h>
#if BYTE_ORDER == BIG_ENDIAN
# define byteorder ELFDATA2MSB
#elif BYTE_ORDER == LITTLE_ENDIAN
# define byteorder ELFDATA2LSB
#else
# error "Unknown BYTE_ORDER " BYTE_ORDER
# define byteorder ELFDATANONE
#endif

#define GET_OBJ(type, offset) \
     reinterpret_cast<type*>( reinterpret_cast<size_t>(program) \
            + static_cast<size_t>(offset) )
#define CHECK_SIZE(obj, size) \
    ((addr_t)obj + size <= (addr_t)program + program_size)

#include <vector>
//#include <iostream> 
#include "./ORAM/Oram.hpp"
#include "./ORAM/Oget.hpp"
#include <iterator>
#include <algorithm>
#include "./securityCPY.h"
#include <map>
#include <set>
#include <list>

#define RAX_BACKUP_FIXUP 31
#define OCALL_TABLE_FIXUP 20
#define STACK_SAVE_FIXUP 12
#define VIRTUAL_STACK_SAVE_FIXUP 4
#define BACK_VIRTUAL_STACK_SAVE_TO_RSP_FIXUP 31

#define SECURECOPY_FIXUP 38

#define REL_DST_NDX(ofs) ((ofs) >> 32)
#define REL_DST_OFS(ofs) ((ofs) & 0xffffffff)
#define REL_OFFSET(ndx, ofs) ((((unsigned long)(ndx)) << 32) | ((unsigned long)(ofs)))


//some macros
#define VALID_PAGE_NUM ((CODE_START_ADD+code_section_size-TARGET_ADD)/SHADOWPAGESIZE)

#define IGNOREDPageNum (TARGET_ADD-CODE_START_ADD)/SHADOWPAGESIZE

#define PAGEINDX_TO_ACCESS_INDEX(index_a) (index_a - EntryPageShadowStartIndex + TARGET_START_INDEX)
#define ACCESS_TO_PAGEINDEX(index_a) (index_a - TARGET_START_INDEX + EntryPageShadowStartIndex)

#define HEAPIndex 0
#define BIGHEAPIndex 1
#define HEAPSIZE SHADOWPAGESIZE
#define IGNOREDHeapPageNumForBig (0x0/HEAPSIZE)
#define IGNOREDHeapPageNum (0x1000/HEAPSIZE)
#define TARGET_DATA_START_INDEX 1
#define DATA_PAGEINDX_TO_ACCESS_INDEX(index_a) ((index_a)-TARGET_DATA_START_INDEX-((heap_virtual_start[HEAPIndex]>>SHADOWPAGEWIDE)))
#define ACCESS_TO_DATA_PAGEINDEX(index_a) (index_a+TARGET_DATA_START_INDEX+((heap_virtual_start[HEAPIndex]>>SHADOWPAGEWIDE)))

#define BLOCK_INDEX_TO_LOGIC_INDEX(blockIndex_a,shadowIndex)\
if(blockIndex_a<Oboundary){\
    shadowIndex = heap_start_index + blockIndex_a - 1 ;\
}else if(blockIndex_a<(Oboundary+DATA_SECTION_OBLIVIOUS_NUM)){\
    shadowIndex = data_section_start_index + blockIndex_a - Oboundary;\
}else {\
    shadowIndex = bss_section_start_index + blockIndex_a - Oboundary - DATA_SECTION_OBLIVIOUS_NUM;\
}

#define LOGIC_INDEX_TO_BLOCK_INDEX(shadowIndex,blockIndex_a)\
if(shadowIndex<bss_section_start_index){\
    blockIndex_a = Oboundary + shadowIndex - data_section_start_index;\
}else if(shadowIndex<heap_start_index){\
    blockIndex_a = shadowIndex - bss_section_start_index + Oboundary + DATA_SECTION_OBLIVIOUS_NUM;\
}else{\
    blockIndex_a = shadowIndex - heap_start_index +TARGET_DATA_START_INDEX;\
}

#define isBigObject(shadowIndex)\
((heap_big_start_index<=shadowIndex) &&\
    (shadowIndex<=(heap_big_start_index+shadowPageNumBig)))


#define BLOCK_INDEX_TO_LOGIC_INDEX_FOR_BIG(blockIndex_a,shadowIndex)\
shadowIndex = blockIndex_a+heap_big_start_index-TARGET_DATA_START_INDEX;

#define LOGIC_INDEX_TO_BLOCK_INDEX_FOR_BIG(shadowIndex, blockIndex_a)\
blockIndex_a = shadowIndex-heap_big_start_index+TARGET_DATA_START_INDEX;

//responsible for copying data back to program
size_t getRealAddress(size_t logicAddr);
bool copyingFromSGXToProgram(size_t dest,char *source,size_t len);
bool copyingFromProgramToSGX(char *dest,size_t source,size_t len);
size_t getStringLength(size_t src);
char* copyStringToSGX(size_t src);


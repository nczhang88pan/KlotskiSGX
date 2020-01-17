#include "./loader.h"
#include "debugConfig.h"
#include <map>

// #define DEBUG_LOADER

//program's argv
char **argvForProgram = NULL; 
char *programName = NULL;

static unsigned long _stack_save = 0;
unsigned long *heap_is_inited;
unsigned long _virtual_stack_save = 0;
unsigned long rax_backup = 0;
static unsigned long _virtual_stack_r13 = 0;
#define HEAPNUM 2
unsigned long heap_virtual_start[HEAPNUM]={0};
unsigned long heap_real_start[HEAPNUM]={0};
size_t heap_size[HEAPNUM]={0};

unsigned char *program = (unsigned char *)&__sgx_start;
size_t program_size = (addr_t)&__sgx_end - (addr_t)&__sgx_start;
size_t code_section_size;
size_t data_section_size;
size_t bss_section_size;
unsigned total_code_page_num;
int OcallTime = 0;

//addr_t __stack_start = (__sgx_data_end & (~0xFFF)) - 0x100000;
addr_t __sgx_data_end = (addr_t)_SGXDATA_BASE + 0x1e00000;
addr_t __stack_start = (__sgx_data_end & (~0xFFF));

static Elf64_Ehdr *pehdr;
static Elf64_Shdr *pshdr;
static size_t n_symtab, _n_symtab = 1;
static size_t real_n_symtab=0;
static Elf64_Sym *symtab;
char *strtab=NULL;
char *shstrtab=NULL;
static Elf64_Sym *main_sym;
Elf64_Addr textSectionRealAddress = 0;
Elf64_Addr rodataSectionRealAddress = 0;
Elf64_Addr rdataSectionLogicAddress = 0;
Elf64_Addr dataSectionRealAddress = 0;
Elf64_Addr dataSectionLogicAddress = 0;
Elf64_Addr bssSectionRealAddress = 0;
Elf64_Addr bssSectionLogicAddress = 0;

//info of the protected program
size_t CodeStartVirtAddr;      //typically, its the virtual address of memcpy
size_t EntryPageShadowStartAddr; //the base address of the page that contains enclave main
size_t EntryPageShadowStartIndex;
int EntryPageStartIndex;                //the start index of the page


using namespace std;
std::vector<Elf64_Sym *> sortSymbol;
int *sym_ndx;

//dereference measurement
#if Do_Event_Measure
//number of call
size_t callEventNum;
//number of ret
size_t retEventNum;
//numbre of fallthrough
size_t fallthrough;
//number of data dereference
size_t dataDereferenceEventNum;
#endif

// PathOram Pool dataStruct
struct OramPool{
    PathORAM *ringOram;
    char *cacheStartAddr;
    int *cacheIndexArray;
    int currentPtr;
    int *cacheSlotValidArray;
#ifdef DEBUG_DATA_TRACE
    std::map<int,size_t> pageMACs;
#endif
};
struct OramPool DataPool_smallData;
struct OramPool DataPool_bigData;

//for testing
size_t func_trace_print_count=0; //used for the start count of function trace
size_t call_ret_pair=0;

int shadowPageIndexStart_bigData; //the start index of the big objects
int shadowPageNumBig;  //the number of shadow pages for big objects

PathORAM *pathOram=NULL;
PathORAM *DATAOram = NULL;
PathORAM *DATABIGOram = NULL;
char *ExcutionPAGE1=NULL;
char *ExcutionPAGE2=NULL;
char *DataPAGE1=NULL;
char *DataPAGEBig=NULL;
int *DataCacheIndex=NULL;
int *DataBigCacheIndex=NULL;
int *CodeCacheIndex=NULL;
unsigned long targetVirtualAddress;
unsigned long translatedTargetAddress;

/*
 * After loading the metadata,
 * rel.r_offset = [ the index of the relocation source : the offset from the source ]
 */
size_t n_rel;               /* # of relocation tables */
size_t *n_reltab;           /* # of relocation entry */
static Elf64_Rela **reltab; /* array of pointers to relocation tables */


uint64_t rounddown(uint64_t align, uint64_t n)
{
    return (n / align) * align;
}

static uint32_t get_rand(void)
{
    uint32_t val;
    sgx_read_rand((unsigned char *)&val, sizeof(uint32_t));
    return val;
}

void *reserve_data(size_t size, size_t align)
{
    static void *data_end = _SGXDATA_BASE;
    void *ret = (void *)rounddown(align, (addr_t)data_end+(align-1));
    data_end = (void *)((addr_t)ret+rounddown(align, size+(align-1)));
    return ret;
}

bool is_available(uint8_t *base, size_t index, size_t size)
{
    for (unsigned i = 0;i < size;++i)
        if (base[index+i]) return false;
    return true;
}

void *reserve_code(size_t size, size_t align)
{
    static void *code_end = _SGXCODE_BASE;
    void *ret = (void *)rounddown(align, (addr_t)code_end+(align-1));
    code_end = (void *)((addr_t)ret+rounddown(align, size+(align-1)));
    return ret;
}

void *reserve(Elf64_Xword flags, size_t size, size_t align)
{
    if (flags & 0x4) return reserve_code(size, align);
    return reserve_data(size, align);
}

Elf64_Addr updateSymbolAddress(Elf64_Xword flags, Elf64_Addr address){
    if(flags & 0x4) return address - VIRTUAL_CODE + (Elf64_Addr)_SGXCODE_BASE;
    return address - VIRTUAL_DATA + (Elf64_Addr)_SGXDATA_BASE;
}

#define STR_EQUAL(s1, s2, n) \
    str_equal((const uint8_t *)(s1), (const uint8_t *)(s2), (n))
uint8_t str_equal(const uint8_t *s1, const uint8_t *s2, size_t n) {
    for (unsigned i = 0;i < n;++i)
        if (s1[i] != s2[i])
            return 0;
    return 1;
}

#define STR_STARTWITH(s1, s2, n)\
    str_startwith((const uint8_t *)(s1), (const uint8_t *)(s2), (n))
uint8_t str_startwith(const uint8_t *s1, const uint8_t *s2, size_t n) {
    for (unsigned i = 0;i < n;++i)
        if (s1[i] != s2[i])
            return 0;
    return 1;
}    
static void validate_ehdr(void)
{
    static const unsigned char expected[EI_NIDENT] =
    {
        [EI_MAG0] = ELFMAG0,
        [EI_MAG1] = ELFMAG1,
        [EI_MAG2] = ELFMAG2,
        [EI_MAG3] = ELFMAG3,
        [EI_CLASS] = ELFCLASS64,
        [EI_DATA] = byteorder,
        [EI_VERSION] = EV_CURRENT,
        [EI_OSABI] = ELFOSABI_SYSV,
        [EI_ABIVERSION] = 0
    };

    if ((pehdr = GET_OBJ(Elf64_Ehdr, 0)) == NULL)
        dlog("%u: Ehdr size", __LINE__);

    if (!str_equal(pehdr->e_ident, expected, EI_ABIVERSION)
            || pehdr->e_ident[EI_ABIVERSION] != 0
            || !str_equal(&pehdr->e_ident[EI_PAD], &expected[EI_PAD],
                EI_NIDENT - EI_PAD))
        dlog("%u: Ehdr ident", __LINE__);

    if (pehdr->e_version != EV_CURRENT)
        dlog("%u: Ehdr version", __LINE__);

    /* ELF format check - relocatable */
    if (pehdr->e_type != ET_REL)
        dlog("%u: Ehdr not relocatable", __LINE__);

    /* check the architecture - currently only support x86_64 */
    if (pehdr->e_machine != EM_X86_64)
        dlog("%u: Ehdr not x86_64", __LINE__);

    if (pehdr->e_shentsize != sizeof (Elf64_Shdr))
        dlog("%u: Shdr entry size", __LINE__);
}

void *get_buf(size_t size) {
    static addr_t heap_end = _HEAP_BASE;
    void *ret = (void *)heap_end;
    heap_end = heap_end + size;
    return ret;
}

/* search (section SE, OFS) from symtab - binary search can be applied */
static unsigned search(const Elf64_Half se, const Elf64_Addr ofs)
{
    // assuming that symbols are already sorted
    for (unsigned i = 0; i < n_symtab; ++i)
      if (symtab[i].st_shndx == se && symtab[i].st_value <= ofs
          && (i+1 >= n_symtab || symtab[i+1].st_value > ofs
              || symtab[i+1].st_shndx != se)) return i;
    return -1;
}

/*
 * process of sorting symbols
 * 1. sort symbols by {st_shndx, st_value, st_size}
 *    while managing "initial symndx to old symndx" mapping
 * 2. update the relocation table (r_info's r_sym)
 *    according to the "initial symndx to old symndx" mapping
 */
bool comp_sym(const Elf64_Sym *r, const Elf64_Sym *l)
{
    if (r->st_shndx != l->st_shndx)
        return r->st_shndx < l->st_shndx;
    else if (r->st_shndx < pehdr->e_shnum &&
            pshdr[r->st_shndx].sh_type == SHT_NOBITS)
        return r->st_size > l->st_size;
    else if (r->st_value != l->st_value)
        return r->st_value < l->st_value;
    else
        return r->st_size > l->st_size;
}
void sort_sym(void)
{
    // add all symbol pointers to the vector, and then sort them
    for (int i = 0; i < n_symtab; ++i) {
        
        if(STR_EQUAL(&strtab[symtab[i].st_name],"MBBStart_",9)){
            // printf("%s\n",&strtab[symtab[i].st_name]);
        }else{
            sortSymbol.push_back(&symtab[i]);
            real_n_symtab++;
        }
        
    }
    #ifdef DEBUG_LOADER
    printf("real_n_symtab:%d\n",real_n_symtab);
    #endif
    sort(sortSymbol.begin(), sortSymbol.end(), comp_sym);

    sym_ndx =(int *) malloc(real_n_symtab*sizeof(int));
    /* generate "initial symndx to new symndx" */
    for (int i = 0; i < real_n_symtab; ++i) {
        int tmp = ((unsigned long)sortSymbol[i] - (unsigned long)symtab) / sizeof(Elf64_Sym);
        sym_ndx[i] = tmp;
    }

    for(int i=0; i < real_n_symtab; ++i){
       int tmp = ((unsigned long)sortSymbol[i] - (unsigned long)symtab) / sizeof(Elf64_Sym);
    }
}

static void update_reltab(void)
{
    /* read shdr */
    if ((pshdr = GET_OBJ(Elf64_Shdr, pehdr->e_shoff)) == NULL
            || !CHECK_SIZE(pshdr, pehdr->e_shnum*sizeof(Elf64_Shdr)))
        dlog("%u: Shdr size", __LINE__);

    /* pointers to symbol, string, relocation tables */
    n_rel = 0;
    for (unsigned i = 0; i < pehdr->e_shnum; ++i) {
        if (pshdr[i].sh_type == SHT_RELA) ++n_rel;
        else if (pshdr[i].sh_type == SHT_SYMTAB) {
            symtab = GET_OBJ(Elf64_Sym, pshdr[i].sh_offset);
            n_symtab = pshdr[i].sh_size / sizeof(Elf64_Sym);
        } else if (pshdr[i].sh_type == SHT_STRTAB){
            if(shstrtab==NULL){
                shstrtab = GET_OBJ(char, pshdr[i].sh_offset);
            }else{
                strtab = GET_OBJ(char, pshdr[i].sh_offset);
            }
        }
    }
    n_reltab = (size_t *)get_buf(n_rel * sizeof(size_t));
    reltab = (Elf64_Rela **)get_buf(n_rel * sizeof(Elf64_Rela *));
    n_rel = 0;
    for (unsigned i = 0; i < pehdr->e_shnum; ++i) {
        if (pshdr[i].sh_type == SHT_RELA && pshdr[i].sh_size) {
            reltab[n_rel] = GET_OBJ(Elf64_Rela, pshdr[i].sh_offset);
            n_reltab[n_rel] = pshdr[i].sh_size / sizeof(Elf64_Rela);

            /* update relocation table: r_offset --> dst + offset */
            // assert(GET_OBJ(pshdr[pshdr[i].sh_link].sh_offset) == symtab);
            for (size_t j = 0; j < n_reltab[n_rel]; ++j) {
                unsigned dst = search(pshdr[i].sh_info, reltab[n_rel][j].r_offset);
                reltab[n_rel][j].r_offset =
                    REL_OFFSET(dst, reltab[n_rel][j].r_offset - symtab[dst].st_value);
            }
            ++n_rel;
        }
    }
}

static void fill_zero(char *ptr, Elf64_Word size) {
    while (size--) ptr[size] = 0;
}
static void cpy(char *dst, char *src, size_t size) {
    while (size--) dst[size] = src[size];
}

#ifndef NOSGX
#include "ocall_stub.cpp"
#include "ocall_stub_table.cpp"
#else
#include "nosgx_ocall_stub.cpp"
#endif

unsigned clock_address=0;
unsigned secureCopy_address = 0;
static unsigned char find_special_symbol(const char* name, const size_t i)
{
    if (STR_EQUAL(name, "dep.bdr\0", 8)) {
        sortSymbol[i]->st_value = (Elf64_Addr)_SGXDATA_BASE;
        sortSymbol[i]->st_size = 0;
        dlog(&strtab[sortSymbol[i]->st_name]);
        return 1;
    } else if (STR_EQUAL(name, "ocall.bdr\0", 10)) {
        sortSymbol[i]->st_value = (Elf64_Addr)_SGXCODE_BASE;
        sortSymbol[i]->st_size = 0;
        dlog(&strtab[sortSymbol[i]->st_name]);
        return 1;
    } else if (STR_EQUAL(name, "sgx_ocall.loader\0", 14)) {
        // sortSymbol[i]->st_value = (Elf64_Addr)do_sgx_ocall_random;
        dlog("%s: %lx", &strtab[sortSymbol[i]->st_name], sortSymbol[i]->st_value);
        return 1;
    } else if (STR_EQUAL(name, "rand_internal\0", 14)) {
        sortSymbol[i]->st_value = (Elf64_Addr)get_rand;
        dlog("%s: %lx", &strtab[sortSymbol[i]->st_name], sortSymbol[i]->st_value);
        return 1;
    } else if (STR_EQUAL(name, "_stack\0", 7)) {
        sortSymbol[i]->st_value = (Elf64_Addr)reserve_data(sortSymbol[i]->st_size, 64);//TODO stack may need to align to page
        dlog("%s: %lx", &strtab[sortSymbol[i]->st_name], sortSymbol[i]->st_value);
        return 1;
    } else if(STR_STARTWITH(name,"_heap_chk\0",9)){ 
        if(STR_EQUAL(name,"_heap_chk0\0",10)){
            heap_virtual_start[0] = sortSymbol[i]->st_value;
            // printf("_heap_chk0 0x%x\n",sortSymbol[i]->st_value);
        } else if(STR_EQUAL(name,"_heap_chk1\0",10)){
            heap_virtual_start[1] = sortSymbol[i]->st_value;
            #ifdef DEBUG_LOADER
            printf("_heap_chk1 0x%x\n",sortSymbol[i]->st_value);
            #endif
        } 
        // else if(STR_EQUAL(name,"_heap_chk2\0",10)){
        //     heap_virtual_start[2] = sortSymbol[i]->st_value;
        // }
    // }else if(STR_EQUAL(name,"memcpy\0",7)){
    }else if(STR_EQUAL(name,"memcpy_org\0",11)){
        // CodeStartVirtAddr = sortSymbol[i]->st_value;
    }else if(STR_EQUAL(name,"enclave_main\0",13)){
        EntryPageShadowStartAddr = sortSymbol[i]->st_value & ~(0x7ff);
        EntryPageShadowStartIndex = EntryPageShadowStartAddr>>11;
        EntryPageStartIndex = *(int *)updateSymbolAddress(pshdr[sortSymbol[i]->st_shndx].sh_flags,
                            EntryPageShadowStartAddr);
        // printf("EntryPageShadowStartAddr %lx:%lx:%d\n",EntryPageShadowStartAddr,EntryPageShadowStartIndex,EntryPageStartIndex);

    }else if (STR_EQUAL(name,"clock\0",6)){
         clock_address= sortSymbol[i]->st_value;
    }else if (STR_EQUAL(name,"secureCopy\0",11)){
         secureCopy_address = sortSymbol[i]->st_value;
    }

    //check arguments
    if(STR_EQUAL(programName,"cjpeg\0",6) || STR_EQUAL(programName,"djpeg\0",6)){
        if(STR_EQUAL(name,"infilename\0",11)){
            argvForProgram[2]=(char *)sortSymbol[i]->st_value;
        }else if(STR_EQUAL(name,"outfilename\0",12)){
            argvForProgram[3]=(char *)sortSymbol[i]->st_value;
        }
    }
    return 0;
}
static void copySections(){
    for(unsigned i =0; i<pehdr->e_shnum; i++ ){
        size_t sectionOffset = pshdr[i].sh_offset;
        size_t sectionSize= pshdr[i].sh_size;
        size_t align = pshdr[i].sh_addralign;
        if(STR_EQUAL(&shstrtab[pshdr[i].sh_name],".text\0",6)){
            textSectionRealAddress=  (Elf64_Addr)_SGXCODE_BASE + sectionOffset;
            CodeStartVirtAddr = 0x400000+sectionOffset;
            #ifdef DEBUG_LOADER
            printf("textSection start: 0x%lx 0x%lx, sectionOffset:%lx, size 0x%lx\n",CodeStartVirtAddr,textSectionRealAddress,sectionOffset,sectionSize);
            #endif
            code_section_size = sectionSize;

            cpy((char *)textSectionRealAddress, GET_OBJ(char, sectionOffset), sectionSize);
            continue;
        }
        if(STR_EQUAL(&shstrtab[pshdr[i].sh_name],".rodata\0",8)){
            rodataSectionRealAddress=  (Elf64_Addr)_SGXCODE_BASE + sectionOffset;
            rdataSectionLogicAddress = pshdr[i].sh_addr;
            #ifdef DEBUG_LOADER
            printf("rodataSection start: 0x%lx,dataSectionLogicAddress:0x%lx,sectionSize: 0x%lx\n",rodataSectionRealAddress,rdataSectionLogicAddress,sectionSize);
            #endif
            cpy((char *)rodataSectionRealAddress, GET_OBJ(char, sectionOffset), sectionSize);
            continue;
        }
        if(STR_EQUAL(&shstrtab[pshdr[i].sh_name],".data\0",6)){
            dataSectionRealAddress =  (Elf64_Addr)_SGXDATA_BASE + sectionOffset;
            dataSectionLogicAddress = pshdr[i].sh_addr;
            #ifdef DEBUG_LOADER
            printf("dataSection start: 0x%lx, dataSectionLogicAddress:0x%lx\n",dataSectionRealAddress,dataSectionLogicAddress);
            #endif
            data_section_size = sectionSize;
            cpy((char *)dataSectionRealAddress, GET_OBJ(char, sectionOffset), sectionSize);
            size_t address_dataSection = dataSectionRealAddress;
            for(int i=0;i<data_section_size;i+=0x4){
                #ifdef DEBUG_LOADER
                if(*(unsigned *)address_dataSection==0x9020)
                    printf("===|||||||||==here %lx:%lx\n",address_dataSection,*(unsigned *)address_dataSection);
                #endif
                address_dataSection+=0x4;
            }
            continue;
        }
        if(STR_EQUAL(&shstrtab[pshdr[i].sh_name],".bss\0",5)){
            size_t virtualAddress = pshdr[i].sh_addr;
            bssSectionRealAddress =  (Elf64_Addr)_SGXDATA_BASE + virtualAddress - 0x400000;
            bssSectionLogicAddress = virtualAddress;
            #ifdef DEBUG_LOADER
            printf("BBSSection start: 0x%lx, size:0x%lx\n",bssSectionRealAddress,sectionSize);
            #endif
            bss_section_size = sectionSize;
            // cpy((char *)dataSectionRealAddress, GET_OBJ(char, sectionOffset), sectionSize);
            // memset(bssSectionRealAddress,0,sectionSize);
            continue;
        }
    }
}

static void load(void)
{
    Elf64_Addr last_off = (Elf64_Addr)-1;
    Elf64_Addr last_st_value = (Elf64_Addr)-1;
    Elf64_Xword last_size = 0;
    Elf64_Addr sectionOffset;
    Elf64_Addr sectionVirtualAddr; 
    unsigned shndx = -1;
    copySections();
    for (unsigned i = 1; i < real_n_symtab; ++i, ++_n_symtab) {
        if (shndx != sortSymbol[i]->st_shndx) {
            // printf("------------------st_shndx = %d-------------------\n",sortSymbol[i]->st_shndx);
            last_off = (Elf64_Addr)-1;
            last_st_value = (Elf64_Addr)-1;
            last_size = 0;
            shndx = sortSymbol[i]->st_shndx;
            if(sortSymbol[i]->st_shndx != SHN_ABS){
                sectionOffset = pshdr[sortSymbol[i]->st_shndx].sh_offset;
                sectionVirtualAddr = pshdr[sortSymbol[i]->st_shndx].sh_addr;
            }
        }

        unsigned char found = sortSymbol[i]->st_name ?
            find_special_symbol(&strtab[sortSymbol[i]->st_name], i) : 0;

        if(sortSymbol[i]->st_shndx == SHN_ABS || sortSymbol[i]->st_shndx == SHN_UNDEF){
            break;
        }else if (sortSymbol[i]->st_shndx == SHN_COMMON && !found) {
            sortSymbol[i]->st_value = (Elf64_Addr)updateSymbolAddress(0, sortSymbol[i]->st_value);
            fill_zero((char *)sortSymbol[i]->st_value, sortSymbol[i]->st_size);
            // printf("123address:%lx,size:%lx\n",sortSymbol[i]->st_value,sortSymbol[i]->st_size);
        } else if (!found) {
            // symoff is the offset in our loading file
            Elf64_Addr symoff = sortSymbol[i]->st_value - sectionVirtualAddr + sectionOffset;
            /* potentially WEAK bind */
            if (last_off <= symoff && symoff < (last_off + last_size)) {
                sortSymbol[i]->st_value = last_st_value + symoff - last_off;
            } else {
                /* find main */
                if (sortSymbol[i]->st_value == pehdr->e_entry)
                    main_sym = sortSymbol[i];

                if(ELF32_ST_TYPE(sortSymbol[i]->st_info)==STT_FUNC ){
                    Elf64_Xword addr_start = sortSymbol[i]->st_value;
                    Elf64_Xword addr_end = addr_start + sortSymbol[i]->st_size;

                    // if(sortSymbol[i]->st_size > SHADOWPAGESIZE){
                    //     printf("function large than 1 page, %lx\n",sortSymbol[i]->st_value);    
                    //     addr_start = (addr_start >> SHADOWPAGEWIDE);
                    //     addr_end = (addr_end >> SHADOWPAGEWIDE) + 1;
                    //     printf("    pageStart, %lx num, %lx\n",addr_start,addr_end - addr_start);
                    //     ContinuousPages *cp = new ContinuousPages(addr_start,addr_end - addr_start-1);
                    //     ContinuousCodePagesVector.push_back(cp);
                    // }
                    // unsigned long start_frame = sortSymbol[i]->st_value >> SHADOWPAGEWIDE;
                    // unsigned long end_frame = (addr_start + sortSymbol[i]->st_size) >> SHADOWPAGEWIDE;
                    // if(start_frame!=end_frame){
                    //     ContinuousPages *cp = new ContinuousPages(start_frame,end_frame - start_frame);
                    //     ./a  .push_back(cp);
                    // }
                    
                }
                sortSymbol[i]->st_value = (Elf64_Addr)updateSymbolAddress(pshdr[sortSymbol[i]->st_shndx].sh_flags,
                            sortSymbol[i]->st_value);

                /* fill zeros for .bss section .. otherwise, copy from file */
                if (pshdr[sortSymbol[i]->st_shndx].sh_type == SHT_NOBITS) {

                    fill_zero((char *)sortSymbol[i]->st_value, sortSymbol[i]->st_size);
                    #ifdef DEBUG_LOADER
                    //printf("address:%lx,size:%lx\n",sortSymbol[i]->st_value,sortSymbol[i]->st_size);
                    #endif
                } else {
                    size_t dataSize = sortSymbol[i]->st_size;
                    size_t align = pshdr[sortSymbol[i]->st_shndx].sh_addralign;
                    
                    // for we have already cp the text section, so we just update the symbol st_value with the textSection base
                    if(STR_EQUAL(&shstrtab[pshdr[sortSymbol[i]->st_shndx].sh_name],".text\0",6)){

                    }else{
                        cpy((char *)sortSymbol[i]->st_value, GET_OBJ(char, symoff), dataSize);
                    }

                    /* update last values */
                    last_size = dataSize; 
                    last_off = symoff;
                    last_st_value = sortSymbol[i]->st_value;
                }
            }
        }
    }
}

//set the page table 
static unsigned long pagetables[0x600+(0x400*4*6+1)*2]={0};
static unsigned long* pagetable = &pagetables[0x600];

static unsigned long *startStackPage = &pagetable[1024*4*2];

#define SHADOW_START_ADDR 0x400000
#define SHADOW_END_ADDR 0x1800000
#define SHADOW_START_INDEX (SHADOW_START_ADDR >> SHADOWPAGEWIDE)
#define HEAP_CHK_SIZE 0x100000
#define SHADOW_TO_VIRTUAL_OFFSET(shadowAddr,virtAddr) (virtAddr - shadowAddr)
char *dirtyStatic=NULL;

//we leverage the unused space in pagetable
// 0x00(r15): reserved for _loader_stack_save
// 0x08(r15): reserved for _virtual_stack_save
// 0x10(r15): reserved for ocall_table's address
// 0x18(r15): reserved for swapCachePageBack function's address

// 0x20(r15): reserved for memcpy dest shadow address
// 0x28(r15): reserved for memcpy src  shadow address
// 0x30(r15): the flag indicated the initialization of heap
// 0x38(r15): reserved for virtual address
// 0x40(r15): shadow address dereferencing function, the value in r14 is the target address
// 0x50(r15): the offset of shadow stack and virtual stack address
// 0x60 : dereference_data
// 0x70 : heapObliviousInit
// 0x80 : dereference_ControlFlow_ret
// 0x90 : fallthourgh, however, we merge it with dereference_ControlFlow_Fallthrough;
void fillPagetable(){
    int i,j;
    unsigned long offset_shadow_and_virtual;
    uint64_t frame_start;
    total_code_page_num = (code_section_size + SHADOWPAGESIZE) / SHADOWPAGESIZE + 1;

    //update ocall
    pagetable[2]=(unsigned long)ocall_table;
        
    #if PAGE_SWAP_AT_OCALL
        pagetable[3] = (unsigned long)swapCachePageBack+4;
    #else
        pagetable[3] = (unsigned long)swapCachePageBack;
    #endif
        
    // pagetable[4]=(unsigned long)pathORAMShuffling;
    pagetable[6]=0;
    heap_is_inited = &pagetable[6];
    pagetable[8]=(unsigned long)dereference_ControlFlow_call + 4;
    pagetable[12]=(unsigned long)dereference_data +4;
    pagetable[14] = (unsigned long)heapObliviousInit;
    pagetable[16] = (unsigned long)dereference_ControlFlow_ret+4;
    pagetable[18]=(unsigned long)dereference_ControlFlow_Fallthrough + 4;
 
    //code
    offset_shadow_and_virtual = SHADOW_TO_VIRTUAL_OFFSET(SHADOW_START_ADDR,(long)_SGXCODE_BASE);
    for(i=(SHADOW_START_ADDR>>SHADOWPAGEWIDE);i<(SHADOW_END_ADDR>>SHADOWPAGEWIDE)+total_code_page_num;i++){
            pagetable[i]= offset_shadow_and_virtual;
    }

    //we do not shuffle the memcpy, memset and etc. 
    i=(TARGET_ADD>>SHADOWPAGEWIDE);
    // printf("%lx=====%lx,%d,%lx\n",CODE_START_ADD+code_section_size,TARGET_ADD,total_code_page_num,TARGET_ADD+(total_code_page_num<<11));
    #if OBLIVIOUSSHUFFLE
    i=(TARGET_ADD>>SHADOWPAGEWIDE);
    for(int itr=0;itr<VALID_PAGE_NUM;itr++,i++){
             pagetable[i]= 0;
    }
    #endif

    //set data rodataSectionRealAddress
    // if (dataSectionLogicAddress == 0){
    //     printf("dataSectionLogicAddress = 0\n");


    // }else{
        i=(dataSectionLogicAddress>>SHADOWPAGEWIDE);
        offset_shadow_and_virtual = SHADOW_TO_VIRTUAL_OFFSET(dataSectionLogicAddress,(long)dataSectionRealAddress);
    // }

    for(;i<0x2e00;i++){
        pagetable[i]= offset_shadow_and_virtual;
    }

    //stack
    offset_shadow_and_virtual = SHADOW_TO_VIRTUAL_OFFSET(SHADOW_END_ADDR,(long)_SGXSTACK_BASE);
    for(i=0x1800;i>=0x1700;i--){
        for(j=0;j<(1<<(12-SHADOWPAGEWIDE));j++)
            pagetable[i*2-j]= offset_shadow_and_virtual;
    }
    pagetable[10]=(unsigned long)offset_shadow_and_virtual;
    return;
}

void calculateHeap(int i){
    uint64_t start = heap_virtual_start[i],end;
    uint64_t addr = (start + 0x1000) & (~0xfff);
    end = (heap_virtual_start[i] + HEAP_CHK_SIZE) & (~0xfff);
    heap_size[i]=end - addr;
    // printf("heap[%d]:0x%x,size:0x%x\n",i,start,heap_size[i]);

    heap_real_start[i]=(long)_SGXDATA_BASE + addr - (0x400<<12);
    heap_virtual_start[i] = addr;
    // printf("heap->transfer:0x%x\n",heap_real_start[i]);
}

void (*entry)();
void enclave_main(int argc,char **argv)
{

    if(argc > 1){
        #ifdef DEBUG_LOADER
        printf("argc:%d,appName:%s\n",argc,argv[1]);
        #endif
        programName = argv[1];

        if(STR_EQUAL(programName,"cjpeg\0",6) || STR_EQUAL(programName,"djpeg\0",6)){
            if(argc!=4){
                printf("error! cjpeg and djpeg program should set inputfile and outputfile, eg:\n");
                printf("./app cjpeg inputfile outputfile\n");
                sgx_exit(1);
            }
            argvForProgram = (char**)malloc(argc * sizeof(char *));
        }
    }else{
        printf("argc==%d please specify app program's name\n",argc);
        sgx_exit(1);
    }
    

    int i=0;
    #ifdef DEBUG_LOADER
    printf("program at %p (%lx)\n", program, program_size);
    printf(".sgxcode = %p\n", _SGXCODE_BASE);
    printf(".sgxcode_end = %p\n", (void *)&__sgx_code_end);

    printf(".sgxdata = %p\n", _SGXDATA_BASE);

    printf("__sgx_start = %p\n", &__sgx_start);
    printf("__sgx_end = %p\n", &__sgx_end);

    printf("__sgx_code = %p\n", &__sgx_code);
    printf("__sgx_code_end = %p\n", &__sgx_code_end);

    printf("__sgx_code_pathOram = %p\n", &__sgx_code_pathOram);
    printf("__sgx_code_pathOram_end = %p\n", &__sgx_code_pathOram_end);

    printf("__sgx_data_pathOram = %p\n", &__sgx_data_pathOram);
    printf("__sgx_data_pathOram_end = %p\n", &__sgx_data_pathOram_end);

    printf("__sgx_data_big_pathOram = %p\n", &__sgx_data_big_pathOram);
    printf("__sgx_data_big_pathOram_end = %p\n", &__sgx_data_big_pathOram_end);

    printf("__elf_end = %p\n", &__elf_end);

    printf("heap base = %lx\n", _HEAP_BASE);
    printf("pagetable base = %lx\n", pagetable);
    #endif

    validate_ehdr();
    update_reltab();
    sort_sym();
    load();

    // relocate();
    fillPagetable();
    for(;i<HEAPNUM;i++){
        calculateHeap(i);
    }
    #ifdef DEBUG_LOADER
    printf("sgx_stack start: 0x%lx\n",(unsigned long)__stack_start);
    #endif

    //entry = (void (*)())(main_sym->st_value);
    dlog("main: %p", entry);


    size_t ORAMProtectedCodeStartAddress = (size_t)textSectionRealAddress + SHADOWPAGESIZE * IGNOREDPageNum;


    int pageNum = (code_section_size + SHADOWPAGESIZE) / SHADOWPAGESIZE  - IGNOREDPageNum;

    int endNum = *(int *)(ORAMProtectedCodeStartAddress+(pageNum<<11));
    
    size_t destAddressTemp = (size_t)&__sgx_code_pathOram + SHADOWPAGESIZE*4;
    
    #if OBLIVIOUSSHUFFLE
    pathOram = new PathORAM(destAddressTemp + SHADOWPAGESIZE*CACHENUM,ORAMProtectedCodeStartAddress,pageNum,SHADOWPAGESIZE,TARGET_START_INDEX,CODE_STASHSIZE);

    //init block index in the Code Cache
    CodeCacheIndex = (int *)(malloc(sizeof(int)*CACHENUM));
    for(int i=0;i<CACHENUM;i++){
        CodeCacheIndex[i]=0;
    }

    ExcutionPAGE1= (char*)destAddressTemp;

    // pathOram->setCacheInfo((size_t)ExcutionPAGE1,CodeCacheIndex,CACHENUM);
    // pathOram->checkInStashOrOramTree();
    
    //copy the first CACHENUM code into the cache
    int start=0x0;
    for(int index=0+start;index<CACHENUM+start;index++){
        // int index = 1;
        #ifdef DEBUG_LOADER
        printf("index:%lx :> %lx\n",ACCESS_TO_PAGEINDEX(index+TARGET_START_INDEX)<<11,ExcutionPAGE1+index*SHADOWPAGESIZE);
        #endif
        int shadowIndex = ACCESS_TO_PAGEINDEX(index+TARGET_START_INDEX);
        int abc=PAGEINDX_TO_ACCESS_INDEX(shadowIndex);
        #ifdef DEBUG_LOADER
        printf("%lx,%lx,%d\n",index+TARGET_START_INDEX,shadowIndex<<11,abc);
        #endif
        pathOram->setCacheInfo((size_t)ExcutionPAGE1,CodeCacheIndex,CACHENUM);

        int tempRecord= CodeCacheIndex[index];

        pathOram->Access(index+TARGET_START_INDEX,tempRecord,(size_t)ExcutionPAGE1+index*SHADOWPAGESIZE,true);
        
        pagetable[ACCESS_TO_PAGEINDEX(index+TARGET_START_INDEX)] = 
                            (size_t)(ExcutionPAGE1+index*SHADOWPAGESIZE) - (ACCESS_TO_PAGEINDEX(index+TARGET_START_INDEX)<<SHADOWPAGEWIDE);
        //set the block index in code cache
        CodeCacheIndex[index]=index+TARGET_START_INDEX;
        // printf("CodeCacheIndex:[%lx],%lx\n",index,index+TARGET_START_INDEX);

        // printf("cache state:");
        // printf("\n========================cache state: start ================\n");
        // for(int indexTemp=0;indexTemp<CACHENUM;indexTemp++){
        //     printf("%d\t",CodeCacheIndex[indexTemp]);
        // }
        // printf("\n========================cache state: end ================\n");


        // pathOram->setCacheInfo((size_t)ExcutionPAGE1,CodeCacheIndex,CACHENUM);
        // pathOram->checkInStashOrOramTree();

        
        int result = comparePage((size_t)ExcutionPAGE1+index*SHADOWPAGESIZE,ORAMProtectedCodeStartAddress+SHADOWPAGESIZE*index);
        if(result != -1){
            printf("    there is something wrong============%d\n",result);
            printf("    org index:%x, dest index:%x\n",*(int *)(ORAMProtectedCodeStartAddress+SHADOWPAGESIZE*index),*(int *)(ExcutionPAGE1+index*SHADOWPAGESIZE));
            printf("    org:%x, dest:%x, %d\n",ORAMProtectedCodeStartAddress+SHADOWPAGESIZE*index,ExcutionPAGE1+index*SHADOWPAGESIZE);
            while(1){}
        }else{
            int magic = *(int *)((size_t)ExcutionPAGE1+index*SHADOWPAGESIZE);
            #ifdef DEBUG_LOADER
            printf("magic num:%d\n\n",magic);
            #endif
        }                        
    }  

// pathOram->Access(1+TARGET_START_INDEX,(size_t)ExcutionPAGE1,true);


//     size_t starttime = sgx_clock();

// for(int itr=0;itr<200000;itr++){
//     for(int index=0;index<50;index++){
//         pathOram->Access(index+TARGET_START_INDEX,(size_t)ExcutionPAGE1,true);
//     }
    
// }   
//     starttime = sgx_clock()-starttime;
//     printf("timestamp%.13f\n",starttime/(double)1000000L);


    #endif //OBLIVIOUSSHUFFLE   

    //check the pages
    // printf("org:%x, dest:%x finale:%lx\n",originalAddress,(size_t)destAddress,destAddressTemp);
    // for(int d=0;d<50000;d++){
    //     for(int itrPage =0;itrPage < pageNum;itrPage++){
    //     // for(int itrPage =0;itrPage<3;itrPage++){
    //         // a->ReadPath(itrPage,itrPage+1,(size_t)&__sgx_code_pathOram);

    //         int pageIndex = (get_rand()%(pageNum));
    //         int cacheIndex = (get_rand()%(CACHENUM));
    //         // cacheIndex = 0;

    //         bool findInCach= false;
    //         for(int i=0;i<CACHENUM;i++){
    //             if(CodeCacheIndex[i]==pageIndex+1){
    //                 findInCach= true;
    //             }
    //         }
    //         if(findInCach) continue;

    //         printf("=== round:%d === Access: itr:%d=== pageNum:%d cacheIndex:%d dest:%lx\n",d,itrPage+1,pageIndex+1,cacheIndex,(size_t)ExcutionPAGE1 + cacheIndex*SHADOWPAGESIZE);
            
             
    //         int tempRecord= CodeCacheIndex[cacheIndex];
    //         CodeCacheIndex[cacheIndex] = pageIndex+TARGET_START_INDEX;  
    //         if(pathOram->Access(pageIndex+TARGET_START_INDEX,tempRecord,(size_t)ExcutionPAGE1 + cacheIndex*SHADOWPAGESIZE,true)){
    //             // printf("failed\n");
    //             while(1){}
    //         }
            

    //         pathOram->setCacheInfo((size_t)ExcutionPAGE1,CodeCacheIndex,CACHENUM);
    //         pathOram->checkInStashOrOramTree();

    //         int result = comparePage((size_t)ExcutionPAGE1+cacheIndex*SHADOWPAGESIZE,ORAMProtectedCodeStartAddress+SHADOWPAGESIZE*pageIndex);
    //         if(result != -1){
            
    //             printf("    there is something wrong============%d\n",result);
    //             printf("    org:%x, dest:%x, %x\n",ORAMProtectedCodeStartAddress+SHADOWPAGESIZE*pageIndex,*(int *)(ORAMProtectedCodeStartAddress+SHADOWPAGESIZE*pageIndex),ExcutionPAGE1+ cacheIndex*SHADOWPAGESIZE,*(int *)(ExcutionPAGE1+ cacheIndex*SHADOWPAGESIZE));
    //             while(1){}
    //         }else{
    //             printf("magic num:");
    //             for(int i=0;i<CACHENUM;i++){
    //                 printf("%d,%d,\t",CodeCacheIndex[i],*(int *)(ExcutionPAGE1+SHADOWPAGESIZE*i));
    //             }
    //             printf("\n\n");
    //         }

    //     }
    // }

    OMeasureInit();

    if(STR_EQUAL(programName,"cjpeg\0",6) || STR_EQUAL(programName,"djpeg\0",6)){
    #ifdef DEBUG_LOADER
        for (int i=1;i<argc;i++){
            printf("argvForProgram[%d]:%lx\n",i,argvForProgram[i]);
        }
        printf("arg[2]:%s\n",argv[2]);
        printf("arg[3]:%s\n",argv[3]);
        printf("argvForProgram[2]:%lx\n",getRealAddress((size_t)argvForProgram[2]));
        printf("argvForProgram[3]:%lx\n",getRealAddress((size_t)argvForProgram[3]));
    #endif
        copyingFromSGXToProgram((size_t)argvForProgram[2],argv[2],strlen(argv[2]));
        copyingFromSGXToProgram((size_t)argvForProgram[3],argv[3],strlen(argv[3]));
    }

    unsigned char *start_8 = (unsigned char *) &pagetables[0];
    __asm__ __volatile__ (
        "vmovdqa %0,%%ymm13\n"
     ::"m"(cacheOffset)
     );

    __asm__ __volatile__("lea %1,%%r15\n"
                         "mov $0x1000,%%r14\n"
                         "movb $0x1,-0x3000(%%r15,%%r14,1)\n"

                         "movq %%rsp,(%%r15)\n"
                         "mov %0,%%rsp\n"
                         //"and $0xffff000,%%rsp\n"
                         "add $0x10,%%rsp\n"
                         "mov $0x1800008,%%r13\n"
                         ::"m"(__stack_start),"m"(*pagetable));
    entry = (void (*)())(main_sym->st_value);
    entry();
    // printf("done\n");
   __asm__ __volatile__(
                         "movq %0,%%rsp\n"::"m"(_stack_save));
}

int comparePage(unsigned long src,unsigned long dest){
    char *srcC=(char *)src;
    char *destC=(char *)dest;
    int compared=0;
    while(compared<SHADOWPAGESIZE){
        if(srcC[compared]!=destC[compared]){
            break;
        }
        compared++;
    }
    if(compared!=SHADOWPAGESIZE){
        return compared;
    }else{
        return -1;
    }
}

//==============================Oblivous Functions=============================
static unsigned char getRandom_LessThan256(void){
    static unsigned char shuffle[64];
    static int i=0;
    i=i%64;
    if(i==0){
        sgx_read_rand(shuffle, sizeof(shuffle));
    }
    return shuffle[i++];
}

size_t heap_start_index;
size_t heap_big_start_index;
size_t data_section_start_index;
size_t bss_section_start_index;
size_t Oboundary;  //the boundary between the heap page and data page,

int CacheValid[DATACACHE_MIN]={1};
int CacheValidBig[DATACACHE_MIN]={1};
void initHeapBig(){
    #ifdef DEBUG_LOADER 
    printf("heap[%d]:%lx\n",BIGHEAPIndex,heap_virtual_start[BIGHEAPIndex]);
    printf("data:%lx:%d\n",heap_real_start[BIGHEAPIndex]+HEAPSIZE*IGNOREDHeapPageNumForBig,*(int *)(heap_real_start[BIGHEAPIndex]+HEAPSIZE*IGNOREDHeapPageNumForBig));
    #endif
    size_t originalBigHeapAddress =  (size_t)heap_real_start[BIGHEAPIndex]+HEAPSIZE*IGNOREDHeapPageNumForBig;

    shadowPageNumBig = (heap_size[BIGHEAPIndex] / HEAPSIZE) - IGNOREDHeapPageNumForBig-2;
    #ifdef DEBUG_LOADER 
    printf("===shadowPageNumBig:%ld\n",shadowPageNumBig);
    #endif
    size_t endAddressBig = originalBigHeapAddress + shadowPageNumBig*HEAPSIZE;
    #ifdef DEBUG_LOADER 
    printf("===originalHeapAddressEndBig:%lx,%d\n",endAddressBig,*(int *)endAddressBig);
    #endif
    heap_big_start_index = (heap_virtual_start[BIGHEAPIndex]+HEAPSIZE*IGNOREDHeapPageNumForBig)>>SHADOWPAGEWIDE;
    #ifdef DEBUG_LOADER 
    printf("===heap big start logic address:%lx,startIndex:%lx,endaddress:%lx\n",heap_big_start_index<<11,heap_big_start_index,(heap_big_start_index+shadowPageNumBig)<<11);
    #endif
    size_t destAddressTemp = (size_t)&__sgx_data_big_pathOram + SHADOWPAGESIZE*4;
    DataPAGEBig = (char*)destAddressTemp;
    DATABIGOram = new PathORAM(destAddressTemp + SHADOWPAGESIZE*DATACACHE,originalBigHeapAddress,shadowPageNumBig,SHADOWPAGESIZE,TARGET_DATA_START_INDEX,DATA_STASHSIZE);

    //init block index in the DataBig Cache
    DataBigCacheIndex = (int *)(malloc(sizeof(int)*DATACACHE));
    for(int i=0;i<DATACACHE;i++){
        DataBigCacheIndex[i]=0;
    }
    DATABIGOram->setCacheInfo((size_t)DataPAGEBig,DataBigCacheIndex,DATACACHE);
    //setup DataPool_bigData
    DataPool_bigData.cacheIndexArray = DataBigCacheIndex;
    DataPool_bigData.ringOram = DATABIGOram;
    DataPool_bigData.currentPtr=DATACACHE_MIN;
    DataPool_bigData.cacheSlotValidArray = CacheValidBig;
    DataPool_bigData.cacheStartAddr=(char *)destAddressTemp;
#ifdef DEBUG_LOADER
    printf("DataPool_bigData.cacheIndexArray = %lx\n",DataBigCacheIndex);
    printf("DataPool_bigData.ringOram = %lx\n",DATABIGOram);
    printf("DataPool_bigData.currentPtr = %lx\n",DATACACHE_MIN);
    printf("DataPool_bigData.cacheSlotValidArray = %lx\n",CacheValidBig);
    printf("DataPool_bigData.cacheStartAddr = %lx\n",destAddressTemp);
#endif
    //clear the heap PTEs
    for(int index=1;index<shadowPageNumBig;index++){
         size_t shadowIndex;
         BLOCK_INDEX_TO_LOGIC_INDEX_FOR_BIG(index,shadowIndex)
        //  printf("1%lx,Logic: %lx: %lx\n",index,shadowIndex<<11,(ACCESS_TO_DATA_PAGEINDEX(index))<<11);
        //  LOGIC_INDEX_TO_BLOCK_INDEX(shadowIndex,index)
        //  printf("2%lx,Logic: %lx: %lx\n",index,shadowIndex<<11,(ACCESS_TO_DATA_PAGEINDEX(index))<<11);
         pagetable[shadowIndex] = 0;             
    }

    for(int index=0;index<DATACACHE_MIN;index++){
        int logicIndex;
        BLOCK_INDEX_TO_LOGIC_INDEX_FOR_BIG(index+TARGET_DATA_START_INDEX,logicIndex);
        int blockIndex;
        LOGIC_INDEX_TO_BLOCK_INDEX_FOR_BIG(logicIndex,blockIndex);
        // printf("logicAddress:%lx,%d\n",logicIndex<<11,blockIndex);
    #ifdef DEBUG_LOADER   
        printf("access:%d\n",index+TARGET_DATA_START_INDEX);
    #endif
        DataPool_bigData.ringOram->Access(index+TARGET_DATA_START_INDEX,DataPool_bigData.cacheIndexArray[index],
                                                                        (size_t)DataPool_bigData.cacheStartAddr+index*SHADOWPAGESIZE*CACHESPARENUM,false);                                                          
        pagetable[logicIndex] = 
                            (size_t)(DataPool_bigData.cacheStartAddr+index*SHADOWPAGESIZE*CACHESPARENUM) - (logicIndex<<SHADOWPAGEWIDE);

        //set dataCacheIndex
        DataPool_bigData.cacheIndexArray[index] = index+TARGET_DATA_START_INDEX;                    
         
        int result = comparePage((size_t)DataPool_bigData.cacheStartAddr+index*SHADOWPAGESIZE*CACHESPARENUM,originalBigHeapAddress+SHADOWPAGESIZE*index);
    #ifdef DEBUG_LOADER    
        printf("access:%d\n",result);   
    #endif
        if(result != -1){
            printf("    there is something wrong============%d\n",result);
            printf("    org index:%x, dest index:%x\n",*(int *)(originalBigHeapAddress+SHADOWPAGESIZE*index),*(int *)(DataPool_bigData.cacheStartAddr+index*SHADOWPAGESIZE*CACHESPARENUM));
            printf("    org:%x, dest:%x, %d\n",originalBigHeapAddress+SHADOWPAGESIZE*index,DataPool_bigData.cacheStartAddr+index*SHADOWPAGESIZE*CACHESPARENUM);
            while(1){}
        }else{   
            int magic = *(int *)((size_t)DataPool_bigData.cacheStartAddr+index*SHADOWPAGESIZE*CACHESPARENUM);
            #ifdef DEBUG_LOADER
            printf("magic num:%d,%d\n\n",magic,DataBigCacheIndex[index]);  
            #endif
        }     
        DataPool_bigData.cacheSlotValidArray[index]=1;                
    }
    #ifdef DEBUG_LOADER 
    printf("initHeapBig inited \n");
    #endif

    return;
}
void heapObliviousInit(){
    size_t originalHeapAddress = (size_t)heap_real_start[HEAPIndex]+HEAPSIZE*IGNOREDHeapPageNum;
    int pageNum = (heap_size[HEAPIndex] / HEAPSIZE)  - IGNOREDHeapPageNum-1;

    size_t endAddress = originalHeapAddress + pageNum*HEAPSIZE;

    //.data global data
    data_section_start_index = dataSectionLogicAddress>>SHADOWPAGEWIDE;
    #ifdef DEBUG_LOADER 
    printf("===global data section start address:%lx,logic address:%lx,size:%lx,startIndex:%lx\n",dataSectionRealAddress,dataSectionLogicAddress,data_section_size,data_section_start_index);
    #endif
    //.bss
    bss_section_start_index = bssSectionLogicAddress>>SHADOWPAGEWIDE;
    #ifdef DEBUG_LOADER
    printf("===bss data section start logic address:%lx,startIndex:%lx\n",bssSectionLogicAddress,bss_section_start_index);
    #endif
    //heap
    heap_start_index = (heap_virtual_start[HEAPIndex]+HEAPSIZE*IGNOREDHeapPageNum)>>SHADOWPAGEWIDE;
    #ifdef DEBUG_LOADER
    printf("===heap[%d] start logic address:%lx,startIndex:%lx\n",HEAPIndex,heap_start_index<<11,heap_start_index);
    #endif
    //set the boundary
    Oboundary = pageNum - (DATA_SECTION_OBLIVIOUS_NUM + BSS_SECTION_OBLIVIOUS_NUM)-1;
    #ifdef DEBUG_LOADER
    printf("Oboundary:%lx\n",Oboundary);
    #endif

    
    // size_t address_dataSection = dataSectionRealAddress;
    // for(int i=0;i<data_section_size;i+=0x800){
    //     if(*(unsigned *)address_dataSection==0x9020)
    //         printf("here%lx:%lx\n",address_dataSection,*(unsigned *)address_dataSection);
    //     address_dataSection+=0x800;
    // }

    #if DATAOBLIVIOUSSHUFFLE
    size_t destAddressTemp = (size_t)&__sgx_data_pathOram + SHADOWPAGESIZE*4;
    DataPAGE1 = (char *)destAddressTemp;
    DATAOram = new PathORAM(destAddressTemp+SHADOWPAGESIZE*DATACACHE,originalHeapAddress,pageNum,SHADOWPAGESIZE,TARGET_DATA_START_INDEX,DATA_STASHSIZE);

    //init block index in the Data Cache
    DataCacheIndex = (int *)(malloc(sizeof(int)*DATACACHE));
    for(int i=0;i<DATACACHE;i++){
        DataCacheIndex[i]=0;
    }
    DATAOram->setCacheInfo((size_t)DataPAGE1,DataCacheIndex,DATACACHE);
    // DATAOram->checkInStashOrOramTree();

    //setup DataPool_smallData
    DataPool_smallData.cacheIndexArray = DataCacheIndex;
    DataPool_smallData.ringOram = DATAOram;
    DataPool_smallData.currentPtr=DATACACHE_MIN;
    DataPool_smallData.cacheSlotValidArray = CacheValid;
    DataPool_smallData.cacheStartAddr=(char *)destAddressTemp;

#ifdef DEBUG_LOADER
    printf("DataPool_smallData.cacheIndexArray = %lx\n",DataCacheIndex);
    printf("DataPool_smallData.ringOram = %lx\n",DATAOram);
    printf("DataPool_smallData.currentPtr = %lx\n",DATACACHE_MIN);
    printf("DataPool_smallData.cacheSlotValidArray = %lx\n",CacheValid);
    printf("DataPool_smallData.cacheStartAddr = %lx\n",destAddressTemp);
#endif    
    
    // for(int d=0;d<5;d++){
    //     for(int itrPage =0;itrPage < pageNum/2;itrPage++){
    //     // for(int itrPage =0;itrPage<3;itrPage++){
    //         // a->ReadPath(itrPage,itrPage+1,(size_t)&__sgx_code_pathOram);

    //         // int pageIndex = (rand()%(Oboundary-1));
    //         // int cacheIndex = (rand()%(DATACACHE_MIN));
    //          int pageIndex = itrPage;
    //         int cacheIndex = 0;
    //         // cacheIndex = 0;

    //         bool findInCache= false;
    //         for(int i=0;i<DATACACHE;i++){
    //             if(DataCacheIndex[i]==pageIndex+TARGET_DATA_START_INDEX){
    //                 findInCache= true;
    //             }
    //         }
    //         if(findInCache) continue;

    //         printf("=== round:%d === Access: itr:%d=== pageNum:%d cacheIndex:%d,pageIndex:%d dest,%lx\n",
    //                         d, 
    //                         itrPage+1,
    //                         pageIndex+TARGET_DATA_START_INDEX,
    //                         cacheIndex,
    //                         DataCacheIndex[cacheIndex],
    //                         (size_t)DataPAGE1 + cacheIndex*SHADOWPAGESIZE);
            
    //         int tempRecord= DataCacheIndex[cacheIndex];
    //         DataCacheIndex[cacheIndex] = pageIndex+TARGET_DATA_START_INDEX; 
    //         if(DATAOram->Access(pageIndex+TARGET_DATA_START_INDEX,tempRecord,(size_t)DataPAGE1 + cacheIndex*SHADOWPAGESIZE,true)){
    //             // printf("failed\n");
    //             while(1){}
    //         }

            
    //         // DATAOram->checkInStashOrOramTree();
            
    //         for(int i=0;i<DATACACHE_MIN;i++){
    //                 printf("(i,c):%d:%d\t",DataCacheIndex[i],*(int *)(DataPAGE1+SHADOWPAGESIZE*i));
    //         }
    //         printf("\n");

    //         DATAOram->checkWhetherInTheRightORAMTree();

    //         int result = comparePage((size_t)DataPAGE1+cacheIndex*SHADOWPAGESIZE,originalHeapAddress+SHADOWPAGESIZE*pageIndex);
    //         if(result != -1){
            
    //             printf("    there is something wrong============%d\n",pageNum);
    //             printf("    org:%x,%d, dest:%x, %x\n",originalHeapAddress+SHADOWPAGESIZE*pageIndex,*(int *)(originalHeapAddress+SHADOWPAGESIZE*pageIndex),DataPAGE1 + cacheIndex*SHADOWPAGESIZE,*(int *)(DataPAGE1+ cacheIndex*SHADOWPAGESIZE));
    //             while(1){}
    //         }else{
    //             printf("magic num:");
    //             for(int i=0;i<DATACACHE_MIN;i++){
    //                 printf("%d,%d\t",DataCacheIndex[i],*(int *)(DataPAGE1+SHADOWPAGESIZE*i));
    //             }
    //             printf("\n\n");
    //         }

    //     }
    // }
    //clear the heap PTEs

    for(int index=1;index<Oboundary-1;index++){
         size_t shadowIndex;
         BLOCK_INDEX_TO_LOGIC_INDEX(index,shadowIndex)
        //  printf("1%lx,Logic: %lx: %lx\n",index,shadowIndex<<11,(ACCESS_TO_DATA_PAGEINDEX(index))<<11);
        //  LOGIC_INDEX_TO_BLOCK_INDEX(shadowIndex,index)
        //  printf("2%lx,Logic: %lx: %lx\n",index,shadowIndex<<11,(ACCESS_TO_DATA_PAGEINDEX(index))<<11);
         pagetable[shadowIndex] = 0;             
    }

    int BlockIndex;
    //access DATA
    for(int index=0;index<DATA_SECTION_OBLIVIOUS_NUM;index++){
        LOGIC_INDEX_TO_BLOCK_INDEX(data_section_start_index+index,BlockIndex);
        #ifdef DEBUG_LOADER
        printf("data_section_start:%lx,BlockIndex:%lx\n",data_section_start_index<<11,BlockIndex);
        #endif
        DATAOram->Access(BlockIndex,DataCacheIndex[0],(size_t)DataPAGE1,true);
        size_t src_address = dataSectionRealAddress+index*SHADOWPAGESIZE;
        memcpy((void *)DataPAGE1,(void *)src_address,SHADOWPAGESIZE);
        DataCacheIndex[0] = BlockIndex;
        // *(int *)DataPAGE1 = BlockIndex;
        pagetable[data_section_start_index+index]=0;
    }
    //access BBS
    for(int index=0;index<BSS_SECTION_OBLIVIOUS_NUM;index++){
        LOGIC_INDEX_TO_BLOCK_INDEX(bss_section_start_index+index,BlockIndex);
        DATAOram->Access(BlockIndex,DataCacheIndex[0],(size_t)DataPAGE1,true);
        size_t src_address = bssSectionRealAddress +index*SHADOWPAGESIZE;
        memcpy((void *)DataPAGE1,(void *)src_address,SHADOWPAGESIZE);
        // *(int *)DataPAGE1 = BlockIndex;
        DataCacheIndex[0] = BlockIndex;
        pagetable[bss_section_start_index+index]=0;
    }
    
    // pagetable[data_section_start_index] = (DataPAGE1>>SHADOWPAGEWIDE) - data_section_start_index;
    
    for(int index=0;index<DATACACHE_MIN;index++){
        int logicIndex;
        BLOCK_INDEX_TO_LOGIC_INDEX(index+TARGET_DATA_START_INDEX,logicIndex);
        int blockIndex;
        LOGIC_INDEX_TO_BLOCK_INDEX(logicIndex,blockIndex);
        // printf("logicAddress:%lx,%d\n",logicIndex<<11,blockIndex);
        #ifdef DEBUG_LOADER
        printf("access:%d\n",index+TARGET_DATA_START_INDEX);
        #endif
        DATAOram->Access(index+TARGET_DATA_START_INDEX,DataCacheIndex[index],(size_t)DataPAGE1+index*SHADOWPAGESIZE,true);
        pagetable[logicIndex] = 
                            (size_t)(DataPAGE1+index*SHADOWPAGESIZE) - (logicIndex<<SHADOWPAGEWIDE);

        //set dataCacheIndex
        DataCacheIndex[index] = index+TARGET_DATA_START_INDEX;                    

        int result = comparePage((size_t)DataPAGE1+index*SHADOWPAGESIZE,originalHeapAddress+SHADOWPAGESIZE*index);
        if(result != -1){
            printf("    there is something wrong============%d\n",result);
            printf("    org index:%x, dest index:%x\n",*(int *)(originalHeapAddress+SHADOWPAGESIZE*index),*(int *)(DataPAGE1+index*SHADOWPAGESIZE));
            printf("    org:%x, dest:%x, %d\n",originalHeapAddress+SHADOWPAGESIZE*index,DataPAGE1+index*SHADOWPAGESIZE);
            while(1){}
        }else{
            int magic = *(int *)((size_t)DataPAGE1+index*SHADOWPAGESIZE);
            #ifdef DEBUG_LOADER
            printf("magic num:%d,%d\n\n",magic,DataCacheIndex[index]);
            #endif
        }        
        CacheValid[index]=1;                
    }
    #endif //DATAOBLIVIOUSSHUFFLE

    heap_big_start_index = (heap_virtual_start[BIGHEAPIndex]+HEAPSIZE*IGNOREDHeapPageNumForBig)>>SHADOWPAGEWIDE;

    // printf("initHeapSmall inited \n");

#if BIGOBJECTOSHUFFLE
    // printf("================== we are init HeapBIg\n");
    initHeapBig();
#endif //BIGOBJECTOSHUFFLE

    return;
}

size_t onlyHandleBlockIndexVerify = 0;
void verifiedDataBlock(unsigned targetLogicIndex,struct OramPool *oramData){

    printf("current cacheIndexArray state:%d:\t",oramData->currentPtr);    
    int logicIndex;
    for(int i=0;i<oramData->currentPtr;i++){
        
        BLOCK_INDEX_TO_LOGIC_INDEX_FOR_BIG(oramData->cacheIndexArray[i],logicIndex);
        if(i<DATACACHE_MIN){
            printf("%d:%lx:valid:%d\t",oramData->cacheIndexArray[i],logicIndex<<11,oramData->cacheSlotValidArray[i]);
        }else{
            printf("%d:%lx\t",oramData->cacheIndexArray[i],logicIndex<<11);
        }
    }
    printf("\n");
}

void handleObliviousPageExchange_call();
std::set<int> indexSet;
char isHeapIsOver = 0;
static int currentPtr=DATACACHE_MIN;
static int currentPtrBig=DATACACHE_MIN;
void handleObliviousPageExchangeData(unsigned targetLogicIndex,unsigned targetBlockIndex,struct OramPool *oramData){

    // printf("   request: targetLogicIndex:%lx,targetBlockIndex:%lx\n",targetLogicIndex<<11,targetBlockIndex);

    size_t dataCacheAddress = (size_t)oramData->cacheStartAddr; 
    //1. check whether target page is inside of the cache_min
    if(oramData->currentPtr==DATACACHE_MIN){
        for(int i=0;i<DATACACHE_MIN;i++){
            if(oramData->cacheIndexArray[i]==targetBlockIndex){
                pagetable[targetLogicIndex] = (size_t)(dataCacheAddress) - (targetLogicIndex<<SHADOWPAGEWIDE);
                oramData->cacheSlotValidArray[i] = 1;
                return;
            }
            dataCacheAddress+=SHADOWPAGESIZE*CACHESPARENUM;
        }
        dataCacheAddress = (size_t)oramData->cacheStartAddr; 
        //get a spare page from the min
        for(int index=0;index<DATACACHE_MIN;index++){
            if(oramData->cacheSlotValidArray[index]==0){
                #ifdef DEBUG_DATA_TRACE
                    //if the page is swapped out from the cache, record its mac
                    int blockIndex = oramData->cacheIndexArray[index];
                    if(blockIndex!=0){
                        size_t evictBlockAddress = (size_t)(oramData->cacheStartAddr) + index*SHADOWPAGESIZE*CACHESPARENUM;
                        size_t mac = oramData->ringOram->getAPageMAC(evictBlockAddress);
                        oramData->pageMACs[blockIndex] = mac;
                        unsigned logicIndex = BLOCK_INDEX_TO_LOGIC_INDEX_FOR_BIG(blockIndex,logicIndex);
                        printf("swapout [%lx]-> mac[%lx]\n",logicIndex<<11,mac);
                    }
                #endif//DEBUG_DATA_TRACE

                oramData->ringOram->Access(targetBlockIndex,oramData->cacheIndexArray[index],dataCacheAddress,true);
                oramData->cacheIndexArray[index]=targetBlockIndex;
                pagetable[targetLogicIndex] = ((size_t)(dataCacheAddress)) - (targetLogicIndex<<SHADOWPAGEWIDE);
                oramData->cacheSlotValidArray[index] = 1;
                #ifdef  DEBUG_DATA_TRACE
                    size_t mac = oramData->ringOram->getAPageMAC(dataCacheAddress);
                    printf("mac,targetBlockIndex;%d:[%lx]\n",targetBlockIndex,mac);
                #endif//DEBUG_DATA_TRACE
                return;
            }
            dataCacheAddress+=SHADOWPAGESIZE*CACHESPARENUM;
        }
    }

    //2. otherwise, we use the extend cache page
    if(oramData->currentPtr >= DATACACHE){
        printf("oramData->currentPtr > DATACACHE: %d\n",oramData->currentPtr);
    }
    dataCacheAddress = (size_t)oramData->cacheStartAddr + oramData->currentPtr*HEAPSIZE*CACHESPARENUM;
    oramData->ringOram->Access(targetBlockIndex,oramData->cacheIndexArray[oramData->currentPtr],dataCacheAddress,false);
    oramData->cacheIndexArray[oramData->currentPtr]=targetBlockIndex;
    pagetable[targetLogicIndex] = ((size_t)(dataCacheAddress)) - (targetLogicIndex<<SHADOWPAGEWIDE);
    oramData->currentPtr++;
    isHeapIsOver = 1;
    return;                        

}
void handleObliviousPageExchange_data(){
    if(!*heap_is_inited) return;
    if(targetVirtualAddress==0) return;

    unsigned targetLogicIndex = targetVirtualAddress >> SHADOWPAGEWIDE;
    unsigned targetBlockIndex;
    struct OramPool * oramPool;

    if(isBigObject(targetLogicIndex)){
        LOGIC_INDEX_TO_BLOCK_INDEX_FOR_BIG(targetLogicIndex,targetBlockIndex)
        oramPool = &DataPool_bigData;

    #ifdef DEBUG_DATA_TRACE
        if(!onlyHandleBlockIndexVerify)
        verifiedDataBlock(targetLogicIndex,oramPool);
    #endif//DEBUG_DATA_TRACE
    }else{
        LOGIC_INDEX_TO_BLOCK_INDEX(targetLogicIndex,targetBlockIndex)
        oramPool = &DataPool_smallData;
    }

    // printf("onlyHandleBlockIndexVerify:%d\n",onlyHandleBlockIndexVerify);

    #ifdef DEBUG_DATA_TRACE
        if(!onlyHandleBlockIndexVerify)
            handleObliviousPageExchangeData(targetLogicIndex,targetBlockIndex,oramPool);

        if(isBigObject(targetLogicIndex) && !onlyHandleBlockIndexVerify){ 
            //verify the data page
            //1. get the request block index
            int requestIndex;
            size_t MAC=-1;
            LOGIC_INDEX_TO_BLOCK_INDEX_FOR_BIG(targetLogicIndex,requestIndex);
            //get the request block index;
            for(int itr=0;itr<oramPool->currentPtr;itr++){
                if(itr < DATACACHE_MIN && !oramPool->cacheSlotValidArray[itr])
                    continue;
                if(requestIndex==oramPool->cacheIndexArray[itr]){
                    size_t startCacheSize = (size_t)(oramPool->cacheStartAddr) + itr*SHADOWPAGESIZE*CACHESPARENUM;
                    MAC = oramPool->ringOram->getAPageMAC(startCacheSize);
                    break;
                }
            }
            std::map<int,size_t>::iterator Itr = oramPool->pageMACs.find(requestIndex);
            if(Itr!=oramPool->pageMACs.end() && Itr->second != MAC){
                printf("we find a page that is not equal:requestIndex: %lx,oldValue: %lx,NewValue: %lx\n",requestIndex,Itr->second,MAC);
            }
            printf("index:%d \t",oramPool->currentPtr);
            unsigned logicIndex;
            for(int itr=0;itr<oramPool->currentPtr;itr++){
                    size_t startCacheAddress = (size_t)(oramPool->cacheStartAddr) + itr*SHADOWPAGESIZE*CACHESPARENUM;
                    MAC = oramPool->ringOram->getAPageMAC(startCacheAddress);
                    BLOCK_INDEX_TO_LOGIC_INDEX_FOR_BIG(oramPool->cacheIndexArray[itr],logicIndex);
                    printf("[%d]:[%lx]:0x%lx  ",itr,logicIndex<<11,MAC);

                    for(int itrt=0;itrt<CACHESPARENUM-1;itrt++){
                        startCacheAddress += SHADOWPAGESIZE;
                        MAC = oramPool->ringOram->getAPageMAC(startCacheAddress);
                        printf("0x%lx\t",MAC);
                        if(MAC!=0){
                            printf("\nerrrro we find a MAC%d not equal to 0\n",itrt+1);
                        }
                    }
                    
            }
            printf("\n");

        }
        
        onlyHandleBlockIndexVerify = 0;
    #else//DEBUG_DATA_TRACE
        handleObliviousPageExchangeData(targetLogicIndex,targetBlockIndex,oramPool);
    #endif 
    // LOGIC_INDEX_TO_BLOCK_INDEX(targetLogicIndex,targetBlockIndex)
    // size_t dataCacheAddress = (size_t)DataPAGE1; 

    // // if(obliviousDataIndex>DATACACHE_MIN) return;

    // // printf("obliviousDataIndex:%d\n",obliviousDataIndex);

    // // printf("targetshadowIndex:%lx\n",targetshadowIndex);

    // //1. check whether target page is inside of the cache_min
    // if(currentPtr==DATACACHE_MIN){
        
    //     for(int i=0;i<DATACACHE_MIN;i++){
    //         // if(*(int *)dataCacheAddress==targetBlockIndex){
    //         if(DataCacheIndex[i]==targetBlockIndex){
    //             // printf("have find page in cache:shadowIndex:%lx,obliviousIndex:%d in cache line:%d\n",targetshadowIndex,obliviousDataIndex,i);
    //             size_t value = pagetable[targetLogicIndex];
    //             pagetable[targetLogicIndex] = 
    //                         ((size_t)(dataCacheAddress)>>SHADOWPAGEWIDE) - targetLogicIndex;
    //             CacheValid[i]=1;            
    //             // printf("pagetable value:%lx,->%lx\n",value,pagetable[targetLogicIndex]);            
    //             return;
    //         }
    //         dataCacheAddress+=SHADOWPAGESIZE;
    //     }
    //     // printf("targetshadowIndex1:%lx\n",targetshadowIndex);
    //     //get a spare page from the min
    //     for(int index=0;index<DATACACHE_MIN;index++){
    //         if(CacheValid[index]==0){
                
    //             // we find a logic page that is not linked to the shadowpage
    //             // 1. we should swap this page out and get our target page in
    //             dataCacheAddress=(size_t)DataPAGE1+index*SHADOWPAGESIZE;
    //             DATAOram->Access(targetBlockIndex,DataCacheIndex[index],dataCacheAddress,true);
    //             DataCacheIndex[index]=targetBlockIndex;
    //             // printf("Index:%d,%ld\n",DataCacheIndex[index],*(int*)dataCacheAddress);

    //             // size_t value = pagetable[targetshadowIndex];
    //             pagetable[targetLogicIndex] = 
    //                         ((size_t)(dataCacheAddress)>>SHADOWPAGEWIDE) - targetLogicIndex;
    //             CacheValid[index]=1;            
    //             // printf("pagetable value:%lx,->%lx\n",value,pagetable[targetshadowIndex]);            
    //             return;
    //         }            
    //     }
    //     // printf("targetshadowIndex2:%lx\n",targetshadowIndex);
    // }
    // // printf("targetshadowIndex:%lx not find target in cache, currentPtr:%d\n",targetshadowIndex,currentPtr);

    // // printf("obliviousDataIndex:%d,%lx\n",obliviousDataIndex,dataCacheAddress);

    // //2. otherwise, we should use the extend cache page
    // dataCacheAddress = (size_t)DataPAGE1 + currentPtr*HEAPSIZE;
    // DATAOram->Access(targetBlockIndex,DataCacheIndex[currentPtr],dataCacheAddress,false);
    // DataCacheIndex[currentPtr]=targetBlockIndex;
    
    // // printf("==obliviousDataIndex:%d,%d\n",DataCacheIndex[currentPtr],*(int *)dataCacheAddress);
    
    // pagetable[targetLogicIndex] = 
    //                         ((size_t)(dataCacheAddress)>>SHADOWPAGEWIDE) - targetLogicIndex;
    // currentPtr++;
    // isHeapIsOver = 1;
    targetVirtualAddress = pagetable[targetLogicIndex] + targetVirtualAddress;

    return;
}

size_t dataEventNum=0;

void dereference_data(){
    __asm__ __volatile__ (
        DATE_EVENT_INC()
        "mov %%r14,0x38(%%r15)\n"
        "shr $11,%%r14\n"
        "mov (%%r15,%%r14,8),%%r14\n"
        "cmp $0,%%r14\n"
        "je entryIsNull_data\n"
    #ifdef DEBUG_DATA_TRACE
        "movq $1,%1\n"
    #endif
    #if !defined(DEBUG_DATA_TRACE)
        "add 0x38(%%r15),%%r14\n"
        "ret\n"
    #endif
    "entryIsNull_data:\n"
        "mov 0x38(%%r15),%%r14\n"
        "mov %%r14,%0\n"
        "mov %%rsp,0x8(%%r15)\n"
        "mov (%%r15),%%rsp\n"
        saveContex()
        :"=m"(targetVirtualAddress)
    #ifdef DEBUG_DATA_TRACE
        ,"m"(onlyHandleBlockIndexVerify)
    #endif
    #if Do_Event_Measure
        :"m"(dataDereferenceEventNum)
    #endif
    );

    DATE_MISSING_EVENT_INC()
    handleObliviousPageExchange_data();

    __asm__ __volatile__ (
        resumeContex()
        "mov %0,%%r14\n"
        "mov 0x8(%%r15),%%rsp\n"
        "ret\n":"=m"(targetVirtualAddress)
    );
}

int ocalltime=0;
void swapCachePageBack_helper(){
    if(!CodeCacheIndex) return;
    // printf("ocall:%d\n",ocalltime);
    ocalltime++;
    
    #if OBLIVIOUSSHUFFLE
    // printf("ocall:%d\n",ocalltime);
    size_t start_addr= (size_t)ExcutionPAGE1;
    for(int i=0;i<CACHENUM;i++){
        if(CodeCacheIndex[i]){
            int shadowIndex = ACCESS_TO_PAGEINDEX(CodeCacheIndex[i]);
            pagetable[shadowIndex] = 0;
        }
        start_addr+=SHADOWPAGESIZE;
    }
    CACHE_FLUSH_EVENT_INC()

    pathOram->writeCashBack((size_t)ExcutionPAGE1,CACHENUM,CACHE_BACK_EVICT_NUM,CodeCacheIndex,0);
    #endif
}
void swapCachePageBack(){
    __asm__ __volatile__ ( 
        "mov %%rax,%0\n"
    ::"m"(rax_backup));

#if PAGE_SWAP_AT_OCALL
    swapCachePageBack_helper();
#endif

    __asm__ __volatile__ (
        "mov %0,%%rax\n"
        "mov 0x8(%%r15),%%rsp\n"
        "pop %%r14\n"
        "jmp *0x80(%%r15)\n"
    ::"m"(rax_backup));
}
size_t onlyHandleDataCach = 0;

void swapExtendCachePageBack(){

    #if SCOUT_A_VIRUTAL_RANGE
    size_t scoutStartAddr=SCOUT_START_ADDR;
    size_t scoutEndAddr=SCOUT_END_ADDR;
    size_t startIndex = scoutStartAddr>>SHADOWPAGEWIDE;
    size_t endIndex = scoutEndAddr>>SHADOWPAGEWIDE;
    #endif

    int shadowIndex = (targetVirtualAddress >> SHADOWPAGEWIDE);
    if(shadowIndex<(CODE_START_ADD>>11)){
        return;
    }
    if(!*heap_is_inited){
        goto exitOut;
    }
        
    #if DATAOBLIVIOUSSHUFFLE
    //we first handle the small pool
    if(DataPool_smallData.currentPtr>DATACACHE_MIN){
        size_t dataCacheAddress = (size_t)DataPool_smallData.cacheStartAddr;
        //we first clear their PTE's value
        for(int index=0;index<DataPool_smallData.currentPtr;index++){
            int logicIndex; 
            BLOCK_INDEX_TO_LOGIC_INDEX(DataPool_smallData.cacheIndexArray[index],logicIndex);
            pagetable[logicIndex] = 0;
            dataCacheAddress+=HEAPSIZE*CACHESPARENUM;
        }
        //then swap the page back
        dataCacheAddress = (size_t)DataPool_smallData.cacheStartAddr + DATACACHE_MIN*HEAPSIZE*CACHESPARENUM;
        DataPool_smallData.ringOram->writeCashBack(dataCacheAddress,DataPool_smallData.currentPtr,0,DataPool_smallData.cacheIndexArray,(int)DATACACHE_MIN);
        
        //reset currentPtr
        DataPool_smallData.currentPtr=DATACACHE_MIN;
        for(int index=0;index<DATACACHE_MIN;index++){
            DataPool_smallData.cacheSlotValidArray[index]=0;
        }
    }
    #endif

    #if BIGOBJECTOSHUFFLE
        #if SCOUT_A_VIRUTAL_RANGE
            size_t scoutStartBlockIndex;
            size_t scoutEndAddrBlockIndex;
            // if(isBigObject(startIndex)){
                // LOGIC_INDEX_TO_BLOCK_INDEX_FOR_BIG(startIndex,scoutStartBlockIndex);
                // LOGIC_INDEX_TO_BLOCK_INDEX_FOR_BIG(endIndex,scoutEndAddrBlockIndex);
                // scoutStartAddr = (scoutStartBlockIndex<<11) + (scoutStartAddr & ((1<<SHADOWPAGEWIDE)-1));
                // scoutEndAddr = (scoutEndAddrBlockIndex<<11) + (scoutEndAddr & ((1<<SHADOWPAGEWIDE)-1));
                // DataPool_bigData.ringOram->getARangeMAC(scoutStartAddr,scoutEndAddr,DataPool_bigData.currentPtr);
            // }else{
                // LOGIC_INDEX_TO_BLOCK_INDEX(startIndex,scoutStartBlockIndex);
                // LOGIC_INDEX_TO_BLOCK_INDEX(endIndex,scoutEndAddrBlockIndex);
                // scoutStartAddr = (scoutStartBlockIndex<<11) + (scoutStartAddr & ((1<<SHADOWPAGEWIDE)-1));
                // scoutEndAddr = (scoutEndAddrBlockIndex<<11) + (scoutEndAddr & ((1<<SHADOWPAGEWIDE)-1));
                
                // DataPool_smallData.ringOram->getARangeMAC(scoutStartAddr,scoutEndAddr,DataPool_smallData.currentPtr);
                scoutStartAddr=heap_real_start[HEAPIndex]+HEAPSIZE*IGNOREDHeapPageNum - heap_virtual_start[HEAPIndex] + scoutStartAddr;
                scoutEndAddr=heap_real_start[HEAPIndex]+HEAPSIZE*IGNOREDHeapPageNum - heap_virtual_start[HEAPIndex] +scoutEndAddr;
                getARangeMAC(scoutStartAddr,scoutEndAddr);
            // }
        #endif

    //then the big pool
    if(DataPool_bigData.currentPtr>DATACACHE_MIN){
        // printf("DataPool_bigData.currentPtr>DATACACHE_MIN %d\n",DataPool_bigData.currentPtr);
        size_t dataCacheAddress = (size_t)DataPool_bigData.cacheStartAddr;
        for(int index=0;index<DataPool_bigData.currentPtr;index++){
            int logicIndex; 
            BLOCK_INDEX_TO_LOGIC_INDEX_FOR_BIG(DataPool_bigData.cacheIndexArray[index],logicIndex);
            pagetable[logicIndex] = 0;
            dataCacheAddress+=HEAPSIZE*CACHESPARENUM;
        }
        //then swap the page back
        #ifdef DEBUG_DATA_TRACE
            //if the page is swapped out from the cache, record its mac
            // printf("swapExtendCachePageBack : current Index %d\n",DataPool_bigData.currentPtr);
            for(int index=0;index<DataPool_bigData.currentPtr;index++){
                int pageIndex = DataPool_bigData.cacheIndexArray[index];
                if(pageIndex!=0){
                    size_t evictBlockAddress = (size_t)(DataPool_bigData.cacheStartAddr) + index*SHADOWPAGESIZE*CACHESPARENUM;
                    size_t mac = DataPool_bigData.ringOram->getAPageMAC(evictBlockAddress);
                    DataPool_bigData.pageMACs[pageIndex] = mac;
                    
                    unsigned logicIndex;
                    BLOCK_INDEX_TO_LOGIC_INDEX_FOR_BIG(pageIndex,logicIndex);
                    // printf("record:%d,index:%d [%lx]-> mac[%lx]\n",index,pageIndex,logicIndex<<11,mac);
                }
            }
        #endif
        dataCacheAddress = (size_t)DataPool_bigData.cacheStartAddr + DATACACHE_MIN*HEAPSIZE*CACHESPARENUM;
        DataPool_bigData.ringOram->writeCashBack(dataCacheAddress,DataPool_bigData.currentPtr,0,DataPool_bigData.cacheIndexArray,(int)DATACACHE_MIN);
        //reset currentPtr
        DataPool_bigData.currentPtr=DATACACHE_MIN;
        for(int index=0;index<DATACACHE_MIN;index++){
            DataPool_bigData.cacheSlotValidArray[index]=0;
        }
    }
    #else
        #if SCOUT_A_VIRUTAL_RANGE
        // if(isBigObject(startIndex)){
            // scoutStartAddr=heap_real_start[BIGHEAPIndex]+HEAPSIZE*IGNOREDHeapPageNumForBig - heap_virtual_start[BIGHEAPIndex] + scoutStartAddr;
            // scoutEndAddr=heap_real_start[BIGHEAPIndex]+HEAPSIZE*IGNOREDHeapPageNumForBig - heap_virtual_start[BIGHEAPIndex] + scoutEndAddr;
            // getARangeMAC(scoutStartAddr,scoutEndAddr);
        // }else{
            scoutStartAddr=heap_real_start[HEAPIndex]+HEAPSIZE*IGNOREDHeapPageNum - heap_virtual_start[HEAPIndex] + scoutStartAddr;
            scoutEndAddr=heap_real_start[HEAPIndex]+HEAPSIZE*IGNOREDHeapPageNum - heap_virtual_start[HEAPIndex] + scoutEndAddr;
            getARangeMAC(scoutStartAddr,scoutEndAddr);
        // }
            
        #endif
    #endif

 exitOut:
    //calculate the ret target
    size_t targetAddress = (size_t)pagetable[shadowIndex] + (size_t)(shadowIndex<<SHADOWPAGEWIDE); 
    translatedTargetAddress = (size_t)targetAddress + (targetVirtualAddress & SHADOWPAGEMASK);
    onlyHandleDataCach=0;
    return;
}

void dereference_ControlFlow_ret(){
       __asm__ __volatile__ (
        RET_EVENT_INC()
        "mov %%r14,0x38(%%r15)\n"
        "shr $11,%%r14\n"
        "movq (%%r15,%%r14,8),%%r14\n"
      #if NO_DEBUG_FUNCTION_TRACE
        "cmp $0,%%r14\n"
        "je entryIsNull_ret\n"
        "cmpw %3,%2\n"
        "jg dataCacheIsOverSized\n"
        #if PAGE_SWAP_RANDOM
        "incq 0x48(%%r15)\n"   
        "cmpq $0x500,0x48(%%r15)\n"
        "je entryIsNull_ret\n"
        #endif
        "add 0x38(%%r15),%%r14\n"
        "jmp *%%r14\n"
      #endif //NO_DEBUG_FUNCTION_TRACE
    "dataCacheIsOverSized:\n"    
        "movq $1,%1\n"
    "entryIsNull_ret:\n"
        "mov 0x38(%%r15),%%r14\n"
        "mov %%r14,%0\n"
        "mov %%rsp,0x8(%%r15)\n"
        "mov (%%r15),%%rsp\n"
        saveContex()
        :"=m"(targetVirtualAddress),"=m"(onlyHandleDataCach):"m"(DataPool_bigData.currentPtr),"i"(DATACACHE_MIN)
        #if Do_Event_Measure
        ,"m"(retEventNum)
        #endif 
    );

      
    RET_MISSING_EVENT_INC()  

#if PRINT_EVEN_OBLIVIOUS_MODULE
        handleObliviousPageExchange_call();
#else
    if(!onlyHandleDataCach){
        handleObliviousPageExchange_call();
    }
#endif

    swapExtendCachePageBack();

    #if PRINT_OUT_FUNCTION_TRACE
    func_trace_print_count++;
    call_ret_pair--;
    if(func_trace_print_count>=FUNC_PRING_START_COUNT){
        printf("%d: return :%lx,target:%lx,%d,%d :count:%lx\n",call_ret_pair,targetVirtualAddress,translatedTargetAddress,DEBUG_FUNCTION_TRACE,NO_DEBUG_FUNCTION_TRACE,func_trace_print_count);
    }
    #endif //PRINT_OUT_FUNCTION_TRACE

    __asm__ __volatile__ (
        resumeContex()
        "mov 0x8(%%r15),%%rsp\n"
        "jmp %0\n"
        ::"m"(translatedTargetAddress)
    );
}


void dereference_ControlFlow_Fallthrough(){

    __asm__ __volatile__ (
        FALLTHROUGH_EVENT_INC()
        "mov %%r14,0x38(%%r15)\n"
        "shr $11,%%r14\n"
        "movq (%%r15,%%r14,8),%%r14\n"
        "cmp $0,%%r14\n"
        "je entryIsNull_fallthrough\n"
        #if PAGE_SWAP_RANDOM
        "incq 0x48(%%r15)\n"   
        "cmpq $0x500,0x48(%%r15)\n"
        "je entryIsNull_fallthrough\n"
        #endif
        "add 0x38(%%r15),%%r14\n"
        "jmp *%%r14\n"
    "entryIsNull_fallthrough:\n"
        "mov 0x38(%%r15),%%r14\n"
        "mov %%r14,%0\n"
        "mov %%rsp,0x8(%%r15)\n"
        "mov (%%r15),%%rsp\n"
        saveContex()
        :"=m"(targetVirtualAddress)
        #if Do_Event_Measure
        :"m"(fallthrough)
        #endif 
    );
    
    FALLTHROUGH_MISSING_EVENT_INC()

    handleObliviousPageExchange_call();
   

    __asm__ __volatile__ (
        resumeContex()
        "mov 0x8(%%r15),%%rsp\n"
        "jmp %0\n"
        ::"m"(translatedTargetAddress)
    );
}

void dereference_ControlFlow_call(){
    
    __asm__ __volatile__ (
        CALL_EVENT_INC()
        "mov %%r14,0x38(%%r15)\n"
        "shr $11,%%r14\n"
        "movq (%%r15,%%r14,8),%%r14\n"
      #if NO_DEBUG_FUNCTION_TRACE
        "cmp $0,%%r14\n"
        "je entryIsNull_call\n"
        #if PAGE_SWAP_RANDOM
        "incq 0x48(%%r15)\n"   
        "cmpq $0x500,0x48(%%r15)\n"
        "je entryIsNull_call\n"
        #endif
        "add 0x38(%%r15),%%r14\n"
        "jmp *%%r14\n"
      #endif //NO_DEBUG_FUNCTION_TRACE
    "entryIsNull_call:\n"
        "mov 0x38(%%r15),%%r14\n"
        "mov %%r14,%0\n"
        "mov %%rsp,0x8(%%r15)\n"
        "mov (%%r15),%%rsp\n"
        saveContex()
        :"=m"(targetVirtualAddress)
        #if Do_Event_Measure
        :"m"(callEventNum)
        #endif
    );
    
    CALLE_MISSING_EVENT_INC()
    
// #if DEBUG_FUNCTION_TRACE
//     #if PRINT_OUT_FUNCTION_TRACE
//     if(func_trace_print_count>=FUNC_PRING_START_COUNT){
//         printf("%d:  call:%lx\n",call_ret_pair,(targetVirtualAddress>>0x35) + (targetVirtualAddress<<11));
//     }
//     #endif
// #endif //DEBUG_FUNCTION_TRACE

    // if(*(int *)_virtual_stack_save==0x40635f){
    //     printf("find it\n");
    // }
    handleObliviousPageExchange_call();

#if DEBUG_FUNCTION_TRACE
    #if PRINT_OUT_FUNCTION_TRACE
    func_trace_print_count++;
    call_ret_pair++;
    if(func_trace_print_count>=FUNC_PRING_START_COUNT){
        printf("%d:  call:%lx,target:%lx,%lx :count:%lx\n",call_ret_pair,targetVirtualAddress,translatedTargetAddress,*(long *)pagetable[1],func_trace_print_count);
    }
    #endif
#endif //DEBUG_FUNCTION_TRACE

    __asm__ __volatile__ (
        resumeContex()
        "mov 0x8(%%r15),%%rsp\n"
        "jmp %0\n"
        ::"m"(translatedTargetAddress)
    );
}

void handleObliviousPageExchange_call(){
    static int itr = 0;
    
    //targetAddress is [pageoffset:pageIndex]
    int Index = (targetVirtualAddress >> SHADOWPAGEWIDE);
    
    #if PAGE_SWAP_RANDOM
    if(pagetable[Index]){
        if(pagetable[9]==0x500){
            //1. swap cache page out
            swapCachePageBack_helper();
            pagetable[9] = 0;

            //2.1 if the Index is not included in the cache
            if(Index < EntryPageShadowStartIndex){
                translatedTargetAddress=pagetable[Index]+targetVirtualAddress;
                return;
            }
            //2.2 we need to obtain the target page.
            size_t candicateSwapOutPageAddress=(size_t)ExcutionPAGE1;
            pathOram->Access(PAGEINDX_TO_ACCESS_INDEX(Index),CodeCacheIndex[0],(size_t)candicateSwapOutPageAddress,true);
            CodeCacheIndex[0] = PAGEINDX_TO_ACCESS_INDEX(Index);
            //4. config the pagetable
            pagetable[Index] =((size_t)candicateSwapOutPageAddress) - (Index<<SHADOWPAGEWIDE);
            

        }

        translatedTargetAddress=pagetable[Index]+targetVirtualAddress;
        return;
    }
    #endif

#if PRINT_EVEN_OBLIVIOUS_MODULE
if(pagetable[Index]){
    translatedTargetAddress = pagetable[Index]+targetVirtualAddress;
    // printf("target:%lx,%lx\n",Index,targetVirtualAddress);
    return;
}
#endif

#if (NO_DEBUG_FUNCTION_TRACE || PRINT_EVEN_OBLIVIOUS_MODULE)
    size_t candicateSwapOutPageAddress;
    itr = getRandom_LessThan256()%CACHENUM;
  
    candicateSwapOutPageAddress = (size_t)ExcutionPAGE1 + itr*SHADOWPAGESIZE;       
    
    //2. clear the entry of this page in pagetable
    int shadowIndex;
    
    if(CodeCacheIndex[itr]){
        shadowIndex = ACCESS_TO_PAGEINDEX(CodeCacheIndex[itr]);
        pagetable[shadowIndex] = 0;
    }

    //3. swap the page out and access the page
    // printf("1:evict target Index is %lx,%lx,%lx\n",CodeCacheIndex[itr],ACCESS_TO_PAGEINDEX(CodeCacheIndex[itr])<<11,(*(int*)candicateSwapOutPageAddress));

    if(PAGEINDX_TO_ACCESS_INDEX(Index)>0xffffff){
        printf("%lx %lx evict target Index is %lx,%lx,%lx\n",targetVirtualAddress,Index,CodeCacheIndex[itr],ACCESS_TO_PAGEINDEX(CodeCacheIndex[itr])<<11,(*(int*)candicateSwapOutPageAddress));
        // printf("Index:%lx,\n",Index);
        // printf("%lx\n",PAGEINDX_TO_ACCESS_INDEX(Index));
        // printf("%lx\n",EntryPageShadowStartIndex);
    }

    pathOram->Access(PAGEINDX_TO_ACCESS_INDEX(Index),CodeCacheIndex[itr],(size_t)candicateSwapOutPageAddress,true);
    CodeCacheIndex[itr] = PAGEINDX_TO_ACCESS_INDEX(Index);
    shadowIndex = ACCESS_TO_PAGEINDEX(CodeCacheIndex[itr]);

    //4. config the pagetable
    pagetable[Index] =((size_t)candicateSwapOutPageAddress) - (Index<<SHADOWPAGEWIDE);

    //5. calcualte the target
    translatedTargetAddress = (size_t)pagetable[Index]+ targetVirtualAddress;
#else //NO_DEBUG_FUNCTION_TRACE
    #if SCOUT_A_VIRUTAL_RANGE
        size_t scoutStartAddr=SCOUT_START_ADDR;
        size_t scoutEndAddr=SCOUT_END_ADDR;
        size_t startIndex = scoutStartAddr>>SHADOWPAGEWIDE;
        size_t endIndex = scoutEndAddr>>SHADOWPAGEWIDE;
        if(!*heap_is_inited){
            translatedTargetAddress=pagetable[Index]+ targetVirtualAddress;
            return;
        }

        #if BIGOBJECTOSHUFFLE
            size_t scoutStartBlockIndex;
            size_t scoutEndAddrBlockIndex;
            // if(isBigObject(startIndex)){
                // LOGIC_INDEX_TO_BLOCK_INDEX_FOR_BIG(startIndex,scoutStartBlockIndex);
                // LOGIC_INDEX_TO_BLOCK_INDEX_FOR_BIG(endIndex,scoutEndAddrBlockIndex);
                // scoutStartAddr = (scoutStartBlockIndex<<11) + (scoutStartAddr & ((1<<SHADOWPAGEWIDE)-1));
                // scoutEndAddr = (scoutEndAddrBlockIndex<<11) + (scoutEndAddr & ((1<<SHADOWPAGEWIDE)-1));
                // DataPool_bigData.ringOram->getARangeMAC(scoutStartAddr,scoutEndAddr,DataPool_bigData.currentPtr);
            // }else{
                // LOGIC_INDEX_TO_BLOCK_INDEX(startIndex,scoutStartBlockIndex);
                // LOGIC_INDEX_TO_BLOCK_INDEX(endIndex,scoutEndAddrBlockIndex);
                // scoutStartAddr = (scoutStartBlockIndex<<11) + (scoutStartAddr & ((1<<SHADOWPAGEWIDE)-1));
                // scoutEndAddr = (scoutEndAddrBlockIndex<<11) + (scoutEndAddr & ((1<<SHADOWPAGEWIDE)-1));
                // DataPool_smallData.ringOram->getARangeMAC(scoutStartAddr,scoutEndAddr,DataPool_smallData.currentPtr);
                scoutStartAddr=heap_real_start[HEAPIndex]+HEAPSIZE*IGNOREDHeapPageNum - heap_virtual_start[HEAPIndex] + scoutStartAddr;
                scoutEndAddr=heap_real_start[HEAPIndex]+HEAPSIZE*IGNOREDHeapPageNum - heap_virtual_start[HEAPIndex] +scoutEndAddr;
                getARangeMAC(scoutStartAddr,scoutEndAddr);
            // }
        #else
            // if(isBigObject(startIndex)){
                // scoutStartAddr=heap_real_start[BIGHEAPIndex]+HEAPSIZE*IGNOREDHeapPageNumForBig - heap_virtual_start[BIGHEAPIndex] + scoutStartAddr;
                // scoutEndAddr=heap_real_start[BIGHEAPIndex]+HEAPSIZE*IGNOREDHeapPageNumForBig - heap_virtual_start[BIGHEAPIndex] + scoutEndAddr;
            // }else{
                scoutStartAddr=heap_real_start[HEAPIndex]+HEAPSIZE*IGNOREDHeapPageNum - heap_virtual_start[HEAPIndex] + scoutStartAddr;
                scoutEndAddr=heap_real_start[HEAPIndex]+HEAPSIZE*IGNOREDHeapPageNum - heap_virtual_start[HEAPIndex] +scoutEndAddr;
            // }

            getARangeMAC(scoutStartAddr,scoutEndAddr);
        #endif
    #endif
    translatedTargetAddress=pagetable[Index]+targetVirtualAddress;
#endif //NO_DEBUG_FUNCTION_TRACE
    return;
}

size_t getARangeMAC(size_t startVirAddr,size_t endVirAddr){
    static int getAllValidPageMACTimes=0;
    static int print_count=0;
    size_t MAC=0;
    size_t cur;
    int index=0;

    print_count++;
    if(print_count<PRINTF_START_COUNT)
        return 0;

    for(size_t itr=startVirAddr;itr<endVirAddr;itr+=8){
        cur = *(size_t *)itr;
        if(getAllValidPageMACTimes==PRINGMAC){
            printf("%d:addr:%lx:%lx\t",index,itr,cur);
            index++;
            if((index%5)==0)
                printf("\n");
        }
        cur = (cur >> 32) + (cur & 0xffffffff);
        MAC+=cur;
    }
    if(getAllValidPageMACTimes==PRINGMAC){
        printf("\n");
    }

    printf("    getValid:%lx,                     MAC:%lx\n",getAllValidPageMACTimes,MAC);
    getAllValidPageMACTimes++;

    return MAC;
}

//-----------------------------------------------------------------------//
//---- the blow functions are used for the supporting of Big Objects-----//
//---- copy the program's contents to SGX component's memory, or v.v-----//
//-----------------------------------------------------------------------//

size_t getRealAddress(size_t logicAddr){
    size_t index = logicAddr>>SHADOWPAGEWIDE;
    //if the page does not exist in cache,swap the page in
    if(!pagetable[index]){
        struct OramPool * oramPool;
        size_t blockIndex;
        if(isBigObject(index)){
            LOGIC_INDEX_TO_BLOCK_INDEX_FOR_BIG(index,blockIndex)
            oramPool = &DataPool_bigData;
        }else{
            LOGIC_INDEX_TO_BLOCK_INDEX(index,blockIndex)
            oramPool = &DataPool_smallData;
        }
        handleObliviousPageExchangeData(index,blockIndex,oramPool);
    }

    return pagetable[index]+logicAddr;
}

bool copyingFromSGXToProgram(size_t dest,char *source,size_t len){
    size_t count=len;
    size_t sourceVirtualAddr=(size_t)source;
    size_t destVirtualAddr;
    size_t boundary;
    int copyLen;
    
    while(count!=0){
        boundary = (dest + SHADOWPAGESIZE) & ~(SHADOWPAGESIZE-1);
        destVirtualAddr = getRealAddress(dest);
        if(dest+count < boundary){
            copyLen = count;
        }else{
            copyLen = boundary - dest;
        }
        memcpy((char*)destVirtualAddr,(char *)sourceVirtualAddr,copyLen);
        dest+=copyLen;
        sourceVirtualAddr+=copyLen;
        count-=copyLen;
    }
    return true;
}

bool copyingFromProgramToSGX(char *dest,size_t source,size_t len){
    size_t count=len;
    size_t sourceVirtualAddr;
    size_t destVirtualAddr= (size_t)dest;
    size_t boundary;
    int copyLen;
    
    while(count!=0){
        boundary = (source + SHADOWPAGESIZE) & ~(SHADOWPAGESIZE-1);
        sourceVirtualAddr = getRealAddress(source);
        if(source+count < boundary){
            copyLen = count;
        }else{
            copyLen = boundary - source;
        }
        memcpy((char*)destVirtualAddr,(char *)sourceVirtualAddr,copyLen);
        destVirtualAddr+=copyLen;
        source+=copyLen;
        count-=copyLen;
    }
    return true;

}

size_t getStringLength(size_t src){
    size_t count = 0;
    size_t srcVirtualAddr = getRealAddress(src);
    
    while(*(char*)srcVirtualAddr){
        src++;
        srcVirtualAddr++;
        count++;
        if(!(src & (SHADOWPAGESIZE-1))){
            srcVirtualAddr = getRealAddress(src);
        }
    }

    return count+1;
}

char* copyStringToSGX(size_t src){
    if(!src) return NULL;
    size_t length = getStringLength(src);
    char *dest = (char *)malloc(length);
    copyingFromProgramToSGX(dest,src,length);
    return dest;
}
#include <stdlib.h>
#include <stdint.h>

#define WITH_HEAP_RAND 0
void *morecore() {
    puts("Heap space is not enough");
    return NULL;
}
#define LACKS_TIME_H 1 /* XXX: do not use time() for generating a magic
                          if linker does not support "time()" */
#define HAVE_MORECORE 0
#define HAVE_MMAP 0
#define ONLY_MSPACES 1
#define USE_LOCKS 0
#include "dlmalloc.inc" /* XXX: ugly include .. updating dlmalloc.inc does not trigger make */

#define HEAP_CHK_SIZE 0x100000
#define N_POOL 0x2
#define RAND_GAP 37
#define SEED_MAX (N_POOL * RAND_GAP)
static uint8_t _heap_chk0[HEAP_CHK_SIZE] = {0};
static uint8_t _heap_chk1[HEAP_CHK_SIZE] = {0};
static uint8_t *_heap= _heap_chk0;
static uint8_t *_heap_big= _heap_chk1;
static mspace _ms= 0;
static mspace _ms_big= 0;
void * heap_start[2] ={0};
size_t heap_size[2] = {0};
unsigned int is_inited = 0;

#include <stdio.h>
void set_inited(){
    __asm__ __volatile__(
        "movq $1,0x30(%r15)\n"
        "callq *0x70(%r15)\n"
    );
}

void _malloc_init() {
    unsigned long addr_start ,end;
    size_t capt ;

    //create the small one,align the page
    addr_start = ((unsigned long)_heap + 0x1000) & (~0xfff);
    end = ((unsigned long)_heap + HEAP_CHK_SIZE) & (~0xfff);
    capt = end - addr_start;
    _ms = create_mspace_with_base((void*)addr_start,
            capt, 0);
    heap_start[0] = addr_start;
    heap_size[0] = capt;
    //mspace_malloc(_ms,0,)
    mspace_init_pan(_ms,0x800);

    //create the big one
    addr_start = ((unsigned long)_heap_big + 0x1000) & (~0xfff);
    end = ((unsigned long)_heap_big + HEAP_CHK_SIZE) & (~0xfff);
    capt = end - addr_start;
    _ms_big = create_mspace_with_base((void*)addr_start,
            capt, 0);
    heap_start[1] = addr_start;
    heap_size[1] = capt;   
    set_inited();  
}

unsigned long total_size=0;

void* malloc(size_t bytes) {
    static mspace ms = NULL;
    if (!_ms) _malloc_init();
    if(bytes<0x7c0){
        ms = _ms;
    }else{
        ms = _ms_big;
    }
    return mspace_malloc(ms, bytes);
}

void free(void* mem) {
    static mspace ms = NULL;
    if (!_ms) _malloc_init();
    if(((uint64_t)_heap <= (uint64_t)mem)
                             &&((uint64_t)_heap + HEAP_CHK_SIZE > (uint64_t)mem)){
        ms = _ms;                
    }else{
        ms = _ms_big;
    }
    mspace_free(ms, mem);
}

void* calloc(size_t n_elements, size_t elem_size) {
    size_t req = n_elements*elem_size;
    void *addr;
    static mspace ms = NULL;
    if (!_ms) _malloc_init();
    if(req<0x7c0){
        ms = _ms;
        addr = mspace_calloc(ms, n_elements, elem_size);
    }else{
        ms = _ms_big;
        addr = mspace_calloc(ms, n_elements, elem_size); 
    }

    return addr;
}

void* realloc(void* oldMem, size_t bytes) {
    static mspace ms = NULL;
    static mspace new_ms = NULL;
    void *addr;
    if (!_ms) _malloc_init();

    if(bytes<0x7c0){
        new_ms = _ms;
    }else{
        new_ms = _ms_big;
    }

    if(((uint64_t)_heap <= (uint64_t)oldMem)
                             &&((uint64_t)_heap + HEAP_CHK_SIZE > (uint64_t)oldMem)){
        ms = _ms;     
        addr = mspace_realloc_pan(ms,new_ms, oldMem, bytes);            
    }else{
        ms = _ms_big;
        addr = mspace_realloc_pan(ms,new_ms, oldMem, bytes);
    }
    
    return addr;
}

void* memalign(size_t alignment, size_t bytes) {
    static mspace ms = NULL;
    if (!_ms) _malloc_init();
    if(bytes<0x7c0){
        ms = _ms;
    }else{
        ms = _ms_big;
    }
    return mspace_memalign(ms, alignment, bytes);
}

size_t malloc_usable_size(const void* mem) {
    if (!_ms) _malloc_init();
    return mspace_usable_size(mem);
}

int posix_memalign(void** memptr, size_t alignment, size_t bytes) {
    if (alignment < sizeof(void *)) return EINVAL;
    if (!memptr) return 1;
    if (!_ms) _malloc_init();
    *memptr = mspace_memalign(_ms, alignment, bytes);
    if (!*memptr) return 1;
    return 0;
}

/* add if needed
struct mallinfo mallinfo() {
    return mspace_mallinfo(_ms);
}

// already defined in src/legacy/valloc.c
void* valloc(size_t bytes) {
    if (!_ms) _malloc_init();
    return mspace_memalign(_ms, PAGE_SIZE, bytes);
}
*/

//weak_alias(__memalign, memalign);

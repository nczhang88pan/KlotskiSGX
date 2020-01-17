/* a very simple test program */

#include <stdio.h>
#include <stdlib.h>

//extern void *cpy(void *dest,void *src,size_t n);
#define BUFFSIZE 0x1000
extern void *memsetWapper(void *src, int i,size_t n);

void enclave_main()
{
    char buf[BUFFSIZE];

    memset(buf,'e',sizeof(char)*BUFFSIZE);
    printf("start %d\t",1);

    for(int i=0;i<BUFFSIZE;i++){
        printf("%d\t",buf[i]);
    }
    enclave_exit();
}

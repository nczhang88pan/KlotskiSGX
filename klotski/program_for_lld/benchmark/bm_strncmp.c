/* a very simple test program */

#include <stdio.h>
#include <stdlib.h>

#define STRNCMP strncmp

#define SIZE 0x1000
#define Special_Index 0x300
extern void *strncmpWapper(void *dest,void *src,size_t n); 

void enclave_main()
{
    char buf[SIZE] = {0};
    char *buf1 = (char*)malloc(sizeof(char)*SIZE);

    for(int i=0;i<SIZE;i++){
        buf1[i]=(i)%255+1;
        buf[i]=(i)%255+1;
    }

    printf("result:%d\n",buf[Special_Index]);
    buf[Special_Index]=8;

    int cmp = STRNCMP(buf, buf1, sizeof(char)*SIZE);

    printf("result:%d\n",cmp);

    enclave_exit();
}

/* a very simple test program */

#include <stdio.h>
#include <stdlib.h>

#define MEMCPY memcpy 

#define SIZE 0x1000
extern void *memmoveWapper(void *dest,void *src,size_t n); 
void enclave_main()
{
    int buf[SIZE] = {0};
    //int *buf1 = (int *)malloc(sizeof(int)*SIZE);
    int *buf2 = &buf[SIZE/4];

    for(int i=0;i<SIZE;i++){
        buf[i]=i;
    }
    //memcpy(buf, "This is a long string to check!\0", 32);
    //cpy(buf, "This is a long string to check!\0", 32);
    memmove(buf2, buf, sizeof(int)*SIZE*3/4);

    for(int i=0;i<SIZE;i++){
        printf("%d\t",buf[i]);
    }
    enclave_exit();
}

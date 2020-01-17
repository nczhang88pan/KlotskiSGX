/* a very simple test program */

#include <stdio.h>
#include <stdlib.h>

#define MEMCPY memcpy 

#define SIZE 0x1000
#define INDEX 4
//extern void *memcpyWapper(void *dest,void *src,size_t n);

void enclave_main()
{
    int *buf[INDEX];

    for(int i=0;i<INDEX;i++){
        buf[i] = (int *)malloc(sizeof(int)*SIZE);
    }

    for(int i=0;i<INDEX;i++){
        printf("malloc %d %lx ,%d\t",i,buf[i],*(buf[i]+4));
    }
    
    int indexd= 0;
    for(int i=0;i<SIZE;i++){
        int offset =(int )(&buf[indexd][i])-0x411000;
        if(((offset>>11)+1)!=buf[indexd][i]){
            printf("test:%lx addr:%lx offset:%d: real value:%d\n",i,&buf[indexd][i],(offset>>11)+1,buf[indexd][i]);
        }
    }


    for(int j=0;j<INDEX;j++){
        for(int i=0;i<SIZE;i++){
            buf[j][i]=j*0x1000+i;
        }
    }

    for(int i=0;i<INDEX;i++){
        printf("%lx\t",buf[i]);
    }
    
    //for(int j=0;j<INDEX;j++){
    //   memcpy(buf, buf[j], sizeof(int)*SIZE);
    //}


    for(int j=0;j<INDEX;j++){
        for(int i=0;i<SIZE;i++){
            if(buf[j][i]!=(j*0x1000+i)){
                printf("error %lx %lx %lx\n",&buf[j][i],buf[j][i],j*0x1000+i);
            }
        }
    }
    printf("success\n");
    enclave_exit();
}

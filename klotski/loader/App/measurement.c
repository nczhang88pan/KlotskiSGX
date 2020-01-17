/*************************************************************************
	> File Name: measurement.c
	> Author: 
	> Mail: 
	> Created Time: Sat 21 Oct 2017 01:57:24 PM PDT
 ************************************************************************/

#include<stdio.h>
#include"measurement.h"
void *dummy_pt = NULL;
int fd = 0;
int ocall_measure_init(__u64 start, __u64 size,__u64 code_start,__u64 code_size,__u64 gp_start,__u64 gp_size){
    struct sgx_measure_init measure_arg = {start, size, code_start, code_size,gp_start,gp_size};
    printf("=====================================================size: %Lx\n",measure_arg.size);
    fd = open("/dev/isgx",O_RDWR);
    if(fd < 0){
        printf("open Dev Error\n");
        return -1;
    }
    
    if(ioctl(fd, SGX_IOCTL_MEASURE_INIT, &measure_arg) < 0){
        printf("call SGX_IOCTL_MEASURE_INIT failed");
        return -1;
    }
     printf("%s finish\n",__func__);
    return 0;
}
int ocall_measure_start(){
    if(ioctl(fd,SGX_IOCTL_MEASURE_START, &dummy_pt)<0){
        return -1;
    }
    printf("%s finish\n",__func__);
    return 0;
}

int ocall_measure_stop(){
    if(ioctl(fd,SGX_IOCTL_MEASURE_STOP, &dummy_pt)<0){
        return -1;
    }
    close(fd);
    printf("%s finish\n",__func__);
    return 0;
}

int ocall_measure_wait(){
    if(ioctl(fd,SGX_IOCTL_MEASURE_WAIT, &dummy_pt)<0){
        return -1;
    }
    printf("%s finish\n",__func__);
    return 0;
}
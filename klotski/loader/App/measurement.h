/*************************************************************************
	> File Name: measurement.h
	> Author: 
	> Mail: 
	> Created Time: Sat 21 Oct 2017 01:43:54 PM PDT
 ************************************************************************/

#ifndef _MEASUREMENT_H
#define _MEASUREMENT_H
#include <linux/types.h>
#include <linux/ioctl.h>
#include <fcntl.h>
typedef unsigned long long __u64;
struct sgx_measure_init{
    __u64 start;
    __u64 size;
    __u64 code_start;
    __u64 code_size;
    __u64 GP_start;
    __u64 GP_size;
};

#define SGX_MAGIC 0XA4

#define SGX_IOCTL_MEASURE_INIT \
            _IOR(SGX_MAGIC,0x03, struct sgx_measure_init)
#define SGX_IOCTL_MEASURE_START \
            _IOR(SGX_MAGIC,0x04, void*)
#define SGX_IOCTL_MEASURE_WAIT \
            _IOR(SGX_MAGIC,0x05, void*)
#define SGX_IOCTL_MEASURE_STOP \
            _IOR(SGX_MAGIC,0x06, void*)

int ocall_measure_init(__u64 start, __u64 size,__u64 code_start,__u64 code_size,__u64 gp_start,__u64 gp_size);
int ocall_measure_start();
int ocall_measure_stop();

#endif

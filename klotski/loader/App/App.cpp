/*
 * Copyright (C) 2011-2016 Intel Corporation. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * Neither the name of Intel Corporation nor the names of its
 *     contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */


#include <stdio.h>
#include <string.h>
#include <assert.h>

# include <pwd.h>

/* man 2 open */
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

/* man 2 stat, read */
#include <unistd.h>

/* man 2 mmap */
#include <sys/mman.h>

typedef void (*sighandler_t)(int);

#include "sgx_urts.h"
#include "App.h"
#include "Enclave_u.h"
#include "measurement.h"

/* Check error conditions for loading enclave */
void print_error_message(sgx_status_t ret)
{
    size_t idx = 0;
    size_t ttl = sizeof sgx_errlist/sizeof sgx_errlist[0];

    for (idx = 0; idx < ttl; idx++) {
        if(ret == sgx_errlist[idx].err) {
            if(NULL != sgx_errlist[idx].sug)
                printf("Info: %s\n", sgx_errlist[idx].sug);
            printf("Error: %s\n", sgx_errlist[idx].msg);
            break;
        }
    }

    if (idx == ttl)
        printf("Error: Unexpected error occurred.\n");
}

/* For attack demo */
#include "attack.h"
static unsigned long base;

using namespace std;
#include <vector>
vector<unsigned long> gg;
void ocall_sgx_push_gadget(unsigned long gadget)
{
    gg.push_back(gadget);
}
#include <time.h>
#define PAGE_SIZE 4096
#define UNIT_SIZE 32
unsigned long guess_in_page(unsigned long addr)
{
    addr = (addr & -PAGE_SIZE); // clear lower bits
    return addr + (((unsigned long)clock()) & ((PAGE_SIZE/UNIT_SIZE)-1)) * UNIT_SIZE;
}
#define SPACE_SIZE 0x2000000
unsigned long guess_in_space(unsigned long addr)
{
    if (addr < gg[1])
        return gg[0] + (((unsigned long)clock()) & ((SPACE_SIZE/UNIT_SIZE)-1)) * UNIT_SIZE;
    else
        return gg[1] + (((unsigned long)clock()) & ((SPACE_SIZE/UNIT_SIZE)-1)) * UNIT_SIZE;
}
unsigned long guess_base(unsigned long addr)
{
    unsigned long _base = 0x7f73c0000000;
    if (addr < gg[1])
        return (gg[0] - base + _base)
            + (((unsigned long)clock()) & ((SPACE_SIZE/UNIT_SIZE)-1)) * UNIT_SIZE;
    else
        return (gg[1] - base + _base)
            + (((unsigned long)clock()) & ((SPACE_SIZE/UNIT_SIZE)-1)) * UNIT_SIZE;
}

// Called by EEXIT attack
char stack_for_attack[0x80000];
const char *attack_msg = "ROP_EEXIT success";
extern "C" void attacked();
extern "C" void print_attack_msg(const char **msg) {
    puts(*msg);
    exit(1);
}

#include "ocall.cpp"
//#include "mbedtls_sgx_u_net.c"

/* Application entry */
int main(int argc, char *argv[])
{
    sgx_launch_token_t token = {0};
    sgx_status_t ret = SGX_ERROR_UNEXPECTED;
    int updated = 0;
    sgx_enclave_id_t eid = 0;

    /* Initialize the enclave */
    ret = sgx_create_enclave(ENCLAVE_FILENAME, SGX_DEBUG_FLAG, &token, &updated, &eid, NULL);
    if (ret != SGX_SUCCESS) {
        print_error_message(ret);
        return -1;
    }

    /* Call enclave main */
    //base = *(unsigned long *)((unsigned long )sgx_create_enclave+0x212098);
    enclave_main(eid,argc,(char **)argv);

    /* Destroy the enclave */
    sgx_destroy_enclave(eid);
    return 0;
}

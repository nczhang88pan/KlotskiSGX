#include <stdarg.h>
#include <stdio.h>      /* vsnprintf */

#include <stdlib.h>
#include <time.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>
#include "ocall_type.h"
typedef void (*sighandler_t)(int);

#include "Enclave.h"
#include "Enclave_t.h"  /* print_string */

#include "sgx_trts.h"   /* sgx_read_rand */

#include "elf.h"        /* ELF */

#include "../App/attack.h"
#include "loader.h"
#include "debugConfig.h"

void printf(const char *fmt, ...)
{
    char buf[BUFSIZ] = {'\0'};
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(buf, BUFSIZ, fmt, ap);
    va_end(ap);
    ocall_print_string(buf);
}

#ifdef LD_DEBUG
#define dlog(...) printf(__VA_ARGS__)
#else
#define dlog(...)
#endif

extern char __elf_end;          /* defined in the linker script */
#define _HEAP_BASE (((addr_t)&__elf_end + 0xfff) & ~0xfff)

//const unsigned long __sgx_data_ofs = 0x2027000;
const unsigned long __sgx_data_ofs = 0x200000;



/*
 * Create a listening socket on bind_ip:port
 */
int mbedtls_net_bind( mbedtls_net_context *ctx, const char *bind_ip, const char *port, int proto )
{
    int ret;
#if BIGOBJECTOSHUFFLE
	mbedtls_net_context ctx_temp;
    mbedtls_net_context * ctx_temp_ptr=NULL;
    char *bind_ip_temp = copyStringToSGX((size_t)bind_ip);
    char *port_temp = copyStringToSGX((size_t)port);
	if(ctx){
        ctx_temp_ptr = &ctx_temp;
        copyingFromProgramToSGX((char*)ctx_temp_ptr,(size_t)ctx,sizeof(mbedtls_net_context));
    }
    ocall_mbedtls_net_bind(&ret, ctx_temp_ptr, bind_ip_temp, port_temp, proto);

    if(ctx){
        copyingFromSGXToProgram((size_t)ctx,(char*)ctx_temp_ptr,sizeof(mbedtls_net_context));
    }
    if(bind_ip)
        free(bind_ip_temp);
    if(port)
        free(port_temp);
#else
    size_t ctx_temp = (size_t)ctx;
    #if POINTER_HAS_TRANSLATED
    ctx = (mbedtls_net_context *)getRealAddress((size_t)ctx);
    bind_ip = (const char *)getRealAddress((size_t)bind_ip);
    port = (const char *)getRealAddress((size_t)port);
    #endif
    ocall_mbedtls_net_bind(&ret, ctx, bind_ip, port, proto);
#endif
    return( ret );

}

/*
 * Accept a connection from a remote client
 */
int mbedtls_net_accept( mbedtls_net_context *bind_ctx,
                        mbedtls_net_context *client_ctx,
                        void *client_ip, size_t buf_size, size_t *ip_len )
{
    int ret;
    /*
     - bind_ctx: int fd [OUT]
     - client_ctx: int fd [IN]
     - client_ip: [IN]
     - buf_size: sizeof client_ip
     - ip_len: receiver of ip_len [IN]
    */
#if BIGOBJECTOSHUFFLE
    mbedtls_net_context bind_ctx_temp;
    mbedtls_net_context client_ctx_temp;
    mbedtls_net_context * bind_ctx_temp_ptr=NULL;
    mbedtls_net_context * client_ctx_temp_ptr=NULL;
    void *client_ip_temp=NULL;
    size_t ip_len_temp;
    size_t *ip_len_temp_ptr=NULL;

    if(bind_ctx){
        bind_ctx_temp_ptr = &bind_ctx_temp;
        copyingFromProgramToSGX((char *)bind_ctx_temp_ptr,(size_t)bind_ctx,sizeof(mbedtls_net_context));
    }
    if(client_ctx){
        client_ctx_temp_ptr = &client_ctx_temp;
        copyingFromProgramToSGX((char *)client_ctx_temp_ptr,(size_t)client_ctx,sizeof(mbedtls_net_context));
    }
    if(client_ip){
        client_ip_temp = (void*)malloc(buf_size);
        copyingFromProgramToSGX((char *)client_ip_temp,(size_t)client_ip,buf_size);
    }
    if(ip_len){
        ip_len_temp_ptr = &ip_len_temp;
        copyingFromProgramToSGX((char *)ip_len_temp_ptr,(size_t)ip_len,sizeof(size_t));
    }

    ocall_mbedtls_net_accept(&ret, bind_ctx_temp_ptr, client_ctx_temp_ptr, client_ip_temp, buf_size, ip_len_temp_ptr);

    if(bind_ctx){
        copyingFromSGXToProgram((size_t)bind_ctx,(char *)bind_ctx_temp_ptr,sizeof(mbedtls_net_context));
    }
    if(client_ctx){
        copyingFromSGXToProgram((size_t)client_ctx,(char *)client_ctx_temp_ptr,sizeof(mbedtls_net_context));
    }
    if(client_ip){
        copyingFromSGXToProgram((size_t)client_ip,(char *)client_ip_temp,buf_size);
        free(client_ip_temp);
    }
    if(ip_len){
        copyingFromSGXToProgram((size_t)ip_len,(char *)ip_len_temp_ptr,sizeof(size_t));
    }

#else
#if POINTER_HAS_TRANSLATED
    bind_ctx = (mbedtls_net_context *)getRealAddress((size_t)bind_ctx);
    client_ctx = (mbedtls_net_context *)getRealAddress((size_t)client_ctx);
    client_ip = (void *)getRealAddress((size_t)client_ip);
    ip_len = (size_t *)getRealAddress((size_t)ip_len);
#endif
    ocall_mbedtls_net_accept(&ret, bind_ctx, client_ctx, client_ip, buf_size, ip_len);
#endif
    return ret;
}

/*
 * Read at most 'len' characters, blocking for at most 'timeout' ms
 */
int mbedtls_net_recv_timeout( void *ctx, unsigned char *buf, size_t len,
                      uint32_t timeout )
{
int ret;
#if BIGOBJECTOSHUFFLE
    mbedtls_net_context ctx_temp;
    mbedtls_net_context *ctx_temp_ptr=NULL;
    unsigned char *buf_temp=NULL;
    if(ctx){
        ctx_temp_ptr = &ctx_temp;
        copyingFromProgramToSGX((char*)ctx_temp_ptr,(size_t)ctx,sizeof(mbedtls_net_context));
    }
    if(buf){
        buf_temp = (unsigned char*)malloc(len);
        // copyingFromProgramToSGX(buf_temp,(size_t)buf,len);
    }

    ocall_mbedtls_net_recv_timeout(&ret, (mbedtls_net_context*) ctx_temp_ptr, buf_temp, len, timeout);

    if(ctx){
        copyingFromSGXToProgram((size_t)ctx,(char*)ctx_temp_ptr,sizeof(mbedtls_net_context));
    }
    if(buf){
        copyingFromSGXToProgram((size_t)buf,(char*)buf_temp,len);
        free(buf_temp);
    }
    

#else
#if POINTER_HAS_TRANSLATED
    ctx = (mbedtls_net_context *)getRealAddress((size_t)ctx);
    buf = (unsigned char *)getRealAddress((size_t)buf);
#endif
    ocall_mbedtls_net_recv_timeout(&ret, (mbedtls_net_context*) ctx, buf, len, timeout);
#endif
    return ret;
}

/*
 * Write at most 'len' characters
 */
int mbedtls_net_send( void *ctx, const unsigned char *buf, size_t len )
{
    int ret;
#if BIGOBJECTOSHUFFLE
    mbedtls_net_context ctx_temp;
    mbedtls_net_context *ctx_temp_ptr=NULL;
    unsigned char *buf_temp=NULL;
    if(ctx){
        ctx_temp_ptr = &ctx_temp;
        copyingFromProgramToSGX((char*)ctx_temp_ptr,(size_t)ctx,sizeof(mbedtls_net_context));
    }
    if(buf){
        buf_temp = (unsigned char*)malloc(len);
        copyingFromProgramToSGX((char *)buf_temp,(size_t)buf,len);
    }

    ocall_mbedtls_net_send(&ret, (mbedtls_net_context*) ctx_temp_ptr, buf_temp, len);

    if(ctx){
        copyingFromSGXToProgram((size_t)ctx,(char*)ctx_temp_ptr,sizeof(mbedtls_net_context));
    }
    if(buf){
        // copyingFromSGXToProgram((size_t)buf,(char*)buf_temp,len);
        free(buf_temp);
    }


#else
#if POINTER_HAS_TRANSLATED
    ctx = (mbedtls_net_context *)getRealAddress((size_t)ctx);
    buf = (const unsigned char *)getRealAddress((size_t)buf);
#endif
    ocall_mbedtls_net_send(&ret, (mbedtls_net_context*) ctx, buf, len);
#endif
    return ret;
}

/*
 * Gracefully close the connection
 */
void mbedtls_net_free( mbedtls_net_context *ctx )
{
    sgx_status_t ret;
#if BIGOBJECTOSHUFFLE
    mbedtls_net_context ctx_temp;
    mbedtls_net_context *ctx_temp_ptr=NULL;
    if(ctx){
        ctx_temp_ptr = &ctx_temp;
        copyingFromProgramToSGX((char*)ctx_temp_ptr,(size_t)ctx,sizeof(mbedtls_net_context));
    }
    ret = ocall_mbedtls_net_free((mbedtls_net_context*) ctx_temp_ptr);

    if(ctx){
        copyingFromSGXToProgram((size_t)ctx,(char*)ctx_temp_ptr,sizeof(mbedtls_net_context));
    }

#else
#if POINTER_HAS_TRANSLATED
    ctx = (mbedtls_net_context *)getRealAddress((size_t)ctx);
#endif
    ret = ocall_mbedtls_net_free((mbedtls_net_context*) ctx);
#endif
    if (ret != SGX_SUCCESS)
    {
        printf("Error: mbedtls_net_free returned %d", ret);
    }
}

#include "loader.cpp"

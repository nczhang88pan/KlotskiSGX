#ifdef LD_DEBUG
#define abort() sgx_exit(1)
#else
#define abort()
#endif
#include "./measure/OMeasure.h"
#include "debugConfig.h"

struct OcallReserved{
    struct tm localtime;
    struct tm gmtime;
    addrinfo addrinfoarr[64];
    struct servent serventret;
    struct protoent protoentret;
    char envret[0x100];
};

static clock_t sgx_clock()
{
    clock_t retv;
    sgx_status_t sgx_retv;
    if((sgx_retv = ocall_sgx_clock(&retv)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    return retv;
}
static time_t sgx_time(time_t *timep)
{
    time_t retv;
    sgx_status_t sgx_retv;

#if BIGOBJECTOSHUFFLE
    time_t timeTemp; 
    if((sgx_retv = ocall_sgx_time(&retv, &timeTemp)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    copyingFromSGXToProgram((size_t)timep,(char *)&timeTemp,sizeof(time_t));

#else
    #if POINTER_HAS_TRANSLATED
    timep = (time_t *)getRealAddress((size_t)timep);
    #endif
    if((sgx_retv = ocall_sgx_time(&retv, timep)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif

    return retv;
}
static struct tm localtime;
static struct tm *sgx_localtime(const time_t *timep)
{
    // TODO: copy res to enclave mem region
    struct tm *retv;
    sgx_status_t sgx_retv;

#if BIGOBJECTOSHUFFLE
    time_t timeTemp; 
    copyingFromProgramToSGX((char *)&timeTemp,(size_t)timep,sizeof(time_t));
    if((sgx_retv = ocall_sgx_localtime(&retv, &timeTemp)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    copyingFromSGXToProgram((size_t)timep,(char *)&timeTemp,sizeof(time_t));
#else
    #if POINTER_HAS_TRANSLATED
    timep = (time_t *)getRealAddress((size_t)timep);
    #endif
    if((sgx_retv = ocall_sgx_localtime(&retv, timep)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif
    cpy((char *)&localtime, (char *)retv, sizeof(struct tm));
    return &localtime;
}

static struct tm gmtime;
static struct tm *sgx_gmtime(const time_t *timep)
{
    struct tm *retv;
    sgx_status_t sgx_retv;
#if BIGOBJECTOSHUFFLE
    time_t timeTemp; 
    copyingFromProgramToSGX((char *)&timeTemp,(size_t)timep,sizeof(time_t));
    if((sgx_retv = ocall_sgx_gmtime(&retv, &timeTemp)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    copyingFromSGXToProgram((size_t)timep,(char *)&timeTemp,sizeof(time_t));
#else
    #if POINTER_HAS_TRANSLATED
    timep = (time_t *)getRealAddress((size_t)timep);
    #endif
    if((sgx_retv = ocall_sgx_gmtime(&retv, timep)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif
    cpy((char *)&gmtime, (char *)retv, sizeof(struct tm));
    return &gmtime;
}

static time_t sgx_mktime(struct tm *timeptr)
{
    time_t retv;
    sgx_status_t sgx_retv;
#if BIGOBJECTOSHUFFLE
    struct tm timeTemp; 
    copyingFromProgramToSGX((char *)&timeTemp,(size_t)timeptr,sizeof(struct tm));
    if((sgx_retv = ocall_sgx_mktime(&retv, &timeTemp)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    copyingFromSGXToProgram((size_t)timeptr,(char *)&timeTemp,sizeof(struct tm));
#else
    #if POINTER_HAS_TRANSLATED
    timeptr = (struct tm *)getRealAddress((size_t)timeptr);
    #endif
    if((sgx_retv = ocall_sgx_mktime(&retv, timeptr)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif
    return retv;
}
static int sgx_gettimeofday(struct timeval *tv, struct timezone *tz)
{
    int retv;
    sgx_status_t sgx_retv;

#if BIGOBJECTOSHUFFLE
    struct timeval tvTemp;
    struct timezone tzTemp;
    struct timeval *tvTempPtr;
    struct timezone *tzTempPtr;
    if(tv){
        tvTempPtr = &tvTemp;
        copyingFromProgramToSGX((char *)&tvTemp,(size_t)tv,sizeof(struct timeval));
    }else 
        tvTempPtr=NULL;

    if(tz){
        tzTempPtr = &tzTemp;
        copyingFromProgramToSGX((char *)&tzTemp,(size_t)tz,sizeof(struct timezone));
    }else 
        tzTempPtr=NULL;

    if((sgx_retv = ocall_sgx_gettimeofday(&retv, &tvTemp, &tzTemp)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    if(tv)
        copyingFromSGXToProgram((size_t)tv,(char *)&tvTemp,sizeof(struct timeval));
    if(tz)
        copyingFromSGXToProgram((size_t)tz,(char *)&tzTemp,sizeof(struct timezone));
#else
#if POINTER_HAS_TRANSLATED
    tv = (struct timeval *)getRealAddress((size_t)tv);
    tz = (struct timezone *)getRealAddress((size_t)tz);
#endif
    if((sgx_retv = ocall_sgx_gettimeofday(&retv, tv, tz)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif
    return retv;
}
static int sgx_puts(const char *str)
{
    int retv;
    sgx_status_t sgx_retv;
#if BIGOBJECTOSHUFFLE
    char *strTemp = copyStringToSGX((size_t)str);
    if((sgx_retv = ocall_sgx_puts(&retv, strTemp)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    free(strTemp);
#else
#if POINTER_HAS_TRANSLATED
    str = (const char *)getRealAddress((size_t)str);
#endif
    if((sgx_retv = ocall_sgx_puts(&retv, str)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif
    return retv;
}
static int sgx_open(const char *pathname, int flags, unsigned mode)
{
    int retv;
    sgx_status_t sgx_retv;
#if BIGOBJECTOSHUFFLE  
    char *pathnameTemp = copyStringToSGX((size_t)pathname);
    if((sgx_retv = ocall_sgx_open(&retv, pathnameTemp, flags, mode)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    free(pathnameTemp);
#else
#if POINTER_HAS_TRANSLATED
    pathname = (const char *)getRealAddress((size_t)pathname);
#endif
    if((sgx_retv = ocall_sgx_open(&retv, pathname, flags, mode)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif
    return retv;
}
static int sgx_close(int fd)
{
    int retv;
    sgx_status_t sgx_retv;
    if((sgx_retv = ocall_sgx_close(&retv, fd)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    return retv;
}

int times = 0;
static ssize_t sgx_read(int fd, char * buf, size_t buf_len)
{
    ssize_t retv;
    sgx_status_t sgx_retv;
    // if(times == 0){
    //     printf(" read:%ld ",sgx_clock());
    //     times+=1;
    // }
    
#if BIGOBJECTOSHUFFLE
    char *bufTemp = (char*)malloc(buf_len);
    if((sgx_retv = ocall_sgx_read(&retv, fd, bufTemp, buf_len)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    copyingFromSGXToProgram((size_t)buf,bufTemp,buf_len);
    free(bufTemp);
#else
#if POINTER_HAS_TRANSLATED
    buf = (char *)getRealAddress((size_t)buf);
#endif
    if((sgx_retv = ocall_sgx_read(&retv, fd, buf, buf_len)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif    
    return retv;
}
static ssize_t sgx_write(int fd, const char *buf, size_t n)
{
    ssize_t retv;
    sgx_status_t sgx_retv;
#if BIGOBJECTOSHUFFLE
    char *bufTemp = (char*)malloc(n);
    copyingFromProgramToSGX(bufTemp,(size_t)buf,n);
    if((sgx_retv = ocall_sgx_write(&retv, fd, bufTemp, n)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    
    free(bufTemp);
#else
#if POINTER_HAS_TRANSLATED
    buf = (const char *)getRealAddress((size_t)buf);
#endif
    if((sgx_retv = ocall_sgx_write(&retv, fd, buf, n)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif
    return retv;
}
static off_t sgx_lseek(int fildes, off_t offset, int whence)
{
    off_t retv;
    sgx_status_t sgx_retv;
    if((sgx_retv = ocall_sgx_lseek(&retv, fildes, offset, whence)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    return retv;
}
static int sgx_socket(int af, int type, int protocol)
{
    int retv;
    sgx_status_t sgx_retv;
    if((sgx_retv = ocall_sgx_socket(&retv, af, type, protocol)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    return retv;
}
static int sgx_bind(int s, const struct sockaddr *addr, size_t addr_size)
{
    int retv;
    sgx_status_t sgx_retv;
#if BIGOBJECTOSHUFFLE
    struct sockaddr addrTemp;
    copyingFromProgramToSGX((char*)(&addrTemp),(size_t)addr,sizeof(struct sockaddr));
    if((sgx_retv = ocall_sgx_bind(&retv, s, (unsigned long)&addrTemp, addr_size)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#else
#if POINTER_HAS_TRANSLATED
    addr = (const struct sockaddr *)getRealAddress((size_t)addr);
#endif
    if((sgx_retv = ocall_sgx_bind(&retv, s, (unsigned long)addr, addr_size)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif
    return retv;
}
static int sgx_connect(int s, const struct sockaddr *addr, size_t addrlen)
{
    int retv;
    sgx_status_t sgx_retv;
#if BIGOBJECTOSHUFFLE
    struct sockaddr addrTemp;
    copyingFromProgramToSGX((char*)(&addrTemp),(size_t)addr,sizeof(struct sockaddr));
    if((sgx_retv = ocall_sgx_connect(&retv, s, &addrTemp, addrlen)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#else    
#if POINTER_HAS_TRANSLATED
    addr = (const struct sockaddr *)getRealAddress((size_t)addr);
#endif
    if((sgx_retv = ocall_sgx_connect(&retv, s, addr, addrlen)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif
    return retv;
}
static int sgx_listen(int s, int backlog)
{
    int retv;
    sgx_status_t sgx_retv;
    if((sgx_retv = ocall_sgx_listen(&retv, s, backlog)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    return retv;
}
static int sgx_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
    int retv;
    sgx_status_t sgx_retv;
#if BIGOBJECTOSHUFFLE
    struct sockaddr addrTemp;
    copyingFromProgramToSGX((char*)(&addrTemp),(size_t)addr,sizeof(struct sockaddr));
    if((sgx_retv = ocall_sgx_accept(&retv, s, &addrTemp, (size_t)*addrlen, addrlen))
            != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#else
#if POINTER_HAS_TRANSLATED
    addr = (struct sockaddr *)getRealAddress((size_t)addr);
    addrlen = (socklen_t *)getRealAddress((size_t)addrlen);
#endif
    if((sgx_retv = ocall_sgx_accept(&retv, s, addr, (size_t)*addrlen, addrlen))
            != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif
    return retv;
}

static int sgx_fstat(int fd, struct stat *buf)
{
    int retv;
    sgx_status_t sgx_retv;

#if BIGOBJECTOSHUFFLE
    struct stat *bufTemp = (struct stat *)malloc(144);
    copyingFromProgramToSGX((char*)(bufTemp),(size_t)buf,144);
    if((sgx_retv = ocall_sgx_fstat(&retv, fd, bufTemp)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    copyingFromSGXToProgram((size_t)buf,(char *)bufTemp,144);
    free(bufTemp);
#else
#if POINTER_HAS_TRANSLATED
    buf = ( struct stat *)getRealAddress((size_t)buf);
#endif
    if((sgx_retv = ocall_sgx_fstat(&retv, fd, buf)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif
    return retv;
}
static ssize_t sgx_send(int s, const void *buf, size_t len, int flags)
{
    ssize_t retv;
    sgx_status_t sgx_retv;
#if BIGOBJECTOSHUFFLE
    void *bufTemp = (void *)malloc(len);
    copyingFromProgramToSGX((char*)(bufTemp),(size_t)buf,len);
    if((sgx_retv = ocall_sgx_send(&retv, s, bufTemp, len, flags)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    free(bufTemp);
#else
#if POINTER_HAS_TRANSLATED
    buf = (const void *)getRealAddress((size_t)buf);
#endif
    if((sgx_retv = ocall_sgx_send(&retv, s, buf, len, flags)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif
    return retv;
}

static ssize_t sgx_recv(int s, void *buf, size_t len, int flags)
{
    ssize_t retv;
    sgx_status_t sgx_retv;
#if BIGOBJECTOSHUFFLE
    void *bufTemp = (void *)malloc(len);
    if((sgx_retv = ocall_sgx_recv(&retv, s, bufTemp, len, flags)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    copyingFromSGXToProgram((size_t)buf,(char *)bufTemp,len);
    free(bufTemp);
#else
#if POINTER_HAS_TRANSLATED
    buf = (void *)getRealAddress((size_t)buf);
#endif
    if((sgx_retv = ocall_sgx_recv(&retv, s, buf, len, flags)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif
    return retv;
}
static ssize_t sgx_sendto(int sockfd, const void *buf, size_t len, int flags,
        const struct sockaddr *dest_addr, size_t addrlen)
{
    ssize_t retv;
    sgx_status_t sgx_retv;
#if BIGOBJECTOSHUFFLE
    void *bufTemp = (void *)malloc(len);
    struct sockaddr dest_addrTemp;
    copyingFromProgramToSGX((char*)bufTemp,(size_t)buf,len);
    copyingFromProgramToSGX((char*)&dest_addrTemp,(size_t)dest_addr,sizeof(struct sockaddr));
    if((sgx_retv = ocall_sgx_sendto(&retv, sockfd, bufTemp, len, flags,
                    &dest_addrTemp, addrlen)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    free(bufTemp);
#else
#if POINTER_HAS_TRANSLATED
    buf = (const void *)getRealAddress((size_t)buf);
    dest_addr = (const struct sockaddr *)getRealAddress((size_t)dest_addr);
#endif
    if((sgx_retv = ocall_sgx_sendto(&retv, sockfd, buf, len, flags,
                    dest_addr, addrlen)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif
    return retv;
}
static ssize_t sgx_recvfrom(int s, void *buf, size_t len, int flags,
        struct sockaddr *dest_addr, socklen_t* addrlen)
{
    ssize_t retv;
    sgx_status_t sgx_retv;
#if BIGOBJECTOSHUFFLE
    void *bufTemp = (void *)malloc(len);
    struct sockaddr dest_addrTemp;
    socklen_t addrlenTemp;
    copyingFromProgramToSGX((char*)bufTemp,(size_t)buf,len);
    copyingFromProgramToSGX((char*)&dest_addrTemp,(size_t)dest_addr,sizeof(struct sockaddr));
    copyingFromProgramToSGX((char*)&addrlenTemp,(size_t)addrlen,sizeof(socklen_t));
    if((sgx_retv = ocall_sgx_recvfrom(&retv, s, bufTemp, len, flags,
                    &dest_addrTemp, addrlenTemp, &addrlenTemp)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    copyingFromSGXToProgram((size_t)buf,(char *)bufTemp,len);
    copyingFromSGXToProgram((size_t)addrlen,(char*)&addrlenTemp,sizeof(socklen_t));
    free(bufTemp);
#else
#if POINTER_HAS_TRANSLATED
    buf = (void *)getRealAddress((size_t)buf);
    dest_addr = (struct sockaddr *)getRealAddress((size_t)dest_addr);
    addrlen = (socklen_t*)getRealAddress((size_t)addrlen);
#endif
    if((sgx_retv = ocall_sgx_recvfrom(&retv, s, buf, len, flags,
                    dest_addr, *addrlen, addrlen)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif
    return retv;
}
static int sgx_gethostname(char *name, size_t namelen)
{
    int retv;
    sgx_status_t sgx_retv;
#if BIGOBJECTOSHUFFLE
    char *nameTemp = (char *)malloc(namelen);
    if((sgx_retv = ocall_sgx_gethostname(&retv, nameTemp, namelen)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }    
    copyingFromSGXToProgram((size_t)name,nameTemp,namelen);
    free(nameTemp);
#else
#if POINTER_HAS_TRANSLATED
    name = (char *)getRealAddress((size_t)name);
#endif
    if((sgx_retv = ocall_sgx_gethostname(&retv, name, namelen)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif
    return retv;
}

/*
int getaddrinfo(const char *node, const char *service,
        const struct addrinfo *hints,
        struct addrinfo **res);
        */
#define INFO_MAX 64
static addrinfo addrinfoarr[INFO_MAX];
static int sgx_getaddrinfo(const char *node, const char *service,
        const struct addrinfo *hints, unsigned long *res)
{
    // TODO: copy res to enclave mem region
    int retv, i;
    sgx_status_t sgx_retv;
#if BIGOBJECTOSHUFFLE
    void *__tmp = NULL;
    char *nodeTemp;
    char *serviceTemp;
    struct addrinfo *hintsTemp;
    unsigned long *resTemp;
	size_t _len_node = node ? getStringLength((size_t)node) + 1 : 0;
	size_t _len_service = service ? getStringLength((size_t)service) + 1 : 0;
	size_t _len_hints = 48;
	size_t _len_res = sizeof(*res);
    size_t ocalloc_size;

	ocalloc_size += (node != NULL) ? _len_node : 0;
	ocalloc_size += (service != NULL) ? _len_service : 0;
	ocalloc_size += (hints != NULL) ? _len_hints : 0;
	ocalloc_size += (res != NULL) ? _len_res : 0;

	__tmp = (void *)malloc(ocalloc_size);

    ocalloc_size=0;
    if(node){
        nodeTemp= (char *)__tmp;
        copyingFromProgramToSGX(nodeTemp,(size_t)node,_len_node);
        ocalloc_size+=_len_node;
    }else nodeTemp=NULL;

    if(service){
        serviceTemp= (char *)((size_t)__tmp+ocalloc_size);
        copyingFromProgramToSGX(serviceTemp,(size_t)service,_len_service);
        ocalloc_size+=_len_service;
    }else nodeTemp=NULL;

    if(hints){
        hintsTemp= (struct addrinfo *)((size_t)__tmp+ocalloc_size);
        copyingFromProgramToSGX((char *)hintsTemp,(size_t)hints,_len_hints);
        ocalloc_size+=_len_hints;
    }else nodeTemp=NULL;
    
    if(res){
        resTemp= (unsigned long *)((size_t)__tmp+ocalloc_size);
        copyingFromProgramToSGX((char *)resTemp,(size_t)resTemp,_len_res);
    }else nodeTemp=NULL;

    if((sgx_retv = ocall_sgx_getaddrinfo(&retv, nodeTemp, serviceTemp, hintsTemp,
                    resTemp)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }

    if(node)
        copyingFromSGXToProgram((size_t)node,(char *)nodeTemp,_len_node);

    if(service)
        copyingFromSGXToProgram((size_t)service,(char *)serviceTemp,_len_service);

    if(hints)
        copyingFromSGXToProgram((size_t)hints,(char *)hintsTemp,_len_hints);
    
    if(res)
        copyingFromSGXToProgram((size_t)resTemp,(char *)resTemp,_len_res);
    
    i = 0;
    for (addrinfo *rp = (addrinfo *)*resTemp; i < INFO_MAX && rp != NULL;
            rp = rp->ai_next, ++i)
        cpy((char *)&addrinfoarr[i], (char *)rp, sizeof(addrinfo));
    if (i == INFO_MAX) {
        ocall_sgx_puts(&retv, "FAILED!, increase INFO_MAX!");
        abort();
    }

    free(__tmp);
    
#else
#if POINTER_HAS_TRANSLATED
    node = (const char *)getRealAddress((size_t)node);
    service = (const char *)getRealAddress((size_t)service);
    hints = (const struct addrinfo *)getRealAddress((size_t)hints);
    res = (unsigned long *)getRealAddress((size_t)res);
#endif
    if((sgx_retv = ocall_sgx_getaddrinfo(&retv, node, service, hints,
                    res)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    i = 0;
    for (addrinfo *rp = (addrinfo *)*res; i < INFO_MAX && rp != NULL;
            rp = rp->ai_next, ++i)
        cpy((char *)&addrinfoarr[i], (char *)rp, sizeof(addrinfo));
    if (i == INFO_MAX) {
        ocall_sgx_puts(&retv, "FAILED!, increase INFO_MAX!");
        abort();
    }
#endif
    return retv;
}

static char envret[0x100];
static char *sgx_getenv(const char *env)
{
    // TODO: copy res to enclave mem region
    char *retv;
    sgx_status_t sgx_retv;
#if BIGOBJECTOSHUFFLE
    char *envTemp = copyStringToSGX((size_t)env);
    if((sgx_retv = ocall_sgx_getenv(&retv, envTemp)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    free(envTemp);
#else
#if POINTER_HAS_TRANSLATED
    env = (const char *)getRealAddress((size_t)env);
#endif
    if((sgx_retv = ocall_sgx_getenv(&retv, env)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif
    size_t i;
    if(retv!=NULL){
        for (i = 0;retv[i];++i) envret[i] = retv[i];
        envret[i] = '\0';
        return envret;
    }else{
        return NULL;
    }
}
static int sgx_getsockname(int s, struct sockaddr *name, socklen_t *addrlen)
{
    int retv;
    sgx_status_t sgx_retv;
#if BIGOBJECTOSHUFFLE
    socklen_t addrlenTemp;
    struct sockaddr *nameTemp=NULL;

    copyingFromProgramToSGX((char *)&addrlenTemp,(size_t)addrlen,sizeof(socklen_t));
        
    if(name){
        nameTemp = (struct sockaddr *)malloc(sizeof(struct sockaddr));
        copyingFromProgramToSGX((char *)nameTemp,(size_t)name,sizeof(struct sockaddr));
    }

    if((sgx_retv = ocall_sgx_getsockname(&retv, s, nameTemp, (size_t)addrlenTemp,
                    &addrlenTemp)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }

    copyingFromSGXToProgram((size_t)addrlen,(char*)&addrlenTemp,sizeof(socklen_t));
    if(name){
        copyingFromSGXToProgram((size_t)name,(char*)nameTemp,sizeof(struct sockaddr));
        free(nameTemp);
    }

#else
#if POINTER_HAS_TRANSLATED
    name = (struct sockaddr *)getRealAddress((size_t)name);
    addrlen = (socklen_t *)getRealAddress((size_t)addrlen);
#endif
    if((sgx_retv = ocall_sgx_getsockname(&retv, s, name, (size_t)*addrlen,
                    addrlen)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif
    return retv;
}
static int sgx_getsockopt(int s, int level, int optname, void *optval,
        socklen_t* optlen)
{
    int retv;
    sgx_status_t sgx_retv;
#if BIGOBJECTOSHUFFLE
    socklen_t optlenTemp;
    void *optvalTemp=NULL;

    copyingFromProgramToSGX((char *)&optlenTemp,(size_t)optlen,sizeof(socklen_t));
        
    if(optval){
        optvalTemp = (void *)malloc(optlenTemp);
        copyingFromProgramToSGX((char *)optvalTemp,(size_t)optval,optlenTemp);
    }

    if((sgx_retv = ocall_sgx_getsockopt(&retv, s, level, optname, optvalTemp,
                    optlenTemp, &optlenTemp)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }

    copyingFromSGXToProgram((size_t)optlen,(char*)&optlenTemp,sizeof(socklen_t));
    if(optvalTemp){
        copyingFromSGXToProgram((size_t)optval,(char*)optvalTemp,optlenTemp);
        free(optvalTemp);
    }

#else
#if POINTER_HAS_TRANSLATED
    optval = (void *)getRealAddress((size_t)optval);
    optlen = (socklen_t *)getRealAddress((size_t)optlen);
#endif
    if((sgx_retv = ocall_sgx_getsockopt(&retv, s, level, optname, optval,
                    *optlen, optlen)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif
    return retv;
}
static struct servent serventret;
static struct servent *sgx_getservbyname(const char *name, const char *proto)
{
    // TODO: copy res to enclave mem region
    struct servent *retv;
    sgx_status_t sgx_retv;
#if POINTER_HAS_TRANSLATED
    name = (const char *)getRealAddress((size_t)name);
    proto = (const char *)getRealAddress((size_t)proto);
#endif
    if((sgx_retv = ocall_sgx_getservbyname(&retv, name, proto)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    cpy((char *)&serventret, (char *)retv, sizeof(struct servent));
    return &serventret;
}
static struct protoent protoentret;
static struct protoent *sgx_getprotobynumber(int proto)
{
    // TODO: copy res to enclave mem region
    struct protoent *retv;
    sgx_status_t sgx_retv;
    if((sgx_retv = ocall_sgx_getprotobynumber(&retv, proto)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    cpy((char *)&protoentret, (char *)retv, sizeof(struct protoent));
    return &protoentret;
}
static int sgx_setsockopt(int s, int level, int optname, const void *optval, size_t optlen)
{
    int retv;
    sgx_status_t sgx_retv;
#if BIGOBJECTOSHUFFLE

    void *optvalTemp=NULL; 
    if(optval){
        optvalTemp = (void *)malloc(optlen);
        copyingFromProgramToSGX((char *)optvalTemp,(size_t)optval,optlen);
    }
    if((sgx_retv = ocall_sgx_setsockopt(&retv, s, level, optname, optvalTemp, optlen)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    if(optvalTemp){
        copyingFromSGXToProgram((size_t)optval,(char*)optvalTemp,optlen);
        free(optvalTemp);
    }

#else
#if POINTER_HAS_TRANSLATED
    optval = (const void *)getRealAddress((size_t)optval);
#endif
    if((sgx_retv = ocall_sgx_setsockopt(&retv, s, level, optname, optval, optlen)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
#endif
    return retv;
}
static unsigned short sgx_htons(unsigned short hostshort)
{
    unsigned short retv;
    sgx_status_t sgx_retv;
    if((sgx_retv = ocall_sgx_htons(&retv, hostshort)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    return retv;
}
static unsigned long sgx_htonl(unsigned long hostlong)
{
    unsigned long retv;
    sgx_status_t sgx_retv;
    if((sgx_retv = ocall_sgx_htonl(&retv, hostlong)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    return retv;
}
static unsigned short sgx_ntohs(unsigned short netshort)
{
    unsigned short retv;
    sgx_status_t sgx_retv;
    if((sgx_retv = ocall_sgx_ntohs(&retv, netshort)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    return retv;
}
static unsigned long sgx_ntohl(unsigned long netlong)
{
    unsigned long retv;
    sgx_status_t sgx_retv;
    if((sgx_retv = ocall_sgx_ntohl(&retv, netlong)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    return retv;
}
static sighandler_t sgx_signal(int signum, sighandler_t a)
{
    sighandler_t retv;
    sgx_status_t sgx_retv;
    if((sgx_retv = ocall_sgx_signal(&retv, signum, a)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    return retv;
}
static int sgx_shutdown(int a, int b)
{
    int retv;
    sgx_status_t sgx_retv;
    if((sgx_retv = ocall_sgx_shutdown(&retv, a, b)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    return retv;
}

static void sgx_exit(int code){
    coutResults(0);
    ocall_exit(code);
}

static void sgx_push_gadget(unsigned long gadget)
{
    sgx_status_t sgx_retv;
    if((sgx_retv = ocall_sgx_push_gadget(gadget)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
}


//measurement 
static bool has_start=false;
static int sgx_measure_init(uint64_t start, uint64_t size,uint64_t code_start,uint64_t code_size,uint64_t gp_start,uint64_t gp_size)
{
    int retv;
    sgx_status_t sgx_retv;
    if((sgx_retv = ocall_measure_init(&retv,start,size,code_start,code_size,gp_start,gp_size)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    return retv;
}

static void sgx_measure_start()
{
    int retv;
    sgx_status_t sgx_retv;
    if((sgx_retv = ocall_measure_start(&retv)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    has_start=true;
}

static void sgx_measure_start_random()
{
    int retv;
    if(!has_start) return;  //if measure starts,
    sgx_status_t sgx_retv;
    if((sgx_retv = ocall_measure_start(&retv)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
}

static void sgx_measure_stop()
{
    int retv;
    sgx_status_t sgx_retv;
    if((sgx_retv = ocall_measure_stop(&retv)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
}

static void sgx_measure_wait()
{
    int retv;
    sgx_status_t sgx_retv;
    if((sgx_retv = ocall_measure_wait(&retv)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
    has_start=false;
}

static void sgx_measure_wait_random()
{
    int retv;
    sgx_status_t sgx_retv;
    if(!has_start) return;   //if measure does not start, there is no need to wait
    if((sgx_retv = ocall_measure_wait(&retv)) != SGX_SUCCESS) {
        dlog(__FUNCTION__ " FAILED!, Error code = %d\n", sgx_retv);
        abort();
    }
}
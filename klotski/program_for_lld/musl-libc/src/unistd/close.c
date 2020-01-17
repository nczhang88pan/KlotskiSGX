#include <unistd.h>
#include <errno.h>
#include "libc.h"

// #if NOSGX_PAN
// #include <sgx-lib.h>

// int close(int fd)
// {
//     sgx_stub_info *stub = (sgx_stub_info *)STUB_ADDR;

//     stub->fcode = FUNC_CLOSE;
//     stub->out_arg1 = fd;

//     sgx_exit(stub->trampoline);

//     return stub->in_arg1;
// }
// #else
// #include "syscall.h"

// static int dummy(int fd)
// {
// 	return fd;
// }

// weak_alias(dummy, __aio_close);

// int close(int fd)
// {
// 	fd = __aio_close(fd);
// 	int r = __syscall_cp(SYS_close, fd);
// 	if (r == -EINTR) r = 0;
// 	return __syscall_ret(r);
// }
// #endif
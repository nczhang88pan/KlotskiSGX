#include "stdio_impl.h"
#include <unistd.h>

int __stdio_close(FILE *f)
{
	//return syscall(SYS_close, f->fd);
	return close(f->fd);
}

#include "stdio_impl.h"
#include <fcntl.h>
#include <string.h>
#include <errno.h>

FILE *fopen(const char *restrict filename, const char *restrict mode)
{
	FILE *f;
	int fd;
	int flags;

	/* Check for valid initial mode character */
	if (!strchr("rwa", *mode)) {
		errno = EINVAL;
		return 0;
	}

	/* Compute the flags to pass to open() */
	flags = __fmodeflags(mode);

	fd = open(filename,flags|O_LARGEFILE,0666);
	//fd = syscall_cp(SYS_open, filename, flags|O_LARGEFILE, 0666);
	// printf("%s,%u,%d,%s",__FUNCTION__,__LINE__,fd,mode);
	if (fd < 0) return 0;
// printf("%s,%u",__FUNCTION__,__LINE__);
	f = __fdopen(fd, mode);
	// printf("%s,%u",__FUNCTION__,__LINE__);
	if (f) return f;
// printf("%s,%u",__FUNCTION__,__LINE__);
	__syscall(SYS_close, fd);
	return 0;
}

LFS64(fopen);
/* a very simple test program */

#include <stdio.h>
#include <stdlib.h>

void enclave_main()
{
    int fd;
    char buf[MAX_OCALL_GET_LINE];
    size_t len;
    open("NNET.DAT", &fd);
    while (get_line(fd, buf))
    puts(buf);
    enclave_exit();
}

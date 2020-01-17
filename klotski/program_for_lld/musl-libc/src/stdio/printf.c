#include <stdio.h>
#include <stdarg.h>



char buff[BUFSIZ] = {'\0'};
int printf(const char *fmt, ...)
{
    int ret;
    va_list ap;
    va_start(ap, fmt);
    vsprintf(buff, fmt, ap);
    va_end(ap);
    puts(buff);
    return ret;
}
// int printf(const char *restrict fmt, ...)
// {
// 	int ret;
// 	va_list ap;
// 	va_start(ap, fmt);
// 	ret = vfprintf(stdout, fmt, ap);
// 	va_end(ap);
// 	return ret;
// }

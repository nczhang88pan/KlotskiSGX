/* a very simple test program */

#include <stdio.h>
#include <string.h>

char *str = "This is a long string";
int zb=1;

void enclave_main()
{
    int *a=&zb;
    *a = 9;
    printf("%d\n",zb);

    char *p = memchr(str, 'l', strlen(str));
    puts(p);
    enclave_exit();
}

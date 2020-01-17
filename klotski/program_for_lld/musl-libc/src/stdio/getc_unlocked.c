#include "stdio_impl.h"

int (getc_unlocked)(FILE *f)
{
	printf("%s,%s===================%u",__FILE__,__FUNCTION__,__LINE__);
	return getc_unlocked(f);
}

weak_alias (getc_unlocked, fgetc_unlocked);
weak_alias (getc_unlocked, _IO_getc_unlocked);

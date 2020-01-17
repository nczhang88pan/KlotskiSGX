#include <unistd.h>
#include "libc.h"
#include "syscall.h"
#include <time.h>
#include <fcntl.h>
#include <netdb.h>
#include <signal.h>
#include "../../include/sys/time.h"
#include "../../include/sys/socket.h"
#include "../../include/sys/stat.h"
#include "stdio_impl.h"
#include <errno.h>

void *_loader_stack_save=NULL;
void *_virtual_stack_save = NULL;
void *_virtual_stack_r13 = NULL;
void *rax_backup = NULL;

#if NOSGX_PAN
 void *ocall_table[36] = {
    (void *) sgx_clock,
    (void *) sgx_time,
    (void *) sgx_localtime,
    (void *) sgx_gmtime,
    (void *) sgx_mktime,
    (void *) sgx_gettimeofday,
    (void *) sgx_puts,
    (void *) sgx_open,
    (void *) sgx_close,
    (void *) sgx_read,
    (void *) sgx_write,
    (void *) sgx_lseek,
    (void *) sgx_socket,
    (void *) sgx_bind,
    (void *) sgx_connect,
    (void *) sgx_listen,
    (void *) sgx_accept,
    (void *) sgx_fstat,
    (void *) sgx_send,
    (void *) sgx_recv,
    (void *) sgx_sendto,
    (void *) sgx_recvfrom,
    (void *) sgx_gethostname,
    (void *) sgx_getaddrinfo,
    (void *) sgx_getenv,
    (void *) sgx_getsockname,
    (void *) sgx_getsockopt,
    (void *) sgx_getservbyname,
    (void *) sgx_getprotobynumber,
    (void *) sgx_setsockopt,
    (void *) sgx_htons,
    (void *) sgx_htonl,
    (void *) sgx_ntohs,
    (void *) sgx_ntohl,
    (void *) sgx_signal,
    (void *) sgx_shutdown,
};
#else
 void *ocall_table[36] = {
    (void *) clock_nosgx,
    (void *) time,
    (void *) localtime,
    (void *) gmtime,
    (void *) mktime,
    (void *) gettimeofday,
    (void *) puts_nosgx,
    (void *) open,
    (void *) close,
    (void *) read,
    (void *) write_nosgx,
    (void *) lseek,
    (void *) socket,
    (void *) bind,
    (void *) connect,
    (void *) listen,
    (void *) accept,
    (void *) fstat,
    (void *) send,
    (void *) recv,
    (void *) sendto,
    (void *) recvfrom,
    (void *) gethostname,
    (void *) getaddrinfo,
    (void *) getenv,
    (void *) getsockname,
    (void *) getsockopt,
    (void *) getservbyname,
    (void *) getprotobynumber,
    (void *) setsockopt,
    (void *) htons,
    (void *) htonl,
    (void *) ntohs,
    (void *) ntohl,
    (void *) signal,
    (void *) shutdown,
};
#endif

// // TODO: check if it breaks the calling ABI
// void do_sgx_ocall() {
//     __asm__ __volatile__ (
//         "mov (%0, %%r14, 8), %%r14\n"
//         "call *%%r14\n"
//     ::"r" (ocall_table));
// }
static __inline long syscall_0(long n)
{
	unsigned long ret;
	__asm__ __volatile__ ("syscall" : "=a"(ret) : "a"(n) : "rcx", "r11", "memory");
	return ret;
}

static __inline long syscall_1(long n, long a1)
{
	unsigned long ret;
	__asm__ __volatile__ ("syscall" : "=a"(ret) : "a"(n), "D"(a1) : "rcx", "r11", "memory");
	return ret;
}

static __inline long syscall_2(long n, long a1, long a2)
{
	unsigned long ret;
	__asm__ __volatile__ ("syscall" : "=a"(ret) : "a"(n), "D"(a1), "S"(a2)
						  : "rcx", "r11", "memory");
	return ret;
}

static __inline long syscall_3(long n, long a1, long a2, long a3)
{
	unsigned long ret;
	__asm__ __volatile__ ("syscall" : "=a"(ret) : "a"(n), "D"(a1), "S"(a2),
						  "d"(a3) : "rcx", "r11", "memory");
	return ret;
}

static __inline long syscall_4(long n, long a1, long a2, long a3, long a4)
{
	unsigned long ret;
	register long r10 __asm__("r10") = a4;
	__asm__ __volatile__ ("syscall" : "=a"(ret) : "a"(n), "D"(a1), "S"(a2),
						  "d"(a3), "r"(r10): "rcx", "r11", "memory");
	return ret;
}

static __inline long syscall_5(long n, long a1, long a2, long a3, long a4, long a5)
{
	unsigned long ret;
	register long r10 __asm__("r10") = a4;
	register long r8 __asm__("r8") = a5;
	__asm__ __volatile__ ("syscall" : "=a"(ret) : "a"(n), "D"(a1), "S"(a2),
						  "d"(a3), "r"(r10), "r"(r8) : "rcx", "r11", "memory");
	return ret;
}

static __inline long syscall_6(long n, long a1, long a2, long a3, long a4, long a5, long a6)
{
	unsigned long ret;
	register long r10 __asm__("r10") = a4;
	register long r8 __asm__("r8") = a5;
	register long r9 __asm__("r9") = a6;
	__asm__ __volatile__ ("syscall" : "=a"(ret) : "a"(n), "D"(a1), "S"(a2),
						  "d"(a3), "r"(r10), "r"(r8), "r"(r9) : "rcx", "r11", "memory");
	return ret;
}


//clock

static int clock_gettime_stub(clockid_t clk, struct timespec *ts)
{
	int r = syscall_2(SYS_clock_gettime, clk, ts);
	if (!r) return r;
	if (r == -ENOSYS) {
		if (clk == CLOCK_REALTIME) {
			syscall_2(SYS_gettimeofday, ts, 0);
			ts->tv_nsec = (int)ts->tv_nsec * 1000;
			return 0;
		}
		r = -EINVAL;
	}
	errno = -r;
	return -1;
}

clock_t clock_nosgx()
{
	struct timespec ts;

	if (clock_gettime_stub(CLOCK_PROCESS_CPUTIME_ID, &ts))
		return -1;

	if (ts.tv_sec > LONG_MAX/1000000
	 || ts.tv_nsec/1000 > LONG_MAX-1000000*ts.tv_sec)
		return -1;

	return ts.tv_sec*1000000 + ts.tv_nsec/1000;
}




ssize_t write_nosgx(int fd, const void *buf, size_t count)
{
	return syscall_3(SYS_write, fd, buf, count);
	//return syscall_cp(SYS_write, fd, buf, count);
}

int puts_nosgx(const char *s)
{
	int r;
	FLOCK(stdout);
	r = -(fputs(s, stdout) < 0 || putc_unlocked('\n', stdout) < 0);
	FUNLOCK(stdout);
	return r;
}


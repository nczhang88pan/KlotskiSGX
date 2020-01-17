#void *memcpy(void *dest, const void *src, size_t n);
.global memcpy
.type memcpy,@function
.p2align 11
memcpy:
    test %rdx, %rdx
    jz 3f              #if n=0 ret
    
    mov %rdi, %rax
	cmp $8,%rdx        #if n>8 n->rcx n>>3 rep movsq   rdi->rsi 
	jc 1f               
	test $7,%edi
	jz 1f
2:	movsb

	dec %rdx
	test $7,%edi
	jnz 2b
1:	mov %rdx,%rcx
	shr $3,%rcx
	rep
	movsq

	and $7,%edx
	jz 3f
2:	movsb
	dec %edx
	jnz 2b
3:	pop %r14
	jmp *0x40(%r15)


# void *memmove(void *dest, const void *src, size_t n);
.global memmove
.type memmove,@function
.p2align 5
memmove:
	mov %rdi, %rax
	sub %rsi,%rax
	cmp %rdx,%rax
	jae memcpy

    xor %rax,%rax
	test %rdx,%rdx
	je 1f

2:	
	mov %rdx,%rcx
	lea -1(%rsi,%rdx),%rsi
	lea -1(%rdi,%rdx),%rdi

	std
	rep movsb
	cld
	lea 1(%rdi),%rax
1:  pop %r14
	jmp *0x40(%r15)


# void *memset(void *rdi (*s), int esi (c), size_t rdx (n));
.global memset
.type memset,@function
memset:

	and $0xff,%esi                     # limit esi to a char
	mov $0x101010101010101,%rax        
	mov %rdx,%rcx                      # n-> rcx
	mov %rdi,%r8                       # s -> r8
	imul %rsi,%rax                     # 
	cmp $16,%rcx
	jb 1f

	mov %rax,-8(%rdi,%rcx)
	shr $3,%rcx
	rep
	stosq
	mov %r8,%rax
	pop %r14
	jmp *0x40(%r15)

1:	test %ecx,%ecx
	jz 1f

	mov %al,(%rdi)
	mov %al,-1(%rdi,%rcx)
	cmp $2,%ecx
	jbe 1f

	mov %al,1(%rdi)
	mov %al,-2(%rdi,%rcx)
	cmp $4,%ecx
	jbe 1f

	mov %eax,(%rdi)
	mov %eax,-4(%rdi,%rcx)
	cmp $8,%ecx
	jbe 1f

	mov %eax,4(%rdi)
	mov %eax,-8(%rdi,%rcx)

1:	mov %r8,%rax
	pop %r14
	jmp *0x40(%r15)

# int strncmp(const char *_l, const char *_r, size_t n)
.global strncmp
.type strncmp,@function
strncmp:
    test %rdx,%rdx
    je 1f
	# dereference rdi
	rorx $0xb,%rdi,%r14
	call *0x60(%r15)
	rorx $0x35,%r14,%rdi

	rorx $0xb,%rsi,%r14
	callq *0x60(%r15)
	rorx $0x35,%r14,%rsi
    # end 
    mov (%rdi),%al
    test %al,%al
    je 3f

    mov $0x1,%ecx
    sub %rdx,%rcx
    inc %rdi

4:  movzbl (%rsi),%edx
    cmp %dl,%al
    jne 2f
    test %rcx,%rcx
    je 2f
    test %dl,%dl
    je 2f
    inc %rsi
    mov (%rdi),%al
    inc %rcx
    inc %rdi
    test %al,%al
    jne 4b 
    
3:  xor %eax,%eax
2:  movzbl %al,%eax
    movzbl (%rsi),%ecx
    sub %ecx,%eax
    pop %r14
	jmp *0x40(%r15)
1:  xor %eax, %eax
    pop %r14
	jmp *0x40(%r15)

.global addressDereference64
.type addressDereference64,@function
addressDereference64:
ret

.text
.global _start
.type _start, @function
.p2align 5
_start:
    jmp enclave_main

.global __syscall
.type __syscall,@function
__syscall:
	movq %rdi,%rax
	movq %rsi,%rdi
	movq %rdx,%rsi
	movq %rcx,%rdx
	movq %r8,%r10
	movq %r9,%r8
	movq 8(%rsp),%r9
	syscall
	ret

# this file is generated by lib/gen_ocall_stub.py script
.text
.global clock
.type clock, @function
.p2align 5
clock:
    mov $0, %r14
    jmp do_sgx_ocall_random

.global time
.type time, @function
.p2align 5
time:
    mov $1, %r14
    jmp do_sgx_ocall_random

.global localtime
.type localtime, @function
.p2align 5
localtime:
    mov $2, %r14
    jmp do_sgx_ocall_random

.global gmtime
.type gmtime, @function
.p2align 5
gmtime:
    mov $3, %r14
    jmp do_sgx_ocall_random

.global mktime
.type mktime, @function
.p2align 5
mktime:
    mov $4, %r14
    jmp do_sgx_ocall_random

.global gettimeofday
.type gettimeofday, @function
.p2align 5
gettimeofday:
    mov $5, %r14
    jmp do_sgx_ocall_random

# puts(char *)
.global puts
.type puts, @function
.p2align 5
puts:
    rorx $0xb,%rdi,%r14
	callq *0x60(%r15)
	rorx $0x35,%r14,%rdi
    mov $6, %r14
    jmp do_sgx_ocall_random

.global open
.type open, @function
.p2align 5
open:
    rorx $0xb,%rdi,%r14
	callq *0x60(%r15)
	rorx $0x35,%r14,%rdi
    mov $7, %r14
    jmp do_sgx_ocall_random

.global close
.type close, @function
.p2align 5
close:
    mov $8, %r14
    jmp do_sgx_ocall_random

.global read
.type read, @function
.p2align 5
read:
    rorx $0xb,%rsi,%r14
	callq *0x60(%r15)
	rorx $0x35,%r14,%rsi
    mov $9, %r14
    jmp do_sgx_ocall_random

.global write
.type write, @function
.p2align 5
# size_t write_nosgx(int fd, const void *buf, size_t count)
write:
    rorx $0xb,%rsi,%r14
    callq *0x60(%r15)
    rorx $0x35,%r14,%rsi
    mov $10, %r14
    jmp do_sgx_ocall_random

.global lseek
.type lseek, @function
.p2align 5
lseek:
    mov $11, %r14
    jmp do_sgx_ocall_random

.global socket
.type socket, @function
.p2align 5
socket:
    mov $12, %r14
    jmp do_sgx_ocall_random

.global bind
.type bind, @function
.p2align 5
bind:
    mov $13, %r14
    jmp do_sgx_ocall_random

.global connect
.type connect, @function
.p2align 5
connect:
    mov $14, %r14
    jmp do_sgx_ocall_random

.global listen
.type listen, @function
.p2align 5
listen:
    mov $15, %r14
    jmp do_sgx_ocall_random

.global accept
.type accept, @function
.p2align 5
accept:
    mov $16, %r14
    jmp do_sgx_ocall_random

.global fstat
.type fstat, @function
.p2align 5
fstat:
    mov $17, %r14
    jmp do_sgx_ocall_random

.global send
.type send, @function
.p2align 5
send:
    mov $18, %r14
    jmp do_sgx_ocall_random

.global recv
.type recv, @function
.p2align 5
recv:
    mov $19, %r14
    jmp do_sgx_ocall_random

.global sendto
.type sendto, @function
.p2align 5
sendto:
    mov $20, %r14
    jmp do_sgx_ocall_random

.global recvfrom
.type recvfrom, @function
.p2align 5
recvfrom:
    mov $21, %r14
    jmp do_sgx_ocall_random

.global gethostname
.type gethostname, @function
.p2align 5
gethostname:
    mov $22, %r14
    jmp do_sgx_ocall_random

.global getaddrinfo
.type getaddrinfo, @function
.p2align 5
getaddrinfo:
    mov $23, %r14
    jmp do_sgx_ocall_random

.global getenv
.type getenv, @function
.p2align 5
getenv:
    rorx $0xb,%rdi,%r14
	callq *0x60(%r15)
	rorx $0x35,%r14,%rdi
    mov $24, %r14
    jmp do_sgx_ocall_random

.global getsockname
.type getsockname, @function
.p2align 5
getsockname:
    mov $25, %r14
    jmp do_sgx_ocall_random

.global getsockopt
.type getsockopt, @function
.p2align 5
getsockopt:
    mov $26, %r14
    jmp do_sgx_ocall_random

.global getservbyname
.type getservbyname, @function
.p2align 5
getservbyname:
    mov $27, %r14
    jmp do_sgx_ocall_random

.global getprotobynumber
.type getprotobynumber, @function
.p2align 5
getprotobynumber:
    mov $28, %r14
    jmp do_sgx_ocall_random

.global setsockopt
.type setsockopt, @function
.p2align 5
setsockopt:
    mov $29, %r14
    jmp do_sgx_ocall_random

.global htons
.type htons, @function
.p2align 5
htons:
    mov $30, %r14
    jmp do_sgx_ocall_random

.global htonl
.type htonl, @function
.p2align 5
htonl:
    mov $31, %r14
    jmp do_sgx_ocall_random

.global ntohs
.type ntohs, @function
.p2align 5
ntohs:
    mov $32, %r14
    jmp do_sgx_ocall_random

.global ntohl
.type ntohl, @function
.p2align 5
ntohl:
    mov $33, %r14
    jmp do_sgx_ocall_random

.global signal
.type signal, @function
.p2align 5
signal:
    mov $34, %r14
    jmp do_sgx_ocall_random

.global shutdown
.type shutdown, @function
.p2align 5
shutdown:
        mov $35, %r14
    jmp do_sgx_ocall_random

.global exit
.type exit, @function
.p2align 5
exit:
    mov $36, %r14
    jmp do_sgx_ocall_random

.global mbedtls_net_bind
.type mbedtls_net_bind, @function
.p2align 5
mbedtls_net_bind:
# rdi
	rorx $0xb,%rdi,%r14
	callq *0x60(%r15)
	rorx $0x35,%r14,%rdi
# rsi 
	rorx $0xb,%rsi,%r14
	callq *0x60(%r15)
	rorx $0x35,%r14,%rsi
# rdx
    rorx $0xb,%rdx,%r14
	callq *0x60(%r15)
	rorx $0x35,%r14,%rdx
    mov $37, %r14
    jmp do_sgx_ocall_random

.global mbedtls_net_accept
.type mbedtls_net_accept, @function
.p2align 5
mbedtls_net_accept:
# rdi
	rorx $0xb,%rdi,%r14
	callq *0x60(%r15)
	rorx $0x35,%r14,%rdi
# rsi 
	rorx $0xb,%rsi,%r14
	callq *0x60(%r15)
	rorx $0x35,%r14,%rsi
# rdx
    rorx $0xb,%rdx,%r14
	callq *0x60(%r15)
	rorx $0x35,%r14,%rdx
# r8
    rorx $0xb,%r8,%r14
	callq *0x60(%r15)
	rorx $0x35,%r14,%r8 
    mov $38, %r14
    jmp do_sgx_ocall_random

.global mbedtls_net_recv_timeout
.type mbedtls_net_recv_timeout, @function
.p2align 5
mbedtls_net_recv_timeout:
# rdi
	rorx $0xb,%rdi,%r14
	callq *0x60(%r15)
	rorx $0x35,%r14,%rdi
# rsi 
	rorx $0xb,%rsi,%r14
	callq *0x60(%r15)
	rorx $0x35,%r14,%rsi
    mov $39, %r14
    jmp do_sgx_ocall_random

.global mbedtls_net_send
.type mbedtls_net_send, @function
.p2align 5
mbedtls_net_send:
# rdi
	rorx $0xb,%rdi,%r14
	callq *0x60(%r15)
	rorx $0x35,%r14,%rdi
# rsi 
	rorx $0xb,%rsi,%r14
	callq *0x60(%r15)
	rorx $0x35,%r14,%rsi
    mov $40, %r14
    jmp do_sgx_ocall_random

.global mbedtls_net_free
.type mbedtls_net_free, @function
.p2align 5
mbedtls_net_free:
# rdi
	rorx $0xb,%rdi,%r14
	callq *0x60(%r15)
	rorx $0x35,%r14,%rdi
    mov $41, %r14
    jmp do_sgx_ocall_random

.global sgx_measure_start
.type sgx_measure_start, @function
.p2align 5
sgx_measure_start:
    mov $43, %r14
    jmp do_sgx_ocall

.global MeasureInit
.type MeasureInit, @function
.p2align 5
MeasureInit:
    mov $44, %r14
    jmp do_sgx_ocall

.global do_sgx_ocall
.type do_sgx_ocall, @function
do_sgx_ocall:
    movq %rsp,(_virtual_stack_save)
    movq (_loader_stack_save),%rsp
    movq ocall_table(,%r14,8),%r14
    call *%r14
    movq (_virtual_stack_save),%rsp
    pop %r14
    jmp *0x40(%r15)

.global do_sgx_ocall_random
.type do_sgx_ocall_random, @function
do_sgx_ocall_random:
    movq %rsp,(_virtual_stack_save)
    movq (_loader_stack_save),%rsp
    movq ocall_table(,%r14,8),%r14
    call *%r14
    movq %rax,(rax_backup)
    movq $secureCopy,%r14
    movq %r13,(_virtual_stack_r13)
    jmp *%r14
#    pop %r14
#    rorx $0xc,%r14,%r14
#	add (%r15d,%r14d,8),%r14
#	rorx $0x34,%r14,%r14
#   jmp *%r14

.global secureCopy
.type secureCopy, @function
secureCopy:
    ret


#.global __fprintf_chk
#.type __fprintf_chk, @function
#__fprintf_chk:
#    syscall    


#.global __sprintf_chk
#.type __fprintf_chk, @function
#__fprintf_chk:
#    syscall 

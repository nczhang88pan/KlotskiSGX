#include "../../loader/Enclave/debugConfig.h"
#define Dereference_Pointer !POINTER_HAS_TRANSLATED
#void *memcpy_org(void *dest, const void *src, size_t n);
# rdi rsi rdx rax rcx 
.global memcpy_org
.type memcpy_org,@function
.p2align 11
memcpy_org:
    test %rdx, %rdx
    jz 3f              ;#if n=0 ret
    
    mov %rdx, %rax
	cmp $8,%rdx        ;#if n>8 n->rcx n>>3 rep movsq   rdi->rsi 
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
	jmp *0x80(%r15)

#void *memcpy_inner(void *dest, const void *src, size_t n);
# rdi rsi rdx rax rcx 
.global memcpy_inner
.type memcpy_inner,@function
.p2align 5
memcpy_inner:
    mov %rdx, %rax
	cmp $8,%rdx        ;#if n>8 n->rcx, n>>3 rep movsq   rdi->rsi 
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
3:	ret

#void *memcpy(void *dest, const void *src, size_t n);
.global memcpy
.type memcpy,@function
.p2align 5
memcpy:
    test %rdx, %rdx
    jz 4f              ;#if n=0 ret

    push %rbp          ;#reserve registers
    push %rbx

    #the logic values of dest and src are stored in 0x20(%r15) and 0x28(%r15)
    #reserved values may pointe to stack, thus its value is real virtual address.
    mov 0x20(%r15),%r8      ;#dest_logic
    mov 0x28(%r15),%r9      ;#src_logic

   
    mov %r8,%rbx       ;#dest_offet = (size) dest_logic & PAGE_MASK;
    and $0x7ff,%rbx
    
    mov %r9,%rbp       ;#src_offset = (size) src_logic & PAGE_MASK;
    and $0x7ff,%rbp

    mov $0,%r13         # size = 0;

1: #while
    mov %rbx,%r14        ;#step_size = (dest_offset > src_offset)? dest_offset:src_offset
    cmp %rbx,%rbp  
    cmovae %rbp,%r14
    mov $0x800,%eax     ;#step_size = PAGE_SIZE - step_size
    sub %r14,%rax
    
    ;#if(n<=step_size)
    cmp %rax,%rdx
    ja 2f
    call memcpy_inner
    add %r13,%rax
    pop %rbx
    pop %rbp
    pop %r14
	jmp *0x80(%r15)
    ;#endif

2:
    push %rdx
    mov %rax,%rdx
    call memcpy_inner         #memcpy_inner((void*)dest,(void*)src,step_size)
    pop %rdx

    sub %rax,%rdx       #n-=step_size
    add %rax,%r8        #dest_logic+=step_size
    add %rax,%r9        #src_logic+=step_size
    add %rax,%r13       #size+=step_size

    mov %r8,%rbx       #dest_offet = (size) dest_logic & PAGE_MASK;
    and $0x7ff,%rbx
    mov %r9,%rbp       #src_offset = (size) src_logic & PAGE_MASK;
    and $0x7ff,%rbp

                        ;#if(dest_offet==0 && dest_logic<0x33000000)
    cmp $0,%rbx             #DEREF(dest,boundary_dest)
    jne 2f
    cmp $0x33000000,%r8
    jae 2f
    #dereference dest  
	movq %r8,%r14      
	callq *0x60(%r15)
	movq %r14,%rdi

2:                      ;#if(src_offet==0 && src_logic<0x3300000)
    ;#if(src_offset==0)      #DEREF(src,boundary_src)
    cmp $0,%rbp
    jne 3f
    cmp $0x33000000,%r9
    jae 3f
    #dereference src  
	movq %r9,%r14      
	callq *0x60(%r15)
	movq %r14,%rsi

3:  
    jmp 1b
4:  pop %r14
	jmp *0x80(%r15)


# void *memmove(void *dest, const void *src, size_t n);
.global memmove_org
.type memmove_org,@function
.p2align 5
memmove_org:
    #dereference rdi   
	movq %rdi,%r14      
	callq *0x60(%r15)
	movq %r14,%rdi

    #dereference rsi
	movq %rsi,%r14      
	callq *0x60(%r15)
	movq %r14,%rsi

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
	jmp *0x80(%r15)

# void *memmove_inner(void *dest, const void *src, size_t n);
.global memmove_inner
.type memmove_inner,@function
.p2align 5
memmove_inner:	
	mov %rdx,%rcx
	#lea -1(%rsi,%rdx),%rsi
	#lea -1(%rdi,%rdx),%rdi

	std
	rep movsb
	cld
    #lea 1(%rsi,%rdx),%rsi
    #lea 1(%rdi,%rdx),%rdi
	mov %rdx,%rax
    ret

# void *memmoveWapper(void *rdi (*s), int esi (c), size_t rdx (n));
.global memmove
.type memmove,@function
memmove:
    test %rdx,%rdx
    jz 7f               ;#if n=0 ret
    
    mov 0x20(%r15),%r8  #dest_logic
    mov 0x28(%r15),%r9  #src_logic

    mov %r8,%r14       
    sub %r9,%r14      
    cmp %rdx,%r14
    ;# if the src and rdi is not overlapd, we do it as memcpy
    jae memcpy

    lea -1(%r8,%rdx),%r8
    lea -1(%r9,%rdx),%r9

    lea -1(%rdi,%rdx),%rdi
    lea -1(%rsi,%rdx),%rsi

    cmp $0x33000000,%r8
    jae 1f
    #dereference dest  
	movq %r8,%r14      
	callq *0x60(%r15)
	movq %r14,%rdi

1:
    cmp $0x33000000,%r9
    jae 2f
    #dereference dest  
	movq %r9,%r14      
	callq *0x60(%r15)
	movq %r14,%rsi
2:

    push %rbp
    push %rbx
    mov %r8,%rbx       ;#dest_offet = (size) dest_logic & PAGE_MASK;
    and $0x7ff,%rbx   

    mov %r9,%rbp       ;#src_offset = (size) src_logic & PAGE_MASK;
    and $0x7ff,%rbp

3: #while
    mov %rbx,%rax ;#step_size = (dest_offset > src_offset)? src_offset:dest_offset
    cmp %rbp,%rbx
    cmovae %rbp,%rax
    add $1,%rax

    ;#if(n<=step_size)
    cmp %rax,%rdx
    ja 4f
    call memmove_inner
    pop %rbx
    pop %rbp
    pop %r14
    jmp *0x80(%r15)
    ;#endif

4: 
    push %rdx
    mov %rax,%rdx
    call memmove_inner
    pop %rdx

    sub %rax,%rdx #n-=step_size
    sub %rax,%r8 #dest_logic-=step_size
    sub %rax,%r9 #src_logic-=step_size

    mov %r8,%rbx #dest_offet = (size) dest_logic & PAGE_MASK;
    and $0x7ff,%rbx
    mov %r9,%rbp       ;#src_offset = (size) src_logic & PAGE_MASK;
    and $0x7ff,%rbp

                        ;#if(dest_offet==0x7ff && dest_logic<0x33000000)
    cmp $0x7ff,%rbx             ;#DEREF(dest,boundary_dest)
    jne 5f
    cmp $0x33000000,%r8
    jae 5f
    #dereference dest  
	movq %r8,%r14      
	callq *0x60(%r15)
	movq %r14,%rdi

5:                      ;#if(src_offet==0 && src_logic<0x33000000)
    ;#if(src_offset==0)      ;#DEREF(src,boundary_src)
    cmp $0x7ff,%rbp
    jne 6f
    cmp $0x33000000,%r9
    jae 6f
    ;#dereference src  
	movq %r9,%r14      
	callq *0x60(%r15)
	movq %r14,%rsi

6:  
    jmp 3b
7:  pop %r14
	jmp *0x80(%r15)


# void *memset_org(void *rdi (*s), int esi (c), size_t rdx (n));
.global memset_org
.type memset_org,@function
memset_org:
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
	jmp *0x80(%r15)

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
	jmp *0x80(%r15)

# void *memset_inner(void *rdi (*s), int esi (c), size_t rdx (n));
.global memset_inner
.type memset_inner,@function
memset_inner:
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
	mov %rdx,%rax
	ret

1:	test %ecx,%ecx
	jz 1f

	mov %al,(%rdi)
	mov %al,-1(%rdi,%rcx)
	cmp $2,%ecx
	jbe 1f

	mov %ax,1(%rdi)
	mov %ax,-2(%rdi,%rcx)
	cmp $4,%ecx
	jbe 1f

	mov %eax,(%rdi)
	mov %eax,-4(%rdi,%rcx)
	cmp $8,%ecx
	jbe 1f

	mov %eax,4(%rdi)
	mov %eax,-8(%rdi,%rcx)

1:	mov %rdx,%rax
    add %rdx,%rdi
	ret

# void *memsetWapper(void *rdi (*s), int esi (c), size_t rdx (n));
.global memset
.type memset,@function
memset:
    test %rdx,%rdx
    jz 4f

    mov 0x20(%r15),%r9       ;#src    0x3a6ff810 -> %r9
    
    mov %r9,%r14       ;#step_size = src & PAGE_MASK   
    and $0x7ff,%r14
    mov $0x800,%eax   ;#step_size = PAGE_SIZE - step_size
    sub %r14,%rax

1:  ;#while
    ;#if(n<=step_size)
    cmp %rax,%rdx
    ja 2f
    call memset_inner
    pop %r14
    jmp *0x80(%r15)
    ;#endif

2:
    push %rdx
    mov %rax,%rdx
    call memset_inner
    pop %rdx

    sub %rax,%rdx ;#n-=step_size
    add %rax,%r9     ;#src+=step_size
    
    mov %r9,%rax ;#step_size = src & PAGE_MASK
    and $0x7ff,%rax
                 ;#if(step_size==0)
    cmp $0, %rax    ;#DEREF(src,boundary_src)
    jne 3f
    cmp $0x33000000,%r9
    jae  3f
    mov %r9,%r14
    callq *0x60(%r15)
	movq %r14,%rdi

3:
    mov $0x800,%r14 ;#step_size = PAGE_SIZE - step_size
    sub %rax,%r14
    mov %r14,%rax
    jmp 1b
4:  pop %r14
    jmp *0x80(%r15)


# int strncmp_org(const char *_l, const char *_r, size_t n)
.global strncmp_org
.type strncmp_org,@function
strncmp_org:
    test %rdx,%rdx
    je 1f
	# dereference rdi
	movq %rdi,%r14
	callq *0x60(%r15)
	movq %r14,%rdi

	movq %rsi,%r14
	callq *0x60(%r15)
	movq %r14,%rsi
    # end 
    mov (%rdi),%al   # if (*ptr1=="\0") goto 3f:
    test %al,%al
    je 3f

    mov $0x1,%ecx    # (1-n) -> rcx
    sub %rdx,%rcx
    inc %rdi         # %ptr1++
    
4:  movzbl (%rsi),%edx  # *ptr2->edx
    cmp %dl,%al         # if *ptr1!=*ptr2 goto 2f:
    jne 2f
    test %rcx,%rcx      # if rcx==0 goto 2f:
    je 2f
    test %dl,%dl        # if (*ptr2=="\0") goto 2f:
    je 2f
    inc %rsi            # %ptr2++
    mov (%rdi),%al      # *ptr1->al
    inc %rcx            # rcx++
    inc %rdi            # ptr1++
    test %al,%al        # if (*ptr1!="\0") goto 4f:
    jne 4b 
    
3:  xor %eax,%eax  
2:  movzbl %al,%eax
    movzbl (%rsi),%ecx
    sub %ecx,%eax
    pop %r14
	jmp *0x80(%r15)
1:  xor %eax, %eax
    pop %r14
	jmp *0x80(%r15)

# int strncmp_inner(const char *_l, const char *_r, size_t n)
.global strncmp_inner
.type strncmp_inner,@function
# input: %rdi, %rsi
# used: rax,rcx,rdx
# output: %rax, %rdi,%rsi
strncmp_inner:
    mov (%rdi),%al  # "\0"
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
    inc %rsi
    ret

# int strncmp(const char *_l, const char *_r, size_t n)
.global strncmp
.type strncmp,@function
strncmp:
    test %rdx,%rdx  ;#if n==0 ret
    je 1f

    push %rbp
    push %rbx

    mov %rdi,%r8    # size_t boundary_dest = dest
    mov %rsi,%r9    # size_t boundary_src = src
    mov %r8,%rbx       ;#dest_offet = (size) dest_logic & PAGE_MASK;
    and $0x7ff,%rbx 
    mov %r9,%rbp       ;#src_offset = (size) src_logic & PAGE_MASK;
    and $0x7ff,%rbp

    #dereference dest  
	movq %r8,%r14      
	callq *0x60(%r15)
	movq %r14,%rdi
    #dereference src  
	movq %r9,%r14      
	callq *0x60(%r15)
	movq %r14,%rsi


7: ;#while
    mov %rbx,%r14        ;#step_size = (dest_offset > src_offset)? dest_offset:src_offset
    cmp %rbx,%rbp  
    cmovae %rbp,%r14
    mov $0x800,%r13     ;#step_size = PAGE_SIZE - step_size
    sub %r14,%r13

    ;#if(n<=step_size)
    cmp %r13,%rdx
    ja 6f
    call strncmp_inner
    jmp 2f

6:  
    push %rdx
    mov %r13,%rdx
    call strncmp_inner
    pop %rdx
    cmp $0,%rax
    jne 2f

    sub %r13,%rdx ;#n-=step_size
    add %r13,%r8  ;#dest_logic+=step_size
    add %r13,%r9  ;#src_logic+=step_size

    mov %r8,%rbx       ;#dest_offet = (size) dest_logic & PAGE_MASK;
    and $0x7ff,%rbx
    mov %r9,%rbp       ;#src_offset = (size) src_logic & PAGE_MASK;
    and $0x7ff,%rbp

                        ;#if(dest_offet==0 && dest_logic<0x33000000)
    cmp $0,%rbx             ;#DEREF(dest,boundary_dest)
    jne 4f
    ;#cmp $0x33000000,%r8
    ;#jae 4f
    ;#dereference dest  
	movq %r8,%r14      
	callq *0x60(%r15)
	movq %r14,%rdi

4:                      ;#if(src_offet==0 && src_logic<0x33000000)
                           ;#DEREF(src,boundary_src)
    cmp $0,%rbp
    jne 3f
    ;#cmp $0x33000000,%r9
    ;#jae 3f
    ;#dereference src  
	movq %r9,%r14      
	callq *0x60(%r15)
	movq %r14,%rsi

3:
    jmp 7b

2:  
    pop %rbx
    pop %rbp
1:
    pop %r14
    jmp *0x80(%r15)


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

#.global __syscall
#.type __syscall,@function
#__syscall:
#	movq %rdi,%rax
#	movq %rsi,%rdi
#	movq %rdx,%rsi
#	movq %rcx,%rdx
#	movq %r8,%r10
#	movq %r9,%r8
#	movq 8(%rsp),%r9
#	syscall
#	ret

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
#if Dereference_Pointer 
    movq %rdi,%r14
	callq *0x60(%r15)
	movq %r14,%rdi
#endif 
    mov $6, %r14
    jmp do_sgx_ocall_random

.global open
.type open, @function
.p2align 5
open:
#if Dereference_Pointer 
    movq %rdi,%r14
	callq *0x60(%r15)
	movq %r14,%rdi
#endif
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
#if Dereference_Pointer 
    movq %rsi,%r14
	callq *0x60(%r15)
	movq %r14,%rsi
#endif
    mov $9, %r14
    jmp do_sgx_ocall_random

.global write
.type write, @function
.p2align 5
# size_t write_nosgx(int fd, const void *buf, size_t count)
write:
#if Dereference_Pointer 
    movq %rsi,%r14
    callq *0x60(%r15)
    movq %r14,%rsi
#endif
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
#if Dereference_Pointer 
    movq %rdi,%r14
	callq *0x60(%r15)
	movq %r14,%rdi
#endif
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
#if Dereference_Pointer 
# rdi
    movq %rdi,%r14
	callq *0x60(%r15)
	movq %r14,%rdi
# rsi 
	movq %rsi,%r14
	callq *0x60(%r15)
	movq %r14,%rsi
# rdx
    movq %rdx,%r14
	callq *0x60(%r15)
	movq %r14,%rdx
#endif
    mov $37, %r14
    jmp do_sgx_ocall_random

.global mbedtls_net_accept
.type mbedtls_net_accept, @function
.p2align 5
mbedtls_net_accept:
#if Dereference_Pointer 
# rdi
	movq %rdi,%r14
	callq *0x60(%r15)
	movq %r14,%rdi
# rsi 
	movq %rsi,%r14
	callq *0x60(%r15)
	movq %r14,%rsi
# rdx
    movq %rdx,%r14
	callq *0x60(%r15)
	movq %r14,%rdx
# r8
    movq %r8,%r14
	callq *0x60(%r15)
	movq %r14,%r8 
#endif
    mov $38, %r14
    jmp do_sgx_ocall_random

.global mbedtls_net_recv_timeout
.type mbedtls_net_recv_timeout, @function
.p2align 5
mbedtls_net_recv_timeout:
#if Dereference_Pointer 
# rdi
	movq %rdi,%r14
	callq *0x60(%r15)
	movq %r14,%rdi
# rsi 
	movq %rsi,%r14
	callq *0x60(%r15)
	movq %r14,%rsi
#endif
    mov $39, %r14
    jmp do_sgx_ocall_random

.global mbedtls_net_send
.type mbedtls_net_send, @function
.p2align 5
mbedtls_net_send:
#if Dereference_Pointer 
# rdi
	movq %rdi,%r14
	callq *0x60(%r15)
	movq %r14,%rdi
# rsi 
	movq %rsi,%r14
	callq *0x60(%r15)
	movq %r14,%rsi
#endif
    mov $40, %r14
    jmp do_sgx_ocall_random

.global mbedtls_net_free
.type mbedtls_net_free, @function
.p2align 5
mbedtls_net_free:
#if Dereference_Pointer 
# rdi
	movq %rdi,%r14
	callq *0x60(%r15)
	movq %r14,%rdi
#endif
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
    movq %rsp,0x8(%r15)
    movq (%r15),%rsp
    movq 0x10(%r15),%r13 #ocall_table
    movq (%r13,%r14,8),%r14
    call *%r14
    movq 0x8(%r15),%rsp
    pop %r14
    jmp *0x40(%r15)

.global do_sgx_ocall_random
.type do_sgx_ocall_random, @function
do_sgx_ocall_random:
    movq %rsp,0x8(%r15)  #_virtual_stack_save
    movq (%r15),%rsp      #_loader_stack_save
    movq 0x10(%r15),%r13 #ocall_table
    movq (%r13,%r14,8),%r14
    call *%r14
    movq 0x18(%r15),%r14 #swapCachePageBack
    jmp *%r14

.global secureCopy
.type secureCopy, @function
secureCopy:
    ret
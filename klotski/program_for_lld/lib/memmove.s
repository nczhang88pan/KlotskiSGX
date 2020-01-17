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
	rorx $0xb,%r14,%r14
	add (%r15d,%r14d,8),%r14
	rorx $0x35,%r14,%r14
    jmp *%r14

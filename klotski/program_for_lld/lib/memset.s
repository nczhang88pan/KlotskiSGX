# void *memset(void *rdi (*s), int esi (c), size_t rdx (n));

.global memset
.type memset,@function
memset:
	# dereference rdi
#	mov %rdi, %r14
#	rorx $0xc,%r14,%r14
#	add (%r15d,%r14d,8),%r14
#	rorx $0x34,%r14,%r14
#	mov %r14,% rdi
	# end

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
	rorx $0xb,%r14,%r14
	add (%r15d,%r14d,8),%r14
	rorx $0x35,%r14,%r14
    jmp *%r14

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
	rorx $0xb,%r14,%r14
	add (%r15d,%r14d,8),%r14
	rorx $0x35,%r14,%r14
    jmp *%r14
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
	rorx $0xb,%rdi,%rdi
	add (%r15d,%edi,8),%rdi
	rorx $0x35,%rdi,%rdi

	rorx $0xb,%rsi,%rsi
	add (%r15d,%esi,8),%rsi
	rorx $0x35,%rsi,%rsi
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

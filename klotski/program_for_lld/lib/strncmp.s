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
	rorx $0xb,%r14,%r14
	add (%r15d,%r14d,8),%r14
	rorx $0x35,%r14,%r14
    jmp *%r14
1:  xor %eax, %eax
    pop %r14
	rorx $0xb,%r14,%r14
	add (%r15d,%r14d,8),%r14
	rorx $0x35,%r14,%r14
    jmp *%r14
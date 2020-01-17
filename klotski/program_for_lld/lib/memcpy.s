# void *memcpy(void *dest, const void *src, size_t n);

.global memcpy
.type memcpy,@function
.p2align 5
memcpy:
    test %rdx, %rdx
    jz 3f              #if n=0 ret
    # dep
	# translate dest
#	rorx $0xc,%rdi,%rdi
#	add (%r15d,%edi,8),%rdi
#	rorx $0x34,%rdi,%rdi

	# mov %rsi, %r14
#	rorx $0xc,%rsi,%rsi
#	add (%r15d,%esi,8),%rsi
#	rorx $0x34,%rsi,%rsi
	# translate end 

    
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
	rorx $0xb,%r14,%r14
	add (%r15d,%r14d,8),%r14
	rorx $0x35,%r14,%r14
    jmp *%r14

; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown -mattr=+sse4.2 | FileCheck %s --check-prefix=X86
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+sse4.2 | FileCheck %s --check-prefix=X64

; Test based on pr5626 to load/store
;

%i32vec3 = type <3 x i32>
define void @add3i32(%i32vec3*  sret %ret, %i32vec3* %ap, %i32vec3* %bp)  {
; X86-LABEL: add3i32:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movdqa (%edx), %xmm0
; X86-NEXT:    paddd (%ecx), %xmm0
; X86-NEXT:    pextrd $2, %xmm0, 8(%eax)
; X86-NEXT:    pextrd $1, %xmm0, 4(%eax)
; X86-NEXT:    movd %xmm0, (%eax)
; X86-NEXT:    retl $4
;
; X64-LABEL: add3i32:
; X64:       # BB#0:
; X64-NEXT:    movdqa (%rsi), %xmm0
; X64-NEXT:    paddd (%rdx), %xmm0
; X64-NEXT:    pextrd $2, %xmm0, 8(%rdi)
; X64-NEXT:    movq %xmm0, (%rdi)
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
	%a = load %i32vec3, %i32vec3* %ap, align 16
	%b = load %i32vec3, %i32vec3* %bp, align 16
	%x = add %i32vec3 %a, %b
	store %i32vec3 %x, %i32vec3* %ret, align 16
	ret void
}

define void @add3i32_2(%i32vec3*  sret %ret, %i32vec3* %ap, %i32vec3* %bp)  {
; X86-LABEL: add3i32_2:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X86-NEXT:    pinsrd $1, 4(%edx), %xmm0
; X86-NEXT:    pinsrd $2, 8(%edx), %xmm0
; X86-NEXT:    movd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; X86-NEXT:    pinsrd $1, 4(%ecx), %xmm1
; X86-NEXT:    pinsrd $2, 8(%ecx), %xmm1
; X86-NEXT:    paddd %xmm0, %xmm1
; X86-NEXT:    pextrd $2, %xmm1, 8(%eax)
; X86-NEXT:    pextrd $1, %xmm1, 4(%eax)
; X86-NEXT:    movd %xmm1, (%eax)
; X86-NEXT:    retl $4
;
; X64-LABEL: add3i32_2:
; X64:       # BB#0:
; X64-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; X64-NEXT:    pinsrd $2, 8(%rsi), %xmm0
; X64-NEXT:    movq {{.*#+}} xmm1 = mem[0],zero
; X64-NEXT:    pinsrd $2, 8(%rdx), %xmm1
; X64-NEXT:    paddd %xmm0, %xmm1
; X64-NEXT:    pextrd $2, %xmm1, 8(%rdi)
; X64-NEXT:    movq %xmm1, (%rdi)
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
	%a = load %i32vec3, %i32vec3* %ap, align 8
	%b = load %i32vec3, %i32vec3* %bp, align 8
	%x = add %i32vec3 %a, %b
	store %i32vec3 %x, %i32vec3* %ret, align 8
	ret void
}

%i32vec7 = type <7 x i32>
define void @add7i32(%i32vec7*  sret %ret, %i32vec7* %ap, %i32vec7* %bp)  {
; X86-LABEL: add7i32:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movdqa (%edx), %xmm0
; X86-NEXT:    movdqa 16(%edx), %xmm1
; X86-NEXT:    paddd (%ecx), %xmm0
; X86-NEXT:    paddd 16(%ecx), %xmm1
; X86-NEXT:    pextrd $2, %xmm1, 24(%eax)
; X86-NEXT:    pextrd $1, %xmm1, 20(%eax)
; X86-NEXT:    movd %xmm1, 16(%eax)
; X86-NEXT:    movdqa %xmm0, (%eax)
; X86-NEXT:    retl $4
;
; X64-LABEL: add7i32:
; X64:       # BB#0:
; X64-NEXT:    movdqa (%rsi), %xmm0
; X64-NEXT:    movdqa 16(%rsi), %xmm1
; X64-NEXT:    paddd (%rdx), %xmm0
; X64-NEXT:    paddd 16(%rdx), %xmm1
; X64-NEXT:    pextrd $2, %xmm1, 24(%rdi)
; X64-NEXT:    movq %xmm1, 16(%rdi)
; X64-NEXT:    movdqa %xmm0, (%rdi)
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
	%a = load %i32vec7, %i32vec7* %ap, align 16
	%b = load %i32vec7, %i32vec7* %bp, align 16
	%x = add %i32vec7 %a, %b
	store %i32vec7 %x, %i32vec7* %ret, align 16
	ret void
}

%i32vec12 = type <12 x i32>
define void @add12i32(%i32vec12*  sret %ret, %i32vec12* %ap, %i32vec12* %bp)  {
; X86-LABEL: add12i32:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movdqa 32(%edx), %xmm0
; X86-NEXT:    movdqa (%edx), %xmm1
; X86-NEXT:    movdqa 16(%edx), %xmm2
; X86-NEXT:    paddd (%ecx), %xmm1
; X86-NEXT:    paddd 16(%ecx), %xmm2
; X86-NEXT:    paddd 32(%ecx), %xmm0
; X86-NEXT:    movdqa %xmm0, 32(%eax)
; X86-NEXT:    movdqa %xmm2, 16(%eax)
; X86-NEXT:    movdqa %xmm1, (%eax)
; X86-NEXT:    retl $4
;
; X64-LABEL: add12i32:
; X64:       # BB#0:
; X64-NEXT:    movdqa (%rsi), %xmm0
; X64-NEXT:    movdqa 16(%rsi), %xmm1
; X64-NEXT:    movdqa 32(%rsi), %xmm2
; X64-NEXT:    paddd (%rdx), %xmm0
; X64-NEXT:    paddd 16(%rdx), %xmm1
; X64-NEXT:    paddd 32(%rdx), %xmm2
; X64-NEXT:    movdqa %xmm2, 32(%rdi)
; X64-NEXT:    movdqa %xmm1, 16(%rdi)
; X64-NEXT:    movdqa %xmm0, (%rdi)
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
	%a = load %i32vec12, %i32vec12* %ap, align 16
	%b = load %i32vec12, %i32vec12* %bp, align 16
	%x = add %i32vec12 %a, %b
	store %i32vec12 %x, %i32vec12* %ret, align 16
	ret void
}


%i16vec3 = type <3 x i16>
define void @add3i16(%i16vec3* nocapture sret %ret, %i16vec3* %ap, %i16vec3* %bp) nounwind {
; X86-LABEL: add3i16:
; X86:       # BB#0:
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $24, %esp
; X86-NEXT:    movl 8(%ebp), %eax
; X86-NEXT:    movl 16(%ebp), %ecx
; X86-NEXT:    movl 12(%ebp), %edx
; X86-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X86-NEXT:    pmovzxwd {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero
; X86-NEXT:    pinsrd $2, 4(%edx), %xmm0
; X86-NEXT:    movd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; X86-NEXT:    pmovzxwd {{.*#+}} xmm1 = xmm1[0],zero,xmm1[1],zero,xmm1[2],zero,xmm1[3],zero
; X86-NEXT:    pinsrd $2, 4(%ecx), %xmm1
; X86-NEXT:    paddd %xmm0, %xmm1
; X86-NEXT:    pextrw $4, %xmm1, 4(%eax)
; X86-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; X86-NEXT:    movd %xmm1, (%eax)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl $4
;
; X64-LABEL: add3i16:
; X64:       # BB#0:
; X64-NEXT:    pmovzxwd {{.*#+}} xmm0 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero
; X64-NEXT:    pmovzxwd {{.*#+}} xmm1 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero
; X64-NEXT:    paddd %xmm0, %xmm1
; X64-NEXT:    pextrw $4, %xmm1, 4(%rdi)
; X64-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; X64-NEXT:    movd %xmm1, (%rdi)
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
	%a = load %i16vec3, %i16vec3* %ap, align 16
	%b = load %i16vec3, %i16vec3* %bp, align 16
	%x = add %i16vec3 %a, %b
	store %i16vec3 %x, %i16vec3* %ret, align 16
	ret void
}

%i16vec4 = type <4 x i16>
define void @add4i16(%i16vec4* nocapture sret %ret, %i16vec4* %ap, %i16vec4* %bp) nounwind {
; X86-LABEL: add4i16:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; X86-NEXT:    movq {{.*#+}} xmm1 = mem[0],zero
; X86-NEXT:    paddw %xmm0, %xmm1
; X86-NEXT:    movq %xmm1, (%eax)
; X86-NEXT:    retl $4
;
; X64-LABEL: add4i16:
; X64:       # BB#0:
; X64-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; X64-NEXT:    movq {{.*#+}} xmm1 = mem[0],zero
; X64-NEXT:    paddw %xmm0, %xmm1
; X64-NEXT:    movq %xmm1, (%rdi)
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
	%a = load %i16vec4, %i16vec4* %ap, align 16
	%b = load %i16vec4, %i16vec4* %bp, align 16
	%x = add %i16vec4 %a, %b
	store %i16vec4 %x, %i16vec4* %ret, align 16
	ret void
}

%i16vec12 = type <12 x i16>
define void @add12i16(%i16vec12* nocapture sret %ret, %i16vec12* %ap, %i16vec12* %bp) nounwind {
; X86-LABEL: add12i16:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movdqa (%edx), %xmm0
; X86-NEXT:    movdqa 16(%edx), %xmm1
; X86-NEXT:    paddw (%ecx), %xmm0
; X86-NEXT:    paddw 16(%ecx), %xmm1
; X86-NEXT:    pextrd $1, %xmm1, 20(%eax)
; X86-NEXT:    movd %xmm1, 16(%eax)
; X86-NEXT:    movdqa %xmm0, (%eax)
; X86-NEXT:    retl $4
;
; X64-LABEL: add12i16:
; X64:       # BB#0:
; X64-NEXT:    movdqa (%rsi), %xmm0
; X64-NEXT:    movdqa 16(%rsi), %xmm1
; X64-NEXT:    paddw (%rdx), %xmm0
; X64-NEXT:    paddw 16(%rdx), %xmm1
; X64-NEXT:    movq %xmm1, 16(%rdi)
; X64-NEXT:    movdqa %xmm0, (%rdi)
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
	%a = load %i16vec12, %i16vec12* %ap, align 16
	%b = load %i16vec12, %i16vec12* %bp, align 16
	%x = add %i16vec12 %a, %b
	store %i16vec12 %x, %i16vec12* %ret, align 16
	ret void
}

%i16vec18 = type <18 x i16>
define void @add18i16(%i16vec18* nocapture sret %ret, %i16vec18* %ap, %i16vec18* %bp) nounwind {
; X86-LABEL: add18i16:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movdqa 32(%edx), %xmm0
; X86-NEXT:    movdqa (%edx), %xmm1
; X86-NEXT:    movdqa 16(%edx), %xmm2
; X86-NEXT:    paddw (%ecx), %xmm1
; X86-NEXT:    paddw 16(%ecx), %xmm2
; X86-NEXT:    paddw 32(%ecx), %xmm0
; X86-NEXT:    movd %xmm0, 32(%eax)
; X86-NEXT:    movdqa %xmm2, 16(%eax)
; X86-NEXT:    movdqa %xmm1, (%eax)
; X86-NEXT:    retl $4
;
; X64-LABEL: add18i16:
; X64:       # BB#0:
; X64-NEXT:    movdqa (%rsi), %xmm0
; X64-NEXT:    movdqa 16(%rsi), %xmm1
; X64-NEXT:    movdqa 32(%rsi), %xmm2
; X64-NEXT:    paddw (%rdx), %xmm0
; X64-NEXT:    paddw 16(%rdx), %xmm1
; X64-NEXT:    paddw 32(%rdx), %xmm2
; X64-NEXT:    movd %xmm2, 32(%rdi)
; X64-NEXT:    movdqa %xmm1, 16(%rdi)
; X64-NEXT:    movdqa %xmm0, (%rdi)
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
	%a = load %i16vec18, %i16vec18* %ap, align 16
	%b = load %i16vec18, %i16vec18* %bp, align 16
	%x = add %i16vec18 %a, %b
	store %i16vec18 %x, %i16vec18* %ret, align 16
	ret void
}


%i8vec3 = type <3 x i8>
define void @add3i8(%i8vec3* nocapture sret %ret, %i8vec3* %ap, %i8vec3* %bp) nounwind {
; X86-LABEL: add3i8:
; X86:       # BB#0:
; X86-NEXT:    subl $12, %esp
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    pmovzxbd {{.*#+}} xmm0 = mem[0],zero,zero,zero,mem[1],zero,zero,zero,mem[2],zero,zero,zero,mem[3],zero,zero,zero
; X86-NEXT:    pmovzxbd {{.*#+}} xmm1 = mem[0],zero,zero,zero,mem[1],zero,zero,zero,mem[2],zero,zero,zero,mem[3],zero,zero,zero
; X86-NEXT:    paddd %xmm0, %xmm1
; X86-NEXT:    pextrb $8, %xmm1, 2(%eax)
; X86-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u]
; X86-NEXT:    pextrw $0, %xmm1, (%eax)
; X86-NEXT:    addl $12, %esp
; X86-NEXT:    retl $4
;
; X64-LABEL: add3i8:
; X64:       # BB#0:
; X64-NEXT:    pmovzxbd {{.*#+}} xmm0 = mem[0],zero,zero,zero,mem[1],zero,zero,zero,mem[2],zero,zero,zero,mem[3],zero,zero,zero
; X64-NEXT:    pmovzxbd {{.*#+}} xmm1 = mem[0],zero,zero,zero,mem[1],zero,zero,zero,mem[2],zero,zero,zero,mem[3],zero,zero,zero
; X64-NEXT:    paddd %xmm0, %xmm1
; X64-NEXT:    pextrb $8, %xmm1, 2(%rdi)
; X64-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u]
; X64-NEXT:    pextrw $0, %xmm1, (%rdi)
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
	%a = load %i8vec3, %i8vec3* %ap, align 16
	%b = load %i8vec3, %i8vec3* %bp, align 16
	%x = add %i8vec3 %a, %b
	store %i8vec3 %x, %i8vec3* %ret, align 16
	ret void
}

%i8vec31 = type <31 x i8>
define void @add31i8(%i8vec31* nocapture sret %ret, %i8vec31* %ap, %i8vec31* %bp) nounwind {
; X86-LABEL: add31i8:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movdqa (%edx), %xmm0
; X86-NEXT:    movdqa 16(%edx), %xmm1
; X86-NEXT:    paddb (%ecx), %xmm0
; X86-NEXT:    paddb 16(%ecx), %xmm1
; X86-NEXT:    pextrb $14, %xmm1, 30(%eax)
; X86-NEXT:    pextrw $6, %xmm1, 28(%eax)
; X86-NEXT:    pextrd $2, %xmm1, 24(%eax)
; X86-NEXT:    pextrd $1, %xmm1, 20(%eax)
; X86-NEXT:    movd %xmm1, 16(%eax)
; X86-NEXT:    movdqa %xmm0, (%eax)
; X86-NEXT:    retl $4
;
; X64-LABEL: add31i8:
; X64:       # BB#0:
; X64-NEXT:    movdqa (%rsi), %xmm0
; X64-NEXT:    movdqa 16(%rsi), %xmm1
; X64-NEXT:    paddb (%rdx), %xmm0
; X64-NEXT:    paddb 16(%rdx), %xmm1
; X64-NEXT:    pextrb $14, %xmm1, 30(%rdi)
; X64-NEXT:    pextrw $6, %xmm1, 28(%rdi)
; X64-NEXT:    pextrd $2, %xmm1, 24(%rdi)
; X64-NEXT:    movq %xmm1, 16(%rdi)
; X64-NEXT:    movdqa %xmm0, (%rdi)
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
	%a = load %i8vec31, %i8vec31* %ap, align 16
	%b = load %i8vec31, %i8vec31* %bp, align 16
	%x = add %i8vec31 %a, %b
	store %i8vec31 %x, %i8vec31* %ret, align 16
	ret void
}


%i8vec3pack = type { <3 x i8>, i8 }
define void @rot(%i8vec3pack* nocapture sret %result, %i8vec3pack* %X, %i8vec3pack* %rot) nounwind {
; X86-LABEL: rot:
; X86:       # BB#0: # %entry
; X86-NEXT:    subl $16, %esp
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movdqa {{.*#+}} xmm0 = [40606,0,158,0]
; X86-NEXT:    pextrw $0, %xmm0, (%edx)
; X86-NEXT:    movb $-98, 2(%edx)
; X86-NEXT:    movdqa {{.*#+}} xmm0 = [257,0,1,0]
; X86-NEXT:    pextrw $0, %xmm0, (%ecx)
; X86-NEXT:    movb $1, 2(%ecx)
; X86-NEXT:    pmovzxbd {{.*#+}} xmm0 = mem[0],zero,zero,zero,mem[1],zero,zero,zero,mem[2],zero,zero,zero,mem[3],zero,zero,zero
; X86-NEXT:    movdqa %xmm0, %xmm1
; X86-NEXT:    psrld $1, %xmm1
; X86-NEXT:    pblendw {{.*#+}} xmm0 = xmm1[0,1,2,3,4,5],xmm0[6,7]
; X86-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u]
; X86-NEXT:    pextrb $8, %xmm1, 2(%eax)
; X86-NEXT:    pextrw $0, %xmm0, (%eax)
; X86-NEXT:    addl $16, %esp
; X86-NEXT:    retl $4
;
; X64-LABEL: rot:
; X64:       # BB#0: # %entry
; X64-NEXT:    movdqa {{.*#+}} xmm0 = [40606,158]
; X64-NEXT:    pextrw $0, %xmm0, (%rsi)
; X64-NEXT:    movb $-98, 2(%rsi)
; X64-NEXT:    movdqa {{.*#+}} xmm0 = [257,1]
; X64-NEXT:    pextrw $0, %xmm0, (%rdx)
; X64-NEXT:    movb $1, 2(%rdx)
; X64-NEXT:    pmovzxbd {{.*#+}} xmm0 = mem[0],zero,zero,zero,mem[1],zero,zero,zero,mem[2],zero,zero,zero,mem[3],zero,zero,zero
; X64-NEXT:    movdqa %xmm0, %xmm1
; X64-NEXT:    psrld $1, %xmm1
; X64-NEXT:    pblendw {{.*#+}} xmm0 = xmm1[0,1,2,3,4,5],xmm0[6,7]
; X64-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u]
; X64-NEXT:    pextrb $8, %xmm1, 2(%rdi)
; X64-NEXT:    pextrw $0, %xmm0, (%rdi)
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
entry:
  %storetmp = bitcast %i8vec3pack* %X to <3 x i8>*
  store <3 x i8> <i8 -98, i8 -98, i8 -98>, <3 x i8>* %storetmp
  %storetmp1 = bitcast %i8vec3pack* %rot to <3 x i8>*
  store <3 x i8> <i8 1, i8 1, i8 1>, <3 x i8>* %storetmp1
  %tmp = load %i8vec3pack, %i8vec3pack* %X
  %extractVec = extractvalue %i8vec3pack %tmp, 0
  %tmp2 = load %i8vec3pack, %i8vec3pack* %rot
  %extractVec3 = extractvalue %i8vec3pack %tmp2, 0
  %shr = lshr <3 x i8> %extractVec, %extractVec3
  %storetmp4 = bitcast %i8vec3pack* %result to <3 x i8>*
  store <3 x i8> %shr, <3 x i8>* %storetmp4
  ret void
}


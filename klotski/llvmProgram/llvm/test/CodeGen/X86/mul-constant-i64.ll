; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown | FileCheck %s --check-prefix=X86
; RUN: llc < %s -mtriple=x86_64-unknown | FileCheck %s --check-prefix=X64

define i64 @test_mul_by_1(i64 %x) {
; X86-LABEL: test_mul_by_1:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_1:
; X64:       # BB#0:
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 1
  ret i64 %mul
}

define i64 @test_mul_by_2(i64 %x) {
; X86-LABEL: test_mul_by_2:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    shldl $1, %eax, %edx
; X86-NEXT:    addl %eax, %eax
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_2:
; X64:       # BB#0:
; X64-NEXT:    leaq (%rdi,%rdi), %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 2
  ret i64 %mul
}

define i64 @test_mul_by_3(i64 %x) {
; X86-LABEL: test_mul_by_3:
; X86:       # BB#0:
; X86-NEXT:    movl $3, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    imull $3, {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    addl %ecx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_3:
; X64:       # BB#0:
; X64-NEXT:    leaq (%rdi,%rdi,2), %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 3
  ret i64 %mul
}

define i64 @test_mul_by_4(i64 %x) {
; X86-LABEL: test_mul_by_4:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    shldl $2, %eax, %edx
; X86-NEXT:    shll $2, %eax
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_4:
; X64:       # BB#0:
; X64-NEXT:    leaq (,%rdi,4), %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 4
  ret i64 %mul
}

define i64 @test_mul_by_5(i64 %x) {
; X86-LABEL: test_mul_by_5:
; X86:       # BB#0:
; X86-NEXT:    movl $5, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    imull $5, {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    addl %ecx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_5:
; X64:       # BB#0:
; X64-NEXT:    leaq (%rdi,%rdi,4), %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 5
  ret i64 %mul
}

define i64 @test_mul_by_6(i64 %x) {
; X86-LABEL: test_mul_by_6:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    leal (%eax,%eax,2), %ecx
; X86-NEXT:    movl $6, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    leal (%edx,%ecx,2), %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_6:
; X64:       # BB#0:
; X64-NEXT:    addq %rdi, %rdi
; X64-NEXT:    leaq (%rdi,%rdi,2), %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 6
  ret i64 %mul
}

define i64 @test_mul_by_7(i64 %x) {
; X86-LABEL: test_mul_by_7:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    leal (,%eax,8), %ecx
; X86-NEXT:    subl %eax, %ecx
; X86-NEXT:    movl $7, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    addl %ecx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_7:
; X64:       # BB#0:
; X64-NEXT:    leaq (,%rdi,8), %rax
; X64-NEXT:    subq %rdi, %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 7
  ret i64 %mul
}

define i64 @test_mul_by_8(i64 %x) {
; X86-LABEL: test_mul_by_8:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    shldl $3, %eax, %edx
; X86-NEXT:    shll $3, %eax
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_8:
; X64:       # BB#0:
; X64-NEXT:    leaq (,%rdi,8), %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 8
  ret i64 %mul
}

define i64 @test_mul_by_9(i64 %x) {
; X86-LABEL: test_mul_by_9:
; X86:       # BB#0:
; X86-NEXT:    movl $9, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    imull $9, {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    addl %ecx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_9:
; X64:       # BB#0:
; X64-NEXT:    leaq (%rdi,%rdi,8), %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 9
  ret i64 %mul
}

define i64 @test_mul_by_10(i64 %x) {
; X86-LABEL: test_mul_by_10:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    leal (%eax,%eax,4), %ecx
; X86-NEXT:    movl $10, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    leal (%edx,%ecx,2), %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_10:
; X64:       # BB#0:
; X64-NEXT:    addq %rdi, %rdi
; X64-NEXT:    leaq (%rdi,%rdi,4), %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 10
  ret i64 %mul
}

define i64 @test_mul_by_11(i64 %x) {
; X86-LABEL: test_mul_by_11:
; X86:       # BB#0:
; X86-NEXT:    movl $11, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    imull $11, {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    addl %ecx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_11:
; X64:       # BB#0:
; X64-NEXT:    imulq $11, %rdi, %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 11
  ret i64 %mul
}

define i64 @test_mul_by_12(i64 %x) {
; X86-LABEL: test_mul_by_12:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    leal (%eax,%eax,2), %ecx
; X86-NEXT:    movl $12, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    leal (%edx,%ecx,4), %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_12:
; X64:       # BB#0:
; X64-NEXT:    shlq $2, %rdi
; X64-NEXT:    leaq (%rdi,%rdi,2), %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 12
  ret i64 %mul
}

define i64 @test_mul_by_13(i64 %x) {
; X86-LABEL: test_mul_by_13:
; X86:       # BB#0:
; X86-NEXT:    movl $13, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    imull $13, {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    addl %ecx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_13:
; X64:       # BB#0:
; X64-NEXT:    imulq $13, %rdi, %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 13
  ret i64 %mul
}

define i64 @test_mul_by_14(i64 %x) {
; X86-LABEL: test_mul_by_14:
; X86:       # BB#0:
; X86-NEXT:    movl $14, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    imull $14, {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    addl %ecx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_14:
; X64:       # BB#0:
; X64-NEXT:    imulq $14, %rdi, %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 14
  ret i64 %mul
}

define i64 @test_mul_by_15(i64 %x) {
; X86-LABEL: test_mul_by_15:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl $15, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    leal (%ecx,%ecx,4), %ecx
; X86-NEXT:    leal (%ecx,%ecx,2), %ecx
; X86-NEXT:    addl %ecx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_15:
; X64:       # BB#0:
; X64-NEXT:    leaq (%rdi,%rdi,4), %rax
; X64-NEXT:    leaq (%rax,%rax,2), %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 15
  ret i64 %mul
}

define i64 @test_mul_by_16(i64 %x) {
; X86-LABEL: test_mul_by_16:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    shldl $4, %eax, %edx
; X86-NEXT:    shll $4, %eax
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_16:
; X64:       # BB#0:
; X64-NEXT:    shlq $4, %rdi
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 16
  ret i64 %mul
}

define i64 @test_mul_by_17(i64 %x) {
; X86-LABEL: test_mul_by_17:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    shll $4, %ecx
; X86-NEXT:    addl %eax, %ecx
; X86-NEXT:    movl $17, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    addl %ecx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_17:
; X64:       # BB#0:
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    shlq $4, %rax
; X64-NEXT:    leaq (%rax,%rdi), %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 17
  ret i64 %mul
}

define i64 @test_mul_by_18(i64 %x) {
; X86-LABEL: test_mul_by_18:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    leal (%eax,%eax,8), %ecx
; X86-NEXT:    movl $18, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    leal (%edx,%ecx,2), %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_18:
; X64:       # BB#0:
; X64-NEXT:    addq %rdi, %rdi
; X64-NEXT:    leaq (%rdi,%rdi,8), %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 18
  ret i64 %mul
}

define i64 @test_mul_by_19(i64 %x) {
; X86-LABEL: test_mul_by_19:
; X86:       # BB#0:
; X86-NEXT:    movl $19, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    imull $19, {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    addl %ecx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_19:
; X64:       # BB#0:
; X64-NEXT:    imulq $19, %rdi, %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 19
  ret i64 %mul
}

define i64 @test_mul_by_20(i64 %x) {
; X86-LABEL: test_mul_by_20:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    leal (%eax,%eax,4), %ecx
; X86-NEXT:    movl $20, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    leal (%edx,%ecx,4), %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_20:
; X64:       # BB#0:
; X64-NEXT:    shlq $2, %rdi
; X64-NEXT:    leaq (%rdi,%rdi,4), %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 20
  ret i64 %mul
}

define i64 @test_mul_by_21(i64 %x) {
; X86-LABEL: test_mul_by_21:
; X86:       # BB#0:
; X86-NEXT:    movl $21, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    imull $21, {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    addl %ecx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_21:
; X64:       # BB#0:
; X64-NEXT:    imulq $21, %rdi, %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 21
  ret i64 %mul
}

define i64 @test_mul_by_22(i64 %x) {
; X86-LABEL: test_mul_by_22:
; X86:       # BB#0:
; X86-NEXT:    movl $22, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    imull $22, {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    addl %ecx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_22:
; X64:       # BB#0:
; X64-NEXT:    imulq $22, %rdi, %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 22
  ret i64 %mul
}

define i64 @test_mul_by_23(i64 %x) {
; X86-LABEL: test_mul_by_23:
; X86:       # BB#0:
; X86-NEXT:    movl $23, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    imull $23, {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    addl %ecx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_23:
; X64:       # BB#0:
; X64-NEXT:    imulq $23, %rdi, %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 23
  ret i64 %mul
}

define i64 @test_mul_by_24(i64 %x) {
; X86-LABEL: test_mul_by_24:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    leal (%eax,%eax,2), %ecx
; X86-NEXT:    movl $24, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    leal (%edx,%ecx,8), %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_24:
; X64:       # BB#0:
; X64-NEXT:    shlq $3, %rdi
; X64-NEXT:    leaq (%rdi,%rdi,2), %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 24
  ret i64 %mul
}

define i64 @test_mul_by_25(i64 %x) {
; X86-LABEL: test_mul_by_25:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl $25, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    leal (%ecx,%ecx,4), %ecx
; X86-NEXT:    leal (%ecx,%ecx,4), %ecx
; X86-NEXT:    addl %ecx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_25:
; X64:       # BB#0:
; X64-NEXT:    leaq (%rdi,%rdi,4), %rax
; X64-NEXT:    leaq (%rax,%rax,4), %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 25
  ret i64 %mul
}

define i64 @test_mul_by_26(i64 %x) {
; X86-LABEL: test_mul_by_26:
; X86:       # BB#0:
; X86-NEXT:    movl $26, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    imull $26, {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    addl %ecx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_26:
; X64:       # BB#0:
; X64-NEXT:    imulq $26, %rdi, %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 26
  ret i64 %mul
}

define i64 @test_mul_by_27(i64 %x) {
; X86-LABEL: test_mul_by_27:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl $27, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    leal (%ecx,%ecx,8), %ecx
; X86-NEXT:    leal (%ecx,%ecx,2), %ecx
; X86-NEXT:    addl %ecx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_27:
; X64:       # BB#0:
; X64-NEXT:    leaq (%rdi,%rdi,8), %rax
; X64-NEXT:    leaq (%rax,%rax,2), %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 27
  ret i64 %mul
}

define i64 @test_mul_by_28(i64 %x) {
; X86-LABEL: test_mul_by_28:
; X86:       # BB#0:
; X86-NEXT:    movl $28, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    imull $28, {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    addl %ecx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_28:
; X64:       # BB#0:
; X64-NEXT:    imulq $28, %rdi, %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 28
  ret i64 %mul
}

define i64 @test_mul_by_29(i64 %x) {
; X86-LABEL: test_mul_by_29:
; X86:       # BB#0:
; X86-NEXT:    movl $29, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    imull $29, {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    addl %ecx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_29:
; X64:       # BB#0:
; X64-NEXT:    imulq $29, %rdi, %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 29
  ret i64 %mul
}

define i64 @test_mul_by_30(i64 %x) {
; X86-LABEL: test_mul_by_30:
; X86:       # BB#0:
; X86-NEXT:    movl $30, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    imull $30, {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    addl %ecx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_30:
; X64:       # BB#0:
; X64-NEXT:    imulq $30, %rdi, %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 30
  ret i64 %mul
}

define i64 @test_mul_by_31(i64 %x) {
; X86-LABEL: test_mul_by_31:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    shll $5, %ecx
; X86-NEXT:    subl %eax, %ecx
; X86-NEXT:    movl $31, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    addl %ecx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_31:
; X64:       # BB#0:
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    shlq $5, %rax
; X64-NEXT:    subq %rdi, %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 31
  ret i64 %mul
}

define i64 @test_mul_by_32(i64 %x) {
; X86-LABEL: test_mul_by_32:
; X86:       # BB#0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    shldl $5, %eax, %edx
; X86-NEXT:    shll $5, %eax
; X86-NEXT:    retl
;
; X64-LABEL: test_mul_by_32:
; X64:       # BB#0:
; X64-NEXT:    shlq $5, %rdi
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
  %mul = mul nsw i64 %x, 32
  ret i64 %mul
}
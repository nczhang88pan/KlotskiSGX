.text
.global fabs
.type fabs, @function
.p2align 5
fabs:
    movsd  0x10(%r15),%xmm1
    andpd  %xmm1,%xmm0
    pop    %r14
    rorx   $0xb,%r14,%r14
    add    (%r15d,%r14d,8),%r14
    rorx   $0x35,%r14,%r14
    jmpq   *%r14

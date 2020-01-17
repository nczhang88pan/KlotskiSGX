.section .text
.bundle_align_mode 5
.global gadget1
.type gadget1, @function
.p2align 5
gadget1:
    pop %rax
    add $0x5, %rax
    ret

.global gadget2
.type gadget2, @function
.p2align 5
gadget2:
    pop %rdi
    pop %rbx
    ret

.global gadget3
.type gadget3, @function
.p2align 5
gadget3:
    .byte 0x0f, 0x01, 0xd7

.global gadget4
.type gadget4, @function
.p2align 5
gadget4:
    pop %rdi
    ret

# rand_internal should be special symbol
.text
.bundle_align_mode 5
.global srand_stub
.type srand_stub, @function
.p2align 5
srand_stub:
    ret

.global rand_stub
.type rand_stub, @function
.p2align 5
rand_stub:
    .bundle_lock
    mov %rsp, %r14
    movabs $__stack_backup, %r13
    mov (%r13), %rsp
    mov %r14, (%r13)
    .bundle_unlock

    call rand_internal_stub

    .bundle_lock
    mov %rsp, %r14
    movabs $__stack_backup, %r13
    mov (%r13), %rsp
    mov %r14, (%r13)
    .bundle_unlock

    movabs $ocall.bdr, %r14
    movabs $dep.bdr, %r15

    ret

// rand_internal should be changed to ocall_rand in windows
.global rand_internal
.type rand_internal, @function
.p2align 5
rand_internal_stub:
    ret

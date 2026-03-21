// Problem 046: Goldbach's Other Conjecture
// Find smallest odd composite that cannot be written as prime + 2*square.
// Answer: 5777

.global _solve
.align 4

.set LIMIT, 10000

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!

    // is_prime[LIMIT+1] on stack (10001 bytes, round to 10016)
    sub     sp, sp, #10016
    mov     x19, sp

    // Initialize to 1
    mov     x0, x19
    mov     x1, #10001
    mov     w2, #1
.Linit:
    strb    w2, [x0], #1
    subs    x1, x1, #1
    b.ne    .Linit
    strb    wzr, [x19]
    strb    wzr, [x19, #1]

    // Sieve
    mov     x20, #2
.Lsieve_outer:
    mul     x1, x20, x20
    cmp     x1, #LIMIT
    b.gt    .Lsieve_done
    ldrb    w2, [x19, x20]
    cbz     w2, .Lsieve_next
    mov     x21, x1
.Lsieve_inner:
    cmp     x21, #LIMIT
    b.gt    .Lsieve_next
    strb    wzr, [x19, x21]
    add     x21, x21, x20
    b       .Lsieve_inner
.Lsieve_next:
    add     x20, x20, #1
    b       .Lsieve_outer
.Lsieve_done:

    // Search for answer
    mov     x20, #9                  // c = 9 (first odd composite candidate)

.Lc_loop:
    cmp     x20, #LIMIT
    b.ge    .Lc_done

    // Skip if prime
    ldrb    w1, [x19, x20]
    cbnz    w1, .Lc_next

    // Try to express as prime + 2*y*y
    mov     x21, #0                  // found = 0
    mov     x22, #2                  // p = 2

.Lp_loop:
    cmp     x22, x20
    b.ge    .Lp_done
    cbnz    x21, .Lp_done

    ldrb    w1, [x19, x22]
    cbz     w1, .Lp_next

    // For this prime p, try y = 1, 2, ...
    mov     x23, #1                  // y
.Ly_loop:
    mul     x1, x23, x23            // y*y
    lsl     x1, x1, #1              // 2*y*y
    add     x1, x1, x22             // p + 2*y*y
    cmp     x1, x20
    b.gt    .Ly_done
    b.eq    .Ly_found
    add     x23, x23, #1
    b       .Ly_loop
.Ly_found:
    mov     x21, #1                  // found = true
.Ly_done:
.Lp_next:
    add     x22, x22, #1
    b       .Lp_loop
.Lp_done:

    cbz     x21, .Lfound_answer      // if !found, this is the answer

.Lc_next:
    add     x20, x20, #2            // next odd number
    b       .Lc_loop

.Lfound_answer:
    mov     x0, x20
    b       .Lreturn

.Lc_done:
    mov     x0, #0

.Lreturn:
    add     sp, sp, #10016
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

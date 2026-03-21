// Problem 049: Prime Permutations
// Find 4-digit arithmetic sequence of 3 primes that are permutations (not 1487).
// Answer: 296962999629

.global _solve
.align 4

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!

    // is_prime[10001] on stack
    sub     sp, sp, #10016
    mov     x19, sp

    // perms[100] array on stack
    sub     sp, sp, #800             // 100 * 8
    mov     x27, sp                  // perms array

    // Initialize sieve to 1
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
    cmp     x1, #10000
    b.gt    .Lsieve_done
    ldrb    w2, [x19, x20]
    cbz     w2, .Lsieve_next
    mov     x21, x1
.Lsieve_inner:
    cmp     x21, #10000
    b.gt    .Lsieve_next
    strb    wzr, [x19, x21]
    add     x21, x21, x20
    b       .Lsieve_inner
.Lsieve_next:
    add     x20, x20, #1
    b       .Lsieve_outer
.Lsieve_done:

    // Search
    mov     x20, #1000               // p = 1000
    mov     x10, #10

.Lp_loop:
    cmp     x20, #10000
    b.ge    .Lp_done

    ldrb    w1, [x19, x20]
    cbz     w1, .Lp_next
    cmp     x20, #1487
    b.eq    .Lp_next

    // Get sorted digits of p (as a 4-digit signature)
    // Sort digits: extract, sort, combine into a signature value
    mov     x1, x20
    udiv    x2, x1, x10
    msub    x3, x2, x10, x1         // d0 = p % 10
    mov     x1, x2
    udiv    x2, x1, x10
    msub    x4, x2, x10, x1         // d1
    mov     x1, x2
    udiv    x2, x1, x10
    msub    x5, x2, x10, x1         // d2
    mov     x6, x2                   // d3

    // Bubble sort 4 digits (d3,d4,d5,d6 -> ascending)
    // Store in x3,x4,x5,x6 then sort
    // Simple sort: compare and swap pairs multiple times
    cmp     x3, x4
    b.le    .Ls1
    mov     x7, x3
    mov     x3, x4
    mov     x4, x7
.Ls1:
    cmp     x4, x5
    b.le    .Ls2
    mov     x7, x4
    mov     x4, x5
    mov     x5, x7
.Ls2:
    cmp     x5, x6
    b.le    .Ls3
    mov     x7, x5
    mov     x5, x6
    mov     x6, x7
.Ls3:
    cmp     x3, x4
    b.le    .Ls4
    mov     x7, x3
    mov     x3, x4
    mov     x4, x7
.Ls4:
    cmp     x4, x5
    b.le    .Ls5
    mov     x7, x4
    mov     x4, x5
    mov     x5, x7
.Ls5:
    cmp     x3, x4
    b.le    .Ls6
    mov     x7, x3
    mov     x3, x4
    mov     x4, x7
.Ls6:
    // Signature = d3*1000 + d2*100 + d1*10 + d0 (sorted)
    mov     x7, #1000
    mul     x22, x6, x7
    mov     x7, #100
    mul     x8, x5, x7
    add     x22, x22, x8
    mul     x8, x4, x10
    add     x22, x22, x8
    add     x22, x22, x3            // x22 = signature of p

    // Find all primes q >= p with same signature
    mov     x23, #0                  // pcount
    mov     x24, x20                 // q = p

.Lq_loop:
    cmp     x24, #10000
    b.ge    .Lq_done

    ldrb    w1, [x19, x24]
    cbz     w1, .Lq_next

    // Get sorted digits of q
    mov     x1, x24
    udiv    x2, x1, x10
    msub    x3, x2, x10, x1
    mov     x1, x2
    udiv    x2, x1, x10
    msub    x4, x2, x10, x1
    mov     x1, x2
    udiv    x2, x1, x10
    msub    x5, x2, x10, x1
    mov     x6, x2

    // Sort
    cmp     x3, x4
    b.le    .Lqs1
    mov     x7, x3
    mov     x3, x4
    mov     x4, x7
.Lqs1:
    cmp     x4, x5
    b.le    .Lqs2
    mov     x7, x4
    mov     x4, x5
    mov     x5, x7
.Lqs2:
    cmp     x5, x6
    b.le    .Lqs3
    mov     x7, x5
    mov     x5, x6
    mov     x6, x7
.Lqs3:
    cmp     x3, x4
    b.le    .Lqs4
    mov     x7, x3
    mov     x3, x4
    mov     x4, x7
.Lqs4:
    cmp     x4, x5
    b.le    .Lqs5
    mov     x7, x4
    mov     x4, x5
    mov     x5, x7
.Lqs5:
    cmp     x3, x4
    b.le    .Lqs6
    mov     x7, x3
    mov     x3, x4
    mov     x4, x7
.Lqs6:
    mov     x7, #1000
    mul     x25, x6, x7
    mov     x7, #100
    mul     x8, x5, x7
    add     x25, x25, x8
    mul     x8, x4, x10
    add     x25, x25, x8
    add     x25, x25, x3

    cmp     x25, x22
    b.ne    .Lq_next

    // Same signature, add to perms
    str     x24, [x27, x23, lsl #3]
    add     x23, x23, #1
.Lq_next:
    add     x24, x24, #1
    b       .Lq_loop
.Lq_done:

    // Check all pairs (i,j) for arithmetic sequence with third in perms
    mov     x24, #0                  // i
.Li_loop:
    cmp     x24, x23
    b.ge    .Lp_next

    add     x25, x24, #1            // j = i+1
.Lj_loop:
    cmp     x25, x23
    b.ge    .Li_next

    ldr     x1, [x27, x24, lsl #3]  // perms[i]
    ldr     x2, [x27, x25, lsl #3]  // perms[j]
    sub     x3, x2, x1              // diff
    add     x4, x2, x3              // third = perms[j] + diff

    // Check if third is in perms[j+1..]
    add     x26, x25, #1
.Lk_loop:
    cmp     x26, x23
    b.ge    .Lj_next
    ldr     x5, [x27, x26, lsl #3]
    cmp     x5, x4
    b.eq    .Lfound

    add     x26, x26, #1
    b       .Lk_loop

.Lj_next:
    add     x25, x25, #1
    b       .Lj_loop
.Li_next:
    add     x24, x24, #1
    b       .Li_loop

.Lp_next:
    add     x20, x20, #1
    b       .Lp_loop

.Lfound:
    // Return perms[i]*100000000 + perms[j]*10000 + third
    ldr     x1, [x27, x24, lsl #3]  // perms[i]
    ldr     x2, [x27, x25, lsl #3]  // perms[j]
    // x4 = third

    mov     x5, #100000000
    mul     x0, x1, x5
    mov     x5, #10000
    mul     x6, x2, x5
    add     x0, x0, x6
    add     x0, x0, x4

    b       .Lreturn

.Lp_done:
    mov     x0, #0

.Lreturn:
    add     sp, sp, #800
    add     sp, sp, #10016
    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

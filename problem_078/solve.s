// Problem 078: Coin Partitions
// Find the least value of n for which p(n) is divisible by one million.
// Answer: 55374
//
// Algorithm: Euler's pentagonal number theorem.
// p(n) = sum of (-1)^(k+1) * p(n - k*(3k-1)/2) for generalized pentagonal numbers.

.global _solve
.global _malloc
.global _free
.align 4

.set LIMIT, 100000
.set MODULUS, 1000000

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!

    // Allocate p[] array: LIMIT * 4 = 400000 bytes
    movz    x0, #(LIMIT & 0xFFFF)
    movk    x0, #(LIMIT >> 16), lsl #16
    lsl     x0, x0, #2
    bl      _malloc
    mov     x19, x0              // x19 = p array

    // Zero the array
    mov     x1, #0
    movz    x2, #(LIMIT & 0xFFFF)
    movk    x2, #(LIMIT >> 16), lsl #16
.Lzero:
    str     w1, [x0], #4
    subs    x2, x2, #1
    b.ne    .Lzero

    // p[0] = 1
    mov     w0, #1
    str     w0, [x19]

    // Precompute pentagonal numbers on stack (1000 entries * 4 = 4000 bytes)
    sub     sp, sp, #4000
    mov     x20, #0              // num_pent
    mov     x21, #1              // k
.Lpent_loop:
    cmp     x21, #500
    b.ge    .Lpent_done

    // pent1 = k*(3k-1)/2
    mov     x0, #3
    mul     x0, x21, x0
    sub     x0, x0, #1
    mul     x0, x21, x0
    lsr     x0, x0, #1
    str     w0, [sp, x20, lsl #2]
    add     x20, x20, #1

    // pent2 = k*(3k+1)/2
    mov     x0, #3
    mul     x0, x21, x0
    add     x0, x0, #1
    mul     x0, x21, x0
    lsr     x0, x0, #1
    str     w0, [sp, x20, lsl #2]
    add     x20, x20, #1

    add     x21, x21, #1
    b       .Lpent_loop
.Lpent_done:
    // x20 = num_pent

    // Main loop: for n = 1; n < LIMIT; n++
    mov     x22, #1              // n
    movz    x27, #(MODULUS & 0xFFFF)
    movk    x27, #(MODULUS >> 16), lsl #16

.Ln_loop:
    movz    x0, #(LIMIT & 0xFFFF)
    movk    x0, #(LIMIT >> 16), lsl #16
    cmp     x22, x0
    b.ge    .Lnot_found

    mov     x23, #0              // sum (signed long long)
    mov     x24, #0              // i

.Lpent_sum_loop:
    cmp     x24, x20
    b.ge    .Lpent_sum_done

    ldr     w25, [sp, x24, lsl #2]  // pentagonals[i]
    cmp     x25, x22
    b.gt    .Lpent_sum_done

    // sign: (i % 4 < 2) ? 1 : -1
    and     x0, x24, #3
    cmp     x0, #2

    // Load p[n - pentagonals[i]]
    sub     x1, x22, x25
    ldr     w26, [x19, x1, lsl #2]  // p[n - pent[i]] (unsigned int)

    // Apply sign
    b.ge    .Lneg_sign
    // positive: sum += p[n - pent[i]]
    add     x23, x23, x26
    b       .Lsign_done
.Lneg_sign:
    // negative: sum -= p[n - pent[i]]
    sub     x23, x23, x26
.Lsign_done:
    // sum %= MODULUS (signed)
    sdiv    x0, x23, x27
    msub    x23, x0, x27, x23

    add     x24, x24, #1
    b       .Lpent_sum_loop

.Lpent_sum_done:
    // p[n] = ((sum % MODULUS) + MODULUS) % MODULUS
    sdiv    x0, x23, x27
    msub    x23, x0, x27, x23
    add     x23, x23, x27
    udiv    x0, x23, x27
    msub    x23, x0, x27, x23

    str     w23, [x19, x22, lsl #2]

    // if p[n] == 0, return n
    cbz     x23, .Lfound_n

    add     x22, x22, #1
    b       .Ln_loop

.Lfound_n:
    mov     x28, x22             // save result
    b       .Lcleanup

.Lnot_found:
    mov     x28, #0

.Lcleanup:
    add     sp, sp, #4000

    // Free p array
    mov     x0, x19
    bl      _free

    mov     x0, x28
    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

// Problem 064: Odd Period Square Roots
// How many continued fractions for sqrt(N), N <= 10000, have odd period?
// Answer: 1322

.global _solve
.align 4

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!

    mov     x19, #0             // count = 0
    mov     x20, #2             // n = 2

.L64_outer:
    mov     x0, #10001
    cmp     x20, x0
    b.ge    .L64_done

    // a0 = isqrt(n)
    // Simple integer square root
    mov     x0, x20
    bl      .L64_isqrt
    mov     x21, x0             // a0

    // Check if perfect square
    mul     x0, x21, x21
    cmp     x0, x20
    b.eq    .L64_next_n

    // Compute period of continued fraction
    mov     x22, #0             // m = 0
    mov     x23, #1             // d = 1
    mov     x24, x21            // a = a0
    mov     x25, #0             // period = 0

.L64_cf_loop:
    // m = d * a - m
    mul     x0, x23, x24
    sub     x22, x0, x22

    // d = (n - m * m) / d
    mul     x0, x22, x22
    sub     x0, x20, x0
    sdiv    x23, x0, x23

    // a = (a0 + m) / d
    add     x0, x21, x22
    sdiv    x24, x0, x23

    add     x25, x25, #1

    // Check a == 2 * a0
    lsl     x0, x21, #1
    cmp     x24, x0
    b.ne    .L64_cf_loop

    // Check if period is odd
    tst     x25, #1
    b.eq    .L64_next_n
    add     x19, x19, #1

.L64_next_n:
    add     x20, x20, #1
    b       .L64_outer

.L64_done:
    mov     x0, x19

    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

// isqrt(x0) -> x0 (integer square root)
.L64_isqrt:
    cbz     x0, .L64_isqrt_ret
    mov     x1, x0
    lsr     x0, x1, #1          // initial guess = n/2
    cbz     x0, .L64_isqrt_one
.L64_isqrt_loop:
    udiv    x2, x1, x0          // n / guess
    add     x2, x2, x0          // guess + n/guess
    lsr     x2, x2, #1          // (guess + n/guess) / 2
    cmp     x2, x0
    b.ge    .L64_isqrt_ret
    mov     x0, x2
    b       .L64_isqrt_loop
.L64_isqrt_one:
    mov     x0, #1
.L64_isqrt_ret:
    ret

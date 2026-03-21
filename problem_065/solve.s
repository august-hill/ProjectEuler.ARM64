// Problem 065: Convergents of e
// Find sum of digits in numerator of 100th convergent of e.
// Answer: 272

.global _solve
.align 4

.set MAX_DIGITS, 80

// BigNum: 80 bytes, digits stored least-significant first
// Uses same continued fraction approach as C version

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!

    // Allocate 4 bignums: h_prev2, h_prev1, mul_tmp, new_h
    // Each 80 bytes, total 320, round to 320
    sub     sp, sp, #320
    mov     x19, sp              // h_prev2
    add     x20, sp, #80         // h_prev1
    add     x21, sp, #160        // mul_tmp
    add     x22, sp, #240        // new_h

    // h_prev2 = 1
    mov     x0, x19
    mov     x1, #0
    mov     x2, #80
    bl      _memset
    mov     w0, #1
    strb    w0, [x19]

    // h_prev1 = 2
    mov     x0, x20
    mov     x1, #0
    mov     x2, #80
    bl      _memset
    mov     w0, #2
    strb    w0, [x20]

    mov     x23, #1             // k = 1

.L65_loop:
    cmp     x23, #100
    b.ge    .L65_sum

    // Compute cf coefficient a
    // if k == 0: a = 2 (already handled)
    // j = k - 1; if j % 3 == 1: a = 2*(j/3+1), else a = 1
    sub     x0, x23, #1         // j = k - 1
    mov     x1, #3
    udiv    x2, x0, x1
    msub    x3, x2, x1, x0     // j % 3
    cmp     x3, #1
    b.ne    .L65_a_is_1
    add     x24, x2, #1
    lsl     x24, x24, #1        // a = 2 * (j/3 + 1)
    b       .L65_got_a
.L65_a_is_1:
    mov     x24, #1
.L65_got_a:

    // mul_tmp = h_prev1 * a (big_mul_small)
    mov     x0, x21
    mov     x1, #0
    mov     x2, #80
    bl      _memset

    mov     x0, #0              // i
    mov     x1, #0              // carry
.L65_mul:
    cmp     x0, #MAX_DIGITS
    b.ge    .L65_mul_done
    ldrb    w2, [x20, x0]       // h_prev1[i]
    mul     w3, w2, w24         // * a
    add     w3, w3, w1          // + carry
    mov     w4, #10
    udiv    w1, w3, w4
    msub    w5, w1, w4, w3
    strb    w5, [x21, x0]
    add     x0, x0, #1
    b       .L65_mul
.L65_mul_done:

    // new_h = mul_tmp + h_prev2 (big_add)
    mov     x0, #0
    mov     x1, #0              // carry
.L65_add:
    cmp     x0, #MAX_DIGITS
    b.ge    .L65_add_done
    ldrb    w2, [x21, x0]       // mul_tmp[i]
    ldrb    w3, [x19, x0]       // h_prev2[i]
    add     w2, w2, w3
    add     w2, w2, w1
    mov     w4, #10
    udiv    w1, w2, w4
    msub    w5, w1, w4, w2
    strb    w5, [x22, x0]
    add     x0, x0, #1
    b       .L65_add
.L65_add_done:

    // h_prev2 = h_prev1
    mov     x0, x19
    mov     x1, x20
    mov     x2, #80
    bl      _memcpy

    // h_prev1 = new_h
    mov     x0, x20
    mov     x1, x22
    mov     x2, #80
    bl      _memcpy

    add     x23, x23, #1
    b       .L65_loop

.L65_sum:
    // Sum digits of h_prev1
    mov     x0, #0              // sum
    mov     x1, #0              // i
.L65_digit_sum:
    cmp     x1, #MAX_DIGITS
    b.ge    .L65_done
    ldrb    w2, [x20, x1]
    add     x0, x0, x2
    add     x1, x1, #1
    b       .L65_digit_sum

.L65_done:
    add     sp, sp, #320

    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

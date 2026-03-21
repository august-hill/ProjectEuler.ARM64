// Problem 056: Powerful Digit Sum
// Considering a^b where a,b < 100, find the maximum digital sum.
// Answer: 972

.global _solve
.align 4

.set MAX_DIGITS, 200

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!

    // Allocate bignum on stack: 200 bytes + 8 for len
    sub     sp, sp, #208
    mov     x19, sp              // x19 = power digits

    mov     x24, #0             // max_sum = 0
    mov     x20, #2             // a = 2

.L56_a_loop:
    cmp     x20, #100
    b.ge    .L56_done

    // bignum_set_one: power = 1
    mov     x0, x19
    mov     x1, #0
    mov     x2, #200
    bl      _memset
    mov     w0, #1
    strb    w0, [x19]
    mov     x25, #1             // len = 1

    mov     x21, #1             // b = 1
.L56_b_loop:
    cmp     x21, #100
    b.ge    .L56_next_a

    // bignum_multiply_int(power, a)
    mov     x22, #0             // i = 0
    mov     x23, #0             // carry = 0
.L56_mul:
    cmp     x22, x25
    b.ge    .L56_mul_carry
    ldrb    w0, [x19, x22]
    mul     w1, w0, w20         // digit * a
    add     w1, w1, w23         // + carry
    mov     w2, #10
    udiv    w23, w1, w2         // carry = prod / 10
    msub    w3, w23, w2, w1     // digit = prod % 10
    strb    w3, [x19, x22]
    add     x22, x22, #1
    b       .L56_mul
.L56_mul_carry:
    cbz     w23, .L56_mul_done
    mov     w2, #10
    udiv    w3, w23, w2
    msub    w4, w3, w2, w23
    strb    w4, [x19, x25]
    add     x25, x25, #1
    mov     w23, w3
    b       .L56_mul_carry
.L56_mul_done:

    // Compute digit sum
    mov     x22, #0             // i = 0
    mov     x26, #0             // sum = 0
.L56_sum:
    cmp     x22, x25
    b.ge    .L56_sum_done
    ldrb    w0, [x19, x22]
    add     x26, x26, x0
    add     x22, x22, #1
    b       .L56_sum
.L56_sum_done:
    cmp     x26, x24
    b.le    .L56_next_b
    mov     x24, x26

.L56_next_b:
    add     x21, x21, #1
    b       .L56_b_loop

.L56_next_a:
    add     x20, x20, #1
    b       .L56_a_loop

.L56_done:
    mov     x0, x24
    add     sp, sp, #208

    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

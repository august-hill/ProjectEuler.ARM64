// Problem 063: Powerful Digit Counts
// How many n-digit positive integers exist which are also an nth power?
// Answer: 49

.global _solve
.align 4

// For base 1..9, compute base^n, count digits until digits < n.
// Max value needed: 9^21 ≈ 1.09e20, needs 128-bit arithmetic.

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!

    mov     x19, #0             // count = 0
    mov     x20, #1             // base = 1

.L63_base:
    cmp     x20, #10
    b.ge    .L63_done

    // power_hi:power_lo = base (128-bit)
    mov     x21, #0             // hi
    mov     x22, x20            // lo
    mov     x23, #1             // n = 1

.L63_power:
    // Count digits of 128-bit number hi:lo
    // Copy to temps for counting
    mov     x0, x21
    mov     x1, x22
    mov     x24, #0             // digit count

    // If both zero, 0 digits
    orr     x2, x0, x1
    cbz     x2, .L63_check

.L63_cd_loop:
    orr     x2, x0, x1
    cbz     x2, .L63_check

    // Divide 128-bit by 10
    // new_hi = hi / 10
    // rem = hi % 10
    // new_lo = (rem * 2^64 + lo) / 10
    // But rem * 2^64 doesn't fit in 64 bits if rem > 0...
    // Use: new_lo = (rem << 60) * 16 ... no.
    // Better: use two-step division
    // hi:lo / 10:
    // q_hi = hi / 10, r = hi % 10
    // temp = r * (2^64 / 10) ... still overflow
    // Standard 128/64 division approach:
    // Process 64 bits at a time
    mov     x3, #10
    udiv    x4, x0, x3          // q_hi = hi / 10
    msub    x5, x4, x3, x0     // r = hi % 10
    // Now need (r * 2^64 + lo) / 10
    // r is 0-9, r * 2^64 overflows
    // Split: (r * 2^63 * 2 + lo) / 10
    // = (r * 2^63) / 5 + lo/10 + adjustments
    // Actually use the identity:
    // (r * 2^64 + lo) / 10 = r * 1844674407370955161 + r * 6/10 + lo/10
    // where 2^64/10 = 1844674407370955161 remainder 6
    // This is: r * (2^64/10) + (r * 6 + lo) / 10
    movz    x6, #0x9999
    movk    x6, #0x9999, lsl #16
    movk    x6, #0x9999, lsl #32
    movk    x6, #0x1999, lsl #48  // 2^64 / 10 = 0x1999999999999999
    mul     x7, x5, x6          // r * (2^64/10) low part
    umulh   x8, x5, x6          // r * (2^64/10) high part (carry to q_hi)

    // (r * 6 + lo) / 10
    mov     x9, #6
    mul     x9, x5, x9          // r * 6
    adds    x9, x9, x1          // r * 6 + lo (might carry)
    adc     x10, xzr, xzr       // carry
    udiv    x11, x9, x3         // (r*6 + lo) / 10

    add     x1, x7, x11         // new lo = r*(2^64/10) + (r*6+lo)/10
    add     x0, x4, x8          // new hi = q_hi + carry from mul

    add     x24, x24, #1
    b       .L63_cd_loop

.L63_check:
    // x24 = number of digits
    cmp     x24, x23
    b.lt    .L63_next_base
    b.gt    .L63_advance
    // digits == n
    add     x19, x19, #1

.L63_advance:
    // power *= base (128-bit)
    mul     x0, x22, x20
    umulh   x1, x22, x20
    mul     x2, x21, x20
    add     x21, x1, x2         // new hi
    mov     x22, x0             // new lo

    add     x23, x23, #1
    cmp     x23, #100
    b.gt    .L63_next_base
    b       .L63_power

.L63_next_base:
    add     x20, x20, #1
    b       .L63_base

.L63_done:
    mov     x0, x19

    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

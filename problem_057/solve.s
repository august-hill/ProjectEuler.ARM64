// Problem 057: Square Root Convergents
// In first 1000 expansions of sqrt(2) continued fraction,
// how many fractions have numerator with more digits than denominator?
// Answer: 153

.global _solve
.align 4

.set MAX_DIGITS, 400

// BigNum operations for continued fraction convergents
// n_{k+1} = n_k + 2*d_k, d_{k+1} = n_k + d_k

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!

    // Allocate 4 bignums: n, d, new_n, new_d
    // Each MAX_DIGITS bytes + 8 for length = 408, round to 416
    // Total: 4 * 416 = 1664 bytes
    // But simpler: just store lengths separately and arrays contiguously
    // n=sp, d=sp+400, new_n=sp+800, new_d=sp+1200
    sub     sp, sp, #1600
    mov     x19, sp              // n
    add     x20, sp, #400        // d
    add     x21, sp, #800        // new_n
    add     x22, sp, #1200       // new_d

    // n = 1, d = 1
    mov     x0, x19
    mov     x1, #0
    mov     x2, #400
    bl      _memset
    mov     x0, x20
    mov     x1, #0
    mov     x2, #400
    bl      _memset
    mov     w0, #1
    strb    w0, [x19]
    strb    w0, [x20]
    mov     x23, #1             // n_len = 1
    mov     x24, #1             // d_len = 1
    mov     x25, #0             // count = 0
    mov     x26, #0             // iteration = 0

.L57_loop:
    cmp     x26, #1000
    b.ge    .L57_done

    // new_n = n + 2*d (bignum_add_twice)
    mov     x0, x21
    mov     x1, #0
    mov     x2, #400
    bl      _memset

    // max_len = max(n_len, d_len)
    cmp     x23, x24
    csel    x27, x23, x24, gt   // x27 = max_len
    mov     x0, #0              // i
    mov     x1, #0              // carry
.L57_add_twice:
    cmp     x0, x27
    b.ge    .L57_at_carry_check
    ldrb    w2, [x19, x0]       // n[i]
    ldrb    w3, [x20, x0]       // d[i]
    add     w2, w2, w3, lsl #1  // n[i] + 2*d[i]
    add     w2, w2, w1          // + carry
    mov     w3, #10
    udiv    w1, w2, w3
    msub    w4, w1, w3, w2
    strb    w4, [x21, x0]
    add     x0, x0, #1
    b       .L57_add_twice
.L57_at_carry_check:
    mov     x28, x0             // new_n_len = max_len (so far)
    cbz     w1, .L57_at_done
    strb    w1, [x21, x28]
    add     x28, x28, #1
.L57_at_done:
    // x28 = new_n_len

    // new_d = n + d (bignum_add)
    mov     x0, x22
    mov     x1, #0
    mov     x2, #400
    bl      _memset

    mov     x0, #0
    mov     x1, #0              // carry
.L57_add:
    cmp     x0, x27
    b.ge    .L57_add_carry
    ldrb    w2, [x19, x0]       // n[i]
    ldrb    w3, [x20, x0]       // d[i]
    add     w2, w2, w3
    add     w2, w2, w1
    mov     w3, #10
    udiv    w1, w2, w3
    msub    w4, w1, w3, w2
    strb    w4, [x22, x0]
    add     x0, x0, #1
    b       .L57_add
.L57_add_carry:
    mov     x27, x0             // new_d_len
    cbz     w1, .L57_add_done
    strb    w1, [x22, x27]
    add     x27, x27, #1
.L57_add_done:
    // x27 = new_d_len

    // Copy new_n -> n, new_d -> d
    mov     x0, x19
    mov     x1, x21
    mov     x2, #400
    bl      _memcpy
    mov     x23, x28            // n_len = new_n_len

    mov     x0, x20
    mov     x1, x22
    mov     x2, #400
    bl      _memcpy
    mov     x24, x27            // d_len = new_d_len

    // Check if n_len > d_len
    cmp     x23, x24
    b.le    .L57_no_count
    add     x25, x25, #1
.L57_no_count:

    add     x26, x26, #1
    b       .L57_loop

.L57_done:
    mov     x0, x25
    add     sp, sp, #1600

    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

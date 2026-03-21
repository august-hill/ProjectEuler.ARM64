// Problem 052: Permuted Multiples
// Find smallest x where x, 2x, 3x, 4x, 5x, 6x contain same digits.
// Answer: 142857

.global _solve
.align 4

// digit_signature: compute sorted digit representation packed in x0
// Uses digit count approach: 4 bits per digit (0-9), packed into 40-bit value
// Input: x0 = number
// Output: x0 = signature
.L52_digit_sig:
    mov     x1, #0              // signature = 0
    mov     x3, #10
.L52_ds_loop:
    cbz     x0, .L52_ds_done
    udiv    x2, x0, x3
    msub    x4, x2, x3, x0     // x4 = x0 % 10 (current digit)
    mov     x0, x2              // x0 = x0 / 10
    // Increment count for digit x4: add 1 << (x4 * 4)
    lsl     x5, x4, #2         // x5 = x4 * 4
    mov     x6, #1
    lsl     x6, x6, x5         // x6 = 1 << (digit * 4)
    add     x1, x1, x6
    b       .L52_ds_loop
.L52_ds_done:
    mov     x0, x1
    ret

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!

    mov     x19, #1             // x = 1

.L52_outer:
    mov     x0, x19
    bl      .L52_digit_sig
    mov     x20, x0             // sig of x

    mov     x21, #2             // m = 2
.L52_check_mult:
    cmp     x21, #7
    b.ge    .L52_found
    mul     x0, x19, x21
    bl      .L52_digit_sig
    cmp     x0, x20
    b.ne    .L52_no_match
    add     x21, x21, #1
    b       .L52_check_mult

.L52_no_match:
    add     x19, x19, #1
    b       .L52_outer

.L52_found:
    mov     x0, x19
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

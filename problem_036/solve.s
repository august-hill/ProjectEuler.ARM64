// Problem 036: Double-base Palindromes
// Find the sum of all numbers < 1000000 palindromic in both base 10 and base 2.
// Answer: 872187

.global _solve
.align 4

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!

    mov     x19, #0                  // sum
    mov     x20, #1                  // n

.L36_loop:
    mov     x1, #16960
    movk    x1, #15, lsl #16         // x1 = 1000000
    cmp     x20, x1
    b.ge    .L36_done

    // Reverse the decimal digits
    mov     x1, x20
    mov     x2, #0                   // reversed
    mov     x3, #10
.L36_rev_dec:
    cbz     x1, .L36_rev_dec_done
    udiv    x4, x1, x3
    msub    x5, x4, x3, x1          // digit = n % 10
    mul     x2, x2, x3
    add     x2, x2, x5
    mov     x1, x4
    b       .L36_rev_dec
.L36_rev_dec_done:
    cmp     x2, x20
    b.ne    .L36_next

    // Reverse the binary representation
    mov     x2, #0                   // reversed binary
    mov     x7, x20
.L36_rev_bin:
    cbz     x7, .L36_rev_bin_done
    lsl     x2, x2, #1
    and     x8, x7, #1
    orr     x2, x2, x8
    lsr     x7, x7, #1
    b       .L36_rev_bin
.L36_rev_bin_done:
    cmp     x2, x20
    b.ne    .L36_next

    add     x19, x19, x20

.L36_next:
    add     x20, x20, #1
    b       .L36_loop

.L36_done:
    mov     x0, x19
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

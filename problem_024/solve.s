// Problem 024: Lexicographic Permutations
// What is the millionth lexicographic permutation of the digits 0-9?
// Answer: 2783915460
//
// Algorithm: Factorial number system decomposition.
// For each position, determine which digit to pick using n / factorial.

.global _solve
.align 4

// long long solve(void)
_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!

    // Allocate digits[10] on stack (use 16 bytes for alignment)
    sub     sp, sp, #16
    mov     x19, sp              // x19 = digits array

    // Initialize digits = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}
    mov     w0, #0
.Linit:
    cmp     w0, #10
    b.ge    .Linit_done
    strb    w0, [x19, w0, uxtw]
    add     w0, w0, #1
    b       .Linit

.Linit_done:
    mov     x20, #10             // remaining = 10
    movz    x21, #(999999 & 0xFFFF)
    movk    x21, #(999999 >> 16), lsl #16  // n = 999999 (0-indexed)
    mov     x22, #0              // result = 0

    // Process positions i = 9 down to 1
    mov     x0, #9               // x0 = i

.Lpos_loop:
    cmp     x0, #1
    b.lt    .Lpos_done

    // Compute factorial(i)
    mov     x1, #1               // fact = 1
    mov     x2, #2               // j = 2
.Lfact_loop:
    cmp     x2, x0
    b.gt    .Lfact_done
    mul     x1, x1, x2
    add     x2, x2, #1
    b       .Lfact_loop

.Lfact_done:
    // idx = n / fact
    udiv    x3, x21, x1          // x3 = idx

    // result = result * 10 + digits[idx]
    mov     x4, #10
    mul     x22, x22, x4
    ldrb    w5, [x19, x3]
    add     x22, x22, x5

    // Remove digit at idx: shift left
    mov     x6, x3
.Lremove:
    add     x7, x6, #1
    cmp     x7, x20
    b.ge    .Lremove_done
    ldrb    w8, [x19, x7]
    strb    w8, [x19, x6]
    add     x6, x6, #1
    b       .Lremove

.Lremove_done:
    sub     x20, x20, #1        // remaining--

    // n %= fact
    msub    x21, x3, x1, x21

    sub     x0, x0, #1
    b       .Lpos_loop

.Lpos_done:
    // Last digit: result = result * 10 + digits[0]
    mov     x4, #10
    mul     x22, x22, x4
    ldrb    w5, [x19]
    add     x0, x22, x5

    add     sp, sp, #16

    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

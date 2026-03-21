// Problem 025: 1000-digit Fibonacci Number
// What is the index of the first term in the Fibonacci sequence
// to contain 1000 digits?
// Answer: 4782
//
// Algorithm: Big number addition. Maintain two arrays fib1 and fib2,
// add them, swap, repeat until length reaches 1000.

.global _solve
.global _malloc
.global _free
.align 4

.set MAX_DIGITS, 1100
.set TARGET_LEN, 1000

// long long solve(void)
_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!

    // Allocate fib1[MAX_DIGITS]
    movz    x0, #MAX_DIGITS
    bl      _malloc
    mov     x19, x0              // x19 = fib1

    // Allocate fib2[MAX_DIGITS]
    movz    x0, #MAX_DIGITS
    bl      _malloc
    mov     x20, x0              // x20 = fib2

    // Zero both arrays
    mov     x1, #0
.Lzero1:
    cmp     x1, #MAX_DIGITS
    b.ge    .Lzero1_done
    strb    wzr, [x19, x1]
    strb    wzr, [x20, x1]
    add     x1, x1, #1
    b       .Lzero1

.Lzero1_done:
    // fib1[0] = 1 (F(1)), fib2[0] = 1 (F(2))
    mov     w0, #1
    strb    w0, [x19]
    strb    w0, [x20]
    mov     x21, #1              // len1 = 1
    mov     x22, #1              // len2 = 1
    mov     x23, #2              // term = 2

.Lmain_loop:
    cmp     x22, #TARGET_LEN
    b.ge    .Lmain_done

    // Add fib1 + fib2 into fib1
    // max_len = max(len1, len2)
    cmp     x21, x22
    csel    x24, x21, x22, ge   // x24 = max_len

    mov     x1, #0               // i = 0
    mov     w2, #0               // carry = 0
.Ladd_loop:
    cmp     x1, x24
    b.ge    .Ladd_done

    ldrb    w3, [x19, x1]       // fib1[i]
    ldrb    w4, [x20, x1]       // fib2[i]
    add     w3, w3, w4
    add     w3, w3, w2           // sum = fib1[i] + fib2[i] + carry
    mov     w5, #10
    udiv    w2, w3, w5           // carry = sum / 10
    msub    w6, w2, w5, w3       // sum % 10
    strb    w6, [x19, x1]       // fib1[i] = sum % 10

    add     x1, x1, #1
    b       .Ladd_loop

.Ladd_done:
    cbz     w2, .Lno_carry
    strb    w2, [x19, x24]
    add     x21, x24, #1        // len1 = max_len + 1
    b       .Lswap
.Lno_carry:
    mov     x21, x24            // len1 = max_len

.Lswap:
    // Swap fib1 and fib2 (swap pointers and lengths)
    mov     x25, x19
    mov     x19, x20
    mov     x20, x25

    mov     x25, x21
    mov     x21, x22
    mov     x22, x25

    add     x23, x23, #1        // term++
    b       .Lmain_loop

.Lmain_done:
    mov     x25, x23             // save result (term)

    // Free arrays
    mov     x0, x19
    bl      _free
    mov     x0, x20
    bl      _free

    mov     x0, x25

    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

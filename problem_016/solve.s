// Problem 016: Power Digit Sum
// What is the sum of the digits of 2^1000?
// Answer: 1366
//
// Algorithm: Big number multiplication by 2, stored as array of digits.
// Uses stack for the digit array (320 bytes).

.global _solve
.align 4

.set MAX_DIGITS, 320
.set POWER, 1000

// long long solve(void)
_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!

    // Allocate digit array on stack (320 bytes, 16-byte aligned -> 320)
    sub     sp, sp, #320
    mov     x19, sp              // x19 = digits array base

    // Zero the array
    mov     x0, #0
    mov     x1, #0
.Lzero:
    cmp     x1, #MAX_DIGITS
    b.ge    .Lzero_done
    strb    wzr, [x19, x1]
    add     x1, x1, #1
    b       .Lzero

.Lzero_done:
    // digits[0] = 1
    mov     w0, #1
    strb    w0, [x19]
    mov     x20, #1              // x20 = len

    // Multiply by 2, 1000 times
    mov     x21, #0              // x21 = iteration counter
.Lmul_loop:
    cmp     x21, #POWER
    b.ge    .Lmul_done

    mov     x1, #0               // j = 0
    mov     w2, #0               // carry = 0
.Ldigit_loop:
    cmp     x1, x20
    b.ge    .Ldigit_done

    ldrb    w3, [x19, x1]       // digits[j]
    lsl     w3, w3, #1           // digits[j] * 2
    add     w3, w3, w2           // + carry
    mov     w4, #10
    udiv    w2, w3, w4           // carry = val / 10
    msub    w5, w2, w4, w3       // val % 10
    strb    w5, [x19, x1]       // digits[j] = val % 10

    add     x1, x1, #1
    b       .Ldigit_loop

.Ldigit_done:
    cbz     w2, .Lno_extend
    strb    w2, [x19, x20]      // digits[len] = carry
    add     x20, x20, #1        // len++
.Lno_extend:

    add     x21, x21, #1
    b       .Lmul_loop

.Lmul_done:
    // Sum all digits
    mov     x0, #0               // sum
    mov     x1, #0               // j
.Lsum_loop:
    cmp     x1, x20
    b.ge    .Lsum_done
    ldrb    w2, [x19, x1]
    add     x0, x0, x2
    add     x1, x1, #1
    b       .Lsum_loop

.Lsum_done:
    add     sp, sp, #320

    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

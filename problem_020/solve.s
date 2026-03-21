// Problem 020: Factorial Digit Sum
// Find the sum of the digits in 100!
// Answer: 648
//
// Algorithm: Big number multiplication. Store digits in array,
// multiply by each factor 2..100, then sum digits.

.global _solve
.align 4

.set MAX_DIGITS, 200

// long long solve(void)
_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!

    // Allocate digit array on stack (208 bytes, 16-byte aligned)
    sub     sp, sp, #208
    mov     x19, sp              // x19 = digits

    // Zero the array
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

    // Multiply by n = 2..100
    mov     x21, #2              // x21 = n

.Lmul_loop:
    cmp     x21, #100
    b.gt    .Lmul_done

    mov     x1, #0               // i = 0
    mov     w22, #0              // carry = 0

.Ldigit_loop:
    cmp     x1, x20
    b.ge    .Ldigit_done

    ldrb    w2, [x19, x1]       // digits[i]
    mul     w2, w2, w21          // digits[i] * n
    add     w2, w2, w22          // + carry
    mov     w3, #10
    udiv    w22, w2, w3          // carry = prod / 10
    msub    w4, w22, w3, w2      // prod % 10
    strb    w4, [x19, x1]

    add     x1, x1, #1
    b       .Ldigit_loop

.Ldigit_done:
    // While carry > 0, extend
.Lextend:
    cbz     w22, .Lextend_done
    mov     w3, #10
    udiv    w23, w22, w3         // new_carry = carry / 10
    msub    w4, w23, w3, w22     // carry % 10
    strb    w4, [x19, x20]
    add     x20, x20, #1
    mov     w22, w23
    b       .Lextend

.Lextend_done:
    add     x21, x21, #1
    b       .Lmul_loop

.Lmul_done:
    // Sum digits
    mov     x0, #0
    mov     x1, #0
.Lsum_loop:
    cmp     x1, x20
    b.ge    .Lsum_done
    ldrb    w2, [x19, x1]
    add     x0, x0, x2
    add     x1, x1, #1
    b       .Lsum_loop

.Lsum_done:
    add     sp, sp, #208

    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

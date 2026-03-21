// Problem 034: Digit Factorials
// Find the sum of all numbers which are equal to the sum of the factorial of their digits.
// Answer: 40730

.global _solve
.align 4

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!

    // Factorials lookup on stack (10 * 8 = 80 bytes)
    sub     sp, sp, #80
    mov     x9, sp

    // factorials = {1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880}
    mov     x0, #1
    str     x0, [x9, #0]            // 0! = 1
    str     x0, [x9, #8]            // 1! = 1
    mov     x0, #2
    str     x0, [x9, #16]           // 2! = 2
    mov     x0, #6
    str     x0, [x9, #24]           // 3! = 6
    mov     x0, #24
    str     x0, [x9, #32]           // 4! = 24
    mov     x0, #120
    str     x0, [x9, #40]           // 5! = 120
    mov     x0, #720
    str     x0, [x9, #48]           // 6! = 720
    mov     x0, #5040
    str     x0, [x9, #56]           // 7! = 5040
    movz    x0, #40320
    str     x0, [x9, #64]           // 8! = 40320
    movz    x0, #0x8980
    movk    x0, #0x5, lsl #16       // 362880 = 0x58980
    str     x0, [x9, #72]           // 9! = 362880

    mov     x19, #0                  // total sum
    mov     x20, #3                  // n = 3

    // Upper bound: 2540160 = 0x26C280
    movz    x10, #0xC280
    movk    x10, #0x0026, lsl #16

.Lloop:
    cmp     x20, x10
    b.gt    .Ldone

    // digit_factorial_sum(n)
    mov     x1, x20                  // temp = n
    mov     x2, #0                   // dfs = 0
    mov     x3, #10
.Ldigit_loop:
    cbz     x1, .Ldigit_done
    udiv    x4, x1, x3
    msub    x5, x4, x3, x1          // digit = temp % 10
    ldr     x6, [x9, x5, lsl #3]    // factorials[digit]
    add     x2, x2, x6
    mov     x1, x4
    b       .Ldigit_loop
.Ldigit_done:

    cmp     x20, x2
    b.ne    .Lnot_equal
    add     x19, x19, x20
.Lnot_equal:
    add     x20, x20, #1
    b       .Lloop

.Ldone:
    mov     x0, x19

    add     sp, sp, #80
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

// Problem 030: Digit Fifth Powers
// Find the sum of all numbers that can be written as the sum of fifth powers of their digits.
// Answer: 443839

.global _solve
.align 4

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!

    // pow5 lookup table on stack (10 * 8 = 80 bytes, round to 80, 16-aligned = 80)
    sub     sp, sp, #80
    mov     x9, sp

    // Store pow5 values: 0,1,32,243,1024,3125,7776,16807,32768,59049
    mov     x0, #0
    str     x0, [x9, #0]            // pow5[0] = 0
    mov     x0, #1
    str     x0, [x9, #8]            // pow5[1] = 1
    mov     x0, #32
    str     x0, [x9, #16]           // pow5[2] = 32
    mov     x0, #243
    str     x0, [x9, #24]           // pow5[3] = 243
    mov     x0, #1024
    str     x0, [x9, #32]           // pow5[4] = 1024
    mov     x0, #3125
    str     x0, [x9, #40]           // pow5[5] = 3125
    mov     x0, #7776
    str     x0, [x9, #48]           // pow5[6] = 7776
    movz    x0, #16807
    str     x0, [x9, #56]           // pow5[7] = 16807
    movz    x0, #32768
    str     x0, [x9, #64]           // pow5[8] = 32768
    movz    x0, #59049
    str     x0, [x9, #72]           // pow5[9] = 59049

    mov     x19, #0                  // total sum = 0
    mov     x20, #2                  // n = 2

    // Upper bound: 354294
    // 354294 = 0x568E6
    movz    x10, #0x68E6
    movk    x10, #0x0005, lsl #16    // x10 = 354294

.Lloop:
    cmp     x20, x10
    b.gt    .Ldone

    // fifth_power_sum(n)
    mov     x1, x20                  // temp = n
    mov     x2, #0                   // digit_sum = 0
    mov     x3, #10
.Ldigit_loop:
    cbz     x1, .Ldigit_done
    udiv    x4, x1, x3              // temp / 10
    msub    x5, x4, x3, x1          // digit = temp % 10
    ldr     x6, [x9, x5, lsl #3]    // pow5[digit]
    add     x2, x2, x6
    mov     x1, x4                   // temp = temp / 10
    b       .Ldigit_loop
.Ldigit_done:

    // if n == fifth_power_sum(n)
    cmp     x20, x2
    b.ne    .Lnot_equal
    add     x19, x19, x20           // sum += n
.Lnot_equal:
    add     x20, x20, #1
    b       .Lloop

.Ldone:
    mov     x0, x19

    add     sp, sp, #80
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

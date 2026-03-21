// Problem 038: Pandigital Multiples
// What is the largest 1 to 9 pandigital 9-digit number that can be formed as the
// concatenated product of an integer with (1,2,...,n) where n > 1?
// Answer: 932718654

.global _solve
.align 4

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!

    mov     x19, #0                  // largest = 0
    mov     x20, #1                  // num = 1
    mov     x10, #10

.Lnum_loop:
    cmp     x20, #10000
    b.ge    .Lnum_done

    // Build concatenated product
    mov     x21, #0                  // concat_value = 0
    mov     x22, #0                  // total_digits = 0
    mov     x23, #1                  // n = 1

.Ln_loop:
    cmp     x22, #9
    b.ge    .Ln_done

    // product = num * n
    mul     x24, x20, x23

    // Count digits of product
    mov     x1, x24
    mov     x2, #0                   // digit count
.Lcount:
    cbz     x1, .Lcount_done
    udiv    x1, x1, x10
    add     x2, x2, #1
    b       .Lcount
.Lcount_done:

    // Shift concat_value left by digit_count digits
    mov     x3, #1
    mov     x4, x2
.Lshift:
    cbz     x4, .Lshift_done
    mul     x3, x3, x10
    sub     x4, x4, #1
    b       .Lshift
.Lshift_done:
    mul     x21, x21, x3
    add     x21, x21, x24           // concat_value = concat_value * 10^digits + product
    add     x22, x22, x2            // total_digits += digit_count

    add     x23, x23, #1
    b       .Ln_loop
.Ln_done:

    // n > 2 means we used at least (1,2) => x23 is now > 2
    cmp     x23, #3                  // n was incremented past 2, so n >= 3 means at least 2 multipliers
    b.lt    .Lnum_next

    // Check total_digits == 9
    cmp     x22, #9
    b.ne    .Lnum_next

    // Check pandigital: each digit 1-9 exactly once, no 0
    mov     x1, x21
    mov     x2, #0                   // bitmask
    mov     x3, #0                   // digit count
    mov     x4, #1                   // valid flag
.Lpan_check:
    cbz     x1, .Lpan_done
    udiv    x5, x1, x10
    msub    x6, x5, x10, x1         // digit
    cbz     x6, .Lpan_fail           // digit 0
    mov     x7, #1
    lsl     x7, x7, x6
    tst     x2, x7
    b.ne    .Lpan_fail               // duplicate
    orr     x2, x2, x7
    add     x3, x3, #1
    mov     x1, x5
    b       .Lpan_check
.Lpan_fail:
    mov     x4, #0
.Lpan_done:
    cbz     x4, .Lnum_next
    cmp     x3, #9
    b.ne    .Lnum_next
    mov     x7, #0x3FE
    cmp     x2, x7
    b.ne    .Lnum_next

    // Update largest
    cmp     x21, x19
    b.le    .Lnum_next
    mov     x19, x21

.Lnum_next:
    add     x20, x20, #1
    b       .Lnum_loop
.Lnum_done:

    mov     x0, x19

    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

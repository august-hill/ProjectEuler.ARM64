// Problem 040: Champernowne's Constant
// Find d1 x d10 x d100 x d1000 x d10000 x d100000 x d1000000
// Answer: 210

.global _solve
.global _malloc
.global _free
.align 4

.set BUFFER_SIZE, 1100000

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!

    // Allocate buffer
    movz    x0, #(BUFFER_SIZE & 0xFFFF)
    movk    x0, #(BUFFER_SIZE >> 16), lsl #16
    bl      _malloc
    mov     x19, x0                  // buffer

    mov     x20, #0                  // pos = 0
    mov     x21, #1                  // i = 1
    mov     x10, #10

    // Build Champernowne's constant string
.Lbuild_loop:
    mov     x1, #1000001
    cmp     x20, x1
    b.ge    .Lbuild_done

    // Convert i to digits and append
    // First, find number of digits and extract them
    mov     x1, x21
    mov     x2, #0                   // digit_count
    mov     x3, #1                   // divisor (will be 10^(digits-1))

    // Count digits
    mov     x4, x1
.Lcount:
    cbz     x4, .Lcount_done
    udiv    x4, x4, x10
    add     x2, x2, #1
    b       .Lcount
.Lcount_done:

    // Compute 10^(digits-1)
    mov     x3, #1
    sub     x4, x2, #1
.Lpow:
    cbz     x4, .Lpow_done
    mul     x3, x3, x10
    sub     x4, x4, #1
    b       .Lpow
.Lpow_done:

    // Extract digits from most significant to least
    mov     x4, x21                  // number
.Lextract:
    cbz     x3, .Lextract_done
    udiv    x5, x4, x3              // digit
    msub    x4, x5, x3, x4          // remainder
    add     x5, x5, #'0'

    movz    x6, #(BUFFER_SIZE & 0xFFFF)
    movk    x6, #(BUFFER_SIZE >> 16), lsl #16
    cmp     x20, x6
    b.ge    .Lextract_done
    strb    w5, [x19, x20]
    add     x20, x20, #1

    udiv    x3, x3, x10
    b       .Lextract
.Lextract_done:

    add     x21, x21, #1
    b       .Lbuild_loop
.Lbuild_done:

    // Compute product: d1 * d10 * d100 * d1000 * d10000 * d100000 * d1000000
    // Indices: 0, 9, 99, 999, 9999, 99999, 999999
    mov     x0, #1                   // product

    ldrb    w1, [x19, #0]
    sub     w1, w1, #'0'
    mul     x0, x0, x1

    ldrb    w1, [x19, #9]
    sub     w1, w1, #'0'
    mul     x0, x0, x1

    ldrb    w1, [x19, #99]
    sub     w1, w1, #'0'
    mul     x0, x0, x1

    mov     x2, #999
    ldrb    w1, [x19, x2]
    sub     w1, w1, #'0'
    mul     x0, x0, x1

    mov     x2, #9999
    ldrb    w1, [x19, x2]
    sub     w1, w1, #'0'
    mul     x0, x0, x1

    mov     x2, #99999
    ldrb    w1, [x19, x2]
    sub     w1, w1, #'0'
    mul     x0, x0, x1

    mov     x2, #999999
    ldrb    w1, [x19, x2]
    sub     w1, w1, #'0'
    mul     x0, x0, x1

    mov     x22, x0                  // save result

    mov     x0, x19
    bl      _free

    mov     x0, x22

    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

// Problem 032: Pandigital Products
// Find the sum of all products whose multiplicand/multiplier/product identity
// can be written as a 1 through 9 pandigital.
// Answer: 45228

.global _solve
.align 4

_solve:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!

    // products[20] on stack + digit tracking
    sub     sp, sp, #96              // 20*4=80, round to 96
    mov     x19, sp                  // x19 = products array
    mov     x20, #0                  // product_count

    // for a = 1; a < 100; a++
    mov     x21, #1
.La_loop:
    cmp     x21, #100
    b.ge    .La_done

    // Determine start/end for b
    cmp     x21, #10
    b.ge    .La_two_digit
    mov     x23, #1000               // start = 1000
    mov     x24, #9999               // end = 9999
    b       .Lb_start
.La_two_digit:
    mov     x23, #100                // start = 100
    mov     x24, #999                // end = 999
.Lb_start:

    // for b = start; b <= end; b++
    mov     x22, x23
.Lb_loop:
    cmp     x22, x24
    b.gt    .Lb_done

    mul     x25, x21, x22           // c = a * b

    // is_pandigital(a, b, c)?
    // Count total digits and check each digit 1-9 appears exactly once
    // We use a bitmask in x26 for digits seen
    mov     x26, #0                  // digit bitmask
    mov     x9, #0                   // total digit count
    mov     x10, #10

    // Extract digits of a
    mov     x11, x21
.Ldig_a:
    cbz     x11, .Ldig_b_start
    udiv    x12, x11, x10
    msub    x13, x12, x10, x11      // digit
    cbz     x13, .Lnot_pandigital   // digit 0 not allowed
    mov     x14, #1
    lsl     x14, x14, x13
    tst     x26, x14                 // already seen?
    b.ne    .Lnot_pandigital
    orr     x26, x26, x14
    add     x9, x9, #1
    mov     x11, x12
    b       .Ldig_a

.Ldig_b_start:
    // Extract digits of b
    mov     x11, x22
.Ldig_b:
    cbz     x11, .Ldig_c_start
    udiv    x12, x11, x10
    msub    x13, x12, x10, x11
    cbz     x13, .Lnot_pandigital
    mov     x14, #1
    lsl     x14, x14, x13
    tst     x26, x14
    b.ne    .Lnot_pandigital
    orr     x26, x26, x14
    add     x9, x9, #1
    mov     x11, x12
    b       .Ldig_b

.Ldig_c_start:
    // Extract digits of c
    mov     x11, x25
.Ldig_c:
    cbz     x11, .Lcheck_pandigital
    udiv    x12, x11, x10
    msub    x13, x12, x10, x11
    cbz     x13, .Lnot_pandigital
    mov     x14, #1
    lsl     x14, x14, x13
    tst     x26, x14
    b.ne    .Lnot_pandigital
    orr     x26, x26, x14
    add     x9, x9, #1
    mov     x11, x12
    b       .Ldig_c

.Lcheck_pandigital:
    // Must have exactly 9 digits, bitmask = 0x3FE (bits 1-9 set)
    cmp     x9, #9
    b.ne    .Lnot_pandigital
    mov     x14, #0x3FE
    cmp     x26, x14
    b.ne    .Lnot_pandigital

    // Check if product c already in products[]
    mov     x11, #0
.Lcheck_dup:
    cmp     x11, x20
    b.ge    .Ladd_product
    ldr     w12, [x19, x11, lsl #2]
    cmp     x12, x25
    b.eq    .Lnot_pandigital        // duplicate, skip
    add     x11, x11, #1
    b       .Lcheck_dup

.Ladd_product:
    str     w25, [x19, x20, lsl #2]
    add     x20, x20, #1

.Lnot_pandigital:
    add     x22, x22, #1
    b       .Lb_loop
.Lb_done:
    add     x21, x21, #1
    b       .La_loop
.La_done:

    // Sum all products
    mov     x0, #0
    mov     x1, #0
.Lsum_loop:
    cmp     x1, x20
    b.ge    .Lsum_done
    ldr     w2, [x19, x1, lsl #2]
    add     x0, x0, x2
    add     x1, x1, #1
    b       .Lsum_loop
.Lsum_done:

    add     sp, sp, #96
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret

// Problem 033: Digit Cancelling Fractions
// Find the denominator of the product of the four "curious" fractions in lowest terms.
// Answer: 100

.global _solve
.align 4

_solve:
    // num_product = 1, den_product = 1
    mov     x8, #1                   // num_product
    mov     x9, #1                   // den_product

    // for a = 1; a <= 9
    mov     x1, #1
.La_loop:
    cmp     x1, #9
    b.gt    .La_done

    // for b = 1; b <= 9
    mov     x2, #1
.Lb_loop:
    cmp     x2, #9
    b.gt    .Lb_done

    // for c = 1; c <= 9
    mov     x3, #1
.Lc_loop:
    cmp     x3, #9
    b.gt    .Lc_done

    // for d = 1; d <= 9
    mov     x4, #1
.Ld_loop:
    cmp     x4, #9
    b.gt    .Ld_done

    // num = a*10 + b
    mov     x5, #10
    mul     x5, x1, x5
    add     x5, x5, x2              // num

    // den = c*10 + d
    mov     x6, #10
    mul     x6, x3, x6
    add     x6, x6, x4              // den

    // if num >= den, skip
    cmp     x5, x6
    b.ge    .Ld_next

    // if b == c && a * den == num * d
    cmp     x2, x3
    b.ne    .Ld_next

    mul     x10, x1, x6             // a * den
    mul     x11, x5, x4             // num * d
    cmp     x10, x11
    b.ne    .Ld_next

    mul     x8, x8, x5              // num_product *= num
    mul     x9, x9, x6              // den_product *= den

.Ld_next:
    add     x4, x4, #1
    b       .Ld_loop
.Ld_done:
    add     x3, x3, #1
    b       .Lc_loop
.Lc_done:
    add     x2, x2, #1
    b       .Lb_loop
.Lb_done:
    add     x1, x1, #1
    b       .La_loop
.La_done:

    // gcd(num_product, den_product)
    mov     x1, x8                   // a = num_product
    mov     x2, x9                   // b = den_product
.Lgcd:
    cbz     x2, .Lgcd_done
    udiv    x3, x1, x2
    msub    x3, x3, x2, x1          // a % b
    mov     x1, x2
    mov     x2, x3
    b       .Lgcd
.Lgcd_done:
    // x1 = gcd
    udiv    x0, x9, x1              // den_product / gcd

    ret

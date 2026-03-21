// Problem 009: Special Pythagorean Triplet
// Find the Pythagorean triplet where a + b + c = 1000, return a*b*c.
// Answer: 31875000
//
// Algorithm: O(n) - derive b algebraically from both constraints.

.global _solve
.align 4

.set S, 1000

// long long solve(void)
_solve:
    mov     w1, #1              // w1 = a
    mov     w10, #S

.La_loop:
    // a < s/3 => a < 333
    cmp     w1, #333
    b.ge    .Lnot_found

    // numerator = s*s - 2*s*a
    mul     w2, w10, w10        // s*s = 1000000
    lsl     w3, w10, #1         // 2*s
    mul     w3, w3, w1          // 2*s*a
    sub     w2, w2, w3          // w2 = numerator

    // denominator = 2*s - 2*a = 2*(s-a)
    sub     w4, w10, w1         // s - a
    lsl     w4, w4, #1          // w4 = denominator = 2*(s-a)

    // if numerator % denominator != 0, skip
    udiv    w5, w2, w4          // w5 = b = numerator / denominator
    msub    w6, w5, w4, w2      // w6 = numerator % denominator
    cbnz    w6, .La_next

    // c = s - a - b
    sub     w7, w10, w1         // s - a
    sub     w7, w7, w5          // w7 = c

    // Check a < b && b < c
    cmp     w1, w5
    b.ge    .La_next
    cmp     w5, w7
    b.ge    .La_next

    // Check a*a + b*b == c*c
    mul     w8, w1, w1          // a*a
    mul     w9, w5, w5          // b*b
    add     w8, w8, w9          // a*a + b*b
    mul     w9, w7, w7          // c*c
    cmp     w8, w9
    b.ne    .La_next

    // Return a*b*c (use 64-bit to avoid overflow)
    sxtw    x0, w1
    sxtw    x1, w5
    sxtw    x2, w7
    mul     x0, x0, x1
    mul     x0, x0, x2
    ret

.La_next:
    add     w1, w1, #1
    b       .La_loop

.Lnot_found:
    mov     x0, #0
    ret

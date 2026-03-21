// Problem 004: Largest Palindrome Product
// Find the largest palindrome made from the product of two 3-digit numbers.
// Answer: 906609
//
// Algorithm: Generate 6-digit palindromes descending, check if factorable
// into two 3-digit numbers.

.global _solve
.align 4

// long long solve(void)
_solve:
    // Loop: a from 9 down to 1
    mov     w1, #9              // w1 = a
.La_loop:
    cmp     w1, #1
    b.lt    .Lnot_found

    // Loop: b from 9 down to 0
    mov     w2, #9              // w2 = b
.Lb_loop:
    cmp     w2, #0
    b.lt    .La_next

    // Loop: c from 9 down to 0
    mov     w3, #9              // w3 = c
.Lc_loop:
    cmp     w3, #0
    b.lt    .Lb_next

    // palindrome = 100001*a + 10010*b + 1100*c
    movz    w4, #0x86A1
    movk    w4, #0x1, lsl #16   // w4 = 100001
    mul     w5, w1, w4          // 100001*a
    mov     w4, #10010
    mul     w6, w2, w4          // 10010*b
    add     w5, w5, w6
    mov     w4, #1100
    mul     w6, w3, w4          // 1100*c
    add     w5, w5, w6          // w5 = palindrome

    // Check if palindrome is factorable: i from 999 down to 100
    mov     w6, #999            // w6 = i
.Li_loop:
    cmp     w6, #100
    b.lt    .Lc_next

    // if i*i < palindrome, break
    mul     w7, w6, w6
    cmp     w7, w5
    b.lt    .Lc_next

    // if palindrome % i == 0
    udiv    w8, w5, w6          // w8 = palindrome / i
    msub    w9, w8, w6, w5      // w9 = palindrome % i
    cbnz    w9, .Li_next

    // j = palindrome / i; check 100 <= j <= 999
    cmp     w8, #100
    b.lt    .Li_next
    cmp     w8, #999
    b.gt    .Li_next

    // Found! Return palindrome
    mov     x0, x5
    ret

.Li_next:
    sub     w6, w6, #1
    b       .Li_loop

.Lc_next:
    sub     w3, w3, #1
    b       .Lc_loop

.Lb_next:
    sub     w2, w2, #1
    b       .Lb_loop

.La_next:
    sub     w1, w1, #1
    b       .La_loop

.Lnot_found:
    mov     x0, #0
    ret

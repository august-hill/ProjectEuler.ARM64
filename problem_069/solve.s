// Problem 69: Totient Maximum
// n/phi(n) is maximized when n is the product of consecutive primes.
// 2 * 3 * 5 * 7 * 11 * 13 * 17 = 510510
// Answer: 510510

.global _solve
.align 4

_solve:
    // 510510 = 0x7CA2E
    movz x0, #0xCA2E
    movk x0, #0x0007, lsl #16
    ret
